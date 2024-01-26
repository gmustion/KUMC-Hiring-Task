#!/bin/sh

fasta="NC_000913.faa"
address="https://ftp.ncbi.nlm.nih.gov/genomes/archive/old_refseq/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid57779/NC_000913.faa"

if [ ! -f "$fasta" ]; then
    wget "$address"
fi

num_bases=$(grep -v '>' "$fasta" | tr -d '\n'| wc -c)
num_proteins=$(grep -c '>' "$fasta")

echo "Average Protein Length: $(echo "$num_bases / $num_proteins" | bc)"
