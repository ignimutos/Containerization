#!/bin/bash
if [[ -n $GITHUB_TOKEN ]]; then
  github_header='--header "Authorization: Bearer '$GITHUB_TOKEN'"'
fi

github_tag() {
  if [[ -z $1 ]]; then
    echo "Error: github_tag param not present"
    return 1
  fi
  curl -s $github_header \
    "https://api.github.com/repos/$1/tags?per_page=1&page=1" | jq -r '.[0].name' | sed 's/^v//'
}

github_sha() {
  if [[ -z $1 ]]; then
    echo "Error: github_tag param not present"
    return 1cat
  fi
  curl -s $github_header \
    "https://api.github.com/repos/$1/commits?per_page=1&page=1" | jq -r '.[0].sha'
}

regex_match() {
  curl -s "$1" | perl -ne 'if (/'"$2"'/) { print "$1" }'
}
