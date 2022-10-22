%% Read .csv file and organize dataset
tic
clear;
clc;

%Define parameters
numOfPhases = 4;
numOfTest = 60;
numOfDam = 3;
numOfCh = 4;
%testFiles = 8;
%-----------

%Filter Parameters
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
    Train = Train - 120;%Set plot to zero
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
        dataset(k,:) = filter(b,a,dataset(k,:));
    end
    
    switch i
        case 1
            TRAIN1 = dataset;
            filename = strcat('TRAIN1');
            %TRAIN1(1,:) = [];
            %TRAIN1(numOfTest-1,:) = [];
            clear dataset
        case 2
            TRAIN2 = dataset;
            filename = strcat('TRAIN2');
            %TRAIN2(1,:) = [];
            %TRAIN2(numOfTest-1,:) = [];
            clear dataset
        case 3
            TRAIN3 = dataset;
            filename = strcat('TRAIN3');
            %TRAIN3(1,:) = [];
            %TRAIN3(numOfTest-1,:) = [];
            clear dataset
        case 4
            TRAIN4 = dataset;
            filename = strcat('TRAIN4');
            %TRAIN4(1,:) = [];
            %TRAIN4(numOfTest-1,:) = [];
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
for i = 1:numOfPhases
    Train = readtable(strcat('TrainTst',num2str(i),'.csv'));
    Train = table2array(Train);
    Train(:,i) = [];%Delete unused channel
    Train = Train - 120;%Set plot to zero
    dataLen = length(Train);
    if (i < 2)
        cont = 0;
        if (mod(dataLen,numOfTest) ~= 0)
        for j = dataLen:-1:0
            if (mod(j,numOfTest) == 0)
                Train(j+1:dataLen,:) = [];
                dataLenP2 = length(Train);
                dataset = zeros(round(numOfTest),round((dataLenP2/numOfTest)*(numOfCh-1)));
                break
            end
            cont = cont + 1;
        end
        else
            dataLenP2 = dataLen;
            dataset = zeros(numOfTest,(dataLenP2/numOfTest)*(numOfCh-1));
        end
    else
        if (dataLen > dataLenP2)
            Train(dataLenP2:dataLen-1,:) = [];
        elseif (dataLen < dataLenP2)
            buff = Train;
            %buff = buff';
            Train = zeros(dataLenP2,(numOfCh-1));
            Train(1:dataLen,:) = buff;
            Train(length(Train)-length(buff):length(Train)-1) = 0;
            clear buff
        end
    end
    
    Train = Train';
    for k = 1:numOfTest
        dataset(k,1:dataLenP2/numOfTest) = Train(1,1:dataLenP2/numOfTest);
        dataset(k,(dataLenP2/numOfTest)+1:(dataLenP2/numOfTest)*2) = Train(2,1:dataLenP2/numOfTest);
        dataset(k,(dataLenP2/numOfTest)*2+1:(dataLenP2/numOfTest)*3) = Train(3,1:dataLenP2/numOfTest);
        Train(:,1:dataLenP2/numOfTest) = [];
        dataset(k,:) = filter(b,a,dataset(k,:));
    end
    
    switch i
        case 1
            TrainTst1 = dataset;
            filename = strcat('TrainTst1');
            %TrainTst1(1,:) = [];
            %TrainTst1(numOfTest-1,:) = [];
            clear dataset
        case 2
            TrainTst2 = dataset;
            filename = strcat('TrainTst2');
            %TrainTst2(1,:) = [];
            %TrainTst2(numOfTest-1,:) = [];
            clear dataset
        case 3
            TrainTst3 = dataset;
            filename = strcat('TrainTst3');
            %TrainTst3(1,:) = [];
            %TrainTst3(numOfTest-1,:) = [];
            clear dataset
        case 4
            TrainTst4 = dataset;
            filename = strcat('TrainTst4');
            %TrainTst4(1,:) = [];
            %TrainTst4(numOfTest-1,:) = [];
            clear dataset
        otherwise
            error('No data :(');
    end
    
    save(strcat(filename,'.mat'),filename)
    clear Train
end

%====================================
% Quit extra data from TrainTst files
%====================================
if (length(TRAIN1) < length(TrainTst1)) %The specific file doesn't matter
    TrainTst1(:,length(TRAIN1)+1:length(TrainTst1)) = [];
    TrainTst2(:,length(TRAIN2)+1:length(TrainTst2)) = [];
    TrainTst3(:,length(TRAIN3)+1:length(TrainTst3)) = [];
    TrainTst4(:,length(TRAIN4)+1:length(TrainTst4)) = [];
else
    buff2 = TrainTst1;
    TrainTst1 = zeros(numOfTest,length(TRAIN1));
    TrainTst1(:,1:length(TRAIN1)) = buff2;
    TrainTst1(length(TrainTst1)-length(buff2):length(TrainTst1)-1) = 0;
    clear buff2
    buff2 = TrainTst2;
    TrainTst2 = zeros(numOfTest,length(TRAIN2));
    TrainTst2(:,1:length(TRAIN2)) = buff2;
    TrainTst2(length(TrainTst2)-length(buff2):length(TrainTst2)-1) = 0;
    clear buff2
    buff2 = TrainTst3;
    TrainTst3 = zeros(numOfTest,length(TRAIN3));
    TrainTst3(:,1:length(TRAIN3)) = buff2;
    TrainTst3(length(TrainTst3)-length(buff2):length(TrainTst3)-1) = 0;
    clear buff2
    buff2 = TrainTst4;
    TrainTst4 = zeros(numOfTest,length(TRAIN4));
    TrainTst4(:,1:length(TRAIN4)) = buff2;
    TrainTst4(length(TrainTst4)-length(buff2):length(TrainTst4)-1) = 0;
    clear buff2
end

%===========================
% Creation of TEST datasets
%===========================
for i = 1:numOfPhases
    count = 0;
    for j = 1:numOfDam
        Test = readtable(strcat('TEST',num2str(i),'D',num2str(j),'.csv'));
        Test = table2array(Test);
        Test(:,i) = [];%Delete unused channel
        Test = Test - 120;%Set plot to zero
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