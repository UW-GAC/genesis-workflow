#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chr21.gds \
    $BASE_PATH/testdata/1KG_phase3_subset_chr22.gds \
  --merged_gds_file test.gds \
  < $BASE_PATH/R/merge_gds.R

cat merge_gds.params

Rscript -e '(gds <- SeqArray::seqOpen("test.gds"))'

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chr21.gds \
  --merged_gds_file test.gds \
  < $BASE_PATH/R/check_merged_gds.R

cat check_merged_gds.params
