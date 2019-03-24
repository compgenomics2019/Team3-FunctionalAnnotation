#!/bin/bash
while getopts "c:m:i:o:t:h" option
do
    case $option in
        c) c=$OPTARG
	   echo "$a";;
	m) m=$OPTARG
	   ;;
	i) i=$OPTARG
	   ;;
	o) o=$OPTARG
	   ;;
	t) t=$OPTARG
	   ;;
	h) echo " [-c <path/to/card.json>]"
	   echo " [-m <path/to/model>]"
	   echo " [-i <input files>]"
	   echo " [-o {output prefix}]"
	   echo " [-t {read,contig,protein,wgs}]"
    esac
done

rgi load -i $c --card_annotation $m --local
rgi main -i $i -o $o --input_type $t --local
