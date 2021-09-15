library(monocle3)
library(slingshot)
library(uwot)

## Prepare the input files accordingly, like those for scRNAseq
e<-read.csv(file="data/first_layer_hidden.csv",header=F)             # from trained deep learning model
dx<-read.csv(file="data/dx.csv",header=T,row.names=1)                # meta data associated with the cohort                              
anno<-read.csv(file="data/annotation.csv",header=T,row.names=1)      # no real gene annotations necessary

row.names(e)<-row.names(anno)
colnames(e)<-row.names(dx)                    # match colnames and rownames of expression matrix 

## Create a monocle object and reduce the dimension by PCA first
cds<-new_cell_data_set(as.matrix(e),dx,anno)
cds<-preprocess_cds(cds,norm_method="none",scaling=F)
cds<-reduce_dimension(cds,max_components=3)
reduced<-cds@int_colData$reducedDims$PCA        # Only use the 50 PCA components 
cds<-cluster_cells(cds)
pca<-cbind(reduced,as.data.frame(cds@clusters$UMAP$clusters)[,1])     # Also keep the cluster #
colnames(pca)[51] <- "cluster"
write.csv(file="data/ROSMAP.pca.csv",pca,quote=F)       # keep the ROSMAP PCA for future model transformation

## Directly use uwot UMAP, for reproducibility. 
## The UMAP result is the same as cds@int_colData$reducedDims$UMAP
## This is just to show the same command can be used to retain the model for future prediction 
set.seed(2016)
ROSMAP.umap<-uwot::umap(reduced,n_components=3,nn_method="annoy",
                    n_neighbors=15L,metric="cosine",min_dist=0.1,
                    verbose=T,fast_sgd=F)

## slingshot pseudotime calculation
colnames(ROSMAP.umap)<-c("UMAP1","UMAP2","UMAP3")
sce<-slingshot(as.matrix(ROSMAP.umap),pca[,"cluster"],start.clus='1')   #start from the first cluster
time<-slingPseudotime(sce)

## write the UMAP coordniates and time (SI) to meta file
meta<-cbind(dx,ROSMAP.umap)
meta$SI<-time
write.csv(file="data/ROSMAP.SI.csv",meta,quote=F)

## Any linear regression to test the association between SI and phenotypes
q()
