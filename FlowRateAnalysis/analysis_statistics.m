%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Statistics
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  July 5, 2013
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  Statisitcal analysis of run data.
%#
%# -------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  05/07/2013 - File creation
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
headerlines             = 29;  % Number of headerlines to data
headerlinesZeroAndCalib = 23;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration ----------------------------
%# ------------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 8000;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 8000;   

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

startRun = 54;      % Start at run x
endRun   = 86;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

statisticsArray = [];
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
    Raw_CH_3_StaticStbd  = data(:,5);       % Static stbd data
    Raw_CH_4_StaticPort  = data(:,6);       % Static port data
    Raw_CH_5_RPMStbd     = data(:,7);       % RPM stbd data
    Raw_CH_6_RPMPort     = data(:,8);       % RPM port data
    Raw_CH_7_ThrustStbd  = data(:,9);       % Thrust stbd data
    Raw_CH_8_ThrustPort  = data(:,10);      % Thrust port data
    Raw_CH_9_TorqueStbd  = data(:,11);      % Torque stbd data
    Raw_CH_10_TorquePort = data(:,12);      % Torque port data
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    %CH_0_CF    = ZeroAndCalib(4);
    CH_0_CF    = 46.001;                % Custom calibration factor
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
    
    %# Cut first X and last X seconds from data
    KPStbd      = CH_1_KPStbd(startSamplePos:end-cutSamplesFromEnd);
    KPPort      = CH_2_KPPort(startSamplePos:end-cutSamplesFromEnd);
    ThrustStbd  = CH_7_ThrustStbd(startSamplePos:end-cutSamplesFromEnd);
    ThrustPort  = abs(CH_8_ThrustPort(startSamplePos:end-cutSamplesFromEnd));
    TorqueStbd  = CH_9_TorqueStbd(startSamplePos:end-cutSamplesFromEnd);
    TorquePort  = abs(CH_10_TorquePort(startSamplePos:end-cutSamplesFromEnd));
    
    %# Determine RPM
    %[RPMStbd RPMPort] = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);

    %# --------------------------------------------------------------------
    %# Populate statistics arrray
    %# --------------------------------------------------------------------
    %# Results array columns: 
        %[1]        Run number
        %[2 3 4]    Mean, std stdmean >> STBD: DPT with kiel probe (V)
        %[5 6 7]    Mean, std stdmean >> PORT: DPT with kiel probe (V)
        %[8 9 10]   Mean, std stdmean >> STBD: Dynamometer: Thrust (g)
        %[11 12 13] Mean, std stdmean >> PORT: Dynamometer: Thrust (g)
        %[14 15 16] Mean, std stdmean >> STBD: Dynamometer: Torque (Nm)
        %[17 18 19] Mean, std stdmean >> PORT: Dynamometer: Torque (Nm)
        %[20]       Set Shaft Speed   (RPM)
        %[21]       STBD: Shaft Speed (RPM)
        %[22]       PORT: Shaft Speed (RPM)

    statisticsArray(k, 1) = k;
    
    %# STBD: DPT with kiel probe
    dataset = KPStbd;
    statisticsArray(k, 2) = mean(dataset);
    statisticsArray(k, 3) = std(dataset);
    statisticsArray(k, 4) = std(dataset)/sqrt(length(dataset));

    %# PORT: DPT with kiel probe
    dataset = KPPort;
    statisticsArray(k, 5) = mean(dataset);
    statisticsArray(k, 6) = std(dataset);
    statisticsArray(k, 7) = std(dataset)/sqrt(length(dataset));
    
    %# STBD: Dynamometer: Thrust
    dataset = ThrustStbd;
    statisticsArray(k, 8) = mean(dataset);
    statisticsArray(k, 9) = std(dataset);
    statisticsArray(k, 10) = std(dataset)/sqrt(length(dataset));
    
    %# PORT: Dynamometer: Thrust
    dataset = ThrustPort;
    statisticsArray(k, 11) = mean(dataset);
    statisticsArray(k, 12) = std(dataset);
    statisticsArray(k, 13) = std(dataset)/sqrt(length(dataset));
    
    %# STBD: Dynamometer: Torque
    dataset = TorqueStbd;
    statisticsArray(k, 14) = mean(dataset);
    statisticsArray(k, 15) = std(dataset);
    statisticsArray(k, 16) = std(dataset)/sqrt(length(dataset));
    
    %# PORT: Dynamometer: Torque    
    dataset = TorquePort;
    statisticsArray(k, 17) = mean(dataset);
    statisticsArray(k, 18) = std(dataset);
    statisticsArray(k, 19) = std(dataset)/sqrt(length(dataset));
    
    %# Add set shaft RPM
    if ismember(k,[9:11 64:66 30:32]) == 1
        statisticsArray(k, 20) = 500;
    elseif ismember(k,[59;67;54]) == 1
        statisticsArray(k, 20) = 750;  
    elseif ismember(k,[12:14 68:70 33:35]) == 1
        statisticsArray(k, 20) = 1000;   
    elseif ismember(k,[60;71;55]) == 1
        statisticsArray(k, 20) = 1250;
    elseif ismember(k,[15:17 72:74 36:38]) == 1
        statisticsArray(k, 20) = 1500;      
    elseif ismember(k,[61;75;56]) == 1
        statisticsArray(k, 20) = 1750;     
    elseif ismember(k,[18:20 76:78 39:41]) == 1
        statisticsArray(k, 20) = 2000;   
    elseif ismember(k,[62;79;57]) == 1
        statisticsArray(k, 20) = 2250;          
    elseif ismember(k,[21:23 80:82 42:44]) == 1
        statisticsArray(k, 20) = 2500;   
    elseif ismember(k,[63;83;58]) == 1
        statisticsArray(k, 20) = 2750;   
    elseif ismember(k,[24:29 84:86 45:50]) == 1
        statisticsArray(k, 20) = 3000;         
    else
        statisticsArray(k, 20) = 0;
    end
    
    %# STBD: Measured shaft RPM
    statisticsArray(k, 21) = 0; %RPMStbd
    
    %# PORT: Measured shaft RPM
    statisticsArray(k, 22) = 0; %RPMPort
        
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);

%# Remove zero rows
%results(all(results==0,2),:)=[];


%# ************************************************************************
%# PLOT XXX vs. YYY *************************************************
%# ************************************************************************

% figurename = sprintf('%s', 'Plot: Kiel Probe vs. Mass Flow Rate');
% f = figure('Name',figurename,'NumberTitle','off');
% 
% %# SEPARATE SYSTEMS: RPM vs. flow rate ------------------------------------
% subplot(1,2,1);
% 
% xport = averagedArray(1:11,7);
% yport = averagedArray(1:11,5);
% 
% xstbd = averagedArray(12:22,6);
% ystbd = averagedArray(12:22,5);
% 
% %# Averaged stbd and port data
% xArray = [];  xArray(:,1) = xport;  xArray(:,2) = xstbd;
% yArray = [];  yArray(:,1) = yport;  yArray(:,2) = ystbd;
% 
% avgX = mean(xArray(:,1:2).');  avgX = avgX.';
% avgY = mean(yArray(:,1:2).');  avgY = avgY.';
% 
% plot(xstbd,ystbd,'x',xport,yport,'o','LineWidth',2,'MarkerSize',10);    % ,avgX,avgY,'-*k'
% xlabel('{\bf Differential pressure transducer output [V]}');
% ylabel('{\bf Flow rate [Kg/s]}');
% title('{\bf Separate runs for stbd and port waterjet system}');
% xlim([0.9 3.1]);
% grid on;
% axis square;
% 
% hleg1 = legend('S:Starboard waterjet','S:Port waterjet');               % ,'S:Averaged'
% set(hleg1,'Location','NorthWest');
% set(hleg1,'Interpreter','none');
% 
% %# Figure size on screen (50% scaled, but same aspect ratio)
% set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
% 
% %# Figure size printed on paper
% set(gcf, 'PaperUnits','centimeters');
% set(gcf, 'PaperSize',[XPlot YPlot]);
% set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
% set(gcf, 'PaperOrientation','portrait');


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
M = statisticsArray;
csvwrite('statisticsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('statisticsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer