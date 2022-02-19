#!/bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --corr_file $BASE_PATH/testdata/1KG_pca_corr_chr1.gds \
              $BASE_PATH/testdata/1KG_pca_corr_chr2.gds \
  --n_pcs 8 \
  --n_perpage 4 \
  --out_prefix test \
  --thin TRUE \
  < $BASE_PATH/R/pca_corr_plots.R

cat pca_corr_plots.params
