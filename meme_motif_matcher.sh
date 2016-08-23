#!/bin/bash
#PBS -P rnaseq_nod
#PBS -N meme_matching
#PBS -J 1-10
#PBS -j oe
#PBS -q workq
#PBS -o /lustre/scratch/users/falko.hofmann/log/meme_matching/160822/
#PBS -l walltime=1:00:00
#PBS -l select=1:ncpus=4:mem=8gb

#set variables
##### specify folders and variables #####
genome_fasta=/lustre/scratch/users/$USER/indices/fasta/Col_nuclear.fa
base_dir=/lustre/scratch/users/$USER/tfbs-matching
motif_dir=$base_dir/all_meme_motifs
output_dir=$base_dir/fimo_matches

script_dir=/lustre/scratch/users/$USER/pipelines/tfbs-analysis-utils
pbs_mapping_file=$script_dir/pbs_mapping_file.txt


## build array index
##### Obtain Parameters from mapping file using $PBS_ARRAY_INDEX as line number
input_mapper=`sed -n "${PBS_ARRAY_INDEX} p" $pbs_mapping_file` #read mapping file
names_mapped=($input_mapper)
motif_input=${names_mapped[1]} # get the sample dir
motif_id=${motif_input##*/}
motif_id=${motif_id%.*}

#load modules
module load MEME/4.11.1-foss-2015b

#print some output for logging
echo '#########################################################################'
echo 'Mapping motif: '$motif_id
echo 'Output dir: ' $sample_dir
echo '#########################################################################'


#run fimo for motif matching
fimo --o $output/$motif_id $motif_input $genome_fasta

echo 'Motif mapping for: '$motif_id
