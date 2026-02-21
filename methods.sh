#!/bin/bash
github_opts=()
if [[ -n $GITHUB_TOKEN ]]; then
  github_opts+=("--header" "Authorization: Bearer $GITHUB_TOKEN")
fi

github_tag() {
  local repo=$1
  local regex=$2
  if [[ -z $repo ]]; then
    echo "Error: param not present"
    return 1
  fi
  local tag=$(curl -s ${github_opts[@]} "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
  if [[ -n "$regex" ]]; then
    tag=$(echo "$tag" | perl -ne "if (/$regex/) { print \$1 // \$& }")
    if [[ -z $tag ]]; then
      echo "Error: Tag '$tag' does not match regex '$regex'" >&2
      return 1
    fi
  fi
  echo $tag
}

github_sha() {
  if [[ $# -eq 0 ]]; then
    echo "Error: param not present"
    return 1
  fi
  targets=($@)
  sha=()
  for target in $targets; do
    sha+=($(curl -s ${github_opts[@]} \
      "https://api.github.com/repos/$target/commits?per_page=1&page=1" | jq -r '.[0].sha'))
  done
  echo ${sha[*]} | sha256sum | cut -d' ' -f1
}

alpine_pkg() {
  if [[ $# -eq 0 ]]; then
    echo "Error: param not present"
    return 1
  fi
  local target=$1
  local branch=${2:-v3.21}
  local repository=${3:-main}
  regex_match "https://pkgs.alpinelinux.org/package/$branch/$repository/x86_64/$target" "<strong>(.*)<\/strong>"
}

regex_match() {
  curl -s "$1" | perl -ne 'if (/'"$2"'/) { print "$1" }'
}
