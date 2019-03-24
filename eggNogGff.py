#!/usr/bin/env python3
# --- Imports ---
import argparse
parser = argparse.ArgumentParser()

def parseArgs():
    global parser
    parser.add_argument("-e", help = "EggNog tsv file")
    parser.add_argument("-o", help = "Name of output gff file")

    args = parser.parse_args()
    return args.e, args.o

def readEgg(eggFile):
    gffLines = []
    with open(eggFile, 'r') as eggFile:
        for line in eggFile:
            if not line.startswith("#"):
                lineSplit = line.split("\t")
                source = "eggNOG"
                feature = "gene"
                # print(line)
                # print(len(line))
                predicted_gene_name = lineSplit[4]
                GO_terms = lineSplit[5]
                KEGG_KOs = lineSplit[6]
                annotation = lineSplit[12].rstrip()
                query = lineSplit[0]
                start = "."
                stop = "."
                score = "."
                strand = "."
                frame = "."
                attribute = "predicted_gene_name={0};annotation={1};GO_terms={2};KEGG_KOs={3};".format(predicted_gene_name, annotation, GO_terms, KEGG_KOs)
                gffLine = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\n".format(query, source, feature, start, stop, score, strand, frame, attribute)
                gffLines.append(gffLine)
    return gffLines

def writeGff(gffLines, outputFile):
    with open(outputFile, 'w') as outputFile:
        for line in gffLines:
            outputFile.write(line)

def main():
    eggFile, outputFile = parseArgs()
    gffLines = readEgg(eggFile)
    writeGff(gffLines, outputFile)

main()
