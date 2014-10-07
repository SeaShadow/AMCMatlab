%# ------------------------------------------------------------------------
%# Self-Propulsion Test - Time Series Investigation
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  November 28, 2013
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
%# CHANGES    :  28/11/2013 - Created new script
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

%startRun = 124;      % Start at run x
%endRun   = 124;      % Stop at run y

startRun = 124;      % Start at run x
endRun   = 180;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ************************************************************************
%# START: START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 17.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500           = 4.30;                              % Model length waterline          (m)
MSwsa1500           = 1.501;                             % Model scale wetted surface area (m^2)
MSdraft1500         = 0.133;                             % Model draft                     (m)
MSAx1500            = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500      = 0.592;                             % Mode block coefficient          (-)
FSlwl1500           = MSlwl1500*FStoMSratio;             % Full scale length waterline     (m)
FSwsa1500           = MSwsa1500*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft1500         = MSdraft1500*FStoMSratio;           % Full scale draft                (m)

%# ------------------------------------------------------------------------
%# END: START CONSTANTS AND PARTICULARS
%# ************************************************************************


% *************************************************************************


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableTSPlot   = 0; % Time series plot and save as PNG
enableDISP     = 0; % Enable or disable values in command window
enableSaveData = 1; % Enable saving of statistics data as .DAT and .TXT

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

% Arrays; save to file
resultsArrayTSBasic    = [];
resultsArrayTSDyno     = [];
resultsArrayTSKp       = [];
resultsArrayTSPressure = [];

%w = waitbar(0,'Processed run files');
for k=startRun:endRun
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % NOTE: If statement bellow is for use in LOOPS only!!!!
    
    % Runs at respective speeds
    RunsAtFr24 = [124 125 126 127];         % i.e. Fr=0.24
    RunsAtFr26 = [128 129 130 131];         % i.e. Fr=0.26
    RunsAtFr28 = [132 133 134 135 136 179]; % i.e. Fr=0.28
    RunsAtFr30 = [180 137 138 139 140];     % i.e. Fr=0.30
    RunsAtFr32 = [141 142 143 144];         % i.e. Fr=0.32
    RunsAtFr34 = [145 146 147 148];         % i.e. Fr=0.34
    RunsAtFr36 = [149 150 151 152];         % i.e. Fr=0.36
    RunsAtFr38 = [153 154 155 156];         % i.e. Fr=0.38
    RunsAtFr40 = [157 158 159 160 ];        % i.e. Fr=0.40
    
    RunsStaticUnlocked = [161 162 163 164 165 166 167 168 169];   % i.e. Static test in middle of towing tank at every RPM with unlocked posts
    RunsStaticLocked   = [170 171 172 173 174 175 176 177 178];   % i.e. Static test in middle of towing tank at every RPM with locked posts (bollard condition)
    
    % SPEED: IF, ELSE statement
    if any(RunsAtFr24==k)
        setSpeedCond = 1;
    elseif any(RunsAtFr26==k)
        setSpeedCond = 2;
    elseif any(RunsAtFr28==k)
        setSpeedCond = 3;
    elseif any(RunsAtFr30==k)
        setSpeedCond = 4;
    elseif any(RunsAtFr32==k)
        setSpeedCond = 5;
    elseif any(RunsAtFr34==k)
        setSpeedCond = 6;
    elseif any(RunsAtFr36==k)
        setSpeedCond = 7;
    elseif any(RunsAtFr38==k)
        setSpeedCond = 8;
    elseif any(RunsAtFr40==k)
        setSpeedCond = 9;
    elseif any(RunsStaticUnlocked==k)
        setSpeedCond = 10;
    elseif any(RunsStaticLocked==k)
        setSpeedCond = 11;
    else
        %disp('OTHER');
    end
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!!!
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
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
    fPath = sprintf('_plots/%s', 'TS');
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
    
    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    % CWR Data
    [CH_0_Speed CH_0_Speed_Mean]                 = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]             = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean]             = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]                   = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
    
    % Dyno Data
    [CH_6_PortThrust CH_6_PortThrust_Mean]       = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
    [CH_7_PortTorque CH_7_PortTorque_Mean]       = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
    [CH_8_StbdThrust CH_8_StbdThrust_Mean]       = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
    [CH_9_StbdTorque CH_9_StbdTorque_Mean]       = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);
    
    % Kiel Probe Data
    [CH_10_PortKP CH_10_PortKP_Mean]             = analysis_realunits(Raw_CH_10_PortKP,CH_10_Zero,CH_11_CF);
    [CH_11_StbdKP CH_11_StbdKP_Mean]             = analysis_realunits(Raw_CH_11_StbdKP,CH_11_Zero,CH_11_CF);
    
    % Pressure Data
    [CH_12_Port_Stat_6 CH_12_Port_Stat_6_Mean]   = analysis_realunits(Raw_CH_12_Port_Stat_6,CH_12_Zero,CH_12_CF);
    [CH_13_Stbd_Stat_6 CH_13_Stbd_Stat_6_Mean]   = analysis_realunits(Raw_CH_13_Stbd_Stat_6,CH_13_Zero,CH_13_CF);
    [CH_14_Stbd_Stat_5 CH_14_Stbd_Stat_5_Mean]   = analysis_realunits(Raw_CH_14_Stbd_Stat_5,CH_14_Zero,CH_14_CF);
    [CH_15_Stbd_Stat_4 CH_15_Stbd_Stat_4_Mean]   = analysis_realunits(Raw_CH_15_Stbd_Stat_4,CH_15_Zero,CH_15_CF);
    [CH_16_Stbd_Stat_3 CH_16_Stbd_Stat_3_Mean]   = analysis_realunits(Raw_CH_16_Stbd_Stat_3,CH_16_Zero,CH_16_CF);
    [CH_17_Port_Stat_1a CH_17_Port_Stat_1a_Mean] = analysis_realunits(Raw_CH_17_Port_Stat_1a,CH_17_Zero,CH_17_CF);
    [CH_18_Stbd_Stat_1a CH_18_Stbd_Stat_1a_Mean] = analysis_realunits(Raw_CH_18_Stbd_Stat_1a,CH_18_Zero,CH_18_CF);
    
    % Change from 2 to 3 digits -------------------------------------------
    if k > 99
        runno = name(2:4);
    else
        runno = name(1:3);
    end
    
    %# ********************************************************************
    %# Speed (CWR Setup): Time Series Output
    %# ********************************************************************
    
    %# ********************************************************************
    %# PLOTTING
    %# ********************************************************************
    if enableTSPlot == 1
        
        figurename = sprintf('%s:: Speed Time Series Plot, Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        % SPEED ---------------------------------------------------------------
        subplot(2,2,1);
        
        % Axis data
        x = timeData;
        y = CH_0_Speed;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Speed}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Speed (m/s)}');
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
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % FWD LVDT ------------------------------------------------------------
        subplot(2,2,2);
        
        % Axis data
        x = timeData;
        y = CH_1_LVDTFwd;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Fwd LVDT}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf FWD LVDT (mm)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % AFT LVDT ------------------------------------------------------------
        subplot(2,2,3);
        
        % Axis data
        x = timeData;
        y = CH_2_LVDTAft;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-r',x,polyv,'-k');
        title('{\bf Aft LVDT}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf AFT LVDT (mm)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % Drag ----------------------------------------------------------------
        subplot(2,2,4);
        
        % Axis data
        x = timeData;
        y = CH_3_Drag;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-m',x,polyv,'-k');
        title('{\bf Drag}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Drag (g)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
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
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_CH_0-3_Speed_LVDT_Drag.pdf', 'TS', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_CH_0-3_Speed_LVDT_Drag.png', 'TS', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
        
    end
    
    %# ********************************************************************
    %# Command Window Output
    %# ********************************************************************
    if enableDISP == 1
        
        % Speed
        MeanData = CH_0_Speed_Mean;
        CHData   = CH_0_Speed;
        
        avgspeed = sprintf('%s:: SPEED (Averaged): %s (m/s)', runno, sprintf('%.2f',MeanData));
        minspeed = sprintf('%s:: SPEED (Minimum): %s (m/s)', runno, sprintf('%.2f',min(CHData)));
        maxspeed = sprintf('%s:: SPEED (Maximum): %s (m/s)', runno, sprintf('%.2f',max(CHData)));
        ptaspeed = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdspeed = sprintf('%s:: Standard deviation: %s (m/s)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgspeed);
        disp(minspeed);
        disp(maxspeed);
        disp(ptaspeed);
        disp(stdspeed);
        
        disp('-------------------------------------------------');
        
        % FWD LVDT
        MeanData = CH_1_LVDTFwd_Mean;
        CHData   = CH_1_LVDTFwd;
        
        avgfwdlvdt = sprintf('%s:: FWD LVDT (Averaged): %s (mm)', runno, sprintf('%.2f',MeanData));
        minfwdlvdt = sprintf('%s:: FWD LVDT (Minimum): %s (mm)', runno, sprintf('%.2f',min(CHData)));
        maxfwdlvdt = sprintf('%s:: FWD LVDT (Maximum): %s (mm)', runno, sprintf('%.2f',max(CHData)));
        ptafwdlvdt = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdfwdlvdt = sprintf('%s:: Standard deviation: %s (mm)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgfwdlvdt);
        disp(minfwdlvdt);
        disp(maxfwdlvdt);
        disp(ptafwdlvdt);
        disp(stdfwdlvdt);
        
        disp('-------------------------------------------------');
        
        % AFT LVDT
        MeanData = CH_2_LVDTAft_Mean;
        CHData   = CH_2_LVDTAft;
        
        avgaftlvdt = sprintf('%s:: AFT LVDT (Averaged): %s (mm)', runno, sprintf('%.2f',MeanData));
        minaftlvdt = sprintf('%s:: AFT LVDT (Minimum): %s (mm)', runno, sprintf('%.2f',min(CHData)));
        maxaftlvdt = sprintf('%s:: AFT LVDT (Maximum): %s (mm)', runno, sprintf('%.2f',max(CHData)));
        ptaaftlvdt = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdaftlvdt = sprintf('%s:: Standard deviation: %s (mm)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgaftlvdt);
        disp(minaftlvdt);
        disp(maxaftlvdt);
        disp(ptaaftlvdt);
        disp(stdaftlvdt);
        
        disp('-------------------------------------------------');
        
        % Drag
        MeanData = CH_3_Drag_Mean;
        CHData   = CH_3_Drag;
        
        avgdrag = sprintf('%s:: Drag (Averaged): %s (g)', runno, sprintf('%.2f',MeanData));
        mindrag = sprintf('%s:: Drag (Minimum): %s (g)', runno, sprintf('%.2f',min(CHData)));
        maxdrag = sprintf('%s:: Drag (Maximum): %s (g)', runno, sprintf('%.2f',max(CHData)));
        ptadrag = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stddrag = sprintf('%s:: Standard deviation: %s (g)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgdrag);
        disp(mindrag);
        disp(maxdrag);
        disp(ptadrag);
        disp(stddrag);
        
        disp('/////////////////////////////////////////////////');
        
    end
    
    %# ********************************************************************
    %# Save data to aray then save to file
    %# ********************************************************************
    
    %# Add results to dedicated array for simple export
    %# Results array columns:
    %[1]  Run No.
    
    %[2]  Channel
    %[3]  SPEED: Averaged              (m/s)
    %[4]  SPEED: Minimum               (m/s)
    %[5]  SPEED: Maximum               (m/s)
    %[6]  SPEED: Diff. min to avg      (percent)
    %[7]  SPEED: Standard deviation    (m/s)
    
    %[8]  Channel
    %[9]  FWD LVDT: Averaged           (mm)
    %[10] FWD LVDT: Minimum            (mm)
    %[11] FWD LVDT: Maximum            (mm)
    %[12] FWD LVDT: Diff. min to avg   (percent)
    %[13] FWD LVDT: Standard deviation (mm)
    
    %[14] Channel
    %[15] AFT LVDT: Averaged           (mm)
    %[16] AFT LVDT: Minimum            (mm)
    %[17] AFT LVDT: Maximum            (mm)
    %[18] AFT LVDT: Diff. min to avg   (percent)
    %[19] AFT LVDT: Standard deviation (mm)
    
    %[20] Channel
    %[21] DRAG: Averaged               (g)
    %[22] DRAG: Minimum                (g)
    %[23] DRAG: Maximum                (g)
    %[24] DRAG: Diff. min to avg       (percent)
    %[25] DRAG: Standard deviation     (g)
    
    %[26]  Froude length Number                     (-)
    %[27]  Speed no. (i.e. 1=0.24, 2=0.26, 3=0.28)  (-)
    
    % General data
    resultsArrayTSBasic(k, 1)  = k;
    
    % Speed
    MeanData = CH_0_Speed_Mean;
    CHData   = CH_0_Speed;
    
    resultsArrayTSBasic(k, 2)  = 0;
    resultsArrayTSBasic(k, 3)  = MeanData;
    resultsArrayTSBasic(k, 4)  = min(CHData);
    resultsArrayTSBasic(k, 5)  = max(CHData);
    resultsArrayTSBasic(k, 6)  = abs(1-(min(CHData)/MeanData));
    resultsArrayTSBasic(k, 7)  = std(CHData);
    
    % FWD LVDT
    MeanData = CH_1_LVDTFwd_Mean;
    CHData   = CH_1_LVDTFwd;
    
    resultsArrayTSBasic(k, 8)  = 1;
    resultsArrayTSBasic(k, 9)  = MeanData;
    resultsArrayTSBasic(k, 10) = min(CHData);
    resultsArrayTSBasic(k, 11) = max(CHData);
    resultsArrayTSBasic(k, 12) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSBasic(k, 13) = std(CHData);
    
    % AFT LVDT
    MeanData = CH_2_LVDTAft_Mean;
    CHData   = CH_2_LVDTAft;
    
    resultsArrayTSBasic(k, 14) = 2;
    resultsArrayTSBasic(k, 15) = MeanData;
    resultsArrayTSBasic(k, 16) = min(CHData);
    resultsArrayTSBasic(k, 17) = max(CHData);
    resultsArrayTSBasic(k, 18) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSBasic(k, 19) = std(CHData);
    
    % Drag
    MeanData = CH_3_Drag_Mean;
    CHData   = CH_3_Drag;
    
    resultsArrayTSBasic(k, 20) = 3;
    resultsArrayTSBasic(k, 21) = MeanData;
    resultsArrayTSBasic(k, 22) = min(CHData);
    resultsArrayTSBasic(k, 23) = max(CHData);
    resultsArrayTSBasic(k, 24) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSBasic(k, 25) = std(CHData);
    
    % Froude length number
    roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArrayTSBasic(k, 26)  = modelfrrounded;
    
    % Speed and depth number
    resultsArrayTSBasic(k, 27)  = setSpeedCond;
    
    
    %# ********************************************************************
    %# Dyno: Time Series Output
    %# ********************************************************************
    
    %# ********************************************************************
    %# PLOTTING
    %# ********************************************************************
    if enableTSPlot == 1
        
        figurename = sprintf('%s:: Dyno Time Series Plot, Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        % PORT: Thrust --------------------------------------------------------
        subplot(2,2,1);
        
        % Axis data
        x = timeData;
        y = CH_6_PortThrust;
        %     y = CH_7_PortTorque;
        %     y = CH_8_StbdThrust;
        %     y = CH_9_StbdTorque;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Port Thrust}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Thrust (N)}');
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
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % PORT: Torque --------------------------------------------------------
        subplot(2,2,2);
        
        % Axis data
        x = timeData;
        %     y = CH_6_PortThrust;
        y = CH_7_PortTorque;
        %     y = CH_8_StbdThrust;
        %     y = CH_9_StbdTorque;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Port Torque}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Torque (Nm)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Thrust --------------------------------------------------------
        subplot(2,2,3);
        
        % Axis data
        x = timeData;
        %     y = CH_6_PortThrust;
        %     y = CH_7_PortTorque;
        y = CH_8_StbdThrust;
        %     y = CH_9_StbdTorque;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Starboard Thrust}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Thrust (N)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Torque --------------------------------------------------------
        subplot(2,2,4);
        
        % Axis data
        x = timeData;
        %     y = CH_6_PortThrust;
        %     y = CH_7_PortTorque;
        %     y = CH_8_StbdThrust;
        y = CH_9_StbdTorque;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Starboard Torque}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Torque (Nm)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
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
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_CH_6-9_Dynamometer.pdf', 'TS', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_CH_6-9_Dynamometer.png', 'TS', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
        
    end
    
    %# ********************************************************************
    %# Command Window Output
    %# ********************************************************************
    if enableDISP == 1
        
        % Port Thrust
        MeanData = CH_6_PortThrust_Mean;
        CHData   = CH_6_PortThrust;
        
        avgportthrust = sprintf('%s:: PORT Thrust (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minportthrust = sprintf('%s:: PORT Thrust (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxportthrust = sprintf('%s:: PORT Thrust (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptaportthrust = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdportthrust = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgportthrust);
        disp(minportthrust);
        disp(maxportthrust);
        disp(ptaportthrust);
        disp(stdportthrust);
        
        disp('-------------------------------------------------');
        
        % Port Torque
        MeanData = CH_7_PortTorque_Mean;
        CHData   = CH_7_PortTorque;
        
        avgporttorque = sprintf('%s:: PORT Torque (Averaged): %s (Nm)', runno, sprintf('%.2f',MeanData));
        minporttorque = sprintf('%s:: PORT Torque (Minimum): %s (Nm)', runno, sprintf('%.2f',min(CHData)));
        maxporttorque = sprintf('%s:: PORT Torque (Maximum): %s (Nm)', runno, sprintf('%.2f',max(CHData)));
        ptaporttorque = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdporttorque = sprintf('%s:: Standard deviation: %s (Nm)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgporttorque);
        disp(minporttorque);
        disp(maxporttorque);
        disp(ptaporttorque);
        disp(stdporttorque);
        
        disp('-------------------------------------------------');
        
        % STBD Thrust
        MeanData = CH_8_StbdThrust_Mean;
        CHData   = CH_8_StbdThrust;
        
        avgstbdthrust = sprintf('%s:: STBD Thrust (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdthrust = sprintf('%s:: STBD Thrust (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdthrust = sprintf('%s:: STBD Thrust (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdthrust = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdthrust = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdthrust);
        disp(minstbdthrust);
        disp(maxstbdthrust);
        disp(ptastbdthrust);
        disp(stdstbdthrust);
        
        disp('-------------------------------------------------');
        
        % STBD Torque
        MeanData = CH_9_StbdTorque_Mean;
        CHData   = CH_9_StbdTorque;
        
        avgstbdtorque = sprintf('%s:: STBD Torque (Averaged): %s (Nm)', runno, sprintf('%.2f',MeanData));
        minstbdtorque = sprintf('%s:: STBD Torque (Minimum): %s (Nm)', runno, sprintf('%.2f',min(CHData)));
        maxstbdtorque = sprintf('%s:: STBD Torque (Maximum): %s (Nm)', runno, sprintf('%.2f',max(CHData)));
        ptastbdtorque = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdtorque = sprintf('%s:: Standard deviation: %s (Nm)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdtorque);
        disp(minstbdtorque);
        disp(maxstbdtorque);
        disp(ptastbdtorque);
        disp(stdstbdtorque);
        
        disp('/////////////////////////////////////////////////');
        
    end
    
    %# ********************************************************************
    %# Save data to aray then save to file
    %# ********************************************************************
    
    %# Add results to dedicated array for simple export
    %# Results array columns:
    %[1]  Run No.
    
    %[2]  Channel
    %[3]  PORT (Thrust): Averaged           (N)
    %[4]  PORT (Thrust): Minimum            (N)
    %[5]  PORT (Thrust): Maximum            (N)
    %[6]  PORT (Thrust): Diff. min to avg   (percent)
    %[7]  PORT (Thrust): Standard deviation (N)
    
    %[8]  Channel
    %[9]  PORT (Torque): Averaged           (Nm)
    %[10] PORT (Torque): Minimum            (Nm)
    %[11] PORT (Torque): Maximum            (Nm)
    %[12] PORT (Torque): Diff. min to avg   (percent)
    %[13] PORT (Torque): Standard deviation (Nm)
    
    %[14]  Channel
    %[15]  STBD (Thrust): Averaged           (N)
    %[16]  STBD (Thrust): Minimum            (N)
    %[17]  STBD (Thrust): Maximum            (N)
    %[18]  STBD (Thrust): Diff. min to avg   (percent)
    %[19]  STBD (Thrust): Standard deviation (N)
    
    %[20]  Channel
    %[21]  STBD (Torque): Averaged           (Nm)
    %[22]  STBD (Torque): Minimum            (Nm)
    %[23]  STBD (Torque): Maximum            (Nm)
    %[24]  STBD (Torque): Diff. min to avg   (percent)
    %[25]  STBD (Torque): Standard deviation (Nm)
    
    %[26]  Froude length Number                     (-)
    %[27]  Speed no. (i.e. 1=0.24, 2=0.26, 3=0.28)  (-)
    
    % General data
    resultsArrayTSDyno(k, 1)  = k;
    
    % Port Thrust
    MeanData = CH_6_PortThrust_Mean;
    CHData   = CH_6_PortThrust;
    
    resultsArrayTSDyno(k, 2)  = 6;
    resultsArrayTSDyno(k, 3)  = MeanData;
    resultsArrayTSDyno(k, 4)  = min(CHData);
    resultsArrayTSDyno(k, 5)  = max(CHData);
    resultsArrayTSDyno(k, 6)  = abs(1-(min(CHData)/MeanData));
    resultsArrayTSDyno(k, 7)  = std(CHData);
    
    % Port Torque
    MeanData = CH_7_PortTorque_Mean;
    CHData   = CH_7_PortTorque;
    
    resultsArrayTSDyno(k, 8)  = 7;
    resultsArrayTSDyno(k, 9)  = MeanData;
    resultsArrayTSDyno(k, 10) = min(CHData);
    resultsArrayTSDyno(k, 11) = max(CHData);
    resultsArrayTSDyno(k, 12) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSDyno(k, 13) = std(CHData);
    
    % Stbd Thrust
    MeanData = CH_8_StbdThrust_Mean;
    CHData   = CH_8_StbdThrust;
    
    resultsArrayTSDyno(k, 14)  = 8;
    resultsArrayTSDyno(k, 15) = MeanData;
    resultsArrayTSDyno(k, 16) = min(CHData);
    resultsArrayTSDyno(k, 17) = max(CHData);
    resultsArrayTSDyno(k, 18) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSDyno(k, 19) = std(CHData);
    
    % Stbd Torque
    MeanData = CH_9_StbdTorque_Mean;
    CHData   = CH_9_StbdTorque;
    
    resultsArrayTSDyno(k, 20) = 9;
    resultsArrayTSDyno(k, 21) = MeanData;
    resultsArrayTSDyno(k, 22) = min(CHData);
    resultsArrayTSDyno(k, 23) = max(CHData);
    resultsArrayTSDyno(k, 24) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSDyno(k, 25) = std(CHData);
    
    % Froude length number
    roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArrayTSDyno(k, 26)  = modelfrrounded;
    
    % Speed and depth number
    resultsArrayTSDyno(k, 27)  = setSpeedCond;
    
    
    %# ********************************************************************
    %# Kiel Probe: Time Series Output
    %# ********************************************************************
    
    %# ********************************************************************
    %# PLOTTING
    %# ********************************************************************
    if enableTSPlot == 1
        
        figurename = sprintf('%s:: Kiel Probe Time Series Plot, Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        % PORT: Thrust --------------------------------------------------------
        subplot(2,1,1);
        
        % Axis data
        x = timeData;
        y = CH_10_PortKP;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Port Kiel Probe}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Kiel Probe (V)}');
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
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % PORT: Torque --------------------------------------------------------
        subplot(2,1,2);
        
        % Axis data
        x = timeData;
        y = CH_11_StbdKP;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Stbd Kiel Probe}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Kiel Probe (V)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
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
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_CH_10-11_Kiel_Probe.pdf', 'TS', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_CH_10-11_Kiel_Probe.png', 'TS', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
        
    end
    
    %# ********************************************************************
    %# Command Window Output
    %# ********************************************************************
    if enableDISP == 1
        
        % Port Kiel Probe
        MeanData = CH_10_PortKP_Mean;
        CHData   = CH_10_PortKP;
        
        avgportkp = sprintf('%s:: PORT Kiel Probe (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minportkp = sprintf('%s:: PORT Kiel Probe (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxportkp = sprintf('%s:: PORT Kiel Probe (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptaportkp = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdportkp = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgportkp);
        disp(minportkp);
        disp(maxportkp);
        disp(ptaportkp);
        disp(stdportkp);
        
        disp('-------------------------------------------------');
        
        % Stbd Kiel Probe
        MeanData = CH_11_StbdKP_Mean;
        CHData   = CH_11_StbdKP;
        
        avgstbdkp = sprintf('%s:: STBD Kiel Probe (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdkp = sprintf('%s:: STBD Kiel Probe (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdkp = sprintf('%s:: STBD Kiel Probe (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdkp = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdkp = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdkp);
        disp(minstbdkp);
        disp(maxstbdkp);
        disp(ptastbdkp);
        disp(stdstbdkp);
        
        disp('/////////////////////////////////////////////////');
        
    end
    
    %# ********************************************************************
    %# Save data to aray then save to file
    %# ********************************************************************
    
    %# Add results to dedicated array for simple export
    %# Results array columns:
    %[1]  Run No.
    
    %[2]  Channel
    %[3]  PORT Kiel Probe: Averaged           (V)
    %[4]  PORT Kiel Probe: Minimum            (V)
    %[5]  PORT Kiel Probe: Maximum            (V)
    %[6]  PORT Kiel Probe: Diff. min to avg   (percent)
    %[7]  PORT Kiel Probe: Standard deviation (V)
    
    %[8]  Channel
    %[9]  STBD Kiel Probe: Averaged           (V)
    %[10] STBD Kiel Probe: Minimum            (V)
    %[11] STBD Kiel Probe: Maximum            (V)
    %[12] STBD Kiel Probe: Diff. min to avg   (percent)
    %[13] STBD Kiel Probe: Standard deviation (V)
    
    %[14]  Froude length Number                     (-)
    %[15]  Speed no. (i.e. 1=0.24, 2=0.26, 3=0.28)  (-)
    
    % General data
    resultsArrayTSKp(k, 1)  = k;
    
    % Port Kiel Probe
    MeanData = CH_10_PortKP_Mean;
    CHData   = CH_10_PortKP;
    
    resultsArrayTSKp(k, 2)  = 10;
    resultsArrayTSKp(k, 3)  = MeanData;
    resultsArrayTSKp(k, 4)  = min(CHData);
    resultsArrayTSKp(k, 5)  = max(CHData);
    resultsArrayTSKp(k, 6)  = abs(1-(min(CHData)/MeanData));
    resultsArrayTSKp(k, 7)  = std(CHData);
    
    % Stbd Kiel Probe
    MeanData = CH_11_StbdKP_Mean;
    CHData   = CH_11_StbdKP;
    
    resultsArrayTSKp(k, 8)  = 11;
    resultsArrayTSKp(k, 9)  = MeanData;
    resultsArrayTSKp(k, 10)  = min(CHData);
    resultsArrayTSKp(k, 11) = max(CHData);
    resultsArrayTSKp(k, 12) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSKp(k, 13) = std(CHData);
    
    % Froude length number
    roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArrayTSKp(k, 14)  = modelfrrounded;
    
    % Speed and depth number
    resultsArrayTSKp(k, 15)  = setSpeedCond;
    
    
    %# ********************************************************************
    %# Pressures: Time Series Output
    %# ********************************************************************
    
    %# ********************************************************************
    %# PLOTTING
    %# ********************************************************************
    if enableTSPlot == 1
        
        figurename = sprintf('%s:: Pressures Time Series Plot, Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        % PORT: Station 6 -----------------------------------------------------
        subplot(5,2,9);
        
        % Axis data
        x = timeData;
        y = CH_12_Port_Stat_6;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Port Station 6 Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
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
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Station 6 -----------------------------------------------------
        subplot(5,2,10);
        
        % Axis data
        x = timeData;
        y = CH_13_Stbd_Stat_6;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Stbd Station 6 Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Station 5 -----------------------------------------------------
        subplot(5,2,8);
        
        % Axis data
        x = timeData;
        y = CH_14_Stbd_Stat_5;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Stbd Station 5 Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Station 4 -----------------------------------------------------
        subplot(5,2,6);
        
        % Axis data
        x = timeData;
        y = CH_15_Stbd_Stat_4;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Stbd Station 4 Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Station 3 -----------------------------------------------------
        subplot(5,2,4);
        
        % Axis data
        x = timeData;
        y = CH_16_Stbd_Stat_3;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Stbd Station 3 Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % PORT: Station 1a -----------------------------------------------------
        subplot(5,2,1);
        
        % Axis data
        x = timeData;
        y = CH_17_Port_Stat_1a;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Port Station 1a Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % STBD: Station 4 -----------------------------------------------------
        subplot(5,2,2);
        
        % Axis data
        x = timeData;
        y = CH_18_Stbd_Stat_1a;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Stbd Station 1a Static Pressure}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Pressue (mmH20)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
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
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_CH_12-18_Pressures.pdf', 'TS', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_CH_12-18_Pressures.png', 'TS', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
        
    end
    
    %# ********************************************************************
    %# Command Window Output
    %# ********************************************************************
    if enableDISP == 1
        
        % PORT Station 6 Static Pressue
        MeanData = CH_12_Port_Stat_6_Mean;
        CHData   = CH_12_Port_Stat_6;
        
        avgportstation6 = sprintf('%s:: PORT Station 6 Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minportstation6 = sprintf('%s:: PORT Station 6 Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxportstation6 = sprintf('%s:: PORT Station 6 Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptaportstation6 = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdportstation6 = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgportstation6);
        disp(minportstation6);
        disp(maxportstation6);
        disp(ptaportstation6);
        disp(stdportstation6);
        
        disp('-------------------------------------------------');
        
        % STBD Station 6 Static Pressue
        MeanData = CH_13_Stbd_Stat_6_Mean;
        CHData   = CH_13_Stbd_Stat_6;
        
        avgstbdstation6 = sprintf('%s:: STBD Station 6 Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdstation6 = sprintf('%s:: STBD Station 6 Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdstation6 = sprintf('%s:: STBD Station 6 Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdstation6 = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdstation6 = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdstation6);
        disp(minstbdstation6);
        disp(maxstbdstation6);
        disp(ptastbdstation6);
        disp(stdstbdstation6);
        
        disp('-------------------------------------------------');
        
        % STBD Station 5 Static Pressue
        MeanData = CH_14_Stbd_Stat_5_Mean;
        CHData   = CH_14_Stbd_Stat_5;
        
        avgstbdstation5 = sprintf('%s:: STBD Station 5 Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdstation5 = sprintf('%s:: STBD Station 5 Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdstation5 = sprintf('%s:: STBD Station 5 Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdstation5 = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdstation5 = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdstation5);
        disp(minstbdstation5);
        disp(maxstbdstation5);
        disp(ptastbdstation5);
        disp(stdstbdstation5);
        
        disp('-------------------------------------------------');
        
        % STBD Station 4 Static Pressue
        MeanData = CH_15_Stbd_Stat_4_Mean;
        CHData   = CH_15_Stbd_Stat_4;
        
        avgstbdstation4 = sprintf('%s:: STBD Station 4 Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdstation4 = sprintf('%s:: STBD Station 4 Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdstation4 = sprintf('%s:: STBD Station 4 Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdstation4 = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdstation4 = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdstation4);
        disp(minstbdstation4);
        disp(maxstbdstation4);
        disp(ptastbdstation4);
        disp(stdstbdstation4);
        
        disp('-------------------------------------------------');
        
        % STBD Station 3 Static Pressue
        MeanData = CH_16_Stbd_Stat_3_Mean;
        CHData   = CH_16_Stbd_Stat_3;
        
        avgstbdstation3 = sprintf('%s:: STBD Station 3 Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdstation3 = sprintf('%s:: STBD Station 3 Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdstation3 = sprintf('%s:: STBD Station 3 Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdstation3 = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdstation3 = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdstation3);
        disp(minstbdstation3);
        disp(maxstbdstation3);
        disp(ptastbdstation3);
        disp(stdstbdstation3);
        
        disp('-------------------------------------------------');
        
        % PORT Station 1a Static Pressue
        MeanData = CH_17_Port_Stat_1a_Mean;
        CHData   = CH_17_Port_Stat_1a;
        
        avgportstation1a = sprintf('%s:: PORT Station 1a Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minportstation1a = sprintf('%s:: PORT Station 1a Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxportstation1a = sprintf('%s:: PORT Station 1a Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptaportstation1a = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdportstation1a = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgportstation1a);
        disp(minportstation1a);
        disp(maxportstation1a);
        disp(ptaportstation1a);
        disp(stdportstation1a);
        
        disp('-------------------------------------------------');
        
        % STBD Station 1a Static Pressue
        MeanData = CH_18_Stbd_Stat_1a_Mean;
        CHData   = CH_18_Stbd_Stat_1a;
        
        avgstbdstation1a = sprintf('%s:: STBD Station 1a Static Pressue (Averaged): %s (N)', runno, sprintf('%.2f',MeanData));
        minstbdstation1a = sprintf('%s:: STBD Station 1a Static Pressue (Minimum): %s (N)', runno, sprintf('%.2f',min(CHData)));
        maxstbdstation1a = sprintf('%s:: STBD Station 1a Static Pressue (Maximum): %s (N)', runno, sprintf('%.2f',max(CHData)));
        ptastbdstation1a = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
        stdstbdstation1a = sprintf('%s:: Standard deviation: %s (N)', runno, sprintf('%.4f',std(CHData)));
        
        disp(avgstbdstation1a);
        disp(minstbdstation1a);
        disp(maxstbdstation1a);
        disp(ptastbdstation1a);
        disp(stdstbdstation1a);
        
        disp('/////////////////////////////////////////////////');
        
    end
    
    %# ********************************************************************
    %# Save data to aray then save to file
    %# ********************************************************************
    
    %# Add results to dedicated array for simple export
    %# Results array columns:
    %[1]  Run No.
    
    %[2]  Channel
    %[3]  PORT Station 6 Static Pressue: Averaged           (mmH2O)
    %[4]  PORT Station 6 Static Pressue: Minimum            (mmH2O)
    %[5]  PORT Station 6 Static Pressue: Maximum            (mmH2O)
    %[6]  PORT Station 6 Static Pressue: Diff. min to avg   (percent)
    %[7]  PORT Station 6 Static Pressue: Standard deviation (mmH2O)
    
    %[8]  Channel
    %[9]  STBD Station 6 Static Pressue: Averaged           (mmH2O)
    %[10] STBD Station 6 Static Pressue: Minimum            (mmH2O)
    %[11] STBD Station 6 Static Pressue: Maximum            (mmH2O)
    %[12] STBD Station 6 Static Pressue: Diff. min to avg   (percent)
    %[13] STBD Station 6 Static Pressue: Standard deviation (mmH2O)
    
    %[14] Channel
    %[15] STBD Station 5 Static Pressue: Averaged           (mmH2O)
    %[16] STBD Station 5 Static Pressue: Minimum            (mmH2O)
    %[17] STBD Station 5 Static Pressue: Maximum            (mmH2O)
    %[18] STBD Station 5 Static Pressue: Diff. min to avg   (percent)
    %[19] STBD Station 5 Static Pressue: Standard deviation (mmH2O)
    
    %[20] Channel
    %[21] STBD Station 4 Static Pressue: Averaged           (mmH2O)
    %[22] STBD Station 4 Static Pressue: Minimum            (mmH2O)
    %[23] STBD Station 4 Static Pressue: Maximum            (mmH2O)
    %[24] STBD Station 4 Static Pressue: Diff. min to avg   (percent)
    %[25] STBD Station 4 Static Pressue: Standard deviation (mmH2O)
    
    %[26] Channel
    %[27] STBD Station 3 Static Pressue: Averaged           (mmH2O)
    %[28] STBD Station 3 Static Pressue: Minimum            (mmH2O)
    %[29] STBD Station 3 Static Pressue: Maximum            (mmH2O)
    %[30] STBD Station 3 Static Pressue: Diff. min to avg   (percent)
    %[31] STBD Station 3 Static Pressue: Standard deviation (mmH2O)
    
    %[32] Channel
    %[33] PORT Station 1a Static Pressue: Averaged           (mmH2O)
    %[34] PORT Station 1a Static Pressue: Minimum            (mmH2O)
    %[35] PORT Station 1a Static Pressue: Maximum            (mmH2O)
    %[36] PORT Station 1a Static Pressue: Diff. min to avg   (percent)
    %[37] PORT Station 1a Static Pressue: Standard deviation (mmH2O)
    
    %[38] Channel
    %[39] STBD Station 1a Static Pressue: Averaged           (mmH2O)
    %[40] STBD Station 1a Static Pressue: Minimum            (mmH2O)
    %[41] STBD Station 1a Static Pressue: Maximum            (mmH2O)
    %[42] STBD Station 1a Static Pressue: Diff. min to avg   (percent)
    %[43] STBD Station 1a Static Pressue: Standard deviation (mmH2O)
    
    %[44]  Froude length Number                     (-)
    %[45]  Speed no. (i.e. 1=0.24, 2=0.26, 3=0.28)  (-)
    
    % General data
    resultsArrayTSPressure(k, 1)  = k;
    
    % PORT Station 6 Static Pressue
    MeanData = CH_12_Port_Stat_6_Mean;
    CHData   = CH_12_Port_Stat_6;
    
    resultsArrayTSPressure(k, 2)  = 12;
    resultsArrayTSPressure(k, 3)  = MeanData;
    resultsArrayTSPressure(k, 4)  = min(CHData);
    resultsArrayTSPressure(k, 5)  = max(CHData);
    resultsArrayTSPressure(k, 6)  = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 7)  = std(CHData);
    
    % STBD Station 6 Static Pressue
    MeanData = CH_13_Stbd_Stat_6_Mean;
    CHData   = CH_13_Stbd_Stat_6;
    
    resultsArrayTSPressure(k, 8)  = 13;
    resultsArrayTSPressure(k, 9)  = MeanData;
    resultsArrayTSPressure(k, 10) = min(CHData);
    resultsArrayTSPressure(k, 11) = max(CHData);
    resultsArrayTSPressure(k, 12) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 13) = std(CHData);
    
    % STBD Station 5 Static Pressue
    MeanData = CH_14_Stbd_Stat_5_Mean;
    CHData   = CH_14_Stbd_Stat_5;
    
    resultsArrayTSPressure(k, 14) = 14;
    resultsArrayTSPressure(k, 15) = MeanData;
    resultsArrayTSPressure(k, 16) = min(CHData);
    resultsArrayTSPressure(k, 17) = max(CHData);
    resultsArrayTSPressure(k, 18) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 19) = std(CHData);
    
    % STBD Station 4 Static Pressue
    MeanData = CH_15_Stbd_Stat_4_Mean;
    CHData   = CH_15_Stbd_Stat_4;
    
    resultsArrayTSPressure(k, 20) = 15;
    resultsArrayTSPressure(k, 21) = MeanData;
    resultsArrayTSPressure(k, 22) = min(CHData);
    resultsArrayTSPressure(k, 23) = max(CHData);
    resultsArrayTSPressure(k, 24) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 25) = std(CHData);
    
    % STBD Station 3 Static Pressue
    MeanData = CH_16_Stbd_Stat_3_Mean;
    CHData   = CH_16_Stbd_Stat_3;
    
    resultsArrayTSPressure(k, 26) = 16;
    resultsArrayTSPressure(k, 27) = MeanData;
    resultsArrayTSPressure(k, 28) = min(CHData);
    resultsArrayTSPressure(k, 29) = max(CHData);
    resultsArrayTSPressure(k, 30) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 31) = std(CHData);
    
    % PORT Station 1a Static Pressue
    MeanData = CH_17_Port_Stat_1a_Mean;
    CHData   = CH_17_Port_Stat_1a;
    
    resultsArrayTSPressure(k, 32) = 17;
    resultsArrayTSPressure(k, 33) = MeanData;
    resultsArrayTSPressure(k, 34) = min(CHData);
    resultsArrayTSPressure(k, 35) = max(CHData);
    resultsArrayTSPressure(k, 36) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 37) = std(CHData);
    
    % STBD Station 1a Static Pressue
    MeanData = CH_18_Stbd_Stat_1a_Mean;
    CHData   = CH_18_Stbd_Stat_1a;
    
    resultsArrayTSPressure(k, 38) = 18;
    resultsArrayTSPressure(k, 39) = MeanData;
    resultsArrayTSPressure(k, 40) = min(CHData);
    resultsArrayTSPressure(k, 41) = max(CHData);
    resultsArrayTSPressure(k, 42) = abs(1-(min(CHData)/MeanData));
    resultsArrayTSPressure(k, 43) = std(CHData);
    
    % Froude length number
    roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArrayTSPressure(k, 44)  = modelfrrounded;
    
    % Speed and depth number
    resultsArrayTSPressure(k, 45)  = setSpeedCond;
    
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

% Basic data: Speed, LVDTs, Drag
M = resultsArrayTSBasic;
M = M(any(M,2),:);                            % Remove zero rows
csvwrite('resultsArrayTSBasic.dat', M)        % Export matrix M to a file delimited by the comma character
disp('Saved: resultsArrayTSBasic.dat');       % Display message in command window

% Dynamometer data: Thrust and Torque
M = resultsArrayTSDyno;
M = M(any(M,2),:);                            % Remove zero rows
csvwrite('resultsArrayTSDyno.dat', M)         % Export matrix M to a file delimited by the comma character
disp('Saved: resultsArrayTSDyno.dat');        % Display message in command window

% Kiel probe data
M = resultsArrayTSKp;
M = M(any(M,2),:);                            % Remove zero rows
csvwrite('resultsArrayTSKp.dat', M)           % Export matrix M to a file delimited by the comma character
disp('Saved: resultsArrayTSKp.dat');          % Display message in command window

% Pressure related data
M = resultsArrayTSPressure;
M = M(any(M,2),:);                            % Remove zero rows
csvwrite('resultsArrayTSPressure.dat', M)     % Export matrix M to a file delimited by the comma character
disp('Saved: resultsArrayTSPressure.dat');    % Display message in command window

%dlmwrite('resultsArrayTS.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
