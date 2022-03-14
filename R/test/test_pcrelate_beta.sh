#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair.RData \
  --out_file test.RData \
  --n_pcs 3 \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --variant_block_size 5000 \
  --num_cores 2 \
  < $BASE_PATH/R/pcrelate_beta.R

cat pcrelate_beta.params

R -q --vanilla --args test.RData \
  < $BASE_PATH/R/test/check_out_file.R
