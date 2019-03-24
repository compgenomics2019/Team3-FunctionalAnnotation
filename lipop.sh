#!/bin/bash

while getopts "i:o:h" option
do
        case $option in
             i) input=$OPTARG;;
             o) output=$OPTARG;;
             h) echo "lipop.bash -i <Input File Name> -o <Output File Name>"
                echo "Required Arguments"
                echo "-i Name of Input file. Needs to be a Protein Fasta file"
                echo "-o Saves the summary output file to given name"
                echo "Script below provides details for all predicted Lipoproteins. Provides plots for each predicted protein as well."
                exit 0;
        esac
done

LipoP $input > $output


