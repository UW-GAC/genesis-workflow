#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --kinship_file $BASE_PATH/testdata/1KG_king_ibdseg_Matrix.RData \
  --divergence_file $BASE_PATH/testdata/1KG_king_robust.gds \
  --kinship_threshold 0.04419417 \
  --divergence_threshold -0.04419417 \
  --out_prefix "test" \
  --phenotype_file $BASE_PATH/testdata/1KG_phase3_subset_annot.RData \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --group Population \
  < $BASE_PATH/R/find_unrelated.R

cat find_unrelated.params

R -q --vanilla --args test_related.RData \
  < $BASE_PATH/R/test/check_out_file.R

R -q --vanilla --args test_unrelated.RData \
  < $BASE_PATH/R/test/check_out_file.R
