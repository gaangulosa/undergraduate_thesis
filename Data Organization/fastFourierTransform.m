%% Fast fourier transform 

signal = y;

%Sample Frequency
Fs = 50000000; %in Hz
T = 1/Fs;
L = length(signal);

Y = fft(signal);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1(1) = [];
P1 = P1';

f = Fs*(0:(L/2))/L;
f(1) = [];
plot(f,P1)
hold on; grid on; grid minor;
%b = (1/windowSize)*ones(1,windowSize);
