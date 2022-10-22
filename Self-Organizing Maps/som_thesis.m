%% Self organizing map, test code. Aluminium plate with 2-3 damages (mine)

close all
clear
clc

%Gathering values
load ScTQr
wkspcData = ScTQr;

%------------------------------
%----Step 1: Construct Data----
%------------------------------

%Generating the labels

%Data struct
sData = som_data_struct(wkspcData,'name','struc states');

%----------------------------------
%----Step 2: Data normalization----
%----------------------------------
optn = 2;
switch(optn)
    case 1
       sData = som_normalize(sData,'var');
    case 2
       sData = som_normalize(sData,'range');
    case 3
       sData = som_normalize(sData,'log');
    case 4
       sData = som_normalize(sData,'logistic');
    case 5
       sData = som_normalize(sData,'histC');
    case 6
       sData = som_normalize(sData,'histD');
end

%----------------------------
%----Step 3: Map training----
%----------------------------

%***Getting info about data***
dataIn = sData.data;
compNames = sData.comp_names;
compNorm = sData.comp_norm;
dataName = sData.name;
[dlen,dim] = size(dataIn);

%--Map struct is created--
sMap = som_map_struct(dim);%Just the struct, there are no data yet.

%*******Input Parameters*******
mapName = 'Map';
sMap.name = mapName;

%**Map Topology**
%--Map size--
m = 10;%17
n = 8; %9
mapSize = [m n]; %[rows columns] %[15 9]
sMap.topol.msize = mapSize;

%--Map Lattice--
mapLatt = 'hexa'; %'hexa' or 'rect'
sMap.topol.lattice = mapLatt;

%--Map shape--
mapShape = 'sheet'; %'sheet', 'cyl' or 'toroid'
sMap.topol.shape = mapShape;

mapTopol = sMap.topol; 
%**************************

%--Map mask--
mask = sMap.mask; %default value

%--Neighborhood function--
neighFunc = 'gaussian'; %'gaussian', 'cutgauss', 'ep' or 'bubble'
sMap.neigh = neighFunc;

%--Tracking--
tracking = 1;

%--Initialization Algorithm--
initalg = 'randinit'; %'lininit' or 'randinit'

%--Training Algorithm--
algorithm = 'seq'; %'seq' or 'batch'
sMap.trainhist.algorithm = algorithm;

%--Number of training epochs--
numEpochs = 300;
training = [numEpochs numEpochs*5]; 

% map struct construction
sMap = som_map_struct(dim,mapTopol,neighFunc,'mask',mask,'name',mapName, ...
                      'comp_names',compNames,'comp_norm',compNorm);

%*******Initialization*******
switch (initalg)
    case 'randinit', sMap = som_randinit(dataIn,sMap); %Random Initialization
    case 'lininit', sMap = som_lininit(dataIn, sMap); %Linear Initialization
end

sMap.trainhist = som_set(sMap.trainhist,'data_name',dataName);

%*******Training*******

%Rough Training (First training step)
sTrain = som_train_struct(sMap,'dlen',dlen,'algorithm',algorithm,'phase','rough');
sTrain = som_set(sTrain,'data_name',dataName);
sTrain.trainlen = training(1); 
switch (algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
end

%Finetuning Training (Second training step)
sTrain = som_train_struct(sMap,'dlen',dlen,'phase','finetune');
sTrain = som_set(sTrain,'data_name',dataName,'algorithm',algorithm);
sTrain.trainlen = training(2); 
switch (algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
end

%****Quality****
%Check quality of map
[mqe,tge] = som_quality(sMap,dataIn);
fprintf(1,'Final quantization error: %5.3f\n',mqe)
fprintf(1,'Final topographic error:  %5.3f\n',tge)

%-----------------------------------------------------
%--------------Step 4: Visualize the SOM--------------
%-----------------------------------------------------

%First we visualize the map only with the training data (just to compare later
%when the damage data is inserted.)
figure(1)
som_show(sMap,'umat','all')%Visualize the 1D U-matrix

%-----------------------------
%------Step 5: Testing--------
%-----------------------------

load ScTQ

dataIn2 = ScTQ;

typeStruct = 1;
if (typeStruct == 1)
    %In this case the labels are 1:18 Und, 19:36 D1, 37:54 D2
    %labels = strings(75,1);
    labels = strings(120,1);
    labels(1:20) = "Und";
    labels(21:40) = "D1";
    labels(41:60) = "D2";
    labels(61:80) = "D3";
    labels(81:100) = "D4";
    labels(101:120) = "D5";
    %labels(111:130) = "D6";
    %labels(131:149) = "D7";
    %labels(150:168) = "D8";
    %labels(169:187) = "D9";
    labels = cellstr(labels);
    sData2 = som_data_struct(dataIn2,'name','struc states','labels',labels);
elseif (typeStruct == 2)
    sData2 = som_data_struct(dataIn2,'name','struc states');
end

%Test map model with test data
%sMap = som_batchtrain(sMap,dataIn2,sTrain);
s_algorithm = 'batch';
switch (s_algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn2,sTrain);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn2,sTrain);
end

%Show u-matrix
figure(2)
som_show(sMap,'umat','all')

% figure
% som_show_mod(sMap,'umat','all')

%Labeling
sMap = som_autolabel(sMap,sData2,'freq');

if (typeStruct == 1)
    %The hit histogram for the whole dataset is calculated
    h1 = som_hits(sMap,sData2.data(1:20,:));
    h2 = som_hits(sMap,sData2.data(21:40,:));
    h3 = som_hits(sMap,sData2.data(41:60,:));
    h4 = som_hits(sMap,sData2.data(61:80,:));
    h5 = som_hits(sMap,sData2.data(81:100,:));
    h6 = som_hits(sMap,sData2.data(101:120,:));
    %h7 = som_hits(sMap,sData2.data(111:130,:));
    %h8 = som_hits(sMap,sData2.data(131:149,:));
    %h9 = som_hits(sMap,sData2.data(150:168,:));
    %h10 = som_hits(sMap,sData2.data(169:187,:));
    
    figure(3)
    som_show(sMap,'empty','Histogram')
    %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
    %som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
    %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
    som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
    som_show_add('label',sMap,'Textsize',8,'TextColor','k')%labels are added to the map
    
    figure(4)
    colormap(1-gray)
    som_show(sMap,'umat','all')
    %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
    %som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
    %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
    som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
    som_show_add('label',sMap,'Textsize',8,'TextColor','k')
    
end


%**Visualize the surface (3D) U-matrix
figure(5)
en = 1;
if (en == 1)
Co=som_unit_coords(sMap); U=som_umat(sMap); U=U(1:2:size(U,1),1:2:size(U,2));
som_grid(sMap,'Coord',[Co, U(:)],'Surf',U(:),'Marker','none');
view(-80,45), axis tight, title('Distance matrix')
end

%% This algorithm was modified to process the dataset with plenty TRAIN data and 
%automated to make iterations
tic
diary struct3Dam.txt
close all
clear
clc

ncomp=8;%[2,4,6,8]; 

%Read file or variable in the workspace
%For this example, the variable scores is used

dir = 'Files_compl';
if ~exist(dir, 'dir')%Check if the directory already exists
    error('The main directory does not exist!')
else
    cd(dir)
end

for j=1:length(ncomp)
    dirName1 = strcat('prep_ncomp-',num2str(ncomp(j)));
    if not(isfolder(dirName1))%Check if the directory already exists
        err_mess = strcat('The folder ',dirName1,' does not exist!');
        error(err_mess)
    else
        cd(dirName1)
    end
    
    method = ["auto","grps","relat1","relat4","range1","range2","snvt"];
    
    for k = 1:length(method)     
        %N = 4;
        dirName2 = strcat('norm_meth_',method(k));
        if not(isfolder(dirName2))%Check if the directory already exists
            err_mess = strcat('The folder ',dirName2,' does not exist!');
            error(err_mess)
        else
            cd(dirName2)
        end
        %------------------------------
        %----Step 0: Get Dataset----
        %------------------------------        
        %Getting matrices
        load ScTQr
        wkspcData = ScTQr;

        fprintf(1,'Normalization...\n');
        normMeth = ["var","range","log","logistic","histD","histC"];
        cont = 1;
        for optn = 1:6
            %------------------------------
            %----Step 1: Construct Data----
            %------------------------------
            %Data struct
            sData = som_data_struct(wkspcData,'name','struc states');
            
            %----------------------------------
            %----Step 2: Data normalization----
            %----------------------------------
            
            switch(optn)
                case 1
                   sData = som_normalize(sData,'var');
                case 2
                   sData = som_normalize(sData,'range');
                case 3
                   sData = som_normalize(sData,'log');
                case 4
                   sData = som_normalize(sData,'logistic');
                case 5
                   sData = som_normalize(sData,'histD');
                case 6
                   sData = som_normalize(sData,'histC');
            end
            
            fprintf(1,'Normalization performed with %s \n',normMeth(optn));
            
            for l = 1:2
                for r = 1:2
                    fprintf(1,'**Map Training**\n');
                    %----------------------------
                    %----Step 3: Map training----
                    %----------------------------

                    %***Getting info about data***
                    dataIn = sData.data;
                    compNames = sData.comp_names;
                    compNorm = sData.comp_norm;
                    dataName = sData.name;
                    [dlen,dim] = size(dataIn);

                    %--Map struct is created--
                    sMap = som_map_struct(dim);%Just the struct, there are no data yet.

                    %*******Input Parameters*******
                    mapName = 'Map';
                    sMap.name = mapName;

                    %**Map Topology**
                    %--Map size--
                    m = 10;
                    n = 10;
                    mapSize = [m n]; %[rows columns] %[15 9]
                    sMap.topol.msize = mapSize;
                    
                    fprintf(1,'Map Size [%d %d] \n',m,n);
                    
                    %--Map Lattice--
                    mapLatt = 'hexa'; %'hexa' or 'rect'
                    sMap.topol.lattice = mapLatt;

                    %--Map shape--
                    mapShape = 'sheet'; %'sheet', 'cyl' or 'toroid'
                    sMap.topol.shape = mapShape;

                    mapTopol = sMap.topol; 
                    %**************************

                    %--Map mask--
                    mask = sMap.mask; %default value

                    %--Neighborhood function--
                    neighFunc = 'gaussian'; %'gaussian', 'cutgauss', 'ep' or 'bubble'
                    sMap.neigh = neighFunc;
                    neigh_ = ["gauss","cutg","ep","bub"];

                    %--Tracking--
                    tracking = 1;
                    
                    %--Selecting Initialization Algorithm--
                    switch (l)
                        %'lininit' or 'randinit'
                        case 1, initalg = 'lininit'; 
                        case 2, initalg = 'randinit';
                    end
                    init_ = ["lin","rand"];
                                        
                    %--Selecting Training Algorithm--
                    switch (r)
                        %'seq' or 'batch'
                        case 1, algorithm = 'seq'; sMap.trainhist.algorithm = algorithm;  
                        case 2, algorithm = 'batch'; sMap.trainhist.algorithm = algorithm;
                    end
                    %sMap.trainhist.algorithm = algorithm;

                    %--Number of training epochs--
                    numEpochs = 300;
                    training = [numEpochs numEpochs*5]; 

                    % map struct construction
                    sMap = som_map_struct(dim,mapTopol,neighFunc,'mask',mask,'name',mapName, ...
                                          'comp_names',compNames,'comp_norm',compNorm);

                    fprintf(1,'Initializing map...\n');
                    %*******Initialization*******
                    switch (initalg)
                        case 'randinit', sMap = som_randinit(dataIn,sMap); %Random Initialization
                        case 'lininit', sMap = som_lininit(dataIn, sMap); %Linear Initialization
                    end

                    sMap.trainhist = som_set(sMap.trainhist,'data_name',dataName);
                    fprintf(1,'Map initialized with %s \n',initalg);
                    
                    fprintf(1,'Training map...\n');
                    %*******Training*******
                    fprintf(1,'Rough training phase...\n');
                    %Rough Training (First training step)
                    sTrain = som_train_struct(sMap,'dlen',dlen,'algorithm',algorithm,'phase','rough');
                    sTrain = som_set(sTrain,'data_name',dataName);
                    sTrain.trainlen = training(1); 
                    switch (algorithm)
                        case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
                        case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
                    end

                    %Finetuning Training (Second training step)
                    fprintf(1,'Finetuning phase...\n');
                    sTrain = som_train_struct(sMap,'dlen',dlen,'phase','finetune');
                    sTrain = som_set(sTrain,'data_name',dataName,'algorithm',algorithm);
                    sTrain.trainlen = training(2); 
                    switch (algorithm)
                        case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
                        case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
                    end
                    
                    fprintf(1,'Map trained with %s algorithm \n',algorithm);
                    
                    %****Quality****
                    %Check quality of trained map
                    [mqe,tge] = som_quality(sMap,dataIn);
                    fprintf(1,'Final quantization error: %5.3f\n',mqe)
                    fprintf(1,'Final topographic error:  %5.3f\n',tge)

                    %-----------------------------------------------------
                    %--------------Step 4: Visualize the SOM--------------
                    %-----------------------------------------------------

                    %First we visualize the map only with the training data (just to compare later
                    %when the damage data is inserted.)
                    
                    %figure generation
                    figure(1)
                    som_show(sMap,'umat','all')%Visualize the 1D U-matrix

                    %Save image
                    fig_name = strcat(num2str(cont),'_TrainUmat_ncomp',num2str(ncomp(j)),'_',method(k),...
                        '_',normMeth(optn),'_size',num2str(m),'-',num2str(n),'_',neigh_(1)...
                        ,'_',init_(l),'_',algorithm,'.png');
                    saveas(gcf,fig_name)
                    close
                    
                    fprintf(1,'Starting testing phase\n');
                    %-----------------------------
                    %------Step 5: Testing--------
                    %-----------------------------
                    
                    load ScTQ
                    dataIn2 = ScTQ;

                    typeStruct = 1;
                    if (typeStruct == 1)
                        %In this case the labels are 1:15 Und, 16:34 D1, 35:53 D2
                        %54:72 D3, 73:91 D4, 92:110 D5, 111:129 D6,
                        %130:148 D7, 149:167 D8; 168:186 D9
                        %labels = strings(75,1);
                        labels = strings(120,1);
                        labels(1:20) = "Und";
                        labels(21:40) = "D1";
                        labels(41:60) = "D2";
                        labels(61:80) = "D3";
                        labels(81:100) = "D4";
                        labels(101:120) = "D5";
                        %labels(111:129) = "D6";
                        %labels(130:148) = "D7";
                        %labels(149:167) = "D8";
                        %labels(168:186) = "D9";
                        labels = cellstr(labels);
                        sData2 = som_data_struct(dataIn2,'name','struc states','labels',labels);
                    elseif (typeStruct == 2)
                        sData2 = som_data_struct(dataIn2,'name','struc states');
                    end

                    %Test map model with test data
                    sMap = som_batchtrain(sMap,dataIn2,sTrain);
                    
                    %Show u-matrix
                    %figure generation
                    figure(2)
                    som_show(sMap,'umat','all')

                    %Save image
                    fig_name = strcat(num2str(cont),'U-mat_ncomp',num2str(ncomp(j)),'_',method(k),...
                        '_',normMeth(optn),'_size',num2str(m),'-',num2str(n),'_',neigh_(1)...
                        ,'_',init_(l),'_',algorithm,'.png');
                    saveas(gcf,fig_name)
                    close

                    %Labeling
                    sMap = som_autolabel(sMap,sData2,'freq');

                    if (typeStruct == 1)
                        %The hit histogram for the whole dataset is calculated
                        h1 = som_hits(sMap,sData2.data(1:20,:));
                        h2 = som_hits(sMap,sData2.data(21:40,:));
                        h3 = som_hits(sMap,sData2.data(41:60,:));
                        h4 = som_hits(sMap,sData2.data(61:80,:));
                        h5 = som_hits(sMap,sData2.data(81:100,:));
                        h6 = som_hits(sMap,sData2.data(101:120,:));
                        %h7 = som_hits(sMap,sData2.data(111:129,:));
                        %h8 = som_hits(sMap,sData2.data(130:148,:));
                        %h9 = som_hits(sMap,sData2.data(149:167,:));
                        %h10 = som_hits(sMap,sData2.data(168:186,:));

                        %figure generation
                        figure(3)
                        som_show(sMap,'empty','Histogram')
                        %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
                        %som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
                        %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
                        som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
                        som_show_add('label',sMap,'Textsize',8,'TextColor','k')%labels are added to the map

                        %Save image
                        fig_name = strcat(num2str(cont),'Hist_ncomp',num2str(ncomp(j)),'_',method(k),...
                        '_',normMeth(optn),'_size',num2str(m),'-',num2str(n),'_',neigh_(1)...
                        ,'_',init_(l),'_',algorithm,'.png');
                        saveas(gcf,fig_name)
                        close

                        %figure generation
                        figure(4)
                        colormap(1-gray)
                        som_show(sMap,'umat','all')
                        %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
                        %som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
                        %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
                        som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
                        %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
                        som_show_add('label',sMap,'Textsize',8,'TextColor','k')

                        %Save image
                        fig_name = strcat(num2str(cont),'HitsU-mat_ncomp',num2str(ncomp(j)),'_',method(k),...
                        '_',normMeth(optn),'_size',num2str(m),'-',num2str(n),'_',neigh_(1)...
                        ,'_',init_(l),'_',algorithm,'.png');
                        saveas(gcf,fig_name)
                        close
                    end

                    %**Visualize the surface (3D) U-matrix
                    %figure generation
                    figure(5)
                    Co=som_unit_coords(sMap); U=som_umat(sMap); U=U(1:2:size(U,1),1:2:size(U,2));
                    som_grid(sMap,'Coord',[Co, U(:)],'Surf',U(:),'Marker','none');
                    view(-80,45), axis tight, title('Distance matrix')

                    %Save image
                    fig_name = strcat(num2str(cont),'SurfU-mat_ncomp',num2str(ncomp(j)),'_',method(k),...
                        '_',normMeth(optn),'_size',num2str(m),'-',num2str(n),'_',neigh_(1)...
                        ,'_',init_(l),'_',algorithm,'.fig');
                    saveas(gcf,fig_name)
                    close
                    cont = cont + 1;
                    clear sMap
                end
            end    
        end
        cd ..
    end
    cd ..
end
cd ..
diary off
toc

%% Self organizing map, test code for structure with 9 sensors, 6 damages

close all
clear
clc

%Gathering values
load ScTQr
wkspcData = ScTQr;

%------------------------------
%----Step 1: Construct Data----
%------------------------------

%Generating the labels

%Data struct
sData = som_data_struct(wkspcData,'name','struc states');

%----------------------------------
%----Step 2: Data normalization----
%----------------------------------
optn = 3;
switch(optn)
    case 1
       sData = som_normalize(sData,'var');
    case 2
       sData = som_normalize(sData,'range');
    case 3
       sData = som_normalize(sData,'log');
    case 4
       sData = som_normalize(sData,'logistic');
    case 5
       sData = som_normalize(sData,'histC');
    case 6
       sData = som_normalize(sData,'histD');
end

%----------------------------
%----Step 3: Map training----
%----------------------------

%***Getting info about data***
dataIn = sData.data;
compNames = sData.comp_names;
compNorm = sData.comp_norm;
dataName = sData.name;
[dlen,dim] = size(dataIn);

%--Map struct is created--
sMap = som_map_struct(dim);%Just the struct, there are no data yet.

%*******Input Parameters*******
mapName = 'Map';
sMap.name = mapName;

%**Map Topology**
%--Map size--
m = 15;%17
n = 6; %9
mapSize = [m n]; %[rows columns] %[15 9]
sMap.topol.msize = mapSize;

%--Map Lattice--
mapLatt = 'hexa'; %'hexa' or 'rect'
sMap.topol.lattice = mapLatt;

%--Map shape--
mapShape = 'sheet'; %'sheet', 'cyl' or 'toroid'
sMap.topol.shape = mapShape;

mapTopol = sMap.topol; 
%**************************

%--Map mask--
mask = sMap.mask; %default value

%--Neighborhood function--
neighFunc = 'gaussian'; %'gaussian', 'cutgauss', 'ep' or 'bubble'
sMap.neigh = neighFunc;

%--Tracking--
tracking = 1;

%--Initialization Algorithm--
initalg = 'randinit'; %'lininit' or 'randinit'

%--Training Algorithm--
algorithm = 'seq'; %'seq' or 'batch'
sMap.trainhist.algorithm = algorithm;

%--Number of training epochs--
numEpochs = 300;
training = [numEpochs numEpochs*5]; 

% map struct construction
sMap = som_map_struct(dim,mapTopol,neighFunc,'mask',mask,'name',mapName, ...
                      'comp_names',compNames,'comp_norm',compNorm);

%*******Initialization*******
switch (initalg)
    case 'randinit', sMap = som_randinit(dataIn,sMap); %Random Initialization
    case 'lininit', sMap = som_lininit(dataIn, sMap); %Linear Initialization
end

sMap.trainhist = som_set(sMap.trainhist,'data_name',dataName);

%*******Training*******

%Rough Training (First training step)
sTrain = som_train_struct(sMap,'dlen',dlen,'algorithm',algorithm,'phase','rough');
sTrain = som_set(sTrain,'data_name',dataName);
sTrain.trainlen = training(1); 
switch (algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
end

%Finetuning Training (Second training step)
sTrain = som_train_struct(sMap,'dlen',dlen,'phase','finetune');
sTrain = som_set(sTrain,'data_name',dataName,'algorithm',algorithm);
sTrain.trainlen = training(2); 
switch (algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
end

%****Quality****
%Check quality of map
[mqe,tge] = som_quality(sMap,dataIn);
fprintf(1,'Final quantization error: %5.3f\n',mqe)
fprintf(1,'Final topographic error:  %5.3f\n',tge)

%-----------------------------------------------------
%--------------Step 4: Visualize the SOM--------------
%-----------------------------------------------------

%First we visualize the map only with the training data (just to compare later
%when the damage data is inserted.)
figure
som_show(sMap,'umat','all')%Visualize the 1D U-matrix

%-----------------------------
%------Step 5: Testing--------
%-----------------------------

load ScTQ

dataIn2 = ScTQ;

typeStruct = 1;
if (typeStruct == 1)
    %In this case the labels are 1:18 Und, 19:36 D1, 37:54 D2
    %labels = strings(75,1);
    labels = strings(115,1);
    labels(1:20) = "Und";
    labels(21:40) = "D1";
    labels(41:60) = "D2";
    labels(61:80) = "D3";
    labels(81:100) = "D4";
    labels(101:120) = "D5";
    labels(121:140) = "D6";
    %labels(131:149) = "D7";
    %labels(150:168) = "D8";
    %labels(169:187) = "D9";
    labels = cellstr(labels);
    sData2 = som_data_struct(dataIn2,'name','struc states','labels',labels);
elseif (typeStruct == 2)
    sData2 = som_data_struct(dataIn2,'name','struc states');
end

%Test map model with test data
%sMap = som_batchtrain(sMap,dataIn2,sTrain);
s_algorithm = 'batch';
switch (s_algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn2,sTrain);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn2,sTrain);
end

%Show u-matrix
figure
som_show(sMap,'umat','all')

figure
som_show_mod(sMap,'umat','all')

%Labeling
sMap = som_autolabel(sMap,sData2,'freq');

if (typeStruct == 1)
    %The hit histogram for the whole dataset is calculated
    h1 = som_hits(sMap,sData2.data(1:20,:));
    h2 = som_hits(sMap,sData2.data(21:40,:));
    h3 = som_hits(sMap,sData2.data(41:60,:));
    h4 = som_hits(sMap,sData2.data(61:80,:));
    h5 = som_hits(sMap,sData2.data(81:100,:));
    h6 = som_hits(sMap,sData2.data(101:120,:));
    h7 = som_hits(sMap,sData2.data(121:140,:));
    %h8 = som_hits(sMap,sData2.data(131:149,:));
    %h9 = som_hits(sMap,sData2.data(150:168,:));
    %h10 = som_hits(sMap,sData2.data(169:187,:));
    
    figure
    som_show(sMap,'empty','Histogram')
    %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
    %som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
    %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
    som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
    som_show_add('label',sMap,'Textsize',8,'TextColor','k')%labels are added to the map
    
    figure
    colormap(1-gray)
    som_show(sMap,'umat','all')
    %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
    %som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
    %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
    som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
    som_show_add('label',sMap,'Textsize',8,'TextColor','k')
    
end


%**Visualize the surface (3D) U-matrix
figure
en = 1;
if (en == 1)
Co=som_unit_coords(sMap); U=som_umat(sMap); U=U(1:2:size(U,1),1:2:size(U,2));
som_grid(sMap,'Coord',[Co, U(:)],'Surf',U(:),'Marker','none');
view(-80,45), axis tight, title('Distance matrix')
end

%% Self organizing map, test code for structure with 4 sensors, 3 damages

close all
clear
clc

%Gathering values
load ScTQr
wkspcData = ScTQr;

%------------------------------
%----Step 1: Construct Data----
%------------------------------

%Generating the labels

%Data struct
sData = som_data_struct(wkspcData,'name','struc states');

%----------------------------------
%----Step 2: Data normalization----
%----------------------------------
optn = 3;
switch(optn)
    case 1
       sData = som_normalize(sData,'var');
    case 2
       sData = som_normalize(sData,'range');
    case 3
       sData = som_normalize(sData,'log');
    case 4
       sData = som_normalize(sData,'logistic');
    case 5
       sData = som_normalize(sData,'histC');
    case 6
       sData = som_normalize(sData,'histD');
end

%----------------------------
%----Step 3: Map training----
%----------------------------

%***Getting info about data***
dataIn = sData.data;
compNames = sData.comp_names;
compNorm = sData.comp_norm;
dataName = sData.name;
[dlen,dim] = size(dataIn);

%--Map struct is created--
sMap = som_map_struct(dim);%Just the struct, there are no data yet.

%*******Input Parameters*******
mapName = 'Map';
sMap.name = mapName;

%**Map Topology**
%--Map size--
m = 9;%17
n = 9; %9
mapSize = [m n]; %[rows columns] %[15 9]
sMap.topol.msize = mapSize;

%--Map Lattice--
mapLatt = 'hexa'; %'hexa' or 'rect'
sMap.topol.lattice = mapLatt;

%--Map shape--
mapShape = 'sheet'; %'sheet', 'cyl' or 'toroid'
sMap.topol.shape = mapShape;

mapTopol = sMap.topol; 
%**************************

%--Map mask--
mask = sMap.mask; %default value

%--Neighborhood function--
neighFunc = 'gaussian'; %'gaussian', 'cutgauss', 'ep' or 'bubble'
sMap.neigh = neighFunc;

%--Tracking--
tracking = 1;

%--Initialization Algorithm--
initalg = 'randinit'; %'lininit' or 'randinit'

%--Training Algorithm--
algorithm = 'seq'; %'seq' or 'batch'
sMap.trainhist.algorithm = algorithm;

%--Number of training epochs--
numEpochs = 300;
training = [numEpochs numEpochs*5]; 

% map struct construction
sMap = som_map_struct(dim,mapTopol,neighFunc,'mask',mask,'name',mapName, ...
                      'comp_names',compNames,'comp_norm',compNorm);

%*******Initialization*******
switch (initalg)
    case 'randinit', sMap = som_randinit(dataIn,sMap); %Random Initialization
    case 'lininit', sMap = som_lininit(dataIn, sMap); %Linear Initialization
end

sMap.trainhist = som_set(sMap.trainhist,'data_name',dataName);

%*******Training*******

%Rough Training (First training step)
sTrain = som_train_struct(sMap,'dlen',dlen,'algorithm',algorithm,'phase','rough');
sTrain = som_set(sTrain,'data_name',dataName);
sTrain.trainlen = training(1); 
switch (algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
end

%Finetuning Training (Second training step)
sTrain = som_train_struct(sMap,'dlen',dlen,'phase','finetune');
sTrain = som_set(sTrain,'data_name',dataName,'algorithm',algorithm);
sTrain.trainlen = training(2); 
switch (algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn,sTrain,'tracking',tracking,'mask',mask);
end

%****Quality****
%Check quality of map
[mqe,tge] = som_quality(sMap,dataIn);
fprintf(1,'Final quantization error: %5.3f\n',mqe)
fprintf(1,'Final topographic error:  %5.3f\n',tge)

%-----------------------------------------------------
%--------------Step 4: Visualize the SOM--------------
%-----------------------------------------------------

%First we visualize the map only with the training data (just to compare later
%when the damage data is inserted.)
figure
som_show(sMap,'umat','all')%Visualize the 1D U-matrix

%-----------------------------
%------Step 5: Testing--------
%-----------------------------

load ScTQ %ScTQ;

dataIn2 = ScTQ;%ScTQ;

typeStruct = 1;
if (typeStruct == 1)
    %In this case the labels are 1:18 Und, 19:36 D1, 37:54 D2
    %labels = strings(75,1);
    labels = strings(100,1);
    labels(1:25) = "Und";
    labels(26:50) = "D1";
    labels(51:75) = "D2";
    labels(76:100) = "D3";
    %labels(81:100) = "D4";
    %labels(101:120) = "D5";
    %labels(121:140) = "D6";
    %labels(131:149) = "D7";
    %labels(150:168) = "D8";
    %labels(169:187) = "D9";
    labels = cellstr(labels);
    sData2 = som_data_struct(dataIn2,'name','struc states','labels',labels);
elseif (typeStruct == 2)
    sData2 = som_data_struct(dataIn2,'name','struc states');
end

%Test map model with test data
%sMap = som_batchtrain(sMap,dataIn2,sTrain);
s_algorithm = 'batch';
switch (s_algorithm)
    case 'seq',    sMap = som_seqtrain(sMap,dataIn2,sTrain);
    case 'batch',  sMap = som_batchtrain(sMap,dataIn2,sTrain);
end

%Show u-matrix
figure
som_show(sMap,'umat','all')

figure
som_show_mod(sMap,'umat','all')

%Labeling
sMap = som_autolabel(sMap,sData2,'freq');

if (typeStruct == 1)
    %The hit histogram for the whole dataset is calculated
    h1 = som_hits(sMap,sData2.data(1:25,:));
    h2 = som_hits(sMap,sData2.data(26:50,:));
    h3 = som_hits(sMap,sData2.data(51:75,:));
    h4 = som_hits(sMap,sData2.data(76:100,:));
    %h5 = som_hits(sMap,sData2.data(81:100,:));
    %h6 = som_hits(sMap,sData2.data(101:120,:));
    %h7 = som_hits(sMap,sData2.data(121:140,:));
    %h8 = som_hits(sMap,sData2.data(131:149,:));
    %h9 = som_hits(sMap,sData2.data(150:168,:));
    %h10 = som_hits(sMap,sData2.data(169:187,:));
    
    figure
    som_show(sMap,'empty','Histogram')
    %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
    som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
    %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
    som_show_add('label',sMap,'Textsize',8,'TextColor','k')%labels are added to the map
    
    figure
    colormap(1-gray)
    som_show(sMap,'umat','all')
    %som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1])
    som_show_add('hit',[h1, h2, h3, h4],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0])
    %som_show_add('hit',[h1, h2, h3, h4, h5],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1])
    %som_show_add('hit',[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10],'MarkerColor',[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 0.5 0.5])
    som_show_add('label',sMap,'Textsize',8,'TextColor','k')
    
end


%**Visualize the surface (3D) U-matrix
figure
en = 1;
if (en == 1)
Co=som_unit_coords(sMap); U=som_umat(sMap); U=U(1:2:size(U,1),1:2:size(U,2));
som_grid(sMap,'Coord',[Co, U(:)],'Surf',U(:),'Marker','none');
view(-80,45), axis tight, title('Distance matrix')
end

%%
figure
Co=som_unit_coords(sMap); 
U=som_umat(sMap);
calc_mean = mean(U,'all');%**
%max_val = max(u);
%mean_max = mean(max_val);
mean_min_val = mean(min(U));
umat_size = size(U);
new_u = U;
for cont=1:umat_size(1)
    for cont2=1:umat_size(2)
        if (U(cont,cont2) >= calc_mean)
            new_u(cont,cont2) = calc_mean;
        elseif (U(cont,cont2) < mean_min_val)
            %new_u(cont,cont2) = min(min(u));
            new_u(cont,cont2) = new_u(cont,cont2)*(1/1000);
        end
    end
end
U = new_u;
U=U(1:2:size(U,1),1:2:size(U,2));
som_grid(sMap,'Coord',[Co, U(:)],'Surf',U(:),'Marker','none');
view(-80,45), axis tight, title('Distance matrix')