clc;
clear;
close all;

%% Load Data
Data=ReadDataset();

%% Apriori
% Parameters are: Data, Minimum Confidence, Minimum Support
[EndofRules]=Apriori(Data,0.22,0.7);

%% Results
disp('Rules are:');
disp(' ');
for index_i=1:size(EndofRules,1)
    disp(['Rule No. #' num2str(index_i) ': ' mat2str(EndofRules{index_i,1}) ' ==> ' mat2str(EndofRules{index_i,2})]);
    disp(['       SUPP = ' num2str(EndofRules{index_i,3})]);
    disp(['       CONF = ' num2str(EndofRules{index_i,4})]);
    disp(' ');
end
disp(' ');
