## sample code to predict SI for FP. Other regions could be predicted the same way
## ROSMAP data used to transform umap to the same 3D space and guide lineage start

library(monocle3)
library(slingshot)
library(uwot)

## Prepare the input files accordingly,  like those for scRNAseq
e <- read.csv(file = "data/FP.first_layer_hidden.csv", header = F)             # from pass forward trained deep learning model
dx <- read.csv(file = "data/FP.dx.csv", header = T, row.names = 1)                # meta data associated with the cohort(region)                              
anno <- read.csv(file = "data/annotation.csv", header = T, row.names = 1)      # no real gene annotations necessary

rownames(e) <- rownames(anno)
colnames(e) <- rownames(dx)                    # match colnames and rownames of expression matrix 

## Create a monocle object and reduce the dimension by PCA first
cds <- new_cell_data_set(as.matrix(e), dx, anno)
cds <- preprocess_cds(cds, norm_method = "none", scaling = F)
cds <- reduce_dimension(cds, max_components = 3)
reduced <- cds@int_colData$reducedDims$PCA        # Only use the 50 PCA components 

## Use ROSMAP PCA to UMAP and retain the model for prediction
ROSMAP <- read.csv(file = "data/ROSMAP.pca.csv", row.names = 1)
ROSMAP.cluster <- ROSMAP[, "cluster"]                                                     
ROSMAP <- ROSMAP[, -51]                            # extract the ROSMAP cluster info
set.seed(2016)
ROSMAP.umap <- uwot::umap(ROSMAP, n_components = 3, nn_method = "annoy", 
                    n_neighbors = 15L,  metric = "cosine",  min_dist = 0.1,  
                    verbose = T,  fast_sgd = F,  ret_model = T)
umap <- umap_transform(reduced, ROSMAP.umap, verbose = T)             # transform based on ROSMAP trajectory

## slingshot pseudotime calculation
colnames(umap) <- c("UMAP1", "UMAP2", "UMAP3")
umap.cluster <- rep("-1", nrow(umap))                              # cluster is unassigned
umap <- rbind(ROSMAP.umap$embedding, umap)                         # add ROSMAP embedding
cluster <- c(as.character(ROSMAP.cluster), as.character(umap.cluster))    # add ROSMAP cluster #
sce <- slingshot(as.matrix(umap), cluster, start.clus = '1')          # start from ROSMAP cluster 1
time <- slingPseudotime(sce, na = F)                                                 
umap <- umap[-(1:nrow(ROSMAP)), ]                                  # drop ROSMAP info
time <- time[-(1:nrow(ROSMAP)), ]                                                  

## write the UMAP coordniates and time (SI) to meta file
meta <- cbind(dx, umap)
meta$SI <- time
write.csv(file = "data/FP.SI.csv", meta, quote = F)

## Any linear regression to test the association between SI and phenotypes
q()
