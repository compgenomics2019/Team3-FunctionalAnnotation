#!/usr/bin/env bash

mkdir Rfam
cd Rfam
wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.1/Rfam.cm.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.1/Rfam.clanin
gunzip Rfam.cm.gz
cmpress Rfam.cm

#cmscan --rfam --cut_ga --nohmmonly --tblout mrum-genome.tblout --fmt 2 \
#    --clanin infernal-1.1.2-linux-intel-gcc/testsuite/Rfam.12.1.clanin Rfam.cm \
#    infernal-1.1.2-linux-intel-gcc/tutorial/mrum-genome.fa > mrum-genome.cmscan

