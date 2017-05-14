#script to rename the the meme_m1.txt files from the ecker dap-seq experiments
import os
import glob
from shutil import copyfile

input_pattern='/Users/falko.hofmann/data/motif_databases/dap_data_v4/peaks/*/*/chr1-5/chr1-5_GEM_events.narrowPeak'
output_dir='/Users/falko.hofmann/data/motif_databases/dap_data_v4/peaks_renamed/'


def getFileNames(path):
    """Function that returns the full paths of files that match a globbing
    pattern.
    """
    filenames = glob.glob(path)
    return filenames

def generateNewFileName(path,out_dir):
    """Function that returns a new file name string and the DAP-seq sample name.
    """
    dirs = path.split('/')
    file_name = out_dir + dirs[-name_colum] + '.narrowPeak'
    sample_name = dirs[-name_colum]
    return file_name, sample_name

def processFile(file_in,file_out, sample_name):
    """Function that reads the DAP-seq narrow peak file and replaces the name
    colum with the sample name.
    """
    #print('Processing: \t' + sample_name)
    #print('New File: ' + file_out)

    with open(file_in, 'r') as fin:
        lines = fin.readlines()
    fout = open(file_out,'w')
    counter = 0
    for line in lines:
        counter+=1
        cols = line.split('\t')
        cols[name_colum] = sample_name

        start = int(cols[1])
        stop = int(cols[2])
        if start < 0:
            print("Warning: " + sample_name + " Start Coordinate < 0.\tline: " + str(counter))
            print("Setting value to 0...")
            cols[1]="0"

        if stop < 0:
            print("Warning: " + sample_name + " Stop Coordinate < 0.\tline: " + str(counter))
            print("Setting value to 0...")
            cols[2]="0"

        fout.write('\t'.join(cols))

global name_colum
name_colum = 3

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

samples = set()
files = getFileNames(input_pattern)

for f in files:
    f_out, sample_name = generateNewFileName(f,output_dir)

    if sample_name in samples:
        print('warning!\t' + sample_name + ' already exists!')
        raise StopIteration
    samples.add(sample_name)
    processFile(f,f_out,sample_name)
