#! /bin/bash

BASE_PATH=$1

R -q --vanilla --args \
  --vcf_file $BASE_PATH/testdata/1KG_phase3_subset_chr21.vcf.gz \
  --gds_file test.gds \
  < $BASE_PATH/R/vcf2gds.R

cat vcf2gds.params

Rscript -e '(gds <- SeqArray::seqOpen("test.gds"))'

Rscript -e 'writeLines(SeqArray::seqExampleFileName("vcf"), "tmp.txt")'
VCF=$(<"tmp.txt")
rm tmp.txt

R -q --vanilla --args \
  --vcf_file $VCF \
  --gds_file test.gds \
  --format GT DP \
  < $BASE_PATH/R/vcf2gds.R

cat vcf2gds.params

Rscript -e '(gds <- SeqArray::seqOpen("test.gds"))'

