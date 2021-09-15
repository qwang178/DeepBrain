%% load trained encoder and read in the trained parameters
load("data/encoder.mat")
W1=AE_final.w_1;
B1=AE_final.b_1;
W2=AE_final.w_2;
B2=AE_final.b_2;

%% read in the scaled gene expression data (Z score,AD+control+other)
ROSMAP=csvread("data/ROSMAP_all.scaled.csv",1,1);

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden=sigmoid(dlarray(W1'*ROSMAP+repmat(B1',[1,size(ROSMAP,2)])));
first_layer_hidden=min(first_layer_hidden ,1-1e-9);                          
first_layer_hidden=max(first_layer_hidden ,1e-9);                            

%% write the manifold for trajectory inference
csvwrite("data/first_layer_hidden.csv",first_layer_hidden)

%% write the trained model parameters for future prediction 
csvwrite("data/B1.csv",B1)                           
csvwrite("data/W1.csv",W1)                           

