#!/bin/bash

cwd_dir=${1:-$PWD}

echo "iris-bc: Checking for class directory at $cwd_dir ..."

if [[ -d "$cwd_dir/cls" ]]; then
  echo "iris-bc: Found class directory. Swapping IRIS expressions for Caché back compatibility ..."

  find $cwd_dir/cls -type f -iname '*.cls' -exec sh -c 'cat "$1" | sed "s/%Storage.Persistent/%Library.CacheStorage/g" > "$1.bak" && mv "$1.bak" "$1"' sh {} \;
  find $cwd_dir/cls -type f -iname '*.cls' -exec sh -c 'cat "$1" | sed "s/%Storage.SQL/%CacheSQLStorage/g" > "$1.bak" && mv "$1.bak" "$1"' sh {} \;
  find $cwd_dir/cls -type f -iname '*.cls' -exec sh -c 'cat "$1" | sed "s/%Any/%CacheString/g" > "$1.bak" && mv "$1.bak" "$1"' sh {} \;
  find $cwd_dir/cls -type f -iname '*.cls' -exec sh -c 'cat "$1" | sed "s/\[ Language = objectscript \]/\[ Language = cache \]/g" > "$1.bak" && mv "$1.bak" "$1"' sh {} \;
fi

echo "iris-bc: Done."

exit 0

