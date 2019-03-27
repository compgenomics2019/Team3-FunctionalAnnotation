#!/bin/bash

#Usage statement
usage () {
	echo "Usage: rename.bash -c <card.json> -m <card_model> -p <input_prot>
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
	if [ -z "$c" ]; then
		echo "A non-empty string for card.json path must be given. Exiting the program."
		usage
		exit 1
	fi
	if [ -z "$m" ]; then
		echo "A non-empty string for card model path must be given. Exiting the program."
		usage
		exit 1
	fi
}

homology() {
	# Run the homology based tools

	
	#Door2 - Operon Prediction
	mydir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	"$mydir"/door2blast.py -i $prot -o door2_out

	#VFDB - Virulence Factors
	"$mydir"/vfdbblast.py -i $prot -o vfdb_out
	
	# InterProScan
	interproscan.sh -i $prot -o intPro_out -f gff3
	
	# SWITCHING TO PYTHON2!
	alias python=python2.7
	# eggNOG
	python emapper.py -i $prot --output eggNOG_temp_out -d bact -m diamond
	# Reformat egg output
	python eggNogGff.py -e eggNOG_temp_out -o eggNOG_out
	
	# CARD
	rgi load -i $c --card_annotation $m --local
	rgi main -i $prot -o card_out --input_type protein --local
	python3 convert_rgi.py -m $o
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
