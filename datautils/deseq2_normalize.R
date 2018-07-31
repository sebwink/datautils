#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(optparse))
suppressMessages(suppressPackageStartupMessages(library(crunch)))

options <- list(
  make_option("--count-matrix",  
              help = "Path of count matrix (gzipped tsv with 'id' column)"),
  make_option("--coldata",
              help = "Path of coldata (gzipped tsv with columns 'sample' and 'condition'"),
  make_option("--design", default="~1",
              help = "Design of the experiment [default \"%default\", ie no condition]"),
  make_option("--row-sum-cutoff", default=-1, type="integer",
              help = "Only genes with more reads across all samples will be considered. [default \"%default\"]"),
  make_option("--num-cores", default=4, type="integer",
              help = "Number of processor cores to use for the calculation [default \"%default\"]"),
  make_option("--output-file", default="",
              help = "Path of the result file to be written [default cwd]"),
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Print extra output [default]"),
  make_option("--path-of-script", default="",
              help="Path of this script (not meant to be used by Python scripts")
  )

args <- parse_args(OptionParser(usage="%prog --count-matrix=path/to/tsv.gz --coldata=path/to/tsv.gz [options]",
                                option_list=options))

SCRIPTDIR <- args[["path-of-script"]]
if (SCRIPTDIR == "") {
    # only works if script is started below graphkernels root
    SCRIPTDIR <- here("data/utils")
}
source(paste0(SCRIPTDIR, "/io.R"))
source(paste0(SCRIPTDIR, "/deseq2.R"))

count_matrix <- load_count_matrix(args[["count-matrix"]])
coldata <- load_coldata(args[["coldata"]])
design <- args[["design"]]
row_sum_cutoff <- args[["row-sum-cutoff"]]
num_cores <- args[["num-cores"]]
outfile <- args[["output-file"]]
if (outfile == "") {
    outfile <- paste0(getwd(), "/normalized_counts.csv.gz")
}
verbose <- args[["verbose"]]

if (verbose) {
    cat("\n########## Normalizing counts with DESeq2 ##########\n\n")
}
normalized_counts <- get_normalized_counts(count_matrix, 
                                           coldata, 
                                           design,
                                           row_sum_cutoff,
                                           num_cores)
if (verbose) {
    cat("\nDone with normalization. Writing results.\n")
}
write.csv.gz(normalized_counts, outfile, row.names=TRUE)
