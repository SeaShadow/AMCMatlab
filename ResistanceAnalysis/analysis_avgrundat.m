%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Average Run Data Summaries
%#                            Includes shallow water correction summaries!
%# ------------------------------------------------------------------------
%#                            NOTE: Calculations for condition 7 only!
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  February 13, 2015
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
%# CHANGES    :  19/01/2015 - Created new script
%#               dd/mm/yyyy - ...
%#
%# ------------------------------------------------------------------------

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


%# ************************************************************************
%# START: PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle       = 1;    % Show plot title in saved file
enablePlotTitle           = 0;    % Show plot title above plot
enableBlackAndWhitePlot   = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot     = 1;    % Show plots scale to A4 size

% Command windows output
enableCommandWindowOutput = 1;    % Show command windows ouput

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
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
FSProjectedArea = 341.5;

% Model displacements (Kg), catamaran = 2 demihulls
MS1500t = 74.47*2;
MS1804t = 89.18*2;

% Model displacements (m^3), catamaran = 2 demihulls
MS1500tVolume = MS1500t/freshwaterdensity;
MS1804tVolume = MS1804t/freshwaterdensity;

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500           = 4.30;                              % Model length waterline          (m)
MSwsa1500           = 1.501;                             % Model scale wetted surface area (m^2)
% Start new fielvariables: Added 19/1/2015
MSwsaDTA1500        = 0.015;                             % Dry transom area                (m^2)
MSwsaCorrDTA1500    = 1.486;                             % Corrected WSA with dry transom area (m^2)
% End new fielvariables: Added 19/1/2015
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
% Start new fielvariables: Added 19/1/2015
MSwsaDTA1500bybow     = 0.012;                           % Dry transom area                (m^2)
MSwsaCorrDTA1500bybow = 1.468;                           % Corrected WSA with dry transom area (m^2)
% End new fielvariables: Added 19/1/2015
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
% Start new fielvariables: Added 19/1/2015
MSwsaDTA1500byster     = 0.018;                          % Dry transom area                (m^2)
MSwsaCorrDTA1500byster = 1.502;                          % Corrected WSA with dry transom area (m^2)
% End new fielvariables: Added 19/1/2015
MSdraft1500bystern  = 0.131;                             % Model draft                     (m)
MSAx1500bystern     = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500bystern = 0.614;                           % Mode block coefficient          (-)
FSlwl1500bystern    = MSlwl1500bystern*FStoMSratio;      % Full scale length waterline     (m)
FSwsa1500bystern    = MSwsa1500bystern*FStoMSratio^2;    % Full scale wetted surface area  (m^2)
FSdraft1500bystern  = MSdraft1500bystern*FStoMSratio;    % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,804 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804          = 4.22;                               % Model length waterline          (m)
MSwsa1804          = 1.68;                               % Model scale wetted surface area (m^2)
% Start new fielvariables: Added 19/1/2015
MSwsaDTA1804       = 0.019;                              % Dry transom area                (m^2)
MSwsaCorrDTA1804   = 1.661;                              % Corrected WSA with dry transom area (m^2)
% End new fielvariables: Added 19/1/2015
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
% Start new fielvariables: Added 19/1/2015
MSwsaDTA1804bybow     = 0.016;                           % Dry transom area                (m^2)
MSwsaCorrDTA1804bybow = 1.644;                           % Corrected WSA with dry transom area (m^2)
% End new fielvariables: Added 19/1/2015
MSdraft1804bybow    = 0.157;                             % Model draft                     (m)
MSA1804bybow        = 0.030;                             % Model area of max. transverse section (m^2)
BlockCoeff1804bybow = 0.603;                             % Mode block coefficient          (-)
FSlwl1804bybow      = MSlwl1804bybow*FStoMSratio;        % Full scale length waterline     (m)
FSwsa1804bybow      = MSwsa1804bybow*FStoMSratio^2;      % Full scale wetted surface area  (m^2)
FSdraft1804bybow    = MSdraft1804bybow*FStoMSratio;      % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bystern   = 4.11;                               % Model length waterline          (m)
MSwsa1804bystern   = 1.70;                               % Model scale wetted surface area (m^2)
% Start new fielvariables: Added 19/1/2015
MSwsaDTA1804bystern     = 0.022;                         % Dry transom area                (m^2)
MSwsaCorrDTA1804bystern = 1.678;                         % Corrected WSA with dry transom area (m^2)
% End new fielvariables: Added 19/1/2015
MSdraft1804bystern = 0.151;                              % Model draft                     (m)
MSA1804bystern     = 0.028;                              % Model area of max. transverse section (m^2)
BlockCoeff1804bystern = 0.657;                           % Mode block coefficient          (-)
FSlwl1804bystern   = MSlwl1804bystern*FStoMSratio;       % Full scale length waterline     (m)
FSwsa1804bystern   = MSwsa1804bystern*FStoMSratio^2;     % Full scale wetted surface area  (m^2)
FSdraft1804bystern = MSdraft1804bystern*FStoMSratio;     % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////


%# -------------------------------------------------------------------------
%# Read results DAT file
%# -------------------------------------------------------------------------
if exist('full_resistance_data.dat', 'file') == 2
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
    %[10] Model (Ctm) Total resistance Coefficient                                 (-)
    %[11] Model Froude length number                                               (-)
    %[12] Model Heave                                                              (mm)
    %[13] Model Trim                                                               (Degrees)
    %[14] Equivalent full scale speed                                              (m/s)
    %[15] Equivalent full scale speed                                              (knots)
    %[16] Model (Rem) Reynolds Number                                              (-)
    %[17] Model (Cfm) Frictional Resistance Coefficient (ITTC'57)                  (-)
    %[18] Model (Cfm) Frictional Resistance Coefficient (Grigson)                  (-)
    %[19] Model (Crm) Residual Resistance Coefficient                              (-)
    %[20] Model (PEm) Model Effective Power                                        (W)
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    %[23] Full Scale (Cfs) Frictional Resistance Coefficient (ITTC'57)             (-)
    %[24] Full Scale (Cts) Total resistance Coefficient                            (-)
    %[25] Full Scale (Rts) Total resistance (Rt)                                   (N)
    %[26] Full Scale (PEs) Model Effective Power                                   (W)
    %[27] Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    %[28] Run condition                                                            (-)
    %[29] SPEED: Minimum value                                                     (m/s)
    %[30] SPEED: Maximum value                                                     (m/s)
    %[31] SPEED: Average value                                                     (m/s)
    %[32] SPEED: Percentage (max.-avg.) to max. value (exp. 3%)                    (m/s)
    %[33] LVDT (FWD): Minimum value                                                (mm)
    %[34] LVDT (FWD): Maximum value                                                (mm)
    %[35] LVDT (FWD): Average value                                                (mm)
    %[36] LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
    %[37] LVDT (AFT): Minimum value                                                (mm)
    %[38] LVDT (AFT): Maximum value                                                (mm)
    %[39] LVDT (AFT): Average value                                                (mm)
    %[40] LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
    %[41] DRAG: Minimum value                                                      (g)
    %[42] DRAG: Maximum value                                                      (g)
    %[43] DRAG: Average value                                                      (g)
    %[44] DRAG: Percentage (max.-avg.) to max. value (exp. 3%)                     (g)
    %[45] SPEED: Standard deviation                                                (m/s)
    %[46] LVDT (FWD): Standard deviation                                           (mm)
    %[47] LVDT (AFT): Standard deviation                                           (mm)
    %[48] DRAG: Standard deviation                                                 (g)
    % ---------------------------------------------------------------------
    % Additional values added: 04/08/2014
    % ---------------------------------------------------------------------
    %[49] Full Scale (CFs) Frictional Resistance Coefficient (Grigson)             (-)
    % ---------------------------------------------------------------------
    % Additional values added: 15/12/2014, R_{TBH} (2011), 7.5-02-03-01.4
    % ---------------------------------------------------------------------
    %[50] Roughness allowance, delta CFs                                           (-)
    %[51] Correlation allowance, Ca                                                (-)
    %[52] Air resistance coefficient in full scale, CAAs                           (-)
    
    results = csvread('full_resistance_data.dat');
    
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('---------------------------------------------------------------------------------------');
    disp('File full_resistance_data.dat does not exist!');
    disp('---------------------------------------------------------------------------------------');
    break;
end

%# Stop script if required data unavailble --------------------------------
if exist('results','var') == 0
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required resistance data file does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end


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

%# _averaged_corr_shallow_water directory ---------------------------------
setDirName = '_plots/_averaged_corr_shallow_water';

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
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ************************************************************************


%# ************************************************************************
%# START Averaging Repeated Run Data
%# ------------------------------------------------------------------------

cond1=[];cond2=[];cond3=[];cond4=[];cond5=[];cond6=[];cond7=[];cond8=[];cond9=[];cond10=[];cond11=[];cond12=[];cond13=[];

R = results;            % Results array
R(all(R==0,2),:) = [];  % Remove Zero rows from array
[m,n] = size(R);        % Array dimensions

% Split results array based on column 28 (test condition)
A = arrayfun(@(x) R(R(:,28) == x, :), unique(R(:,28)), 'uniformoutput', false);
[ma,na] = size(A);      % Array dimensions

% Create a new array for each condition
for j=1:ma
    if A{j}(1,28) == 1
        cond1 = A{j};
    end
    if A{j}(1,28) == 2
        cond2 = A{j};
    end
    if A{j}(1,28) == 3
        cond3 = A{j};
    end
    if A{j}(1,28) == 4
        cond4 = A{j};
    end
    if A{j}(1,28) == 5
        cond5 = A{j};
    end
    if A{j}(1,28) == 6
        cond6 = A{j};
    end
    if A{j}(1,28) == 7
        cond7 = A{j};
    end
    if A{j}(1,28) == 8
        cond8 = A{j};
    end
    if A{j}(1,28) == 9
        cond9 = A{j};
    end
    if A{j}(1,28) == 10
        cond10 = A{j};
    end
    if A{j}(1,28) == 11
        cond11 = A{j};
    end
    if A{j}(1,28) == 12
        cond12 = A{j};
    end
    if A{j}(1,28) == 13
        cond13 = A{j};
    end
end

%# Testname
testName = 'Averaged Repeated Runs Data Plots';

%# Min & Max Values
[minmaxcond1]  = stats_minmax(cond1);
[minmaxcond2]  = stats_minmax(cond2);
[minmaxcond3]  = stats_minmax(cond3);
[minmaxcond4]  = stats_minmax(cond4);
[minmaxcond5]  = stats_minmax(cond5);
[minmaxcond6]  = stats_minmax(cond6);
[minmaxcond7]  = stats_minmax(cond7);
[minmaxcond8]  = stats_minmax(cond8);
[minmaxcond9]  = stats_minmax(cond9);
[minmaxcond10] = stats_minmax(cond10);
[minmaxcond11] = stats_minmax(cond11);
[minmaxcond12] = stats_minmax(cond12);
[minmaxcond13] = stats_minmax(cond13);

%# Calculate averages for conditions
[avgcond1]  = stats_avg(1:15,results);
[avgcond2]  = stats_avg(16:25,results);
[avgcond3]  = stats_avg(26:35,results);
[avgcond4]  = stats_avg(36:44,results);
[avgcond5]  = stats_avg(45:53,results);
[avgcond6]  = stats_avg(54:62,results);
[avgcond7]  = stats_avg(63:141,results);
[avgcond8]  = stats_avg(142:156,results);
[avgcond9]  = stats_avg(157:171,results);
[avgcond10] = stats_avg(172:201,results);
[avgcond11] = stats_avg(202:216,results);
[avgcond12] = stats_avg(217:231,results);
[avgcond13] = stats_avg(232:249,results);

% Complete set of averaged values for saving
resultsAveragedArray = [
    avgcond1;
    avgcond2;
    avgcond3;
    avgcond4;
    avgcond5;
    avgcond6;
    avgcond7;
    avgcond8;
    avgcond9;
    avgcond10;
    avgcond11;
    avgcond12;
    avgcond13
    ];

%# ------------------------------------------------------------------------
%# END Averaging Repeated Run Data
%# ************************************************************************


%# ************************************************************************
%# START Write results to DAT or TXT file
%# ------------------------------------------------------------------------
M = resultsAveragedArray;
csvwrite('resultsAveragedArray.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsAveragedArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
%# ------------------------------------------------------------------------
%# END Write results to DAT or TXT file
%# ************************************************************************


%# ************************************************************************
%# 0. Condition 7: Loop through averaged run values
%# ************************************************************************

AD    = avgcond7; % Active dataset (AD)
[m,n] = size(AD);

RRArray = [];

% RRArray columns
% [1]  Froude length number                                     (-)
%# Uncorrected:
% [2]  Grigson: Model rscale esidual resistance coeff., CRm     (-)
% [3]  ITTC'57: Model rscale esidual resistance coeff., CRm     (-)
%# Corrected: Tamura
% [4]  Grigson: Model rscale esidual resistance coeff., CRm     (-)
% [5]  ITTC'57: Model rscale esidual resistance coeff., CRm     (-)
% [6]  Grigson: CR(shallow)-CR(deep)/CR(deep)                   (-)
% [7]  ITTC'57: CR(shallow)-CR(deep)/CR(deep)                   (-)
%# Corrected: Schuster
% [8]  Grigson: Model rscale esidual resistance coeff., CRm     (-)
% [9]  ITTC'57: Model rscale esidual resistance coeff., CRm     (-)
% [10] Grigson: CR(shallow)-CR(deep)/CR(deep)                   (-)
% [11] ITTC'57: CR(shallow)-CR(deep)/CR(deep)                   (-)
%# Corrected: Scott
% [12] Grigson: Model rscale esidual resistance coeff., CRm     (-)
% [13] ITTC'57: Model rscale esidual resistance coeff., CRm     (-)
% [14] Grigson: CR(shallow)-CR(deep)/CR(deep)                   (-)
% [15] ITTC'57: CR(shallow)-CR(deep)/CR(deep)                   (-)

RAUncorrected       = [];
RACorrectedTamura   = [];
RACorrectedSchuster = [];
RACorrectedScott    = [];

% RAUncorr. and RACorr. columns (Catamaran, two demihulls):
% [1]  Froude length number                                     (-)
% >> Model scale ----------------------------------------------------------
% [2]  Model speed, Vm                                          (m/s)
% [3]  Model scale Reynolds number, Rem                         (-)
% [4]  Model scale resistance, RTm                              (N)
% [5]  Model scale resistan coefficient, CTm                    (-)
% [6]  Grigson: Model scale frictional resistance coeff., CFm   (-)
% [7]  ITTC'57: Model scale frictional resistance coeff., CFm   (-)
% [8]  Grigson: Model rscale esidual resistance coeff., CRm     (-)
% [9]  ITTC'57: Model scale residual resistance coeff., CRm     (-)
% >> Full scale -----------------------------------------------------------
% [10] Full scale speed, Vs                                     (m/s)
% [11] Full scale speed, Vs                                     (knots)
% [12] Full scale Reynolds number, Rem                          (-)
% [13] Roughness allowance, delta CF                            (-)
% [14] Correlation allowance, Ca                                (-)
% [15] Air resistance coefficient in full scale                 (-)
% [16] Grigson: Full scale resistace, RTs                       (N)
% [17] ITTC'57: Full scale resistace, RTs                       (N)
% [18] Grigson: Full scale resistance coefficient, CTs          (-)
% [19] ITTC'57: Full scale resistance coefficient, CTs          (-)
% [20] Grigson: Full scale frictional resistance coeff., CFs    (-)
% [21] ITTC'57: Full scale frictional resistance coeff., CFs    (-)
% [22] Grigson: Full rscale esidual resistance coeff., CRs      (-)
% [23] ITTC'57: Full rscale esidual resistance coeff., CRs      (-)
% [24] Grigson: Grigson: Full scale resistace, RTs              (kN)
% [25] ITTC'57: Grigson: Full scale resistace, RTs              (kN)

% Set shorter variables
% TODO: Add switch for other test conditions if required
testcond     = AD(1,28);
MSlwl        = MSlwl1500;
MSwsa        = MSwsa1500;
MSwsaDTA     = MSwsaDTA1500;
MSwsaCorrDTA = MSwsaCorrDTA1500;
MSdraft      = MSdraft1500;
FSlwl        = FSlwl1500;
FSwsa        = FSwsa1500;
FSdraft      = FSdraft1500;
MSAx         = MSAx1500;
BlockCoeff   = BlockCoeff1500;
AreaRatio    = MSAx/(ttwaterdepth*ttwidth);

for k=1:m
    
    % Set variables -------------------------------------------------------
    FroudeNo = AD(k,11);
    
    % Use corrected WSA (i.e. subtracted transom area) when Fr > 0.3
    if FroudeNo > 0.3
        MSCatWSA = 2*MSwsaCorrDTA;
    else
        MSCatWSA = 2*MSwsa;
    end
    
    MSCatRTm      = 2*AD(k,9);
    MSSpeed       = AD(k,5);
    DepthFroudeNo = MSSpeed/sqrt(gravconst*ttwaterdepth);
    
    %# ********************************************************************
    %# 1. Condition 7: Resistance Summary (Uncorrected)
    %# ********************************************************************
    
    MSReynoldsNo    = (MSSpeed*MSlwl)/MSKinVis;
    MSCatCTm        = MSCatRTm/(0.5*freshwaterdensity*MSCatWSA*MSSpeed^2);
    
    if MSReynoldsNo < 10000000
        MSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        MSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    MSCatITTC57CFm  = 0.075/(log10(MSReynoldsNo)-2)^2;
    
    MSCatGrigsonCRm = MSCatCTm-FormFactor*MSCatGrigsonCFm;
    MSCatITTC57CRm  = MSCatCTm-FormFactor*MSCatITTC57CFm;
    
    % Start writing to residual resistance array
    % Note: Fpr CR(shallow)-CR(deep)/CR(deep) vs. Froude length number plot
    RRArray(k,1) = FroudeNo;
    RRArray(k,2) = MSCatGrigsonCRm;
    RRArray(k,3) = MSCatITTC57CRm;
    % End writing to residual resistance array
    
    FSSpeed      = MSSpeed*sqrt(FStoMSratio);
    FSSpeedKnots = FSSpeed/0.514444;
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;
    
    FSCatWSA     = MSCatWSA*FStoMSratio^2;
    
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSCatWSA));
    
    if FSReynoldsNo < 10000000
        FSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        FSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    FSCatITTC57CFm  = 0.075/(log10(FSReynoldsNo)-2)^2;
    
    FSCatGrigsonCRs = MSCatGrigsonCRm;
    FSCatITTC57CRs  = MSCatITTC57CRm;
    
    FSCatGrigsonCTs = FormFactor*FSCatGrigsonCFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatGrigsonCRs+FSAirResistanceCoeff;
    FSCatITTC57CTs  = FormFactor*FSCatITTC57CFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatITTC57CRs+FSAirResistanceCoeff;
    
    FSCatGrigsonRTs = FSCatGrigsonCTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    FSCatITTC57RTs  = FSCatITTC57CTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    
    % Write to array ------------------------------------------------------
    RAUncorrected(k,1)  = FroudeNo;
    RAUncorrected(k,2)  = MSSpeed;
    RAUncorrected(k,3)  = MSReynoldsNo;
    RAUncorrected(k,4)  = MSCatRTm;
    RAUncorrected(k,5)  = MSCatCTm;
    RAUncorrected(k,6)  = MSCatGrigsonCFm;
    RAUncorrected(k,7)  = MSCatITTC57CFm;
    RAUncorrected(k,8)  = MSCatGrigsonCRm;
    RAUncorrected(k,9)  = MSCatITTC57CRm;
    RAUncorrected(k,10) = FSSpeed;
    RAUncorrected(k,11) = FSSpeedKnots;
    RAUncorrected(k,12) = FSReynoldsNo;
    RAUncorrected(k,13) = FSRoughnessAllowance;
    RAUncorrected(k,14) = FSCorrelelationCoeff;
    RAUncorrected(k,15) = FSAirResistanceCoeff;
    RAUncorrected(k,16) = FSCatGrigsonRTs;
    RAUncorrected(k,17) = FSCatITTC57RTs;
    RAUncorrected(k,18) = FSCatGrigsonCTs;
    RAUncorrected(k,19) = FSCatITTC57CTs;
    RAUncorrected(k,20) = FSCatGrigsonCFm;
    RAUncorrected(k,21) = FSCatITTC57CFm;
    RAUncorrected(k,22) = FSCatGrigsonCRs;
    RAUncorrected(k,23) = FSCatITTC57CRs;
    RAUncorrected(k,24) = FSCatGrigsonRTs/1000;
    RAUncorrected(k,25) = FSCatITTC57RTs/1000;
    
    %# ********************************************************************
    %# 2. Condition 7: Resistance Summary (Corrected using Tamura)
    %# ********************************************************************
    
    % Start Tamura correction factors -------------------------------------
    MSCorrSpeedRatio = 0.67*AreaRatio*((MSlwl/ttwidth)^(3/4))*(1/(1-DepthFroudeNo^2));
    MSSpeedCorr      = MSSpeed*(1+MSCorrSpeedRatio);
    % End Tamura correction factors ---------------------------------------
    
    MSReynoldsNo    = (MSSpeedCorr*MSlwl)/MSKinVis;
    MSCatCTm        = MSCatRTm/(0.5*freshwaterdensity*MSCatWSA*MSSpeedCorr^2);
    
    if MSReynoldsNo < 10000000
        MSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        MSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    MSCatITTC57CFm  = 0.075/(log10(MSReynoldsNo)-2)^2;
    
    MSCatGrigsonCRm = MSCatCTm-FormFactor*MSCatGrigsonCFm;
    MSCatITTC57CRm  = MSCatCTm-FormFactor*MSCatITTC57CFm;
    
    % Start writing to residual resistance array
    % Note: Fpr CR(shallow)-CR(deep)/CR(deep) vs. Froude length number plot
    RRArray(k,4) = MSCatGrigsonCRm;
    RRArray(k,5) = MSCatITTC57CRm;
    RRArray(k,6) = (RRArray(k,2)-MSCatGrigsonCRm)/MSCatGrigsonCRm;
    RRArray(k,7) = (RRArray(k,3)-MSCatITTC57CRm)/MSCatITTC57CRm;
    % End writing to residual resistance array
    
    FSSpeed      = MSSpeed*sqrt(FStoMSratio);
    FSSpeedKnots = FSSpeed/0.514444;
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;
    
    FSCatWSA     = MSCatWSA*FStoMSratio^2;
    
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSCatWSA));
    
    if FSReynoldsNo < 10000000
        FSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        FSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    FSCatITTC57CFm  = 0.075/(log10(FSReynoldsNo)-2)^2;
    
    FSCatGrigsonCRs = MSCatGrigsonCRm;
    FSCatITTC57CRs  = MSCatITTC57CRm;
    
    FSCatGrigsonCTs = FormFactor*FSCatGrigsonCFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatGrigsonCRs+FSAirResistanceCoeff;
    FSCatITTC57CTs  = FormFactor*FSCatITTC57CFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatITTC57CRs+FSAirResistanceCoeff;
    
    FSCatGrigsonRTs = FSCatGrigsonCTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    FSCatITTC57RTs  = FSCatITTC57CTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    
    % Write to array ------------------------------------------------------
    RACorrectedTamura(k,1)  = FroudeNo;
    RACorrectedTamura(k,2)  = MSSpeed;
    RACorrectedTamura(k,3)  = MSReynoldsNo;
    RACorrectedTamura(k,4)  = MSCatRTm;
    RACorrectedTamura(k,5)  = MSCatCTm;
    RACorrectedTamura(k,6)  = MSCatGrigsonCFm;
    RACorrectedTamura(k,7)  = MSCatITTC57CFm;
    RACorrectedTamura(k,8)  = MSCatGrigsonCRm;
    RACorrectedTamura(k,9)  = MSCatITTC57CRm;
    RACorrectedTamura(k,10) = FSSpeed;
    RACorrectedTamura(k,11) = FSSpeedKnots;
    RACorrectedTamura(k,12) = FSReynoldsNo;
    RACorrectedTamura(k,13) = FSRoughnessAllowance;
    RACorrectedTamura(k,14) = FSCorrelelationCoeff;
    RACorrectedTamura(k,15) = FSAirResistanceCoeff;
    RACorrectedTamura(k,16) = FSCatGrigsonRTs;
    RACorrectedTamura(k,17) = FSCatITTC57RTs;
    RACorrectedTamura(k,18) = FSCatGrigsonCTs;
    RACorrectedTamura(k,19) = FSCatITTC57CTs;
    RACorrectedTamura(k,20) = FSCatGrigsonCFm;
    RACorrectedTamura(k,21) = FSCatITTC57CFm;
    RACorrectedTamura(k,22) = FSCatGrigsonCRs;
    RACorrectedTamura(k,23) = FSCatITTC57CRs;
    RACorrectedTamura(k,24) = FSCatGrigsonRTs/1000;
    RACorrectedTamura(k,25) = FSCatITTC57RTs/1000;
    
    %# ********************************************************************
    %# 3. Condition 7: Resistance Summary (Corrected using Schuster)
    %# ********************************************************************
    
    MSReynoldsNo    = (MSSpeed*MSlwl)/MSKinVis;
    MSCatCTm        = MSCatRTm/(0.5*freshwaterdensity*MSCatWSA*MSSpeed^2);
    
    if MSReynoldsNo < 10000000
        MSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        MSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    MSCatITTC57CFm  = 0.075/(log10(MSReynoldsNo)-2)^2;
    
    MSCatGrigsonCRm = MSCatCTm-FormFactor*MSCatGrigsonCFm;
    MSCatITTC57CRm  = MSCatCTm-FormFactor*MSCatITTC57CFm;
    
    % Start Schuster correction factors -----------------------------------
    MSGrigsonRv = MSCatGrigsonCFm*(0.5*freshwaterdensity*MSCatWSA*MSSpeed^2);
    MSITTC57Rv  = MSCatITTC57CFm*(0.5*freshwaterdensity*MSCatWSA*MSSpeed^2);
    
    MSGrigsonCorrSpeedRatio = (AreaRatio/(1-AreaRatio-DepthFroudeNo^2))+(1-(MSGrigsonRv/MSCatRTm))*(2/3)*DepthFroudeNo^10;
    MSITTC57CorrSpeedRatio  = (AreaRatio/(1-AreaRatio-DepthFroudeNo^2))+(1-(MSITTC57Rv/MSCatRTm))*(2/3)*DepthFroudeNo^10;
    
    MSGrigsonSpeedCorr = MSSpeed*(1+MSGrigsonCorrSpeedRatio);
    MSITTC57SpeedCorr  = MSSpeed*(1+MSITTC57CorrSpeedRatio);
    % End Schuster correction factors -------------------------------------
    
    % Calculate Reynolds Number and CTm using Schuster corrected speed
    MSReynoldsNo = (MSGrigsonSpeedCorr*MSlwl)/MSKinVis;
    MSCatCTm     = MSCatRTm/(0.5*freshwaterdensity*MSCatWSA*MSGrigsonSpeedCorr^2);
    
    if MSReynoldsNo < 10000000
        MSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        MSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    MSCatITTC57CFm  = 0.075/(log10(MSReynoldsNo)-2)^2;
    
    MSCatGrigsonCRm = MSCatCTm-FormFactor*MSCatGrigsonCFm;
    MSCatITTC57CRm  = MSCatCTm-FormFactor*MSCatITTC57CFm;
    
    % Start writing to residual resistance array
    % Note: Fpr CR(shallow)-CR(deep)/CR(deep) vs. Froude length number plot
    RRArray(k,8)  = MSCatGrigsonCRm;
    RRArray(k,9)  = MSCatITTC57CRm;
    RRArray(k,10) = (RRArray(k,2)-MSCatGrigsonCRm)/MSCatGrigsonCRm;
    RRArray(k,11) = (RRArray(k,3)-MSCatITTC57CRm)/MSCatITTC57CRm;
    % End writing to residual resistance array    
    
    FSSpeed      = MSSpeed*sqrt(FStoMSratio);
    FSSpeedKnots = FSSpeed/0.514444;
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;
    
    FSCatWSA     = MSCatWSA*FStoMSratio^2;
    
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSCatWSA));
    
    if FSReynoldsNo < 10000000
        FSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        FSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    FSCatITTC57CFm  = 0.075/(log10(FSReynoldsNo)-2)^2;
    
    FSCatGrigsonCRs = MSCatGrigsonCRm;
    FSCatITTC57CRs  = MSCatITTC57CRm;
    
    FSCatGrigsonCTs = FormFactor*FSCatGrigsonCFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatGrigsonCRs+FSAirResistanceCoeff;
    FSCatITTC57CTs  = FormFactor*FSCatITTC57CFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatITTC57CRs+FSAirResistanceCoeff;
    
    FSCatGrigsonRTs = FSCatGrigsonCTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    FSCatITTC57RTs  = FSCatITTC57CTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    
    % Write to array ------------------------------------------------------
    RACorrectedSchuster(k,1)  = FroudeNo;
    RACorrectedSchuster(k,2)  = MSSpeed;
    RACorrectedSchuster(k,3)  = MSReynoldsNo;
    RACorrectedSchuster(k,4)  = MSCatRTm;
    RACorrectedSchuster(k,5)  = MSCatCTm;
    RACorrectedSchuster(k,6)  = MSCatGrigsonCFm;
    RACorrectedSchuster(k,7)  = MSCatITTC57CFm;
    RACorrectedSchuster(k,8)  = MSCatGrigsonCRm;
    RACorrectedSchuster(k,9)  = MSCatITTC57CRm;
    RACorrectedSchuster(k,10) = FSSpeed;
    RACorrectedSchuster(k,11) = FSSpeedKnots;
    RACorrectedSchuster(k,12) = FSReynoldsNo;
    RACorrectedSchuster(k,13) = FSRoughnessAllowance;
    RACorrectedSchuster(k,14) = FSCorrelelationCoeff;
    RACorrectedSchuster(k,15) = FSAirResistanceCoeff;
    RACorrectedSchuster(k,16) = FSCatGrigsonRTs;
    RACorrectedSchuster(k,17) = FSCatITTC57RTs;
    RACorrectedSchuster(k,18) = FSCatGrigsonCTs;
    RACorrectedSchuster(k,19) = FSCatITTC57CTs;
    RACorrectedSchuster(k,20) = FSCatGrigsonCFm;
    RACorrectedSchuster(k,21) = FSCatITTC57CFm;
    RACorrectedSchuster(k,22) = FSCatGrigsonCRs;
    RACorrectedSchuster(k,23) = FSCatITTC57CRs;
    RACorrectedSchuster(k,24) = FSCatGrigsonRTs/1000;
    RACorrectedSchuster(k,25) = FSCatITTC57RTs/1000;
    
    %# ********************************************************************
    %# 4. Condition 7: Resistance Summary (Corrected using Scott)
    %# ********************************************************************
    
    MSReynoldsNo = (MSSpeed*MSlwl)/MSKinVis;
    
    % Start Scott correction factors --------------------------------------
    DispLengthRatio = (BlockCoeff*MS1500tVolume^(1/3))/MSlwl;
    
    % K1 constants --------------------------------------------------------
    if DispLengthRatio < 0.9
        if MSReynoldsNo <= 5.8*10^6
            %disp('A1');
            K1 = (-1E-09)*MSReynoldsNo+1.9005;
        elseif MSReynoldsNo > 5.8*10^6 && MSReynoldsNo < 1.97*10^7
            %disp('A2');
            K1 = (-1E-07)*MSReynoldsNo+2.4732;
        end
    elseif DispLengthRatio >= 0.9 && DispLengthRatio <= 0.11
        if MSReynoldsNo <= 5.2*10^6
            %disp('B1');
            K1 = (-2E-09)*MSReynoldsNo+1.5965;
        elseif MSReynoldsNo > 5.2*10^6 && MSReynoldsNo <= 7.9*10^6
            %disp('B2');
            K1 = (-1E-07)*MSReynoldsNo+2.1636;
        elseif MSReynoldsNo > 7.9*10^6 && MSReynoldsNo < 1.88*10^7
            %disp('B3');
            K1 = (-7E-08)*MSReynoldsNo+1.867;
        end
    elseif DispLengthRatio > 0.11
        if MSReynoldsNo <= 4.81*10^6
            %disp('C1');
            K1 = (-5E-10)*MSReynoldsNo+1.2935;
        elseif MSReynoldsNo > 4.81*10^6 && MSReynoldsNo <= 8.3*10^6
            %disp('C2');
            K1 = (-1E-07)*MSReynoldsNo+1.8925;
        elseif MSReynoldsNo > 8.3*10^6 && MSReynoldsNo < 1.71*10^7
            %disp('C3');
            K1 = (-4E-08)*MSReynoldsNo+1.1928;
        end
    end
    
    % K2 constants --------------------------------------------------------
    
    if FroudeNo > 0.22 && FroudeNo < 0.40
        K2 = 2.4*(FroudeNo-0.22)^2;
    elseif FroudeNo < 0.22
        K2 = 0;
    else
        K2 = 0;        
    end
    
    % TODO: EITHER K1, K2 or any other variables in MSSpeedRatio are wrong
    %       as resulting speed is too hight!!!
    MSSpeedRatio = K1*MS1500tVolume*((ttwaterdepth*ttwidth)^(-3/2))+(4.5/21.6)*(MSlwl^2)*K2*((ttwaterdepth*ttwidth)^(-3/2));
    MSSpeedCorr  = MSSpeed*(1+MSSpeedRatio);  

    % End Scott correction factors ----------------------------------------
    
    MSReynoldsNo    = (MSSpeedCorr*MSlwl)/MSKinVis;
    MSCatCTm        = MSCatRTm/(0.5*freshwaterdensity*MSCatWSA*MSSpeedCorr^2);
    
    if MSReynoldsNo < 10000000
        MSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        MSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    MSCatITTC57CFm  = 0.075/(log10(MSReynoldsNo)-2)^2;
    
    MSCatGrigsonCRm = MSCatCTm-FormFactor*MSCatGrigsonCFm;
    MSCatITTC57CRm  = MSCatCTm-FormFactor*MSCatITTC57CFm;
    
    % Start writing to residual resistance array
    % Note: Fpr CR(shallow)-CR(deep)/CR(deep) vs. Froude length number plot
    RRArray(k,12) = MSCatGrigsonCRm;
    RRArray(k,13) = MSCatITTC57CRm;
    RRArray(k,14) = (RRArray(k,2)-MSCatGrigsonCRm)/MSCatGrigsonCRm;
    RRArray(k,15) = (RRArray(k,3)-MSCatITTC57CRm)/MSCatITTC57CRm;
    % End writing to residual resistance array        
    
    FSSpeed      = MSSpeed*sqrt(FStoMSratio);
    FSSpeedKnots = FSSpeed/0.514444;
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;
    
    FSCatWSA     = MSCatWSA*FStoMSratio^2;
    
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSCatWSA));
    
    if FSReynoldsNo < 10000000
        FSCatGrigsonCFm = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
    else
        FSCatGrigsonCFm = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
    end
    FSCatITTC57CFm  = 0.075/(log10(FSReynoldsNo)-2)^2;
    
    FSCatGrigsonCRs = MSCatGrigsonCRm;
    FSCatITTC57CRs  = MSCatITTC57CRm;
    
    FSCatGrigsonCTs = FormFactor*FSCatGrigsonCFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatGrigsonCRs+FSAirResistanceCoeff;
    FSCatITTC57CTs  = FormFactor*FSCatITTC57CFm+FSRoughnessAllowance+FSCorrelelationCoeff+FSCatITTC57CRs+FSAirResistanceCoeff;
    
    FSCatGrigsonRTs = FSCatGrigsonCTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);
    FSCatITTC57RTs  = FSCatITTC57CTs*(0.5*saltwaterdensity*FSCatWSA*FSSpeed^2);    
    
    % Write to array ------------------------------------------------------
    RACorrectedScott(k,1)  = FroudeNo;
    RACorrectedScott(k,2)  = MSSpeed;
    RACorrectedScott(k,3)  = MSReynoldsNo;
    RACorrectedScott(k,4)  = MSCatRTm;
    RACorrectedScott(k,5)  = MSCatCTm;
    RACorrectedScott(k,6)  = MSCatGrigsonCFm;
    RACorrectedScott(k,7)  = MSCatITTC57CFm;
    RACorrectedScott(k,8)  = MSCatGrigsonCRm;
    RACorrectedScott(k,9)  = MSCatITTC57CRm;
    RACorrectedScott(k,10) = FSSpeed;
    RACorrectedScott(k,11) = FSSpeedKnots;
    RACorrectedScott(k,12) = FSReynoldsNo;
    RACorrectedScott(k,13) = FSRoughnessAllowance;
    RACorrectedScott(k,14) = FSCorrelelationCoeff;
    RACorrectedScott(k,15) = FSAirResistanceCoeff;
    RACorrectedScott(k,16) = FSCatGrigsonRTs;
    RACorrectedScott(k,17) = FSCatITTC57RTs;
    RACorrectedScott(k,18) = FSCatGrigsonCTs;
    RACorrectedScott(k,19) = FSCatITTC57CTs;
    RACorrectedScott(k,20) = FSCatGrigsonCFm;
    RACorrectedScott(k,21) = FSCatITTC57CFm;
    RACorrectedScott(k,22) = FSCatGrigsonCRs;
    RACorrectedScott(k,23) = FSCatITTC57CRs;
    RACorrectedScott(k,24) = FSCatGrigsonRTs/1000;
    RACorrectedScott(k,25) = FSCatITTC57RTs/1000;    
    
end


%# ************************************************************************
%# 5. Plottting results
%# ************************************************************************

%# Plotting Uncorrected and Corrected Resistance --------------------------
figurename = 'Plot 1: Uncorrected and Corrected Resistance';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
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
setMarkerSize      = 8;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '-.';
setLineStyle2      = '-.';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

% Uncorrected
x1 = RAUncorrected(:,11);
y1 = RAUncorrected(:,24);

% Corrected using Tamura
x2 = RACorrectedTamura(:,11);
y2 = RACorrectedTamura(:,24);

% Corrected using Schuster
x3 = RACorrectedSchuster(:,11);
y3 = RACorrectedSchuster(:,24);

% Corrected using Scott
x4 = RACorrectedScott(1:17,11);
y4 = RACorrectedScott(1:17,24);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-',x3,y3,'*-',x4,y4,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Total resistance, R_{T} (kN)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Blockage and depth corrections}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h(1),'Color',setColor{1},'Marker','none','LineStyle','-','linewidth',setLineWidth);
%set(h(2),'Color',setColor{2},'Marker','none','LineStyle','--','linewidth',setLineWidth);
%set(h(3),'Color',setColor{3},'Marker','none','LineStyle','-.','linewidth',setLineWidth);
%set(h(4),'Color',setColor{4},'Marker','none','LineStyle',':','linewidth',setLineWidth);
%set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-','linewidth',setLineWidth);
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--','linewidth',setLineWidth);
set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.','linewidth',setLineWidth);
set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',':','linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 5;
maxX  = 29;
incrX = 2;
minY  = 0;
maxY  = 800;
incrY = 100;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend('R_{TBH}','Tamura','Schuster','Scott');
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

% Differences -------------------------------------------------------------

[md,nd] = size(RAUncorrected);

for kd=1:md
    differencesArray(kd,1) = RAUncorrected(kd,1);
    differencesArray(kd,2) = RAUncorrected(kd,11);
    differencesArray(kd,3) = (1-(RACorrectedTamura(kd,16)/RAUncorrected(kd,16)))*100;
    differencesArray(kd,4) = (1-(RACorrectedSchuster(kd,16)/RAUncorrected(kd,16)))*100;
    differencesArray(kd,5) = (1-(RACorrectedScott(kd,16)/RAUncorrected(kd,16)))*100;
end

%# X and Y axis -----------------------------------------------------------

% Uncorrected to Tamura
x1 = differencesArray(:,2);
y1 = differencesArray(:,3);

% Uncorrected to Schuster
x2 = differencesArray(:,2);
y2 = differencesArray(:,4);

% Uncorrected to Scott
x3 = differencesArray(1:17,2);
y3 = differencesArray(1:17,5);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-',x3,y3,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Differences uncorrected to corrected}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h(1),'Color',setColor{1},'LineStyle',setLineStyle,'linewidth',setLineWidth);
%set(h(2),'Color',setColor{2},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
%set(h(3),'Color',setColor{3},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--','linewidth',setLineWidth);
set(h(2),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.','linewidth',setLineWidth);
set(h(3),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',':','linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 5;
maxX  = 29;
incrX = 2;
minY  = 0;
maxY  = 16;
incrY = 2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend('R_{TBH} to Tamura','R_{TBH} to Schuster','R_{TBH} to Scott');
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
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Uncorrected_and_Corrected_Resistance_Comparison_Plot.%s', '_averaged_corr_shallow_water', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# Plotting Uncorrected and Corrected Resistance --------------------------
figurename = 'Plot 2: Uncorrected and Corrected Resistance';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
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
setLineStyle2      = '-.';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

% Uncorrected
x1 = RAUncorrected(:,1);
y1 = RAUncorrected(:,8);

% Corrected using Tamura
x2 = RACorrectedTamura(:,1);
y2 = RACorrectedTamura(:,8);

% Corrected using Schuster
x3 = RACorrectedSchuster(:,1);
y3 = RACorrectedSchuster(:,8);

% Corrected using Scott
x4 = RACorrectedScott(1:17,1);
y4 = RACorrectedScott(1:17,8);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-',x3,y3,'*-',x4,y4,'*-');
xlabel('{\bf Froude length number (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Residual resistance coefficient, C_{R} (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Residual resistance comparison}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h(1),'Color',setColor{1},'Marker','none','LineStyle','-','linewidth',setLineWidth);
%set(h(2),'Color',setColor{2},'Marker','none','LineStyle','--','linewidth',setLineWidth);
%set(h(3),'Color',setColor{3},'Marker','none','LineStyle','-.','linewidth',setLineWidth);
%set(h(4),'Color',setColor{4},'Marker','none','LineStyle',':','linewidth',setLineWidth);
%set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-','linewidth',setLineWidth);
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--','linewidth',setLineWidth);
set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.','linewidth',setLineWidth);
set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',':','linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 0.1;
maxX  = 0.5;
incrX = 0.05;
minY  = 0.001;
maxY  = 0.0035;
incrY = 0.0005;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.4f'));

%# Legend
hleg1 = legend('R_{TBH}','Tamura','Schuster','Scott');
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

% Tamura
x1 = RRArray(:,1);
y1 = RRArray(:,6);

% Schuster
x2 = RRArray(:,1);
y2 = RRArray(:,10);

% Scott
x3 = RRArray(1:17,1);
y3 = RRArray(1:17,14);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-',x3,y3,'*-');
xlabel('{\bf Froude length number (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf (CR(shallow)-CR(deep)) / CR(deep) (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Residual resistance comparison}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h(1),'Color',setColor{1},'Marker','none','LineStyle','-','linewidth',setLineWidth);
%set(h(2),'Color',setColor{2},'Marker','none','LineStyle','--','linewidth',setLineWidth);
%set(h(3),'Color',setColor{3},'Marker','none','LineStyle','-.','linewidth',setLineWidth);
%set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--','linewidth',setLineWidth);
set(h(2),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.','linewidth',setLineWidth);
set(h(3),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',':','linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 0.1;
maxX  = 0.5;
incrX = 0.05;
minY  = 0;
maxY  = 0.35;
incrY = 0.05;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend('Tamura','Schuster','Scott');
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
    plotsavename = sprintf('_plots/%s/%s/Plot_2_Uncorrected_and_Corrected_Resistance_Comparison_Plot.%s', '_averaged_corr_shallow_water', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 6. Clear variables
%# ************************************************************************
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
