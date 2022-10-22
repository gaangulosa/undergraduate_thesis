%% Digital Filter 1D

%Data
x = VarName4;

%Define Window size
windowSize = 10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

y = filter(b,a,x);