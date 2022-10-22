%% Classification algorithm using CPANN, Kohonen, SKN and XYF Test code

%***************************
% CFRP Plate with 6 damages
%***************************

%----------------------------
%----Create the structure----
%----------------------------

clear
clc

%Define Dataset
%scores1
load ScTQ
dataSet = ScTQ;%ScTQ;

%Define labels
class_string = strings(140,1);
class_string(1:20) = "Und";
class_string(21:40) = "D1";
class_string(41:60) = "D2";
class_string(61:80) = "D3";
class_string(81:100) = "D4";
class_string(101:120) = "D5";
class_string(121:140) = "D6";
class_string = cellstr(class_string);

%Define network parameters
typeNet = 'xyf'; %The options are 'cpann', 'kohonen', 'skn' and 'xyf'
nsize = 10;%12cpann %Number of neurons in each side of the map, nsize x nsize
nEpochs = 300; %150cpann; %Number of epochs
init = 'random'; %*weight initialization*: 'random' or 'eigen'
a_max = 0.5;
a_min = 0.01;
%Scaling options: 'cent' centering; 'scal' variance scaling
          %'auto' autoscaling (centering + variance scaling)
          %'none' no scaling
net_settings = som_settings(typeNet,nsize,nEpochs);

%----------------------------
%---Cross validation setup---
%----------------------------

%SOM CV
cv_type = 'vene'; %'cont' for contiguous blocks, 'rand' for random sampling (montecarlo) of 20% of samples
cv_group = 5; %Number of divisions

%----------------------------
%----------Training----------
%----------------------------

switch (typeNet)
    case 'cpann'
        model = model_cpann(dataSet,class_string,net_settings);
        cv = cv_cpann(dataSet,class_string,net_settings,cv_type,cv_group);
    case 'kohonen'
        model = model_kohonen(dataSet,net_settings);
    case 'skn'
        model = model_skn(dataSet,class_string,net_settings);
        cv = cv_skn(dataSet,class_string,net_settings,cv_type,cv_group);
    case 'xyf'
        model = model_xyf(dataSet,class_string,net_settings);
        cv = cv_xyf(dataSet,class_string,net_settings,cv_type,cv_group);
end
%----------------------------
%-------Visualization--------
%----------------------------

visualize_topmap(model)
acc = cv.class_param.accuracy*100;

%% Supervised Self-Organizing Maps CPANN, SKN and XYF
%***************************
% Aluminum Plate 200x200mm
%***************************

%----------------------------
%----Create the structure----
%----------------------------

clear
clc

%Define Dataset
%scores1
load ScTQ
dataSet = ScTQ;%ScTQ;

%Define labels
class_string = strings(120,1);
class_string(1:20) = "Und";
class_string(21:40) = "D1";
class_string(41:60) = "D2";
class_string(61:80) = "D3";
class_string(81:100) = "D4";
class_string(101:120) = "D5";
class_string = cellstr(class_string);

%Define network parameters
typeNet = 'skn'; %The options are 'cpann', 'kohonen', 'skn' and 'xyf'
nsize = 10;%12cpann %Number of neurons in each side of the map, nsize x nsize
nEpochs = 500; %150cpann; %Number of epochs
init = 'random'; %*weight initialization*: 'random' or 'eigen'
a_max = 0.5;
a_min = 0.01;
%Scaling options: 'cent' centering; 'scal' variance scaling
          %'auto' autoscaling (centering + variance scaling)
          %'none' no scaling
net_settings = som_settings(typeNet,nsize,nEpochs,'Init','random',...
    'Train','sequential','Scaling','none');

%----------------------------
%---Cross validation setup---
%----------------------------

%SOM CV
cv_type = 'vene'; %'cont' for contiguous blocks, 'rand' for random sampling (montecarlo) of 20% of samples
cv_group = 5; %Number of divisions


%----------------------------
%----------Training----------
%----------------------------

switch (typeNet)
    case 'cpann'
        model = model_cpann(dataSet,class_string,net_settings);
        cv = cv_cpann(dataSet,class_string,net_settings,cv_type,cv_group);
    case 'kohonen'
        model = model_kohonen(dataSet,net_settings);
    case 'skn'
        model = model_skn(dataSet,class_string,net_settings);
        cv = cv_skn(dataSet,class_string,net_settings,cv_type,cv_group);
    case 'xyf'
        model = model_xyf(dataSet,class_string,net_settings);
        cv = cv_xyf(dataSet,class_string,net_settings,cv_type,cv_group);
end
%----------------------------
%-------Visualization--------
%----------------------------

visualize_topmap(model)
acc = cv.class_param.accuracy*100;
%---------------------------------------
%-------Cross validation results--------
%---------------------------------------

%Conf matrix
% C = cv.class_param.conf_mat;
% C(:,length(C)) = [];
% figure
% confusionchart(C,{'Und','D1','D2','D3'})
%print('Conf_matrix','-dpdf','-bestfit')

% %Comparing CV
% %*** k-NN CV ***
% %Setup
% K = 10;
% dist_type = 'euclidean';
% preprocess_rows = 'none';
% preprocess_columns = 'none';
% 
% %Apply setup
% cv_knn = knncv(dataSet,class_string,K,dist_type,preprocess_rows,preprocess_columns,cv_type,cv_group);
% C_knn = cv_knn.class_param.conf_mat;
% C_knn(:,length(C_knn)) = [];
% figure
% confusionchart(C_knn,{'Und','D1','D2','D3'})

%% Supervised Self-Organizing Maps CPANN, SKN and XYF
%******************************
% Aluminum Plate USTA 3 damages
%******************************

%----------------------------
%----Create the structure----
%----------------------------

clear
clc

%Define Dataset
%scores1
load ScTQ
dataSet = ScTQ;%ScTQ;

%Define labels
class_string = strings(100,1);
class_string(1:25) = "Und";
class_string(26:50) = "D1";
class_string(51:75) = "D2";
class_string(76:100) = "D3";
class_string = cellstr(class_string);

%Define network parameters
typeNet = 'xyf'; %The options are 'cpann', 'kohonen', 'skn' and 'xyf'
nsize = 10;%12cpann %Number of neurons in each side of the map, nsize x nsize
nEpochs = 350; %150cpann; %Number of epochs
init = 'random'; %*weight initialization*: 'random' or 'eigen'
a_max = 0.5;
a_min = 0.01;
%Scaling options: 'cent' centering; 'scal' variance scaling
          %'auto' autoscaling (centering + variance scaling)
          %'none' no scaling
net_settings = som_settings(typeNet,nsize,nEpochs,'Init','random',...
    'Train','sequential','Scaling','none');

%----------------------------
%---Cross validation setup---
%----------------------------

%SOM CV
cv_type = 'vene'; %'cont' for contiguous blocks, 'rand' for random sampling (montecarlo) of 20% of samples
cv_group = 5; %Number of divisions


%----------------------------
%----------Training----------
%----------------------------

switch (typeNet)
    case 'cpann'
        model = model_cpann(dataSet,class_string,net_settings);
        cv = cv_cpann(dataSet,class_string,net_settings,cv_type,cv_group);
    case 'kohonen'
        model = model_kohonen(dataSet,net_settings);
    case 'skn'
        model = model_skn(dataSet,class_string,net_settings);
        cv = cv_skn(dataSet,class_string,net_settings,cv_type,cv_group);
    case 'xyf'
        model = model_xyf(dataSet,class_string,net_settings);
        cv = cv_xyf(dataSet,class_string,net_settings,cv_type,cv_group);
end
%----------------------------
%-------Visualization--------
%----------------------------

visualize_topmap(model)

%---------------------------------------
%-------Cross validation results--------
%---------------------------------------

%Conf matrix
% C = cv.class_param.conf_mat;
% C(:,length(C)) = [];
% figure
% confusionchart(C,{'Und','D1','D2','D3'})