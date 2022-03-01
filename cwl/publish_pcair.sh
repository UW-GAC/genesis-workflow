#! /bin/bash

# push to development project
sbpack bdc smgogarten/genesis-relatedness/find-unrelated tools/find_unrelated.cwl
sbpack bdc smgogarten/genesis-relatedness/pca-byrel tools/pca_byrel.cwl
sbpack bdc smgogarten/genesis-relatedness/pca-plots tools/pca_plots.cwl
sbpack bdc smgogarten/genesis-relatedness/pca-corr-vars tools/pca_corr_vars.cwl
sbpack bdc smgogarten/genesis-relatedness/pca-corr tools/pca_corr.cwl
sbpack bdc smgogarten/genesis-relatedness/pca-corr-plots tools/pca_corr_plots.cwl
sbpack bdc smgogarten/genesis-relatedness/pc-variant-correlation pc_variant_correlation.cwl
sbpack bdc smgogarten/genesis-relatedness/pc-air pc-air-wf.cwl

# test
python3 test/test_pcair.py

# push to pre-build project
sbpack bdc smgogarten/genesis-relatedness-pre-build/find-unrelated tools/find_unrelated.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pca-byrel tools/pca_byrel.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pca-plots tools/pca_plots.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pca-corr-vars tools/pca_corr_vars.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pca-corr tools/pca_corr.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pca-corr-plots tools/pca_corr_plots.cwl

# pull tools with new app ids from pre-build
sbpull bdc smgogarten/genesis-relatedness-pre-build/find-unrelated tools/find_unrelated.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pca-byrel tools/pca_byrel.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pca-plots tools/pca_plots.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pca-corr-vars tools/pca_corr_vars.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pca-corr tools/pca_corr.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pca-corr-plots tools/pca_corr_plots.cwl

# push workflow to pre-build
sbpack bdc smgogarten/genesis-relatedness-pre-build/pc-variant-correlation pc_variant_correlation.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pc-air pc-air-wf.cwl

# push workflow to commit
sbpack bdc smgogarten/uw-gac-commit/pc-air pc-air-wf.cwl
