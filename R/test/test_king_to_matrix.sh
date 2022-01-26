#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --king_file $BASE_PATH/testdata/hapmap3_king_ibdseg.seg \
  --out_file test.RData \
  --kinship_method king_ibdseg \
  --sparse_threshold 0.01104854 \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  < $BASE_PATH/R/king_to_matrix.R

cat king_to_matrix.params

R -q --vanilla --args test.RData \
  < $BASE_PATH/R/test/check_out_file.R
