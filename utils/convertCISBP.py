import os
import subprocess

inputDir = '/Users/falko.hofmann/data/motif_databases/cisbp/Arabidopsis_thaliana_2016_08_22_12-09_pm/pwms_all_motifs/'
outputDir = '/Users/falko.hofmann/data/motif_databases/cisbp/Arabidopsis_thaliana_2016_08_22_12-09_pm/transfac_like_motifs/'
memeDir = '/Users/falko.hofmann/data/motif_databases/cisbp/Arabidopsis_thaliana_2016_08_22_12-09_pm/meme_motifs/'
bg_freqs = '/Users/falko.hofmann/data/motif_databases/Col_nuclear_freqs.txt'

#create output directories
if not os.path.exists(outputDir):
    os.makedirs(outputDir)

if not os.path.exists(memeDir):
    os.makedirs(memeDir)

counter = 0
emptyFileCounter = 0
#loop over input files
for f in os.listdir(inputDir):

    counter+=1

    fin=open(inputDir + f, 'r')

    #skip first lines
    line = fin.readline()

    #parse rest
    lineCount = 0
    lines =[]
    while True:
        line = fin.readline()

        if not line:
            break
        lines.append(line)
        lineCount+=1

    if not lineCount > 1:
        print('File: ' + f + ' empty! Skipping...')
        emptyFileCounter += 1
        continue

    lineCount = 0

    #create new header
    fileId = f[:-4]
    fileHeader = str('ID\t' + fileId + '\n')
    fileHeader =  fileHeader + 'P0\tA\tC\tG\tT\n'

    #write new file
    fout=open(outputDir + f,'w')
    fout.write(fileHeader)
    for line in lines:
        fout.write(line)

    fout.write('//')
    fout.close()
    print('Converting: ' + f + '\t' + 'Number: ' + str(counter) + '/' +
          str(len(os.listdir(inputDir))))
    bashCommand = ('transfac2meme -bg '+ bg_freqs + ' ' + outputDir + f +
                   ' > ' + memeDir + f)
    os.system(bashCommand)
print('# total files:\t' +  str(counter))
print('# empty files:\t' + str(emptyFileCounter))
print('# files with content:\t' + str(counter-emptyFileCounter))
