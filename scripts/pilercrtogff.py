#!/usr/bin/env python

import sys
import re

if len(sys.argv) < 3 or len(sys.argv) > 3:
    print("Supply Required Arguments. First Argument needs to be the Output File Obtained from pilercr program which acts as input for the conversion script. 2md argument specifies the name of the final gff output file.")
else:
    InputFile = sys.argv[1]
    OutputFile = sys.argv[2]
    Input = open(InputFile, 'r')
    source = "Pilercr"
    type = "CRISPR"

    a1 = Input.readline()
    a2 = Input.readline()
    a3 = Input.readline()
    a4 = Input.readline()
    a = re.search(r': (.*?) putative', a4).group(1)
    if a == '0':
        print("No Crispr Arrays available. Exiting Program")
        sys.exit()
    else:
        MainString = ''
        MainString = MainString + "##gff-version 3" + '\n'
        a5 = Input.readlines()
        sim = a5.index("SUMMARY BY SIMILARITY\n")
        pos = a5.index("SUMMARY BY POSITION\n")
        crisprlist = []
        for i in range(sim + 1, pos):
            crisprlist.append(a5[i])
        crisprlist = [x for x in crisprlist if x != '\n']
        del crisprlist[0]
        del crisprlist[0]
        for j in crisprlist:
            b = j.split(' ')
            b = [y for y in b if y != '']
            c = int(b[2]) + int(b[3])
            MainString = MainString + b[1] + '\t' + type + '\t' + source + '\t' + b[2] + '\t' + str(c) + '\t' + '.' + '\t' + b[7] + '\t' + '.' + '\t' + b[8]
        Output = open(OutputFile, 'w')
        Output.write(MainString)


