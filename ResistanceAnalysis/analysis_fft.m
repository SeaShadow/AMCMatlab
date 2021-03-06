%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Frequency Analysis of Heave Data
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (kzurcher@amc.edu.au)
%# Date:         March 20, 2014
%#
%# Test date  :  August 27 to September 6, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  Runs 01-35   Turbulence Studs Investigation               (TSI)
%#               |__Disp. & trim:   1,500t, level static trim
%#               |__Conditions:     1 = No turbulence studs
%#                                  2 = First row of turbulence studs
%#                                  3 = First and second row of turbulence studs
%#
%# Runs TTI   :  Runs 36-62   Trim Tab Optimisation                        (TTI)
%#               |__Disp. & trim:   1,500t, level static trim
%#               |__Conditions:     4 = Trim tab at 5 degrees
%#                                  5 = Trim tab at 0 degrees
%#                                  6 = Trim tab at 10 degrees
%#
%# Runs FF1   :  Runs 63-80   Form Factor Estimation using Prohaska Method (FF)
%#               |__Disp. & trim:   1,500t, level static trim, trim tab 5 deg.
%#               |__Condition:      7 = Fr 0.1 to 0.2
%#
%# Runs RT    :  Runs 81-231  Resistance Test                              (RT)
%#               |__Disp. & trim:   1,500t, trim tab 5 deg.
%#               |__Conditions:     7 = Level static trim
%#                                  8 = Static trim = -0.5 deg. (by bow)
%#                                  9 = Static trim = 0.5 deg. (by stern)
%#                                 10 = Level static trim
%#                                 11 = Static trim = -0.5 deg. (by bow)
%#                                 12 = Static trim = 0.5 deg. (by stern)
%#
%# Runs FF2   :  Runs 231-249 Form Factor Estimation using Prohaska Method (FF)
%#               |__Disp. & trim:   1,500t, static trim approx. 3 deg., trim tab 5 deg.
%#               |__Condition:     13 = Fr 0.1 to 0.2
%#
%# Speeds (FR)    :  0.1-0.47 (5.9-27.6 knots)
%#
%# Description    :  Turbulence studs investigation, trim tab optimisation and
%#                   standard resistance test using a single catamaran demihull.
%#                   Form factor estimation has been carried out using prohaska
%#                   method as described by ITTC 7.2-02-02-01.
%#
%# ITTC Guidelines:  7.5-02-02-01
%#                   7.5-02-02-02
%#
%# ------------------------------------------------------------------------
%#
%# SCRIPTS  :    1 => analysis.m          Real units, save date to result array
%#
%#               => Copy data from resultsArray.dat to full_resistance_data.dat
%#
%#               2 => analysis_stats.m    Resistance and error plots
%#               3 => analysis_heave.m    Heave investigation related plots
%#               4 => analysis_lvdts.m    Fr vs. fwd, aft and heave plots
%#               5 => analysis_custom.m   Fr vs. Rtm/(VolDisp*p*g)*(1/Fr^2)
%#               6 => analysis_ts.m       Time series data for cond 7-12
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  24/09/2013 - Created new script
%#               dd/mm/yyyy - ...
%#
%# -------------------------------------------------------------------------


%# ------------------------------------------------------------------------
%# Clear workspace
%# ------------------------------------------------------------------------
clear
clc

%# ------------------------------------------------------------------------
%# Find and close all plots
%# ------------------------------------------------------------------------
allPlots = findall(0, 'Type', 'figure', 'FileName', []);
delete(allPlots);   % Close all plots

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
%profile on

%# ------------------------------------------------------------------------
%# Path where run directories are located
%# ------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
% testName = 'Turbulence Stud Investigation';
% testName = 'Trim Tab Optimistation';
testName = 'Frequency Analysis using FFT';

%# DAQ related settings ----------------------------------------------------
Fs = 200;                      % DAQ sampling frequency = 200Hz

%# ------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# ------------------------------------------------------------------------
headerlines             = 22;  % Number of headerlines to data
headerlinesZeroAndCalib = 16;  % Number of headerlines to zero and calibration factors


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START: Omit first X seconds of data due to acceleration
%# ------------------------------------------------------------------------

% X seconds x sample frequency = X x FS = XFS samples (from start)
startSamplePos    = 1;

% X seconds x sample frequency = X x FS = XFS samples (from end)
cutSamplesFromEnd = 0;

%# ------------------------------------------------------------------------
%# END: Omit first 10 seconds of data due to acceleration
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

startRun = 81;  % Start at run x
endRun   = 81;  % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArray = [];
for k=startRun:endRun
    
    %# Allow for 1 to become 01 for run numbers
    if k < 10
        filename = sprintf('%sR0%s.run\\RR0%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    else
        filename = sprintf('%sR%s.run\\RR%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    end
    [pathstr, name, ext] = fileparts(filename);     % Get file details like path, filename and extension
    
    %# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
    zAndCFData = importdata(filename, ' ', headerlines);
    zAndCF     = zAndCFData.data;
    
    %# Calibration factors and zeros
    ZeroAndCalibData = importdata(filename, ' ', headerlinesZeroAndCalib);
    ZeroAndCalib     = ZeroAndCalibData.data;
    
    %# Time series
    AllRawChannelData = importdata(filename, ' ', headerlines);
    
    %# Create new variables in the base workspace from those fields.
    vars = fieldnames(AllRawChannelData);
    for i = 1:length(vars)
        assignin('base', vars{i}, AllRawChannelData.(vars{i}));
    end
    
    % /////////////////////////////////////////////////////////////////////
    % START: CREATE PLOTS AND RUN DIRECTORY
    % ---------------------------------------------------------------------
    
    %# _PLOTS directory
    fPath = '_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end
    
    %# Averaged directory
    fPath = sprintf('_plots/%s', '_fft');
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % /////////////////////////////////////////////////////////////////////
    
    
    % /////////////////////////////////////////////////////////////////////
    %# START: Columns as variables (RAW DATA)
    %# --------------------------------------------------------------------
    
    timeData            = data(:,1);   % Timeline
    Raw_CH_0_Speed      = data(:,2);   % Speed             RU: m/s
    Raw_CH_1_LVDTFwd    = data(:,3);   % LVDT: Forward     RU: mm
    Raw_CH_2_LVDTAft    = data(:,4);   % LVDT: Aft         RU: mm
    Raw_CH_3_Drag       = data(:,5);   % Drag              RU: Grams (g)
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);   % Time: Zero
    Time_CF    = ZeroAndCalib(2);   % Time: Calibration factor
    CH_0_Zero  = ZeroAndCalib(3);   % Spped: Zero
    CH_0_CF    = ZeroAndCalib(4);   % Speed: Calibration factor
    CH_1_Zero  = ZeroAndCalib(5);   % Fwd LVDT: Zero
    CH_1_CF    = ZeroAndCalib(6);   % Fwd LVDT: Calibration factor
    CH_2_Zero  = ZeroAndCalib(7);   % Aft LVDT: Zero
    CH_2_CF    = ZeroAndCalib(8);   % Aft LVDT: Calibration factor
    CH_3_Zero  = ZeroAndCalib(9);   % Drag: Zero
    CH_3_CF    = ZeroAndCalib(10);  % Drag: Calibration factor
    
    %# --------------------------------------------------------------------
    %# END: Columns as variables (RAW DATA)
    % /////////////////////////////////////////////////////////////////////
    
    % /////////////////////////////////////////////////////////////////////
    % START: REAL UNITS COVNERSION
    % ---------------------------------------------------------------------
    
    [CH_0_Speed CH_0_Speed_Mean]     = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean] = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean] = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]       = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
    
    % ---------------------------------------------------------------------
    % END: REAL UNITS COVNERSION
    % /////////////////////////////////////////////////////////////////////
    
    
    %# ********************************************************************
    %# Fast Fourier Transform (FFT)
    %# ********************************************************************
    
    %# Create FFT plots and PNG images
    if k > 99
        runno = name(3:5);
        name  = name(2:5);
    else
        runno = name(3:4);
        name  = name(2:5);
    end
    
    [m,n] = size(timeData); % Array dimensions
    
    heaveData = [];
    for j=1:m
        heaveData(j,1) = (CH_1_LVDTFwd(j)+CH_2_LVDTAft(j))/2;
    end
    
    Fs = 200;                     % Sampling frequency
    T = 1/Fs;                     % Sample time
    L = m;                        % Length of signal
    t = (0:L-1)*T;                % Time vector
    
    heaveData = heaveData.';
    
    % Plot: With noise
    n        = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
    y        = n + heaveData;
    filename = sprintf('Run_%s_LVDT_Fwd_Noise', runno);
    fft_plot(Fs,timeData,y,1,length(y),filename,name);
    
    % Plot: No noise
    y        = heaveData;
    filename = sprintf('Run_%s_LVDT_Fwd', runno);
    fft_plot(Fs,timeData,y,1,length(y),filename,name);
    
    
    
    
    
    break;
    
    %# ********************************************************************
    %# MANUAL FFT FOR CHECKING
    %# ********************************************************************
    
    figurename = sprintf('%s (averaged):: 1,500 and 1,804 tonnes, level, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');
    
    Fs = 200;                     % Sampling frequency
    T = 1/Fs;                     % Sample time
    L = m;                        % Length of signal
    t = (0:L-1)*T;                % Time vector
    
    % Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
    %x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
    %y = x + 2*randn(size(t));    % Sinusoids plus noise
    
    x = timeData;
    n = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
    
    heaveData = heaveData.';      % Flip a matrix about its main diagonal, turning row vectors into column vectors and vice versa.
    
    y = n + heaveData;            % Plot (WITH noise)
    %y = heaveData;               % Plot (NO noise)
    
    %# Single-Sided Amplitude Spectrum of y(t) ----------------------------
    subplot(1,2,1)
    
    plot(x,y)
    title('{\bf Signal}')
    xlabel('{\bf Time (seconds)}')
    ylabel('{\bf Output (mm)}')
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Plot single-sided amplitude spectrum.
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(y,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    
    %# Single-Sided Amplitude Spectrum of y(t) ----------------------------
    subplot(1,2,2)
    
    plot(f,2*abs(Y(1:NFFT/2+1)))
    title('{\bf Single-Sided Amplitude Spectrum of y(t)}')
    xlabel('{\bf Frequency (Hz)}')
    ylabel('{\bf |Y(f)|}')
    grid on;
    box on;
    axis square;
    
    %# Save plot as PNG -------------------------------------------------------
    
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
    
end
