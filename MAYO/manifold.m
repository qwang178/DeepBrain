%% read in the trained parameters
W1=csvread("data/W1.common.csv",1,1);                                    
B1=csvread("data/B1.csv");                                    

%% read in the scaled gene expression data (Z score)
TCX=csvread("data/MAYO.TCX.scaled.csv",1,1);
CER=csvread("data/MAYO.CER.scaled.csv",1,1);                                         

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden=sigmoid(dlarray(W1'*TCX+repmat(B1',[1,size(TCX,2)])));
first_layer_hidden=min(first_layer_hidden,1-1e-9);                          
first_layer_hidden=max(first_layer_hidden,1e-9);                            

%% write the manifold for trajectory inference
csvwrite("data/TCX.first_layer_hidden.csv",first_layer_hidden)

%% calculate manifold of the intermediate layer by pass forward the trained network
first_layer_hidden=sigmoid(dlarray(W1'*CER+ repmat(B1',[1,size(CER,2)])));
first_layer_hidden=min(first_layer_hidden,1-1e-9);                          
first_layer_hidden=max(first_layer_hidden,1e-9);                            
                                                                                
%% write the manifold for trajectory inference                                  
csvwrite("data/CER.first_layer_hidden.csv",first_layer_hidden)                       

