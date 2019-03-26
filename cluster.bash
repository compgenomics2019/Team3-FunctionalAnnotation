#!/bin/bash

#Author: George Gruenhagen
#Purpose: Call the variants in the bam files

#Usage statement
usage () {
	echo "Usage: cluster.bash -I <input_dir>
	-I input directory
	"
}

#Command-line options
get_input() {
	check_for_help "$1"
	
	inDir=""
	while getopts "I:h" opt; do
		case $opt in
		I ) inDir=$OPTARG;;
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

cluster() {
	cat $inDir/*.faa > merged.faa
	cd-hit -i clust_prot.faa -o nr95 -c 0.95 -s 0.95 -d 0
}

main() {
	get_input "$@"
	check_files
	cluster
}


main "$@"