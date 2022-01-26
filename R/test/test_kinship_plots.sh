#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --kinship_file $BASE_PATH/testdata/1KG_king_robust.gds \
  --kinship_method king_robust \
  --kinship_threshold 0.04419417 \
  --out_prefix "test_robust" \
  --phenotype_file $BASE_PATH/testdata/1KG_phase3_subset_annot.RData \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --group Population \
  < $BASE_PATH/R/kinship_plots.R

cat kinship_plots.params


R -q --vanilla --args \
  --kinship_file $BASE_PATH/testdata/hapmap3_king_ibdseg.seg \
  --kinship_method king_ibdseg \
  --kinship_threshold 0.04419417 \
  --out_prefix "test_ibdseg" \
  --phenotype_file $BASE_PATH/testdata/1KG_phase3_subset_annot.RData \
  --group Population \
  < $BASE_PATH/R/kinship_plots.R

cat kinship_plots.params
