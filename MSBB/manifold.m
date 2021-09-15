%% read in the trained parameters
W1  =  csvread("data/W1.common.csv", 1, 1);
B1  =  csvread("data/B1.csv");

%% read in the scaled gene expression data (Z score,  four regions)
FP  =  csvread("data/MSBB.FP.scaled.csv", 1, 1);
STG  =  csvread("data/MSBB.STG.scaled.csv", 1, 1);
PHG  =  csvread("data/MSBB.PHG.scaled.csv", 1, 1);
IFG  =  csvread("data/MSBB.IFG.scaled.csv", 1, 1);

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden  =  sigmoid(dlarray(W1' * FP + repmat(B1', [1, size(FP, 2)])));
first_layer_hidden  =  min(first_layer_hidden, 1-1e-9);
first_layer_hidden  =  max(first_layer_hidden, 1e-9);

%% write the manifold for trajectory inference
csvwrite("data/FP.first_layer_hidden.csv", first_layer_hidden)

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden  =  sigmoid(dlarray(W1' * STG + repmat(B1', [1, size(STG, 2)])));
first_layer_hidden  =  min(first_layer_hidden, 1-1e-9);
first_layer_hidden  =  max(first_layer_hidden, 1e-9);

%% write the manifold for trajectory inference
csvwrite("data/STG.first_layer_hidden.csv", first_layer_hidden)

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden  =  sigmoid(dlarray(W1' * PHG + repmat(B1', [1, size(PHG, 2)])));
first_layer_hidden  =  min(first_layer_hidden, 1-1e-9);
first_layer_hidden  =  max(first_layer_hidden, 1e-9);

%% write the manifold for trajectory inference
csvwrite("data/PHG.first_layer_hidden.csv", first_layer_hidden)

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden  =  sigmoid(dlarray(W1' * IFG + repmat(B1', [1, size(IFG, 2)])));
first_layer_hidden  =  min(first_layer_hidden, 1-1e-9);
first_layer_hidden  =  max(first_layer_hidden, 1e-9);

%% write the manifold for trajectory inference
csvwrite("data/IFG.first_layer_hidden.csv", first_layer_hidden)

