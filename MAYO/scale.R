library(sva)
library(synapser)
library(data.table)

## Download data from synapse
synLogin()
fileEntity<-synGet("syn8456638")                                              
ROSMAP<-read.table(fileEntity$path,header=T,sep='\t',check.names=F)
fileEntity<-synGet("syn8466816")
MAYO<-read.table(fileEntity$path,header=T,sep='\t',check.names=F)
synLogout()

dt1<-data.table(ROSMAP,key='ensembl_gene_id')
dt2<-data.table(MAYO,key='ensembl_gene_id')

## Do an INNER JOIN-like operation,where non-matching rows are removed
e<-dt1[dt2,nomatch=0]
e<-as.data.frame(e)
rownames(e)<-e$ensembl_gene_id
e<-e[,-1]
#write.table(e,file="combined.common.tsv",sep="\t",quote=F,col.names=NA)    

## Add rownames
rownames(ROSMAP)<-ROSMAP$ensembl_gene_id                                                  
ROSMAP<-ROSMAP[,-1]                                                                       
rownames(MAYO)<-MAYO$ensembl_gene_id                                                  
MAYO<-MAYO[,-1] 
                                                                      
## Prepare batch file
batch1<-data.frame(rep("ROSMAP",ncol(ROSMAP)))
rownames(batch1)<-colnames(ROSMAP)
batch2<-data.frame(rep("MAYO",ncol(MAYO)))                                  
rownames(batch2)<-colnames(MAYO)
colnames(batch1)<-"batch"                                                        
colnames(batch2)<-"batch"                                                        
batch<-rbind(batch1,batch2)

## Run batch correction
combat_e=ComBat(dat=as.matrix(e),batch=batch$batch,ref.batch="ROSMAP")
#write.table(combat_e,file="combat.common.tsv",sep="\t",quote=F,col.names=NA)

## Run scaling based on ROSMAP mean/sd
MAYO<-combat_e[,-(1:ncol(ROSMAP))]

ROSMAP_scale<-read.csv(file="data/ROSMAP.mean-sd.csv",header=T,row.names=1)  # precalculated mean/sd for each gene
sorted.gene<-rownames(ROSMAP_scale)
MAYO<-MAYO[match(sorted.gene,rownames(MAYO)),]
MAYO<-MAYO[complete.cases(MAYO),]                                      # find the common genes
ROSMAP_scale<-ROSMAP_scale[sorted.gene %in% rownames(MAYO),]

MAYO<-t(MAYO)                                                            # tranpose for scaling
MAYO<-scale(MAYO,center=ROSMAP_scale$mean,scale=ROSMAP_scale$sd)

MAYO_TCX<-MAYO[grep("TCX",rownames(MAYO)),]                           # two regions                                          
MAYO_TCX<-t(MAYO_TCX)
MAYO_CER<-MAYO[grep("CER",rownames(MAYO)),]                                   
MAYO_CER<-t(MAYO_CER)                                                           
write.csv(file="data/MAYO.TCX.scaled.csv",MAYO_TCX,quote=F)
write.csv(file="data/MAYO.CER.scaled.csv",MAYO_CER,quote=F)  

## intersect W1 for the common genes
W1<-read.csv(file="data/W1.csv",header=F)
rownames(W1)<-sorted.gene
W1<-W1[rownames(W1) %in% rownames(ROSMAP_scale),]
write.csv(file="data/W1.common.csv",W1,quote=F)                           
q()
