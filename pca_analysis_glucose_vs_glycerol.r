library(dplyr)
library(tidyr)
library(ggplot2)
library(grid)

# The following few lines just import data from CSVs and merge it into one
# data frame for easy analysis.
reads <- read.csv('deseq_normalized_mrna_data.csv')
reads %>% gather(sample, count, -X) -> reads
metadata <- read.csv('metaRNA.csv')
joined <- inner_join(reads,metadata,by = c('sample'='dataSet')) %>%
  rename(gene=X) 

# Here is where you can filter the data based on various conditions
joined %>% filter(GrowthConditions == 'glucose'
				& Growthtime.hr. != 3 
				& Growthtime.hr. != 4 
				& Growthtime.hr. != 6 
				& Growthtime.hr. != 168 
				& Growthtime.hr. != 336 ) -> filtered_glu
joined %>% filter(GrowthConditions == 'glycerol' 
				& Growthtime.hr. != 10 
				& Growthtime.hr. != 14 
				& Growthtime.hr. != 7 
				& Growthtime.hr. != 168 
				& Growthtime.hr. != 336 ) -> filtered_gly
				
filtered <- data.frame(gene=filtered_glu$gene,
						glucose_1=filtered_glu[filtered_glu$Batch_Number==7,]$count,
						glucose_2=filtered_glu[filtered_glu$Batch_Number==8,]$count,
						glucose_3=filtered_glu[filtered_glu$Batch_Number==9,]$count,
						glycerol_1=filtered_gly[filtered_gly$Batch_Number==10,]$count,
						glycerol_2=filtered_gly[filtered_gly$Batch_Number==11,]$count,
						glycerol_3=filtered_gly[filtered_gly$Batch_Number==12,]$count)

filtered %>% select(-gene) -> joined
# Calculate PCA
joined %>% prcomp() -> pca

pca_data <- data.frame(pca$x, gene=filtered$gene)

# Generate plot
p <- ggplot(pca_data, aes(x=PC1, y=PC2, color=gene)) + 
	geom_point() +
	geom_text(aes(x=PC1, y=PC2, label=gene),hjust=0, size=3, color='black') 
ggsave('pca_glucose_vs_glycerol.pdf',plot=p)

rotation_data <- data.frame(pca$rotation, variable=row.names(pca$rotation))
# define a pleasing arrow style type = "closed")
# now plot, using geom_segment() for arrows and geom_text for labels
p <- ggplot(rotation_data) + 
  geom_segment(aes(xend=PC1, yend=PC2), x=0, y=0, arrow=arrow_style) + 
  geom_text(aes(x=PC1, y=PC2, label=variable), hjust=0, size=3, color='red') + 
  xlim(-1.,1.25) + 
  ylim(-1.,1.) +
  coord_fixed() # fix aspect ratio to 1:1
ggsave('pca_glucose_vs_glycerol_arrows.pdf',plot=p)