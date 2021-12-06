![graphic_abstract](https://user-images.githubusercontent.com/81768870/144928577-78b7fd15-0c26-4fa9-ae08-4c4203f85166.png)


# DeepBrain
Deep learning framework for Alzheimer's disease severity index (SI) from brain transcriptomic data

The code to reproduce the work reported at

https://www.biorxiv.org/content/10.1101/2021.06.08.447615v2

Deep Learning-Based Brain Transcriptomic Signatures Associated with the Neuropathological and Clinical Severity of Alzheimer’s Disease

Qi Wang, Kewei Chen, Yi Su, Eric M. Reiman, Joel T. Dudley, Benjamin Readhead

doi: https://doi.org/10.1101/2021.06.08.447615


The file structures are as follows:

ROSMAP_trained_model -- deep learning (supervised classification) of the neuropathologically confirmed AD and control subjects (n = 234), and unsupervised dimensionality reduction (UMAP) of the whole cohort subjects (n = 634), based on the RNAseq data from DLPFC tissues of ROSMAP cohort (syn8456629). 
          
          DeepType: representative training process for AD + control groups (5 fold cross validation)
          
          UMAP: intermediate layer manifold calculation for the whole cohort, dimensionality reduction of the manifold for a 3D tranjectory, and SI (pseudotime) calculation
          
          IndexGenes: index gene identification

MAYO -- SI calculation based on ROSMAP trained model for two brain regions (TCX and CER, syn8466812). Obtaining manifold representation by forward pass of the trained network, carrying out the UMAP transformation of the existing embedding model from ROSMAP to get the trajectory and SI.

MSBB -- SI calculation based on ROSMAP trained model for four brain regions (FP(Brodmann area 10), IFG(Brodmann area 44), STG(Brodmann area 22), PHG(Brodmann area 36), syn8484987). Obtaining manifold representation by forward pass of the trained network, carrying out the UMAP transformation of the existing embedding model from ROSMAP to get the trajectory and SI.

All the synapse data/results are withheld. 
