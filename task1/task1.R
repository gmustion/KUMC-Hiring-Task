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
    # Note: To account for those symbols which appear as a symbol and synonym in
    # different rows (e.g. JUNB), we will define the GeneID corresponding to the
    # row in which a given symbol appears in the Symbol column as the "primary_ID."
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
pathways <- fread(gmt, header = FALSE, fill = TRUE, sep = "\t")

# Loop through all symbols and replace them with the hash table
for (i in 1:nrow(pathways)) {
    for (j in 3:ncol(pathways[i, ])) {
        sym = pathways[[i,j]]
        if (sym != "") {
            pathways[[i,j]] <- map[[sym]]
        }
    }
}

# Write results
fwrite(pathways, file = "output.tsv", sep = "\t", quote = FALSE, col.names=FALSE)
