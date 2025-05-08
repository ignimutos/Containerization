#!/bin/bash
build() {
  local dir=$1
  pushd "$dir"
  if [[ ! -s config.yml ]]; then
    echo 2>&1 "config.yml not found"
    exit 1
  fi
  local config=$(cat config.yml)
  local repo=$(yq '.name // "'$(basename $dir)'"' <<<$config)
  local version_top=$(yq '.version // ""' <<<$config)
  if [[ -n version_top ]]; then
    version_top=$(bash -c "$version_top")
  fi
  for ((i = 0; ; i++)); do
    local target=$(yq '.targets['$i'] // ""' <<<$config)
    if [[ -z $target ]]; then
      break
    fi

    local version=$(yq '.version // ""' <<<$target)
    if [[ -z $version ]]; then
      if [[ -z $version_top ]]; then
        break
      fi
      version=$version_top
    else
      version=$(bash -c "$version")
    fi
    local sha=$(yq '.sha // ""' <<<$target)
    if [[ -n $sha ]]; then
      sha=$(bash -c "$sha")
    fi
    local name=$(yq '.name // ""' <<<$target)
    if ! checkver "$repo" "$name" "$version" "$sha" && [[ $FORCE != "true" ]]; then
      echo "is newest version: $version"
      continue
    fi

    local latest=$(union $name latest)
    local latest_version=$(union $name $version)
    local build_target
    if [[ -z $name ]]; then
      build_target=""
    else
      build_target="--target $name"
    fi

    local dockerfile=$(yq '.dockerfile // "Dockerfile"' <<<$target)

    if [[ $DEBUG == "true" ]]; then
      docker build \
        --load $build_target \
        --build-arg version=$version \
        -t $REGISTRY_USER/$repo:$latest \
        -f $dockerfile \
        .
      docker tag $REGISTRY_USER/$repo:${prefix}latest $REGISTRY_USER/$repo:$latest_version
    else
      docker buildx build \
        --push $build_target \
        --platform $PLATFORM \
        --build-arg version=$version \
        -t $REGISTRY_USER/$repo:$latest_version \
        -t $REGISTRY_USER/$repo:$latest \
        -f $dockerfile \
        .
    fi
  done
  popd
}

checkver() {
  local path=$(union $1 $2)
  local version=$(union $3 $4)
  touch "$version_dir/version.yml"
  version_last=$(yq '."'$path'" // ""' "$version_dir/version.yml")
  echo $version,$version_last
  if [[ $version == $version_last ]]; then
    return 1
  elif [[ -n $version ]]; then
    yq -i '.'$path' = "'$version'"' "$version_dir/version.yml"
    return 0
  fi
}

union() {
  local arr=()
  for e in $@; do
    if [[ "$e" == "null" ]] || [[ "$e" == "base" ]] || [[ -z "$e" ]]; then
      continue
    fi
    arr+=("$e")
  done
  IFS='-'
  echo "${arr[*]}"
  unset IFS
}

set -e
base_dir=$(cd "$(dirname "$0")" &>/dev/null && pwd)
version_dir=$(realpath -m "$base_dir/../version")
if [[ $# -eq 0 ]]; then
  find "$base_dir" -mindepth 1 -maxdepth 1 -type d ! -name ".git*" | while read -r dir; do
    build "$dir" 2>&1 | sed "s#^#[$(basename $dir)] => #"
  done
else
  for target in $@; do
    build "$base_dir/$target" 2>&1 | sed "s#^#[$target] => #"
  done
fi
