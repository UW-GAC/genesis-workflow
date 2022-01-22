#! /bin/bash

# push to development project
sbpack bdc smgogarten/genesis-relatedness/ld-pruning tools/ld_pruning.cwl
sbpack bdc smgogarten/genesis-relatedness/subset_gds tools/subset_gds.cwl
sbpack bdc smgogarten/genesis-relatedness/merge-gds tools/merge_gds.cwl
sbpack bdc smgogarten/genesis-relatedness/check-merged-gds tools/check_merged_gds.cwl
sbpack bdc smgogarten/genesis-relatedness/ld-pruning-pipeline ld-pruning-wf.cwl

# test
python3 test/test_ld_pruning.py

# push to pre-build project
sbpack bdc smgogarten/genesis-relatedness-pre-build/ld-pruning ld-pruning-wf.cwl.steps/ld_pruning.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/subset-gds ld-pruning-wf.cwl.steps/subset_gds.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/merge-gds ld-pruning-wf.cwl.steps/merge_gds.cwl
sbpack bdc smgogarten/genesis-relatedness-pre-build/check-merged-gds ld-pruning-wf.cwl.steps/check_merged_gds.cwl

# pull tools with new app ids from pre-build
sbpull bdc smgogarten/genesis-relatedness-pre-build/ld-pruning tools/ld_pruning.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/subset-gds tools/subset_gds.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/merge-gds tools/merge_gds.cwl
sbpull bdc smgogarten/genesis-relatedness-pre-build/check-merged-gds tools/check_merged_gds.cwl

# push workflow to pre-build
sbpack bdc smgogarten/genesis-relatedness-pre-build/ld-pruning-1 ld-pruning-wf.cwl

# push workflow to commit
sbpack bdc smgogarten/uw-gac-commit/ld-pruning ld-pruning-wf.cwl
