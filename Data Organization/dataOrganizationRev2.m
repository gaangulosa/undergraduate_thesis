%% Read .csv file and organize dataset
tic
clear;
clc;

%Define parameters
numOfPhases = 4;
numOfTest = 100;
numOfDam = 5;
numOfCh = 4;
percOfTrainVal = 20/100;% percent(%)
%testFiles = 8;
%-----------

%Filter Parameters
% Improve filter implementation
windowSize = 10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
%------------

%===========================
% Creation of TRAIN datasets
%===========================
for i = 1:numOfPhases
    Train = readtable(strcat('TRAIN',num2str(i),'.csv'));
    Train = table2array(Train);
    Train(:,i) = [];%Delete unused channel
    Train = Train - mean(Train);%Set plot to zero
    dataLen = length(Train);
    if (i < 2)
        cont = 0;
        if (mod(dataLen,numOfTest) ~= 0)
        for j = dataLen:-1:0
            if (mod(j,numOfTest) == 0)
                Train(j+1:dataLen,:) = [];
                dataLenP = length(Train);
                dataset = zeros(round(numOfTest),round((dataLenP/numOfTest)*(numOfCh-1)));
                break
            end
            cont = cont + 1;
        end
        else
            dataLenP = dataLen;
            dataset = zeros(numOfTest,(dataLenP/numOfTest)*(numOfCh-1));
        end
    else
        if (dataLen > dataLenP)
            Train(dataLenP:dataLen-1,:) = [];
        elseif (dataLen < dataLenP)
            buff = Train;
            %buff = buff';
            Train = zeros(dataLenP,(numOfCh-1));
            Train(1:dataLen,:) = buff;
            Train(length(Train)-length(buff):length(Train)-1) = 0;%100;
            clear buff
        end
    end
    
    Train = Train';
    for k = 1:numOfTest
        dataset(k,1:dataLenP/numOfTest) = Train(1,1:dataLenP/numOfTest);
        dataset(k,(dataLenP/numOfTest)+1:(dataLenP/numOfTest)*2) = Train(2,1:dataLenP/numOfTest);
        dataset(k,(dataLenP/numOfTest)*2+1:(dataLenP/numOfTest)*3) = Train(3,1:dataLenP/numOfTest);
        Train(:,1:dataLenP/numOfTest) = [];
        %dataset(k,:) = filter(b,a,dataset(k,:));
    end
    
    switch i
        case 1
            TRAIN1 = dataset;
            filename = strcat('TRAIN1');
            clear dataset
        case 2
            TRAIN2 = dataset;
            filename = strcat('TRAIN2');
            clear dataset
        case 3
            TRAIN3 = dataset;
            filename = strcat('TRAIN3');
            clear dataset
        case 4
            TRAIN4 = dataset;
            filename = strcat('TRAIN4');
            clear dataset
        otherwise
            error('No data :(');
    end
    
    save(strcat(filename,'.mat'),filename)
    clear Train
end

%=================================
% TRAIN data for validation
%=================================
%TrainTst1
n_rows = size(TRAIN1);

TrainTst1 = TRAIN1(n_rows(1)-round(n_rows(1)*percOfTrainVal)+1:n_rows(1),:);
TrainTst2 = TRAIN2(n_rows(1)-round(n_rows(1)*percOfTrainVal)+1:n_rows(1),:);
TrainTst3 = TRAIN3(n_rows(1)-round(n_rows(1)*percOfTrainVal)+1:n_rows(1),:);
TrainTst4 = TRAIN4(n_rows(1)-round(n_rows(1)*percOfTrainVal)+1:n_rows(1),:);
%%
%===========================
% Creation of TEST datasets
%===========================
for i = 1:numOfPhases
    count = 0;
    for j = 1:numOfDam
        Test = readtable(strcat('TEST',num2str(i),'D',num2str(j),'.csv'));
        Test = table2array(Test);
        Test(:,i) = [];%Delete unused channel
        Test = Test - mean(Test);%Set plot to zero
        dataLen = length(Test);
        
        if (dataLen > dataLenP)
            Test(dataLenP:dataLen-1,:) = [];
        elseif (dataLen < dataLenP)
            buff = Test;
            Test = zeros(dataLenP,(numOfCh-1));
            Test(1:dataLen,:) = buff;
            clear buff
        end
        if (j<2)
            dataset2 = zeros(numOfDam*numOfTest,(dataLenP/numOfTest)*(numOfCh-1));
        end
        
        Test = Test';      
        if (j<2)
            for k = 1:numOfTest
                dataset2(k,1:dataLenP/numOfTest) = Test(1,1:dataLenP/numOfTest);
                dataset2(k,(dataLenP/numOfTest)+1:(dataLenP/numOfTest)*2) = Test(2,1:dataLenP/numOfTest);
                dataset2(k,(dataLenP/numOfTest)*2+1:(dataLenP/numOfTest)*3) = Test(3,1:dataLenP/numOfTest);
                Test(:,1:dataLenP/numOfTest) = [];
                dataset2(k,:) = filter(b,a,dataset2(k,:));
            end
        else
            for k = numOfTest*(j-1)+1:numOfTest*j
                dataset2(k,1:dataLenP/numOfTest) = Test(1,1:dataLenP/numOfTest);
                dataset2(k,(dataLenP/numOfTest)+1:(dataLenP/numOfTest)*2) = Test(2,1:dataLenP/numOfTest);
                dataset2(k,(dataLenP/numOfTest)*2+1:(dataLenP/numOfTest)*3) = Test(3,1:dataLenP/numOfTest);
                Test(:,1:dataLenP/numOfTest) = [];
                dataset2(k,:) = filter(b,a,dataset2(k,:));
            end
        end     
    end
    
    switch i
        case 1
            TEST1 = [TrainTst1;dataset2];
            filename = strcat('TEST1');
            clear dataset2
        case 2
            TEST2 = [TrainTst2;dataset2];
            filename = strcat('TEST2');
            clear dataset2
        case 3
            TEST3 = [TrainTst3;dataset2];
            filename = strcat('TEST3');
            clear dataset2
        case 4
            TEST4 = [TrainTst4;dataset2];
            filename = strcat('TEST4');
            clear dataset2
        otherwise
            error('No data :(');
    end
    
    save(strcat(filename,'.mat'),filename)
    clear Test
end
toc