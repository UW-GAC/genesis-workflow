#! /bin/bash

BASE_PATH=$1

# basic
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chr1.gds \
  --autosome_only TRUE \
  --exclude_pca_corr TRUE \
  --genome_build hg19 \
  --ld_r_threshold 0.32 \
  --ld_win_size 10 \
  --maf_threshold 0.01 \
  --missing_threshold 0.01 \
  --out_prefix test \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_chr1.RData \
  --chromosome 1 \
  < $BASE_PATH/R/ld_pruning.R

cat ld_pruning.params

R -q --vanilla --args test_pruned_variants.RData \
  < $BASE_PATH/R/test/check_out_file.R

# X chrom
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chrX.gds \
  --autosome_only FALSE \
  --exclude_pca_corr FALSE \
  --genome_build hg19 \
  --ld_r_threshold 0.32 \
  --ld_win_size 10 \
  --maf_threshold 0.01 \
  --missing_threshold 0.01 \
  --out_prefix test \
  < $BASE_PATH/R/ld_pruning.R

cat ld_pruning.params

R -q --vanilla --args test_pruned_variants.RData \
  < $BASE_PATH/R/test/check_out_file.R
