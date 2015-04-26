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
  rename(gene=X) %>%
  spread(gene,count)
                      
t_hr <- unique(joined$Growthtime.hr.)

for (t in t_hr)
{
	gene_hr <- filter(joined,Growthtime.hr.==t)
	
	if (length(unique(gene_hr$GrowthConditions))>1)
	{
		gene_hr %>% select(-sample,
						-Sample.,
					  -Experiment, 
					  -Batch, 
					  -GrowthConditions, 
					  -Growthtime.hr., 
					  -HarvestDate, 
					  -Notes.NGS., 
					  -Cell_total, 
					  -cells_per_tube, 
					  -X.tubesinstorage,
					  -concentration,
					  -cellCondition,
					  -condition,
					  -Batch_Concentration,
					  -Batch_Number) -> filtered
	
		filtered %>% prcomp() -> pca

		pca_data <- data.frame(pca$x, condition=gene_hr$GrowthConditions)

		# Generate plot
		p <- ggplot(pca_data, aes(x=PC1, y=PC2, color=condition)) + 
			geom_point()		
		ggsave(paste('pca_all_samples_t',t,'.pdf',sep=''),plot=p)

		rotation_data <- data.frame(pca$rotation, variable=row.names(pca$rotation))
		# define a pleasing arrow style
		arrow_style <- arrow(length = unit(0.05, "inches"),
							 type = "closed")
		# now plot, using geom_segment() for arrows and geom_text for labels
		p <- ggplot(rotation_data) + 
		  geom_segment(aes(xend=PC1, yend=PC2), x=0, y=0, arrow=arrow_style) + 
		  geom_text(aes(x=PC1, y=PC2, label=variable), hjust=0, size=3, color='red') + 
		  xlim(-1.,1.25) + 
		  ylim(-1.,1.) +
		  coord_fixed() # fix aspect ratio to 1:1
		ggsave(paste('pca_all_samples_t',t,'_arrows.pdf',sep=''),plot=p)
	}	
}