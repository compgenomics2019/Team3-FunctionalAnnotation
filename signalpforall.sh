#!/bin/bash

while getopts "i:o:h" option
do
	case $option in
	     i) input=$OPTARG;;
	     o) org=$OPTARG;;
	     h) echo "signalpforall.bash -i <Input File Directory - Only .faa files> -o <Organism Type>"
		echo "Required Arguments"
	        echo "-i Name of Input file Directory. Input Needs to be a Protein Fasta file. The script assumes the files are in .faa format"
        	echo "-o Organism. Archaea: 'arch', Gram-positive: 'gram+', Gram-negative: 'gram-' or Eukarya: 'euk'"
 		exit 0;
	esac
done


mkdir tempsignalpout
signalppath=$(which signalp)
for file in $input*.faa
  do
	f="$(echo $file | rev | cut -d/ -f1 | rev )"
  	#echo $f
	f2=${f%.faa}
	#echo $f2
	$signalppath -fasta $file -org $org -format short -gff3 -prefix tempsignalpout/$f2
  done
