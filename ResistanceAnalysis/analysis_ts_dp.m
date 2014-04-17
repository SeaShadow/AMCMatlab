%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Time Series analysis, data processing
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  April 16, 2014
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
%# SCRIPTS  :    1 => analysis.m          >> Real units, save date to result array
%#                    |
%#                    |__> BASE DATA:     DAQ run files
%#
%#               >>> TODO: Copy data from resultsArray.dat to full_resistance_data.dat
%#
%#               2 => analysis_stats.m    >> Resistance and error plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               3 => analysis_heave.m    >> Heave investigation related plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               4 => analysis_lvdts.m    >> Fr vs. fwd, aft and heave plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               5 => analysis_custom.m   >> Fr vs. Rtm/(VolDisp*p*g)*(1/Fr^2)
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#                    |__> RESULTS:       "resultsAveragedArray.dat" and "*.txt"
%#
%#               6 => analysis_ts.m       >> Time series data for cond 7-12
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               7 => analysis_ua.m       >> Resistance uncertainty analysis
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               8 => analysis_sene.m     >> Calibration errors
%#                    |
%#                    |__> BASE DATA:     1. Read .cal data files
%#                                        2. "resultsArraySensorError.dat"
%#
%#               9 => analysis_ts_drag.m  >> Time series data for cond 7-12
%#                    |                   >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               10 => analysis_ts_drag_fft.m  >> Time series data for cond 7-12
%#                    |                        >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               >>> TODO: Copy data from frequencyArrayFFT.dat to fft_frequency_data.dat
%#
%#               11 => analysis_ts_dp.m  >> Time series data for cond 7-12
%#                    |
%#                    |__> BASE DATA:     DAQ run files
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  27/09/2013 - Created new script
%#               14/01/2014 - Added conditions list and updated script
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
testName = 'Resistance Test';

%# DAQ related settings ----------------------------------------------------
Fs = 200;                               % DAQ sampling frequency = 200Hz


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
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, -0.5 degrees by bow, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500bybow      = 4.33;                              % Model length waterline          (m)
MSwsa1500bybow      = 1.48;                              % Model scale wetted surface area (m^2)
MSdraft1500bybow    = 0.138;                             % Model draft                     (m)
MSAx1500bybow       = 0.025;                             % Model area of max. transverse section (m^2)
BlockCoeff1500bybow = 0.570;                             % Mode block coefficient          (-)
FSlwl1500bybow      = MSlwl1500bybow*FStoMSratio;        % Full scale length waterline     (m)
FSwsa1500bybow      = MSwsa1500bybow*FStoMSratio^2;      % Full scale wetted surface area  (m^2)
FSdraft1500bybow    = MSdraft1500bybow*FStoMSratio;      % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500bystern    = 4.22;                              % Model length waterline          (m)
MSwsa1500bystern    = 1.52;                              % Model scale wetted surface area (m^2)
MSdraft1500bystern  = 0.131;                             % Model draft                     (m)
MSAx1500bystern     = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500bystern = 0.614;                           % Mode block coefficient          (-)
FSlwl1500bystern    = MSlwl1500bystern*FStoMSratio;      % Full scale length waterline     (m)
FSwsa1500bystern    = MSwsa1500bystern*FStoMSratio^2;    % Full scale wetted surface area  (m^2)
FSdraft1500bystern  = MSdraft1500bystern*FStoMSratio;    % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, deep transom for prohaska runs, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500prohaska    = 3.78;                             % Model length waterline          (m)
MSwsa1500prohaska    = 1.49;                             % Model scale wetted surface area (m^2)
MSdraft1500prohaska  = 0.133;                            % Model draft                     (m)
FSlwl1500prohaska    = MSlwl1500prohaska*FStoMSratio;    % Full scale length waterline     (m)
FSwsa1500prohaska    = MSwsa1500prohaska*FStoMSratio^2;  % Full scale wetted surface area  (m^2)
FSdraft1500prohaska  = MSdraft1500prohaska*FStoMSratio;  % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,804 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804          = 4.22;                               % Model length waterline          (m)
MSwsa1804          = 1.68;                               % Model scale wetted surface area (m^2)
MSdraft1804        = 0.153;                              % Model draft                     (m)
MSAx1804           = 0.028;                              % Model area of max. transverse section (m^2)
BlockCoeff1804     = 0.631;                              % Mode block coefficient          (-)
FSlwl1804          = MSlwl1804*FStoMSratio;              % Full scale length waterline     (m)
FSwsa1804          = MSwsa1804*FStoMSratio^2;            % Full scale wetted surface area  (m^2)
FSdraft1804        = MSdraft1804*FStoMSratio;            % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, -0.5 degrees by bow, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bybow     = 4.31;                               % Model length waterline          (m)
MSwsa1804bybow     = 1.66;                               % Model scale wetted surface area (m^2)
MSdraft1804bybow   = 0.157;                              % Model draft                     (m)
MSA1804bybow      = 0.030;                               % Model area of max. transverse section (m^2)
BlockCoeff1804bybow = 0.603;                             % Mode block coefficient          (-)
FSlwl1804bybow     = MSlwl1804bybow*FStoMSratio;         % Full scale length waterline     (m)
FSwsa1804bybow     = MSwsa1804bybow*FStoMSratio^2;       % Full scale wetted surface area  (m^2)
FSdraft1804bybow   = MSdraft1804bybow*FStoMSratio;       % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bystern   = 4.11;                               % Model length waterline          (m)
MSwsa1804bystern   = 1.70;                               % Model scale wetted surface area (m^2)
MSdraft1804bystern = 0.151;                              % Model draft                     (m)
MSA1804bystern     = 0.028;                              % Model area of max. transverse section (m^2)
BlockCoeff1804bystern = 0.657;                           % Mode block coefficient          (-)
FSlwl1804bystern   = MSlwl1804bystern*FStoMSratio;       % Full scale length waterline     (m)
FSwsa1804bystern   = MSwsa1804bystern*FStoMSratio^2;     % Full scale wetted surface area  (m^2)
FSdraft1804bystern = MSdraft1804bystern*FStoMSratio;     % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************

%# ------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# ------------------------------------------------------------------------
headerlines             = 22;  % Number of headerlines to data
headerlinesZeroAndCalib = 16;  % Number of headerlines to zero and calibration factors


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START: Omit first X seconds of data due to acceleration
%# ------------------------------------------------------------------------

% X seconds x sample frequency = X x FS = XFS samples (from start)
%startSamplePos    = 1;
startSamplePos    = 1000;   % Cut first 5 seconds

% X seconds x sample frequency = X x FS = XFS samples (from end)
%cutSamplesFromEnd = 0;   
cutSamplesFromEnd = 400;    % Cut last 2 seconds

%# ------------------------------------------------------------------------
%# END: Omit first 10 seconds of data due to acceleration
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% All runs
% startRun = 1;       % Start at run x
% endRun   = 249;     % Stop at run y

% Custom range
%startRun = 63;      % Start at run x
%endRun   = 80;      % Stop at run y

% Custom range
startRun = 81;      % Start at run x
endRun   = 81;     % Stop at run y

% Single runs
startRun = 81;    % Start at run x
endRun   = 141;    % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED 
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableRawDataPlot      = 0; % Raw data plots of speed, fwd and aft LVDT and drag
enableHvsRtmTvsRtmPlot = 0; % Heave vs. Rtm and trim vs. Rtm

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************  


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START DEFINE RUN NUMBERS BY TEST !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# ------------------------------------------------------------------------

RunNosCond1  = 1:15;    % Cond. 1 (Turb-studs): Bare-hull
RunNosCond2  = 16:25;   % Cond. 2 (Turb-studs): 1st row
RunNosCond3  = 26:35;   % Cond. 3 (Turb-studs): 1st and 2nd row
RunNosCond4  = 36:44;   % Cond. 4 (Trim-tab): 5 deg., level stat. trim
RunNosCond5  = 45:53;   % Cond. 5 (Trim-tab): 0 deg., level stat. trim
RunNosCond6  = 54:62;   % Cond. 6 (Trim-tab): 10 deg., level stat. trim
RunNosCond7  = 63:141;  % Cond. 7 (Resistance): 1,500t, level
RunNosCond8  = 142:156; % Cond. 8 (Resistance): 1,500t, -0.5 deg. bow
RunNosCond9  = 157:171; % Cond. 9 (Resistance): 1,500t, 0.5 deg. stern
RunNosCond10 = 172:201; % Cond. 10 (Resistance): 1,804t, level
RunNosCond11 = 202:216; % Cond. 11 (Resistance): 1,804t, -0.5 deg. bow
RunNosCond12 = 217:231; % Cond. 12 (Resistance): 1,804t, 0.5 deg. stern
RunNosCond13 = 232:249; % Cond. 13 (Prohaska): 1,500t, deep transom

% NOTE: If statement bellow is for use in LOOPS only!!!!
%
% if any(RunNosCond1==k)
%     disp('Cond. 1 (Turb-studs): Bare-hull');
% elseif any(RunNosCond2==k)
%     disp('Cond. 2 (Turb-studs): 1st row');
% elseif any(RunNosCond3==k)
%     disp('Cond. 3 (Turb-studs): 1st and 2nd row');
% elseif any(RunNosCond4==k)
%     disp('Cond. 4 (Trim-tab): 5 deg., level stat. trim');
% elseif any(RunNosCond5==k)
%     disp('Cond. 5 (Trim-tab): 0 deg., level stat. trim');
% elseif any(RunNosCond6==k)
%     disp('Cond. 6 (Trim-tab): 10 deg., level stat. trim');
% elseif any(RunNosCond7==k)
%     disp('Cond. 7 (Resistance): 1,500t, level');
% elseif any(RunNosCond8==k)
%     disp('Cond. 8 (Resistance): 1,500t, -0.5 deg. bow');
% elseif any(RunNosCond9==k)
%     disp('Cond. 9 (Resistance): 1,500t, 0.5 deg. stern');
% elseif any(RunNosCond10==k)
%     disp('Cond. 10 (Resistance): 1,804t, level');
% elseif any(RunNosCond11==k)
%     disp('Cond. 11 (Resistance): 1,804t, -0.5 deg. bow');
% elseif any(RunNosCond12==k)
%     disp('Cond. 12 (Resistance): 1,804t, 0.5 deg. stern');
% elseif any(RunNosCond13==k)
%     disp('Cond. 13 (Prohaska): 1,500t, deep transom');
% else
%     disp('Unspecified condition');        
% end

%# ------------------------------------------------------------------------
%# END DEFINE RUN NUMBERS BY TEST !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
trimFreqArray = [];
%w = waitbar(0,'Processed run files'); 
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
    
    fPath = '_time_series_data/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end
    
    fPath = '_time_series_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end

    fPath = '_time_series_drag_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end    
    
    fPath = '_time_series_dp_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end    
    
    %# Have directory
    fPath = sprintf('_plots/%s', '_heave');
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else    
        mkdir(fPath);
    end

    %# Averaged directory
    fPath = sprintf('_plots/%s', '_averaged');
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
    
    % Real units (i.e. m/s, mm and grams)
    [CH_0_Speed CH_0_Speed_Mean]     = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean] = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean] = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]       = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);    
    
    % Leave it as voltage but subtract zero value     
    [CH_0_Speed_Volt CH_0_Speed_Mean_Volt]     = analysis_voltage(Raw_CH_0_Speed,CH_0_Zero);
    [CH_1_LVDTFwd_Volt CH_1_LVDTFwd_Mean_Volt] = analysis_voltage(Raw_CH_1_LVDTFwd,CH_1_Zero);
    [CH_2_LVDTAft_Volt CH_2_LVDTAft_Mean_Volt] = analysis_voltage(Raw_CH_2_LVDTAft,CH_2_Zero);
    [CH_3_Drag_Volt CH_3_Drag_Mean_Volt]       = analysis_voltage(Raw_CH_3_Drag,CH_3_Zero);    
 
    %# Set variables based on condition -----------------------------------
    
    if any(RunNosCond1==k)
        %disp('Cond. 1 (Turb-studs): Bare-hull');
        testcond = 1;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;        
    elseif any(RunNosCond2==k)
        %disp('Cond. 2 (Turb-studs): 1st row');
        testcond = 2;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;        
    elseif any(RunNosCond3==k)
        %disp('Cond. 3 (Turb-studs): 1st and 2nd row');
        testcond = 3;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond4==k)
        %disp('Cond. 4 (Trim-tab): 5 deg., level stat. trim');
        testcond = 4;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond5==k)
        %disp('Cond. 5 (Trim-tab): 0 deg., level stat. trim');
        testcond = 5;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond6==k)
        %disp('Cond. 6 (Trim-tab): 10 deg., level stat. trim');
        testcond = 6;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond7==k)
        %disp('Cond. 7 (Resistance): 1,500t, level');
        testcond = 7;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;        
    elseif any(RunNosCond8==k)
        %disp('Cond. 8 (Resistance): 1,500t, -0.5 deg. bow');
        testcond = 8;
        MSlwl    = MSlwl1500bybow;
        MSwsa    = MSwsa1500bybow;
        MSdraft  = MSdraft1500bybow;
        FSlwl    = FSlwl1500bybow;
        FSwsa    = FSwsa1500bybow;
        FSdraft  = FSdraft1500bybow;
    elseif any(RunNosCond9==k)
        %disp('Cond. 9 (Resistance): 1,500t, 0.5 deg. stern');
        testcond = 9;
        MSlwl    = MSlwl1500bystern;
        MSwsa    = MSwsa1500bystern;
        MSdraft  = MSdraft1500bystern;
        FSlwl    = FSlwl1500bystern;
        FSwsa    = FSwsa1500bystern;
        FSdraft  = FSdraft1500bystern;
    elseif any(RunNosCond10==k)
        %disp('Cond. 10 (Resistance): 1,804t, level');
        testcond = 10;
        MSlwl    = MSlwl1804;
        MSwsa    = MSwsa1804;
        MSdraft  = MSdraft1804;
        FSlwl    = FSlwl1804;
        FSwsa    = FSwsa1804;
        FSdraft  = FSdraft1804;
    elseif any(RunNosCond11==k)
        %disp('Cond. 11 (Resistance): 1,804t, -0.5 deg. bow');
        testcond = 11;
        MSlwl    = MSlwl1804bybow;
        MSwsa    = MSwsa1804bybow;
        MSdraft  = MSdraft1804bybow;
        FSlwl    = FSlwl1804bybow;
        FSwsa    = FSwsa1804bybow;
        FSdraft  = FSdraft1804bybow;
    elseif any(RunNosCond12==k)
        %disp('Cond. 12 (Resistance): 1,804t, 0.5 deg. stern');
        testcond = 12;
        MSlwl    = MSlwl1804bystern;
        MSwsa    = MSwsa1804bystern;
        MSdraft  = MSdraft1804bystern;
        FSlwl    = FSlwl1804bystern;
        FSwsa    = FSwsa1804bystern;
        FSdraft  = FSdraft1804bystern;       
    elseif any(RunNosCond13==k)
        %disp('Cond. 13 (Prohaska): 1,500t, deep transom');
        testcond = 13;
        MSlwl    = MSlwl1500prohaska;
        MSwsa    = MSwsa1500prohaska;
        MSdraft  = MSdraft1500prohaska;
        FSlwl    = FSlwl1500prohaska;
        FSwsa    = FSwsa1500prohaska;
        FSdraft  = FSdraft1500prohaska;
    else
        disp('Unspecified condition');
        break;
    end    
    
    %# Data processing: Time series data ----------------------------------
    [ms,ns] = size(CH_0_Speed);
    
    %# Results array columns: 
        %[1]  Time                                                    (s)
        %[2]  Run No.                                                 (-)
        %[3]  Condition                                               (-)
        %[4]  Speed                                                   (m/s)
        %[5]  Length Froude number                                    (-)
        %[6]  Fwd LVDT                                                (mm)
        %[7]  Aft LVDT                                                (mm)
        %[8]  Heave                                                   (mm)
        %[9]  Trim                                                    (deg)
        %[10] Drag                                                    (g)
        
    % Loop through time series data
    dataArray = [];
    for j=1:ms
        
        dataArray(j, 1) = timeData(j);
        
        dataArray(j, 2) = k;
        dataArray(j, 3) = testcond;
        dataArray(j, 4) = CH_0_Speed(j);
        
        roundedspeed    = str2num(sprintf('%.2f',CH_0_Speed(j)));                        % Round averaged speed to two (2) decimals only
        modelfrrounded  = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl))); % Calculate Froude length number
        dataArray(j, 5) = modelfrrounded;    
        
        dataArray(j, 6) = CH_1_LVDTFwd(j);
        dataArray(j, 7) = CH_2_LVDTAft(j);
        
        dataArray(j, 8) = (CH_1_LVDTFwd(j)+CH_2_LVDTAft(j))/2;
        dataArray(j, 9) = atand((CH_1_LVDTFwd(j)-CH_2_LVDTAft(j))/distbetwposts);
        
        dataArray(j, 10) = CH_3_Drag(j);
    end
    
    % Plots ---------------------------------------------------------------

    figurename = sprintf('Condition: %s, Run: %s, Fr: %.2f // Time Series: Heave and Trim', num2str(testcond), num2str(k), dataArray(1,5));
    fig = figure('Name',figurename,'NumberTitle','off');

    setColor  = {'k';'k';'r';'g';'b';'k';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1]};
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
    setLine   = {'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};
    
    % Speed ---------------------------------------------------------------
    subplot(4,1,1);

    x = dataArray(:,1);
    y = dataArray(:,4);
    
    h = plot(x,y);
    xlabel('{\bf Time (s)}');
    ylabel('{\bf Speed (m/s)}');
    %title('{\bf Speed}');
    grid on;
    box on;
    %axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    % Line - Colors and markers
    setSubPlotNo = 1;
    set(h(1),'Color',setColor{setSubPlotNo},'Marker',setMarker{setSubPlotNo},'MarkerSize',1,'LineStyle',setMarker{setSubPlotNo},'linewidth',1);
    %set(h(1),'Color','k','Marker','x','MarkerSize',1,'LineStyle','--','linewidth',1);
    
    %# Axis limitations
    minX = min(x);
    maxX = max(x);
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:2:maxX);    
    
    % Drag ----------------------------------------------------------------
    subplot(4,1,2);
    
    x = dataArray(:,1);
    y = dataArray(:,10);

    % Grams to Newton conversion
    Raw_Data  = num2cell(y);                                                    % Double to cell conversion
    Raw_Data  = cellfun(@(y) (y/100)*9.806, Raw_Data, 'UniformOutput', false);  % Apply functions to cell
    y         = cell2mat(Raw_Data);                                             % Cell to double conversion
    
    h = plot(x,y);
    xlabel('{\bf Time (s)}');
    ylabel('{\bf Drag (N)}');
    %title('{\bf Drag}');
    grid on;
    box on;
    %axis square;
    
    % Line - Colors and markers
    setSubPlotNo = 2;
    set(h(1),'Color',setColor{setSubPlotNo},'Marker',setMarker{setSubPlotNo},'MarkerSize',1,'LineStyle',setMarker{setSubPlotNo},'linewidth',1);
    %set(h(1),'Color','k','Marker','x','MarkerSize',1,'LineStyle','--','linewidth',1);   
    
    %# Axis limitations
    minX = min(x);
    maxX = max(x);
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:2:maxX);      
    
    % Fwd LVDT, aft LVDT and heave ----------------------------------------
    subplot(4,1,3);
    
    x = dataArray(:,1);
    
    y1 = dataArray(:,6);    % Fwd LVDT
    y2 = dataArray(:,7);    % Aft LVDT
    y3 = dataArray(:,8);    % Heave
    
    h = plot(x,y1,'r-',x,y2,'g-',x,y3,'b-');
    xlabel('{\bf Time (s)}');
    ylabel('{\bf LVDTs and heave (mm)}');
    %title('{\bf Fwd LVDT, aft LVDT and heave}');
    grid on;
    box on;
    %axis square;
    
    % Colors and markers
    %MS = 2;
    %LW = 1;
    %setSubPlotNo = 3; set(h(1),'Color',setColor{setSubPlotNo},'Marker',setMarker{setSubPlotNo},'MarkerSize',MS,'LineStyle',setMarker{setSubPlotNo},'linewidth',LW);
    %setSubPlotNo = 4; set(h(2),'Color',setColor{setSubPlotNo},'Marker',setMarker{setSubPlotNo},'MarkerSize',MS,'LineStyle',setMarker{setSubPlotNo},'linewidth',LW);
    %setSubPlotNo = 5; set(h(3),'Color',setColor{setSubPlotNo},'Marker',setMarker{setSubPlotNo},'MarkerSize',MS,'LineStyle',setMarker{setSubPlotNo},'linewidth',LW); 
    
    %# Axis limitations
    minX = min(x);
    maxX = max(x);
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:2:maxX); 
    
    % Legend
    hleg1 = legend('Fwd LVDT','Aft LVDT','Heave'); %,'Trim'
    set(hleg1,'Location','SouthEast');
    set(hleg1,'Interpreter','none');
    %legend boxoff;
    clearvars legendInfo;

    % Trim ----------------------------------------------------------------
    subplot(4,1,4);
    
    x = dataArray(:,1);
    y = dataArray(:,9);
    
    h = plot(x,y);
    xlabel('{\bf Time (s)}');
    ylabel('{\bf Trim (deg)}');
    %title('{\bf Trim}');
    grid on;
    box on;
    %axis square;
    
    % Line - Colors and markers
    setSubPlotNo = 6;
    set(h(1),'Color',setColor{setSubPlotNo},'Marker',setMarker{setSubPlotNo},'MarkerSize',1,'LineStyle',setMarker{setSubPlotNo},'linewidth',1);
    %set(h(1),'Color','k','Marker','x','MarkerSize',1,'LineStyle','--','linewidth',1);   
    
    %# Axis limitations
    minX = min(x);
    maxX = max(x);
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:2:maxX);
    
    %# Save plot as PNG ---------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    
    %# Plot title -----------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintf('%s/Cond_%s_Run_%s_Fr_%s_Time_Series_DP_Plots_Heave_Trim.pdf', '_time_series_dp_plots', num2str(testcond), num2str(k), num2str(dataArray(j, 5)));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('%s/Cond_%s_Run_%s_Fr_%s_Time_Series_DP_Plots_Heave_Trim.png', '_time_series_dp_plots', num2str(testcond), num2str(k), num2str(dataArray(j, 5)));
    saveas(fig, plotsavename);                % Save plot as PNG
    close;
    
    %# Display in command window ------------------------------------------

    speed   = CH_0_Speed_Mean;
    fwdLvdt = CH_1_LVDTFwd_Mean;
    aftLvdt = CH_2_LVDTAft_Mean;
    drag    = CH_3_Drag_Mean;
    
    heave = (fwdLvdt+aftLvdt)/2;                    % Model Heave (mm)
    trim  = atand((fwdLvdt-aftLvdt)/distbetwposts);  % Model Trim (Degrees)

    fprintf('Condition: %s, Run: %s:: Speed         = %.2f m/s \r', num2str(testcond), num2str(k), speed);
    fprintf('Condition: %s, Run: %s:: Mean fwd LVDT = %.2f mm \r', num2str(testcond), num2str(k), fwdLvdt);
    fprintf('Condition: %s, Run: %s:: Mean aft LVDT = %.2f mm \r', num2str(testcond), num2str(k), aftLvdt);
    fprintf('Condition: %s, Run: %s:: Drag          = %.2f g \r', num2str(testcond), num2str(k), drag);
    disp('*****Calculated using averaged values*****************');
    fprintf('Condition: %s, Run: %s:: Heave         = %.2f mm \r', num2str(testcond), num2str(k), heave);
    fprintf('Condition: %s, Run: %s:: Trim          = %.2f degrees \r', num2str(testcond), num2str(k), trim);
    disp('******************************************************');
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


% /////////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% -------------------------------------------------------------------------

%M = resultsArray;
%csvwrite('resultsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character      
%dlmwrite('resultsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% -------------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer