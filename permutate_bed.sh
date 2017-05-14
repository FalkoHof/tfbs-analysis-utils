#!/bin/bash
#PBS -P rnaseq_nod
#PBS -N motif_enrichment
#PBS -J 1-1000
#PBS -j oe
#PBS -q workq
#PBS -o /lustre/scratch/users/falko.hofmann/pipelines/tfbs-analysis-utils/log/shuffeling/shuffeling_^array_index^.log
#PBS -l walltime=0:10:00
#PBS -l select=1:ncpus=4:mem=8gb

#set variables
##### specify folders and variables #####
genome_fasta=/lustre/scratch/users/$USER/indices/fasta/Col_nuclear.fa
base_dir=/lustre/scratch/users/$USER/tfbs-matching

script_dir=/lustre/scratch/users/$USER/pipelines/tfbs-analysis-utils

#to parallelize and make shuffeling reproducible
pbs_mapping_file=$script_dir/utils/seed.txt

bed_file=/lustre/scratch/users/$USER/peak_calling/fseq/merges/embryo_specific.bed

shuffled_regions=$base_dir/shuffled_bed

mkdir $test_region_motifs
mkdir $shuffled_regions

#file for shuffeling
tair10_nuclear=$script_dir/utils/tair10.genome
tair10_exclude=$script_dir/utils/tair10_blacklist.txt

## build array index
##### Obtain Parameters from mapping file using $PBS_ARRAY_INDEX as line number
input_mapper=`sed -n "${PBS_ARRAY_INDEX} p" $pbs_mapping_file` #read mapping file
names_mapped=($input_mapper)
seed=${names_mapped[1]} # get the seed number

#load modules
ml BEDTools/2.26.0-foss-2016a

#print some output for logging
echo '#########################################################################'
echo 'Shuffeling file: '$bed_file
echo 'Seed: ' $seed
echo '#########################################################################'

eval "bedtools shuffle -i $bed_file -g $tair10_nuclear -excl $tair10_exclude -chrom -noOverlapping -seed $seed > $shuffled_regions/$seed.bed"

echo 'Finished shuffeling mapping for: '$seed
