#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair.RData \
  --beta_file $BASE_PATH/testdata/1KG_pcrelate_beta.RData \
  --out_prefix test \
  --n_pcs 3 \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --variant_block_size 5000 \
  --ibd_probs TRUE \
  --num_cores 2 \
  --n_sample_blocks 2 \
  --i 1 \
  --j 2 \
  < $BASE_PATH/R/pcrelate.R

cat pcrelate.params

R -q --vanilla --args test_block_1_2.RData \
  < $BASE_PATH/R/test/check_out_file.R

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair.RData \
  --beta_file $BASE_PATH/testdata/1KG_pcrelate_beta.RData \
  --out_prefix test \
  --n_pcs 3 \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --variant_block_size 5000 \
  --ibd_probs TRUE \
  --num_cores 2 \
  --n_sample_blocks 2 \
  --i 1 \
  --j 1 \
  < $BASE_PATH/R/pcrelate.R

cat pcrelate.params

R -q --vanilla --args \
  --gds_file $BASE_PATH/testdata/1KG_phase3_subset_pruned.gds \
  --pca_file $BASE_PATH/testdata/1KG_pcair.RData \
  --beta_file $BASE_PATH/testdata/1KG_pcrelate_beta.RData \
  --out_prefix test \
  --n_pcs 3 \
  --sample_include_file $BASE_PATH/testdata/sample_include.RData \
  --variant_include_file $BASE_PATH/testdata/variant_include_pruned.RData \
  --variant_block_size 5000 \
  --ibd_probs TRUE \
  --num_cores 2 \
  --n_sample_blocks 2 \
  --i 2 \
  --j 2 \
  < $BASE_PATH/R/pcrelate.R

cat pcrelate.params
