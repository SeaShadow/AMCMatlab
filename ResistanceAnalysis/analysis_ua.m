%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Uncertainty Analysis
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  January 21, 2014
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
%# CHANGES    :  21/01/2014 - Created new script
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
counter1 = 1;
for condNo=7:12
    
    % Set variables based on condition number
    if condNo == 7
        setCond   = cond7;
        setCondNo = 7;
        setModWsa = MSwsa1500;
        setModLwl = MSlwl1500;
        setBeam   = MSbeam1500;
        setFormFactor = 0.12;
    elseif condNo == 8
        setCond   = cond8;
        setCondNo = 8;
        setModWsa = MSwsa1500bybow;
        setModLwl = MSlwl1500bybow;
        setBeam   = MSbeam1500;
        setFormFactor = 0.12;
    elseif condNo == 9
        setCond   = cond9;
        setCondNo = 9;
        setModWsa = MSwsa1500bystern;
        setModLwl = MSlwl1500bystern;
        setBeam   = MSbeam1500;
        setFormFactor = 0.12;
    elseif condNo == 10
        setCond   = cond10;
        setCondNo = 10;
        setModWsa = MSwsa1804;
        setModLwl = MSlwl1804;
        setBeam   = MSbeam1500;
        setFormFactor = 0.12;
    elseif condNo == 11
        setCond   = cond11;
        setCondNo = 11;
        setModWsa = MSwsa1804bybow;
        setModLwl = MSlwl1804bybow;
        setBeam   = MSbeam1500;
        setFormFactor = 0.12;
    elseif condNo == 12
        setCond   = cond12;
        setCondNo = 12;
        setModWsa = MSwsa1804bystern;
        setModLwl = MSlwl1804bystern;
        setBeam   = MSbeam1500;
        setFormFactor = 0.12;
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
        %# 4.0 Input variables
        %# ////////////////////////////////////////////////////////////////
        
        % Model kinematic viscosity (m/s^2)
        setModKinVisc = modelkinviscosity;
        
        % Total Resistance Coefficient (average @ 15 deg C)
        setCF15degC   = 0.075/(log10((A{j}(1,5)*setModLwl)/setModKinVisc)-2)^2;
        
        % Frictional resistance coeff. at measured temp, tw
        setCFtw       = 0.075/(log10((A{j}(1,5)*setModLwl)/setModKinVisc)-2)^2;
        
        %# ////////////////////////////////////////////////////////////////
        %# 3.0 Multiple test uncertainty
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
        %# 4.0 Input variables (continued)
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
        
        %         if A{j}(1,11) == 0.20
        %             %resultsArrayRT
        %             avgCT
        %             avgCT15degC
        %             stdDev
        %             setMx
        %             setRx
        %         end
        
        %# ////////////////////////////////////////////////////////////////
        %# 6.0 Bias limits
        %# ////////////////////////////////////////////////////////////////
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.1 Wetted Surface
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % Bs1 (Assumed error in hull form)    (m^2)
        setBs1       = setModWsa*0.005;
        
        % Bs2 (Error in displacement)         (m^2)
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
        
        %         if A{j}(1,11) == 0.20
        %             setModLwl
        %             setBs1
        %             setBs2
        %             percentOfBs1
        %             percentOfBs2
        %             setBs
        %             percentOfS
        %         end
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.2 Speed
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % BV (Speed)   (m/s)
        setBv       = 0.003;
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        percentOfV  = (setBv/A{j}(1,5))*100;
        
        %         if A{j}(1,11) == 0.20
        %             setBv
        %             percentOfV
        %         end
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % 6.3 Resistance
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        % BMx1 (Calibration)                (Kg)
        setBMx1 = 0.000006847;
        
        % BMx2 (Curve fit bias)             (Kg)
        setBMx2 = 0.000007174;
        
        % BMx3 (Load cell misalignment)     (Kg)
        setBMx3 = 0.0008384;
        
        % BMx4 (Towing force inclination)   (Kg)
        setBMx4 = 0;
        
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % Wetted surface bias
        setBMx       = sqrt(setBMx1^2+setBMx2^2+setBMx3^2+setBMx4^2);  % Bs (Wetted Surface)    (Kg)
        percentOfBMx = (setBMx/setMx)*100;
        
        % Percentage of (Bs)^2
        percentOfBMx1 = (setBMx1^2/setBMx^2)*100;
        percentOfBMx2 = (setBMx2^2/setBMx^2)*100;
        percentOfBMx3 = (setBMx3^2/setBMx^2)*100;
        percentOfBMx4 = (setBMx4^2/setBMx^2)*100;
        
        %         if A{j}(1,11) == 0.20
        %             setBMx1
        %             setBMx2
        %             setBMx3
        %             setBMx4
        %             percentOfBMx1
        %             percentOfBMx2
        %             percentOfBMx3
        %             percentOfBMx4
        %             setBMx
        %             percentOfBMx
        %         end
        
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
        
        %         if A{j}(1,11) == 0.20
        %             setBtw
        %             setBRho
        %             percentOfTw
        %             percentOfRho
        %         end
        
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
        thetaRhoTw = abs(0.0638-(0.0173*15)+(0.000189*(15^2)));
        
        %         if A{j}(1,11) == 0.20
        %             thetaS
        %             thetaV
        %             thetaMx
        %             thetaRho
        %             thetaRhoTw
        %         end
        
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
        
        %         if A{j}(1,11) == 0.20
        %             setBCT
        %             percentOfCT15degC
        %         end
        
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
        
        %         if A{j}(1,11) == 0.20
        %             setM
        %             setSCT
        %             setPCT
        %             percentOfCT15degC_2
        %         end
        
        %# ////////////////////////////////////////////////////////////////
        %# 8.0 Total Uncertainty
        %# ////////////////////////////////////////////////////////////////
        
        % UCT15 deg C (Resistance Coefficient CT) (-)
        setUCT152degC = sqrt(setBCT^2+setSCT^2);
        
        % Percentage of CT at 15 deg C
        percentOfCT152degC = (setUCT152degC/avgCT15degC)*100;
        
        % Percentage of UCT at 15 deg C
        percentOfUCT152degC1 = (setBCT^2/setUCT152degC^2)*100;
        percentOfUCT152degC2 = (setPCT^2/setUCT152degC^2)*100;
        
        % Display in command window
        %         disp(sprintf('Run No.: %s => BCT: %s, %% of UCT15 deg C: %s',num2str(A{j}(k,1)),num2str(setBCT),num2str(percentOfUCT152degC1)));
        %         disp(sprintf('Run No.: %s => PCT: %s, %% of UCT15 deg C: %s',num2str(A{j}(k,1)),num2str(setPCT),num2str(percentOfUCT152degC2)));
        %         disp(sprintf('Run No.: %s => UCT 15 deg C: %s, %% of CT 15 deg C: %s',num2str(A{j}(k,1)),num2str(setUCT152degC),num2str(percentOfCT152degC)));
        %         disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        
        %         if A{j}(1,11) == 0.20
        %             setBCT
        %             setSCT
        %             setUCT152degC
        %             percentOfCT152degC
        %             percentOfUCT152degC1
        %             percentOfUCT152degC2
        %         end
        
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
        
        counter1 = counter1 + 1;
    end
    
end


%# ////////////////////////////////////////////////////////////////////
%# Plotting
%# ////////////////////////////////////////////////////////////////////

% Create one plot array per condition
[qas,ras] = size(resultsArrayUARes);

plotArray7  = [];
plotArray8  = [];
plotArray9  = [];
plotArray10 = [];
plotArray11 = [];
plotArray12 = [];

for l=1:qas
    if resultsArrayUARes(l,2) == 7 && resultsArrayUARes(l,1) >= 81 && resultsArrayUARes(l,1) <= 234
        plotArray7(l,:) = resultsArrayUARes(l,:);
    end
end
plotArray7 = plotArray7(any(plotArray7,2),:);  % Remove zero rows

for l=1:qas
    if resultsArrayUARes(l,2) == 8
        plotArray8(l,:) = resultsArrayUARes(l,:);
    end
end
plotArray8 = plotArray8(any(plotArray8,2),:);  % Remove zero rows

for l=1:qas
    if resultsArrayUARes(l,2) == 9
        plotArray9(l,:) = resultsArrayUARes(l,:);
    end
end
plotArray9 = plotArray9(any(plotArray9,2),:);  % Remove zero rows

for l=1:qas
    if resultsArrayUARes(l,2) == 10
        plotArray10(l,:) = resultsArrayUARes(l,:);
    end
end
plotArray10 = plotArray10(any(plotArray10,2),:);  % Remove zero rows

for l=1:qas
    if resultsArrayUARes(l,2) == 11
        plotArray11(l,:) = resultsArrayUARes(l,:);
    end
end
plotArray11 = plotArray11(any(plotArray11,2),:);  % Remove zero rows

for l=1:qas
    if resultsArrayUARes(l,2) == 12
        plotArray12(l,:) = resultsArrayUARes(l,:);
    end
end
plotArray12 = plotArray12(any(plotArray12,2),:);  % Remove zero rows

%# ////////////////////////////////////////////////////////////////////////
% Plots
%# ////////////////////////////////////////////////////////////////////////

%# PLOT #1: Fr versus resistance coefficient, total uncertainty ***********

figurename = sprintf('%s >> Conditions %s to %s', 'Total uncertainty U_{CT 15 deg C}', num2str(7), num2str(12));
f = figure('Name',figurename,'NumberTitle','off');

setX1 = plotArray7(:,3);
setY1 = plotArray7(:,9);

setX2 = plotArray8(:,3);
setY2 = plotArray8(:,9);

setX3 = plotArray9(:,3);
setY3 = plotArray9(:,9);

setX4 = plotArray10(:,3);
setY4 = plotArray10(:,9);

setX5 = plotArray11(:,3);
setY5 = plotArray11(:,9);

setX6 = plotArray12(:,3);
setY6 = plotArray12(:,9);

% Set marker size, color and line width
setMarkerSize = 10;
setLineWidth  = 1.5;
setColor1     = [0 0 1];
setColor2     = [0 0.5 0];
setColor3     = [1 0 0];
setColor4     = [1 0 1];
setColor5     = [1 0 0];
setColor6     = [0 1 1];

% Prepare plot
h = plot(setX1,setY1,'s',setX2,setY2,'x',setX3,setY3,'*',setX4,setY4,'v',setX5,setY5,'x',setX6,setY6,'*');   %,'MarkerSize',8,'MarkerEdgeColor','r','MarkerFaceColor','r'
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of C_{T15 deg C} [-]}');
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Colors and markers
set(h(1),'Color',setColor1,'Marker','s','MarkerSize',setMarkerSize,'LineWidth',setLineWidth); %,'MarkerFaceColor',setColor1,'LineStyle','-','linewidth',setLineWidth
set(h(2),'Color',setColor2,'Marker','x','MarkerSize',setMarkerSize,'LineWidth',setLineWidth); %,'MarkerFaceColor',setColor2,'LineStyle',':','linewidth',setLineWidth
set(h(3),'Color',setColor3,'Marker','*','MarkerSize',setMarkerSize,'LineWidth',setLineWidth); %,'MarkerFaceColor',setColor3,'LineStyle',':','linewidth',setLineWidth
set(h(4),'Color',setColor4,'Marker','v','MarkerSize',setMarkerSize,'LineWidth',setLineWidth); %,'MarkerFaceColor',setColor4,'LineStyle','-','linewidth',setLineWidth
set(h(5),'Color',setColor5,'Marker','x','MarkerSize',setMarkerSize,'LineWidth',setLineWidth); %,'MarkerFaceColor',setColor5,'LineStyle',':','linewidth',setLineWidth
set(h(6),'Color',setColor6,'Marker','*','MarkerSize',setMarkerSize,'LineWidth',setLineWidth); %,'MarkerFaceColor',setColor6,'LineStyle',':','linewidth',setLineWidth

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0.6 1.4]);
set(gca,'YTick',[0.6:0.05:1.4]);

%# Legend
hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%legend boxoff;

%# ------------------------------------------------------------------------
%# Save plot as PNG
%# ------------------------------------------------------------------------

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# Plot title -------------------------------------------------------------
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

%# ------------------------------------------------------------------------
%# Save plots as PDF and PNG
%# ------------------------------------------------------------------------
%plotsavenamePDF = sprintf('_plots/%s/Condition_7_to_12_Resistance_Uncertainty_Analysis_Plots.pdf', '_uncertainty_analysis');
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/%s/Condition_7_to_12_Resistance_Uncertainty_Analysis_Plots.png', '_uncertainty_analysis');
saveas(f, plotsavename);                % Save plot as PNG
%close;


%# -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
%# -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
%# -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/


%# PLOT #2: Resistance coefficient bias and precision limit ***************

% Fr versus resistance coefficient, total uncertainty
figurename = sprintf('%s >> Conditions %s to %s', 'Resistance coefficient bias and precision limits', num2str(7), num2str(12));
f = figure('Name',figurename,'NumberTitle','off');

% Condition 7 -------------------------------------------------------------
subplot(3,2,1)

X = plotArray7(:,3);
A = plotArray7(:,5);
B = plotArray7(:,7);

bar(X,[A B])
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of U_{CT15 deg C}}');
title('{\bf Cond 7: 1,500t, static trim level}');
grid on;
box on;

% % Set marker size
% setMarkerSize = 8;
%
% h = plot(X,A,'s',X,B,'o');
% xlabel('{\bf Froude length number [-]}');
% ylabel('{\bf % of U_{CT15 deg C}}');
% title('{\bf Cond 7: 1,500t, static trim level}');
% grid on;
% box on;
% %axis square;

% % Colors and markers
% set(h(1),'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',setMarkerSize);
% set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',setMarkerSize);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0 100]);
set(gca,'YTick',[0:20:100]);

%# Legend
hleg1 = legend('Resistance coefficient bias limit','Resistance coefficient precision limit');
set(hleg1,'Location','NorthEast'); %SouthOutside
set(hleg1,'Interpreter','none');
set(hleg1, 'Box', 'on');

% Condition 8 -------------------------------------------------------------
subplot(3,2,3)

X = plotArray8(:,3);
A = plotArray8(:,5);
B = plotArray8(:,7);

bar(X,[A B])
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of U_{CT15 deg C}}');
title('{\bf Cond 8: 1,500t, static trim 0.5}');
grid on;
box on;

% % Set marker size
% setMarkerSize = 8;
%
% h = plot(X,A,'s',X,B,'o');
% xlabel('{\bf Froude length number [-]}');
% ylabel('{\bf % of U_{CT15 deg C}}');
% title('{\bf Cond 8: 1,500t, static trim 0.5}');
% grid on;
% box on;
% %axis square;

% % Colors and markers
% set(h(1),'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',setMarkerSize);
% set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',setMarkerSize);

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0 100]);
set(gca,'YTick',[0:20:100]);

%# Legend
hleg1 = legend('Resistance coefficient bias limit','Resistance coefficient precision limit');
set(hleg1,'Location','NorthEast'); %SouthOutside
set(hleg1,'Interpreter','none');
set(hleg1, 'Box', 'on');

% Condition 9 -------------------------------------------------------------
subplot(3,2,5)

X = plotArray9(:,3);
A = plotArray9(:,5);
B = plotArray9(:,7);

bar(X,[A B])
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of U_{CT15 deg C}}');
title('{\bf Cond 9: 1,500t, static trim -0.5}');
grid on;
box on;

% % Set marker size
% setMarkerSize = 8;
%
% h = plot(X,A,'s',X,B,'o');
% xlabel('{\bf Froude length number [-]}');
% ylabel('{\bf % of U_{CT15 deg C}}');
% title('{\bf Cond 9: 1,500t, static trim -0.5}');
% grid on;
% box on;
% %axis square;

% % Colors and markers
% set(h(1),'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',setMarkerSize);
% set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',setMarkerSize);

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0 100]);
set(gca,'YTick',[0:20:100]);

%# Legend
hleg1 = legend('Resistance coefficient bias limit','Resistance coefficient precision limit');
set(hleg1,'Location','NorthEast'); %SouthOutside
set(hleg1,'Interpreter','none');
set(hleg1, 'Box', 'on');

% Condition 10 ------------------------------------------------------------
subplot(3,2,2)

X = plotArray10(:,3);
A = plotArray10(:,5);
B = plotArray10(:,7);

bar(X,[A B])
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of U_{CT15 deg C}}');
title('{\bf Cond 10: 1,804t, static trim level}');
grid on;
box on;

% % Set marker size
% setMarkerSize = 8;
%
% h = plot(X,A,'s',X,B,'o');
% xlabel('{\bf Froude length number [-]}');
% ylabel('{\bf % of U_{CT15 deg C}}');
% title('{\bf Cond 10: 1,804t, static trim level}');
% grid on;
% box on;
% %axis square;

% % Colors and markers
% set(h(1),'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',setMarkerSize);
% set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',setMarkerSize);

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0 100]);
set(gca,'YTick',[0:20:100]);

%# Legend
hleg1 = legend('Resistance coefficient bias limit','Resistance coefficient precision limit');
set(hleg1,'Location','NorthEast'); %SouthOutside
set(hleg1,'Interpreter','none');
set(hleg1, 'Box', 'on');

% Condition 11 ------------------------------------------------------------
subplot(3,2,4)

X = plotArray11(:,3);
A = plotArray11(:,5);
B = plotArray11(:,7);

bar(X,[A B])
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of U_{CT15 deg C}}');
title('{\bf Cond 11: 1,804t, static trim 0.5}');
grid on;
box on;

% % Set marker size
% setMarkerSize = 8;
%
% h = plot(X,A,'s',X,B,'o');
% xlabel('{\bf Froude length number [-]}');
% ylabel('{\bf % of U_{CT15 deg C}}');
% title('{\bf Cond 11: 1,804t, static trim 0.5}');
% grid on;
% box on;
% %axis square;

% % Colors and markers
% set(h(1),'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',setMarkerSize);
% set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',setMarkerSize);

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0 100]);
set(gca,'YTick',[0:20:100]);

%# Legend
hleg1 = legend('Resistance coefficient bias limit','Resistance coefficient precision limit');
set(hleg1,'Location','NorthEast'); %SouthOutside
set(hleg1,'Interpreter','none');
set(hleg1, 'Box', 'on');

% Condition 12 ------------------------------------------------------------
subplot(3,2,6)

X = plotArray12(:,3);
A = plotArray12(:,5);
B = plotArray12(:,7);

bar(X,[A B])
xlabel('{\bf Froude length number [-]}');
ylabel('{\bf % of U_{CT15 deg C}}');
title('{\bf Cond 12: 1,804t, static trim -0.5}');
grid on;
box on;

% % Set marker size
% setMarkerSize = 8;
%
% h = plot(X,A,'s',X,B,'o');
% xlabel('{\bf Froude length number [-]}');
% ylabel('{\bf % of U_{CT15 deg C}}');
% title('{\bf Cond 12: 1,804t, static trim -0.5}');
% grid on;
% box on;
% %axis square;

% % Colors and markers
% set(h(1),'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',setMarkerSize);
% set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',setMarkerSize);

%# Axis limitations
set(gca,'XLim',[0.2 0.5]);
set(gca,'XTick',[0.2:0.02:0.5]);
set(gca,'YLim',[0 100]);
set(gca,'YTick',[0:20:100]);

%# Legend
hleg1 = legend('Resistance coefficient bias limit','Resistance coefficient precision limit');
set(hleg1,'Location','NorthEast'); %SouthOutside
set(hleg1,'Interpreter','none');
set(hleg1, 'Box', 'on');

%# ------------------------------------------------------------------------
%# Save plot as PNG
%# ------------------------------------------------------------------------

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# Plot title -------------------------------------------------------------
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

%# ------------------------------------------------------------------------
%# Save plots as PDF and PNG
%# ------------------------------------------------------------------------
%plotsavenamePDF = sprintf('_plots/%s/Condition_7_to_12_Resistance_Coefficient_Bias_and_Precision_Limit_Plots.pdf', '_uncertainty_analysis');
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/%s/Condition_7_to_12_Resistance_Coefficient_Bias_and_Precision_Limit_Plots.png', '_uncertainty_analysis');
saveas(f, plotsavename);                % Save plot as PNG
%close;


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


%# ////////////////////////////////////////////////////////////////////////
%# Clear variables
%# ////////////////////////////////////////////////////////////////////////
clearvars ttlength ttwidth ttwaterdepth ttcsa ttwatertemp gravconst modelkinviscosity fullscalekinvi freshwaterdensity saltwaterdensity distbetwposts FStoMSratio
clearvars MSlwl1500 MSwsa1500 MSdraft1500 MSAx1500 BlockCoeff1500 FSlwl1500 FSwsa1500 FSdraft1500 MSlwl1500bybow MSwsa1500bybow MSdraft1500bybow MSAx1500bybow BlockCoeff1500bybow FSlwl1500bybow FSwsa1500bybow FSdraft1500bybow MSlwl1500bystern MSwsa1500bystern MSdraft1500bystern MSAx1500bystern BlockCoeff1500bystern FSlwl1500bystern FSwsa1500bystern FSdraft1500bystern MSbeam1500 MSbeam1500bybow MSbeam1500bystern
clearvars MSlwl1804 MSwsa1804 MSdraft1804 MSAx1804 BlockCoeff1804 FSlwl1804 FSwsa1804 FSdraft1804 MSlwl1804bybow MSwsa1804bybow MSdraft1804bybow MSAx1804bybow BlockCoeff1804bybow FSlwl1804bybow FSwsa1804bybow FSdraft1804bybow MSlwl1804bystern MSwsa1804bystern MSdraft1804bystern MSAx1804bystern BlockCoeff1804bystern FSlwl1804bystern FSwsa1804bystern FSdraft1804bystern MSbeam1804 MSbeam1804bybow MSbeam1804bystern
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
clearvars setFormFactor
clearvars ma na mas nas oas pas qas ras n results setCond setCondNo condNo counter1 counter2 h l f j k m A R M allPlots testName
clearvars setBeam setModWsa avgCT avgCT15degC setCF15degC setCFtw setCurrentCT setK setModKinVisc setModLwl setMx setRx setTw stdDev
clearvars cond1 cond2 cond3 cond4 cond5 cond6 cond13
clearvars setBs1 setBs2 setBs percentOfBs1 percentOfBs2 percentOfS setBv percentOfV setBMx1 setBMx2 setBMx3 setBMx4 setBMx percentOfBMx percentOfBMx1 percentOfBMx2 percentOfBMx3 percentOfBMx4 setBtw setBRho percentOfTw percentOfRho
clearvars thetaS thetaV thetaMx thetaRho thetaRhoTw setBCT percentOfCT15degC percentOfCT15degC_2 setSCT setBCT setPCT setM setUCT152degC percentOfCT152degC percentOfUCT152degC1 percentOfUCT152degC2
clearvars plotsavename fPath figurename hleg1 setMarkerSize
clearvars plotArray7 plotArray8 plotArray9 plotArray10 plotArray11 plotArray12
clearvars setX1 setX2 setX3 setX4 setX5 setX6 setY1 setY2 setY3 setY4 setY5 setY6
