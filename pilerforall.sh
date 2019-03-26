#!/bin/bash

while getopts "i:o:h" option
do
        case $option in
             i) input=$OPTARG;;
             o) output=$OPTARG;;
             h) echo "pilercr.bash -i <Input Directory Name> -o <Output Directory Name>"
                echo "Required Arguments"
                echo "-i Name of Input file directory. All Input files should be in nucleotide fasta format. Script assumes files are only in .fna or .fasta format"
                echo "-o Name of Output file directory. Please make sure directory exists before running script. Gff files will be stored here. "
                exit 0;
        esac
done

cd $input
for f in *.fasta
  do
  echo $f
  pilercr -in $f -out $output/temp_piler_out -quiet -noinfo
  f2=${f%.fasta}.gff
  /home/siddhartha/input/pilertogff.py $output/temp_piler_out $output/$f2
  rm $output/temp_piler_out
  done


for f in *.fna
  do
  echo $f
  pilercr -in $f -out $output/temp_piler_out -quiet -noinfo
  f2=${f%.fna}.gff
  /home/siddhartha/input/pilertogff.py $output/temp_piler_out $output/$f2
  rm $output/temp_piler_out
  done


#pilercr -in $input -out temp_piler_out -quiet -noinfo
#/home/siddhartha/input/pilertogff.py temp_piler_out $output
#rm temp_piler_out

