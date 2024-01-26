suppressPackageStartupMessages({
    library(data.table)
    library(hash)
})

# Extract data from tsv.gz
file_path <- "Homo_sapiens.gene_info.gz"
gene_info <- fread(file_path, sep = "\t", header = TRUE)
gene_info <- gene_info[, c(2, 3, 5)]

# Create and fill hash table
map <- hash()

for (i in 1:nrow(gene_info)) {
    # Note: To account for those symbols which appear as both a symbol and synonym in
    # different rows (e.g. JUNB), we will define a given symbol's "primary_ID" as the
    # GeneID corresponding to the row in which that symbol appears in the Symbol column.
    # All symbols will be mapped to their primary_ID if one exists.

    map[gene_info[[i, 2]]] <- gene_info[[i, 1]]

    if (gene_info[[i, 3]] != "-") {
        symbols <- strsplit(gene_info[[i, 3]], split = "|", fixed = TRUE)[[1]]
        for (symbol in symbols) {
            if (!has.key(symbol, map)) {
                map[[symbol]] <- gene_info[[i, 1]]
            }
        }
    }
}

# Extract data from .gmt file
gmt <- "h.all.v2023.1.Hs.symbols.gmt"
lines <- readLines(gmt)

pathways <- lapply(lines, function(line) {
    line = strsplit(line, "\t")[[1]]

    for (i in 3:length(line)) {
        line[i] <- map[[line[i]]]
    }

    return(paste(unlist(line), collapse = "\t"))
})

# Write results
writeLines(unlist(pathways), "output.gmt")
