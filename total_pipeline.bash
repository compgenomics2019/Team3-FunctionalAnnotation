#!/bin/bash

#Author: George Gruenhagen
#Purpose: Call the variants in the bam files

#Usage statement
usage () {
	echo "Usage: total_pipeline.bash -i <input_dir> -o <output_name> -a <assembled_genome_dir> -c <card.json> -m <card_model> -t <org_type>
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
	
	if [ "$org" != "gram+" ] && [ "$org" != "gram-" ] && [ "$org" != "euk" ]; then
		echo "Please supply a valid type of organism"
		usage
		exit 1
	fi
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
	./cluster.bash -I inputRenamed >> log
	echo "Done"
	
	echo "Calling tools on clustered proteins: eggNOG, InterProScan, CARD"
	# Call tools on clust_prot.faa
	# output should be called merged.gff
	echo "Done"
	
	# Call tools on unclustered proteins
	echo "Calling tools on unclustered proteins: Phobius and SignalP"
	rm -r tempsignalpout
	./signalpforall.sh -i inputRenamed -o $org >> log

    ## phobius
	echo "Start running phobius"
	rm -r tempphobiusout # clean up
	mkdir tempphobiusout # creat temp dir
	## Run phobius in parallel and wait for all processes to finish
	for faa in inputRenamed/*.faa; do
		FAA_BASENAME=`basename $faa .faa`
		./run_phobius -i $faa -r $inDir/"$FAA_BASENAME".gff -o tempphobiusout/"$FAA_BASENAME" >> log 2>&1    &
	done
	wait
	## Now the output should be at "tempphobiusout/<basename>.gff" and "tempphobiusout/<basename>.out"

	echo "Done"
	
	# Call tools on assembledGenome
	echo "Calling tools on assembled genomes: Piler"
	rm -r pilerout
	./pilerforall.sh -i $assembledGenome >> log
	echo "Done"
	
	echo "Mapping clustered annotations to the whole cluster. Mapping coordinates back to scaffold coordinates. Mapping files back into 50 files."
	# remap clustered proteins to gff files
	rm -r merged_prot
	mkdir merged_prot
	mergedGff="/projects/team3/func_annot/merged.gff" # TODO change this to the actual merged file
	python ./remap.py -g $mergedGff -c nr95.clstr -d $inDir -o merged_prot > remap_log
	echo "Done"
	
	# merge rRNAs
	rm -r temp/
	mkdir temp/
	for file in $inDir/*_RNA.fna; do
		genome=${file##*/}
		name=${genome%.*}
		genome="$(cut -d'_' -f1 <<< $name)"
		awk -F'\t' '{if ( $1 ~ /^>rRNA/) { split($1,array,"_"); split(array[8], coord, "-"); print array[2] "_" array[3] "_" array[4] "_" array[5] "_" array[6] "_" array[7] "\t" "rRNA" "\t" "rRNA" "\t" coord[1] "\t" coord[2] "\t.\t" substr(array[9],4,1) "\t.\t."; }}' $file > temp/"$genome"_scaffolds_cds.gff
	done
	./merge.bash merged_prot temp prot_n_rna > log
	
	# merge gffs from tools that didn't use proteins
	# Piler
	rm -r prot_n_rna_n_piler/
	mkdir prot_n_rna_n_piler/
	./merge.bash prot_n_rna pilerout prot_n_rna_n_piler
	
	
	# Create fasta files
	echo "Creating nucleotide and protein fasta files"
	rm -r final
	mkdir final
	./gffToFasta.bash -A prot_n_rna -G $assembledGenome -O final
	mv prot_n_rna/* final
	echo "Done"
	
	# remove temporary files
}


main "$@"
