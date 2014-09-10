%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Curve fitting and error estimate
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 8, 2014
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Repeated flow rate measurement test for validation and
%#               uncertainty analysis reasons.
%#
%# -------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  08/09/2014 - File creation
%#               dd/mm/yyyy - ...
%#
%# -------------------------------------------------------------------------

%# -------------------------------------------------------------------------
%# Clear workspace
%# -------------------------------------------------------------------------
clear
clc

%# -------------------------------------------------------------------------
%# Find and close all plots
%# -------------------------------------------------------------------------
allPlots = findall(0, 'Type', 'figure', 'FileName', []);
delete(allPlots);   % Close all plots

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
headerlines             = 27;  % Number of headerlines to data
headerlinesZeroAndCalib = 21;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration ----------------------------
%# ------------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 8000;
%startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 8000;
%cutSamplesFromEnd = 0;

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% startRun = 27;      % Start at run x
% endRun   = 29;      % Stop at run y

startRun = 1;      % Start at run x
endRun   = 67;      % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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

%# Time series directory
fPath = sprintf('_plots/%s', '_wave_probe');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

% ---------------------------------------------------------------------
% END: CREATE PLOTS AND RUN DIRECTORY
% /////////////////////////////////////////////////////////////////////


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

%# Collect data for cfArray
%[1]  Run number
%[2]  Slope
%[3]  Intercept
%[4]  S (root square)
%[5]  Error slope
%[6]  Error intercept
%[7]  Relative slope error
%[8]  Relative intercept error
%[9]  Channel number

cfArray = [];

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
    
    %# Columns as variables (RAW DATA)
    timeData             = data(:,1);       % Timeline
    Raw_CH_0_WaveProbe   = data(:,2);       % Wave probe data
    Raw_CH_1_KPStbd      = data(:,3);       % Kiel probe stbd data
    Raw_CH_2_KPPort      = data(:,4);       % Kiel probe port data
    %Raw_CH_3_StaticStbd  = data(:,5);       % Static stbd data
    %Raw_CH_4_StaticPort  = data(:,6);       % Static port data
    Raw_CH_5_RPMStbd     = data(:,5);       % RPM stbd data
    Raw_CH_6_RPMPort     = data(:,6);       % RPM port data
    Raw_CH_7_ThrustStbd  = data(:,7);       % Thrust stbd data
    Raw_CH_8_ThrustPort  = data(:,8);       % Thrust port data
    Raw_CH_9_TorqueStbd  = data(:,9);       % Torque stbd data
    Raw_CH_10_TorquePort = data(:,10);      % Torque port data
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
    %CH_0_CF    = 46.001;                % Custom calibration factor
    CH_1_Zero  = ZeroAndCalib(5);
    CH_1_CF    = ZeroAndCalib(6);
    CH_2_Zero  = ZeroAndCalib(7);
    CH_2_CF    = ZeroAndCalib(8);
    %CH_3_Zero  = ZeroAndCalib(9);
    %CH_3_CF    = ZeroAndCalib(10);
    %CH_4_Zero  = ZeroAndCalib(11);
    %CH_4_CF    = ZeroAndCalib(12);
    CH_5_Zero  = ZeroAndCalib(9);
    CH_5_CF    = ZeroAndCalib(10);
    CH_6_Zero  = ZeroAndCalib(11);
    CH_6_CF    = ZeroAndCalib(12);
    CH_7_Zero  = ZeroAndCalib(13);
    CH_7_CF    = ZeroAndCalib(14);
    CH_8_Zero  = ZeroAndCalib(15);
    CH_8_CF    = ZeroAndCalib(16);
    CH_9_Zero  = ZeroAndCalib(17);
    CH_9_CF    = ZeroAndCalib(18);
    CH_10_Zero = ZeroAndCalib(19);
    CH_10_CF   = ZeroAndCalib(20);
    
    %# --------------------------------------------------------------------
    %# Get real units by applying calibration factors and zeros
    %# --------------------------------------------------------------------
    
    timeDataShort                            = timeData(startSamplePos:end-cutSamplesFromEnd);
    
    %# Wave probe
    [CH_0_WaveProbe CH_0_WaveProbe_Mean]     = analysis_realunits(Raw_CH_0_WaveProbe,CH_0_Zero,CH_0_CF);
    
    %# DPT with kiel probe
    CH_1_KPStbd                              = Raw_CH_1_KPStbd;   % 5 PSI DPT
    CH_2_KPPort                              = Raw_CH_2_KPPort;   % 5 PSI DPT
    
    %# Dynamometer: Thrust
    [CH_7_ThrustStbd CH_7_ThrustStbd_Mean]   = analysis_realunits(Raw_CH_7_ThrustStbd,CH_7_Zero,CH_7_CF);
    [CH_8_ThrustPort CH_8_ThrustPort_Mean]   = analysis_realunits(Raw_CH_8_ThrustPort,CH_8_Zero,CH_8_CF);
    
    %# Dynamometer: Torque
    [CH_9_TorqueStbd CH_9_TorqueStbd_Mean]   = analysis_realunits(Raw_CH_9_TorqueStbd,CH_9_Zero,CH_9_CF);
    [CH_10_TorquePort CH_10_TorquePort_Mean] = analysis_realunits(Raw_CH_10_TorquePort,CH_10_Zero,CH_10_CF);
    
    [RPMStbd RPMPort]                        = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);
    
    %# Cut first X and last X seconds from data
    WaveProbe                                = CH_0_WaveProbe(startSamplePos:end-cutSamplesFromEnd);
    KPStbd                                   = CH_1_KPStbd(startSamplePos:end-cutSamplesFromEnd);
    KPPort                                   = CH_2_KPPort(startSamplePos:end-cutSamplesFromEnd);
    ThrustStbd                               = CH_7_ThrustStbd(startSamplePos:end-cutSamplesFromEnd);
    ThrustPort                               = abs(CH_8_ThrustPort(startSamplePos:end-cutSamplesFromEnd));
    TorqueStbd                               = CH_9_TorqueStbd(startSamplePos:end-cutSamplesFromEnd);
    TorquePort                               = abs(CH_10_TorquePort(startSamplePos:end-cutSamplesFromEnd));
    
    %# --------------------------------------------------------------------
    %# CHANNEL LIST
    %# --------------------------------------------------------------------
    
    %[0]    Wave probe
    %[1]    STBD: DPT (Kiel probe)
    %[2]    PORT: DPT (Kiel probe)
    %-4-    STBD: ISP (RPM)
    %-5-    PORT: ISP (RPM)
    %[6]    STBD: Dyno. thrust
    %[7]    PORT: Dyno. thrust
    %[8]    STBD: Dyno. torque
    %[9]    PORT: Dyno. torque
    
    % Sensor
    %(1)    Wave probe
    %(2)    STBD kiel probe
    %(3)    PORT kiel probe
    
    % /////////////////////////////////////////////////////////////////////
    % START: WAVE PROBE ANALYSIS
    % ---------------------------------------------------------------------

    %# Wave Probe: Summarise data for cfArray
    disp('------------------------------------------------------------------');
    titleTxt = sprintf('Run %s: Wave probe',num2str(k));
    disp(titleTxt);
    disp('------------------------------------------------------------------');
    [results] = curvefit(k,timeDataShort,WaveProbe);
    [m,n] = size(cfArray);
    if m == 0
        i=1;
    else
        i=m+1;        
    end
    cfArray(i,1) = results(1);
    cfArray(i,2) = results(2);
    cfArray(i,3) = results(3);
    cfArray(i,4) = results(4);
    cfArray(i,5) = results(5);
    cfArray(i,6) = results(6);
    cfArray(i,7) = results(7);
    cfArray(i,8) = results(8);
    cfArray(i,9) = 1;
    
    %# Keil Probe (Stbd): Summarise data for cfArray
    disp('------------------------------------------------------------------');
    titleTxt = sprintf('Run %s: Kiel Probe (Stbd)',num2str(k));
    disp(titleTxt);
    disp('------------------------------------------------------------------');
    [results] = curvefit(k,timeDataShort,KPStbd);
    [m,n] = size(cfArray);
    if m == 1
        i=2;
    else
        i=m+1;        
    end
    cfArray(i,1) = results(1);
    cfArray(i,2) = results(2);
    cfArray(i,3) = results(3);
    cfArray(i,4) = results(4);
    cfArray(i,5) = results(5);
    cfArray(i,6) = results(6);
    cfArray(i,7) = results(7);
    cfArray(i,8) = results(8);
    cfArray(i,9) = 2;
    
    %# Keil Probe (Port): Summarise data for cfArray
    disp('------------------------------------------------------------------');
    titleTxt = sprintf('Run %s: Kiel Probe (Port)',num2str(k));
    disp(titleTxt);
    disp('------------------------------------------------------------------');
    [results] = curvefit(k,timeDataShort,KPPort);
    [m,n] = size(cfArray);
    if m == 2
        i=3;
    else
        i=m+1;        
    end
    cfArray(i,1) = results(1);
    cfArray(i,2) = results(2);
    cfArray(i,3) = results(3);
    cfArray(i,4) = results(4);
    cfArray(i,5) = results(5);
    cfArray(i,6) = results(6);
    cfArray(i,7) = results(7);
    cfArray(i,8) = results(8);
    cfArray(i,9) = 3;
    
    %# --------------------------------------------------------------------
    %# Plotting
    %# --------------------------------------------------------------------
    
    %# Distinguish between PORT and STBD variables ------------------------
    if RPMStbd == 0
        shaftSpeed = RPMPort;
        propSys    = 'PORT';
    elseif RPMPort == 0
        propSys    = 'STBD';
        shaftSpeed = RPMStbd;
    end
    
    figurename = sprintf('Wave probe: Run %s, %s Shaft Speed = %s RPM', name(2:3), propSys, num2str(shaftSpeed));
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Time vs. Mass ------------------------------------------------------
    subplot(1,2,1);
    
    %# X and Y values
    x = timeDataShort;
    y = WaveProbe;
    
    %# Trendline
    p  = polyfit(x,y,1);
    p2 = polyval(p,x);
    
    h = plot(x,y,'-b',x,p2,'--k');
    title('{\bf Wave probe}');
    xlabel('{\bf Time [s]}');
    ylabel('{\bf Mass (Water) [Kg]}');
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line width
    set(h(1),'linewidth',1);
    set(h(2),'linewidth',2);
    
    %# Axis limitations
    xlim([x(1) x(end)]);
    ylim([y(1) y(end)]);
    %ylim([0 525]);
    
    %# Legend
    hleg1 = legend('Wave probe output','Trendline');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    
    %# Time vs. Kiel Probe Output -----------------------------------------
    subplot(1,2,2);
    
    %# X and Y values
    x = timeDataShort;
    y1 = KPStbd;
    y2 = KPPort;
    
    %# Trendline
    
    %# Starboard
    p1  = polyfit(x,y1,1);
    p21 = polyval(p1,x);
    
    %# Port
    p2  = polyfit(x,y2,1);
    p22 = polyval(p2,x);
    
    h = plot(x,y1,'-b',x,p21,'--k',x,y2,'-g',x,p22,'-.k');
    title('{\bf Kiel probe}');
    xlabel('{\bf Time [s]}');
    ylabel('{\bf Kiel probe [V]}');
    grid on;
    box on;
    axis square;
    
    %# Line width
    set(h(1),'linewidth',1);
    set(h(2),'linewidth',2);
    set(h(3),'linewidth',1);
    set(h(4),'linewidth',2);
    
    %# Axis limitations
    xlim([x(1) x(end)]);
    %ylim([y(1) y(end)]);
    ylim([1 4.5]);
    
    %# Legend
    hleg1 = legend('Kiel probe output (Stbd)','Trendline (Stbd)','Kiel probe output (Port)','Trendline (Port)');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    
    %# ********************************************************************
    %# Save plot as PNG
    %# ********************************************************************
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    
    %# Plot title ---------------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintff('_plots/%s/Run_%s_Time_vs_Mass_and_Time_vs_Kiel_Probe_Plot.pdf', '_wave_probe', num2str(k));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run_%s_Time_vs_Mass_and_Time_vs_Kiel_Probe_Plot.png', '_wave_probe', num2str(k));
    saveas(f, plotsavename);                % Save plot as PNG
    close;
    
    % ---------------------------------------------------------------------
    % END: WAVE PROBE ANALYSIS
    % /////////////////////////////////////////////////////////////////////
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);

%# Remove zero rows
%results(all(results==0,2),:)=[];


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
M = cfArray;
csvwrite('cfArray.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('cfArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer