%# ------------------------------------------------------------------------
%# function fft_plot( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Z�rcher (kzurcher@amc.edu.au)
%# Date:         September 11, 2013
%# 
%# Function   :  Plot FFTs 
%# 
%# Description:  Fast Fourier Transform (FFT) plots and save as PNG file.
%# 
%# Parameters :  samplefreq   = Sampling frequency (i.e. 200)
%#               timeData     = Time series data
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
%#    >> samplefreq  = 200; 
%#    >> timeData    = [ 1 2 3 4 5 6 7 8 9 10 ]; 
%#    >> rawData     = [ 5 6 7 8 9 10 11 12 13 14 ]; 
%#    >> sampleStart = 1; 
%#    >> sampleEnd   = 1000; 
%#    >> savename    = 'filename'; 
%#    >> name        = 'R09'; 
%#    >> fft_plot(samplefreq,timeData,rawData,sampleStart,sampleEnd,savename,name)
%#    ans = NONE
%#
%# ------------------------------------------------------------------------

function fft_plot(samplefreq,timeData,rawData,sampleStart,sampleEnd,savename,name)

%# ------------------------------------------------------------------------
%# START DEFINE PLOT SIZE
%# ------------------------------------------------------------------------
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END DEFINE PLOT SIZE
%# ------------------------------------------------------------------------

%# ------------------------------------------------------------------------
%# START PLOTTING
%# ------------------------------------------------------------------------
figurename = sprintf('Fast Fourier Transform (FFT): Run %s %s', name(2:3));
f = figure('Name',figurename,'NumberTitle','off');

x   = rawData;
t   = timeData(sampleStart:sampleEnd);      % Time series
x   = x(sampleStart:sampleEnd);             % Input Data

Fs  = samplefreq;                           % Sampling frequency
T   = 1/Fs;                                 % Sample time
L   = length(x);                            % Length of signal
t   = (0:L-1)*T;                            % Time vector

%# Plot RAW data ----------------------------------------------------------
subplot(1,2,1);
plot(t,x);
xlabel('Time (s)');
ylabel('Output (V)');
title('{\bf Raw Data}');
%xlim([0 round(length(x)/Fs)]);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');  

NFFT = 2^nextpow2(L);               % Next power of 2 from length of y
Y    = fft(x,NFFT)/L;
f    = Fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum ------------------------------------
subplot(1,2,2);
plot(f,2*abs(Y(1:NFFT/2))) 
title('{\bf Single-Sided Amplitude Spectrum of y(t)}')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');  

%# Plot title -------------------------------------------------------------
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

%# ------------------------------------------------------------------------
%# END PLOTTING
%# ------------------------------------------------------------------------

%# ------------------------------------------------------------------------
%# SAVE PLOTS AS PNGs
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end    

%# RUN directory
fPath = sprintf('_plots/%s', '_fft');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end
plotsavename = sprintf('_plots/%s/FFT_%s.png', '_fft', savename);   % Assign save name
print(gcf, '-djpeg', plotsavename);                                 % Save plot to _plots
%close;