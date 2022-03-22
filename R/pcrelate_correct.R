library(argparser)
library(PipelineHelper)
library(GENESIS)
sessionInfo()

argp <- arg_parser("PC-Relate")
argp <- add_argument(argp, "--pcrelate_prefix", help="prefix for pcrelate sample block files")
argp <- add_argument(argp, "--out_prefix", default="pcrelate",
                     help="prefix for output files (filenames must have suffix '_block_i_j.RData')")
argp <- add_argument(argp, "--sparse_threshold", default=0.02209709, 
                     help="Minimum kinship to use for creating the sparse matrix default is 4th deg")
argp <- add_argument(argp, "--n_sample_blocks", default=1, type="integer", 
                     help="number of blocks to divide samples into for parallel computation")
argv <- parse_args(argp)
writeParams(argv, "pcrelate_correct.params")

nsampblock <- argv$n_sample_blocks

kinSelf <- NULL
kinBtwn <- NULL
kin.thresh <- argv$sparse_threshold

### correct IBD results and combine
# i know the order seems weird, but this should make sure all the correct data is loaded when needed
for (i in nsampblock:1){
    for (j in i:nsampblock){
        message('Sample Blocks ', i, ' and ', j)
        
        ## load the data
        res <- getobj(paste0(argv$pcrelate_prefix, "_block_", i, "_", j, ".RData")) 
        
        if(i == j) kinSelf <- rbind(kinSelf, res$kinSelf)
        
        # correct the IBD estimates
        res$kinBtwn <- correctK2(kinBtwn = res$kinBtwn, 
                                 kinSelf = kinSelf, 
                                 small.samp.correct = FALSE, 
                                 pcs = NULL, 
                                 sample.include = NULL)
        
        res$kinBtwn <- correctK0(kinBtwn = res$kinBtwn)
        
        # this should replace the original results, but i probably wouldn't overwrite them yet
        save(res, file=paste0(argv$out_prefix, "_block_", i, "_", j, "_corrected.RData"))

        # save results above threshold in combined file
        kinBtwn <- rbind(kinBtwn, res$kinBtwn[kin > kin.thresh])
        
        rm(res); gc()
    }
}

# save pcrelate object
pcrelobj <- list(kinSelf = kinSelf, kinBtwn = kinBtwn)
class(pcrelobj) <- "pcrelate"
save(pcrelobj, file=paste0(argv$out_prefix, ".RData"))

rm(kinBtwn, kinSelf); gc()
   
# save sparse kinship matrix
km <- pcrelateToMatrix(pcrelobj, thresh = 2*kin.thresh, scaleKin = 2)
save(km, file=paste0(argv$out_prefix, "Matrix.RData"))
