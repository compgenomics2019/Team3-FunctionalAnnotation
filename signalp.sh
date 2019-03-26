#!/bin/bash

while getopts "i:o:h" option
do
        case $option in
             i) input=$OPTARG;;
             o) org=$OPTARG;;
             h) echo "signalp.bash -i <Input File Address> -o <Organism Type>"
                echo "Required Arguments"
                echo "-i Name of Input file. Needs to be a Fasta file"
                echo "-o Organism. Archaea: 'arch', Gram-positive: 'gram+', Gram-negative: 'gram-' or Eukarya: 'euk'"
                exit 0;
        esac
done

signalppath=$(which signalp)
$signalppath -fasta $input -org $org -format short -gff3 -prefix signalpOut

