library(dplyr)
library(tidyr)
library(ggplot2)

# The following few lines just import data from CSVs and merge it into one
# data frame for easy analysis.
reads <- read.csv('deseq_normalized_mrna_data.csv')
reads %>% gather(sample, count, -X) -> reads
metadata <- read.csv('metaRNA.csv')
#joined <- inner_join(reads,metadata,by = c('sample'='Sample')) %>%
#  rename(gene=X) 

# Here is where you can filter the data based on various conditions
#joined %>% filter(Growth.Conditions == 'glucose'
#				&  
#				& Growth.time != 3 
#				& Growth.time != 4 
#				& Growth.time != 6 
#				& Growth.time != 168 
#				& Growth.time != 336 ) -> filtered_glu
#joined %>% filter(Growth.Conditions == 'glycerol' & Growth.time != 10 & Growth.time != 14 & Growth.time != 7 & Growth.time != 168 & Growth.time != 336 ) -> filtered_gly
#filtered <- data.frame(gene=filtered_glu$gene,
#						glucose=filtered_glu$count,
#						glycerol=filtered_gly$count)

#filtered %>% select(-gene) -> joined

# Calculate PCA
#joined %>% prcomp() -> pca

#pca_data <- data.frame(pca$x, gene=filtered$gene)

# Generate plot
#p <- ggplot(pca_data, aes(x=PC1, y=PC2, color=gene)) + geom_point()
#ggsave('pca_glucose_vs_glycerol.pdf',plot=p)