#!/bin/bash

#Usage statement
usage () {
	echo "Usage: rename.bash -g <input_gff> -n <input_nucl> -p <input_prot> -o <output_name>
	Required Arguments:
	-g name of the input gff file that contains predicted genes
	-n name of the input fna file that contains predicted genes
	-p name of the input faa file that contains predicted proteins
	-o desired name of the annotated output files. This will included annotated nucleotide, protein, and gff files.
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
	
	gff=""
	nucl=""
	prot=""
	out=""
	while getopts "g:n:p:o:h" opt; do
		case $opt in
		g ) gff=$OPTARG;;
		n ) nucl=$OPTARG;;
		p ) prot=$OPTARG;;
		o ) out=$OPTARG;;
		h ) usage; exit 0;
		esac
	done
	
	outGff="$out.gff"
	outNucl="$out.fna"
	outProt="$out.faa"
}

check_files() {
	# Check to see if input files are actual files
	if [ -z "$gff" ] || [ ! -f "$gff" ]; then
		echo "A valid gff file must be given. Exiting the program."
		usage
		exit 1
	fi
	if [ -z "$nucl" ] || [ ! -f "$nucl" ]; then
		echo "A valid input fna file must be given. Exiting the program."
		usage
		exit 1
	fi
	if [ -z "$prot" ] || [ ! -f "$prot" ]; then
		echo "A valid input faa file must be given. Exiting the program."
		usage
		exit 1
	fi
	if [ -z "$out" ]; then
		echo "A non-empty string for the output file must be given. Exiting the program."
		usage
		exit 1
	fi
	
	# Check to see if the input files have the correct extensions
	gffExtension="${gff##*.}"
	nuclExtension="${nucl##*.}"
	protExtension="${prot##*.}"
	if [ "$gffExtension" != "gff" ] && [ "$gff" != "gff3" ]; then
		echo "The input gff file does not have a gff or gff3 extension. Exiting the program."
		usage
		exit 1
	fi
	if [ "$nuclExtension" != "fna" ] && [ "$nuclExtension" != "fasta" ] && [ "$nuclExtension" != "fa" ]; then
		echo "The input nucleotide sequences do not have a fna, fasta, nor fa file extension. Exiting the program."
		usage
		exit 1
	fi
	if [ "$protExtension" != "faa" ] && [ "$protExtension" != "fasta" ] && [ "$protExtension" != "fa" ]; then
		echo "The input protein sequences do not have a faa, fasta, nor fa file extension. Exiting the program."
		usage
		exit 1
	fi
	
}

homology() {
	# Run the homology based tools
	
}

ab_initio() {
	# Run the ab initio based tools
	
}

merge() {
	# Merge the output of the all the tools together into a gff file
	# Concatenate the output files together
}

annotate_fast() {
	# Take the annotations from the gff file and give those annotation to the fasta files
	# ie the nucleotide sequences and protein sequences
	
}

main() {
	get_input "$@"
	check_files
	homology
	ab_initio
	merge
	annotate_fasta
}


main "$@"