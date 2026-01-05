#!/bin/bash

cwd_dir=${1:-$PWD}

find_and_replace() {
  category="$1"

  echo "strip-atelier-headers: Scanning for files in $cwd_dir/$category"

  if [[ -d "$cwd_dir/$category" ]]; then
    echo "strip-atelier-headers: Files for category $category were found. Stripping ..."
    find "$cwd_dir/$category" -type f -iname "*.$category" -exec sh -c 'grep -v "ROUTINE\s.*\[Type=.*\]" "$1" > "$1.bak" && mv "$1.bak" "$1"' sh {} \;
  else
    echo "strip-atelier-headers: Category $category has been skipped: No entries were found at the destination."
  fi
}

find_and_replace "inc"
find_and_replace "int"
find_and_replace "mac"

echo "strip-atelier-headers: Done."

exit 0
