#!/bin/bash

#Author: George Gruenhagen
#Purpose: Call the variants in the bam files

#Usage statement
usage () {
	echo "Usage: gffToFasta.bash -A <annotated_dir> -G <genome_dir>
	-A directory of annotated gff files
	-G directory of genome directories containing scaffolds.fasta
	-O output directory of annotated fasta files
	"
}

check_for_help() {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		usage;
		exit 0;
	fi
}

#Command-line options
get_input() {
	check_for_help "$1"
	
	genomeDir=""
	gffDir=""
	outDir=""
	while getopts "A:G:O:h" opt; do
		case $opt in
		A ) gffDir=$OPTARG;;
		G ) genomeDir=$OPTARG;;
		O ) outDir=$OPTARG;;
		h ) usage; exit 0;
		esac
	done
}

check_files() {

	if [ -z "$genomeDir" ]; then
		echo "A directory of genomes must be given.Exiting the program."
		usage
		exit 1
	fi
	
	if [ -z "$gffDir" ]; then
		echo "A directory of annotated gff files be given.Exiting the program."
		usage
		exit 1
	fi
	
	if [ -z "$outDir" ]; then
		echo "An output directory must be given.Exiting the program."
		usage
		exit 1
	fi
	
	for file in $gffDir/*.gff; do
		genome=${file##*/}
		name=${genome%.*}
		genome="$(cut -d'_' -f1 <<< $name)"
		genome="$genomeDir/$genome.fasta"
		echo $genome
		[[ ! -f $genome ]] && continue
		echo "exists!"
		outputFile="$outDir/""$name.fna"
		outputFile2="$outDir/""$name.faa"
		cat $file | awk -F'\t' '{print $1 "\t" $2 "\t" $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' > temp.gff
		bedtools getfasta -fi $genome -bed temp.gff -fo $outputFile -name
	done
	
	for file in $outDir/*.fna; do
		outputFile2=${file%.*}
		outputFile2="$outputFile2.faa"
		echo "Translating $file"
		/projects/team3/func_annot/miniconda3/envs/annotation/bin/transeq $file $outputFile2 -frame=1 -trim -sformat pearson
		echo "Done"
	done
}


main() {
	get_input "$@"
	check_files
}


main "$@"