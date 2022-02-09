#! /bin/bash

# push to development project
sbpack bdc smgogarten/genesis-relatedness-pre-build/gds2bed tools/gds2bed.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/plink-make-bed tools/plink_make_bed.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-ibdseg tools/king_ibdseg.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-to-matrix tools/king_to_matrix.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl
sbpack bdc smgogarten/genesis-relatedness/king-pipeline king-ibdseg-wf.cwl

 #test
python3 test/test_king_ibdseg.py
