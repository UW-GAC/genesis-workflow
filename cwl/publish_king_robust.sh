#! /bin/bash

# push to development project
sbpack bdc smgogarten/genesis-relatedness/king-robust tools/king_robust.cwl
sbpack bdc smgogarten/genesis-relatedness/kinship-plots tools/kinship_plots.cwl
sbpack bdc smgogarten/genesis-relatedness/king-robust-1 king-robust-wf.cwl

 #test
python3 test/test_king_robust.py

# push to pre-build project
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-robust tools/king_robust.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl

# pull tools with new app ids from pre-build
sbpull bdc smgogarten/genesis-relatedness-pre-build/king-robust tools/king_robust.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/kinship-plots tools/kinship_plots.cwl

# push workflow to pre-build
sbpack bdc smgogarten/genesis-relatedness-pre-build/king-robust-1 king-robust-wf.cwl

# push workflow to commit
sbpack bdc smgogarten/uw-gac-commit/king-robust king-robust-wf.cwl
