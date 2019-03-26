#!/usr/bin/env python3
# --- Imports ---
import argparse
import os
import re
parser = argparse.ArgumentParser()

def parseArgs():
    global parser
    parser.add_argument("-g", help = "GFF file")
    parser.add_argument("-c", help = "Cluster file")
    parser.add_argument("-d", help = "Orignal directory of gff files")

    parser.add_argument("-o", help = "Name of output directory")

    args = parser.parse_args()
    return args.g, args.c, args.d, args.o

def readCluster(clusterFile):
    cluster = {}
    with open(clusterFile, 'r') as clusterFile:
        clusterSeqs = []
        rep = ""
        for line in clusterFile:
            if line.startswith('>'):
                if not line.startswith('>Cluster 0'):
                    cluster[rep] = clusterSeqs
                clusterSeqs = []
                rep = ""
            else:
                line = line.replace("(", "")
                line = line.replace(")", "")
                lineSplit = line.split()
                line = line.strip()
                name = lineSplit[2][1:-3]
                # print(line)
                if line.endswith('*'):
                    rep = name
                    # print(rep)
                # print(name)
                clusterSeqs.append(name)
    return cluster

def readOldGffs(oldGffDir):
    oldGffs = {}
    for filename in os.listdir(oldGffDir):
        if filename.endswith(".gff") or filename.endswith(".gff3"):
            with open(oldGffDir + "/" + filename, 'r') as file:
                for line in file:
                    lineSplit = line.split()
                    start = str(int(lineSplit[3]) - 1)
                    stop = lineSplit[4]
                    strand = lineSplit[6]
                    # print(filename)
                    prot_name = start + "-" + stop + strand + "_1" + "_" + str(filename)
                    prot_name_2 = start + "-" + stop + "(" + strand + ")_1" + "_" + str(filename)
                    # print(line)
                    # print(prot_name)
                    oldGffs.setdefault(filename, []).append([prot_name, prot_name_2, line])
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
def remap(cluster, gffFile, oldGffs):
    newGffs = {}

    # Make a gff file for
    with open(gffFile, 'r') as gffFile:
        for line in gffFile:
            if not line.startswith('#'):
                line = line.replace("(", "")
                line = line.replace(")", "")
                lineSplit = line.split()
                name = lineSplit[0]
                # print(name)
                # print(fileName)
                if name in cluster:
                    currCluster = cluster[name]
                    for protein in currCluster:
                        protein = protein.replace(".faa", ".gff")
                        protein = protein.rstrip()
                        fileName = "_".join(protein.split('_')[2::])
                        replaced = line.replace(name, protein)  # replaces the representative protein name with the protein of this one in the cluster
                        matchFound = False
                        # print(protein)
                        # print(fileName)
                        for genePred in oldGffs[fileName]:
                            genePred[0] = genePred[0].rstrip()
                            if genePred[0] == protein or genePred[1] == protein:
                                # print("Match! protein = " + protein)
                                # print("Replaced = " + replaced)
                                # print("Original name = " + genePred[1])
                                newLine = changeCoord(genePred[2], replaced)
                                newGffs.setdefault(fileName, []).append(newLine)
                                matchFound = True
                                break
                        if not matchFound:
                            print("Match not found for protein: ")
                            print(protein + "|")
                        # changeCoord(replaced)
                        # newGffs.setdefault(fileName, []).append(replaced)
                        # newGffs[fileName] = currLines.append(replaced)  # if the key isn't in the dictionary, make an empty list. Then append the line.
                else:
                    print("Protein not a rep of the cluster: " + name)
    return newGffs

def writeNewGffs(newGffs, outputDir):
    for newGff in newGffs:
        with open(outputDir + "/" + newGff, 'w') as output:
            for line in newGffs[newGff]:
                output.write(line)

def main():
    print("Parsing args")
    gffFile, clusterFile, oldGffDir, outputDir = parseArgs()
    print("Done parsing args\nReading Cluster File")
    cluster = readCluster(clusterFile)
    print("Done reading cluster file")
    # for key in cluster.keys():
    #     print(key)
    #     print(cluster[key])
    print("Reading gff information from original gene prediction files")
    oldGffs = readOldGffs(oldGffDir)
    print("Done reading old gff files")
    for key in oldGffs.keys():
        for annot in oldGffs[key]:
    #         print(annot[0])

    if not os.path.exists(outputDir):
        os.makedirs(outputDir)
    print("Doing the remapping")
    newGffs = remap(cluster, gffFile, oldGffs)
    print("Done remapping")
    writeNewGffs(newGffs, outputDir)

main()
