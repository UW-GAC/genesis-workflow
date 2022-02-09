#! /bin/bash

# push to development project
sbpack bdc smgogarten/genesis-relatedness/gds2bed tools/gds2bed.cwl
sbpack bdc smgogarten/genesis-relatedness/plink_make-bed tools/plink_make_bed.cwl
sbpack bdc smgogarten/genesis-relatedness/king_ibdseg tools/king_ibdseg.cwl
sbpack bdc smgogarten/genesis-relatedness/king-to-matrix tools/king_to_matrix.cwl
sbpack bdc smgogarten/genesis-relatedness/kinship-plots tools/kinship_plots.cwl
sbpack bdc smgogarten/genesis-relatedness/king-pipeline king-ibdseg-wf.cwl

 #test
python3 test/test_king_ibdseg.py

# push to pre-build project
sbpack bdc smgogarten/genesis-relatedness-pre-build/gds2bed tools/gds2bed.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/plink-make-bed tools/plink_make_bed.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-ibdseg tools/king_ibdseg.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-to-matrix tools/king_to_matrix.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl

# pull tools with new app ids from pre-build
sbpull bdc smgogarten/genesis-relatedness-pre-build/gds2bed tools/gds2bed.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/plink-make-bed tools/plink_make_bed.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/king-ibdseg tools/king_ibdseg.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/king-to-matrix tools/king_to_matrix.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl

# push workflow to pre-build
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-ibdseg-1 king-ibdseg-wf.cwl

# push workflow to commit
sbpack bdc smgogarten/uw-gac-commit/king-ibdseg king-ibdseg-wf.cwl
