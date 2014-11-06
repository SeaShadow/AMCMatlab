%# ------------------------------------------------------------------------
%# Self-Propulsion Test - Fast Fourier Transforms
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  November 12, 2013
%#
%# Test date  :  November 5 to November 18, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs CT    :  1-15    PST + DPT Calibration Test               (CT)
%# Runs RT    :  16-28   Resistance Test / Transom Streamlines    (RT)
%# Runs BLM   :  29-69   Boundary Layer Measurements              (BLM)
%# Runs SPP   :  70-110  Self-Propulsion Points                   (SPP)
%# Runs SPT   :  111-180 Self-Propulsion Test                     (SPT)
%#
%# Speeds (FR)    :  0.3-0.4 (18-24 knots)
%#
%# Description    :  Waterjet self-propulsion test based on test setups
%#                   using literature and ITTC.
%#
%# ITTC Guidelines:  7.5-02-02-03.1
%#                   7.5-02-02-03.2
%#                   7.5-02-02-03.3
%#
%# ------------------------------------------------------------------------
%#
%# SCRIPTS  :    => analysis.m        First iteration analysis
%#                                    ==> Creates resultsArray.dat
%#
%#               => analysis_calib.m  PST calibration run data
%#                                    ==> Creates resultsArrayCALIB.dat
%#
%#               => analysis_rt.m    Flow visualistation and resistance
%#                                    ==> Creates resultsArrayRT.dat
%#
%#               => analysis_bl.m    Bondary layer measurements
%#                                    ==> Creates resultsArrayBL.dat
%#
%#               => analysis_spp.m    Self-propulsion points
%#                                    ==> Creates resultsArraySPP.dat
%#
%#               => analysis_spt.m    Self-propulsion test
%#                                    ==> Creates resultsArraySPT.dat
%#
%#               => analysis_avg.m    Averages self-propulsion test repeats
%#                                    ==> Creates avgResultsArray.dat
%#
%#               => analysis_ts.m    Time series data
%#                                    ==> Creates resultsArrayTS.dat
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  21/10/2013 - Created new script
%#               dd/mm/yyyy - ...
%#
%# ------------------------------------------------------------------------

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

%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
% testName = 'Resistance Test';
% testName = 'Boundary Layer Investigation';
% testName = 'Waterjet Self-Propulsion Points';
testName = 'Waterjet Self-Propulsion Test';

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
%profile on

%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 39;  % Number of headerlines to data
headerlinesZeroAndCalib = 33;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration ----------------------------
%# ------------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 0;

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

startRun = 119;      % Start at run x
endRun   = 119;      % Stop at run y

%startRun = 111;      % Start at run x
%endRun   = 180;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableRPMPlot          = 1; % RPM FFT plot

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArrayFFT = [];
%w = waitbar(0,'Processed run files');
for k=startRun:endRun
    
    %# Allow for 1 to become 01 for run numbers
    if k < 10
        filename = sprintf('%s0%s.run\\R0%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    else
        filename = sprintf('%s%s.run\\R%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
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
    
    %# RUN directory
    fPath = sprintf('_plots/%s', 'RPM');
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % /////////////////////////////////////////////////////////////////////
    
    %# Columns as variables (RAW DATA)
    timeData               = data(:,1);       % Timeline
    Raw_CH_0_Speed         = data(:,2);       % Speed
    Raw_CH_1_LVDTFwd       = data(:,3);       % Forward LVDT
    Raw_CH_2_LVDTAft       = data(:,4);       % Aft LVDT
    Raw_CH_3_Drag          = data(:,5);       % Load cell (drag)
    Raw_CH_4_PortRPM       = data(:,6);       % Port RPM
    Raw_CH_5_StbdRPM       = data(:,7);       % Starboard RPM
    Raw_CH_6_PortThrust    = data(:,8);       % Port thrust
    Raw_CH_7_PortTorque    = data(:,9);       % Port torque
    Raw_CH_8_StbdThrust    = data(:,10);      % Starboard thrust
    Raw_CH_9_StbdTorque    = data(:,11);      % Starboard torque
    Raw_CH_10_PortKP       = data(:,12);      % Port kiel probe
    Raw_CH_11_StbdKP       = data(:,13);      % Starboard kiel probe
    Raw_CH_12_Port_Stat_6  = data(:,14);      % Port static pressure ITTC station 6
    Raw_CH_13_Stbd_Stat_6  = data(:,15);      % Starboard static pressure ITTC station 6
    Raw_CH_14_Stbd_Stat_5  = data(:,16);      % Starboard static pressure ITTC station 5
    Raw_CH_15_Stbd_Stat_4  = data(:,17);      % Starboard static pressure ITTC station 4
    Raw_CH_16_Stbd_Stat_3  = data(:,18);      % Starboard static pressure ITTC station 3
    Raw_CH_17_Port_Stat_1a = data(:,19);      % Port static pressure ITTC station 1a
    Raw_CH_18_Stbd_Stat_1a = data(:,20);      % Starboard static pressure ITTC station 1a
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
    CH_1_Zero  = ZeroAndCalib(5);
    CH_1_CF    = ZeroAndCalib(6);
    CH_2_Zero  = ZeroAndCalib(7);
    CH_2_CF    = ZeroAndCalib(8);
    CH_3_Zero  = ZeroAndCalib(9);
    CH_3_CF    = ZeroAndCalib(10);
    CH_4_Zero  = ZeroAndCalib(11);
    CH_4_CF    = ZeroAndCalib(12);
    CH_5_Zero  = ZeroAndCalib(13);
    CH_5_CF    = ZeroAndCalib(14);
    CH_6_Zero  = ZeroAndCalib(15);
    CH_6_CF    = ZeroAndCalib(16);
    CH_7_Zero  = ZeroAndCalib(17);
    CH_7_CF    = ZeroAndCalib(18);
    CH_8_Zero  = ZeroAndCalib(19);
    CH_8_CF    = ZeroAndCalib(20);
    CH_9_Zero  = ZeroAndCalib(21);
    CH_9_CF    = ZeroAndCalib(22);
    CH_10_Zero = ZeroAndCalib(23);
    CH_10_CF   = ZeroAndCalib(24);
    CH_11_Zero = ZeroAndCalib(25);
    CH_11_CF   = ZeroAndCalib(26);
    CH_12_Zero = ZeroAndCalib(27);
    CH_12_CF   = ZeroAndCalib(28);
    CH_13_Zero = ZeroAndCalib(29);
    CH_13_CF   = ZeroAndCalib(30);
    CH_14_Zero = ZeroAndCalib(31);
    CH_14_CF   = ZeroAndCalib(32);
    CH_15_Zero = ZeroAndCalib(33);
    CH_15_CF   = ZeroAndCalib(34);
    CH_16_Zero = ZeroAndCalib(35);
    CH_16_CF   = ZeroAndCalib(36);
    CH_17_Zero = ZeroAndCalib(37);
    CH_17_CF   = ZeroAndCalib(38);
    CH_18_Zero = ZeroAndCalib(39);
    CH_18_CF   = ZeroAndCalib(40);
    
    % Change from 2 to 3 digits
    if k > 99
        runno = name(2:4);
    else
        runno = name(1:3);
    end
    
    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    %[RPMStbd RPMPort] = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);
    
    %# *******************************************************************
    %# RPM FFT Plots
    %# *******************************************************************
    if enableRPMPlot == 1
        
        %# RAW data plots -------------------------------------------------
        
        startSample = 1;
        endSample   = 800;
        
        x  = timeData(startSample:endSample);
        y1 = Raw_CH_4_PortRPM(startSample:endSample);
        y2 = Raw_CH_5_StbdRPM(startSample:endSample);
        
        figurename = sprintf('%s:: RPM Logger (Raw Data), Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# PORT -----------------------------------------------------------
        subplot(2,2,1)
        
        %x = timeData;
        %y = Raw_CH_10_PortKP;
        
        %yy = sgolayfilt(y,3,41);   % Apply 3rd-order filter
        
        h = plot(x,y1,'MarkerSize',7);
        title('{\bf Raw data}');
        xlabel('{\bf Time series [s]}');
        ylabel('{\bf Output [V]}');
        grid on;
        box on;
        %axis square;
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        %set(h(1),'linewidth',1);
        %set(h(2),'linewidth',2);
        
        % FFT /////////////////////////////////////////////////////////////
        subplot(2,2,2)
        
        [m,n] = size(timeData); % Array dimensions
        
        Fs = 800;           % Sampling frequency
        T = 1/Fs;           % Sample time
        L = m;              % Length of signal
        t = (0:L-1)*T;      % Time vector
        
        % Plot single-sided amplitude spectrum
        NFFT = 2^nextpow2(L);               % Calculating the min power p with 2^p > N
        Y    = fft(y1,NFFT)/L;               % FFT calculation
        fp   = Fs/2*linspace(0,1,NFFT/2+1); % Frequency points for the calculated FFT
        
        plot(fp,2*abs(Y(1:NFFT/2+1)))
        title('{\bf FFT: Single-Sided Amplitude Spectrum of y(t)}')
        xlabel('{\bf Frequency (Hz)}')
        ylabel('{\bf |Y(f)|}')
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([0 400]);
        set(gca,'XTick',[0:20:400]);
        
        
        %# STARBOARD ------------------------------------------------------
        subplot(2,2,3)
        
        %x = timeData;
        %y = Raw_CH_11_StbdKP;
        
        h = plot(x,y2,'MarkerSize',7);
        title('{\bf Raw data}');
        xlabel('{\bf Time series [s]}');
        ylabel('{\bf Output [V]}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        % FFT /////////////////////////////////////////////////////////////
        subplot(2,2,4)
        
        [m,n] = size(timeData); % Array dimensions
        
        Fs = 800;           % Sampling frequency
        T = 1/Fs;           % Sample time
        L = m;              % Length of signal
        t = (0:L-1)*T;      % Time vector
        
        % Plot single-sided amplitude spectrum
        NFFT = 2^nextpow2(L);               % Calculating the min power p with 2^p > N
        Y    = fft(y2,NFFT)/L;               % FFT calculation
        fp   = Fs/2*linspace(0,1,NFFT/2+1); % Frequency points for the calculated FFT
        
        plot(fp,2*abs(Y(1:NFFT/2+1)))
        title('{\bf FFT: Single-Sided Amplitude Spectrum of y(t)}')
        xlabel('{\bf Frequency (Hz)}')
        ylabel('{\bf |Y(f)|}')
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([0 400]);
        set(gca,'XTick',[0:20:400]);
        
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
        
        %# Save plots as PDF and PNG
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_FFT_Stbd_and_Port.pdf', 'RPM', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_FFT_Stbd_and_Port.png', 'RPM', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        %close;
        
    end
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
%M = resultsArrayFFT;
%csvwrite('resultsArrayFFT.dat', M)                                     % Export matrix M to a file delimited by the comma character
%dlmwrite('resultsArrayFFT.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
