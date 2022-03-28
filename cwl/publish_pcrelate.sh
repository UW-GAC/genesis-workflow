#! /bin/bash

# push to development project
sbpack bdc smgogarten/genesis-relatedness/pcrelate-beta tools/pcrelate_beta.cwl
sbpack bdc smgogarten/genesis-relatedness/pcrelate tools/pcrelate.cwl
sbpack bdc smgogarten/genesis-relatedness/pcrelate-correct tools/pcrelate_correct.cwl
sbpack bdc smgogarten/genesis-relatedness/sample-blocks tools/sample_blocks.cwl
sbpack bdc smgogarten/genesis-relatedness/kinship-plots tools/kinship_plots.cwl
sbpack bdc smgogarten/genesis-relatedness/pc-relate pc-relate-wf.cwl

# test
python3 test/test_pcrelate.py
python3 test/test_pcrelate_noplots.py

# push to pre-build project
sbpack bdc smgogarten/genesis-relatedness-pre-build/pcrelate-beta tools/pcrelate_beta.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pcrelate tools/pcrelate.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/pcrelate-correct tools/pcrelate_correct.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/sample-blocks tools/sample_blocks.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl

# pull tools with new app ids from pre-build
sbpull bdc smgogarten/genesis-relatedness-pre-build/pcrelate-beta tools/pcrelate_beta.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pcrelate tools/pcrelate.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/pcrelate-correct tools/pcrelate_correct.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/sample-blocks tools/sample_blocks.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl

# push workflow to pre-build
sbpack bdc smgogarten/genesis-relatedness-pre-build/pc-relate pc-relate-wf.cwl

# push workflow to commit
sbpack bdc smgogarten/uw-gac-commit/pc-relate pc-relate-wf.cwl
