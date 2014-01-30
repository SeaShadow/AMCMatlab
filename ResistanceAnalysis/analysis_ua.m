%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Uncertainty Analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Z�rcher (kzurcher@amc.edu.au)
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
%#
%#               >>> TODO: Copy data from resultsArrayUARes.dat to full_resistance_data.dat
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


% *************************************************************************
% START: CALCULATING MIN, MAX AND AVERAGED DATA
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

%# *********************************************************************
%# Testname
%# *********************************************************************
testName = 'Resistance uncertainty analysis';

% *************************************************************************
%# UA #1: Resistance Measurements
% *************************************************************************

resultsArrayUARes = [];
%# Results array columns: 
    %[1] Run No.                                                        (-)
    %[2] Condition                                                      (-)
    %[3] Model Froude length number                                     (-)

%# ************************************************************************
%# ITTC Based Resistance Uncertainty Analysis (multipe tests)
%# ************************************************************************

% Loop through conditions
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
        % Loop through individual array entries
        [mas,nas] = size(A{j});      % Array dimensions

        %# ----------------------------------------------------------------
        %# 4.0 Input variables
        %# ----------------------------------------------------------------
        
        setModKinVisc = modelkinviscosity;    % Model kinematic viscosity (m/s^2) 
        setCF15degC = 0.075/(log10((A{j}(1,5)*setModLwl)/setModKinVisc)-2)^2;    % Total Resistance Coefficient (average @ 15 deg C)
        setCFtw     = 0.075/(log10((A{j}(1,5)*setModLwl)/setModKinVisc)-2)^2;    % Frictional resistance coeff. at measured temp, tw
               
        %# ----------------------------------------------------------------
        %# 3.0 Multiple test uncertainty
        %# ----------------------------------------------------------------
        resultsArrayRT = [];
        counter2 = 1;
        for k=1:mas
            
            % CT
            resultsArrayRT(counter2, 1) = (2*A{j}(k,9))/(freshwaterdensity*setModWsa*A{j}(k,5)^2);
            
            % CT at 15 degrees C
            setCurrentCT = resultsArrayRT(counter2, 1);
            resultsArrayRT(counter2, 2) = setCurrentCT+((setCF15degC-setCFtw)*(1+setFormFactor));
            
            % Write results to array to save to file
            %resultsArrayUARes(counter2, 1) = A{j}(k,1);       % Run no.
            %resultsArrayUARes(counter2, 2) = setCondNo;       % Condition
            %resultsArrayUARes(counter2, 3) = A{j}(k,11);      % Froude length number
            
            counter2 = counter2 + 1;
        end
        
        % Total resistance coefficients and standard deviaton -------------
        avgCT       = mean(resultsArrayRT(:,1));  % Total Resistance Coefficient CT values
        avgCT15degC = mean(resultsArrayRT(:,2));  % Total Resistance Coefficient CT values
        stdDev      = std(resultsArrayRT(:,1));   % Standard deviation

        %# 4.0 Input variables (continued) --------------------------------
        setK    = 2;                          % K = 2 (confidence level of approx. 95%)
                                              % K = 3 (confidence level greater than 99%)         
        setRx   = avgCT15degC*0.5*freshwaterdensity*setModWsa*A{j}(1,5)^2;  % Resistance average
        setMx   = setRx/gravconst;            % Total resistance mass in x-direction
        setTw   = ttwatertemp;                % Water temperature            
        
%         if A{j}(1,11) == 0.20
%             %resultsArrayRT
%             avgCT
%             avgCT15degC
%             stdDev
%             setMx
%             setRx
%         end
        
        %# ----------------------------------------------------------------
        %# 6.0 Bias limits
        %# ----------------------------------------------------------------
        
        % 6.1 Wetted Surface ++++++++++++++++++++++++++++++++++++++++++++++
        
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        setBs1       = setModWsa*0.005;  % Bs1 (Assumed error in hull form)    (m^2)       
        setBs2       = setBs1/2;         % Bs2 (Error in displacement)         (m^2)
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % Wetted surface bias
        setBs       = sqrt(setBs1^2+setBs2^2);  % Bs (Wetted Surface)          (m^2)
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
        
        % 6.2 Speed +++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        setBv       = 0.003;  % BV (Speed)          (m/s)
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        percentOfV  = (setBv/A{j}(1,5))*100;
        
%         if A{j}(1,11) == 0.20
%             setBv
%             percentOfV
%         end
        
        % 6.3 Resistance ++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        setBMx1 = 0.000006847;  % BMx1 (Calibration)                (Kg)
        setBMx2 = 0.000007174;  % BMx2 (Curve fit bias)             (Kg)
        setBMx3 = 0.0008384;    % BMx3 (Load cell misalignment)     (Kg)
        setBMx4 = 0;            % BMx4 (Towing force inclination)   (Kg)
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
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
                
        % 6.4 Towing tank water properties ++++++++++++++++++++++++++++++++
        
        % START: Input Values >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        setBtw  = 0.2;   % Btw (Water Temperature)   (Deg C)
        setBRho = 1;     % Brho (Water Density)      (Kg/m^3)
        % END: Input Values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        percentOfTw  = (setBtw/setTw)*100;
        percentOfRho = (setBRho/freshwaterdensity)*100;
        
%         if A{j}(1,11) == 0.20
%             setBtw
%             setBRho
%             percentOfTw
%             percentOfRho
%         end

        %# ----------------------------------------------------------------
        %# Populate resultsArrayUARes
        %# ----------------------------------------------------------------
        
        %# Results array columns: 
            %[1]  Run No.                                               (-)
            %[2]  Condition                                             (-)
            %[3]  Froude length number                                  (-)        
        
        resultsArrayUARes(counter1, 1) = A{j}(1,1);       % Run no.
        resultsArrayUARes(counter1, 2) = setCondNo;       % Condition
        resultsArrayUARes(counter1, 3) = A{j}(1,11);      % Froude length number

        counter1 = counter1 + 1;
    end

end

%# Order resultsArrayUARes by Froude length number
resultsArrayUARes = sortrows(resultsArrayUARes,[2 3]);

% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

M = resultsArrayUARes;
csvwrite('resultsArrayUARes.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('resultsArrayUARes.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# Clear variables
%# ************************************************************************
clearvars ttlength ttwidth ttwaterdepth ttcsa ttwatertemp gravconst modelkinviscosity fullscalekinvi freshwaterdensity saltwaterdensity distbetwposts FStoMSratio 
clearvars MSlwl1500 MSwsa1500 MSdraft1500 MSAx1500 BlockCoeff1500 FSlwl1500 FSwsa1500 FSdraft1500 MSlwl1500bybow MSwsa1500bybow MSdraft1500bybow MSAx1500bybow BlockCoeff1500bybow FSlwl1500bybow FSwsa1500bybow FSdraft1500bybow MSlwl1500bystern MSwsa1500bystern MSdraft1500bystern MSAx1500bystern BlockCoeff1500bystern FSlwl1500bystern FSwsa1500bystern FSdraft1500bystern MSbeam1500 MSbeam1500bybow MSbeam1500bystern
clearvars MSlwl1804 MSwsa1804 MSdraft1804 MSAx1804 BlockCoeff1804 FSlwl1804 FSwsa1804 FSdraft1804 MSlwl1804bybow MSwsa1804bybow MSdraft1804bybow MSAx1804bybow BlockCoeff1804bybow FSlwl1804bybow FSwsa1804bybow FSdraft1804bybow MSlwl1804bystern MSwsa1804bystern MSdraft1804bystern MSAx1804bystern BlockCoeff1804bystern FSlwl1804bystern FSwsa1804bystern FSdraft1804bystern MSbeam1804 MSbeam1804bybow MSbeam1804bystern
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
clearvars setFormFactor
clearvars ma na mas nas n results setCond setCondNo condNo counter1 counter2 j k m A R M allPlots testName 
clearvars setBeam setModWsa avgCT avgCT15degC setCF15degC setCFtw setCurrentCT setK setModKinVisc setModLwl setMx setRx setTw stdDev
clearvars cond1 cond2 cond3 cond4 cond5 cond6 cond13
clearvars setBs1 setBs2 setBs percentOfBs1 percentOfBs2 percentOfS setBv percentOfV setBMx1 setBMx2 setBMx3 setBMx4 setBMx percentOfBMx percentOfBMx1 percentOfBMx2 percentOfBMx3 percentOfBMx4 setBtw setBRho percentOfTw percentOfRho
