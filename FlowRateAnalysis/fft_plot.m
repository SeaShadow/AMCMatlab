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

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START DEFINE PLOT SIZE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END DEFINE PLOT SIZE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

figurename = sprintf('Fast Fourier Transform (FFT): Run %s', name(2:3));
f = figure('Name',figurename,'NumberTitle','off');

x   = rawData;
t   = timeData(sampleStart:sampleEnd,1);    % Time series
x   = x(sampleStart:sampleEnd,1);           % Input Data

Fs  = 800;              % Sampling frequency
T   = 1/Fs;             % Sample time
L   = length(x);        % Length of signal
t   = (0:L-1)*T;        % Time vector

%# RAW data
subplot(2,1,1);
plot(t,x);
xlabel('Time (s)');
ylabel('Output (V)');
title('{\bf Raw Data}');
xlim([0 round(length(x)/Fs)]);
grid on;

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');  

NFFT = 2^nextpow2(L);   % Next power of 2 from length of y
Y    = fft(x,NFFT)/L;
f    = Fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
subplot(2,1,2);
plot(f,2*abs(Y(1:NFFT/2))) 
title('{\bf Single-Sided Amplitude Spectrum of y(t)}')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on;

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');  

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
plotsavename = sprintf('_plots/%s/FFT_%s.png', name(1:3), savename);    % Assign save name
print(gcf, '-djpeg', plotsavename);                                     % Save plot to _plots
close;