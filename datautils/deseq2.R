suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(DESeq2))

load_coldata <- function(path2coldata) {
  # ---
  coldata <- read.csv(gzfile(path2coldata), header = TRUE, check.names = FALSE)
  rownames(coldata) <- coldata[,"sample"]
  coldata <- coldata[sort(rownames(coldata)),]
  coldata <- subset(coldata, select=-c(sample))
  return(coldata)
}

get_normalized_counts <- function(count_matrix,
                                  coldata,
                                  design,
                                  row_sum_cutoff=1,
                                  num_cores = 4) {
  # ---
  register(MulticoreParam(num_cores))
  count_matrix <- count_matrix[, sort(colnames(count_matrix))]
  dds <- DESeqDataSetFromMatrix(countData = count_matrix,
                                colData = coldata,
                                design = as.formula(design))
  coldata_levels <- levels(coldata$condition)
  dds$conditions <- factor(dds$condition,levels = coldata_levels)
  dds <- dds[rowSums(counts(dds))>row_sum_cutoff,]
  dds <- estimateSizeFactors(dds)
  return(counts(dds, normalized=TRUE))
}
