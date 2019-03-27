#!/usr/bin/env python3

import argparse
import re
pars=argparse.ArgumentParser()
pars.add_argument('-m',help="fuck",required=True,type=str)
args=pars.parse_args()
temp_file=args.m
def rgi_2_gff(temp_file):
    with open("%s.txt"%(temp_file), encoding='latin-1') as f:
        lines = f.readlines()
        del lines[0]
    out_content = '##gff-version  3\n'
    for line in lines:
        items = [l for l in line.replace(' ', '\t').split('\t') if l]
        out_content += items[0] + '\t'
        out_content += 'RGI-CARD\tAntibiotic resistant genes\t'
        start, end = re.findall(r'(\d+)-(\d+)\([-\+]\)', items[0])[0]
        out_content += '{}\t{}\t'.format(start, end)
        out_content += '.\t.\t.\t'
        out_content += ';'.join(items[12:-5])
        out_content += '\n'
    out_content = out_content[:-1]
    with open("%s.gff"%(temp_file), 'w') as f:
        f.write(out_content)
rgi_2_gff(temp_file)
    
