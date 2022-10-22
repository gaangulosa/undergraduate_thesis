%%
%==========================================================================
%                       Preprocessing Algorithm
%==========================================================================

%Version 1.0.0 beta

%This program was modified from the original to allow make iterations and
%thus provide data  from multiple options of data preprocessing.
%Some other modifications were
% -Not plot the Scores and T vs Q (Because the most important is the classification).  
% -The numbers of components to be used are now in a array, the same for
% the normalization methods.

%This program provide three useful arrays for damage clasification
% - Scores
% - T index
% - Q index

%=========================
%------Data Loading-------
%=========================

%Train correspond to data without damages
%Tests corresponf to data with damages (6 in total for this case)

clear
clc
close all
load TRAIN1
load TEST1
load TRAIN2
load TEST2
load TRAIN3
load TEST3
load TRAIN4
load TEST4

% %===some extra====
% TRAIN1(:,1:3) = [];
% TRAIN2(:,1:3) = [];
% TRAIN3(:,1:3) = [];
% TRAIN4(:,1:3) = [];
% TEST1(:,1:3) = [];
% TEST2(:,1:3) = [];
% TEST3(:,1:3) = [];
% TEST4(:,1:3) = [];
% %=================

o= [8];  %Set the number of components

ncomp=o;

for d=1:length(ncomp)
    if (ncomp(d) < 2)
        error('The number of components must be greater than 1!');
    end
end

dirFiles = 'Files_compl';
if not(isfolder(dirFiles))%Check if the directory already exists
    mkdir(dirFiles)
	cd(dirFiles)
else
    cd(dirFiles)
end

for j=1:length(ncomp)
    dirName1 = strcat('prep_ncomp-',num2str(ncomp(j)));
    if not(isfolder(dirName1))%Check if the directory already exists
        mkdir(dirName1)
        cd(dirName1)
    else
        cd(dirName1)
    end
    %Normalization methods
    method = ["auto","grps","relat1","relat4","range1","range2","snvt"];%
    
    for k=1:length(method)
        close all
        dirName2 = strcat('norm_meth_',method(k));
        if not(isfolder(dirName2))%Check if the directory already exists
            mkdir(dirName2)
            cd(dirName2)
        else
            cd(dirName2)
        end 
        
        %==========================
        %------Preprocessing-------          
        %==========================
        [train1,test1]=preprocessing(TRAIN1,TEST1,method(k),ncomp(j));
        [train2,test2]=preprocessing(TRAIN2,TEST2,method(k),ncomp(j));
        [train3,test3]=preprocessing(TRAIN3,TEST3,method(k),ncomp(j));
        [train4,test4]=preprocessing(TRAIN4,TEST4,method(k),ncomp(j));
        %==================================================================
        
        %figure;

        %================================
        %--Principal Component Analysis--
        %================================
        [load_model1, scores_model1,latent_model1,T_model1] = pca(train1,'NumComponents',ncomp(j));
        [load_model2, scores_model2,latent_model2,T_model2] = pca(train2,'NumComponents',ncomp(j));
        [load_model3, scores_model3,latent_model3,T_model3] = pca(train3,'NumComponents',ncomp(j));
        [load_model4, scores_model4,latent_model4,T_model4] = pca(train4,'NumComponents',ncomp(j));
        %======================================================================================
        
        %ponderación del porcentaje de varianza (latent) para mirar la variabilidad
        [m,n] = size(latent_model1);
        K1=sum(latent_model1);
        K2=sum(latent_model2);
        K3=sum(latent_model3);
        K4=sum(latent_model4);
        %---------- prealocating ----------
        per_comp1 = zeros(m,1);
        per_comp2 = zeros(m,1);
        per_comp3 = zeros(m,1);
        per_comp4 = zeros(m,1);
        %----------------------------------
        for i=1:m
            per_comp1(i,1)=(100*(latent_model1(i,1)))/K1;
            per_comp2(i,1)=(100*(latent_model2(i,1)))/K2;
            per_comp3(i,1)=(100*(latent_model3(i,1)))/K3;
            per_comp4(i,1)=(100*(latent_model4(i,1)))/K4;
        end
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp1);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the first PZT ')
        %fig_name = 'per_comp_first_pzt.png'; %strcat('per_comp',num2str(k),'.png');
        %saveas(gcf,fig_name) 
        print('per_comp_first_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp2);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the second PZT ')
        %fig_name = 'per_comp_second_pzt.png';%strcat('per_comp',num2str(k+1),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_second_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp3);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the third PZT ')
        %fig_name = 'per_comp_third_pzt.png';%strcat('per_comp',num2str(k+2),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_thidr_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp4);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the fourth PZT ')
        %fig_name = 'per_comp_fourth_pzt.png';%strcat('per_comp',num2str(k+3),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_fourth_pzt','-dpdf','-bestfit')
        close
        
        %==========================================
        %---Calculation of Scores, T and Q index---
        %==========================================
        
        %Features of Undamage structure
        [scoresTr1,Tr1,Qr1]=tqs1(train1,load_model1(:,1:ncomp(j)),latent_model1(1:ncomp(j)));
        clear train1
        [scoresTr2,Tr2,Qr2]=tqs1(train2,load_model2(:,1:ncomp(j)),latent_model2(1:ncomp(j)));
        clear train2
        [scoresTr3,Tr3,Qr3]=tqs1(train3,load_model3(:,1:ncomp(j)),latent_model3(1:ncomp(j)));
        clear train3
        [scoresTr4,Tr4,Qr4]=tqs1(train4,load_model4(:,1:ncomp(j)),latent_model4(1:ncomp(j)));
        clear train4
        
        %Projection over Undamage features
        [scores1,T1,Q1]=tqs1(test1,load_model1(:,1:ncomp(j)),latent_model1(1:ncomp(j)));
        clear test1
        clear load_model1
        clear latent_model1
        [scores2,T2,Q2]=tqs1(test2,load_model2(:,1:ncomp(j)),latent_model2(1:ncomp(j)));
        clear test2
        clear load_model2
        clear latent_model2
        [scores3,T3,Q3]=tqs1(test3,load_model3(:,1:ncomp(j)),latent_model3(1:ncomp(j)));
        clear test3
        clear load_model3
        clear latent_model3
        [scores4,T4,Q4]=tqs1(test4,load_model4(:,1:ncomp(j)),latent_model4(1:ncomp(j)));
        clear test4
        clear load_model4
        clear latent_model4
        
        %-----Scores graph-----
        figure
        plot (scores1(1:20,1),scores1(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores1(21:40,1),scores1(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores1(41:60,1),scores1(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores1(61:80,1),scores1(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores1(81:100,1),scores1(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (scores1(101:120,1),scores1(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title('ACTUATOR 1')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator1.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator1','-dpdf','-bestfit')
        close
        
        figure
        plot (scores2(1:20,1),scores2(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores2(21:40,1),scores2(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores2(41:60,1),scores2(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores2(61:80,1),scores2(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores2(81:100,1),scores2(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (scores2(101:120,1),scores2(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title('ACTUATOR 2')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator2.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator2','-dpdf','-bestfit')
        close
        
        figure
        plot (scores3(1:20,1),scores3(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores3(21:40,1),scores3(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores3(41:60,1),scores3(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores3(61:80,1),scores3(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores3(81:100,1),scores3(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (scores3(101:120,1),scores3(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title('ACTUATOR 3')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator3.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator3','-dpdf','-bestfit')
        close
        
        figure
        plot (scores4(1:20,1),scores4(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores4(21:40,1),scores4(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (scores4(41:60,1),scores4(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (scores4(61:80,1),scores4(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
        hold on
        plot (scores4(81:100,1),scores4(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (scores4(101:120,1),scores4(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title('ACTUATOR 4')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator4.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator4','-dpdf','-bestfit')
        close

        %-----T vs Q graphs-----
        figure
        plot (T1(1:20),Q1(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T1(21:40),Q1(21:40),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T1(41:60),Q1(41:60),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T1(61:80),Q1(61:80),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
        hold on
        plot (T1(81:100),Q1(81:100),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (T1(101:120),Q1(101:120),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title ('ACTUATOR 1')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator1.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator1','-dpdf','-bestfit')
        close
        
        figure
        plot (T2(1:20),Q2(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T2(21:40),Q2(21:40),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T2(41:60),Q2(41:60),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T2(61:80),Q2(61:80),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
        hold on
        plot (T2(81:100),Q2(81:100),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (T2(101:120),Q2(101:120),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title ('ACTUATOR 2')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator2.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator2','-dpdf','-bestfit')
        close
        
        figure
        plot (T3(1:20),Q3(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T3(21:40),Q3(21:40),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T3(41:60),Q3(41:60),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T3(61:80),Q3(61:80),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
        hold on
        plot (T3(81:100),Q3(81:100),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (T3(101:120),Q3(101:120),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title ('ACTUATOR 3')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator3.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator3','-dpdf','-bestfit')
        close
        
        figure
        plot (T4(1:20),Q4(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T4(21:40),Q4(21:40),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T4(41:60),Q4(41:60),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T4(61:80),Q4(61:80),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
        hold on
        plot (T4(81:100),Q4(81:100),'gh','MarkerFaceColor',[.1 .2 .6]) %Damage 4
        hold on
        plot (T4(101:120),Q4(101:120),'ys','MarkerFaceColor',[.5 .1 .4]) %Damage 5
        title ('ACTUATOR 4')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Und','D1','D2','D3','D4','D5','Location','Best')
        %legend('Und','D1','D2','D3','D4','Location','Best')
        %legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator4.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator4','-dpdf','-bestfit')
        close
        
        %========================
        %---------Storage--------
        %========================
        
        %Store the Scores, the T and Q index in .mat files independently
        for i=1:4
            filename = strcat('scores',num2str(i));
            save(strcat(filename,'.mat'),filename)
            filename = strcat('scoresTr',num2str(i));
            save(strcat(filename,'.mat'),filename)
        end
        
        %Fuses the Scores, the T and Q index in one file for each case
        %Features without damages
        ScTQr = [scoresTr1 Tr1 Qr1 scoresTr2 Tr2 Qr2 scoresTr3 Tr3 Qr3 scoresTr4 Tr4 Qr4];
        filename2 = 'ScTQr';
        save(strcat(filename2,'.mat'),filename2)
        %Features with damage.
        ScTQ = [scores1 T1 Q1 scores2 T2 Q2 scores3 T3 Q3 scores4 T4 Q4];
        filename2 = 'ScTQ';
        save(strcat(filename2,'.mat'),filename2)
        
        %Fuses the Scores and the Q index in one file for each case
        %Features without damages
        ScQr = [scoresTr1 Qr1 scoresTr2 Qr2 scoresTr3 Qr3 scoresTr4 Qr4];
        filename2 = 'ScQr';
        save(strcat(filename2,'.mat'),filename2)
        %Features with damages
        ScQ = [scores1 Q1 scores2 Q2 scores3 Q3 scores4 Q4];
        filename2 = 'ScQ';
        save(strcat(filename2,'.mat'),filename2)
        
        cd ..
    end
    cd ..
end

cd ..
%% Simplified preprocessing algorithm 

%**This algorthm works with the unified dataset (just one TRAIN and TEST file)**

%==========================================================================
%                       Preprocessing Algorithm
%==========================================================================

%Version 1.0.0 beta

%This program was modified from the original to allow make iterations and
%thus provide data  from multiple options of data preprocessing.
%Some other modifications were
% -Not plot the Scores and T vs Q (Because the most important is the classification).  
% -The numbers of components to be used are now in a array, the same for
% the normalization methods.

%This program provide three useful arrays for damage clasification
% - Scores
% - T index
% - Q index

clear
clc

%=========================
%------Data Loading-------
%=========================

load TEST
load TRAIN

o=[2,4,6,8];  %Set the number of components

ncomp=o;

for d=1:length(ncomp)
    if (ncomp(d) < 2)
        error('The number of components must be greater than 1!');
    end
end

dirFiles = 'Figures';
if not(isfolder(dirFiles))%Check if the directory already exists
    mkdir(dirFiles)
	cd(dirFiles)
else
    cd(dirFiles)
end

for j=1:length(ncomp)
    dirName1 = strcat('prep_ncomp-',num2str(ncomp(j)));
    if not(isfolder(dirName1))%Check if the directory already exists
        mkdir(dirName1)
        cd(dirName1)
    else
        cd(dirName1)
    end
    %Normalization methods
    method = ["auto","grps","relat1","relat4","range1","range2","snvt"];
    
    for k=1:length(method)
        close all
        dirName2 = strcat('norm_meth_',method(k));
        if not(isfolder(dirName2))%Check if the directory already exists
            mkdir(dirName2)
            cd(dirName2)
        else
            cd(dirName2)
        end 
        
        %==========================
        %------Preprocessing-------          
        %==========================
        [train,test]=preprocessing(TRAIN,TEST,method(k),ncomp(j));
        %==================================================================
        
        %figure;

        %================================
        %--Principal Component Analysis--
        %================================
        [load_model, scores_model,latent_model,T_model] = pca(train,'NumComponents',ncomp(j));
        %======================================================================================
        
        %ponderación del porcentaje de varianza (latent) para mirar la variabilidad
        [m,n] = size(latent_model);
        K1=sum(latent_model);
        %---------- prealocating ----------
        per_comp1 = zeros(m,1);
        %----------------------------------
        for i=1:m
            per_comp1(i,1)=(100*(latent_model(i,1)))/K1;
        end
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp1);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the first PZT ')
        fig_name = strcat('per_comp',num2str(k),'.png');
        saveas(gcf,fig_name) 
        close
        
        %==========================================
        %---Calculation of Scores, T and Q index---
        %==========================================
        [scores,T,Q]=tqs1(test,load_model(:,1:ncomp(j)),latent_model(1:ncomp(j)));
        clear train
        clear test
        clear load_model
        clear latent_model
        
        %========================
        %--------Storage---------
        %========================
        
        %Store the Scores, the T and Q index in .mat files independently
        filename = strcat('scores');
        save(strcat(filename,'.mat'),filename)
        
        %Fuses the Scores, the T and Q index in one file for each case
        ScTQ = [scores T Q];
        filename2 = 'ScTQ';
        save(strcat(filename2,'.mat'),filename2)
        
        %Fuses the Scores and the Q index in one file for each case
        ScQ = [scores Q];
        filename2 = 'ScQ';
        save(strcat(filename2,'.mat'),filename2)
        
        cd ..
    end
    cd ..
end

cd ..
%%
clear
clc
close all
load TRAIN1
load TEST1
load TRAIN2
load TEST2
load TRAIN3
load TEST3
load TRAIN4
load TEST4

% %===some extra====
% TRAIN1(:,1:3) = [];
% TRAIN2(:,1:3) = [];
% TRAIN3(:,1:3) = [];
% TRAIN4(:,1:3) = [];
% TEST1(:,1:3) = [];
% TEST2(:,1:3) = [];
% TEST3(:,1:3) = [];
% TEST4(:,1:3) = [];
% %=================

o= [2,4,6,8];  %Set the number of components

ncomp=o;

for d=1:length(ncomp)
    if (ncomp(d) < 2)
        error('The number of components must be greater than 1!');
    end
end

dirFiles = 'Files_compl';
if not(isfolder(dirFiles))%Check if the directory already exists
    mkdir(dirFiles)
	cd(dirFiles)
else
    cd(dirFiles)
end

for j=1:length(ncomp)
    dirName1 = strcat('prep_ncomp-',num2str(ncomp(j)));
    if not(isfolder(dirName1))%Check if the directory already exists
        mkdir(dirName1)
        cd(dirName1)
    else
        cd(dirName1)
    end
    %Normalization methods
    method = ["auto"]%,"grps","relat1","relat4","range1","range2","snvt"];%
    
    for k=1:length(method)
        close all
        dirName2 = strcat('norm_meth_',method(k));
        if not(isfolder(dirName2))%Check if the directory already exists
            mkdir(dirName2)
            cd(dirName2)
        else
            cd(dirName2)
        end 
        
        %==========================
        %------Preprocessing-------          
        %==========================
        [train1,test1]=preprocessing(TRAIN1,TEST1,method(k),ncomp(j));
        [train2,test2]=preprocessing(TRAIN2,TEST2,method(k),ncomp(j));
        [train3,test3]=preprocessing(TRAIN3,TEST3,method(k),ncomp(j));
        [train4,test4]=preprocessing(TRAIN4,TEST4,method(k),ncomp(j));
        %==================================================================
        
        %figure;

        %================================
        %--Principal Component Analysis--
        %================================
        [load_model1, scores_model1,latent_model1,T_model1] = pca(train1,'NumComponents',ncomp(j));
        [load_model2, scores_model2,latent_model2,T_model2] = pca(train2,'NumComponents',ncomp(j));
        [load_model3, scores_model3,latent_model3,T_model3] = pca(train3,'NumComponents',ncomp(j));
        [load_model4, scores_model4,latent_model4,T_model4] = pca(train4,'NumComponents',ncomp(j));
        %======================================================================================
        
        %ponderación del porcentaje de varianza (latent) para mirar la variabilidad
        [m,n] = size(latent_model1);
        K1=sum(latent_model1);
        K2=sum(latent_model2);
        K3=sum(latent_model3);
        K4=sum(latent_model4);
        %---------- prealocating ----------
        per_comp1 = zeros(m,1);
        per_comp2 = zeros(m,1);
        per_comp3 = zeros(m,1);
        per_comp4 = zeros(m,1);
        %----------------------------------
        for i=1:m
            per_comp1(i,1)=(100*(latent_model1(i,1)))/K1;
            per_comp2(i,1)=(100*(latent_model2(i,1)))/K2;
            per_comp3(i,1)=(100*(latent_model3(i,1)))/K3;
            per_comp4(i,1)=(100*(latent_model4(i,1)))/K4;
        end
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp1);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the first PZT ')
        %fig_name = 'per_comp_first_pzt.png'; %strcat('per_comp',num2str(k),'.png');
        %saveas(gcf,fig_name) 
        print('per_comp_first_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp2);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the second PZT ')
        %fig_name = 'per_comp_second_pzt.png';%strcat('per_comp',num2str(k+1),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_second_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp3);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the third PZT ')
        %fig_name = 'per_comp_third_pzt.png';%strcat('per_comp',num2str(k+2),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_thidr_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp4);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the fourth PZT ')
        %fig_name = 'per_comp_fourth_pzt.png';%strcat('per_comp',num2str(k+3),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_fourth_pzt','-dpdf','-bestfit')
        close
        
        %==========================================
        %---Calculation of Scores, T and Q index---
        %==========================================
        %Features of Undamage structure
        [scoresTr1,Tr1,Qr1]=tqs1(train1,load_model1(:,1:ncomp(j)),latent_model1(1:ncomp(j)));
        clear train1
        [scoresTr2,Tr2,Qr2]=tqs1(train2,load_model2(:,1:ncomp(j)),latent_model2(1:ncomp(j)));
        clear train2
        [scoresTr3,Tr3,Qr3]=tqs1(train3,load_model3(:,1:ncomp(j)),latent_model3(1:ncomp(j)));
        clear train3
        [scoresTr4,Tr4,Qr4]=tqs1(train4,load_model4(:,1:ncomp(j)),latent_model4(1:ncomp(j)));
        clear train4
        
        %Projection over Undamage features
        [scores1,T1,Q1]=tqs1(test1,load_model1(:,1:ncomp(j)),latent_model1(1:ncomp(j)));
        clear test1
        clear load_model1
        clear latent_model1
        [scores2,T2,Q2]=tqs1(test2,load_model2(:,1:ncomp(j)),latent_model2(1:ncomp(j)));
        clear test2
        clear load_model2
        clear latent_model2
        [scores3,T3,Q3]=tqs1(test3,load_model3(:,1:ncomp(j)),latent_model3(1:ncomp(j)));
        clear test3
        clear load_model3
        clear latent_model3
        [scores4,T4,Q4]=tqs1(test4,load_model4(:,1:ncomp(j)),latent_model4(1:ncomp(j)));
        clear test4
        clear load_model4
        clear latent_model4
        
        %-----T vs Q graphs-----
        figure
        plot (T1(1:25),Q1(1:25),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T1(26:50),Q1(26:50),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T1(51:75),Q1(51:75),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T1(76:100),Q1(76:100),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
%         hold on
%         plot (T1(76:95),Q1(76:95),'k*') %Damage 4
        title ('ACTUATOR 1')
        xlabel('T')
        ylabel('Q')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator1.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator1','-dpdf','-bestfit')
        close
        
        figure
        plot (T2(1:25),Q2(1:25),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T2(26:50),Q2(26:50),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T2(51:75),Q2(51:75),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T2(76:100),Q2(76:100),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
%         hold on
%         plot (T2(76:95),Q2(76:95),'k*') %Damage 4
        title ('ACTUATOR 2')
        xlabel('T')
        ylabel('Q')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator2.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator2','-dpdf','-bestfit')
        close
        
        figure
        plot (T3(1:25),Q3(1:25),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T3(26:50),Q3(26:50),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T3(51:75),Q3(51:75),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T3(76:100),Q3(76:100),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
%         hold on
%         plot (T3(76:95),Q3(76:95),'k*') %Damage 4
        title ('ACTUATOR 3')
        xlabel('T')
        ylabel('Q')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator3.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator3','-dpdf','-bestfit')
        close
        
        figure
        plot (T4(1:25),Q4(1:25),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (T4(26:50),Q4(26:50),'bs','MarkerFaceColor',[.2 .6 .6]) %Damage 1
        hold on
        plot (T4(51:75),Q4(51:75),'kd','MarkerFaceColor',[.8 .6 .6]) %Damage 2
        hold on
        plot (T4(76:100),Q4(76:100),'mp','MarkerFaceColor',[.1 .2 .6]) %Damage 3
%         hold on
%         plot (T4(76:95),Q4(76:95),'k*') %Damage 4
        title ('ACTUATOR 4')
        xlabel('T')
        ylabel('Q')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Un','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'TvsQ_actuator4.png';
        %saveas(gcf,fig_name)
        print('TvsQ_actuator4','-dpdf','-bestfit')
        close
        
        %-----Scores graph-----
        figure
        plot (scores1(1:25,1),scores1(1:25,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores1(26:50,1),scores1(26:50,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores1(51:75,1),scores1(51:75,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores1(76:100,1),scores1(76:100,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
%         hold on
%         plot (scores1(76:95,1),scores1(76:95,2),'g^') %D4
        title('ACTUATOR 1')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator1.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator1','-dpdf','-bestfit')
        close
        
        figure
        plot (scores2(1:25,1),scores2(1:25,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores2(26:50,1),scores2(26:50,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores2(51:75,1),scores2(51:75,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores2(76:100,1),scores2(76:100,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
%         hold on
%         plot (scores2(76:95,1),scores2(76:95,2),'g^') %D4
        title('ACTUATOR 2')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator2.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator2','-dpdf','-bestfit')
        close
        
        figure
        plot (scores3(1:25,1),scores3(1:25,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores3(26:50,1),scores3(26:50,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores3(51:75,1),scores3(51:75,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores3(76:100,1),scores3(76:100,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
%         hold on
%         plot (scores3(76:95,1),scores3(76:95,2),'g^') %D4
        title('ACTUATOR 3')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator3.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator3','-dpdf','-bestfit')
        close
        
        figure
        plot (scores4(1:25,1),scores4(1:25,2),'ro','MarkerFaceColor',[1 .6 .6]) %Undamaged
        hold on
        plot (scores4(26:50,1),scores4(26:50,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores4(51:75,1),scores4(51:75,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores4(76:100,1),scores4(76:100,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
%         hold on
%         plot (scores4(76:95,1),scores4(76:95,2),'g^') %D4
        title('ACTUATOR 4')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        %legend('Und','D1','D2','D3','D4','Location','Best')
        legend('Und','D1','D2','D3','Location','Best')
        %legend('Und','D1','D2','Location','Best')
        %fig_name = 'Scores_actuator4.png';
        %saveas(gcf,fig_name)
        print('Scores_actuator4','-dpdf','-bestfit')
        close
        
        %========================
        %---------Storage--------
        %========================
        
        %Store the Scores, the T and Q index in .mat files independently
        for i=1:4
            filename = strcat('scores',num2str(i));
            save(strcat(filename,'.mat'),filename)
            filename = strcat('scoresTr',num2str(i));
            save(strcat(filename,'.mat'),filename)
        end
        
        %Fuses the Scores, the T and Q index in one file for each case
        %Features without damages
        ScTQr = [scoresTr1 Tr1 Qr1 scoresTr2 Tr2 Qr2 scoresTr3 Tr3 Qr3 scoresTr4 Tr4 Qr4];
        filename2 = 'ScTQr';
        save(strcat(filename2,'.mat'),filename2)
        %Features with damage.
        ScTQ = [scores1 T1 Q1 scores2 T2 Q2 scores3 T3 Q3 scores4 T4 Q4];
        filename2 = 'ScTQ';
        save(strcat(filename2,'.mat'),filename2)
        
        %Fuses the Scores and the Q index in one file for each case
        %Features without damages
        ScQr = [scoresTr1 Qr1 scoresTr2 Qr2 scoresTr3 Qr3 scoresTr4 Qr4];
        filename2 = 'ScQr';
        save(strcat(filename2,'.mat'),filename2)
        %Features with damages
        ScQ = [scores1 Q1 scores2 Q2 scores3 Q3 scores4 Q4];
        filename2 = 'ScQ';
        save(strcat(filename2,'.mat'),filename2)
        
        cd ..
    end
    cd ..
end

cd ..

%% CFRP PLATE
clear
clc
close all
load TRAIN1
load TEST1
load TRAIN2
load TEST2
load TRAIN3
load TEST3
load TRAIN4
load TEST4
load TRAIN5
load TEST5
load TRAIN6
load TEST6
load TRAIN7
load TEST7
load TRAIN8
load TEST8
load TRAIN9
load TEST9


o=[2,4,6,8];  %Set the number of components

ncomp=o;

for d=1:length(ncomp)
    if (ncomp(d) < 2)
        error('The number of components must be greater than 1!');
    end
end

dirFiles = 'Files_compl';
if not(isfolder(dirFiles))%Check if the directory already exists
    mkdir(dirFiles)
	cd(dirFiles)
else
    cd(dirFiles)
end

for j=1:length(ncomp)
    dirName1 = strcat('prep_ncomp-',num2str(ncomp(j)));
    if not(isfolder(dirName1))%Check if the directory already exists
        mkdir(dirName1)
        cd(dirName1)
    else
        cd(dirName1)
    end
    %Normalization methods
    method = ["auto"];%,"grps","relat1","relat2","relat4","range1","range2","snvt"];
    
    for k=1:length(method)
        close all
        dirName2 = strcat('norm_meth_',method(k));
        if not(isfolder(dirName2))%Check if the directory already exists
            mkdir(dirName2)
            cd(dirName2)
        else
            cd(dirName2)
        end 
        
        %==========================
        %------Preprocessing-------          
        %==========================
        [train1,test1]=preprocessing(TRAIN1,TEST1,method(k),ncomp(j));
        [train2,test2]=preprocessing(TRAIN2,TEST2,method(k),ncomp(j));
        [train3,test3]=preprocessing(TRAIN3,TEST3,method(k),ncomp(j));
        [train4,test4]=preprocessing(TRAIN4,TEST4,method(k),ncomp(j));
        [train5,test5]=preprocessing(TRAIN5,TEST5,method(k),ncomp(j));
        [train6,test6]=preprocessing(TRAIN6,TEST6,method(k),ncomp(j));
        [train7,test7]=preprocessing(TRAIN7,TEST7,method(k),ncomp(j));
        [train8,test8]=preprocessing(TRAIN8,TEST8,method(k),ncomp(j));
        [train9,test9]=preprocessing(TRAIN9,TEST9,method(k),ncomp(j));
        %==================================================================
        
        %figure;

        %================================
        %--Principal Component Analysis--
        %================================
        [load_model1, scores_model1,latent_model1,T_model1] = pca(train1,'NumComponents',ncomp(j));
        [load_model2, scores_model2,latent_model2,T_model2] = pca(train2,'NumComponents',ncomp(j));
        [load_model3, scores_model3,latent_model3,T_model3] = pca(train3,'NumComponents',ncomp(j));
        [load_model4, scores_model4,latent_model4,T_model4] = pca(train4,'NumComponents',ncomp(j));
        [load_model5, scores_model5,latent_model5,T_model5] = pca(train5,'NumComponents',ncomp(j));
        [load_model6, scores_model6,latent_model6,T_model6] = pca(train6,'NumComponents',ncomp(j));
        [load_model7, scores_model7,latent_model7,T_model7] = pca(train7,'NumComponents',ncomp(j));
        [load_model8, scores_model8,latent_model8,T_model8] = pca(train8,'NumComponents',ncomp(j));
        [load_model9, scores_model9,latent_model9,T_model9] = pca(train9,'NumComponents',ncomp(j));
        %======================================================================================
        
        %ponderación del porcentaje de varianza (latent) para mirar la variabilidad
        [m,n] = size(latent_model1);
        K1=sum(latent_model1);
        K2=sum(latent_model2);
        K3=sum(latent_model3);
        K4=sum(latent_model4);
        K5=sum(latent_model5);
        K6=sum(latent_model6);
        K7=sum(latent_model7);
        K8=sum(latent_model8);
        K9=sum(latent_model9);
        %---------- prealocating ----------
        per_comp1 = zeros(m,1);
        per_comp2 = zeros(m,1);
        per_comp3 = zeros(m,1);
        per_comp4 = zeros(m,1);
        per_comp5 = zeros(m,1);
        per_comp6 = zeros(m,1);
        per_comp7 = zeros(m,1);
        per_comp8 = zeros(m,1);
        per_comp9 = zeros(m,1);
        %----------------------------------
        for i=1:m
            per_comp1(i,1)=(100*(latent_model1(i,1)))/K1;
            per_comp2(i,1)=(100*(latent_model2(i,1)))/K2;
            per_comp3(i,1)=(100*(latent_model3(i,1)))/K3;
            per_comp4(i,1)=(100*(latent_model4(i,1)))/K4;
            per_comp5(i,1)=(100*(latent_model5(i,1)))/K5;
            per_comp6(i,1)=(100*(latent_model6(i,1)))/K6;
            per_comp7(i,1)=(100*(latent_model7(i,1)))/K7;
            per_comp8(i,1)=(100*(latent_model8(i,1)))/K8;
            per_comp9(i,1)=(100*(latent_model9(i,1)))/K9;
        end
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp1);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the first PZT ')
        %fig_name = strcat('per_comp',num2str(k),'.png');
        %saveas(gcf,fig_name) 
        print('per_comp_first_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp2);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the second PZT ')
        %fig_name = strcat('per_comp',num2str(k+1),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_second_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp3);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the third PZT ')
        %fig_name = strcat('per_comp',num2str(k+2),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_third_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp4);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the fourth PZT ')
        %fig_name = strcat('per_comp',num2str(k+3),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_fourth_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp5);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the fifth PZT ')
        %fig_name = strcat('per_comp',num2str(k+4),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_fifth_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp6);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the sixth PZT ')
        %fig_name = strcat('per_comp',num2str(k+5),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_sixth_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp7);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the seventh PZT ')
        %fig_name = strcat('per_comp',num2str(k+6),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_seventh_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp8);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the eighth PZT ')
        %fig_name = strcat('per_comp',num2str(k+7),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_eighth_pzt','-dpdf','-bestfit')
        close
        
        figure
        %set(gcf,'units','normalized','outerposition',[0 0 1 1])
        bar(per_comp9);
        ylabel('%')
        xlabel('principal components')
        title('percentage of principal components for the ninth PZT ')
        %fig_name = strcat('per_comp',num2str(k+8),'.png');
        %saveas(gcf,fig_name)
        print('per_comp_ninth_pzt','-dpdf','-bestfit')
        close
        
        %==========================================
        %---Calculation of Scores, T and Q index---
        %==========================================
        [scores1,T1,Q1]=tqs1(test1,load_model1(:,1:ncomp(j)),latent_model1(1:ncomp(j)));
        clear train1
        clear test1
        clear load_model1
        clear latent_model1
        [scores2,T2,Q2]=tqs1(test2,load_model2(:,1:ncomp(j)),latent_model2(1:ncomp(j)));
        clear train2
        clear test2
        clear load_model2
        clear latent_model2
        [scores3,T3,Q3]=tqs1(test3,load_model3(:,1:ncomp(j)),latent_model3(1:ncomp(j)));
        clear train3
        clear test3
        clear load_model3
        clear latent_model3
        [scores4,T4,Q4]=tqs1(test4,load_model4(:,1:ncomp(j)),latent_model4(1:ncomp(j)));
        clear train4
        clear test4
        clear load_model4
        clear latent_model4
        [scores5,T5,Q5]=tqs1(test5,load_model5(:,1:ncomp(j)),latent_model5(1:ncomp(j)));
        clear train5
        clear test5
        clear load_model5
        clear latent_model5
        [scores6,T6,Q6]=tqs1(test6,load_model6(:,1:ncomp(j)),latent_model6(1:ncomp(j)));
        clear train6
        clear test6
        clear load_model6
        clear latent_model6
        [scores7,T7,Q7]=tqs1(test7,load_model7(:,1:ncomp(j)),latent_model7(1:ncomp(j)));
        clear train7
        clear test7
        clear load_model7
        clear latent_model7
        [scores8,T8,Q8]=tqs1(test8,load_model8(:,1:ncomp(j)),latent_model8(1:ncomp(j)));
        clear train8
        clear test8
        clear load_model8
        clear latent_model8
        [scores9,T9,Q9]=tqs1(test9,load_model9(:,1:ncomp(j)),latent_model9(1:ncomp(j)));
        clear train9
        clear test9
        clear load_model9
        clear latent_model9
        
        %------------------------
        %------T vs. Q plot------
        %------------------------
        figure
        plot (T1(1:20),Q1(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T1(21:40),Q1(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T1(41:60),Q1(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T1(61:80),Q1(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T1(81:100),Q1(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T1(101:120),Q1(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T1(121:140),Q1(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 1')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator1','-dpdf','-bestfit')
        close
        
        figure
        plot (T2(1:20),Q2(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T2(21:40),Q2(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T2(41:60),Q2(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T2(61:80),Q2(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T2(81:100),Q2(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T2(101:120),Q2(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T2(121:140),Q2(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 2')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator2','-dpdf','-bestfit')
        close
        
        figure
        plot (T3(1:20),Q3(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T3(21:40),Q3(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T3(41:60),Q3(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T3(61:80),Q3(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T3(81:100),Q3(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T3(101:120),Q3(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T3(121:140),Q3(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 3')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator3','-dpdf','-bestfit')
        close
        
        figure
        plot (T4(1:20),Q4(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T4(21:40),Q4(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T4(41:60),Q4(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T4(61:80),Q4(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T4(81:100),Q4(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T4(101:120),Q4(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T4(121:140),Q4(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 4')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator4','-dpdf','-bestfit')
        close
        
        figure
        plot (T5(1:20),Q5(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T5(21:40),Q5(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T5(41:60),Q5(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T5(61:80),Q5(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T5(81:100),Q5(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T5(101:120),Q5(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T5(121:140),Q5(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 5')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator5','-dpdf','-bestfit')
        close
        
        figure
        plot (T6(1:20),Q6(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T6(21:40),Q6(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T6(41:60),Q6(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T6(61:80),Q6(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T6(81:100),Q6(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T6(101:120),Q6(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T6(121:140),Q6(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 6')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator6','-dpdf','-bestfit')
        close
        
        figure
        plot (T7(1:20),Q7(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T7(21:40),Q7(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T7(41:60),Q7(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T7(61:80),Q7(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T7(81:100),Q7(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T7(101:120),Q7(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T7(121:140),Q7(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 7')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator7','-dpdf','-bestfit')
        close
        
        figure
        plot (T8(1:20),Q8(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T8(21:40),Q8(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T8(41:60),Q8(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T8(61:80),Q8(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T8(81:100),Q8(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T8(101:120),Q8(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T8(121:140),Q8(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 8')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator8','-dpdf','-bestfit')
        close
        
        figure
        plot (T9(1:20),Q9(1:20),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (T9(21:40),Q9(21:40),'bs','MarkerFaceColor',[.2 .6 .6])%grafica de los scores daño 1
        hold on
        plot (T9(41:60),Q9(41:60),'kd','MarkerFaceColor',[.8 .6 .6])
        hold on
        plot (T9(61:80),Q9(61:80),'mp','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T9(81:100),Q9(81:100),'gh','MarkerFaceColor',[.1 .2 .6])
        hold on
        plot (T9(101:120),Q9(101:120),'ys','MarkerFaceColor',[.5 .1 .4])
        hold on
        plot (T9(121:140),Q9(121:140),'cd','MarkerFaceColor',[.3 .4 .1])
        title ('ACTUATOR 9')
        xlabel('T')
        ylabel('Q')
        hold on
        legend('Un','D1','D2','D3','D4','D5','D6','Location','Best')
        print('TvsQ_actuator9','-dpdf','-bestfit')
        close
        
        %--------------------
        %----Scores plot-----
        %--------------------
        
        figure
        plot (scores1(1:20,1),scores1(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores1(21:40,1),scores1(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores1(41:60,1),scores1(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores1(61:80,1),scores1(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores1(81:100,1),scores1(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores1(101:120,1),scores1(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores1(121:140,1),scores1(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 1')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator1','-dpdf','-bestfit')
        close
        
        figure
        plot (scores2(1:20,1),scores2(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores2(21:40,1),scores2(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores2(41:60,1),scores2(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores2(61:80,1),scores2(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores2(81:100,1),scores2(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores2(101:120,1),scores2(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores2(121:140,1),scores2(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 2')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator2','-dpdf','-bestfit')
        close
        
        figure
        plot (scores3(1:20,1),scores3(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores3(21:40,1),scores3(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores3(41:60,1),scores3(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores3(61:80,1),scores3(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores3(81:100,1),scores3(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores3(101:120,1),scores3(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores3(121:140,1),scores3(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 3')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator3','-dpdf','-bestfit')
        close
        
        figure
        plot (scores4(1:20,1),scores4(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores4(21:40,1),scores4(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores4(41:60,1),scores4(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores4(61:80,1),scores4(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores4(81:100,1),scores4(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores4(101:120,1),scores4(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores4(121:140,1),scores4(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 4')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator4','-dpdf','-bestfit')
        close
        
        figure
        plot (scores5(1:20,1),scores5(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores5(21:40,1),scores5(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores5(41:60,1),scores5(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores5(61:80,1),scores5(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores5(81:100,1),scores5(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores5(101:120,1),scores5(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores5(121:140,1),scores5(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 5')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator5','-dpdf','-bestfit')
        close
        
        figure
        plot (scores6(1:20,1),scores6(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores6(21:40,1),scores6(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores6(41:60,1),scores6(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores6(61:80,1),scores6(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores6(81:100,1),scores6(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores6(101:120,1),scores6(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores6(121:140,1),scores6(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 6')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator6','-dpdf','-bestfit')
        close
        
        figure
        plot (scores7(1:20,1),scores7(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores7(21:40,1),scores7(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores7(41:60,1),scores7(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores7(61:80,1),scores7(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores7(81:100,1),scores7(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores7(101:120,1),scores7(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores7(121:140,1),scores7(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 7')
        xlabel('scores 1')
        ylabel('scores 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator7','-dpdf','-bestfit')
        close
        
        figure
        plot (scores8(1:20,1),scores8(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores8(21:40,1),scores8(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores8(41:60,1),scores8(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores8(61:80,1),scores8(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores8(81:100,1),scores8(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores8(101:120,1),scores8(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores8(121:140,1),scores8(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 8')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator8','-dpdf','-bestfit')
        close
        
        figure
        plot (scores9(1:20,1),scores9(1:20,2),'ro','MarkerFaceColor',[1 .6 .6]) %grafica de los scores del sistema sin daños
        hold on
        plot (scores9(21:40,1),scores9(21:40,2),'bs','MarkerFaceColor',[.2 .6 .6]) %D1
        hold on
        plot (scores9(41:60,1),scores9(41:60,2),'kd','MarkerFaceColor',[.8 .6 .6]) %D2
        hold on
        plot (scores9(61:80,1),scores9(61:80,2),'mp','MarkerFaceColor',[.1 .2 .6]) %D3
        hold on
        plot (scores9(81:100,1),scores9(81:100,2),'gh','MarkerFaceColor',[.1 .2 .6]) %D4
        hold on
        plot (scores9(101:120,1),scores9(101:120,2),'ys','MarkerFaceColor',[.5 .1 .4]) %D5
        hold on
        plot (scores9(121:140,1),scores9(121:140,2),'cd','MarkerFaceColor',[.3 .4 .1]) %D6
        hold on
        title('ACTUATOR 9')
        xlabel('score 1')
        ylabel('score 2')
        hold on
        legend('UND','D1','D2','D3','D4','D5','D6','Location','Best')
        print('Scores_actuator9','-dpdf','-bestfit')
        close
        
        %========================
        %-----Almacenamiento-----
        %========================
        
        %Store the Scores, the T and Q index in .mat files independently
        for i=1:9
            filename = strcat('scores',num2str(i));
            save(strcat(filename,'.mat'),filename)
        end
        
        %Fuses the Scores, the T and Q index in one file for each case
        ScTQ = [scores1 T1 Q1 scores2 T2 Q2 scores3 T3 Q3 scores4 T4 Q4 ...
            scores5 T5 Q5 scores6 T6 Q6 scores7 T7 Q7 scores8 T8 Q8 scores9 T9 Q9];
        filename2 = 'ScTQ';
        save(strcat(filename2,'.mat'),filename2)
        
        %Fuses the Scores and the Q index in one file for each case
        ScQ = [scores1 Q1 scores2 Q2 scores3 Q3 scores4 Q4 ...
            scores5 Q5 scores6 Q6 scores7 Q7 scores8 Q8 scores9 Q9];
        filename2 = 'ScQ';
        save(strcat(filename2,'.mat'),filename2)
        
        cd ..
    end
    cd ..
end

cd ..

