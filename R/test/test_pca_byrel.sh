#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --related_file $BASE_PATH/testdata/1KG_related.RData \
  --unrelated_file $BASE_PATH/testdata/1KG_unrelated.RData \
  --out_prefix test \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --num_cores 2 \
  < $BASE_PATH/R/pca_byrel.R

cat pca_byrel.params

R -q --vanilla --args test.RData \
  < $BASE_PATH/R/test/check_out_file.R

R -q --vanilla --args test_unrel.RData \
  < $BASE_PATH/R/test/check_out_file.R
