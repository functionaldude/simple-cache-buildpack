#!/usr/bin/env bash

export BUILDPACK_STDLIB_URL="https://lang-common.s3.amazonaws.com/buildpack-stdlib/v7/stdlib.sh"


# By default gradle will write its cache in `$BUILD_DIR/.gradle`. Rather than
# using the --project-cache-dir option, which muddies up the command, we
# symlink this directory to the cache.
create_project_cache_symlink() {
  echo "-----> linking gradle cache..."
  local buildpackCacheDir="${1:?}/.gradle-project"
  local projectCacheLink="${2:?}/.gradle"
  if [ ! -d "$projectCacheLink" ]; then
    mkdir -p "$buildpackCacheDir"
    ln -s "$buildpackCacheDir" "$projectCacheLink"
    trap "rm -f $projectCacheLink" EXIT
  fi
}

# Make sure to have node_modules in the cache folder
create_node_cache_symlink() {
  echo "-----> linking node_modules cache..."
  local buildpackCacheDir="${1:?}/node-modules"
  local projectCacheLink="${2:?}/build/js/node_modules"
  if [ ! -d "$projectCacheLink" ]; then
    mkdir -p "$buildpackCacheDir"
    mkdir -p "$projectCacheLink"
    ln -s "$buildpackCacheDir" "$projectCacheLink"
    trap "rm -f $projectCacheLink" EXIT
  fi
}

create_folder_cache_symlink() {
  local buildpackCacheDir="${1:?}/simple-cache-buildpack/${2:?}"
  local projectCacheLink="${2:?}"

  # Check if linked directory (from CACHE_DIR) exists in the project, if yes, do not link for safety reasons
  # because it is OK to assume that whatever is in PROJECT_DIR is more up-to-date than CACHE_DIR
  if [ ! -d "$projectCacheLink" ]; then
      echo "-----> linking $projectCacheLink from cache..."
      mkdir -p "$buildpackCacheDir"
      ln -s "$buildpackCacheDir" "$projectCacheLink"
      trap "rm -f $projectCacheLink" EXIT
  else
      echo "-----> $projectCacheLink was not linked form cache, because it exists in the repo"
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

cache_copy() {
  rel_dir=$1
  from_dir=$2
  to_dir=$3
  rm -rf $to_dir/$rel_dir
  if [ -d $from_dir/$rel_dir ]; then
    mkdir -p $to_dir/$rel_dir
    cp -pr $from_dir/$rel_dir/. $to_dir/$rel_dir
  fi
}
