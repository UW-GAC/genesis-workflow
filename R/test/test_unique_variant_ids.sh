#! /bin/bash

BASE_PATH=$1
cp $BASE_PATH/testdata/1KG_phase3_subset_chr1.gds chr1.gds
cp $BASE_PATH/testdata/1KG_phase3_subset_chr2.gds chr2.gds
cp $BASE_PATH/testdata/1KG_phase3_subset_chrX.gds chrX.gds

R -q --vanilla --args \
  --gds_file chrX.gds chr2.gds chr1.gds \
  < $BASE_PATH/R/unique_variant_ids.R

cat unique_variant_ids.params

Rscript -e 'for (c in c(1:2,"X")) {gds <- SeqArray::seqOpen(paste0("chr", c, ".gds")); ids <- SeqArray::seqGetData(gds, "variant.id"); print(head(ids))}'
