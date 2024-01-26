library(ggplot2)
library(data.table)

# Extract data from tsv.gz
file_path <- "Homo_sapiens.gene_info.gz"
gene_info <- fread(file_path, sep = "\t", header = TRUE)
gene_info <- gene_info[, c(3, 7)]
gene_info <- gene_info[!grepl("[|-]", gene_info$chromosome), ]

# Count genes per chromosome
gene_count <- as.data.frame(table(gene_info$chromosome))
colnames(gene_count) <- c("chr", "count")

# Order chromosomes for plotting
gene_count$chr <- factor(gene_count$chr, levels = c(seq(1, 22), "X", "Y", "MT", "Un"))

# Plot results
p <- ggplot(gene_count, aes(x = chr, y = count)) +
        geom_bar(stat = "identity") +
        labs(title = "Number of genes in each chromosome",
            x = "Chromosomes",
            y = "Gene count") +
        theme_classic() +
        theme(plot.title = element_text(hjust = 0.5))

ggsave("genes_per_chr.pdf", p, width = 8, height = 6)
