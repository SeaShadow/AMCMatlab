%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Compare repeats of repeated runs and plot data
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  May 16, 2015
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Repeated flow rate measurement test for validation and
%#               uncertainty analysis reasons.
%#
%# ------------------------------------------------------------------------
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


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

startRun = 9;       % Start at run x
endRun   = 11;      % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START Repeated Runs
%# ------------------------------------------------------------------------

repeatRunsArray = [];

%# ------------------------------------------------------------------------
%# END Repeated Runs
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////
resultsArrayWP     = [];
resultsArrayKPStbd = [];
resultsArrayKPPort = [];
resultsArrayTStbd  = [];
resultsArrayTPort  = [];
resultsArrayQStbd  = [];
resultsArrayQPort  = [];
rpmStbdArray       = [];
rpmPortArray       = [];
runArray           = [];
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
    
 
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# START: WRITE RESULT ARRAYS
    %# --------------------------------------------------------------------
    
    [CH_0_WaveProbe ans2] = analysis_realunits(Raw_CH_0_WaveProbe,CH_0_Zero,CH_0_CF);
    resultsArrayWP(k,1:length(CH_0_WaveProbe)) = CH_0_WaveProbe;
    
    resultsArrayKPStbd(k,1:length(Raw_CH_1_KPStbd)) = Raw_CH_1_KPStbd;
    resultsArrayKPPort(k,1:length(Raw_CH_2_KPPort)) = Raw_CH_2_KPPort;
    
    [CH_7_ThrustStbd ans2] = analysis_realunits(Raw_CH_7_ThrustStbd,CH_7_Zero,CH_7_CF);
    resultsArrayTStbd(k,1:length(CH_7_ThrustStbd)) = CH_7_ThrustStbd;
    
    [CH_8_ThrustPort ans2] = analysis_realunits(Raw_CH_8_ThrustPort,CH_8_Zero,CH_8_CF);
    resultsArrayTPort(k,1:length(CH_8_ThrustPort)) = CH_8_ThrustPort;
    
    [CH_9_TorqueStbd ans2] = analysis_realunits(Raw_CH_9_TorqueStbd,CH_9_Zero,CH_9_CF);
    resultsArrayQStbd(k,1:length(CH_9_TorqueStbd)) = CH_9_TorqueStbd;

    [CH_10_TorquePort ans2] = analysis_realunits(Raw_CH_10_TorquePort,CH_10_Zero,CH_10_CF);       
    resultsArrayQPort(k,1:length(CH_10_TorquePort)) = CH_10_TorquePort;
    
    [RPMStbd RPMPort] = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);
    
%     rpmStbdArray(k) = RPMStbd;
%     rpmPortArray(k) = RPMPort;
    
    if RPMStbd > RPMPort
        setMeasuredRPM = RPMStbd;
    elseif RPMPort > RPMStbd
        setMeasuredRPM = RPMPort;
    else
        setMeasuredRPM = 0;
    end
    
    %# --------------------------------------------------------------------
    %%# END: WRITE RESULT ARRAYS
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    runArray(k, 1) = str2num(name(2:3));
    
end

%# Remove zero rows
runArray(all(runArray==0,2),:)=[];
resultsArrayWP(all(resultsArrayWP==0,2),:)=[];
resultsArrayKPStbd(all(resultsArrayKPStbd==0,2),:)=[];
resultsArrayKPPort(all(resultsArrayKPPort==0,2),:)=[];
resultsArrayTStbd(all(resultsArrayTStbd==0,2),:)=[];
resultsArrayTPort(all(resultsArrayTPort==0,2),:)=[];
resultsArrayQStbd(all(resultsArrayQStbd==0,2),:)=[];
resultsArrayQPort(all(resultsArrayQPort==0,2),:)=[];

% rpmStbdArray = rpmStbdArray.';
% rpmPortArray = rpmPortArray.';
% rpmStbdArray(all(rpmStbdArray==0,2),:)=[];
% rpmPortArray(all(rpmPortArray==0,2),:)=[];
% 
% meanRPMStbd = round(mean(rpmStbdArray));
% meanRPMPort = round(mean(rpmPortArray));

%# Plot repeats, save PNG files and execure single factor ANOVA
repeat_plot(timeData,resultsArrayWP,runArray,setMeasuredRPM,'CH 0: Wave Probe','Kg','CH_0_Wave_Probe',name)
%repeat_plot(timeData,resultsArrayKPStbd,runArray,meanRPMStbd,'CH 1: STBD Kiel Probe','V','CH_1_STBD_Kiel_Probe',name)
repeat_plot(timeData,resultsArrayKPPort,runArray,setMeasuredRPM,'CH 2: PORT Kiel Probe','V','CH_2_PORT_Kiel_Probe',name)
%repeat_plot(timeData,resultsArrayTStbd,runArray,meanRPMStbd,'CH 5: STBD Thrust','g','CH_7_STBD_Thrust',name)
repeat_plot(timeData,resultsArrayTPort,runArray,setMeasuredRPM,'CH 6: PORT Thrust','g','CH_8_PORT_Thrust',name)
%repeat_plot(timeData,resultsArrayQStbd,runArray,meanRPMStbd,'CH 7: STBD Torque','Nm','CH_9_STBD_Torque',name)
repeat_plot(timeData,resultsArrayQPort,runArray,setMeasuredRPM,'CH 8: PORT Torque','Nm','CH_10_PORT_Torque',name)
