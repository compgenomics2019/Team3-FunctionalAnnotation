#!/usr/bin/env python3
# --- Imports ---
import argparse
import os
import re
parser = argparse.ArgumentParser()

def parseArgs():
    global parser
    parser.add_argument("-g", help = "Directory of GFF file")
    parser.add_argument("-d", help = "Orignal directory of gff files")

    parser.add_argument("-o", help = "Name of output directory")

    args = parser.parse_args()
    return args.g, args.d, args.o

def readOldGffs(oldGffDir):
    oldGffs = {}
    for filename in os.listdir(oldGffDir):
        # print(filename)
        if filename.endswith(".gff") or filename.endswith(".gff3"):
            with open(oldGffDir + "/" + filename, 'r') as file:
                for line in file:
                    lineSplit = line.split()
                    start = str(int(lineSplit[3]) - 1)
                    stop = lineSplit[4]
                    strand = lineSplit[6]
                    # print(filename)
                    basename = os.path.basename(filename)
                    prot_name = start + "-" + stop + strand + "_1" + "_" + str(basename)
                    prot_name_2 = start + "-" + stop + "(" + strand + ")_1" + "_" + str(basename)
                    # print(line)
                    # print(prot_name)
                    oldGffs.setdefault(basename, []).append([prot_name, prot_name_2, line])
    return oldGffs

def my_split(s):
    return filter(None, re.split(r'(\d+)', s))

def changeCoord(originalLine, line):
    lineSplit = line.split("\t")
    originalLineSplit = originalLine.split("\t")
    seqname = originalLineSplit[0]
    originalStrand = originalLineSplit[6]
    id = originalLineSplit[8].split(";")[0]
    # print(originalLine)
    # print(id)

    name = lineSplit[0]
    originalStart = my_split(name)[0]
    originalStop = my_split(name)[2]

    source = lineSplit[1]
    feature = lineSplit[2]
    start = lineSplit[3]
    stop = lineSplit[4]
    score = lineSplit[5]
    strand = lineSplit[6]
    frame = lineSplit[7]
    attribute = lineSplit[8].rstrip()

    attribute = id + ";" + attribute
    strand = originalStrand
    if start == ".":
        start = 1

    if stop == ".":
        stop = int(originalStop) - int(originalStart)

    newStart = int(originalStart) + int(start)
    newStop = int(stop) + int(originalStart)
    newLine = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\n".format(seqname, source, feature, newStart, newStop, score, strand, frame, attribute)
    return newLine


"""
Give the annotations that were given to the representative sequence to all the
proteins in the cluster. Put the proteins into their correct gff file (out of 50 total).
"""
def remap(gffDir, oldGffs):
    newGffs = {}

    for filename in os.listdir(gffDir):
        # print(filename)
        if filename.endswith(".gff") or filename.endswith(".gff3"):
            with open(gffDir + "/" + filename, 'r') as gffFile:
                for line in gffFile:
                    if not line.startswith('#'):
                        line = line.replace("(", "")
                        line = line.replace(")", "")
                        lineSplit = line.split()
                        name = lineSplit[0]
                        # print(name)
                        # print(fileName)

                        name = name.replace(".faa", ".gff")
                        name = name.rstrip()
                        fileName = "_".join(name.split('_')[2::])
                        # replaced = line.replace(name, protein)  # replaces the representative protein name with the protein of this one in the cluster
                        matchFound = False
                        # print(protein)
                        # print(fileName)
                        basename = os.path.basename(fileName)
                        if basename in oldGffs:
                            for genePred in oldGffs[basename]:
                                genePred[0] = genePred[0].rstrip()
                                if genePred[0] == name or genePred[1] == name:
                                    # print("Match! name = " + name)
                                    # print("Replaced = " + replaced)
                                    # print("Original name = " + genePred[1])
                                    newLine = changeCoord(genePred[2], line)
                                    newGffs.setdefault(fileName, []).append(newLine)
                                    matchFound = True
                                    break
                        else:
                            print("Key not found: " + basename)
                        if not matchFound:
                            print("Match not found for protein: ")
                            print(name + "|")

    return newGffs

def writeNewGffs(newGffs, outputDir):
    for newGff in newGffs:
        with open(outputDir + "/" + newGff, 'w') as output:
            for line in newGffs[newGff]:
                output.write(line)

def main():
    print("Parsing args")
    gffDir, oldGffDir, outputDir = parseArgs()
    print("Done parsing args\nReading gff information from original gene prediction files")
    oldGffs = readOldGffs(oldGffDir)
    print("Done reading old gff files")
    # for key in oldGffs.keys():
    #     print(key)
    #    for annot in oldGffs[key]:
    #         print(annot[0])

    if not os.path.exists(outputDir):
        os.makedirs(outputDir)
    print("Doing the remapping")
    newGffs = remap(gffDir, oldGffs)
    print("Done remapping")
    writeNewGffs(newGffs, outputDir)

main()
