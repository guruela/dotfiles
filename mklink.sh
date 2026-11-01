#!/usr/bin/env bash

mklink() {
  if [ "$#" -ne 2 ]; then
      echo "Error: Wrong number of arguments."
      echo "Usage: make_symlink <target_file> <link_name>"
      return 1
  fi

  local target=$(realpath "$1")
  local link=$(realpath "$2")

  if [ ! -e "$target" ]; then
      echo "Error: Target '$target' does not exist."
      return 1
  fi

  ln -s "$target" "$link"
  
  echo "Success: Created symlink '$target' -> '$link'"
}
