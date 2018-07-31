load_count_matrix <- function(path2countMatrix) {
  # ---
  count_matrix <- read.csv(gzfile(path2countMatrix), header = TRUE, check.names = FALSE)
  rownames(count_matrix) <- count_matrix[,"id"]
  count_matrix <- subset(count_matrix, select=-c(id))
  return(count_matrix)
}