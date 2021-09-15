# plot the weight distribution histogram and make the cut

library(ggplot2)
library(see)
genes<-read.csv(file="../UMAP/ROSMAP_all.scaled.csv")       # the original scaled data                         
all<-read.csv(file="weight.csv",header=F)                   # weight from trained model                               
row.names(all)<-genes[,1]                                                       
colnames(all)<-"weight"                                     # add row and column label                    
g<-
ggplot(all, aes(x=0,y=weight,color="red"))+ scale_y_continuous(trans='log10', limits=c(1e-6, 1)) +
        geom_violinhalf() + coord_flip() +
        theme(legend.position="none", panel.grid.major = element_blank(),  
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour="black"), axis.title=element_text(size=16), 
        axis.text.x = element_text(size=14), axis.text.y= element_text(size=14)) +
        geom_abline(intercept=-3.8, slope=0, lty=2, color="black", size=0.5) +
        xlab("distribution")+ylab("weight")

ggsave(file="histogram.pdf",g,h=6,w=8)
q()
