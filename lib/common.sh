#!/usr/bin/env bash

export BUILDPACK_STDLIB_URL="https://lang-common.s3.amazonaws.com/buildpack-stdlib/v7/stdlib.sh"

get_parent_directory() {
    local path="$1"

    # Use dirname to get the parent directory
    local parent_directory=$(dirname "$path")

    # Print the result
    echo "$parent_directory"
}

create_folder_cache_symlink() {
  local buildpackCacheDir="${1:?}/simple-cache-buildpack/${2:?}"
  local projectCacheLink="${2:?}"

  # Check if linked directory (from CACHE_DIR) exists in the project, if yes, do not link for safety reasons
  # because it is OK to assume that whatever is in PROJECT_DIR is more up-to-date than CACHE_DIR
  if [ ! -d "$projectCacheLink" ]; then
      echo "       linking $projectCacheLink from cache..."
      mkdir -p "$buildpackCacheDir"
      mkdir -p "$projectCacheLink"
      ln -s "$(get_parent_directory "$projectCacheLink")" "$projectCacheLink"
      #trap "rm -f $projectCacheLink" EXIT
  else
      echo "       Warning: $projectCacheLink was not linked form cache, because it exists in the repo"
  fi
}

# sed -l basically makes sed replace and buffer through stdin to stdout
# so you get updates while the command runs and dont wait for the end
# e.g. sbt stage | indent
output() {
  local logfile="$1"
  local c='s/^/       /'

  case $(uname) in
    Darwin) tee -a "$logfile" | sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      tee -a "$logfile" | sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}