#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  < $BASE_PATH/R/gds2bed.R

cat gds2bed.params
ls 1KG_phase3_subset_pruned*
