% get the weight of the important genes

load("../UMAP/encoder.mat");        % read in the trained model 
Weight = AE_final.w_1;
Weight(Weight <= 1e-6) = 0; % remove numerical errors
w = sqrt(sum(Weight.^2, 2));% calculate RSS
w = w/max(w);               % normalize
csvwrite("weight.csv",w);
