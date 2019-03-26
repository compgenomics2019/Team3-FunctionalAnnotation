#!/bin/bash

#Author: George Gruenhagen
#Purpose: Call the variants in the bam files

#Usage statement
usage () {
	echo "Usage: total_pipeline.bash -i <input_dir> -a <assembled_genome_dir> -c <card.json> -m <card_model> -o <output_name> -t <org_type>
	Required Arguments:
	-i input directory containing gff, fna, and faa files
	-o desired name of the annotated output dir. This will included annotated nucleotide, protein, and gff files.
	-a assembled genome directory
	-c path/to/card.json
	-m path/to/model
	-t Type of Organism - Required for SignalP. Archaea: 'arch', Gram-positive: 'gram+', Gram-negative: 'gram-' or Eukarya: 'euk'
	"
}

get_input() {
	check_for_help "$1"
	
	assembledGenome=""
	inDir=""
	out=""
	c=""
	m=""
	org=""
	while getopts "i:a:o:c:m:t:h" opt; do
		case $opt in
		i ) inDir=$OPTARG;;
		a ) assembledGenome=$OPTARG;;
		o ) out=$OPTARG;;
		c ) c=$OPTARG;;
		m ) m=$OPTARG;;
		t ) org=$OPTARG;;
		h ) usage; exit 0;
		esac
	done
}

check_for_help() {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		usage;
		exit 0;
	fi
}

main() {
	get_input "$@"
	
	# Cluster
	./cluster.bash -I $inDir > log
	
	# Call tools on clust_prot.faa
	# output should be called merged.gff
	
	# Call tools on assembledGenome
	
	# remap clustered proteins to gff files
	# python ./remap.py -g merged.gff -c nr95.clstr -d $inDir
	
	# merge gffs from tools that used clustered proteins with tools that didn't
	
	
}


main "$@"