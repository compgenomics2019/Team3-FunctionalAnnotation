#!/usr/bin/env python3

import os
import shutil
import re

def rgi_2_gff(in_folder, out_folder):
    if os.path.exists(out_folder):
        shutil.rmtree(out_folder)
    os.mkdir(out_folder)
    file_names = os.listdir(in_folder)
    for file_name in file_names:
        if file_name in ['.DS_Store']: continue
        file_path = os.path.join(in_folder, file_name)
        new_file_name = file_name.split('_')[-1] + '_rgi.gff'
        new_file_path = os.path.join(out_folder, new_file_name)
        with open(file_path, encoding='latin-1') as f:
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
        with open(new_file_path, 'w') as f:
            f.write(out_content)

if __name__=="__main__":
    rgi_2_gff('./rgi_txt', './yini_rgi_gff')
    