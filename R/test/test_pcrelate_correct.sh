#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --pcrelate_prefix test \
  --sparse_threshold 0.044 \
  --n_sample_blocks 2 \
  < $BASE_PATH/R/pcrelate_correct.R

cat pcrelate_correct.params

R -q --vanilla --args test_pcrelate.RData \
  < $BASE_PATH/R/test/check_out_file.R

R -q --vanilla --args test_pcrelate_Matrix.RData \
  < $BASE_PATH/R/test/check_out_file.R
