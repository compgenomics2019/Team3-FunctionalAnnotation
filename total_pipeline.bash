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
	
	# Rename input
	echo "Renaming input"
	rm -r inputRenamed
	mkdir inputRenamed
	./rename.bash -D $inDir -O inputRenamed > log
	echo "Done"
	
	# Cluster
	echo "Clustering"
	./cluster.bash -I inputRenamed > log
	echo "Done"
	
	echo "Calling tools on clustered proteins: eggNOG, InterProScan, CARD"
	# Call tools on clust_prot.faa
	# output should be called merged.gff
	echo "Done"
	
	echo "Calling tools on assembled genomes"
	# Call tools on assembledGenome
	echo "Done"
	
	echo "Mapping clustered annotations to the whole cluster. Mapping coordinates back to scaffold coordinates. Mapping files back into 50 files."
	# remap clustered proteins to gff files
	rm -r merged_prot
	mkdir merged_prot
	mergedGff="/projects/team3/func_annot/merged.gff"
	python ./remap.py -g $mergedGff -c nr95.clstr -d $inDir -o merged_prot
	echo "Done"
	
	
	# merge gffs from tools that used clustered proteins with tools that didn't
	
	
	# merge rRNAs
	rm -r temp/
	mkdir temp/
	for file in $inDir/*_RNA.fna; do
		genome=${file##*/}
		name=${genome%.*}
		genome="$(cut -d'_' -f1 <<< $name)"
		awk -F'\t' '{if ( $1 ~ /^>rRNA/) { split($1,array,"_"); split(array[8], coord, "-"); print array[2] "_" array[3] "_" array[4] "_" array[5] "_" array[6] "_" array[7] "\t" "rRNA" "\t" "rRNA" "\t" coord[1] "\t" coord[2] "\t.\t" substr(array[9],4,1) "\t.\t."; }}' $file > temp/"$genome"_scaffolds_cds.gff
	done
	./merge.bash merged_prot temp prot_n_rna
}


main "$@"