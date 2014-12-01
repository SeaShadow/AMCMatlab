%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Statistics
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  December 1, 2014
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Statistics for time series data.
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  08/09/2014 - File creation
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


%# ************************************************************************
%# START: PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle     = 1;    % Show plot title in saved file
enablePlotTitle         = 1;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 1;    % Show plots scale to A4 size

% Loop through stats
enableStatsLoop         = 1;    % Show original statistics

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox2'));
[mtb,ntb] = size(ind);

% IF ntb > 0 Curve Fitting Toolbox is installed
enableCurveFittingToolboxCurvePlot = 0;    % Show fit curves when using Curve Fitting Toolbox
if ntb > 0
    enableCurveFittingToolboxPlot  = 1;
    enableEqnOfFitPlot             = 0;
else
    enableCurveFittingToolboxPlot  = 0;
    enableEqnOfFitPlot             = 1;
end

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


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
%# GENERAL SETTINGS
%# ------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# ------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# ------------------------------------------------------------------------
headerlines             = 27;  % Number of headerlines to data
headerlinesZeroAndCalib = 21;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 8000;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 8000;   


%# ************************************************************************
%# START File loop for runs, startRun to endRun
%# ------------------------------------------------------------------------

startRun = 1;      % Start at run x
endRun   = 67;     % Stop at run y

startRun = 8;      % Start at run x
endRun   = 67;     % Stop at run y

%# ------------------------------------------------------------------------
%# END File loop for runs, startRun to endRun
%# ************************************************************************


%# ************************************************************************
%# START Define plot size
%# ------------------------------------------------------------------------
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END Define plot size
%# ************************************************************************


%# ************************************************************************
%# START Distinguish between PORT and STBD
%# ------------------------------------------------------------------------
testRuns = 1:7;
portRuns = 8:37;
stbdRuns = 38:67;
%# ------------------------------------------------------------------------
%# END Distinguish between PORT and STBD
%# ************************************************************************


%# ************************************************************************
%# START Create directories if not available
%# ------------------------------------------------------------------------

%# _wave_probe directory --------------------------------------------------
setDirName = '_plots/_descriptive_statistics';

fPath = setDirName;
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('%s/%s', setDirName, 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('%s/%s', setDirName, 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('%s/%s', setDirName, 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END Create directories if not available
%# ************************************************************************


%# ************************************************************************
%# START Read results DAT file
%# ------------------------------------------------------------------------
if exist('resultsArray_copy.dat', 'file') == 2
    %# Results array columns:
    %[1]  Run No.
    %[2]  FS                                                        (Hz)
    %[3]  No. of samples                                            (-)
    %[4]  Record time                                               (s)
    %[5]  Flow rate                                                 (Kg/s)
    %[6]  Kiel probe STBD                                           (V)
    %[7]  Kiel probe PORT                                           (V)
    %[8]  Thrust STBD                                               (N)
    %[9]  Thrust PORT                                               (N)
    %[10] Torque STBD                                               (Nm)
    %[11] Torque PORT                                               (Nm)
    %[12] Shaft Speed STBD                                          (RPM)
    %[13] Shaft Speed PORT                                          (RPM)
    %[14] Power STBD                                                (W)
    %[15] Power PORT                                                (W)
    %# Added columns: 18/8/2014
    %[16] Mass flow rate (1s only)                                  (Kg/s)
    %[17] Mass flow rate (mean, 1s intervals)                       (Kg/s)
    %[18] Mass flow rate (overall, Q/t)                             (Kg/s)
    %[19] Diff. mass flow rate (mean, 1s intervals)/(overall, Q/t)  (%)
    
    results = csvread('resultsArray_copy.dat');
    
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('-----------------------------------------------------------------');
    disp('File resultsArray_copy.dat does not exist!');
    disp('-----------------------------------------------------------------');
    break;
end
%# ------------------------------------------------------------------------
%# START Read results DAT file
%# ************************************************************************


%# ************************************************************************
%# 1. Calculate Descriptive Statistics for Time Series Data
%# ************************************************************************
if enableStatsLoop == 1
    
    statisticsArray    = [];
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
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        
        %# Wave probe
        %[CH_0_WaveProbe CH_0_WaveProbe_Mean]     = analysis_realunits(Raw_CH_0_WaveProbe,CH_0_Zero,CH_0_CF);
        
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
        KPStbd      = CH_1_KPStbd(startSamplePos:end-cutSamplesFromEnd);
        KPPort      = CH_2_KPPort(startSamplePos:end-cutSamplesFromEnd);
        ThrustStbd  = CH_7_ThrustStbd(startSamplePos:end-cutSamplesFromEnd);
        ThrustPort  = abs(CH_8_ThrustPort(startSamplePos:end-cutSamplesFromEnd));
        TorqueStbd  = CH_9_TorqueStbd(startSamplePos:end-cutSamplesFromEnd);
        TorquePort  = abs(CH_10_TorquePort(startSamplePos:end-cutSamplesFromEnd));
 
        %# Determine RPM
        %[RPMStbd RPMPort] = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);
        
        %# ----------------------------------------------------------------
        %# DESCRIPTIVE STATISTICS FOR TIME SERIES DATA ONLY (FOR EACH RUN)!
        %# Populate statistics arrray (var and std based on mean comparison)
        %# ----------------------------------------------------------------
        %# NOTES (see Matlab help files):
        %# var(X,1) normalizes by N and produces the second moment of the 
        %#          sample about its mean.  var(X,0) is the same as var(X)
        %# std(X,1) normalizes by N and produces the square root of the 
        %#          second  moment of the sample about its mean
        %# ----------------------------------------------------------------
        %# Results array columns:
        % [1]     Run number                                            (#)
        % [2:6]   Min, Max, Mean, Var, Std >> STBD: DPT with kiel probe (V)
        % [7:11]  Min, Max, Mean, Var, Std >> PORT: DPT with kiel probe (V)
        % [12:16] Min, Max, Mean, Var, Std >> STBD: Dynamometer: Thrust (g)
        % [17:21] Min, Max, Mean, Var, Std >> PORT: Dynamometer: Thrust (g)
        % [22:26] Min, Max, Mean, Var, Std >> STBD: Dynamometer: Torque (Nm)
        % [27:31] Min, Max, Mean, Var, Std >> PORT: Dynamometer: Torque (Nm)
        % [32]    STBD: Shaft Speed                                     (RPM)
        % [33]    PORT: Shaft Speed                                     (RPM)
        %# Columns added 21/11/2014:
        % [34]    Propulsion system (0=Test, 1=Port and 2=Stbd)         (#)
        % [35]    Set shaft speed                                       (RPM)
        
        statisticsArray(k, 1) = k;
        
        %# STBD: DPT with kiel probe
        dataset = KPStbd;
        statisticsArray(k, 2)  = min(dataset);
        statisticsArray(k, 3)  = max(dataset);
        statisticsArray(k, 4)  = mean(dataset);
        statisticsArray(k, 5)  = var(dataset,1);
        statisticsArray(k, 6)  = std(dataset,1);
        
        %# PORT: DPT with kiel probe
        dataset = KPPort;
        statisticsArray(k, 7)  = min(dataset);
        statisticsArray(k, 8)  = max(dataset);
        statisticsArray(k, 9)  = mean(dataset);
        statisticsArray(k, 10) = var(dataset,1);
        statisticsArray(k, 11) = std(dataset,1);
        
        %# STBD: Dynamometer: Thrust
        dataset = ThrustStbd;
        statisticsArray(k, 12) = min(dataset);
        statisticsArray(k, 13) = max(dataset);
        statisticsArray(k, 14) = mean(dataset);
        statisticsArray(k, 15) = var(dataset,1);
        statisticsArray(k, 16) = std(dataset,1);
        
        %# PORT: Dynamometer: Thrust
        dataset = ThrustPort;
        statisticsArray(k, 17) = min(dataset);
        statisticsArray(k, 18) = max(dataset);
        statisticsArray(k, 19) = mean(dataset);
        statisticsArray(k, 20) = var(dataset,1);
        statisticsArray(k, 21) = std(dataset,1);
        
        %# STBD: Dynamometer: Torque
        dataset = TorqueStbd;
        statisticsArray(k, 22) = min(dataset);
        statisticsArray(k, 23) = max(dataset);
        statisticsArray(k, 24) = mean(dataset);
        statisticsArray(k, 25) = var(dataset,1);
        statisticsArray(k, 26) = std(dataset,1);
        
        %# PORT: Dynamometer: Torque
        dataset = TorquePort;
        statisticsArray(k, 27)  = min(dataset);
        statisticsArray(k, 28)  = max(dataset);
        statisticsArray(k, 29)  = mean(dataset);
        statisticsArray(k, 30)  = var(dataset,1);
        statisticsArray(k, 31)  = std(dataset,1);
        
        %# STBD: Measured shaft RPM
        statisticsArray(k, 32) = RPMStbd;
        
        %# PORT: Measured shaft RPM
        statisticsArray(k, 33) = RPMPort;

        % Add static number for propulsion system where 0=Test, 1=Port and 2=Stbd
        if ismember(k,testRuns) == 1
            setPropSys = 0;
        elseif ismember(k,portRuns) == 1
            setPropSys = 1;
        elseif ismember(k,stbdRuns) == 1
            setPropSys = 2;
        end
        statisticsArray(k, 34) = setPropSys;
        
        % Add set shaft speed
        
        % Port and Stbd
        if ismember(k,8) || ismember(k,40)
            setSS = 800;
        elseif ismember(k,9:11) || ismember(k,[38 41:43])
            setSS = 1000;
        elseif ismember(k,[12 16]) || ismember(k,44)
            setSS = 1200;
        elseif ismember(k,[13:15 17]) || ismember(k,45:47)
            setSS = 1400;
        elseif ismember(k,18) || ismember(k,48)
            setSS = 1600;
        elseif ismember(k,19:21) || ismember(k,49:51)
            setSS = 1800;
        elseif ismember(k,22) || ismember(k,[39 52])
            setSS = 2000;
        elseif ismember(k,23:25) || ismember(k,53:55)
            setSS = 2200;
        elseif ismember(k,26) || ismember(k,56)
            setSS = 2400;
        elseif ismember(k,27:29) || ismember(k,57:59)
            setSS = 2600;
        elseif ismember(k,30) || ismember(k,60)
            setSS = 2800
        elseif ismember(k,31:33) || ismember(k,61:63)
            setSS = 3000;
        elseif ismember(k,34) || ismember(k,64)
            setSS = 3200;
        elseif ismember(k,35:37) || ismember(k,65:67)
            setSS = 3400;
        else
            setSS = 0;
        end
        statisticsArray(k, 35) = setSS;
        
    end % Loop
    
    %# ************************************************************************
    %# START Write results to CVS
    %# ------------------------------------------------------------------------
    statisticsArray = statisticsArray(any(statisticsArray,2),:);           % Remove zero rows
    M = statisticsArray;
    csvwrite('statisticsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character
    dlmwrite('statisticsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
    %# ------------------------------------------------------------------------
    %# END Write results to CVS
    %# ************************************************************************
    
end % enableStatsLoop


%# ************************************************************************
%# 2. Calculate Descriptive Statistics (Repeatability)
%#    NOTE: Source of calculations are results for averaged repeated runs
%# ************************************************************************

%# Distinguish between PORT and STBD --------------------------------------
testRuns = results(1:7,:);
portRuns = results(8:37,:);
stbdRuns = results(38:end,:);

TestRunArray = [1:7];
PortRunArray = [8:37];
StbdRunArray = [38:67];

%# Number of runs ---------------------------------------------------------
[mtr,ntr] = size(testRuns);
[mpr,npr] = size(portRuns);
[msr,nsr] = size(stbdRuns);

% Put RPM values in correct column (because wrong DAQ channel)
for k=1:mpr
    if ismember(k,[1 2 3 4])
        %disp(sprintf('Run %s',num2str(k)));
        portRuns(k,13) = portRuns(k,12);
        portRuns(k,12) = 0;
    end
end

% PORT
for k=1:mpr
    if ismember(portRuns(k,1),8)
        runSeries = 1;
    elseif ismember(portRuns(k,1),9:11)
        runSeries = 2;
    elseif ismember(portRuns(k,1),[12 16])
        runSeries = 3;
    elseif ismember(portRuns(k,1),[13:15 17])
        runSeries = 4;
    elseif ismember(portRuns(k,1),18)
        runSeries = 5;
    elseif ismember(portRuns(k,1),19:21)
        runSeries = 6;
    elseif ismember(portRuns(k,1),22)
        runSeries = 7;
    elseif ismember(portRuns(k,1),23:25)
        runSeries = 8;
    elseif ismember(portRuns(k,1),26)
        runSeries = 9;
    elseif ismember(portRuns(k,1),27:29)
        runSeries = 10;
    elseif ismember(portRuns(k,1),30)
        runSeries = 11;
    elseif ismember(portRuns(k,1),31:33)
        runSeries = 12;
    elseif ismember(portRuns(k,1),34)
        runSeries = 13;
    elseif ismember(portRuns(k,1),35:37)
        runSeries = 14;
    else
        runSeries = 0;
    end
    portRuns(k,20) = runSeries;
end

% STBD
for k=1:msr
    if ismember(stbdRuns(k,1),40)
        runSeries = 1;
    elseif ismember(stbdRuns(k,1),[38 41:43])
        runSeries = 2;
    elseif ismember(stbdRuns(k,1),44)
        runSeries = 3;
    elseif ismember(stbdRuns(k,1),45:47)
        runSeries = 4;
    elseif ismember(stbdRuns(k,1),48)
        runSeries = 5;
    elseif ismember(stbdRuns(k,1),49:51)
        runSeries = 6;
    elseif ismember(stbdRuns(k,1),[39 52])
        runSeries = 7;
    elseif ismember(stbdRuns(k,1),53:55)
        runSeries = 8;
    elseif ismember(stbdRuns(k,1),56)
        runSeries = 9;
    elseif ismember(stbdRuns(k,1),57:59)
        runSeries = 10;
    elseif ismember(stbdRuns(k,1),60)
        runSeries = 11;
    elseif ismember(stbdRuns(k,1),61:63)
        runSeries = 12;
    elseif ismember(stbdRuns(k,1),64)
        runSeries = 13;
    elseif ismember(stbdRuns(k,1),65:67)
        runSeries = 14;
    else
        runSeries = 0;
    end
    stbdRuns(k,20) = runSeries;
end

%# 1. Calculate the mean or average of your data. To do this, add your measurements and divide by the number of elements in your sample. For example, if your measurements are 1, 2, 2, 3, 2, the average would be 2 -- 10 divided by 5.
%# 2. Calculate the variance of your data. To do this, calculate the difference of each result from the mean, square each result and work out the average. For example, if the difference from the mean in a set of data were 1, 2, -2 and -1, the variance would be 2.5. That is, the average of 1, 4, 4 and 1.
%# 3. Calculate the square root of the variance. This is the repeatability standard deviation of your data. Following our previous example, the standard deviation would be 1.5811.

% Sort PORT runs by RPM values (repeated runs)
R = portRuns;   % Results array
APort = arrayfun(@(x) R(R(:,20) == x, :), unique(R(:,20)), 'uniformoutput', false);
[mport,nport] = size(APort);

% Sort STBD runs by RPM values (repeated runs)
R = stbdRuns;   % Results array
AStbd = arrayfun(@(x) R(R(:,20) == x, :), unique(R(:,20)), 'uniformoutput', false);
[mstbd,nstbd] = size(AStbd);

% Create array for descriptive statistics
descStatsArray = [];

% Columns descStatsArray:
%[1]  Speed (1-14)                          (-)
% NOTE: Speeds 1-14 are for set speeds: 800   (1)
%                                       1,000 (2)
%                                       1,200 (3)
%                                       1,400 (4)
%                                       1,600 (5)
%                                       1,800 (6)
%                                       2,000 (7)
%                                       2,200 (8)
%                                       2,400 (9)
%                                       2,600 (10)
%                                       2,800 (11)
%                                       3,000 (12)
%                                       3,200 (13)
%                                       3,400 (14)

% SHAFT SPEED
%[2]  Min                                   (-)
%[3]  Max                                   (-)
%[4]  Mean (or average)                     (-)
%[5]  Variance                              (-)
%[6]  Standard deviation                    (-)

% MASS FLOW RATE (1s only)
%[7]  Min                                   (-)
%[8]  Max                                   (-)
%[9]  Mean (or average)                     (-)
%[10] Variance                              (-)
%[11] Standard deviation                    (-)

% MASS FLOW RATE (mean, 1s intervals)
%[12] Min                                   (-)
%[13] Max                                   (-)
%[14] Mean (or average)                     (-)
%[15] Variance                              (-)
%[16] Standard deviation                    (-)

% MASS FLOW RATE (overall, Q/t)
%[17] Min                                   (-)
%[18] Max                                   (-)
%[19] Mean (or average)                     (-)
%[20] Variance                              (-)
%[21] Standard deviation                    (-)

% KIEL PROBE
%[22] Min                                   (-)
%[23] Max                                   (-)
%[24] Mean (or average)                     (-)
%[25] Variance                              (-)
%[26] Standard deviation                    (-)

% PROPULSION SYSTEM (PORT=1 and STBD=2)
%[27] Propulsion system                     (-)

%# ------------------------------------------------------------------------
%# NOTES (see Matlab help files):
%# var(X,1) normalizes by N and produces the second moment of the
%#          sample about its mean.  var(X,0) is the same as var(X)
%# std(X,1) normalizes by N and produces the square root of the
%#          second  moment of the sample about its mean
%# ------------------------------------------------------------------------

% Simple example for descriptive statistics:
%# 1. Calculate the mean or average of your data. To do this, add your measurements and divide by the number of elements in your sample. For example, if your measurements are 1, 2, 2, 3, 2, the average would be 2 -- 10 divided by 5.
%# 2. Calculate the variance of your data. To do this, calculate the difference of each result from the mean, square each result and work out the average. For example, if the difference from the mean in a set of data were 1, 2, -2 and -1, the variance would be 2.5. That is, the average of 1, 4, 4 and 1.
%# 3. Calculate the square root of the variance. This is the repeatability standard deviation of your data. Following our previous example, the standard deviation would be 1.5811.
% A = [1 2 2 3 2];
% [m,n] = size(A);
% meanA = mean(A);
% varArray  = [];
% for k=1:n
% 	varArray (k) = (A(k)-meanA)^2;
% end
% meanVA = mean(varArray);
% stdA = sqrt(meanVA);
% disp('-----------------------------------------------');
% disp(sprintf('Mean: %s',num2str(meanA)));
% disp(sprintf('Variance: %s',num2str(meanVA)));
% disp(sprintf('Standard deviation: %s',num2str(stdA)));
% disp('-----------------------------------------------');
% disp(sprintf('Mean: %s',num2str(mean(A))));
% disp(sprintf('Variance: %s',num2str(var(A,1))));
% disp(sprintf('Standard deviation: %s',num2str(std(A,1))));
% disp('-----------------------------------------------');

% PORT
for k=1:mport
    % SPEED
    descStatsArray(k,1) = k;
    
    % SHAFT SPEED
    dataset = APort{k}(:,13);
    descStatsArray(k,2) = min(dataset);
    descStatsArray(k,3) = max(dataset);
    descStatsArray(k,4) = mean(dataset);
    descStatsArray(k,5) = var(dataset,1);
    descStatsArray(k,6) = std(dataset,1);
    
    % MASS FLOW RATE (1s only)
    dataset = APort{k}(:,16);
    descStatsArray(k,7) = min(dataset);
    descStatsArray(k,8) = max(dataset);
    descStatsArray(k,9) = mean(dataset);
    descStatsArray(k,10) = var(dataset,1);
    descStatsArray(k,11) = std(dataset,1);
    
    % MASS FLOW RATE (mean, 1s intervals)
    dataset = APort{k}(:,17);
    descStatsArray(k,12) = min(dataset);
    descStatsArray(k,13) = max(dataset);
    descStatsArray(k,14) = mean(dataset);
    descStatsArray(k,15) = var(dataset,1);
    descStatsArray(k,16) = std(dataset,1);
    
    % MASS FLOW RATE (overall, Q/t)
    dataset = APort{k}(:,18);
    descStatsArray(k,17) = min(dataset);
    descStatsArray(k,18) = max(dataset);
    descStatsArray(k,19) = mean(dataset);
    descStatsArray(k,20) = var(dataset,1);
    descStatsArray(k,21) = std(dataset,1);
    
    % KIEL PROBE
    dataset = APort{k}(:,7);
    descStatsArray(k,22) = min(dataset);
    descStatsArray(k,23) = max(dataset);
    descStatsArray(k,24) = mean(dataset);
    descStatsArray(k,25) = var(dataset,1);
    descStatsArray(k,26) = std(dataset,1);
    
    % PROPULSION SYSTEM (PORT=1 and STBD=2)
    descStatsArray(k,27) = 1;
end

[m,n] = size(descStatsArray);

% STBD
for k=1:mstbd
    kadd = m+k;
    
    % SPEED
    descStatsArray(kadd,1) = k;
    
    % SHAFT SPEED
    dataset = AStbd{k}(:,12);
    descStatsArray(kadd,2) = min(dataset);
    descStatsArray(kadd,3) = max(dataset);
    descStatsArray(kadd,4) = mean(dataset);
    descStatsArray(kadd,5) = var(dataset,1);
    descStatsArray(kadd,6) = std(dataset,1);
    
    % MASS FLOW RATE (1s only)
    dataset = AStbd{k}(:,16);
    descStatsArray(kadd,7) = min(dataset);
    descStatsArray(kadd,8) = max(dataset);
    descStatsArray(kadd,9) = mean(dataset);
    descStatsArray(kadd,10) = var(dataset,1);
    descStatsArray(kadd,11) = std(dataset,1);
    
    % MASS FLOW RATE (mean, 1s intervals)
    dataset = AStbd{k}(:,17);
    descStatsArray(kadd,12) = min(dataset);
    descStatsArray(kadd,13) = max(dataset);
    descStatsArray(kadd,14) = mean(dataset);
    descStatsArray(kadd,15) = var(dataset,1);
    descStatsArray(kadd,16) = std(dataset,1);
    
    % MASS FLOW RATE (overall, Q/t)
    dataset = AStbd{k}(:,18);
    descStatsArray(kadd,17) = min(dataset);
    descStatsArray(kadd,18) = max(dataset);
    descStatsArray(kadd,19) = mean(dataset);
    descStatsArray(kadd,20) = var(dataset,1);
    descStatsArray(kadd,21) = std(dataset,1);
    
    % KIEL PROBE
    dataset = AStbd{k}(:,6);
    descStatsArray(kadd,22) = min(dataset);
    descStatsArray(kadd,23) = max(dataset);
    descStatsArray(kadd,24) = mean(dataset);
    descStatsArray(kadd,25) = var(dataset,1);
    descStatsArray(kadd,26) = std(dataset,1);
    
    % PROPULSION SYSTEM (PORT=1 and STBD=2)
    descStatsArray(kadd,27) = 2;
end


%# ************************************************************************
%# 3. Plotting Descriptive Statistics (Repeatability)
%# ************************************************************************

% Set RPM speeds
setRPMArray = [800 1000 1200  1400 1600 1800 2000 2200 2400 2600 2800 3000 3200 3400];

% Plotting
figurename = sprintf('%s: Standard Deviation', 'Descriptive Statistics (Repeatability)');
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours ---------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. --------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors --------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth1      = 1;
setLineWidth2      = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';

%# Subplot #1 -------------------------------------------------------------
subplot(3,2,1);

%# X and Y axis -----------------------------------------------------------

x     = descStatsArray(1:14,1);

yPort = descStatsArray(1:14,11)';
yStbd = descStatsArray(15:28,11)';

y     = [yPort; yStbd];

%# Plotting ---------------------------------------------------------------
h = bar(x,y');
if enablePlotTitle == 1
    title('{\bf Mass Flow Rate (1s only)}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Set shaft speed condition [#]}','FontSize',setGeneralFontSize);
ylabel('{\bf Standard Deviation [-]}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Axis limitations
%minX  = 1;
%maxX  = 2;
%incrX = 1;
minY  = 0;
maxY  = 0.03;
incrY = 0.01;
%set(gca,'XLim',[minX maxX]);
%set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Legend
hleg1 = legend('Port','Starboard');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Subplot #2 -------------------------------------------------------------
subplot(3,2,3);

%# X and Y axis -----------------------------------------------------------
x     = descStatsArray(1:14,1);
%x     = setRPMArray;
yPort = descStatsArray(1:14,16)';
yStbd = descStatsArray(15:28,16)';
y     = [yPort; yStbd];

%# Plotting ---------------------------------------------------------------
h = bar(x,y');
if enablePlotTitle == 1
    title('{\bf Mass Flow Rate (mean, 1s intervals)}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Set shaft speed condition [#]}','FontSize',setGeneralFontSize);
ylabel('{\bf Standard Deviation [-]}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Axis limitations
%minX  = 1;
%maxX  = 2;
%incrX = 1;
minY  = 0;
maxY  = 0.03;
incrY = 0.01;
%set(gca,'XLim',[minX maxX]);
%set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))

%# Legend
hleg1 = legend('Port','Starboard');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Subplot #3 -------------------------------------------------------------
subplot(3,2,5);

%# X and Y axis -----------------------------------------------------------
x     = descStatsArray(1:14,1);
%x     = setRPMArray;
yPort = descStatsArray(1:14,21)';
yStbd = descStatsArray(15:28,21)';
y     = [yPort; yStbd];

%# Plotting ---------------------------------------------------------------
h = bar(x,y');
if enablePlotTitle == 1
    title('{\bf Mass Flow Rate (overall, Q/t)}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Set shaft speed condition [#]}','FontSize',setGeneralFontSize);
ylabel('{\bf Standard Deviation [-]}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Axis limitations
%minX  = 1;
%maxX  = 2;
%incrX = 1;
minY  = 0;
maxY  = 0.03;
incrY = 0.01;
%set(gca,'XLim',[minX maxX]);
%set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))

%# Legend
hleg1 = legend('Port','Starboard');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Subplot #4 -------------------------------------------------------------
subplot(3,2,2);

%# X and Y axis -----------------------------------------------------------
x     = descStatsArray(1:14,1);
%x     = setRPMArray;
yPort = descStatsArray(1:14,21)';
yStbd = descStatsArray(15:28,21)';
y     = [yPort; yStbd];

%# Plotting ---------------------------------------------------------------
h = bar(x,y');
if enablePlotTitle == 1
    title('{\bf Kiel Probe}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Set shaft speed condition [#]}','FontSize',setGeneralFontSize);
ylabel('{\bf Standard Deviation [-]}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Axis limitations
%minX  = 1;
%maxX  = 2;
%incrX = 1;
minY  = 0;
maxY  = 0.03;
incrY = 0.01;
%set(gca,'XLim',[minX maxX]);
%set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))

%# Legend
hleg1 = legend('Port','Starboard');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Subplot #1 -------------------------------------------------------------
subplot(3,2,4);

%# X and Y axis -----------------------------------------------------------
x     = descStatsArray(1:14,1);
%x     = setRPMArray;
yPort = descStatsArray(1:14,6)';
yStbd = descStatsArray(15:28,6)';
y     = [yPort; yStbd];

%# Plotting ---------------------------------------------------------------
h = bar(x,y');
if enablePlotTitle == 1
    title('{\bf Measured shaft speed}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Set shaft speed condition [#]}','FontSize',setGeneralFontSize);
ylabel('{\bf Standard Deviation [-]}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Axis limitations
%minX  = 1;
%maxX  = 2;
%incrX = 1;
%minY  = 1;
%maxY  = 4;
%incrY = 1;
%set(gca,'XLim',[minX maxX]);
%set(gca,'XTick',minX:incrX:maxX);
%et(gca,'YLim',[minY maxY]);
%set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Legend
hleg1 = legend('Port','Starboard');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for kl=1:3
    plotsavename = sprintf('_plots/%s/%s/Descriptive_Statistics_for_Averaged_Runs_Plot.%s', '_descriptive_statistics', setFileFormat{kl}, setFileFormat{kl});
    print(gcf, setSaveFormat{kl}, plotsavename);
end
%close;

% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
