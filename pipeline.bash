#!/bin/bash

#Usage statement
usage () {
	echo "Usage: rename.bash -c <card.json> -m <card_model> -p <input_prot> -o <output_name> 
	Required Arguments:
	-c path/to/card.json
	-m path/to/model
	-p name of the input faa file that clustered proteins
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
	
	prot=""
	c=""
	m=""
	while getopts "p:c:m:h" opt; do
		case $opt in
		p ) prot=$OPTARG;;
		c ) c=$OPTARG;;
		m ) m=$OPTARG;;
		h ) usage; exit 0;
		esac
	done
}

check_files() {
	# Check to see if input files are actual files
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
	protExtension="${prot##*.}"
	if [ "$gffExtension" != "gff" ] && [ "$gff" != "gff3" ]; then
		echo "The input gff file does not have a gff or gff3 extension. Exiting the program."
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
	
	# CARD
	conda activate function_annotation
	
	rgi load -i $c --card_annotation $m --local
	rgi main -i $prot -o card_out --input_type protein --local
	
	#Door2 - Operon Prediction
	mydir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	"$mydir"/door2blast.py -i $prot -o door2_out

	#VFDB - Virulence Factors
	"$mydir"/vfdbblast.py -i $prot -o vfdb_out

	conda deactivate
	
	# eggNOG
	python emapper.py -i $prot --output eggNOG_temp_out -d bact -m diamond
	# Reformat egg output
	python "$mydir"/eggNogGff.py -e eggNOG_temp_out -o eggNOG_out
	
	# InterProScan
	# SWITCHING TO PYTHON3!
	alias python=python3
	interproscan.sh -i $prot -o intPro_out -f gff3
}

merge() {
	# Merge the output of the all the tools together into a gff file
	# Concatenate the output files together
	cat eggNOG_out card_out door2_out vfdb_out intPro_out > final_out.gff
}

main() {
	get_input "$@"
	check_files
	homology
	merge
}


main "$@"
