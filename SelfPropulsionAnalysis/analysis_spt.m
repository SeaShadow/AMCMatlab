%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 26, 2014
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
%#                                    ==> Creates resultsArraySPT.dat
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


% *************************************************************************
% Start PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

% Profiler
enableProfiler              = 0;    % Use profiler to show execution times

% Decide if June 2013 or September 2014 data is used for calculations
%enableSept2014FRMValues     = 1;    % Use enable uses flow rate values established September 2014

% Plot titles, colours, etc.
enablePlotMainTitle         = 0;    % Show plot title in saved file
enablePlotTitle             = 0;    % Show plot title above plot
enableBlackAndWhitePlot     = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot       = 1;    % Show plots scale to A4 size

% Error plots
enableErrorStDevPlot        = 0;    % Show error plots based on StDev

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox'));
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

% -------------------------------------------------------------------------
% End PLOT SWITCHES
% *************************************************************************


%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'Waterjet Self-Propulsion Test';


% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile on
end


%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory


%# ************************************************************************
%# Start DAQ related settings
%# ------------------------------------------------------------------------

Fs = 800;                               % DAQ sampling frequency = 200Hz

%# ------------------------------------------------------------------------
%# End DAQ related settings
%# ************************************************************************


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 18.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

% Waterjet constants (FS = full scale and MS = model scale)

% Pump diameter, Dp, (m)
FS_PumpDia     = 1.2;
%MS_PumpDia     = 0.056;
MS_PumpDia     = FS_PumpDia/FStoMSratio;

% Effective nozzle diameter, Dn, (m)
FS_EffNozzDia  = 0.72;
%MS_EffNozzDia  = 0.033;
MS_EffNozzDia  = FS_EffNozzDia/FStoMSratio;

% Nozzle area, An, (m^2)
FS_NozzArea    = 0.4072;
%MS_NozzArea    = 0.00087;
MS_NozzArea    = ((FS_EffNozzDia/2)/FStoMSratio)^2*pi;

% Impeller diameter, Di, (m)
FS_ImpDia      = 1.582;
%MS_ImpDia      = 0.073;
MS_ImpDia      = FS_ImpDia/FStoMSratio;

% Pump inlet area, A4, (m^2)
FS_PumpInlArea = 1.99;
MS_PumpInlArea = 0.004;

% Pump maximum area, A5, (m^2)
FS_PumpMaxArea = 0.67;
MS_PumpMaxArea = 0.001;

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
%# ////////////////////////////////////////////////////////////////////////

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 39;  % Number of headerlines to data
headerlinesZeroAndCalib = 33;  % Number of headerlines to zero and calibration factors


%# ------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 0;


%# ************************************************************************
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

%startRun = 119;      % Start at run x
%endRun   = 119;      % Stop at run y

startRun = 124;      % Start at run x
endRun   = 160;      % Stop at run y

%startRun = 125;      % Start at run x
%endRun   = 131;      % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# ************************************************************************


%# ************************************************************************
%# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS
%# ------------------------------------------------------------------------

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

%# ------------------------------------------------------------------------
%# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS
%# ************************************************************************


%# ************************************************************************
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
%# ************************************************************************


%# ************************************************************************
%# Start CREATE PLOTS AND RUN DIRECTORY
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# SPP directory ----------------------------------------------------------
setDirName = '_plots/SPT';

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
%# End CREATE PLOTS AND RUN DIRECTORY
%# ************************************************************************


%# ************************************************************************
%# Start Speed Run Numbers
%# ------------------------------------------------------------------------

speed1RunNo = 125:127;
speed2RunNo = 129:131;
speed3RunNo = 133:136;
speed4RunNo = 138:140;
speed5RunNo = 142:144;
speed6RunNo = 146:148;
speed7RunNo = 150:152;
speed8RunNo = 154:156;
speed9RunNo = 158:160;

%# ------------------------------------------------------------------------
%# End Speed Run Numbers
%# ************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

% If resultsArraySPT.dat does NOT EXIST loop through DAQ files
if exist('resultsArraySPT.dat', 'file') == 0
    
    resultsArraySPT        = [];
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
        
        %# ----------------------------------------------------------------
        %# Real units
        %# ----------------------------------------------------------------
        
        % Standard resistance components
        [CH_0_Speed CH_0_Speed_Mean]                 = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
        [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]             = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
        [CH_2_LVDTAft CH_2_LVDTAft_Mean]             = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
        [CH_3_Drag CH_3_Drag_Mean]                   = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
        
        % Shaft speed
        [RPMStbd RPMPort]                            = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);
        
        % Thrust and torque
        [CH_6_PortThrust CH_6_PortThrust_Mean]       = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
        [CH_7_PortTorque CH_7_PortTorque_Mean]       = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
        [CH_8_StbdThrust CH_8_StbdThrust_Mean]       = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
        [CH_9_StbdTorque CH_9_StbdTorque_Mean]       = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);
        
        % Static pressures
        [CH_12_Port_Stat_6 CH_12_Port_Stat_6_Mean]   = analysis_realunits(Raw_CH_12_Port_Stat_6,CH_12_Zero,CH_12_CF);
        [CH_13_Stbd_Stat_6 CH_13_Stbd_Stat_6_Mean]   = analysis_realunits(Raw_CH_13_Stbd_Stat_6,CH_13_Zero,CH_13_CF);
        [CH_14_Stbd_Stat_5 CH_14_Stbd_Stat_5_Mean]   = analysis_realunits(Raw_CH_14_Stbd_Stat_5,CH_14_Zero,CH_14_CF);
        [CH_15_Stbd_Stat_4 CH_15_Stbd_Stat_4_Mean]   = analysis_realunits(Raw_CH_15_Stbd_Stat_4,CH_15_Zero,CH_15_CF);
        [CH_16_Stbd_Stat_3 CH_16_Stbd_Stat_3_Mean]   = analysis_realunits(Raw_CH_16_Stbd_Stat_3,CH_16_Zero,CH_16_CF);
        [CH_17_Port_Stat_1a CH_17_Port_Stat_1a_Mean] = analysis_realunits(Raw_CH_17_Port_Stat_1a,CH_17_Zero,CH_17_CF);
        [CH_18_Stbd_Stat_1a CH_18_Stbd_Stat_1a_Mean] = analysis_realunits(Raw_CH_18_Stbd_Stat_1a,CH_18_Zero,CH_18_CF);
        
        
        % /////////////////////////////////////////////////////////////////
        % DISPLAY RESULTS
        % /////////////////////////////////////////////////////////////////
        
        %# Add results to dedicated array for simple export
        %# Results array columns:
        
        %[1]  Run No.                               (-)
        %[2]  FS                                    (Hz)
        %[3]  No. of samples                        (-)
        %[4]  Record time                           (s)
        %[5]  Speed                                 (m/s)
        %[6]  Forward LVDT                          (mm)
        %[7]  Aft LVDT                              (mm)
        %[8]  Drag                                  (g)
        %[9]  Froude length number                  (-)
        
        %[10] Shaft Speed PORT                      (RPM)
        %[11] Shaft Speed STBD                      (RPM)
        
        %[12] Thrust PORT                           (N)
        %[13] Torque PORT                           (Nm)
        
        %[14] Thrust STBD                           (N)
        %[15] Torque STBD                           (Nm)
        
        %[16] Kiel probe PORT                       (V)
        %[17] Kiel probe STBD                       (V)
        
        %[18] PORT static pressure ITTC station 6   (mmH20)
        %[19] STBD static pressure ITTC station 6   (mmH20)
        %[20] STBD static pressure ITTC station 5   (mmH20)
        %[21] STBD static pressure ITTC station 4   (mmH20)
        %[22] STBD static pressure ITTC station 3   (mmH20)
        %[23] PORT static pressure ITTC station 1a  (mmH20)
        %[24] STBD static pressure ITTC station 1a  (mmH20)
        
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
        resultsArraySPT(k, 10) = RPMPort;                                            % Shaft Speed PORT (RPM)
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
        
        %# Prepare strings for display ------------------------------------
        
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
        
        %# Display strings ------------------------------------------------
        
        disp(froudeno);
        
        disp(kielprobeport);
        disp(kielprobestbd);
        
        disp(thrustport);
        disp(thruststbd);
        
        disp(torqueport);
        disp(torquestbd);
        
        disp(shaftrpmport);
        disp(shaftrpmstbd);
        
        disp('-----------------------------------------------------------------');
    end % loop
    
    %# ********************************************************************
    %# Start Write results to CVS
    %# --------------------------------------------------------------------
    resultsArraySPT = resultsArraySPT(any(resultsArraySPT,2),:);           % Remove zero rows
    M = resultsArraySPT;
    %M = M(any(M,2),:);                                                    % remove zero rows only in resultsArraySPT text file
    csvwrite('resultsArraySPT.dat', M)                                     % Export matrix M to a file delimited by the comma character
    %dlmwrite('resultsArraySPT.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
    %# --------------------------------------------------------------------
    % End Write results to CVS
    %# ********************************************************************
    
else
    
    %# As we know that resultsArraySPT.dat exits, read it
    resultsArraySPT = csvread('resultsArraySPT.dat');
    
    %# Remove zero rows
    resultsArraySPT(all(resultsArraySPT==0,2),:)=[];
    [mspt,nspt] = size(resultsArraySPT);

end % exist resultsArraySPT.dat


%# ************************************************************************
%# 0. Create resultsArraySPT_R
%# ************************************************************************
resultsArraySPT_R = [];
for kl=1:9
    resultsArraySPT_R{kl} = [];
end
for k=startRun:endRun
    
    if ismember(k,speed1RunNo)
        speedNo = 1;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed2RunNo)
        speedNo = 2;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed3RunNo)
        speedNo = 3;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed4RunNo)
        speedNo = 4;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed5RunNo)
        speedNo = 5;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed6RunNo)
        speedNo = 6;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed7RunNo)
        speedNo = 7;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed8RunNo)
        speedNo = 8;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    elseif ismember(k,speed9RunNo)
        speedNo = 9;
        [m,n] = size(resultsArraySPT_R{speedNo});
        [~,indx] = ismember(k,resultsArraySPT);
        resultsArraySPT_R{speedNo}(m+1,:) = resultsArraySPT(indx,:);
    end
    
end % loop

% Average repeated runs ---------------------------------------------------
resultsArraySPT_RAvg = [];
%# resultsArraySPT_RAvg columns:

%[1]  Run No.                               (-)
%[2]  FS                                    (Hz)
%[3]  No. of samples                        (-)
%[4]  Record time                           (s)
%[5]  Speed                                 (m/s)
%[6]  Forward LVDT                          (mm)
%[7]  Aft LVDT                              (mm)
%[8]  Drag                                  (g)
%[9]  Froude length number                  (-)

%[10] Shaft Speed PORT                      (RPM)
%[11] Shaft Speed STBD                      (RPM)

%[12] Thrust PORT                           (N)
%[13] Torque PORT                           (Nm)

%[14] Thrust STBD                           (N)
%[15] Torque STBD                           (Nm)

%[16] Kiel probe PORT                       (V)
%[17] Kiel probe STBD                       (V)

%[18] PORT static pressure ITTC station 6   (mmH20)
%[19] STBD static pressure ITTC station 6   (mmH20)
%[20] STBD static pressure ITTC station 5   (mmH20)
%[21] STBD static pressure ITTC station 4   (mmH20)
%[22] STBD static pressure ITTC station 3   (mmH20)
%[23] PORT static pressure ITTC station 1a  (mmH20)
%[24] STBD static pressure ITTC station 1a  (mmH20)

resultsArraySPT_DS   = [];
%# resultsArraySPT_DS columns:

%[1]  Speed (1-9)                           (-)

% Static Pressure: Station 1a
%[2]  Min                                   (mmH20)
%[3]  Max                                   (mmH20)
%[4]  Mean (or average)                     (mmH20)
%[5]  Variance                              (mmH20)
%[6]  Standard deviation                    (mmH20)

% Static Pressure: Station 3
%[7]  Min                                   (mmH20)
%[8]  Max                                   (mmH20)
%[9]  Mean (or average)                     (mmH20)
%[10] Variance                              (mmH20)
%[11] Standard deviation                    (mmH20)

% Static Pressure: Station 4
%[12] Min                                   (mmH20)
%[13] Max                                   (mmH20)
%[14] Mean (or average)                     (mmH20)
%[15] Variance                              (mmH20)
%[16] Standard deviation                    (mmH20)

% Static Pressure: Station 5
%[17]  Min                                  (mmH20)
%[18]  Max                                  (mmH20)
%[19]  Mean (or average)                    (mmH20)
%[20]  Variance                             (mmH20)
%[21]  Standard deviation                   (mmH20)

% Static Pressure: Station 6
%[22]  Min                                  (mmH20)
%[23]  Max                                  (mmH20)
%[24]  Mean (or average)                    (mmH20)
%[25]  Variance                             (mmH20)
%[26]  Standard deviation                   (mmH20)

for k=1:9
    [m,n] = size(resultsArraySPT_R{k});
    if m > 0
        % Averaged repeated runs ------------------------------------------
        resultsArraySPT_RAvg(k, 1)  = k;
        resultsArraySPT_RAvg(k, 2)  = mean(resultsArraySPT_R{k}(:,2));
        resultsArraySPT_RAvg(k, 3)  = mean(resultsArraySPT_R{k}(:,3));
        resultsArraySPT_RAvg(k, 4)  = mean(resultsArraySPT_R{k}(:,4));
        resultsArraySPT_RAvg(k, 5)  = mean(resultsArraySPT_R{k}(:,5));
        resultsArraySPT_RAvg(k, 6)  = mean(resultsArraySPT_R{k}(:,6));
        resultsArraySPT_RAvg(k, 7)  = mean(resultsArraySPT_R{k}(:,7));
        resultsArraySPT_RAvg(k, 8)  = mean(resultsArraySPT_R{k}(:,8));
        resultsArraySPT_RAvg(k, 9)  = mean(resultsArraySPT_R{k}(:,9));
        resultsArraySPT_RAvg(k, 10) = mean(resultsArraySPT_R{k}(:,10));
        resultsArraySPT_RAvg(k, 11) = mean(resultsArraySPT_R{k}(:,11));
        resultsArraySPT_RAvg(k, 12) = mean(resultsArraySPT_R{k}(:,12));
        resultsArraySPT_RAvg(k, 13) = mean(resultsArraySPT_R{k}(:,13));
        resultsArraySPT_RAvg(k, 14) = mean(resultsArraySPT_R{k}(:,14));
        resultsArraySPT_RAvg(k, 15) = mean(resultsArraySPT_R{k}(:,15));
        resultsArraySPT_RAvg(k, 16) = mean(resultsArraySPT_R{k}(:,16));
        resultsArraySPT_RAvg(k, 17) = mean(resultsArraySPT_R{k}(:,17));
        resultsArraySPT_RAvg(k, 18) = mean(resultsArraySPT_R{k}(:,18));
        resultsArraySPT_RAvg(k, 19) = mean(resultsArraySPT_R{k}(:,19));
        resultsArraySPT_RAvg(k, 20) = mean(resultsArraySPT_R{k}(:,20));
        resultsArraySPT_RAvg(k, 21) = mean(resultsArraySPT_R{k}(:,21));
        resultsArraySPT_RAvg(k, 22) = mean(resultsArraySPT_R{k}(:,22));
        resultsArraySPT_RAvg(k, 23) = mean(resultsArraySPT_R{k}(:,23));
        resultsArraySPT_RAvg(k, 24) = mean(resultsArraySPT_R{k}(:,24));
        
        % Descriptive statistics ------------------------------------------
        resultsArraySPT_DS(k,1) = k;
        
        % Static Pressure: Station 1a
        dataset = resultsArraySPT_R{k}(:,23);
        resultsArraySPT_DS(k,2) = min(dataset);
        resultsArraySPT_DS(k,3) = max(dataset);
        resultsArraySPT_DS(k,4) = mean(dataset);
        resultsArraySPT_DS(k,5) = var(dataset,1);
        resultsArraySPT_DS(k,6) = std(dataset,1);
        
        % Static Pressure: Station 3
        dataset = resultsArraySPT_R{k}(:,22);
        resultsArraySPT_DS(k,7) = min(dataset);
        resultsArraySPT_DS(k,8) = max(dataset);
        resultsArraySPT_DS(k,9) = mean(dataset);
        resultsArraySPT_DS(k,10) = var(dataset,1);
        resultsArraySPT_DS(k,11) = std(dataset,1);
        
        % Static Pressure: Station 4
        dataset = resultsArraySPT_R{k}(:,21);
        resultsArraySPT_DS(k,12) = min(dataset);
        resultsArraySPT_DS(k,13) = max(dataset);
        resultsArraySPT_DS(k,14) = mean(dataset);
        resultsArraySPT_DS(k,15) = var(dataset,1);
        resultsArraySPT_DS(k,16) = std(dataset,1);
        
        % Static Pressure: Station 5
        dataset = resultsArraySPT_R{k}(:,20);
        resultsArraySPT_DS(k,17) = min(dataset);
        resultsArraySPT_DS(k,18) = max(dataset);
        resultsArraySPT_DS(k,19) = mean(dataset);
        resultsArraySPT_DS(k,20) = var(dataset,1);
        resultsArraySPT_DS(k,21) = std(dataset,1);
        
        % Static Pressure: Station 6
        dataset = resultsArraySPT_R{k}(:,19);
        resultsArraySPT_DS(k,22) = min(dataset);
        resultsArraySPT_DS(k,23) = max(dataset);
        resultsArraySPT_DS(k,24) = mean(dataset);
        resultsArraySPT_DS(k,25) = var(dataset,1);
        resultsArraySPT_DS(k,26) = std(dataset,1);
    end
end % loop

%# ************************************************************************
%# 1. Static Pressures
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 1: Static Pressure and Pump Head (Pressure at Station 5 - Pressure at Station 3)';
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
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
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
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '-.';
setLineStyle2      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

% Repated runs
%activeArray = resultsArraySPT;

% Averaged runs
activeArray = resultsArraySPT_RAvg;

x1 = activeArray(:,11);
y1 = activeArray(:,23);

x2 = activeArray(:,11);
y2 = activeArray(:,22);

x3 = activeArray(:,11);
y3 = activeArray(:,21);

x4 = activeArray(:,11);
y4 = activeArray(:,20);

x5 = activeArray(:,11);
y5 = activeArray(:,19);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*');
if enableErrorStDevPlot == 1
    % Error (StDev): Station 1a
    hold on;
    h1 = errorbar(x1,y1,resultsArraySPT_DS(:,6),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    % Error (StDev): Station 3
    hold on;
    h1 = errorbar(x2,y2,resultsArraySPT_DS(:,11),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    % Error (StDev): Station 4
    hold on;
    h1 = errorbar(x3,y3,resultsArraySPT_DS(:,16),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    % Error (StDev): Station 5
    hold on;
    h1 = errorbar(x4,y4,resultsArraySPT_DS(:,21),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    % Error (StDev): Station 6
    hold on;
    h1 = errorbar(x5,y5,resultsArraySPT_DS(:,26),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
end % enableErrorStDevPlot
xlabel('{\bf Shaft speed (RPM)}','FontSize',setGeneralFontSize);
ylabel('{\bf Static pressure (mmH20)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
title('{\bf Static Pressure}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
if enableErrorStDevPlot == 1
    set(h1,'marker','+');
    set(h1,'linestyle','none');
end

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 1900;
maxX  = 3100;
incrX = 200;
minY  = -600;
maxY  = 1600;
incrY = 200;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('Starboard: Station 1a','Starboard: Station 3','Starboard: Station 4','Starboard: Station 5','Starboard: Station 6');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,2)

%# X and Y axis -----------------------------------------------------------

% Repated runs
%activeArray = resultsArraySPT;

% Averaged runs
activeArray = resultsArraySPT_RAvg;
[msa,nsa] = size(activeArray);

resultsArraySPT_PH = [];
for kl=1:msa
    resultsArraySPT_PH(kl,1) = resultsArraySPT_RAvg(kl,11);
    resultsArraySPT_PH(kl,2) = resultsArraySPT_RAvg(kl,20)-resultsArraySPT_RAvg(kl,22);
    lowest  = min(resultsArraySPT_R{kl}(:,20))-max(resultsArraySPT_R{kl}(:,22));
    highest = max(resultsArraySPT_R{kl}(:,20))-min(resultsArraySPT_R{kl}(:,22));
    resultsArraySPT_PH(kl,3) = lowest;
    resultsArraySPT_PH(kl,4) = highest;
    resultsArraySPT_PH(kl,5) = std([lowest highest],1);
end

activeArray = resultsArraySPT_PH;

x = activeArray(:,1);
y = activeArray(:,2);
e = activeArray(:,5);

% Fitting curve through sea trials delivered power ------------------------
[fitobject,gof,output] = fit(x,y,'poly2');
cvalues = coeffvalues(fitobject);
cnames  = coeffnames(fitobject);
output  = formula(fitobject);

setDec = '%.4f';
setDecimals1 = setDec;
setDecimals2 = sprintf('+%s',setDec);
setDecimals3 = sprintf('+%s',setDec);
setDecimals4 = sprintf('+%s',setDec);
setDecimals5 = sprintf('+%s',setDec);
if cvalues(1) < 0
    setDecimals1 = setDec;
end
if cvalues(2) < 0
    setDecimals2 = setDec;
end
if cvalues(3) < 0
    setDecimals3 = setDec;
end
%if cvalues(4) < 0
%    setDecimals4 = setDec;
%end
%if cvalues(5) < 0
%    setDecimals5 = setDec;
%end
p1 = sprintf(setDecimals1,cvalues(1));
p2 = sprintf(setDecimals2,cvalues(2));
p3 = sprintf(setDecimals3,cvalues(3));
%p4 = sprintf(setDecimals4,cvalues(4));
%p5 = sprintf(setDecimals5,cvalues(5));
EqnOfFitText = sprintf('\\bfy = %s*x^2%s*x%s, R^{2}=%s',p1,p2,p3,sprintf('%.1f',gof.rsquare));

% Fitting
fitSS = [1500:100:3100];
[mf,nf] = size(fitSS);

fitArray = [];
for kl=1:nf
    fitArray(kl,1) = fitSS(kl);
    fitArray(kl,2) = cvalues(1)*fitSS(kl)^2+cvalues(2)*fitSS(kl)+cvalues(3);
end

%# Plotting ---------------------------------------------------------------
h = plot(fitobject,'-k',x,y,'*');
legendInfo{1} = 'Starboard: Pump Head';
if enableErrorStDevPlot == 1
    % Error (StDev)
    hold on;
    h1 = errorbar(x,y,e,'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
end
% Fitting
hold on;
h2 = plot(fitArray(:,1),fitArray(:,2),'-');
legendInfo{2} = 'Starboard: Pump Head Fitted';
xlabel('{\bf Shaft speed (RPM)}','FontSize',setGeneralFontSize);
ylabel('{\bf Pump head (mm)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
title('{\bf Pump Head}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(1),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',1);
%set(h2(1),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
if enableErrorStDevPlot == 1
    set(h1,'marker','+');
    set(h1,'linestyle','none');
end

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(2000,400,EqnOfFitText,'FontSize',12,'color','k','FontWeight','normal');

%# Axis limitations
minX  = 1400;
maxX  = 3200;
incrX = 200;
minY  = 0;
maxY  = 1500;
incrY = 300;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend('Starboard: Pump Head');
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

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
%if enablePlotMainTitle == 1
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
%end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPT_Plot_1_Static_Pressure_Station_5_and_3_and_Pump_Heads.%s', 'SPT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile viewer
end
