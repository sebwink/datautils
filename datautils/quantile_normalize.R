#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(optparse))
suppressMessages(suppressPackageStartupMessages(library(crunch)))
suppressPackageStartupMessages(library(preprocessCore))

options <- list(
  make_option("--data-matrix",  
              help = "Path of data matrix (gzipped tsv with 'id' column)"),
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

data_matrix <- load_count_matrix(args[["data-matrix"]])
outfile <- args[["output-file"]]
if (outfile == "") {
  outfile <- paste0(getwd(), "/normalized_counts.csv.gz")
}
verbose <- args[["verbose"]]

if (verbose) {
  cat("\n########## Carry out Quantile normalization! Sretan put! ##########\n\n")
}
transformed_counts <- normalize.quantiles(as.matrix(data_matrix))
if (verbose) {
  cat("\nDone with normalization. Writing results.\n")
}
colnames(transformed_counts) <- colnames(data_matrix)
rownames(transformed_counts) <- rownames(data_matrix)
write.csv.gz(transformed_counts, outfile, row.names=TRUE)
