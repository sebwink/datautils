suppressPackageStartupMessages(library(limma))

voom_transform <- function(count_matrix, row_sum_cutoff=-1, normalize_method="none") {
    count_matrix <- count_matrix[rowSums(count_matrix)>row_sum_cutoff,]
    return(voom(count_matrix, normalize.method = norm_method))
}