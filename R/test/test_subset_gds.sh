#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chr1.gds \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_chr1.RData \
  < $BASE_PATH/R/subset_gds.R

cat subset_gds.params

Rscript -e '(gds <- SeqArray::seqOpen("1KG_phase3_subset_chr1_subset.gds"))'
