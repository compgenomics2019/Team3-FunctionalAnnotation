#!/bin/bash

while getopts "i:f:o:h" option
do
        case $option in
             i) input=$OPTARG;;
             f) format=$OPTARG;;
             o) org=$OPTARG;;
             h) echo "signalp.bash -i <Input File Address> -f <Output Format> -o <Organism Type>"
                echo "Required Arguments"
                echo "-i Name of Input file. Needs to be a Fasta file"
                echo "-f Output format. 'long' for generating the predictions with plots, 'short' for the predictions without plots."
                echo "-o Organism. Archaea: 'arch', Gram-positive: 'gram+', Gram-negative: 'gram-' or Eukarya: 'euk'"
                exit 0;
        esac
done

signalp -fasta $input -org $org -format $format 


