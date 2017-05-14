#!/bin/bash
#PBS -P rnaseq_nod
#PBS -N motif_enrichment
#PBS -J 1-1
#PBS -j oe
#PBS -q workq
#PBS -o /lustre/scratch/users/falko.hofmann/log/motif_enrichment/170514/meme_matching_^array_index^.log
#PBS -l walltime=0:30:00
#PBS -l select=1:ncpus=4:mem=8gb

#set variables
##### specify folders and variables #####
genome_fasta=/lustre/scratch/users/$USER/indices/fasta/Col_nuclear.fa
base_dir=/lustre/scratch/users/$USER/tfbs-matching
motifs_matched=$base_dir/fimo_matches
motif_dir=$base_dir/all_meme_motifs

#output_dir=$base_dir/fimo_matches

script_dir=/lustre/scratch/users/$USER/pipelines/tfbs-analysis-utils
pbs_mapping_file=$script_dir/pbs_mapping_file.txt

granges_files=$base_dir/granges/
granges_file=$granges_files/open_chrom_embryo.bed
shuffled_regions=$granges_files/shuffled
shuffled_regions_motifs=$granges_files/shuffled/motifs

mkdir $shuffled_regions
mkdir $shuffled_regions_motifs

#to make shuffeling reproducible
seeds_file=$script_dir/utils/seeds.txt
#file for shuffeling
tair10_nuclear=$script_dir/utils/tair10_size.txt
tair10_exclude=$script_dir/utils/tair10_exclude.txt

## build array index
##### Obtain Parameters from mapping file using $PBS_ARRAY_INDEX as line number
input_mapper=`sed -n "${PBS_ARRAY_INDEX} p" $pbs_mapping_file` #read mapping file
names_mapped=($input_mapper)
motif_input=${names_mapped[1]} # get the sample dir
motif_id=${motif_input##*/}
motif_id=${motif_id%.*}

#load modules
ml BEDTools/2.26.0-foss-2016a
ml R/3.4.0-foss-2016b


#print some output for logging
echo '#########################################################################'
echo 'Mapping motif: '$motif_id
echo 'Output dir: ' $output_dir/$motif_id
echo '#########################################################################'


n_motifs=()
#shuffle regions for statistics and intersect the motifs
for seed in $seeds ; do

  bedtools shuffle -i $granges_file \
    -g $tair10_nuclear \
    -excl $tair10_exclude \
    -chrom \
    -noOverlapping \
    -seed $seed
    > $shuffled_regions/$seed.bed

  bedtools intersect \
    -a $motifs_matched/$motif_id/fimo.bed \
    -b $shuffled_regions/$seed.bed -f 1.0 -wa \
    > $shuffled_regions_motifs/$seed_$motif.bed

    n_motifs+=`wc -l $shuffled_regions_motifs/$seed_$motif_id.bed`
done


#do statistics

Rscript estimate_motif_significance.R




ho 'Finished motif mapping for: '$motif_id
