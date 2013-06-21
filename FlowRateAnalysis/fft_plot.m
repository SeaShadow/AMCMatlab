%# ------------------------------------------------------------------------
%# function fft_plot( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         June 19, 2013
%# 
%# Function   :  Plot FFTs 
%# 
%# Description:  Fast Fourier Transform (FFT) plots and save as PNG file.
%# 
%# Parameters :  timeData     = Time series data
%#               rawData      = Raw measurement data
%#               sampleStart  = Start of sample (i.e. for windowing)
%#               sampleEnd    = End of sample (i.e. for windowing)
%#               savename     = Filename for PNG file
%#               name         = Run file name (e.g. R12-02_moving)
%#
%# Return     :  NONE
%# 
%# Examples of Usage: 
%# 
%#    >> timeData    = [ 1 2 3 4 5 6 7 8 9 10 ]; 
%#    >> rawData     = [ 5 6 7 8 9 10 11 12 13 14 ]; 
%#    >> sampleStart = 1; 
%#    >> sampleEnd   = 1000; 
%#    >> savename    = 'filename'; 
%#    >> name        = 'R09'; 
%#    >> fft_plot(timeData,rawData,sampleStart,sampleEnd,savename,name)
%#    ans = NONE
%#
%# ------------------------------------------------------------------------

function fft_plot(timeData,rawData,sampleStart,sampleEnd,savename,name)
    
figurename = sprintf('Fast Fourier Transform (FFT): %s', name);
f = figure('Name',figurename,'NumberTitle','off');

x   = rawData;
t   = timeData(sampleStart:sampleEnd,1);    % Time series
x   = x(sampleStart:sampleEnd,1);           % Input Data

Fs  = 800;          % Sampling frequency
T   = 1/Fs;         % Sample time
L   = length(x);    % Length of signal
t   = (0:L-1)*T;    % Time vector

%# RAW data
subplot(2,1,1);
plot(t,x);
xlabel('Time (s)');
ylabel('Output (V)');
title('{\bf Raw Data}');
xlim([0 round(length(x)/Fs)]);
grid on;

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y    = fft(x,NFFT)/L;
f    = Fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
subplot(2,1,2);
plot(f,2*abs(Y(1:NFFT/2))) 
title('{\bf Single-Sided Amplitude Spectrum of y(t)}')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on;

%# ------------------------------------------------------------------------
%# Save plots as PNGs -----------------------------------------------------
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end    

%# RUN directory
fPath = sprintf('_plots/%s', name(1:3));
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end
plotsavename = sprintf('_plots/%s/%s_FFT.png', name(1:3), savename);    % Assign save name
print(gcf, '-djpeg', plotsavename);                                     % Save plot to _plots
close;