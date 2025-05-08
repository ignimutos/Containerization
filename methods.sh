#!/bin/bash
github_opts=()
if [[ -n $GITHUB_TOKEN ]]; then
  github_opts+=("--header" "Authorization: Bearer $GITHUB_TOKEN")
fi

github_tag() {
  if [[ -z $1 ]]; then
    echo "Error: github_tag param not present"
    return 1
  fi
  curl -s ${github_opts[@]} "https://api.github.com/repos/$1/tags?per_page=1&page=1" | jq -r '.[0].name' | sed 's/^v//'
}

github_sha() {
  if [[ $# -eq 0 ]]; then
    echo "Error: github_tag param not present"
    return 1cat
  fi
  targets=($@)
  sha=()
  for target in $targets; do
    sha+=($(curl -s ${github_opts[@]} \
      "https://api.github.com/repos/$target/commits?per_page=1&page=1" | jq -r '.[0].sha'))
  done
  echo ${sha[*]} | sha256sum | cut -d' ' -f1
}

regex_match() {
  curl -s "$1" | perl -ne 'if (/'"$2"'/) { print "$1" }'
}
