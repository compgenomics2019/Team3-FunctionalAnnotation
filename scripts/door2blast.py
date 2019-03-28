#!/usr/bin/env python3

import sys
import os
import subprocess
import argparse

DIR = os.path.dirname(__file__)
opr_file = os.path.join(DIR,'door2db/listeria_all.opr')
gi_file = os.path.join(DIR,'door2db/gi_map.txt')
db_file = os.path.join(DIR,'door2db/final.table')
pidentity = 90
coverage = 90

#get input file
parser = argparse.ArgumentParser()
parser.add_argument('-i','--infile',required=True,help='Enter input .faa file')
parser.add_argument('-o','--outfile',required=True,help='Enter output file')
args = parser.parse_args()

input_file = args.infile
final_output = args.outfile

# operon db files pre-processing
operon_data = {}

opr = open(opr_file,'r')
in_val = []
in_val += opr

for line in in_val:
	split_line = line.rstrip().split('\t')
	gi_id = split_line[1]
	o_id = split_line[0]
	cog = split_line[7]
	product = split_line[8]
	group = o_id+'\t'+cog+'\t'+product
	operon_data[gi_id] = group
opr.close()

gi_values = {}

gi = open(gi_file,'r')
gi_val = []
gi_val += gi

for line1 in gi_val:
	gi_split = line1.rstrip().split(' ')
	gid = gi_split[0]
	seq_id = gi_split[1]
	gi_values[seq_id] = gid
gi.close()

#running BLAST
temp_folder = os.path.join(DIR,'door2db/temp/')
blast_output = os.path.join(DIR,'door2db/temp/inter_output.txt')
subprocess.run(['mkdir {}'.format(temp_folder)], shell=True, check = True)
subprocess.run(['cp {} {}'.format(db_file,temp_folder)], shell=True, check=True)
subprocess.run(['makeblastdb -in {} -dbtype prot'.format(temp_folder+'final.table')], shell=True, check = True)
subprocess.run(['blastp -query {} -db {} -out {} -num_threads 4 -evalue 1e-10 -outfmt "6 qseqid sseqid qstart qend evalue pident qcovs" -max_target_seqs 1 -max_hsps 1'.format(input_file, temp_folder+'final.table', blast_output)], shell=True,check=True)


#add fields to blast output

bls = open(blast_output,'r')
tls = os.path.join(DIR, 'door2db/temp/temp_final_out.txt')
out  = open(tls,'w')
in_fl = []
in_fl += bls

for line2 in in_fl:
	bls_split = line2.rstrip().split('\t')
	perc_ident = bls_split[5]
	query_cov = bls_split[6]
	if float(perc_ident) >= pidentity and float(query_cov) >= coverage:
		out.write(line2)
bls.close()
out.close()

new_in = open(tls,'r')
n_fl = []
n_fl += new_in
vs = os.path.join(DIR,'door2db/temp/pre_final_out.txt')
new_out = open(vs, 'w')

for line3 in n_fl:
	out_split = line3.rstrip().split('\t')
	seq = out_split[1]
	tip = '>'+seq
	for key1 in gi_values:
		if key1 == tip:
			for key2 in operon_data:
				if key2 == gi_values[key1]:
					new_out.write('{}\t{}\n'.format(line3.rstrip(), operon_data[key2]))

with open(vs,'r')as test:
	data = test.read().strip().split('\n')
	final_output = open(final_output,'w')
	source = "Door2"
	feature = "operon"
	strand = "."
	frame = "."
	final_output.write("##gff-version 3\n")
	for i in range(len(data)):
		temp = data[i].split('\t')
		seqid = temp[0]
		start = temp[2]
		stop = temp[3]
		score = temp[4]
		attribute = "target={0};start={1};stop={2};score={3};percentid={4};coverage={5};operonid={6};cog={7}".format(temp[1],temp[2],temp[3],temp[4],temp[5],temp[6],temp[7],temp[8])
		final_output.write('{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\n'.format(seqid,source,feature,start,stop,score,strand,frame,attribute))
	final_output.close()	

subprocess.run(['rm -rf {}'.format(temp_folder)], shell=True, check = True)
