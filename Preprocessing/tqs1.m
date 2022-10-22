function [scores,T,Q]=tqs1(X,loadings,eigenvalues)

scores=X*loadings;
%[scores,T,Q,CPQ,CPT,phi]=tqs(X,loadings,eigenvalues)
% % loadings
% % eigenvalues
S=1./sqrt(eigenvalues);
SM=S.^2;
T3=scores*diag(S);
T4=T3*loadings';
T=sum((T4.^2)')';
% %CPT=1;
% for i=1:20; %nd*ne%  REVISAR LAS CONTRIBUTIONS PLOTS.......
% CPT(i,1)=loadings(i,1)*X(i)*(scores(i,1))/(eigenvalues(1,1)); %para el primer score
% CPT(i,2)=loadings(i,2)*X(i)*(scores(i,2))/(eigenvalues(2,1)); %para el segundo score
% end
% cwd = pwd;
% cd(tempdir);
% pack
% cd(cwd)
% m=loadings';
% % for i=1:20;
% % CPT(i,:,1)=m(1,i)*X(i,:)*(scores(i,1))/(eigenvalues(1,1)); %para el primer score
% % CPT(i,:,2)=m(2,i)*X(i,:)*(scores(i,2))/(eigenvalues(2,1)); %para el segundo score
% % end
% % for i=1:100
% %     CPT(i,1)=(scores(i,1))/(eigenvalues(1,1));
% % end
E=X-scores*loadings';
% CPQ=(E.^2);% contribution to Q-statistics
Q=sum(E.^2,2);  %sum of each one of the elements elevated square of the each columns 
% %combined index......This index include T statistics and Q statistics.
% % xi=X;
% % x=xi;
% % Chi=chi2pdf(x,xi);           %Chi square distribution.
% % teta1=sum(diag(S));
% % teta2=sum((diag(S)).^2);
% % gSPE=teta2/teta1;
% % hSPE=(teta1.^2)/teta2;
% % %limit of control for SPE (Q)
% % delta=gSPE*Chi*hSPE;
% % %limit of control for T2
% % t2=Chi;
% %Combined index
% % phi1=((Q)*delta');
% % phi2=((T)*t2');
% % phi=phi1+phi2;
% phi=T+Q;
% %file modified for the calculate of the contribution plots
% %Diego Alexander Tibaduiza Burgos