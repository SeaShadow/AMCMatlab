%# ------------------------------------------------------------------------
%# Resistance Test Analysis - ITTC Based Uncertainty Analysis
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  June 11, 2015
%#
%# Test date  :  August 27 to September 6, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  Runs 01-35   Turbulence Studs Investigation               (TSI)
%#               |__Disp. & trim:   1,500t, level static trim
%#               |__Conditions:     1 = No turbulence studs
%#                                  2 = First row of turbulence studs
%#                                  3 = First and seCond. row of turbulence studs
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
%# Description    :  Uncertainty analysis for multiple tests as outlined
%#                   by ITTC including resistance, speed, sinkage and
%#                   trim measurements.
%#
%# ITTC Guidelines:  7.5-02-02-01
%#                   7.5-02-02-02
%#                   7.5-02-02-03
%#                   7.5-02-02-04
%#                   7.5-02-02-05
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
%#               6 => analysis_ts.m       >> Time series data for Cond. 7-12
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
%#               9 => analysis_ts_drag.m  >> Time series data for Cond. 7-12
%#                    |                   >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               10 => analysis_ts_drag_fft.m  >> Time series data for Cond. 7-12
%#                    |                        >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               >>> TODO: Copy data from frequencyArrayFFT.dat to fft_frequency_data.dat
%#
%#               11 => analysis_ts_dp.m  >> Time series data for Cond. 7-12
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
%# CHANGES    :  21/01/2014 - Created new script
%#               08/10/2014 - Updated kinematic viscosity + density values
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


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

% Time series data
enableTSDataSave          = 0;    % Enable time series data saving

% Main and plot titles
enablePlotMainTitle       = 0;    % Show plot title in saved file
enablePlotTitle           = 1;    % Show plot title above plot
enableTextOnPlot          = 0;    % Show text on plot
enableBlackAndWhitePlot   = 1;    % Show plot in black and white
enableEqnOfFitPlot        = 0;    % Show equations of fit
enableCommandWindowOutput = 0;    % Show command windown ouput

% Enable individual plots
enablePlot1               = 1;    % Scatter plot: 1,500t and 1,804t total uncertainty
enablePlot1_1             = 0;    % Scatter plot: 1,500t and 1,804t total uncertainty (fitted curves)
enablePlot1_2             = 0;    % Scatter plot: 1,500t and 1,804t total uncertainty (fitted curves)
enablePlot1_3             = 0;    % Scatter plot: 1,500t 95% probability
enablePlot1_4             = 0;    % Scatter plot: 1,808t 95% probability
enablePlot1_5             = 1;    % Bar plot: Fitted total uncertatnty (Fr range 0.2-0.5)
enablePlot1_6             = 1;    % Bar plot: Fitted total uncertatnty (Fr range 0.1-0.2)
enablePlot2               = 0;    % Bar plot: 1,500t total uncertainty
enablePlot3               = 0;    % Bar plot: 1,808t total uncertainty

% Scaled to A4 paper
enableA4PaperSizePlot     = 1;    % Show plots scale to A4 size

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


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
    %[17] Model (CFm) Frictional Resistance Coefficient (ITTC'57)                  (-)
    %[18] Model (CFm) Frictional Resistance Coefficient (Grigson)                  (-)
    %[19] Model (CRm) Residual Resistance Coefficient                              (-)
    %[20] Model (PEm) Model Effective Power                                        (W)
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    %[23] Full Scale (CFs) Frictional Resistance Coefficient (ITTC'57)             (-)
    %[24] Full Scale (CTs) Total resistance Coefficient                            (-)
    %[25] Full Scale (RTs) Total resistance (Rt)                                   (N)
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


% /////////////////////////////////////////////////////////////////////
% START: CREATE PLOTS AND RUN DIRECTORY
% ---------------------------------------------------------------------

fPath = sprintf('_plots/%s', '_uncertainty_analysis');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', '_uncertainty_analysis', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', '_uncertainty_analysis', 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', '_uncertainty_analysis', 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

% ---------------------------------------------------------------------
% END: CREATE PLOTS AND RUN DIRECTORY
% /////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth*ttwaterdepth;   % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 17.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500           = 4.30;                              % Model length waterline          (m)
MSwsa1500           = 1.501;                             % Model scale wetted surface area (m^2)
MSdraft1500         = 0.133;                             % Model draft                     (m)
MSbeam1500          = 0.208;                             % Model beam                      (m)
MSAx1500            = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500      = 0.592;                             % Mode block coefficient          (-)
FSlwl1500           = MSlwl1500*FStoMSratio;             % Full scale length waterline     (m)
FSwsa1500           = MSwsa1500*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft1500         = MSdraft1500*FStoMSratio;           % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, -0.5 degrees by bow, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500bybow      = 4.328;                             % Model length waterline          (m)
MSwsa1500bybow      = 1.48;                              % Model scale wetted surface area (m^2)
MSdraft1500bybow    = 0.138;                             % Model draft                     (m)
MSbeam1500bybow     = 0.208;                             % Model beam                      (m)
MSAx1500bybow       = 0.025;                             % Model area of max. transverse section (m^2)
BlockCoeff1500bybow = 0.570;                             % Mode block coefficient          (-)
FSlwl1500bybow      = MSlwl1500bybow*FStoMSratio;        % Full scale length waterline     (m)
FSwsa1500bybow      = MSwsa1500bybow*FStoMSratio^2;      % Full scale wetted surface area  (m^2)
FSdraft1500bybow    = MSdraft1500bybow*FStoMSratio;      % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500bystern      = 4.216;                           % Model length waterline          (m)
MSwsa1500bystern      = 1.52;                            % Model scale wetted surface area (m^2)
MSdraft1500bystern    = 0.131;                           % Model draft                     (m)
MSbeam1500bystern     = 0.208;                           % Model beam                      (m)
MSAx1500bystern       = 0.024;                           % Model area of max. transverse section (m^2)
BlockCoeff1500bystern = 0.614;                           % Mode block coefficient          (-)
FSlwl1500bystern      = MSlwl1500bystern*FStoMSratio;    % Full scale length waterline     (m)
FSwsa1500bystern      = MSwsa1500bystern*FStoMSratio^2;  % Full scale wetted surface area  (m^2)
FSdraft1500bystern    = MSdraft1500bystern*FStoMSratio;  % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, deep transom for prohaska runs, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500prohaska     = 3.78;                            % Model length waterline          (m)
MSwsa1500prohaska     = 1.49;                            % Model scale wetted surface area (m^2)
MSdraft1500prohaska   = 0.133;                           % Model draft                     (m)
FSlwl1500prohaska     = MSlwl1500prohaska*FStoMSratio;   % Full scale length waterline     (m)
FSwsa1500prohaska     = MSwsa1500prohaska*FStoMSratio^2; % Full scale wetted surface area  (m^2)
FSdraft1500prohaska   = MSdraft1500prohaska*FStoMSratio; % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////


%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,804 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804          = 4.222;                              % Model length waterline          (m)
MSwsa1804          = 1.68;                               % Model scale wetted surface area (m^2)
MSdraft1804        = 0.153;                              % Model draft                     (m)
MSbeam1804         = 0.208;                              % Model beam                      (m)
MSAx1804           = 0.028;                              % Model area of max. transverse section (m^2)
BlockCoeff1804     = 0.631;                              % Mode block coefficient          (-)
FSlwl1804          = MSlwl1804*FStoMSratio;              % Full scale length waterline     (m)
FSwsa1804          = MSwsa1804*FStoMSratio^2;            % Full scale wetted surface area  (m^2)
FSdraft1804        = MSdraft1804*FStoMSratio;            % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, -0.5 degrees by bow, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bybow      = 4.306;                             % Model length waterline          (m)
MSwsa1804bybow      = 1.66;                              % Model scale wetted surface area (m^2)
MSdraft1804bybow    = 0.157;                             % Model draft                     (m)
MSbeam1804bybow     = 0.208;                             % Model beam                      (m)
MSAx1804bybow       = 0.030;                             % Model area of max. transverse section (m^2)
BlockCoeff1804bybow = 0.603;                             % Mode block coefficient          (-)
FSlwl1804bybow      = MSlwl1804bybow*FStoMSratio;        % Full scale length waterline     (m)
FSwsa1804bybow      = MSwsa1804bybow*FStoMSratio^2;      % Full scale wetted surface area  (m^2)
FSdraft1804bybow    = MSdraft1804bybow*FStoMSratio;      % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bystern      = 4.107;                           % Model length waterline          (m)
MSwsa1804bystern      = 1.70;                            % Model scale wetted surface area (m^2)
MSdraft1804bystern    = 0.151;                           % Model draft                     (m)
MSbeam1804bystern     = 0.208;                           % Model beam                      (m)
MSAx1804bystern       = 0.028;                           % Model area of max. transverse section (m^2)
BlockCoeff1804bystern = 0.657;                           % Mode block coefficient          (-)
FSlwl1804bystern      = MSlwl1804bystern*FStoMSratio;    % Full scale length waterline     (m)
FSwsa1804bystern      = MSwsa1804bystern*FStoMSratio^2;  % Full scale wetted surface area  (m^2)
FSdraft1804bystern    = MSdraft1804bystern*FStoMSratio;  % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


%# ************************************************************************
%# START: CALCULATING CONDITIONS, MIN, MAX AND AVERAGED DATA
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

%# ------------------------------------------------------------------------
%# END: CALCULATING CONDITIONS, MIN, MAX AND AVERAGED DATA
%# ************************************************************************


%# *********************************************************************
%# Testname
%# *********************************************************************
testName = 'Resistance uncertainty analysis';

%# ************************************************************************
%# ITTC Based Resistance Uncertainty Analysis (multipe tests)
%# ************************************************************************

% Loop through conditions
resultsArrayUARes = [];
UAThesisTable           = [];
counter1 = 1;
for condNo=7:13
    
    % Set variables based on condition number
    if condNo == 7
        setCond       = cond7;
        setCondNo     = 7;
        setModWsa     = MSwsa1500;
        setModLwl     = MSlwl1500;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;
    elseif condNo == 8
        setCond       = cond8;
        setCondNo     = 8;
        setModWsa     = MSwsa1500bybow;
        setModLwl     = MSlwl1500bybow;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;
    elseif condNo == 9
        setCond       = cond9;
        setCondNo     = 9;
        setModWsa     = MSwsa1500bystern;
        setModLwl     = MSlwl1500bystern;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;
    elseif condNo == 10
        setCond       = cond10;
        setCondNo     = 10;
        setModWsa     = MSwsa1804;
        setModLwl     = MSlwl1804;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;
    elseif condNo == 11
        setCond       = cond11;
        setCondNo     = 11;
        setModWsa     = MSwsa1804bybow;
        setModLwl     = MSlwl1804bybow;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;
    elseif condNo == 12
        setCond       = cond12;
        setCondNo     = 12;
        setModWsa     = MSwsa1804bystern;
        setModLwl     = MSlwl1804bystern;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;
    elseif condNo == 13
        setCond       = cond13;
        setCondNo     = 13;
        setModWsa     = MSwsa1500prohaska;
        setModLwl     = MSlwl1500prohaska;
        setBeam       = MSbeam1500;
        setFormFactor = 0.18;        
    else
        break;
    end
    
    % Split into individual arrays based on Froude length numbers
    R = setCond;
    A = arrayfun(@(x) R(R(:,11) == x, :), unique(R(:,11)), 'uniformoutput', false);
    [ma,na] = size(A);      % Array dimensions
    
    % Loop though speeds of selected condition
    for j=1:ma
        [mas,nas] = size(A{j});      % Array dimensions
        
        %# ////////////////////////////////////////////////////////////////
        %# 4. Input variables
        %# ////////////////////////////////////////////////////////////////
        
        % Total Resistance Coefficient (average @ 15 deg C)
        setCF15degC   = 0.075/(log10((A{j}(1,5)*setModLwl)/MSKinVis)-2)^2;
        
        % Frictional resistance coeff. at measured temp, tw
        setCFtw       = 0.075/(log10((A{j}(1,5)*setModLwl)/MSKinVis)-2)^2;
        
        %# ////////////////////////////////////////////////////////////////
        %# 3. Multiple test uncertainty
        %# ////////////////////////////////////////////////////////////////
        
        % Loop through individual array entries
        resultsArrayRT = [];
        counter2 = 1;
        for k=1:mas
            % CT
            resultsArrayRT(counter2, 1) = (2*A{j}(k,9))/(freshwaterdensity*setModWsa*A{j}(k,5)^2);
            
            % CT at 15 degrees C
            setCurrentCT = resultsArrayRT(counter2, 1);
            resultsArrayRT(counter2, 2) = setCurrentCT+((setCF15degC-setCFtw)*(1+setFormFactor));
            
            counter2 = counter2 + 1;
        end
        
        [oas,pas] = size(resultsArrayRT);
        %disp(sprintf('Run No.: %s || %s x %s',num2str(A{j}(k,1)),num2str(oas),num2str(pas)));
        
        % Total resistance coefficients and standard deviaton -------------
        
        % Total Resistance Coefficient CT values
        avgCT       = mean(resultsArrayRT(:,1));
        
        % Total Resistance Coefficient CT values
        avgCT15degC = mean(resultsArrayRT(:,2));
        
        % Standard deviation
        stdDev      = std(resultsArrayRT(:,1));
        
        %# ////////////////////////////////////////////////////////////////
        %# 4. Input variables (continued)
        %# ////////////////////////////////////////////////////////////////
        
        % Coverage factor for standard deviation:
        %   K = 2 (confidence level of approx. 95%)
        %   K = 3 (confidence level greater than 99%)
        setK = 2;
        
        % Resistance average (N)
        setRx = avgCT15degC*0.5*freshwaterdensity*setModWsa*A{j}(1,5)^2;
        
        % Total resistance mass in x-direction (Kg)
        setMx = setRx/gravconst;
        
        % Water temperature (deg C)
        setTw = ttwatertemp;
        
        % M(1 for single test, else multiple tests) (-)
        % NOTE: Number of repeats of this test (i.e. speed)
        setM = oas;

        %# ////////////////////////////////////////////////////////////////
        %# 6. Bias limits
        %# ////////////////////////////////////////////////////////////////
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.1 Wetted Surface
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % Bs1 (Assumed error in hull form)    (m^2)
        % Note: 5% of wetted surface area
        setBs1       = setModWsa*0.005;
        
        % Bs2 (Error in displacement)         (m^2)
        % Note: 1/2 of 5% of wetted surface area
        setBs2       = setBs1/2;
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % % Bs (Wetted Surface)          (m^2)
        % NOTE: Wetted surface bias
        setBs       = sqrt(setBs1^2+setBs2^2);
        percentOfS  = (setBs/setModWsa)*100;
        
        % Percentage of (Bs)^2
        percentOfBs1 = (setBs1^2/setBs^2)*100;
        percentOfBs2 = (setBs2^2/setBs^2)*100;
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.2 Speed
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % BV (Speed)   (m/s)
        % Note: Averaged standard deviation of spped using repeated runs
        setBv       = 0.0004;
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        percentOfV  = (setBv/A{j}(1,5))*100;
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.3 Resistance
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % BMx1 (Calibration)                    (Kg)
        % See: "Calibration - Sensor Errors.xlsx"
        setBMx1 = 0.013;
        
        % BMx2 (Curve fit bias)                 (Kg)
        % See: "Calibration - Sensor Errors.xlsx"
        setBMx2 = 0.013;
        
        % BMx3 (Load cell misalignment)         (Kg)
        % Note: Educated guess
        setBMx3 = 0.01;
        
        % BMx4 (Towing force inclination)       (Kg)
        % Note: Educated guess
        setBMx4 = 0;
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % Wetted surface bias - Bs (Wetted Surface) (Kg)
        setBMx        = sqrt(setBMx1^2+setBMx2^2+setBMx3^2+setBMx4^2);
        percentOfBMx  = (setBMx/setMx)*100;
        
        % Percentage of (Bs)^2
        percentOfBMx1 = (setBMx1^2/setBMx^2)*100;
        percentOfBMx2 = (setBMx2^2/setBMx^2)*100;
        percentOfBMx3 = (setBMx3^2/setBMx^2)*100;
        percentOfBMx4 = (setBMx4^2/setBMx^2)*100;

        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.4 Towing tank water properties
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % Btw (Water Temperature)   (Deg C)
        setBtw  = 0.2;
        
        % B? (Water Density)        (Kg/m^3)
        setBRho = 1;
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % Percentage of Tw and ?
        percentOfTw  = (setBtw/setTw)*100;
        percentOfRho = (setBRho/freshwaterdensity)*100;
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.5 Sensitivity Coefficients
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % ?S (Wetted Surface)           (1/m^2)
        % NOTE: Sensitivity coefficient for wetted surface, S
        thetaS = (setRx/(0.5*freshwaterdensity*(A{j}(1,5)^2)))*(-1/(setModWsa^2));
        
        % ?V (Speed)                    (1/(m/s))
        % NOTE: Sensitivity coefficient for speed, V
        thetaV = (setRx/(0.5*freshwaterdensity*setModWsa))*(-2/(A{j}(1,5)^3));
        
        % ?Mx (Total Mass Resistance)   (m/Ns^2)
        % NOTE: Sensitivity coefficient for total resistance mass, Mx
        thetaMx = gravconst/(0.5*freshwaterdensity*(A{j}(1,5)^2)*setModWsa);
        
        % ?? (Water Density)            (m^3/Kg)
        % NOTE: Sensitivity coefficient for water density, ?
        thetaRho = (setRx/(0.5*(A{j}(1,5)^2)*setModWsa))*(-1/(freshwaterdensity^2));
        
        % ??tw? (Water Temperature)     (1/Deg C)
        % NOTE: Sensitivity coefficient for water temperature, tw
        thetaRhoTw = abs(0.0638-(0.0173*15)+(0.0001897*(15^2)));
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.6 Total Bias of Resistance Coefficient CT
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % BCT (Resistance Coefficient CT) (-)
        setBCT = sqrt(((setBs*thetaS)^2)+((setBv*thetaV)^2)+((setBMx*thetaMx)^2)+((thetaRho*(setBRho+(setBtw*thetaRhoTw)))^2));
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        percentOfCT15degC = (setBCT/avgCT15degC)*100;
        
        %# ////////////////////////////////////////////////////////////////
        %# 7.0 Precision Limit
        %# ////////////////////////////////////////////////////////////////
        
        % sCT (Standard Deviation of CT)    (-)
        setSCT = stdDev;
        
        % PCT (Resistance Coefficient CT)   (-)
        % NOTE: Resistance Coefficient precision limit
        setPCT = (setK*setSCT)/(sqrt(setM));
        
        % Percent of CT at 15 deg C
        percentOfCT15degC_2 = (setPCT/avgCT15degC)*100;
        
        %# ////////////////////////////////////////////////////////////////
        %# 8. Total Uncertainty
        %# ////////////////////////////////////////////////////////////////
        
        % UCT15 deg C (Resistance Coefficient CT) (-)
        setUCT152degC        = sqrt(setBCT^2+setSCT^2);
        
        % Percentage of CT at 15 deg C
        percentOfCT152degC   = (setUCT152degC/avgCT15degC)*100;
        
        % Percentage of UCT at 15 deg C
        percentOfUCT152degC1 = (setBCT^2/setUCT152degC^2)*100;
        percentOfUCT152degC2 = (setPCT^2/setUCT152degC^2)*100;

        % /////////////////////////////////////////////////////////////////
        %# Populate resultsArrayUARes
        % /////////////////////////////////////////////////////////////////
        
        %# Results array columns:
        %[1] Run No.                                               (-)
        %[2] Condition                                             (-)
        %[3] Froude length number                                  (-)
        
        % Section 8.0: Total Uncertainty
        %[4] BCT                                                   (-)
        %[5] % of UCT15 deg C                                      (-)
        %[6] PCT                                                   (-)
        %[7] % of UCT15 deg C                                      (-)
        %[8] UCT 15 deg C                                          (-)
        %[9] % of CT 15 deg C                                      (-)
        
        % Section 3.0: Single or Multiple Test Uncertainty
        %[10] Average CT                                           (-)
        %[11] Average CT at 15 deg C                               (-)
        %[12] Standard deviation                                   (-)
        
        % Section 4.0: Input variables
        %[13] Mx, mass, total resistance in x-direction            (Kg)
        %[14] Rx, resistance (average)                             (N)
        %[15] CF at 15 deg C                                       (-)
        %[16] CFtw, fric. resistance coeff. at measured temp, tw   (-)
        
        % Section 6.1: Wetted Surface
        %[17] BS (Wetted Surface)                                  (m^2)
        %[18] % of S                                               (-)
        
        % Section 6.2: Speed
        %[19] BV (Speed)                                           (m/s)
        %[20] % of V                                               (-)
        
        % Section 6.3: Resistance
        %[21] BMx (Total Resistance Mass)                          (Kg)
        %[22] % of Mx                                              (-)
        
        % Section 6.4: Towing Tank Water Properties
        %[23] Btw (Water temperature)                              (Deg C)
        %[24] % of tw                                              (-)
        %[25] B? (Water density)                                   (Kg)
        %[26] % of ?                                               (-)
        
        % Section 6.5: Sensitivity Coefficients
        %[27] ?S (Wetted Surface)                                  (1/m^2)
        %[28] ?V (Speed)                                           (1/(m/s))
        %[29] ?Mx (Total Mass Resistance)                          (m/Ns^2)
        %[30] ?? (Water Density)                                   (m^3/Kg)
        %[31] ??tw? (Water Temperature)                            (1/Deg C)
        
        % Section 6.6: Total Bias of Resistance Coefficient CT
        %[32] BCT (Resistance Coefficient CT)                      (-)
        %[33] % of CT15degC                                        (-)
        
        % Section 7.0: Precision Limit
        %[34] PCT (Resistance Coefficient CT)                      (-)
        %[35] % of CT15degC                                        (-)
        
        %# Constants and identifiers ---------------------------------------
        
        % General identifiers
        resultsArrayUARes(counter1, 1)  = A{j}(1,1);
        resultsArrayUARes(counter1, 2)  = setCondNo;
        resultsArrayUARes(counter1, 3)  = A{j}(1,11);
        
        %# Total uncertainty ----------------------------------------------
        
        % Section 8.0: Total Uncertainty
        resultsArrayUARes(counter1, 4)  = setBCT;
        resultsArrayUARes(counter1, 5)  = percentOfUCT152degC1;
        resultsArrayUARes(counter1, 6)  = setPCT;
        resultsArrayUARes(counter1, 7)  = percentOfUCT152degC2;
        resultsArrayUARes(counter1, 8)  = setUCT152degC;
        resultsArrayUARes(counter1, 9)  = percentOfCT152degC;
        
        %# Averages and standard deviation --------------------------------
        
        % Section 3.0: Single or Multiple Test Uncertainty
        resultsArrayUARes(counter1, 10) = avgCT;
        resultsArrayUARes(counter1, 11) = avgCT15degC;
        resultsArrayUARes(counter1, 12) = stdDev;
        
        %# Variables ------------------------------------------------------
        
        % Section 4.0: Input variables
        resultsArrayUARes(counter1, 13) = setMx;
        resultsArrayUARes(counter1, 14) = setRx;
        resultsArrayUARes(counter1, 15) = setCF15degC;
        resultsArrayUARes(counter1, 16) = setCFtw;
        
        %# Coefficients ---------------------------------------------------
        
        % Section 6.1: Wetted Surface
        resultsArrayUARes(counter1, 17) = setBs;
        resultsArrayUARes(counter1, 18) = percentOfS;
        
        % Section 6.2: Speed
        resultsArrayUARes(counter1, 19) = setBv;
        resultsArrayUARes(counter1, 20) = percentOfV;
        
        % Section 6.3: Resistance
        resultsArrayUARes(counter1, 21) = setBMx;
        resultsArrayUARes(counter1, 22) = percentOfBMx;
        
        % Section 6.4: Towing Tank Water Properties
        resultsArrayUARes(counter1, 23) = setBtw;
        resultsArrayUARes(counter1, 24) = percentOfTw;
        resultsArrayUARes(counter1, 25) = setBRho;
        resultsArrayUARes(counter1, 26) = percentOfRho;
        
        % Section 6.5: Sensitivity Coefficients
        resultsArrayUARes(counter1, 27) = thetaS;
        resultsArrayUARes(counter1, 28) = thetaV;
        resultsArrayUARes(counter1, 29) = thetaMx;
        resultsArrayUARes(counter1, 30) = thetaRho;
        resultsArrayUARes(counter1, 31) = thetaRhoTw;
        
        % Section 6.6: Total Bias of Resistance Coefficient CT
        resultsArrayUARes(counter1, 32) = setBCT;
        resultsArrayUARes(counter1, 33) = percentOfCT15degC;
        
        % Section 7.0: Precision Limit
        resultsArrayUARes(counter1, 34) = setPCT;
        resultsArrayUARes(counter1, 35) = percentOfCT15degC_2;
        
        %# ----------------------------------------------------------------
        %# Uncertainty Tables for Thesis
        %# ----------------------------------------------------------------
        
        %# Condition number and length Froude number ----------------------
        
        UAThesisTable(counter1, 1)  = setCondNo;
        UAThesisTable(counter1, 2)  = A{j}(1,11);
      
        %# Sensitivity coefficients (Bias) x Bias errors ------------------

        UAThesisTable(counter1, 3)  = setBs*thetaS;
        UAThesisTable(counter1, 4)  = setBv*thetaV;
        UAThesisTable(counter1, 5)  = setBMx*thetaMx;
        UAThesisTable(counter1, 6)  = thetaRho*(setBRho+(setBtw*thetaRhoTw));
        
        %# Total bias (B_CT) and precision errors (P_CT) ------------------
        %# NOTE: (B_CT15C)^2=(Sigma_S B_S)^2+(Sigma_V B_V)^2+(Sigma_Mx B_Mx)^2+(Sigma_p(B_p+Sigma_ptw B_tw))^2
        
        UAThesisTable(counter1, 7)  = setBCT;
        UAThesisTable(counter1, 8)  = setPCT;
       
        %# Sensitivity coefficients (Sigma) -------------------------------
        
        UAThesisTable(counter1, 9)  = thetaS;
        UAThesisTable(counter1, 10) = thetaV;
        UAThesisTable(counter1, 11) = thetaMx;
        UAThesisTable(counter1, 12) = thetaRho;
        UAThesisTable(counter1, 13) = thetaRhoTw;
        
        %# Bias errors ----------------------------------------------------
        
        UAThesisTable(counter1, 14) = setBs;
        UAThesisTable(counter1, 15) = setBv;
        UAThesisTable(counter1, 16) = setBMx;
        UAThesisTable(counter1, 17) = setBRho;
        UAThesisTable(counter1, 18) = setBtw;
        
        counter1 = counter1 + 1;
    end % for j=1:ma
    
end % condNo=7:13


%# ////////////////////////////////////////////////////////////////////
%# Plotting
%# ////////////////////////////////////////////////////////////////////

% Create one plot array per condition
[qas,ras] = size(resultsArrayUARes);

% Split results array based on column 2 (test condition)
R  = resultsArrayUARes;
AA = arrayfun(@(x) R(R(:,2) == x, :), unique(R(:,2)), 'uniformoutput', false);

% Write data for each test condition in a saparate array
Cond7Data  = AA{1};
Cond8Data  = AA{2};
Cond9Data  = AA{3};
Cond10Data = AA{4};
Cond11Data = AA{5};
Cond12Data = AA{6};
Cond13Data = AA{7};

%# ************************************************************************
%# 1. Fr versus resistance coefficient, total uncertainty
%# ************************************************************************
if enablePlot1 == 1
    figurename = sprintf('Plot 1: Total uncertainty U_{CT 15 deg C}:: Conditions %s to %s', num2str(7), num2str(12));
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
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',14,...
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
    setMarkerSize      = 14;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,1)
    
    % X and Y values ----------------------------------------------------------
    
    setX1 = Cond7Data(:,3);
    setY1 = Cond7Data(:,9);
    
    setX2 = Cond8Data(:,3);
    setY2 = Cond8Data(:,9);
    
    setX3 = Cond9Data(:,3);
    setY3 = Cond9Data(:,9);
    
    setX4 = Cond13Data(:,3);
    setY4 = Cond13Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX1,setY1,'*',setX2,setY2,'*',setX3,setY3,'*',setX4,setY4,'*');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    %ylabel('{\bf % of C_{T15 deg C} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 1,500 tonnes}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    % Colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin
    set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.25;
    maxX  = 0.5;
    incrX = 0.05;
    minY  = 0;
    maxY  = 2;
    incrY = 0.5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('1,500t (level trim)','1,500t (-0.5 deg by bow)','1,500t (0.5 deg by stern)','1,500t (deep transom for Prohaska runs)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,2)
    
    % X and Y values ----------------------------------------------------------
    
    setX4 = Cond10Data(:,3);
    setY4 = Cond10Data(:,9);
    
    setX5 = Cond11Data(:,3);
    setY5 = Cond11Data(:,9);
    
    setX6 = Cond12Data(:,3);
    setY6 = Cond12Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX4,setY4,'*',setX5,setY5,'*',setX6,setY6,'*');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 1,804 tonnes}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    % Colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin
    set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.25;
    maxX  = 0.5;
    incrX = 0.05;
    minY  = 0;
    maxY  = 2;
    incrY = 0.5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('1,804t (level trim)','1,804t (-0.5 deg by bow)','1,804t (0.5 deg by stern)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
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
    
    %# Plot title ---------------------------------------------------------
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1

%# ************************************************************************
%# 1.1 Fr versus resistance coefficient, total uncertainty
%# ************************************************************************
if enablePlot1_1 == 1
    figurename = sprintf('Plot 1.1: Total uncertainty U_{CT 15 deg C}:: Conditions %s to %s', num2str(7), num2str(12));
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
        'FontSize',14,...
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
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,1)
    
    % X and Y values ----------------------------------------------------------
    
    % Condition 7 -------------------------------------------------------------
    setX7 = Cond7Data(:,3);
    setY7 = Cond7Data(:,9);
    
    % Fitting curve
    x          = setX7;
    y          = setY7;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject7 = fitobject;
    gof7       = gof;
    cvalues7   = cvalues;
    %disp(sprintf('Condition 7: R^2 = %s',sprintf('%0.3f',gof7.rsquare)));
    
    % Condition 8 -------------------------------------------------------------
    setX8 = Cond8Data(:,3);
    setY8 = Cond8Data(:,9);
    
    % Fitting curve
    x          = setX8;
    y          = setY8;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject8 = fitobject;
    gof8       = gof;
    cvalues8   = cvalues;
    %disp(sprintf('Condition 8: R^2 = %s',sprintf('%0.3f',gof8.rsquare)));
    
    % Condition 9 -------------------------------------------------------------
    setX9 = Cond9Data(:,3);
    setY9 = Cond9Data(:,9);
    
    % Fitting curve
    x          = setX9;
    y          = setY9;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject9 = fitobject;
    gof9       = gof;
    cvalues9   = cvalues;
    %disp(sprintf('Condition 9: R^2 = %s',sprintf('%0.3f',gof9.rsquare)));
    
    % Condition 13 ------------------------------------------------------------
    setX13 = Cond13Data(:,3);
    setY13 = Cond13Data(:,9);
    
    % Fitting curve
    x          = setX13;
    y          = setY13;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject13 = fitobject;
    gof13       = gof;
    cvalues13   = cvalues;
    %disp(sprintf('Condition 13: R^2 = %s',sprintf('%0.3f',gof13.rsquare)));
    
    % Condition 10 ------------------------------------------------------------
    setX10 = Cond10Data(:,3);
    setY10 = Cond10Data(:,9);
    
    % Fitting curve
    x          = setX10;
    y          = setY10;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject10 = fitobject;
    gof10       = gof;
    cvalues10   = cvalues;
    %disp(sprintf('Condition 10: R^2 = %s',sprintf('%0.3f',gof10.rsquare)));
    
    % Condition 11 ------------------------------------------------------------
    setX11 = Cond11Data(:,3);
    setY11 = Cond11Data(:,9);
    
    % Fitting curve
    x          = setX11;
    y          = setY11;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject11 = fitobject;
    gof11       = gof;
    cvalues11   = cvalues;
    %disp(sprintf('Condition 11: R^2 = %s',sprintf('%0.3f',gof11.rsquare)));
    
    % Condition 12 ------------------------------------------------------------
    setX12 = Cond12Data(:,3);
    setY12 = Cond12Data(:,9);
    
    % Fitting curve
    x          = setX12;
    y          = setY12;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject12 = fitobject;
    gof12       = gof;
    cvalues12   = cvalues;
    %disp(sprintf('Condition 12: R^2 = %s',sprintf('%0.3f',gof12.rsquare)));
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX7,setY7,'*',setX8,setY8,'*',setX9,setY9,'*',setX13,setY13,'*',setX10,setY10,'*',setX11,setY11,'*',setX12,setY12,'*');
    legendInfo1_1{1} = '1,500t (level trim)';
    legendInfo1_1{2} = '1,500t (-0.5 deg by bow)';
    legendInfo1_1{3} = '1,500t (0.5 deg by stern)';
    legendInfo1_1{4} = '1,500t (deep transom Prohaska runs)';
    legendInfo1_1{5} = '1,804t (level trim)';
    legendInfo1_1{6} = '1,804t (-0.5 deg by bow)';
    legendInfo1_1{7} = '1,804t (0.5 deg by stern)';
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    % Colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
    set(h(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin
    set(h(3),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin
    set(h(4),'Color',setColor{4},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
    set(h(5),'Color',setColor{5},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin
    set(h(6),'Color',setColor{6},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin
    set(h(7),'Color',setColor{7},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.1;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_1);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,2)
    
    % X and Y values ----------------------------------------------------------
    
    % Plotting ----------------------------------------------------------------
    h7 = plot(fitobject12,'k-',setX12,setY12,'*');
    set(h7(1),'Color',setColor{7},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h7(2),'Color',setColor{7},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
    set(h7,'userdata','1,804t (0.5 deg by stern)');
    hold on;
    h6 = plot(fitobject11,'k-',setX11,setY11,'*');
    set(h6(1),'Color',setColor{6},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h6(2),'Color',setColor{6},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h6,'userdata','1,804t (-0.5 deg by bow)');
    hold on;
    h5 = plot(fitobject10,'k-',setX10,setY10,'*');
    set(h5(1),'Color',setColor{5},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h5(2),'Color',setColor{5},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    set(h5,'userdata','1,804t (level trim)');
    hold on;
    h4 = plot(fitobject13,'k-',setX13,setY13,'*');
    set(h4(1),'Color',setColor{4},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h4(2),'Color',setColor{4},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h4,'userdata','1,500t (deep transom Prohaska runs)');
    hold on;
    h3 = plot(fitobject9,'k-',setX9,setY9,'*');
    set(h3(1),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h3(2),'Color',setColor{3},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
    set(h3,'userdata','1,500t (0.5 deg by stern)');
    hold on;
    h2 = plot(fitobject8,'k-',setX8,setY8,'*');
    set(h2(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h2(2),'Color',setColor{2},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h2,'userdata','1,500t (-0.5 deg by bow)');
    hold on;
    h1 = plot(fitobject7,'k-',setX7,setY7,'*');
    set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h1(2),'Color',setColor{1},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    set(h1,'userdata','1,500t (level trim)');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.1;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hc = get(gca,'children');
    s  = {};
    for h=hc'
        s={s{:},get(h,'userdata')};
    end
    %hleg1 = legend(hc([1,3,5],:),s(:,[1,3,5]));
    hleg1 = legend(hc([2,4,6,8,10,12,14],:),s(:,[2,4,6,8,10,12,14]));
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
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
    
    %# Plot title ---------------------------------------------------------
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_1_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1_1

%# ************************************************************************
%# 1.2 Fr versus resistance coefficient, total uncertainty
%# ************************************************************************
if enablePlot1_2 == 1
    figurename = sprintf('Plot 1.2: Total uncertainty U_{CT 15 deg C}:: Conditions %s to %s', num2str(7), num2str(12));
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
        'FontSize',14,...
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
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,1)
    
    % X and Y values ----------------------------------------------------------
    
    % Condition 7 -------------------------------------------------------------
    setX7 = Cond7Data(:,3);
    setY7 = Cond7Data(:,9);
    
    % Fitting curve
    x          = setX7;
    y          = setY7;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject7 = fitobject;
    gof7       = gof;
    cvalues7   = cvalues;
    %disp(sprintf('Condition 7: R^2 = %s',sprintf('%0.3f',gof7.rsquare)));
    
    % Condition 8 -------------------------------------------------------------
    setX8 = Cond8Data(:,3);
    setY8 = Cond8Data(:,9);
    
    % Fitting curve
    x          = setX8;
    y          = setY8;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject8 = fitobject;
    gof8       = gof;
    cvalues8   = cvalues;
    %disp(sprintf('Condition 8: R^2 = %s',sprintf('%0.3f',gof8.rsquare)));
    
    % Condition 9 -------------------------------------------------------------
    setX9 = Cond9Data(:,3);
    setY9 = Cond9Data(:,9);
    
    % Fitting curve
    x          = setX9;
    y          = setY9;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject9 = fitobject;
    gof9       = gof;
    cvalues9   = cvalues;
    %disp(sprintf('Condition 9: R^2 = %s',sprintf('%0.3f',gof9.rsquare)));
    
    % Condition 13 ------------------------------------------------------------
    setX13 = Cond13Data(:,3);
    setY13 = Cond13Data(:,9);
    
    % Fitting curve
    x           = setX13;
    y           = setY13;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject13 = fitobject;
    gof13       = gof;
    cvalues13   = cvalues;
    %disp(sprintf('Condition 13: R^2 = %s',sprintf('%0.3f',gof13.rsquare)));
    
    % Condition 10 ------------------------------------------------------------
    setX10 = Cond10Data(:,3);
    setY10 = Cond10Data(:,9);
    
    % Fitting curve
    x           = setX10;
    y           = setY10;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject10 = fitobject;
    gof10       = gof;
    cvalues10   = cvalues;
    %disp(sprintf('Condition 10: R^2 = %s',sprintf('%0.3f',gof10.rsquare)));
    
    % Condition 11 ------------------------------------------------------------
    setX11 = Cond11Data(:,3);
    setY11 = Cond11Data(:,9);
    
    % Fitting curve
    x           = setX11;
    y           = setY11;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject11 = fitobject;
    gof11       = gof;
    cvalues11   = cvalues;
    %disp(sprintf('Condition 11: R^2 = %s',sprintf('%0.3f',gof11.rsquare)));
    
    % Condition 12 ------------------------------------------------------------
    setX12 = Cond12Data(:,3);
    setY12 = Cond12Data(:,9);
    
    % Fitting curve
    x           = setX12;
    y           = setY12;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject12 = fitobject;
    gof12       = gof;
    cvalues12   = cvalues;
    %disp(sprintf('Condition 12: R^2 = %s',sprintf('%0.3f',gof12.rsquare)));
    
    % Plotting ----------------------------------------------------------------
    h4 = plot(fitobject13,'k-',setX13,setY13,'*');
    set(h4(1),'Color',setColor{4},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h4(2),'Color',setColor{4},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h4,'userdata','1,500t (deep transom Prohaska runs)');
    hold on;
    h3 = plot(fitobject9,'k-',setX9,setY9,'*');
    set(h3(1),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h3(2),'Color',setColor{3},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
    set(h3,'userdata','1,500t (0.5 deg by stern)');
    hold on;
    h2 = plot(fitobject8,'k-',setX8,setY8,'*');
    set(h2(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h2(2),'Color',setColor{2},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h2,'userdata','1,500t (-0.5 deg by bow)');
    hold on;
    h1 = plot(fitobject7,'k-',setX7,setY7,'*');
    set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h1(2),'Color',setColor{1},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    set(h1,'userdata','1,500t (level trim)');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.1;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hc = get(gca,'children');
    s  = {};
    for h=hc'
        s={s{:},get(h,'userdata')};
    end
    %hleg1 = legend(hc([1,3,5],:),s(:,[1,3,5]));
    hleg1 = legend(hc([2,4,6,8],:),s(:,[2,4,6,8]));
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,2)
    
    % X and Y values ----------------------------------------------------------
    
    % Plotting ----------------------------------------------------------------
    h7 = plot(fitobject12,'k-',setX12,setY12,'*');
    set(h7(1),'Color',setColor{7},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h7(2),'Color',setColor{7},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
    set(h7,'userdata','1,804t (0.5 deg by stern)');
    hold on;
    h6 = plot(fitobject11,'k-',setX11,setY11,'*');
    set(h6(1),'Color',setColor{6},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h6(2),'Color',setColor{6},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h6,'userdata','1,804t (-0.5 deg by bow)');
    hold on;
    h5 = plot(fitobject10,'k-',setX10,setY10,'*');
    set(h5(1),'Color',setColor{5},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h5(2),'Color',setColor{5},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    set(h5,'userdata','1,804t (level trim)');
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.1;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hc = get(gca,'children');
    s  = {};
    for h=hc'
        s={s{:},get(h,'userdata')};
    end
    %hleg1 = legend(hc([1,3,5],:),s(:,[1,3,5]));
    hleg1 = legend(hc([2,4,6],:),s(:,[2,4,6]));
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
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
    
    %# Plot title ---------------------------------------------------------
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_2_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1_2

%# ************************************************************************
%# 1.3 Fr versus resistance coefficient, 95% probability
%# ************************************************************************
if enablePlot1_3 == 1
    figurename = sprintf('Plot 1.3: Total uncertainty U_{CT 15 deg C}:: Conditions %s to %s', num2str(7), num2str(12));
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
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',14,...
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
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    % X and Y values ----------------------------------------------------------
    
    % Condition 7 -------------------------------------------------------------
    setX7 = Cond7Data(:,3);
    setY7 = Cond7Data(:,9);
    
    % Fitting curve
    x          = setX7;
    y          = setY7;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject7 = fitobject;
    gof7       = gof;
    cvalues7   = cvalues;
    %disp(sprintf('Condition 7: R^2 = %s',sprintf('%0.3f',gof7.rsquare)));
    
    % Condition 8 -------------------------------------------------------------
    setX8 = Cond8Data(:,3);
    setY8 = Cond8Data(:,9);
    
    % Fitting curve
    x          = setX8;
    y          = setY8;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues    = coeffvalues(fitobject);
    fitobject8 = fitobject;
    gof8       = gof;
    cvalues8   = cvalues;
    %disp(sprintf('Condition 8: R^2 = %s',sprintf('%0.3f',gof8.rsquare)));
    
    % Condition 9 -------------------------------------------------------------
    setX9 = Cond9Data(:,3);
    setY9 = Cond9Data(:,9);
    
    % Fitting curve
    x          = setX9;
    y          = setY9;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues    = coeffvalues(fitobject);
    fitobject9 = fitobject;
    gof9       = gof;
    cvalues9   = cvalues;
    %disp(sprintf('Condition 9: R^2 = %s',sprintf('%0.3f',gof9.rsquare)));
    
    % Condition 13 ------------------------------------------------------------
    setX13 = Cond13Data(:,3);
    setY13 = Cond13Data(:,9);
    
    % Fitting curve
    x           = setX13;
    y           = setY13;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues     = coeffvalues(fitobject);
    fitobject13 = fitobject;
    gof13       = gof;
    cvalues13   = cvalues;
    %disp(sprintf('Condition 13: R^2 = %s',sprintf('%0.3f',gof13.rsquare)));
    
    % Condition 10 ------------------------------------------------------------
    setX10 = Cond10Data(:,3);
    setY10 = Cond10Data(:,9);
    
    % Fitting curve
    x           = setX10;
    y           = setY10;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject10 = fitobject;
    gof10       = gof;
    cvalues10   = cvalues;
    %disp(sprintf('Condition 10: R^2 = %s',sprintf('%0.3f',gof10.rsquare)));
    
    % Condition 11 ------------------------------------------------------------
    setX11 = Cond11Data(:,3);
    setY11 = Cond11Data(:,9);
    
    % Fitting curve
    x           = setX11;
    y           = setY11;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues     = coeffvalues(fitobject);
    fitobject11 = fitobject;
    gof11       = gof;
    cvalues11   = cvalues;
    %disp(sprintf('Condition 11: R^2 = %s',sprintf('%0.3f',gof11.rsquare)));
    
    % Condition 12 ------------------------------------------------------------
    setX12 = Cond12Data(:,3);
    setY12 = Cond12Data(:,9);
    
    % Fitting curve
    x           = setX12;
    y           = setY12;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues     = coeffvalues(fitobject);
    fitobject12 = fitobject;
    gof12       = gof;
    cvalues12   = cvalues;
    %disp(sprintf('Condition 12: R^2 = %s',sprintf('%0.3f',gof12.rsquare)));
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,1)
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX7,setY7,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject7,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_3_1{1} = '1,500t (level trim)';
    legendInfo1_3_1{2} = 'Fitted curve';
    legendInfo1_3_1{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.1;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_3_1);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,2)
    
    % % Plotting ----------------------------------------------------------------
    h = plot(setX8,setY8,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject8,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_3_2{1} = '1,500t (-0.5 deg by bow)';
    legendInfo1_3_2{2} = 'Fitted curve';
    legendInfo1_3_2{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.2;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_3_2);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,3)
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX9,setY9,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject9,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_3_3{1} = '1,500t (0.5 deg by stern)';
    legendInfo1_3_3{2} = 'Fitted curve';
    legendInfo1_3_3{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.2;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_3_3);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,4)
    
    % % Plotting ----------------------------------------------------------------
    h = plot(setX13,setY13,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject13,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_3_4{1} = '1,500t (Prohaska runs)';
    legendInfo1_3_4{2} = 'Fitted curve';
    legendInfo1_3_4{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.1;
    maxX  = 0.25;
    incrX = 0.05;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_3_4);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
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
    
    %# Plot title ---------------------------------------------------------
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_3_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1_3

%# ************************************************************************
%# 1.4 Fr versus resistance coefficient, 95% probability
%# ************************************************************************
if enablePlot1_4 == 1
    figurename = sprintf('Plot 1.4: Total uncertainty U_{CT 15 deg C}:: Conditions %s to %s', num2str(7), num2str(12));
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
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',14,...
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
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    % X and Y values ----------------------------------------------------------
    
    % Condition 7 -------------------------------------------------------------
    setX7 = Cond7Data(:,3);
    setY7 = Cond7Data(:,9);
    
    % Fitting curve
    x          = setX7;
    y          = setY7;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject7 = fitobject;
    gof7       = gof;
    cvalues7   = cvalues;
    %disp(sprintf('Condition 7: R^2 = %s',sprintf('%0.3f',gof7.rsquare)));
    
    % Condition 8 -------------------------------------------------------------
    setX8 = Cond8Data(:,3);
    setY8 = Cond8Data(:,9);
    
    % Fitting curve
    x          = setX8;
    y          = setY8;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues    = coeffvalues(fitobject);
    fitobject8 = fitobject;
    gof8       = gof;
    cvalues8   = cvalues;
    %disp(sprintf('Condition 8: R^2 = %s',sprintf('%0.3f',gof8.rsquare)));
    
    % Condition 9 -------------------------------------------------------------
    setX9 = Cond9Data(:,3);
    setY9 = Cond9Data(:,9);
    
    % Fitting curve
    x          = setX9;
    y          = setY9;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues    = coeffvalues(fitobject);
    fitobject9 = fitobject;
    gof9       = gof;
    cvalues9   = cvalues;
    %disp(sprintf('Condition 9: R^2 = %s',sprintf('%0.3f',gof9.rsquare)));
    
    % Condition 13 ------------------------------------------------------------
    setX13 = Cond13Data(:,3);
    setY13 = Cond13Data(:,9);
    
    % Fitting curve
    x           = setX13;
    y           = setY13;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues     = coeffvalues(fitobject);
    fitobject13 = fitobject;
    gof13       = gof;
    cvalues13   = cvalues;
    %disp(sprintf('Condition 13: R^2 = %s',sprintf('%0.3f',gof13.rsquare)));
    
    % Condition 10 ------------------------------------------------------------
    setX10 = Cond10Data(:,3);
    setY10 = Cond10Data(:,9);
    
    % Fitting curve
    x           = setX10;
    y           = setY10;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject10 = fitobject;
    gof10       = gof;
    cvalues10   = cvalues;
    %disp(sprintf('Condition 10: R^2 = %s',sprintf('%0.3f',gof10.rsquare)));
    
    % Condition 11 ------------------------------------------------------------
    setX11 = Cond11Data(:,3);
    setY11 = Cond11Data(:,9);
    
    % Fitting curve
    x           = setX11;
    y           = setY11;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues     = coeffvalues(fitobject);
    fitobject11 = fitobject;
    gof11       = gof;
    cvalues11   = cvalues;
    %disp(sprintf('Condition 11: R^2 = %s',sprintf('%0.3f',gof11.rsquare)));
    
    % Condition 12 ------------------------------------------------------------
    setX12 = Cond12Data(:,3);
    setY12 = Cond12Data(:,9);
    
    % Fitting curve
    x           = setX12;
    y           = setY12;
    [fitobject,gof,output] = fit(x,y,'poly3');
    cvalues     = coeffvalues(fitobject);
    fitobject12 = fitobject;
    gof12       = gof;
    cvalues12   = cvalues;
    %disp(sprintf('Condition 12: R^2 = %s',sprintf('%0.3f',gof12.rsquare)));
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,1)
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX10,setY10,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject10,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_4_1{1} = '1,804t (level trim)';
    legendInfo1_4_1{2} = 'Fitted curve';
    legendInfo1_4_1{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.2;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_3_1);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,2)
    
    % % Plotting ----------------------------------------------------------------
    h = plot(setX11,setY11,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject11,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_4_2{1} = '1,804t (-0.5 deg by bow)';
    legendInfo1_4_2{2} = 'Fitted curve';
    legendInfo1_4_2{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.2;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_4_2);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,2,3)
    
    % Plotting ----------------------------------------------------------------
    h = plot(setX12,setY12,'o');
    set(h(1),'Color','b','Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    h = plot(fitobject12,'predobs',0.95);
    set(h(1),'Color','r','Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
    set(h(2),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h(3),'Color','r','Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    hold off;
    legendInfo1_4_3{1} = '1,804t (0.5 deg by stern)';
    legendInfo1_4_3{2} = 'Fitted curve';
    legendInfo1_4_3{3} = '95% probability';
    xlabel('{\bf F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf 95% prediction}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.2;
    maxX  = 0.5;
    incrX = 0.1;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_4_3);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
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
    
    %# Plot title ---------------------------------------------------------
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_4_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1_4

%# ************************************************************************
%# 1.5 Fr versus resistance coefficient, total uncertainty of CT
%# ************************************************************************
if enablePlot1_5 == 1
    figurename = 'Plot 1.5: Total uncertainty of C_{T}';
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
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',14,...
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
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    % X and Y values ----------------------------------------------------------
    
    % Condition 7 -------------------------------------------------------------
    setX7 = Cond7Data(:,3);
    setY7 = Cond7Data(:,9);
    
    % Fitting curve
    x          = setX7;
    y          = setY7;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject7 = fitobject;
    gof7       = gof;
    cvalues7   = cvalues;   
    
    % Condition 8 -------------------------------------------------------------
    setX8 = Cond8Data(:,3);
    setY8 = Cond8Data(:,9);
    
    % Fitting curve
    x          = setX8;
    y          = setY8;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject8 = fitobject;
    gof8       = gof;
    cvalues8   = cvalues;

    % Condition 9 -------------------------------------------------------------
    setX9 = Cond9Data(:,3);
    setY9 = Cond9Data(:,9);
    
    % Fitting curve
    x          = setX9;
    y          = setY9;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject9 = fitobject;
    gof9       = gof;
    cvalues9   = cvalues;    
    
    % Condition 13 ------------------------------------------------------------
    setX13 = Cond13Data(:,3);
    setY13 = Cond13Data(:,9);
    
    % Fitting curve
    x           = setX13;
    y           = setY13;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject13 = fitobject;
    gof13       = gof;
    cvalues13   = cvalues; 
    
    % Condition 10 ------------------------------------------------------------
    setX10 = Cond10Data(:,3);
    setY10 = Cond10Data(:,9);
    
    % Fitting curve
    x           = setX10;
    y           = setY10;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject10 = fitobject;
    gof10       = gof;
    cvalues10   = cvalues;   
    
    % Condition 11 ------------------------------------------------------------
    setX11 = Cond11Data(:,3);
    setY11 = Cond11Data(:,9);
    
    % Fitting curve
    x           = setX11;
    y           = setY11;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject11 = fitobject;
    gof11       = gof;
    cvalues11   = cvalues;  
    
    % Condition 12 ------------------------------------------------------------
    setX12 = Cond12Data(:,3);
    setY12 = Cond12Data(:,9);
    
    % Fitting curve
    x           = setX12;
    y           = setY12;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject12 = fitobject;
    gof12       = gof;
    cvalues12   = cvalues;  
    
    % Fitted curves -----------------------------------------------------------
    
    setFrNo =[0.1:0.02:0.48;]';
    [mfn,nfn] = size(setFrNo);
    
    fittedTUArray = [];
    for kfn=1:mfn
        cFr = setFrNo(kfn);
        % Froude number
        fittedTUArray(kfn,1) = cFr;
        % Fitted (Condition 7): 1,500t (level trim)
        fittedTUArray(kfn,2) = cvalues7(1)*cFr^4+cvalues7(2)*cFr^3+cvalues7(3)*cFr^2+cvalues7(4)*cFr+cvalues7(5);
        % Fitted (Condition 8): 1,500t (-0.5 deg by bow)
        fittedTUArray(kfn,3) = cvalues8(1)*cFr^4+cvalues8(2)*cFr^3+cvalues8(3)*cFr^2+cvalues8(4)*cFr+cvalues8(5);
        % Fitted (Condition 9): 1,500t (0.5 deg by stern)
        fittedTUArray(kfn,4) = cvalues9(1)*cFr^4+cvalues9(2)*cFr^3+cvalues9(3)*cFr^2+cvalues9(4)*cFr+cvalues9(5);
        % Fitted (Condition 13): 1,500t (deep transom Prohaska runs)
        fittedTUArray(kfn,5) = cvalues13(1)*cFr^4+cvalues13(2)*cFr^3+cvalues13(3)*cFr^2+cvalues13(4)*cFr+cvalues13(5);
        % Fitted (Condition 10): 1,804t (level trim)
        fittedTUArray(kfn,6) = cvalues10(1)*cFr^4+cvalues10(2)*cFr^3+cvalues10(3)*cFr^2+cvalues10(4)*cFr+cvalues10(5);
        % Fitted (Condition 11): 1,804t (-0.5 deg by bow)
        fittedTUArray(kfn,7) = cvalues11(1)*cFr^4+cvalues11(2)*cFr^3+cvalues11(3)*cFr^2+cvalues11(4)*cFr+cvalues11(5);
        % Fitted (Condition 12): 1,804t (0.5 deg by stern)
        fittedTUArray(kfn,8) = cvalues12(1)*cFr^4+cvalues12(2)*cFr^3+cvalues12(3)*cFr^2+cvalues12(4)*cFr+cvalues12(5);
    end

    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,1,1)
    
    % X and Y values ----------------------------------------------------------    
    
    x = setFrNo(6:20);
    
    % Total uncertainty (Condition 7): 1,500t (level trim)
    y1 = fittedTUArray(6:20,2);
    
    % Total uncertainty (Condition 8): 1,500t (-0.5 deg by bow)
    y2 = fittedTUArray(6:20,3);
    
    % Total uncertainty (Condition 9): 1,500t (0.5 deg by stern)
    y3 = fittedTUArray(6:20,4);
    
    % Plotting ----------------------------------------------------------------
    h = bar(x, [y1 y2 y3], 1);
    legendInfo1_5_1{1} = '1,500t (level trim)';
    legendInfo1_5_1{2} = '1,500t (-0.5 deg by bow)';
    legendInfo1_5_1{3} = '1,500t (0.5 deg by stern)';
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Colors and markers
    set(h(1),'FaceColor',[0.4,0.4,0.4]);
    set(h(2),'FaceColor',[0.6,0.6,0.6]);
    set(h(3),'FaceColor',[0.8,0.8,0.8]);
    %set(h(1),'FaceColor','r');
    %set(h(2),'FaceColor','g');
    %set(h(3),'FaceColor','b');
    
    %# Axis limitations
    minX  = 0.18;
    maxX  = 0.5;
    incrX = 0.02;
    minY  = 0;
    maxY  = 4;
    incrY = 1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_5_1);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,1,2)
    
    % X and Y values ----------------------------------------------------------    
    
    x = setFrNo(6:20);
    
    % Total uncertainty (Condition 10): 1,804t (level trim)
    y1 = fittedTUArray(6:20,6);
    
    % Total uncertainty (Condition 11): 1,804t (-0.5 deg by bow)
    y2 = fittedTUArray(6:20,7);
    
    % Total uncertainty (Condition 12): 1,804t (0.5 deg by stern)
    y3 = fittedTUArray(6:20,8);

    % Plotting ----------------------------------------------------------------
    h = bar(x, [y1 y2 y3], 1);
    legendInfo1_5_2{1} = '1,804t (level trim)';
    legendInfo1_5_2{2} = '1,804t (-0.5 deg by bow)';
    legendInfo1_5_2{3} = '1,804t (0.5 deg by stern)';
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Colors and markers
    set(h(1),'FaceColor',[0.4,0.4,0.4]);
    set(h(2),'FaceColor',[0.6,0.6,0.6]);
    set(h(3),'FaceColor',[0.8,0.8,0.8]);
    %set(h(1),'FaceColor','r');
    %set(h(2),'FaceColor','g');
    %set(h(3),'FaceColor','b');
    
    %# Axis limitations
    minX  = 0.18;
    maxX  = 0.5;
    incrX = 0.02;
    minY  = 0;
    maxY  = 4;
    incrY = 1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_5_2);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
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
    
    %# Plot title ---------------------------------------------------------
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_5_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1_5


%# ************************************************************************
%# 1.6 Fr versus resistance coefficient, total uncertainty of CT
%# ************************************************************************
if enablePlot1_6 == 1
    figurename = 'Plot 1.6: Total uncertainty of C_{T}';
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
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',14,...
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
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    % X and Y values ----------------------------------------------------------
    
    % Condition 7 -------------------------------------------------------------
    setX7 = Cond7Data(:,3);
    setY7 = Cond7Data(:,9);
    
    % Fitting curve
    x          = setX7;
    y          = setY7;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject7 = fitobject;
    gof7       = gof;
    cvalues7   = cvalues;   
    
    % Condition 8 -------------------------------------------------------------
    setX8 = Cond8Data(:,3);
    setY8 = Cond8Data(:,9);
    
    % Fitting curve
    x          = setX8;
    y          = setY8;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject8 = fitobject;
    gof8       = gof;
    cvalues8   = cvalues;

    % Condition 9 -------------------------------------------------------------
    setX9 = Cond9Data(:,3);
    setY9 = Cond9Data(:,9);
    
    % Fitting curve
    x          = setX9;
    y          = setY9;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues    = coeffvalues(fitobject);
    fitobject9 = fitobject;
    gof9       = gof;
    cvalues9   = cvalues;    
    
    % Condition 13 ------------------------------------------------------------
    setX13 = Cond13Data(:,3);
    setY13 = Cond13Data(:,9);
    
    % Fitting curve
    x           = setX13;
    y           = setY13;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject13 = fitobject;
    gof13       = gof;
    cvalues13   = cvalues; 
    
    % Condition 10 ------------------------------------------------------------
    setX10 = Cond10Data(:,3);
    setY10 = Cond10Data(:,9);
    
    % Fitting curve
    x           = setX10;
    y           = setY10;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject10 = fitobject;
    gof10       = gof;
    cvalues10   = cvalues;   
    
    % Condition 11 ------------------------------------------------------------
    setX11 = Cond11Data(:,3);
    setY11 = Cond11Data(:,9);
    
    % Fitting curve
    x           = setX11;
    y           = setY11;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject11 = fitobject;
    gof11       = gof;
    cvalues11   = cvalues;  
    
    % Condition 12 ------------------------------------------------------------
    setX12 = Cond12Data(:,3);
    setY12 = Cond12Data(:,9);
    
    % Fitting curve
    x           = setX12;
    y           = setY12;
    [fitobject,gof,output] = fit(x,y,'poly4');
    cvalues     = coeffvalues(fitobject);
    fitobject12 = fitobject;
    gof12       = gof;
    cvalues12   = cvalues;  
    
    % Fitted curves -----------------------------------------------------------
    
    setFrNo =[0.1:0.02:0.48;]';
    [mfn,nfn] = size(setFrNo);
    
    fittedTUArray = [];
    for kfn=1:mfn
        cFr = setFrNo(kfn);
        % Froude number
        fittedTUArray(kfn,1) = cFr;
        % Fitted (Condition 7): 1,500t (level trim)
        fittedTUArray(kfn,2) = cvalues7(1)*cFr^4+cvalues7(2)*cFr^3+cvalues7(3)*cFr^2+cvalues7(4)*cFr+cvalues7(5);
        % Fitted (Condition 8): 1,500t (-0.5 deg by bow)
        fittedTUArray(kfn,3) = cvalues8(1)*cFr^4+cvalues8(2)*cFr^3+cvalues8(3)*cFr^2+cvalues8(4)*cFr+cvalues8(5);
        % Fitted (Condition 9): 1,500t (0.5 deg by stern)
        fittedTUArray(kfn,4) = cvalues9(1)*cFr^4+cvalues9(2)*cFr^3+cvalues9(3)*cFr^2+cvalues9(4)*cFr+cvalues9(5);
        % Fitted (Condition 13): 1,500t (deep transom Prohaska runs)
        fittedTUArray(kfn,5) = cvalues13(1)*cFr^4+cvalues13(2)*cFr^3+cvalues13(3)*cFr^2+cvalues13(4)*cFr+cvalues13(5);
        % Fitted (Condition 10): 1,804t (level trim)
        fittedTUArray(kfn,6) = cvalues10(1)*cFr^4+cvalues10(2)*cFr^3+cvalues10(3)*cFr^2+cvalues10(4)*cFr+cvalues10(5);
        % Fitted (Condition 11): 1,804t (-0.5 deg by bow)
        fittedTUArray(kfn,7) = cvalues11(1)*cFr^4+cvalues11(2)*cFr^3+cvalues11(3)*cFr^2+cvalues11(4)*cFr+cvalues11(5);
        % Fitted (Condition 12): 1,804t (0.5 deg by stern)
        fittedTUArray(kfn,8) = cvalues12(1)*cFr^4+cvalues12(2)*cFr^3+cvalues12(3)*cFr^2+cvalues12(4)*cFr+cvalues12(5);
    end

    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(2,1,1)
    
    % X and Y values ----------------------------------------------------------    
    
    x = setFrNo(1:7);
    
    % Total uncertainty (Condition 7): 1,500t (level trim)
    y1 = fittedTUArray(1:7,2);
    
    % Total uncertainty (Condition 8): 1,500t (deep transom Prohaska runs)
    y2 = fittedTUArray(1:7,5);

    % Plotting ----------------------------------------------------------------
    h = bar(x, [y1 y2], 1);
    legendInfo1_6_1{1} = '1,500t (level trim)';
    legendInfo1_6_1{2} = '1,500t (deep transom Prohaska runs)';
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Colors and markers
    set(h(1),'FaceColor',[0.4,0.4,0.4]);
    set(h(2),'FaceColor',[0.6,0.6,0.6]);
    %set(h(1),'FaceColor','r');
    %set(h(2),'FaceColor','g');
    
    %# Axis limitations
    minX  = 0.08;
    maxX  = 0.24;
    incrX = 0.02;
    minY  = 0;
    maxY  = 20;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfo1_6_1);
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
%     %# SUBPLOT ////////////////////////////////////////////////////////////////
%     subplot(2,1,2)
%     
%     % X and Y values ----------------------------------------------------------    
%     
%     x = setFrNo(6:20);
%     
%     % Total uncertainty (Condition 10): 1,804t (level trim)
%     y1 = fittedTUArray(6:20,6);
%     
%     % Total uncertainty (Condition 11): 1,804t (-0.5 deg by bow)
%     y2 = fittedTUArray(6:20,7);
%     
%     % Total uncertainty (Condition 12): 1,804t (0.5 deg by stern)
%     y3 = fittedTUArray(6:20,8);
% 
%     % Plotting ----------------------------------------------------------------
%     h = bar(x, [y1 y2 y3], 1);
%     legendInfo1_5_1{1} = '1,804t (level trim)';
%     legendInfo1_5_1{2} = '1,804t (-0.5 deg by bow)';
%     legendInfo1_5_1{3} = '1,804t (0.5 deg by stern)';
%     xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
%     ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
%     % if enablePlotTitle == 1
%     %     title('{\bf Total uncertainty}','FontSize',setGeneralFontSize);
%     % end
%     grid on;
%     box on;
%     %axis square;
%     
%     %# Set plot figure background to a defined color
%     %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
%     set(gcf,'Color',[1,1,1]);
%     
%     % Colors and markers
%     set(h(1),'FaceColor',[0.4,0.4,0.4]);
%     set(h(2),'FaceColor',[0.6,0.6,0.6]);
%     set(h(3),'FaceColor',[0.8,0.8,0.8]);
%     %set(h(1),'FaceColor','r');
%     %set(h(2),'FaceColor','g');
%     %set(h(3),'FaceColor','b');
%     
%     %# Axis limitations
%     minX  = 0.18;
%     maxX  = 0.5;
%     incrX = 0.02;
%     minY  = 0;
%     maxY  = 3.5;
%     incrY = 0.5;
%     set(gca,'XLim',[minX maxX]);
%     set(gca,'XTick',minX:incrX:maxX);
%     set(gca,'YLim',[minY maxY]);
%     set(gca,'YTick',minY:incrY:maxY);
%     set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
%     set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
%     
%     %# Legend
%     hleg1 = legend(legendInfo1_5_1);
%     set(hleg1,'Location','NorthEast');
%     set(hleg1,'Interpreter','none');
%     set(hleg1,'LineWidth',1);
%     set(hleg1,'FontSize',setLegendFontSize);
%     %legend boxoff;
%     
%     %# Font sizes and border --------------------------------------------------
%     
%     set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
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
    % if enablePlotMainTitle == 1
    %     annotation('textbox', [0 0.9 1 0.1], ...
    %         'String', strcat('{\bf ', figurename, '}'), ...
    %         'EdgeColor', 'none', ...
    %         'HorizontalAlignment', 'center');
    % end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_1_6_Condition_7_to_12_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot1_6


%# ************************************************************************
%# 2. Fr versus resistance coefficient, total uncertainty (1,500 tonnes)
%# ************************************************************************
if enablePlot2 == 1
    figurename = 'Plot 2: Fr versus resistance coefficient, total uncertainty';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ------------------------------------------------
    
    % if enableA4PaperSizePlot == 1
    %     set(gcf, 'PaperSize', [19 19]);
    %     set(gcf, 'PaperPositionMode', 'manual');
    %     set(gcf, 'PaperPosition', [0 0 19 19]);
    %
    %     set(gcf, 'PaperUnits', 'centimeters');
    %     set(gcf, 'PaperSize', [19 19]);
    %     set(gcf, 'PaperPositionMode', 'manual');
    %     set(gcf, 'PaperPosition', [0 0 19 19]);
    % end
    
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
    
    %# Markes and colors ------------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    %setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,1)
    
    % X and Y axis values -----------------------------------------------------
    
    x = Cond7Data(:,3);
    y = Cond7Data(:,9);
    
    % x = Cond8Data(:,3);
    % y = Cond8Data(:,9);
    
    % x = Cond9Data(:,3);
    % y = Cond9Data(:,9);
    
    % x = Cond13Data(:,3);
    % y = Cond13Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,1,'r');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,500t (level trim)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 12;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,2)
    
    % X and Y axis values -----------------------------------------------------
    
    % x = Cond7Data(:,3);
    % y = Cond7Data(:,9);
    
    % x = Cond8Data(:,3);
    % y = Cond8Data(:,9);
    
    % x = Cond9Data(:,3);
    % y = Cond9Data(:,9);
    
    x = Cond13Data(:,3);
    y = Cond13Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,0.85,'c');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,500t (deep transom, Prohaska runs)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 16;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,3)
    
    % X and Y axis values -----------------------------------------------------
    
    % x = Cond7Data(:,3);
    % y = Cond7Data(:,9);
    
    x = Cond8Data(:,3);
    y = Cond8Data(:,9);
    
    % x = Cond9Data(:,3);
    % y = Cond9Data(:,9);
    
    % x = Cond13Data(:,3);
    % y = Cond13Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,0.15,'g');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,500t (-0.5 deg by bow)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 12;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,4)
    
    % X and Y axis values -----------------------------------------------------
    
    % x = Cond7Data(:,3);
    % y = Cond7Data(:,9);
    
    % x = Cond8Data(:,3);
    % y = Cond8Data(:,9);
    
    x = Cond9Data(:,3);
    y = Cond9Data(:,9);
    
    % x = Cond13Data(:,3);
    % y = Cond13Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,0.15,'b');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,500t (0.5 deg by stern)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 12;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# ************************************************************************
    %# Save plot as PNG
    %# ************************************************************************
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    % if enableA4PaperSizePlot == 1
    %     set(gcf, 'PaperUnits','centimeters');
    %     set(gcf, 'PaperSize',[XPlot YPlot]);
    %     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    %     set(gcf, 'PaperOrientation','portrait');
    % end
    
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
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_2_Condition_7_to_12_1500_Tonnes_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot2

%# ************************************************************************
%# 3. Fr versus resistance coefficient, total uncertainty (1,804 tonnes)
%# ************************************************************************
if enablePlot3 == 1
    figurename = 'Plot 3: Fr versus resistance coefficient, total uncertainty';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ----------------------------------------------------
    
    % if enableA4PaperSizePlot == 1
    %     set(gcf, 'PaperSize', [19 19]);
    %     set(gcf, 'PaperPositionMode', 'manual');
    %     set(gcf, 'PaperPosition', [0 0 19 19]);
    %
    %     set(gcf, 'PaperUnits', 'centimeters');
    %     set(gcf, 'PaperSize', [19 19]);
    %     set(gcf, 'PaperPositionMode', 'manual');
    %     set(gcf, 'PaperPosition', [0 0 19 19]);
    % end
    
    % Fonts and colours -------------------------------------------------------
    setGeneralFontName = 'Helvetica';
    setGeneralFontSize = 14;
    setBorderLineWidth = 2;
    setLegendFontSize  = 12;
    
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
    %setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,1)
    
    % X and Y axis values -----------------------------------------------------
    
    x = Cond10Data(:,3);
    y = Cond10Data(:,9);
    
    % x = Cond11Data(:,3);
    % y = Cond11Data(:,9);
    
    % x = Cond12Data(:,3);
    % y = Cond12Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,0.4,'r');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,804t (level trim)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 12;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,3)
    
    % X and Y axis values -----------------------------------------------------
    
    % x = Cond10Data(:,3);
    % y = Cond10Data(:,9);
    
    x = Cond11Data(:,3);
    y = Cond11Data(:,9);
    
    % x = Cond12Data(:,3);
    % y = Cond12Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,0.2,'g');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,804t (-0.5 deg by bow)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 12;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////////
    subplot(2,2,4)
    
    % X and Y axis values -----------------------------------------------------
    
    % x = Cond10Data(:,3);
    % y = Cond10Data(:,9);
    
    % x = Cond11Data(:,3);
    % y = Cond11Data(:,9);
    
    x = Cond12Data(:,3);
    y = Cond12Data(:,9);
    
    % Plotting ----------------------------------------------------------------
    hb = bar(x,y,0.2,'b');
    xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total uncertainty of C_{T} (%)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    title('{\bf 1,804t (0.5 deg by stern)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.05;
    maxX  = 0.5;
    incrX = 0.15;
    minY  = 0;
    maxY  = 12;
    incrY = 2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    % hleg1 = legend('Load cell');
    % set(hleg1,'Location','NorthWest');
    % set(hleg1,'Interpreter','none');
    % set(hleg1,'LineWidth',1);
    % set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# ************************************************************************
    %# Save plot as PNG
    %# ************************************************************************
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    % if enableA4PaperSizePlot == 1
    %     set(gcf, 'PaperUnits','centimeters');
    %     set(gcf, 'PaperSize',[XPlot YPlot]);
    %     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    %     set(gcf, 'PaperOrientation','portrait');
    % end
    
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
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_3_Condition_7_to_12_1804_Tonnes_Resistance_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end %enablePlot3

%# ////////////////////////////////////////////////////////////////////////
%# 1. Order resultsArrayUARes by Froude length number
%# 2. Remove from factor related runs (i.e. Prohaska) from resultsArrayUARes
%# ////////////////////////////////////////////////////////////////////////

% 1. Order
resultsArrayUARes = sortrows(resultsArrayUARes,[2 3]);

% 2. Remove Prohaska runs
resultsArrayUAResShort = [];
for l=1:qas
    if resultsArrayUARes(l,1) >= 81 && resultsArrayUARes(l,1) <= 234
        resultsArrayUAResShort(l,:) = resultsArrayUARes(l,:);
    end
end
resultsArrayUAResShort = resultsArrayUAResShort(any(resultsArrayUAResShort,2),:);  % Remove zero rows


%# ////////////////////////////////////////////////////////////////////////
%# START: Write results to CVS
%# ------------------------------------------------------------------------

M = resultsArrayUAResShort;
csvwrite('resultsArrayUAResShort.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsArrayUAResShort.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

%# ------------------------------------------------------------------------
%# END: Write results to CVS
%# ////////////////////////////////////////////////////////////////////////
