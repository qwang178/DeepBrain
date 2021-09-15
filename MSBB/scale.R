library(sva)
library(synapser)
library(data.table)

## Download data
synLogin()
fileEntity <- synGet("syn8456638")                                              
ROSMAP <- read.table(fileEntity$path, header = T, sep = '\t', check.names = F)
fileEntity <- synGet("syn8485017")
MSBB <- read.table(fileEntity$path, header = T, sep = '\t', check.names = F)
fileEntity <- synGet("syn21893059")
biospecimen <- read.table(fileEntity$path, header = T, sep = ',', check.names = F) 
synLogout()

dt1 <- data.table(ROSMAP, key = 'ensembl_gene_id')
dt2 <- data.table(MSBB, key = 'ensembl_gene_id')

## Do an INNER JOIN-like operation, where non-matching rows are removed
e <- dt1[dt2, nomatch = 0]
e <- as.data.frame(e)
rownames(e) <- e$ensembl_gene_id
e <- e[, -1]
#write.table(e, file = "combined.common.tsv", sep = "\t", quote = F, col.names = NA)    

## Add rownames
rownames(ROSMAP) <- ROSMAP$ensembl_gene_id                                                  
ROSMAP <- ROSMAP[, -1]                                                                       
rownames(MSBB) <- MSBB$ensembl_gene_id                                                  
MSBB <- MSBB[, -1] 
                                                                      
## Prepare batch file
batch1 <- data.frame(rep("ROSMAP", ncol(ROSMAP)))
rownames(batch1) <- colnames(ROSMAP)
batch2 <- data.frame(rep("MSBB", ncol(MSBB)))                                  
rownames(batch2) <- colnames(MSBB)
colnames(batch1) <- "batch"                                                        
colnames(batch2) <- "batch"                                                        
batch <- rbind(batch1, batch2)

## Run batch correction
combat_e = ComBat(dat = as.matrix(e), batch = batch$batch, ref.batch = "ROSMAP")
#write.table(combat_e, file = "combat.common.tsv", sep = "\t", quote = F, col.names = NA)

## Run scaling based on ROSMAP mean/sd
MSBB <- combat_e[, -(1:ncol(ROSMAP))]

ROSMAP_scale <- read.csv(file = "data/ROSMAP.mean-sd.csv", header = T, row.names = 1)  # precalculated mean/sd for each gene
sorted.gene <- rownames(ROSMAP_scale)
MSBB <- MSBB[match(sorted.gene, rownames(MSBB)), ]
MSBB <- MSBB[complete.cases(MSBB), ]                                      # find the common genes
ROSMAP_scale <- ROSMAP_scale[sorted.gene %in% rownames(MSBB), ]

MSBB <- t(MSBB)                                                            # tranpose for scaling
MSBB <- scale(MSBB, center = ROSMAP_scale$mean, scale = ROSMAP_scale$sd)

## Get data for 4 brain regions respectively
FP <- subset(biospecimen, tissue == "frontal pole")
PHG <- subset(biospecimen, tissue == "parahippocampal gyrus")
STG <- subset(biospecimen, tissue == "superior temporal gyrus")
IFG <- subset(biospecimen, tissue == "inferior frontal gyrus")
MSBB_FP <- MSBB[rownames(MSBB) %in% FP$specimenID, ]
MSBB_FP <- t(MSBB_FP)
MSBB_STG <- MSBB[rownames(MSBB) %in% STG$specimenID, ]
MSBB_STG <- t(MSBB_STG)
MSBB_PHG <- MSBB[rownames(MSBB) %in% PHG$specimenID, ]
MSBB_PHG <- t(MSBB_PHG) 
MSBB_IFG <- MSBB[rownames(MSBB) %in% IFG$specimenID, ]                                                            
MSBB_IFG <- t(MSBB_IFG)                                                           
                                                           
write.csv(file = "data/MSBB.FP.scaled.csv", MSBB_FP, quote = F)
write.csv(file = "data/MSBB.STG.scaled.csv", MSBB_STG, quote = F)  
write.csv(file = "data/MSBB.PHG.scaled.csv", MSBB_PHG, quote = F)                     
write.csv(file = "data/MSBB.IFG.scaled.csv", MSBB_IFG, quote = F)                     

## intersect W1 for the common genes
W1 <- read.csv(file = "data/W1.csv", header = F)
rownames(W1) <- sorted.gene
W1 <- W1[rownames(W1) %in% rownames(ROSMAP_scale), ]
write.csv(file = "data/W1.common.csv", W1, quote = F)                           
q()
