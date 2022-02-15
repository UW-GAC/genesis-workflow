#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --pca_file $BASE_PATH/testdata/1KG_pcair.RData \
  --n_pairs 4 \
  --out_prefix test \
  --phenotype_file $BASE_PATH/testdata/1KG_phase3_subset_annot.RData \
  --group Population \
  < $BASE_PATH/R/pca_plots.R

cat pca_plots.params
