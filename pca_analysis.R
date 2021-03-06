##########################################################################
# This script must be run with 'deseq_normalized_mrna_data.csv' and
# 'sample_list.csv' in the current working directory.
##########################################################################

rm(list=ls())
library(dplyr)
library(tidyr)
library(ggplot2)

# The following few lines just import data from CSVs and merge it into one
# data frame for easy analysis.
reads <- read.csv('deseq_normalized_mrna_data.csv')
reads %>% gather(sample, count, -X) -> reads
metadata <- read.csv('metaRNA.csv')
joined <- inner_join(reads,metadata,by = c('sample'='dataSet')) %>%
  rename(gene=X) %>%
  spread(gene,count)

# Here is where you can filter the data based on various conditions
joined %>% filter(Growthtime.hr. > 24) -> filtered

# In order to do PCA, you have to remove EVERYTHING that's not a gene count from
# the data frame.
filtered %>% select(-sample,
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
                    -Batch_Number) -> joined

# Calculate PCA
joined %>% prcomp() -> pca

# Now you need to add back in a column with some information that will
# be used to color the points on the PCA plot. Here I'm coloring by
# growth conditions.
pca_data <- data.frame(pca$x, condition=filtered$GrowthConditions)

# Generate plot
p <- ggplot(pca_data, aes(x=PC1, y=PC2, color=condition)) + geom_point()
print(p)