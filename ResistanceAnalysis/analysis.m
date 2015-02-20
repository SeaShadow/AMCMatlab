%# ------------------------------------------------------------------------
%# Resistance Test Analysis
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  February 20, 2015
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
%#                   method as described by ITTC 7.2-02-02-01. Remove turbulence
%#                   stimulator resistance from model scale resistance.
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
%#               2   => analysis_stats.m     >> Resistance and error plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               3 => analysis_custom.m   >> Fr vs. Rtm/(VolDisp*p*g)*(1/Fr^2)
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#                    |__> RESULTS:       "resultsAveragedArray.dat" and "*.txt"
%#
%#               4 => analysis_avgrundat.m >> Averaged run data, summary
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               5 => analysis_heave.m    >> Heave investigation related plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               6 => analysis_lvdts.m    >> Fr vs. fwd, aft and heave plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               7 => analysis_ts.m       >> Time series data for cond 7-12
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               8 => analysis_ua.m       >> Resistance uncertainty analysis
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               9 => analysis_sene.m     >> Calibration errors
%#                    |
%#                    |__> BASE DATA:     1. Read .cal data files
%#                                        2. "resultsArraySensorError.dat"
%#
%#               10 => analysis_ts_drag.m  >> Time series data for cond 7-12
%#                    |                   >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               11 => analysis_ts_drag_fft.m  >> Time series data for cond 7-12
%#                    |                        >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               >>> TODO: Copy data from frequencyArrayFFT.dat to fft_frequency_data.dat
%#
%#               12 => analysis_ts_dp.m  >> Time series data for cond 7-12
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
%# CHANGES    :  31/07/2013 - Adjusted analysis file for resistance test data
%#               09/09/2013 - Adjusted analysis file for resistance test data
%#               14/01/2014 - Added conditions list and updated script
%#               08/10/2014 - Adjusted plotting style for thesis plots
%#               08/01/2015 - Added reduction if resistance due to TS
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


%# ************************************************************************
%# START: PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Time series data
%enableTSDataSave          = 1;    % Enable time series data saving

% Main and plot titles
enablePlotMainTitle       = 1;    % Show plot title in saved file
enablePlotTitle           = 1;    % Show plot title above plot
enableTextOnPlot          = 0;    % Show text on plot
enableBlackAndWhitePlot   = 0;    % Show plot in black and white
enableEqnOfFitPlot        = 0;    % Show equations of fit
enableCommandWindowOutput = 0;    % Show command windown ouput

% Special plots
enableRawDataPlot         = 0;    % Raw data plots of speed, fwd and aft LVDT and drag
enableHvsRtmTvsRtmPlot    = 0;    % Heave vs. Rtm and trim vs. Rtm

% Scaled to A4 paper
enableA4PaperSizePlot     = 1;    % Show plots scale to A4 size

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


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
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

% Form factors and correlaction coefficient
FormFactor = 1.18;                            % Form factor (1+k)

% Correlation coefficients: No Ca (AMC), typical Ca (Bose 2008) and MARIN Ca
CorrCoeff  = 0.00035;                                           % Ca value as used by MARIN for JHSV testing (USE AS DEFAULT)

% Drag coefficient
% See: Oura, T. & Ikeda, Y. 2007, 'Maneuverability Of A Wavepiercing High-Speed
%      Catamaran At Low Speed In Strong Wind', Proceedings of the The
%      2nd International Conference on Marine Research and Transportation
%      28/6/2007, Ischia, Naples, Italy.
DragCoeff = 0.446;

% Roughness of hull surface (ks), typical value
RoughnessOfHullSurface = 150*10^(-6);

% Air density at 20 °C and 101.325 kPa
airDensity = 1.2041;

% FULL SCALE: Demihull, projected area of the ship above the water line
% to the transverse plane, AVS (m^2)
% Established using Incat GA drawing and extracting transverse area then scaling to full scale size.
FSProjectedArea = 341.5/2;

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


%# ************************************************************************
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
%# ************************************************************************


%# ************************************************************************
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% All runs
startRun = 1;       % Start at run x
endRun   = 249;     % Stop at run y

% Custom range
%startRun = 63;      % Start at run x
%endRun   = 80;      % Stop at run y

% Custom range
%startRun = 63;      % Start at run x
%endRun   = 231;     % Stop at run y

% Single runs
%startRun = 63;    % Start at run x
%endRun   = 63;    % Stop at run y

% Single runs
%startRun = 81;    % Start at run x
%endRun   = 81;    % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# ************************************************************************


%# ************************************************************************
%# START DEFINE RUN NUMBERS BY TEST
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
%# END DEFINE RUN NUMBERS BY TEST
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
%# START: CREATE PLOTS AND RUN DIRECTORY
%# ------------------------------------------------------------------------

%# _plots directory -------------------------------------------------------
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _time_series_data directory --------------------------------------------
fPath = '_plots/_time_series_data/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _time_series_plots directory -------------------------------------------
setDirName = '_plots/_time_series_plots';

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

%# _time_series_drag_plots directory --------------------------------------
fPath = '_plots/_time_series_drag_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _heave directory -------------------------------------------------------
setDirName = '_heave';

fPath = sprintf('_plots/%s', setDirName);
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', setDirName, 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', setDirName, 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', setDirName, 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _averaged directory ----------------------------------------------------
setDirName = '_averaged';

fPath = sprintf('_plots/%s', setDirName);
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', setDirName, 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', setDirName, 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', setDirName, 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ************************************************************************


%# ************************************************************************
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ************************************************************************

resultsArray = [];
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
    [CH_0_Speed CH_0_Speed_Mean]               = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]           = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean]           = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]                 = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
    
    % Leave it as voltage but subtract zero value
    [CH_0_Speed_Volt CH_0_Speed_Mean_Volt]     = analysis_voltage(Raw_CH_0_Speed,CH_0_Zero);
    [CH_1_LVDTFwd_Volt CH_1_LVDTFwd_Mean_Volt] = analysis_voltage(Raw_CH_1_LVDTFwd,CH_1_Zero);
    [CH_2_LVDTAft_Volt CH_2_LVDTAft_Mean_Volt] = analysis_voltage(Raw_CH_2_LVDTAft,CH_2_Zero);
    [CH_3_Drag_Volt CH_3_Drag_Mean_Volt]       = analysis_voltage(Raw_CH_3_Drag,CH_3_Zero);
    
    % Time series data array and save as DAT file -------------------------
    
    % Column names
    
    % Where:
    % UNIT = Real units   (i.e. s, m/s, mm, g)
    % VOLT = Raw data     (V)
    
    %[1] Time                 (s)
    
    %[2] UNIT: Speed          (m/s)
    %[3] UNIT: Forward LVDT   (mm)
    %[4] UNIT: Aft LVDT       (mm)
    %[5] UNIT: Drag           (g)
    
    %[6] VOLT: Speed          (V)
    %[7] VOLT: Forward LVDT   (V)
    %[8] VOLT: Aft LVDT       (V)
    %[9] VOLT: Drag           (V)
    
    tsArray = [];
    
    tsArray(:,1) = timeData;
    
    tsArray(:,2) = CH_0_Speed;
    tsArray(:,3) = CH_1_LVDTFwd;
    tsArray(:,4) = CH_2_LVDTAft;
    tsArray(:,5) = CH_3_Drag;
    
    tsArray(:,6) = CH_0_Speed_Volt;
    tsArray(:,7) = CH_1_LVDTFwd_Volt;
    tsArray(:,8) = CH_2_LVDTAft_Volt;
    tsArray(:,9) = CH_3_Drag_Volt;
    
    if k > 99
        runnumber = name(3:5);
    else
        runnumber = name(3:4);
    end
    
    % Save ALL time series data
    tsA = tsArray;
    filenameDat = sprintf('_plots/_time_series_data/R%s.dat',runnumber);
    csvwrite(filenameDat, tsA)                                     % Export matrix tsA to a file delimited by the comma character
    %filenameTxt = sprintf('_time_series_data/R%s.txt',runnumber);
    %dlmwrite(filenameTxt, tsA, 'delimiter', '\t', 'precision', 4)  % Export matrix tsA to a file delimited by the tab character and using a precision of four significant digits
    
    % ---------------------------------------------------------------------
    % END: REAL UNITS COVNERSION
    % /////////////////////////////////////////////////////////////////////
    
    
    % *********************************************************************
    % START: Plotting RAW data
    % ---------------------------------------------------------------------
    
    if enableRawDataPlot == 1
        
        if k > 99
            runnumber = name(3:5);
        else
            runnumber = name(3:4);
        end
        
        figurename = sprintf('Run %s: %s: Time Series Plots', num2str(k), testName);
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings --------------------------------------------
        
        if enableA4PaperSizePlot == 1
            set(gcf, 'PaperSize', [19 19]);
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperPosition', [0 0 19 19]);
            
            set(gcf, 'PaperUnits', 'centimeters');
            set(gcf, 'PaperSize', [19 19]);
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperPosition', [0 0 19 19]);
        end
        
        % Fonts and colours -----------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        setLegendFontSize  = 12;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. ----------------------------
        set(gca,'TickDir','in',...
            'FontSize',10,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors ----------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Set plot figure background to a defined color ------------------
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        
        set(gcf,'Color',[1,1,1]);
        
        %# Time vs. speed -----------------------------------------------------
        subplot(2,2,1);
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        y = CH_0_Speed(startSamplePos:end-cutSamplesFromEnd);
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        %# Plotting
        h = plot(x,y,'x',x,polyv,'-');
        if enablePlotTitle == 1
            title('{\bf Speed}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Speed [m/s]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        %axis square;
        
        %# Line width
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-.';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Time vs. fdw LVDT --------------------------------------------------
        subplot(2,2,2);
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        y = CH_1_LVDTFwd(startSamplePos:end-cutSamplesFromEnd);
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        %# Plotting
        h = plot(x,y,'x',x,polyv,'-');
        if enablePlotTitle == 1
            title('{\bf Fwd LVDT}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Fdw LVDT [mm]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        %axis square;
        
        %# Line width
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-.';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Time vs. aft LVDT --------------------------------------------------
        subplot(2,2,3);
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        y = CH_2_LVDTAft(startSamplePos:end-cutSamplesFromEnd);
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        %# Plotting
        h = plot(x,y,'x',x,polyv,'-');
        if enablePlotTitle == 1
            title('{\bf Aft LVDT}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Afr LVDT [mm]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        %axis square;
        
        %# Line width
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-.';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Time vs. drag ------------------------------------------------------
        subplot(2,2,4);
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        y = CH_3_Drag(startSamplePos:end-cutSamplesFromEnd);
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        %# Plotting
        h = plot(x,y,'x',x,polyv,'-');
        if enablePlotTitle == 1
            title('{\bf Drag}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Drag [g]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        %axis square;
        
        %# Line width
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-.';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
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
        
        %# Plot title ---------------------------------------------------------
        if enablePlotMainTitle == 1
            annotation('textbox', [0 0.9 1 0.1], ...
                'String', strcat('{\bf ', figurename, '}'), ...
                'EdgeColor', 'none', ...
                'HorizontalAlignment', 'center');
        end
        
        %# Save plots as PDF, PNG and EPS -----------------------------------------
        
        %# Save plots as PDF and PNG
        if k > 99
            runnumber = name(2:5);
        else
            runnumber = name(2:4);
        end
        
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for kl=1:3
            plotsavename = sprintf('_plots/%s/%s/Run_%s_Time_Series_Real_Units_Plot.%s', '_time_series_plots', setFileFormat{kl}, num2str(k), setFileFormat{kl});
            print(gcf, setSaveFormat{kl}, plotsavename);
        end
        close;
        
    end
    
    % ---------------------------------------------------------------------
    % END: Plotting RAW data
    % *********************************************************************
    
    
    % *********************************************************************
    % START: Plotting heave vs. Rtm and trim vs. Rtm
    % ---------------------------------------------------------------------
    
    if enableHvsRtmTvsRtmPlot == 1
        
        if k > 99
            runnumber = name(3:5);
        else
            runnumber = name(3:4);
        end
        
        % Associate length waterlines based on condition
        if any(RunNosCond1==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond2==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond3==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond4==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond5==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond6==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond7==k)
            MSlwl    = MSlwl1500;
        elseif any(RunNosCond8==k)
            MSlwl    = MSlwl1500bybow;
        elseif any(RunNosCond9==k)
            MSlwl    = MSlwl1500bystern;
        elseif any(RunNosCond10==k)
            MSlwl    = MSlwl1804;
        elseif any(RunNosCond11==k)
            MSlwl    = MSlwl1804bybow;
        elseif any(RunNosCond12==k)
            MSlwl    = MSlwl1804bystern;
        elseif any(RunNosCond13==k)
            MSlwl    = MSlwl1500prohaska;
        end
        
        % Data variables
        tData     = timeData(startSamplePos:end-cutSamplesFromEnd);
        speedData = CH_0_Speed(startSamplePos:end-cutSamplesFromEnd);
        fLVDTData = CH_1_LVDTFwd(startSamplePos:end-cutSamplesFromEnd);
        aLVDTData = CH_2_LVDTAft(startSamplePos:end-cutSamplesFromEnd);
        dragData  = CH_3_Drag(startSamplePos:end-cutSamplesFromEnd);
        
        % Model Froude length number
        modelFroudeNo = sprintf('%.2f',mean(speedData) / sqrt(gravconst*MSlwl));
        
        % Array size
        [m,n] = size(tData);
        
        % Populate custom array
        tsArray = [];
        %# Results tsArray columns:
        %[1]  Time          (s)
        %[2]  Heave         (mm)
        %[3]  Trim          (degrees)
        %[4]  Rtm           (N)
        for j=1:m
            tsArray(j,1) = tData(j);
            tsArray(j,2) = (fLVDTData(j) + aLVDTData(j)) / 2;
            tsArray(j,3) = atand((fLVDTData(j) - aLVDTData(j)) / distbetwposts);
            tsArray(j,4) = (dragData(j) / 1000) * gravconst;
        end
        
        % Plotting
        figurename = sprintf('Run %s (Fr=%s): %s: Heave vs. R_{Tm} and trim vs. R_{Tm} Plots', num2str(k), modelFroudeNo, testName);
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings --------------------------------------------
        
        if enableA4PaperSizePlot == 1
            set(gcf, 'PaperSize', [19 19]);
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperPosition', [0 0 19 19]);
            
            set(gcf, 'PaperUnits', 'centimeters');
            set(gcf, 'PaperSize', [19 19]);
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperPosition', [0 0 19 19]);
        end
        
        % Fonts and colours -----------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. ----------------------------
        set(gca,'TickDir','in',...
            'FontSize',10,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors ----------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Set plot figure background to a defined color ------------------
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        
        set(gcf,'Color',[1,1,1]);
        
        %# Time vs. Heave -------------------------------------------------
        subplot(2,3,1);
        
        x = tsArray(:,1);
        y = tsArray(:,2);
        
        h = plot(x,y,'*');
        if enablePlotTitle == 1
            title('{\bf Time vs. Heave}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        
        % Colors and markers
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
        %set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','-','linewidth',1);
        
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Time vs. Trim --------------------------------------------------
        subplot(2,3,2);
        
        x = tsArray(:,1);
        y = tsArray(:,3);
        
        h = plot(x,y,'*');
        if enablePlotTitle == 1
            title('{\bf Time vs. Trim}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Trim [deg]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        
        % Colors and markers
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
        %set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','-','linewidth',1);
        
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Time vs. Rtm ---------------------------------------------------
        subplot(2,3,3);
        
        x = tsArray(:,1);
        y = tsArray(:,4);
        
        h = plot(x,y,'*');
        if enablePlotTitle == 1
            title('{\bf Time vs. R_{tm}}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
        ylabel('{\bf R_{Tm} [N]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Axis limitations
        xlim([round(x(1)) round(x(end))]);
        
        % Colors and markers
        setMarkerSize      = 6;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-';
        set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
        %set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','-','linewidth',1);
        
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Heave vs. Rtm --------------------------------------------------
        subplot(2,3,4);
        
        x = tsArray(:,2);
        y = tsArray(:,4);
        
        h = plot(x,y,'*');
        if enablePlotTitle == 1
            title('{\bf Heave vs. R_{Tm}}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Total resistance R_{Tm} [N]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        % Colors and markers
        setMarkerSize      = 4;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-';
        set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
        %set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','-','linewidth',1);
        
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Trim vs. Rtm ---------------------------------------------------
        subplot(2,3,5);
        
        x = tsArray(:,3);
        y = tsArray(:,4);
        
        h = plot(x,y,'*');
        if enablePlotTitle == 1
            title('{\bf Trim vs. R_{Tm}}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Trim [deg]}','FontSize',setGeneralFontSize);
        ylabel('{\bf Total resistance R_{Tm} [N]}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        % Colors and markers
        setMarkerSize      = 4;
        setLineWidthMarker = 0.5;
        setLineWidth       = 2;
        setLineStyle       = '-';
        set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
        %set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','-','linewidth',1);
        
        % Limit decimals in X and Y axis numbers
        set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))
        
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
        
        %# Plot title ---------------------------------------------------------
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
            plotsavename = sprintf('_plots/%s/%s/Run_%s_Heave_vs_Rtm_and_Trim_vs_Rtm.%s', '_heave', setFileFormat{kl}, num2str(k), setFileFormat{kl});
            print(gcf, setSaveFormat{kl}, plotsavename);
        end
        close;
        
    end % enableHvsRtmTvsRtmPlot
    
    % ---------------------------------------------------------------------
    % END: Plotting heave vs. Rtm and trim vs. Rtm
    % *********************************************************************
    
    
    %# ********************************************************************
    %# Collect and display results
    %# ********************************************************************
    
    %# CONDITIONS ---------------------------------------------------------
    if enableCommandWindowOutput == 1
        disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    end
    if any(RunNosCond1==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 1 (Turb-studs): Bare-hull');
        end
        testcond = 1;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond2==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 2 (Turb-studs): 1st row');
        end
        testcond = 2;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond3==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 3 (Turb-studs): 1st and 2nd row');
        end
        testcond = 3;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond4==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 4 (Trim-tab): 5 deg., level stat. trim');
        end
        testcond = 4;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond5==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 5 (Trim-tab): 0 deg., level stat. trim');
        end
        testcond = 5;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond6==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 6 (Trim-tab): 10 deg., level stat. trim');
        end
        testcond = 6;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond7==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 7 (Resistance): 1,500t, level');
        end
        testcond = 7;
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif any(RunNosCond8==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 8 (Resistance): 1,500t, -0.5 deg. bow');
        end
        testcond = 8;
        MSlwl    = MSlwl1500bybow;
        MSwsa    = MSwsa1500bybow;
        MSdraft  = MSdraft1500bybow;
        FSlwl    = FSlwl1500bybow;
        FSwsa    = FSwsa1500bybow;
        FSdraft  = FSdraft1500bybow;
    elseif any(RunNosCond9==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 9 (Resistance): 1,500t, 0.5 deg. stern');
        end
        testcond = 9;
        MSlwl    = MSlwl1500bystern;
        MSwsa    = MSwsa1500bystern;
        MSdraft  = MSdraft1500bystern;
        FSlwl    = FSlwl1500bystern;
        FSwsa    = FSwsa1500bystern;
        FSdraft  = FSdraft1500bystern;
    elseif any(RunNosCond10==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 10 (Resistance): 1,804t, level');
        end
        testcond = 10;
        MSlwl    = MSlwl1804;
        MSwsa    = MSwsa1804;
        MSdraft  = MSdraft1804;
        FSlwl    = FSlwl1804;
        FSwsa    = FSwsa1804;
        FSdraft  = FSdraft1804;
    elseif any(RunNosCond11==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 11 (Resistance): 1,804t, -0.5 deg. bow');
        end
        testcond = 11;
        MSlwl    = MSlwl1804bybow;
        MSwsa    = MSwsa1804bybow;
        MSdraft  = MSdraft1804bybow;
        FSlwl    = FSlwl1804bybow;
        FSwsa    = FSwsa1804bybow;
        FSdraft  = FSdraft1804bybow;
    elseif any(RunNosCond12==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 12 (Resistance): 1,804t, 0.5 deg. stern');
        end
        testcond = 12;
        MSlwl    = MSlwl1804bystern;
        MSwsa    = MSwsa1804bystern;
        MSdraft  = MSdraft1804bystern;
        FSlwl    = FSlwl1804bystern;
        FSwsa    = FSwsa1804bystern;
        FSdraft  = FSdraft1804bystern;
    elseif any(RunNosCond13==k)
        if enableCommandWindowOutput == 1
            disp('Cond. 13 (Prohaska): 1,500t, deep transom');
        end
        testcond = 13;
        MSlwl    = MSlwl1500prohaska;
        MSwsa    = MSwsa1500prohaska;
        MSdraft  = MSdraft1500prohaska;
        FSlwl    = FSlwl1500prohaska;
        FSwsa    = FSwsa1500prohaska;
        FSdraft  = FSdraft1500prohaska;
    else
        disp('Unspecified condition');
    end
    if enableCommandWindowOutput == 1
        disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    end
    
    %# Results array columns:
    %[1]  Run No.                                                                  (-)
    %[2]  FS                                                                       (Hz)
    %[3]  No. of samples                                                           (-)
    %[4]  Record time                                                              (s)
    %[5]  Model Averaged speed                                                     (m/s)
    %[6]  Model Averaged fwd LVDT                                                  (m)
    %[7]  Model Averaged aft LVDT                                                  (m)
    %[8]  Model Averaged drag                                                      (g)
    %[9]  Model (Rtm) Total resistance                                             (N)
    %[10] Model (CTm) Total resistance Coefficient                                 (-)
    %[11] Model Froude length number                                               (-)
    %[12] Model Heave                                                              (mm)
    %[13] Model Trim                                                               (Degrees)
    %[14] Equivalent full scale speed                                              (m/s)
    %[15] Equivalent full scale speed                                              (knots)
    
    % ---------------------------------------------------------------------
    % Additional values added: 10/09/2013
    % ---------------------------------------------------------------------
    %[16] Model (Rem) Reynolds Number                                              (-)
    %[17] Model (CFm) Frictional Resistance Coefficient (ITTC'57)                  (-)
    %[18] Model (CFm) Frictional Resistance Coefficient (Grigson)                  (-)
    %[19] Model (CRm) Residual Resistance Coefficient                              (-)
    %[20] Model (PEm) Model Effective Power                                        (W)
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    %[23] Full Scale (CFs) Frictional Resistance Coefficient (ITTC'57)             (-)
    %[24] Full Scale (CTs) Total resistance Coefficient                            (-)
    %[25] Full Scale (RTs) Total resistance (RT)                                   (N)
    %[26] Full Scale (PEs) Model Effective Power                                   (W)
    %[27] Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    %[28] Run condition                                                            (-)
    
    % ---------------------------------------------------------------------
    % Additional values added: 12/09/2013
    % ---------------------------------------------------------------------
    %[29] SPEED: Minimum value                                                      (m/s)
    %[30] SPEED: Maximum value                                                      (m/s)
    %[31] SPEED: Average value                                                      (m/s)
    %[32] SPEED: Percentage (max.-avg.) to max. value (exp. 3%)                     (m/s)
    %[33] LVDT (FWD): Minimum value                                                 (mm)
    %[34] LVDT (FWD): Maximum value                                                 (mm)
    %[35] LVDT (FWD): Average value                                                 (mm)
    %[36] LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%)                (mm)
    %[37] LVDT (AFT): Minimum value                                                 (mm)
    %[38] LVDT (AFT): Maximum value                                                 (mm)
    %[39] LVDT (AFT): Average value                                                 (mm)
    %[40] LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%)                (mm)
    %[41] DRAG: Minimum value                                                       (g)
    %[42] DRAG: Maximum value                                                       (g)
    %[43] DRAG: Average value                                                       (g)
    %[44] DRAG: Percentage (max.-avg.) to max. value (exp. 3%)                      (g)
    
    % ---------------------------------------------------------------------
    % Additional values added: 18/09/2013
    % ---------------------------------------------------------------------
    %[45] SPEED: Standard deviation                                                 (m/s)
    %[46] LVDT (FWD): Standard deviation                                            (mm)
    %[47] LVDT (AFT): Standard deviation                                            (mm)
    %[48] DRAG: Standard deviation                                                  (g)
    
    % ---------------------------------------------------------------------
    % Additional values added: 04/08/2014
    % ---------------------------------------------------------------------
    %[49] Full Scale (CFs) Frictional Resistance Coefficient (Grigson)              (-)
    
    % ---------------------------------------------------------------------
    % Additional values added: 15/12/2014, ITTC 1978 (2011), 7.5-02-03-01.4
    % ---------------------------------------------------------------------
    %[50] Roughness allowance, delta CFs                                            (-)
    %[51] Correlation allowance, CA                                                 (-)
    %[52] Air resistance coefficient in full scale, CAAs                            (-)
    
    % ---------------------------------------------------------------------
    % Additional values added: 14/01/2015, RTm without turb. stim. corr.
    % ---------------------------------------------------------------------    
    %[53] Model Scale Total Resistance includes TS Resistance, RTm                  (N)
    
    
    %# --------------------------------------------------------------------
    %# Write data to array
    %# --------------------------------------------------------------------
    resultsArray(k, 1)  = k;                                                        % Run No.
    resultsArray(k, 2)  = round(length(timeData) / timeData(end));                  % FS (Hz)
    resultsArray(k, 3)  = length(timeData);                                         % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArray(k, 4)  = round(recordTime);                                        % Record time in seconds
    resultsArray(k, 5)  = CH_0_Speed_Mean;                                          % Model Averaged speed (m/s)
    resultsArray(k, 6)  = CH_1_LVDTFwd_Mean;                                        % Model Averaged forward LVDT (mm)
    resultsArray(k, 7)  = CH_2_LVDTAft_Mean;                                        % Model Averaged aft LVDT (mm)
    resultsArray(k, 8)  = CH_3_Drag_Mean;                                           % Model Averaged drag (g)
    
    % Calculate Froude length number
    roundedspeed = str2num(sprintf('%.2f',resultsArray(k, 5)));                     % Round averaged speed to two (2) decimals only
    MSFrRounded  = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl)));   % Calculate Froude length number
    
    %# --------------------------------------------------------------------
    %# Resistance reduction due to turbulence stimulators
    %# --------------------------------------------------------------------
    %# Only needs subtraction in conditions 7, 8, 9, 10, 11, 12, and 13
    %# Use equation of fit: y = 3.1638x-0.4031 where x = Fr and y = resistance of turbulence stimulators
    %# --------------------------------------------------------------------
    %# Note: Equation of fit is linear fit based on two points only as
    %#       turbulence stimulator tests included only two speeds!!!
    %# --------------------------------------------------------------------
    MSRTInNewton = (resultsArray(k, 8)/1000)*gravconst;
    if any(4:12==testcond)
        %disp(sprintf('Run: %s, Condition: %s, Apply TS correction.',num2str(k),num2str(testcond)));
        % Turbulence reduction based on EoF as shown in analysis_stats.m (seee Turb Stim Plot)
        TSReduction = 3.1638*MSFrRounded-0.4031;
        % Only apply TS correction if value > 0 (due to EoF)
        if TSReduction > 0
            MSRTInNewton = MSRTInNewton-TSReduction;
        else
            MSRTInNewton = MSRTInNewton;
        end
    else
        %disp(sprintf('Run: %s, Condition: %s, DO NOT apply TS correction.',num2str(k),num2str(testcond)));
        MSRTInNewton = MSRTInNewton;
    end % any(7:13==testcond)
    resultsArray(k, 9)  = MSRTInNewton;                                            % Model Averaged drag (RTm) (N)
    resultsArray(k, 10) = resultsArray(k, 9) / (0.5*freshwaterdensity*MSwsa*CH_0_Speed_Mean^2); % Model Averaged drag (CTm) (-)
    resultsArray(k, 11) = MSFrRounded;                                              % Froude length number (adjusted for Lwl change at different conditions) (-)
    
    resultsArray(k, 12) = (resultsArray(k, 6)+resultsArray(k, 7))/2;                % Model Heave (mm)
    resultsArray(k, 13) = atand((resultsArray(k, 6)-resultsArray(k, 7))/distbetwposts); % Model Trim (Degrees)
    resultsArray(k, 14) = resultsArray(k, 5) * sqrt(FStoMSratio);                   % Full scale speed (m/s)
    resultsArray(k, 15) = resultsArray(k, 14) / 0.5144;                             % Full scale speed (knots)
    % ---------------------------------------------------------------------
    % Additional values added: 10/09/2013
    % ---------------------------------------------------------------------
    resultsArray(k, 16) = (resultsArray(k, 5)*MSlwl)/MSKinVis;              % Model Reynolds Number (-)
    resultsArray(k, 17) = 0.075/(log10(resultsArray(k, 16))-2)^2;           % Model Frictional Resistance Coefficient (ITTC'57) (-)
    if resultsArray(k, 16) < 10000000
        resultsArray(k, 18) = 10^(2.98651-10.8843*(log10(log10(resultsArray(k, 16))))+5.15283*(log10(log10(resultsArray(k, 16))))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        resultsArray(k, 18) = 10^(-9.57459+26.6084*(log10(log10(resultsArray(k, 16))))-30.8285*(log10(log10(resultsArray(k, 16))))^2+10.8914*(log10(log10(resultsArray(k, 16))))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    resultsArray(k, 19) = resultsArray(k, 10)-FormFactor*resultsArray(k, 18); % Model (CRm) Residual Resistance Coefficient, CRm=CTm-(1+k)CFm, ITTC 1978 (2011), 7.5-02-03-01.4 (-)
    resultsArray(k, 20) = resultsArray(k, 5)*resultsArray(k, 9);              % Model (PEm) Model Effective Power                                   (W)
    resultsArray(k, 21) = resultsArray(k, 20)/0.5;                            % Model (PBm) Model Brake Power (using 50% prop. efficiency estimate) (W)
    resultsArray(k, 22) = (resultsArray(k, 14)*FSlwl)/FSKinVis;               % Full Scale (Res) Reynolds Number (-)
    resultsArray(k, 23) = 0.075/(log10(resultsArray(k, 22))-2)^2;             % Full Scale (CFs) Frictional Resistance Coefficient (ITTC'57) (-)
    
    % Full scale total resistance coefficient (CTs), ITTC 1978 (2011), 7.5-02-03-01.4
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*resultsArray(k, 22)^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(resultsArray(k, 22)))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSwsa));
    FSReynoldsNumber = resultsArray(k, 22);
    if FSReynoldsNumber < 10000000
        FSFricResCoeff = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNumber)))+5.15283*(log10(log10(FSReynoldsNumber)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        FSFricResCoeff = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNumber)))-30.8285*(log10(log10(FSReynoldsNumber)))^2+10.8914*(log10(log10(FSReynoldsNumber)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    % CRs = CRm
    FSResidualResCoeff = resultsArray(k, 19);
    resultsArray(k, 24) = FormFactor*FSFricResCoeff+FSRoughnessAllowance+FSCorrelelationCoeff+FSResidualResCoeff+FSAirResistanceCoeff;  % Full Scale (Cts) Total resistance Coefficient, ITTC 1978 (2011), 7.5-02-03-01.4 (-)
    
    FSTotResCoeff = resultsArray(k, 24);
    resultsArray(k, 25) = 0.5*saltwaterdensity*(resultsArray(k, 14)^2)*FSwsa*FSTotResCoeff; % Full Scale (RTs) Total resistance (RT) (N)
    resultsArray(k, 26) = resultsArray(k, 14)*resultsArray(k, 25);           % Full Scale (PEs) Model Effective Power (W)
    resultsArray(k, 27) = resultsArray(k, 26)/0.5;                           % Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    resultsArray(k, 28) = testcond;                                          % Run condition (-)
    % ---------------------------------------------------------------------
    % Additional values added: 12/09/2013
    % ---------------------------------------------------------------------
    sdata               = CH_0_Speed(startSamplePos:end-cutSamplesFromEnd);
    tfwddata            = CH_1_LVDTFwd(startSamplePos:end-cutSamplesFromEnd);
    taftdata            = CH_2_LVDTAft(startSamplePos:end-cutSamplesFromEnd);
    ddata               = CH_3_Drag(startSamplePos:end-cutSamplesFromEnd);
    resultsArray(k, 29) = min(sdata);                                           % SPEED: Minimum value (m/s)
    resultsArray(k, 30) = max(sdata);                                           % SPEED: Maximum value (m/s)
    resultsArray(k, 31) = mean(sdata);                                          % SPEED: Average value (m/s)
    resultsArray(k, 32) = (max(sdata) - mean(sdata)) / max(sdata);              % SPEED: Percentage (max.-avg.) to max. value (exp. 3% (m/s))
    resultsArray(k, 33) = min(tfwddata);                                        % LVDT (FWD): Minimum value (mm)
    resultsArray(k, 34) = max(tfwddata);                                        % LVDT (FWD): Maximum value (mm)
    resultsArray(k, 35) = mean(tfwddata);                                       % LVDT (FWD): Average value (mm)
    resultsArray(k, 36) = abs(max(tfwddata) - mean(tfwddata)) / abs(max(tfwddata)-min(tfwddata));     % LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%) (mm)
    resultsArray(k, 37) = min(taftdata);                                        % LVDT (AFT): Minimum vaue (mm)
    resultsArray(k, 38) = max(taftdata);                                        % LVDT (AFT): Maximum value (mm)
    resultsArray(k, 39) = mean(taftdata);                                       % LVDT (AFT): Average value (mm)
    resultsArray(k, 40) = abs(max(taftdata) - mean(taftdata)) / abs(max(taftdata)-min(taftdata));     % LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%) (mm)
    resultsArray(k, 41) = min(ddata);                                           % DRAG: Minimum value (g)
    resultsArray(k, 42) = max(ddata);                                           % DRAG: Maximum value (g)
    resultsArray(k, 43) = mean(ddata);                                          % DRAG: Average value (g)
    resultsArray(k, 44) = (max(ddata) - mean(ddata)) / max(ddata);              % DRAG: Percentage (max.-avg.) to max. value (exp. 3%) (g)
    % ---------------------------------------------------------------------
    % Additional values added: 18/09/2013: Statistics (Standard Deviation)
    % ---------------------------------------------------------------------
    resultsArray(k, 45) = std(sdata,1);                                         % SPEED: Standard deviation (-)
    resultsArray(k, 46) = std(tfwddata,1);                                      % LVDT (FWD): Standard deviation (-)
    resultsArray(k, 47) = std(taftdata,1);                                      % LVDT (AFT): Standard deviation (-)
    resultsArray(k, 48) = std(ddata,1);                                         % DRAG: Standard deviation (-)
    % ---------------------------------------------------------------------
    % Additional values added: 04/08/2014
    % ---------------------------------------------------------------------
    % Model Frictional Resistance Coefficient (Grigson) (-)
    resultsArray(k, 49) = FSFricResCoeff;
    % ---------------------------------------------------------------------
    % Additional values added: 15/12/2014, ITTC 1978 (2011), 7.5-02-03-01.4
    % ---------------------------------------------------------------------
    %[50] Roughness allowance, delta CFs                 (-)
    %[51] Correlation allowance, CA                      (-)
    %[52] Air resistance coefficient in full scale, CAAs (-)
    resultsArray(k, 50) = FSRoughnessAllowance;
    resultsArray(k, 51) = FSCorrelelationCoeff;
    resultsArray(k, 52) = FSAirResistanceCoeff;
    
    % ---------------------------------------------------------------------
    % Additional values added: 14/01/2015, RTm without turb. stim. corr.
    % ---------------------------------------------------------------------  
    resultsArray(k, 53) = (resultsArray(k, 8)/1000)*gravconst;
    
    % ---------------------------------------------------------------------
    % Additional values added: 13/02/2015: Statistics (Variance)
    % ---------------------------------------------------------------------
    resultsArray(k, 54) = var(sdata,1);                                         % SPEED: Variance (-)
    resultsArray(k, 55) = var(tfwddata,1);                                      % LVDT (FWD): Variance (-)
    resultsArray(k, 56) = var(taftdata,1);                                      % LVDT (AFT): Variance (-)
    resultsArray(k, 57) = var(ddata,1);                                         % DRAG: Variance (-)
    
    % Command window output -----------------------------------------------
    if enableCommandWindowOutput == 1
        
        %# Prepare strings for display ------------------------------------
        if k > 99
            name = name(2:5);
        else
            name = name(2:4);
        end
        avgspeed          = sprintf('%s:: Model Averaged speed: %s [m/s]', name, sprintf('%.2f',resultsArray(k, 5)));
        avglvdtfdw        = sprintf('%s:: Model Averaged fwd LVDT: %s [mm]', name, sprintf('%.2f',resultsArray(k, 6)));
        avglvdtaft        = sprintf('%s:: Model Averaged aft LVDT: %s [mm]', name, sprintf('%.2f',resultsArray(k, 7)));
        avgdrag           = sprintf('%s:: Model Averaged drag: %s [g]', name, sprintf('%.2f',resultsArray(k, 8)));
        avgdragrt         = sprintf('%s:: Model Total resistance (Rtm): %s [N]', name, sprintf('%.2f',resultsArray(k, 9)));
        avgdragct         = sprintf('%s:: Model Total resistance coefficient (Ctm): %s [-]', name, sprintf('%.5f',resultsArray(k, 10)));
        froudlengthnumber = sprintf('%s:: Froude length number (Fr): %s [-]', name, sprintf('%.2f',resultsArray(k, 11)));
        heave             = sprintf('%s:: Model Heave: %s [mm]', name, sprintf('%.2f',resultsArray(k, 12)));
        trim              = sprintf('%s:: Model Trim: %s [Degrees]', name, sprintf('%.2f',resultsArray(k, 13)));
        % -----------------------------------------------------------------
        % Additional values added: 10/09/2013
        % -----------------------------------------------------------------
        modelreynoldsno   = sprintf('%s:: Model Reynolds Number (Rem): %s [-]', name, sprintf('%.0f',resultsArray(k, 16)));
        modelcfmittc57    = sprintf('%s:: Model Frictional Resistance Coeff. (Cfm using ITTC 1957): %s [-]', name, sprintf('%.5f',resultsArray(k, 17)));
        modelcfmgrigson   = sprintf('%s:: Model Frictional Resistance Coeff. (Cfm using Grigson): %s [-]', name, sprintf('%.5f',resultsArray(k, 18)));
        modelcrm          = sprintf('%s:: Model Residual Resistance Coeff. (Crm): %s [-]', name, sprintf('%.5f',resultsArray(k, 19)));
        modeleffpower     = sprintf('%s:: Model Effective Power (PEm): %s [W]', name, sprintf('%.2f',resultsArray(k, 20)));
        modelbrakepower   = sprintf('%s:: Model Brake Power (PBm at an estimated 50 percent prop. efficiency): %s [W]', name, sprintf('%.2f',resultsArray(k, 21)));
        FSspeedms         = sprintf('%s:: Full Scale speed: %s [m/s]', name, sprintf('%.2f',resultsArray(k, 14)));
        FSspeedkts        = sprintf('%s:: Full Scale speed: %s [knots]', name, sprintf('%.2f',resultsArray(k, 15)));
        FSreynoldsno      = sprintf('%s:: Full Scale Reynolds Number (Res): %s [-]', name, sprintf('%.0f',resultsArray(k, 22)));
        FSCfsittc57       = sprintf('%s:: Full Scale Frictional Resistance Coeff. (Cfs using ITTC 1957): %s [-]', name, sprintf('%.5f',resultsArray(k, 23)));
        FSCfsgrigson      = sprintf('%s:: Full Scale Frictional Resistance Coeff. (Cfs using Grigson): %s [-]', name, sprintf('%.5f',resultsArray(k, 49)));
        FSCts             = sprintf('%s:: Full Scale Total resistance coefficient (Cts): %s [-]', name, sprintf('%.5f',resultsArray(k, 24)));
        FSRts             = sprintf('%s:: Full Scale Total resistance (Rts): %s [N] / %s [kN]', name, sprintf('%.0f',resultsArray(k, 25)), sprintf('%.0f',resultsArray(k, 25)/1000));
        FSPEs             = sprintf('%s:: Full Scale Effective Power (PEs): %s [W] / %s [kW] / %s [mW]', name, sprintf('%.0f',resultsArray(k, 26)), sprintf('%.0f',resultsArray(k, 26)/1000), sprintf('%.2f',resultsArray(k, 26)/1000000));
        FSPBs             = sprintf('%s:: Full Scale Brake Power (PBs at an estimated 50 percent prop. efficiency): %s [W] / %s [kW] / %s [mW]', name, sprintf('%.0f',resultsArray(k, 27)), sprintf('%.0f',resultsArray(k, 27)/1000), sprintf('%.2f',resultsArray(k, 27)/1000000));
        
        %# Display strings ------------------------------------------------
        disp('>>> MODEL SCALE');
        disp(avgspeed);
        disp(avglvdtfdw);
        disp(avglvdtaft);
        disp(avgdrag);
        disp(avgdragrt);
        disp(avgdragct);
        disp(froudlengthnumber);
        disp(heave);
        disp(trim);
        % -----------------------------------------------------------------
        % Additional values added: 10/09/2013
        % -----------------------------------------------------------------
        disp(modelreynoldsno);
        disp(modelcfmittc57);
        disp(modelcfmgrigson);
        disp(modelcrm);
        disp(modeleffpower);
        disp(modelbrakepower);
        disp('>>> FULL SCALE');
        disp(FSspeedms);
        disp(FSspeedkts);
        disp(FSreynoldsno);
        disp(FSCfsittc57);
        disp(FSCfsgrigson);
        disp(FSCts);
        disp(FSRts);
        disp(FSPEs);
        disp(FSPBs);
        disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        
    else
        disp(sprintf('Run %s (Condition %s): Succssfully processed...',num2str(k),num2str(testcond)));
    end % enableCommandWindowOutput
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);

% /////////////////////////////////////////////////////////////////////////
% START Write results to DAT or TXT file
% -------------------------------------------------------------------------
M  = resultsArray;
M2 = M(any(M,2),:);                                                  % Remove zero rows
csvwrite('resultsArray.dat', M2)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsArray.txt', M2, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
disp('All done!');
% -------------------------------------------------------------------------
% END Write results to DAT or TXT file
% /////////////////////////////////////////////////////////////////////////


% Save as MAT file example
%x = [1 2 3 4 5];
%save('..\..\..\2013 November - Self-Propulsion Test\_Run files\_Matlab analysis\test.mat','x')

%if exist('..\..\..\2013 November - Self-Propulsion Test\_Run files\_Matlab analysis\test.mat', 'file') == 2
%	disp('File exists');
%else
%	disp('File does not exist');
%end


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
