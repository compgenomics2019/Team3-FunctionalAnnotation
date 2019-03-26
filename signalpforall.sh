#!/bin/bash

while getopts "i:o:t:h" option
do
	case $option in
	     i) input=$OPTARG;;
			 o) output=$OPTARG;;
	     t) org=$OPTARG;;
	     h) echo "signalp.bash -i <Input File Directory> -f <Output Format> -o <Organism Type>"
					echo "Required Arguments"
	        echo "-i Name of Input file Directory. Input Needs to be a Protein Fasta file. The script assumes the files are in .faa or .fasta format"
					echo "-o Name of Output file Directory. Please ensure directory exists before running script"
        	echo "-t Organism. Archaea: 'arch', Gram-positive: 'gram+', Gram-negative: 'gram-' or Eukarya: 'euk'"
 		exit 0;
	esac
done

signalppath=$(which signalp)
#echo $signalppath
cd $input
for f in *.faa
  do
  #echo $f
	f2=${f%.faa}
	echo $f2
	$signalppath -fasta $f -org $org -format short -gff3 -prefix $output/$f2
  done

for f in *.fasta
	  do
	  #echo $f
		f2=${f%.fasta}
		echo $f2
		$signalppath -fasta $f -org $org -format short -gff3 -prefix $output/$f2
	  done
	

