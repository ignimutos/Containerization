#!/bin/bash
build() {
  local dir=$1
  pushd "$dir"
  local config
  if [[ -s config.yml ]]; then
    config=$(cat config.yml)
  else
    config=""
  fi
  local repo=$(yq '.name // "'$(basename $dir)'"' <<<$config)
  local version_top=$(yq '.version // ""' <<<$config)
  if [[ -n $version_top ]]; then
    version_top=$(bash -c "$version_top")
  fi
  local count=$(yq '.targets | length' <<<$config)
  if [[ $count -eq 0 ]]; then
    # run at least once
    count=1
  fi
  for ((i = 0; i < count; i++)); do
    local target=$(yq '.targets['$i'] // ""' <<<$config)
    local version=$(yq '.version // ""' <<<$target)
    if [[ -z $version ]]; then
      if [[ -n $version_top ]]; then
        version=$version_top
      fi
    else
      version=$(bash -c "$version")
    fi
    local sha=$(yq '.sha // ""' <<<$target)
    if [[ -n $sha ]]; then
      sha=$(bash -c "$sha")
    fi
    local build_target=$(yq '.target // ""' <<<$target)
    local name=$(yq '.name // ""' <<<$target)
    name=${name:-$build_target}
    if ! checkver "$repo" "$name" "$version" "$sha" && [[ $FORCE != "true" ]]; then
      echo "is newest version: $version"
      continue
    fi
    local latest=$(union $name latest)
    local latest_version=$(union $name $version)
    if [[ -z $build_target ]]; then
      if [[ -n $name ]]; then
        build_target="--target $name"
      fi
    else
      build_target="--target $build_target"
    fi

    local dockerfile=$(yq '.dockerfile // "Dockerfile"' <<<$target)
    echo "Build name: $name, version: $version, dockerfile: $dockerfile"

    if [[ $DEBUG == "true" ]]; then
      docker build \
        --load $build_target \
        --build-arg VERSION=$version \
        -t $REGISTRY_USER/$repo:$latest \
        -f $dockerfile \
        .
      if [[ -n $latest_version ]]; then
        docker tag $REGISTRY_USER/$repo:$latest $REGISTRY_USER/$repo:$latest_version
      fi
    else
      local latest_version_tag=()
      if [[ -n $latest_version ]]; then
        latest_version_tag=("-t" "$REGISTRY_USER/$repo:$latest_version")
      fi
      local platform_tag=()
      if [[ -n $PLATFORM ]]; then
        platform_tag=("--platform" "$PLATFORM")
      fi
      if ! docker buildx build \
        --push $build_target \
        "${platform_tag[@]}" \
        --build-arg VERSION=$version \
        "${latest_version_tag[@]}" \
        -t $REGISTRY_USER/$repo:$latest \
        -f $dockerfile \
        .; then
        echo "Failed to build $REGISTRY_USER/$repo:$latest_version" >&2
        exit 1
      fi
    fi
  done
  popd
}

checkver() {
  local path=$(union $1 $2)
  local version=$(union $3 $4)
  touch "$version_file"
  version_last=$(yq '."'$path'" // ""' "$version_file")
  if [[ $version == $version_last ]]; then
    return 1
  elif [[ -n $version ]]; then
    yq -i '.'$path' = "'$version'"' "$version_file"
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

resolve_version_file() {
  local candidate

  if [[ -n $VERSION_FILE ]]; then
    candidate=$(realpath -m "$VERSION_FILE")
  elif [[ -d "$base_dir/../version" ]] || [[ -f "$base_dir/../version/version.yml" ]]; then
    # GitHub Actions 场景：version 分支 checkout 到同级目录 version/
    candidate=$(realpath -m "$base_dir/../version/version.yml")
  elif [[ -f "$base_dir/version.yml" ]]; then
    candidate=$(realpath -m "$base_dir/version.yml")
  elif [[ -f "$base_dir/../version.yml" ]]; then
    candidate=$(realpath -m "$base_dir/../version.yml")
  else
    candidate=$(realpath -m "$base_dir/version.yml")
  fi

  # 兼容 VERSION_FILE 传入目录
  if [[ -d $candidate ]]; then
    candidate=$(realpath -m "$candidate/version.yml")
  fi

  echo "$candidate"
}

set -e
base_dir=$(cd "$(dirname "$0")" &>/dev/null && pwd)
source "$base_dir/methods.sh"
export -f regex_match github_tag github_sha alpine_pkg
version_file=$(resolve_version_file)
mkdir -p "$(dirname "$version_file")"
if [[ $# -eq 0 ]]; then
  find "$base_dir" -mindepth 1 -maxdepth 1 -type d ! -name ".git*" | while read -r dir; do
    build "$dir" 2>&1 | sed "s#^#[$(basename $dir)] => #"
  done
else
  for target in $@; do
    build "$base_dir/$target" 2>&1 | sed "s#^#[$target] => #"
  done
fi
