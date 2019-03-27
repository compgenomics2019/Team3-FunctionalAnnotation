#!/bin/bash
folder1=$1
folder2=$2
output=$3

rm -r $output
mkdir $output
cd "$folder1"
for file in *.gff3; do
  echo $file
  [[ ! -f $file ]] && continue      # pick up only regular files
  cat $file > "../$output/$file"

  otherfile="../$folder2/$file"
  [[ ! -f $otherfile ]] && continue # skip if there is no matching file in folder 2
  cat "$file" "$otherfile" > "../$output/$file"
  echo "Merged $file"
done
