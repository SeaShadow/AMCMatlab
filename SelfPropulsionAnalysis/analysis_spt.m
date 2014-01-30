%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis
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
%#               then use --> analysis_calib_plot.m
%#
%#               => analysis_rt.m    Flow visualistation and resistance
%#                                    ==> Creates resultsArrayRT.dat
%#
%#               then use --> analysis_rt_plot.m
%#
%#               => analysis_bl.m    Bondary layer measurements
%#                                    ==> Creates resultsArrayBL.dat
%#
%#               then use --> analysis_bl_plot.m
%#
%#               => analysis_spp.m    Self-propulsion points
%#                                    ==> Creates resultsArraySPP.dat
%#
%#               then use --> analysis_spp_plot.m
%#
%#               => analysis_spt.m    Self-propulsion test
%#                                    ==> Creates resultsArraySPT.dat
%#
%#               then use --> analysis_spt_plot.m
%#
%#               => analysis_ts.m    Time series data
%#                                    ==> Creates resultsArrayTS.dat
%#
%#               then use --> analysis_ts_plot.m
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  12/11/2013 - Created new script
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

%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 17.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
modelkinviscosity   = (((0.585*10^(-3))*(ttwatertemp-12)-0.03361)*(ttwatertemp-12)+1.235)*10^(-6); % Model scale kinetic viscosity at X (see ttwatertemp) degrees following ITTC (m2/s)
fullscalekinvi      = 0.000001034;            % Full scale kinetic viscosity     (m^2/s)
freshwaterdensity   = 1000;                   % Model scale water density        (Kg/m^3)
saltwaterdensity    = 1025;                   % Salt water scale water density   (Kg/m^3)
distbetwposts       = 1150;                   % Distance between carriage posts  (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio  (-)

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
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

%startRun = 119;      % Start at run x
%endRun   = 119;      % Stop at run y

startRun = 111;      % Start at run x
endRun   = 180;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% RunNosTest = [1:8];          % Prelimnary testing only
% RunNosPort = [9:29 59:63];   % Port propulsion system only
% RunNosComb = [30:50 55:58];  % Combined propulsion systems
% RunNosStbd = [64:86];        % Starboard propulsion system only
% RunNosStat = [51:53];        % Static flow rates due to head difference of waterlevels of basin and bucket

% NOTE: If statement bellow is for use in LOOPS only!!!!
%
% if any(RunNosTest==k)
%     disp('TEST');
% elseif any(RunNosPort==k)
%     disp('PORT');
% elseif any(RunNosComb==k)
%     disp('COMBINED');    
% elseif any(RunNosStbd==k)
%     disp('STBD');    
% elseif any(RunNosStat==k)
%     disp('STATIC');    
% else
%     disp('OTHER');        
% end

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!!!
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

resultsArraySPT = [];
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
%     fPath = sprintf('_plots/%s', name(1:3));
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else
%         mkdir(fPath);
%     end
    
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
    
    % CUSTOM: If static pressure as mmH20 use:
    setPaCF = 714.29;
    CH_12_CF = setPaCF;
    CH_13_CF = setPaCF;
    CH_14_CF = setPaCF;
    CH_15_CF = setPaCF;
    CH_16_CF = setPaCF;
    CH_17_CF = setPaCF;
    CH_18_CF = setPaCF;    
    
    % CUSTOM: If static pressure as pascal (PA) use:
%     setPaCF = 7004.75;
%     CH_12_CF = setPaCF;
%     CH_13_CF = setPaCF;
%     CH_14_CF = setPaCF;
%     CH_15_CF = setPaCF;
%     CH_16_CF = setPaCF;
%     CH_17_CF = setPaCF;
%     CH_18_CF = setPaCF;
    
    % CUSTOM: If static pressure as PSI use:
%     setPaCF = 1.016;
%     CH_12_CF = setPaCF;
%     CH_13_CF = setPaCF;
%     CH_14_CF = setPaCF;
%     CH_15_CF = setPaCF;
%     CH_16_CF = setPaCF;
%     CH_17_CF = setPaCF;
%     CH_18_CF = setPaCF;

    % CUSTOM: If static pressure as BAR use:
%     setPaCF = 0.07;
%     CH_12_CF = setPaCF;
%     CH_13_CF = setPaCF;
%     CH_14_CF = setPaCF;
%     CH_15_CF = setPaCF;
%     CH_16_CF = setPaCF;
%     CH_17_CF = setPaCF;
%     CH_18_CF = setPaCF;

    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    [CH_0_Speed CH_0_Speed_Mean]                 = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]             = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean]             = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]                   = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);       

    [RPMStbd RPMPort]                            = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);     
    
    [CH_6_PortThrust CH_6_PortThrust_Mean]       = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
    [CH_7_PortTorque CH_7_PortTorque_Mean]       = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
    [CH_8_StbdThrust CH_8_StbdThrust_Mean]       = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
    [CH_9_StbdTorque CH_9_StbdTorque_Mean]       = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);
    
    [CH_12_Port_Stat_6 CH_12_Port_Stat_6_Mean]   = analysis_realunits(Raw_CH_12_Port_Stat_6,CH_12_Zero,CH_12_CF);
    [CH_13_Stbd_Stat_6 CH_13_Stbd_Stat_6_Mean]   = analysis_realunits(Raw_CH_13_Stbd_Stat_6,CH_13_Zero,CH_13_CF);
    [CH_14_Stbd_Stat_5 CH_14_Stbd_Stat_5_Mean]   = analysis_realunits(Raw_CH_14_Stbd_Stat_5,CH_14_Zero,CH_14_CF);
    [CH_15_Stbd_Stat_4 CH_15_Stbd_Stat_4_Mean]   = analysis_realunits(Raw_CH_15_Stbd_Stat_4,CH_15_Zero,CH_15_CF);
    [CH_16_Stbd_Stat_3 CH_16_Stbd_Stat_3_Mean]   = analysis_realunits(Raw_CH_16_Stbd_Stat_3,CH_16_Zero,CH_16_CF);
    [CH_17_Port_Stat_1a CH_17_Port_Stat_1a_Mean] = analysis_realunits(Raw_CH_17_Port_Stat_1a,CH_17_Zero,CH_17_CF);
    [CH_18_Stbd_Stat_1a CH_18_Stbd_Stat_1a_Mean] = analysis_realunits(Raw_CH_18_Stbd_Stat_1a,CH_18_Zero,CH_18_CF);
    
    
    % /////////////////////////////////////////////////////////////////////
    % DISPLAY RESULTS
    % /////////////////////////////////////////////////////////////////////
    
    %# Add results to dedicated array for simple export
    %# Results array columns: 
        %[1]  Run No.
        %[2]  FS                   (Hz)
        %[3]  No. of samples       (-)
        %[4]  Record time          (s)
        %[5]  Speed                (m/s)
        %[6]  Forward LVDT         (mm)
        %[7]  Aft LVDT             (mm)
        %[8]  Drag                 (g)
        %[9]  Froude length number (-)
        
        %[9]  Shaft Speed PORT     (RPM)
        %[10] Shaft Speed STBD     (RPM)
        %[11] Thrust PORT          (N)
        %[12] Torque PORT          (Nm)
        %[13] Thrust STBD          (N)
        %[14] Torque STBD          (Nm)        
        %[15] Kiel probe PORT      (V)
        %[16] Kiel probe STBD      (V)
        %[17] PORT static pressure ITTC station 6   (mmH20)
        %[18] STBD static pressure ITTC station 6   (mmH20)
        %[19] STBD static pressure ITTC station 5   (mmH20)
        %[20] STBD static pressure ITTC station 4   (mmH20)
        %[21] STBD static pressure ITTC station 3   (mmH20)
        %[22] PORT static pressure ITTC station 1a  (mmH20)
        %[23] STBD static pressure ITTC station 1a  (mmH20)
    
    % General data
    resultsArraySPT(k, 1)  = k;                                                  % Run No.
    resultsArraySPT(k, 2)  = round(length(timeData) / timeData(end));            % FS (Hz)    
    resultsArraySPT(k, 3)  = length(timeData);                                   % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArraySPT(k, 4)  = round(recordTime);                                  % Record time in seconds
    
    % Resistance data
    resultsArraySPT(k, 5)  = CH_0_Speed_Mean;                                    % Speed (m/s)
    resultsArraySPT(k, 6)  = CH_1_LVDTFwd_Mean;                                  % Forward LVDT (mm)
    resultsArraySPT(k, 7)  = CH_2_LVDTAft_Mean;                                  % Aft LVDT (mm)
    resultsArraySPT(k, 8)  = CH_3_Drag_Mean;                                     % Drag (g)

    roundedspeed   = str2num(sprintf('%.2f',resultsArraySPT(k, 5)));                % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArraySPT(k, 9) = modelfrrounded;                                         % Froude length number (adjusted for Lwl change at different conditions) (-)    
    
    % RPM data
    resultsArraySPT(k, 10)  = RPMPort;                                            % Shaft Speed PORT (RPM)
    resultsArraySPT(k, 11) = RPMStbd;                                            % Shaft Speed STBD (RPM)

    % Thrust and torque data
    resultsArraySPT(k, 12) = abs(CH_6_PortThrust_Mean/1000)*9.806;               % Thrust PORT (N)
    resultsArraySPT(k, 13) = CH_7_PortTorque_Mean;                               % Torque PORT (Nm)
    resultsArraySPT(k, 14) = abs(CH_8_StbdThrust_Mean/1000)*9.806;               % Thrust STBD (N)
    resultsArraySPT(k, 15) = CH_9_StbdTorque_Mean;                               % Torque STBD (Nm)  
    
    % Kiel probe data
    resultsArraySPT(k, 16)  = mean(Raw_CH_10_PortKP);                            % Kiel probe PORT (V)
    resultsArraySPT(k, 17)  = mean(Raw_CH_11_StbdKP);                            % Kiel probe STBD (V)    
    
    % Static pressure data
    resultsArraySPT(k, 18)  = CH_12_Port_Stat_6_Mean;                            % PORT static pressure ITTC station 6 (mmH20)
    resultsArraySPT(k, 19)  = CH_13_Stbd_Stat_6_Mean;                            % STBD static pressure ITTC station 6 (mmH20)
    resultsArraySPT(k, 20)  = CH_14_Stbd_Stat_5_Mean;                            % STBD static pressure ITTC station 5 (mmH20)
    resultsArraySPT(k, 21)  = CH_15_Stbd_Stat_4_Mean;                            % STBD static pressure ITTC station 4 (mmH20)
    resultsArraySPT(k, 22)  = CH_16_Stbd_Stat_3_Mean;                            % STBD static pressure ITTC station 3 (mmH20)
    resultsArraySPT(k, 23)  = CH_17_Port_Stat_1a_Mean;                           % PORT static pressure ITTC station 1a (mmH20)
    resultsArraySPT(k, 24)  = CH_18_Stbd_Stat_1a_Mean;                           % STBD static pressure ITTC station 1a (mmH20)
    
    %# Prepare strings for display ----------------------------------------
    
    % Change from 2 to 3 digits
    if k > 99
        name = name(1:4);
    else
        name = name(1:3);
    end
    
    froudeno         = sprintf('%s:: Froude length number: %s [-]', name, sprintf('%.2f',modelfrrounded));
    
    kielprobeport    = sprintf('%s:: Kiel probe PORT (mean): %s [V]', name, sprintf('%.2f',mean(Raw_CH_10_PortKP)));
    kielprobestbd    = sprintf('%s:: Kiel probe STBD (mean): %s [V]', name, sprintf('%.2f',mean(Raw_CH_10_PortKP)));

    thrustport       = sprintf('%s:: Thrust PORT (mean): %s [N]', name, sprintf('%.2f',abs(((CH_6_PortThrust_Mean/1000)*9.806))));
    thruststbd       = sprintf('%s:: Thrust STBD (mean): %s [N]', name, sprintf('%.2f',abs(((CH_8_StbdThrust_Mean/1000)*9.806))));
    
    torqueport       = sprintf('%s:: Torque PORT (mean): %s [Nm]', name, sprintf('%.2f',abs(CH_7_PortTorque_Mean)));    
    torquestbd       = sprintf('%s:: Torque STBD (mean): %s [Nm]', name, sprintf('%.2f',abs(CH_9_StbdTorque_Mean)));

    shaftrpmport     = sprintf('%s:: Shaft speed PORT: %s [RPM]', name, sprintf('%.0f',RPMPort));  
    shaftrpmstbd     = sprintf('%s:: Shaft speed STBD: %s [RPM]', name, sprintf('%.0f',RPMStbd));

    %# Display strings ---------------------------------------------------
 
    disp(froudeno);
    
    disp(kielprobeport);
    disp(kielprobestbd);

    disp(thrustport);
    disp(thruststbd);

    disp(torqueport);
    disp(torquestbd);

    disp(shaftrpmport);
    disp(shaftrpmstbd);

    disp('/////////////////////////////////////////////////');
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
resultsArraySPT = resultsArraySPT(any(resultsArraySPT,2),:);           % Remove zero rows
M = resultsArraySPT;
%M = M(any(M,2),:);                                                    % remove zero rows only in resultsArraySPP text file
csvwrite('resultsArraySPT.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('resultsArraySPT.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer