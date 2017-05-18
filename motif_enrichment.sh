#!/bin/bash
#PBS -P rnaseq_nod
#PBS -N motif_enrichment
#PBS -J 1-2
#PBS -j oe
#PBS -q workq
#PBS -o /lustre/scratch/users/falko.hofmann/pipelines/tfbs-analysis-utils/log/enrichment/enrichment_^array_index^.log
#PBS -l walltime=0:30:00
#PBS -l select=1:ncpus=4:mem=8gb

#set variables
##### specify folders and variables #####
base_dir=/lustre/scratch/users/$USER/tfbs-matching

motifs_matched=$base_dir/fimo_matches
motif_dir=$base_dir/all_meme_motifs

script_dir=/lustre/scratch/users/$USER/pipelines/tfbs-analysis-utils
pbs_mapping_file=$script_dir/pbs_mapping_file.txt


granges_files=$base_dir/test_bed
mkdir -p $granges_files
#granges_files=$base_dir/granges/
test_granges_file=/lustre/scratch/users/$USER/peak_calling/fseq/merges/embryo_specific.bed

#test_region_motifs=$base_dir/granges/motifs
#mkdir $test_region_motifs

shuffled_regions=$base_dir/shuffled_bed
shuffled_regions_motifs=$shuffled_regions/motifs

mkdir $shuffled_regions
mkdir $shuffled_regions_motifs

#to make shuffeling reproducible
seeds_file=$script_dir/utils/seed.txt
#file for shuffeling
tair10_nuclear=$script_dir/utils/tair10.genome
tair10_exclude=$script_dir/utils/tair10_exclude.txt

## build array index
##### Obtain Parameters from mapping file using $PBS_ARRAY_INDEX as line number
input_mapper=`sed -n "${PBS_ARRAY_INDEX} p" $pbs_mapping_file` #read mapping file
names_mapped=($input_mapper)
motif_input=${names_mapped[1]} # get the sample dir
motif_id=${motif_input##*/}
motif_id=${motif_id%.*}

output_dir=$base_dir/enrichment/$motif_id
mkdir -p $output_dir

#load modules
ml BEDTools/2.26.0-foss-2016a
ml R/3.4.0-foss-2016b

#print some output for logging
echo '#########################################################################'
echo 'Mapping motif: '$motif_id
echo 'Output dir: ' $output_dir
echo '#########################################################################'

n_motifs=()
#shuffle regions for statistics and intersect the motifs

seeds=`cut -d ' ' -f 2 $seeds_file`

for seed in $seeds ; do

  bedtools intersect \
    -a $motifs_matched/$motif_id/fimo.bed \
    -b $shuffled_regions/$seed.bed -f 1.0 -wa \
    > $shuffled_regions_motifs/$seed_$motif_id.bed

    n_motifs+=(`wc -l $shuffled_regions_motifs/$seed_$motif_id.bed`)
done

printf "%s\n" "${n_motifs[@]}" > $output_dir/motif_count.txt


eval "bedtools intersect -a  $motifs_matched/$motif_id/fimo.bed -b $test_granges_file -f 1.0 -wa  > $granges_files/open_chrom_embryo_$motif_id.bed"

#do statistics

eval "Rscript $script_dir/estimate_motif_significance.R $granges_files/open_chrom_embryo_$motif_id.bed $output_dir/motif_count.txt  $output_dir/$motif_id-p-value.txt $output_dir/$motif_id_ecdf-plot.jpg $motif_id"

echo 'Finished motif enrichment for: '$motif_id
