#! /bin/bash

BASE_PATH=$1

# single chromosome file
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_chr1.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair_unrel.RData \
  --n_pcs 16 \
  --out_file test.gds \
  --variant_include_file $BASE_PATH/testdata/variant_include_chr1.RData \
  --num_cores 2 \
  < $BASE_PATH/R/pca_corr.R

cat pca_corr.params

Rscript -e '(gds <- gdsfmt::openfn.gds("test.gds"))'

# all chromosomes file with argument
R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair_unrel.RData \
  --n_pcs 16 \
  --out_file test.gds \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --num_cores 2 \
  < $BASE_PATH/R/pca_corr.R

cat pca_corr.params

Rscript -e '(gds <- gdsfmt::openfn.gds("test.gds"))'
