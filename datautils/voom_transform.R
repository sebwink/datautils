#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(optparse))
suppressMessages(suppressPackageStartupMessages(library(crunch)))

options <- list(
  make_option("--count-matrix",  
              help = "Path of count matrix (gzipped tsv with 'id' column)"),
  make_option("--row-sum-cutoff", default=-1, type="integer",
              help = "Only genes with more reads across all samples will be considered. [default \"%default\"]"),
  make_option("--normalize-method", default="none",
              help = "Normalize data with given normalization method [default \"none\"]"),
  make_option("--output-file", default="",
              help = "Path of the result file to be written [default cwd]"),
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Print extra output [default]"),
  make_option("--path-of-script", default="",
              help="Path of this script (not meant to be used by Python scripts")
)

args <- parse_args(OptionParser(usage="%prog --count-matrix=path/to/tsv.gz [options]",
                                option_list=options))

SCRIPTDIR <- args[["path-of-script"]]
if (SCRIPTDIR == "") {
  # only works if script is started below graphkernels root
  SCRIPTDIR <- here("data/utils")
}
source(paste0(SCRIPTDIR, "/io.R"))
source(paste0(SCRIPTDIR, "/voom.R"))

count_matrix <- load_count_matrix(args[["count-matrix"]])
row_sum_cutoff <- args[["row-sum-cutoff"]]
norm_method <- args[["normalize-method"]]
outfile <- args[["output-file"]]
if (outfile == "") {
  outfile <- paste0(getwd(), "/normalized_counts.csv.gz")
}
verbose <- args[["verbose"]]

if (verbose) {
  cat("\n########## Transforming counts with limma::voom ##########\n\n")
}
transformed_counts <- voom_transform(count_matrix, row_sum_cutoff, norm_method)
if (verbose) {
  cat("\nDone with transformation Writing results.\n")
}
write.csv.gz(transformed_counts, outfile, row.names=TRUE)
