#!/bin/bash
folder1=$1
folder2=$2
output=$3

rm -r $output
mkdir $output
for file in $folder1/*.gff; do
  outputFile=${file##*/}
  echo $file
  [[ ! -f $file ]] && continue      # pick up only regular files
  cat $file > "/$output/$outputFile"

  otherfile="/$folder2/$outputFile"
  [[ ! -f $otherfile ]] && continue # skip if there is no matching file in folder 2
  cat "$file" "$otherfile" > "/$output/$outputFile"
  echo "Merged $file"
done
