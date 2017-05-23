#!/bin/bash
#PBS -P rnaseq_nod
#PBS -N meme_matching
#PBS -J 1-414
#PBS -j oe
#PBS -q workq
#PBS -o /lustre/scratch/users/falko.hofmann/log/meme_matching/160822/meme_matching_^array_index^.log
#PBS -l walltime=0:30:00
#PBS -l select=1:ncpus=4:mem=8gb

#set variables
##### specify folders and variables #####
genome_fasta=/lustre/scratch/users/$USER/indices/fasta/Col_nuclear.fa

base_dir=/lustre/scratch/users/$USER/tfbs-matching
output_dir=$base_dir/fimo_matches

script_dir=/lustre/scratch/users/$USER/pipelines/tfbs-analysis-utils
pbs_mapping_file=$script_dir/pbs_mapping_file.txt
meme_bg_file=$script_dir/Col_nuclear_freqs.txt

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
echo 'Output dir: ' $output_dir/$motif_id
echo '#########################################################################'

#run fimo for motif matching
fimo --bgfile $meme_bg_file --oc $output_dir/$motif_id $motif_input $genome_fasta

PATH=$PATH:$script_dir/bedops2.4.20/bin

gff2bed < $output_dir/$motif_id/fimo.gff > $output_dir/$motif_id/fimo.bed

echo 'Finished motif mapping for: '$motif_id
