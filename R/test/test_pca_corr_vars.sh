#! /bin/bash

BASE_PATH=$1

# single chromosome file
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chr1.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair_unrel.RData \
  --n_corr_vars 1e6 \
  --out_file test_1.RData \
  --corr_maf_threshold 0.01 \
  --corr_missing_threshold 0.05 \
  < $BASE_PATH/R/pca_corr_vars.R

cat pca_corr_vars.params

R -q --vanilla --args test_1.RData \
  < $BASE_PATH/R/test/check_out_file.R

# all chromosomes file with argument
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair_unrel.RData \
  --n_corr_vars 1e6 \
  --out_file test_all.RData \
  --corr_maf_threshold 0.01 \
  --corr_missing_threshold 0.05 \
  --chromosome 1 \
  < $BASE_PATH/R/pca_corr_vars.R

cat pca_corr_vars.params

R -q --vanilla --args test_all.RData \
  < $BASE_PATH/R/test/check_out_file.R

# add variants
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair_unrel.RData \
  --n_corr_vars 1e6 \
  --out_file test_vars.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_chr1.RData \
  --corr_maf_threshold 0.01 \
  --corr_missing_threshold 0.05 \
  --chromosome 1 \
  < $BASE_PATH/R/pca_corr_vars.R

cat pca_corr_vars.params

R -q --vanilla --args test_vars.RData \
  < $BASE_PATH/R/test/check_out_file.R
