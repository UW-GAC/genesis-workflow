#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --out_file test.gds \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --num_cores 2 \
  < $BASE_PATH/R/ibd_king.R

cat ibd_king.params

Rscript -e '(gds <- gdsfmt::openfn.gds("test.gds"))'
