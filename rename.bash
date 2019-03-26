#!/bin/bash

#Author: George Gruenhagen
#Purpose: Call the variants in the bam files

#Usage statement
usage () {
	echo "Usage: rename.bash -D <faa_dir>
	-D directory of faa files (must use -I or -D)
	-O output directory of new renamed faa files
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
	
	faaDir=""
	outDir=""
	while getopts "I:D:O:S:L:XL:P:N:l:t:q:j:o:m:M:c:h" opt; do
		case $opt in
		D ) faaDir=$OPTARG;;
		O ) outDir=$OPTARG;;
		h ) usage; exit 0;
		esac
	done
}

check_files() {

	if [ -z "$faaDir" ]; then
		echo "a directory of faa files must be given.Exiting the program."
		usage
		exit 1
	fi
	
	if [ -z "$outDir" ]; then
		echo "an output directory must be given.Exiting the program."
		usage
		exit 1
	fi
	
	for file in $faaDir/*.faa; do
		if [ -f "$file" ]; then
			while read p; do
				file=${file##*/}
				if [[ $p == \>* ]]; then 
					p="${p}_${file}"
					# echo "$p"
				fi
				name=${file##*/}
				outFile="${outDir}/${name}"
				echo "$p" >> $outFile
			done < $file
			echo "finished file: $file"
		fi
	done

	
}


main() {
	get_input "$@"
	check_files
}


main "$@"