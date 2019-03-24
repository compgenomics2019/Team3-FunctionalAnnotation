#!/bin/bash

while getopts "i:o:h" option
do
        case $option in
             i) input=$OPTARG;;
             o) output=$OPTARG;;
             h) echo "pilercr.bash -i <Input File Name> -o <Output File Name>"
                echo "Required Arguments"
                echo "-i Name of Input file. Needs to be a Fasta Nucleotide file"
                echo "-o Name of Output File."
                exit 0;
        esac
done

pilercr -in $input -out $output -quiet -noinfo


