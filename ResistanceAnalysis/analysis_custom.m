%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Custome Plots
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  January 8, 2015
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
%# CHANGES    :  23/09/2013 - Created new script
%#               14/01/2014 - Added conditions list and updated script
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
enablePlotMainTitle     = 1;    % Show plot title in saved file
enablePlotTitle         = 1;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 1;    % Show plots scale to A4 size

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


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
    % Additional values added: 15/12/2014, ITTC 1978 (2011), 7.5-02-03-01.4
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

% *************************************************************************
% START: PLOTTING AVERAGED DATA
% *************************************************************************

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
testName = 'Custom Plots';

%# *********************************************************************
%# Min & Max Values
%# *********************************************************************

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

%# *********************************************************************
%# Calculate averages for conditions
%# *********************************************************************
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


% /////////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% -------------------------------------------------------------------------
M = resultsAveragedArray;
csvwrite('resultsAveragedArray.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsAveragedArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% -------------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength           = 100;                    % Towing Tank: Length            (m)
ttwidth            = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth       = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa              = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp        = 17.5;                   % Towing Tank: Water temperature (degrees C)

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
MSdisp1500          = 74.47;                            % Model displacemment            (Kg)
MSVdisp1500         = MSdisp1500/freshwaterdensity;     % Model volumetric displacemment (m^3)
%# ////////////////////////////////////////////////////////////////////////

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,804 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSdisp1804          = 89.18;                            % Model displacemment            (Kg)
MSVdisp1804         = MSdisp1804/freshwaterdensity;     % Model volumetric displacemment (m^3)
%# ////////////////////////////////////////////////////////////////////////

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


% *************************************************************************
% 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
    
    startRun = 81;
    endRun   = 231;
    
    % *********************************************************************
    % Fr vs. Rtm/(VDisp * Density * Gravitational constant)
    % *********************************************************************
    %figurename = sprintf('%s (Averaged):: 1,500 and 1,804 tonnes', testName); % , num2str(startRun), num2str(endRun)
    figurename = 'Averaged Non-Dimensional Resistance for 1,500 and 1,804 tonnes';
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
        'FontSize',16,...
        'LineWidth',2,...
        'FontName',setGeneralFontName,...
        'Clipping','off',...
        'Color',[1 1 1],...
        'LooseInset',get(gca,'TightInset'));
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    %setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize           = 10;
    setLineWidthMarker      = 1;
    setLineWidthMarkerCond7 = 1;
    setLineWidth            = 1;
    setLineStyle            = '-.';
    
    % Model speed vs. non dim ---------------------------------------------
    subplot(1,2,1)
    
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,9);
        
        cond7Array = [];
        cond7Array(:,1) = xavgcond7;
        cond7Array(:,2) = yavgcond7;
        
        [m,n] = size(cond7Array); % Array dimensions
        
        for j=1:m
            cond7Array(j,3) = (cond7Array(j,2)/(MSVdisp1500*freshwaterdensity*gravconst));
        end
        
        x7 = cond7Array(:,1); y7 = cond7Array(:,3);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,9);
        
        cond8Array = [];
        cond8Array(:,1) = xavgcond8;
        cond8Array(:,2) = yavgcond8;
        
        [m,n] = size(cond8Array); % Array dimensions
        
        for j=1:m
            cond8Array(j,3) = (cond8Array(j,2)/(MSVdisp1500*freshwaterdensity*gravconst));
        end
        
        x8 = cond8Array(:,1); y8 = cond8Array(:,3);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,9);
        
        cond9Array = [];
        cond9Array(:,1) = xavgcond9;
        cond9Array(:,2) = yavgcond9;
        
        [m,n] = size(cond9Array);        % Array dimensions
        
        for j=1:m
            cond9Array(j,3) = (cond9Array(j,2)/(MSVdisp1500*freshwaterdensity*gravconst));
        end
        
        x9 = cond9Array(:,1); y9 = cond9Array(:,3);
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,9);
        
        cond10Array = [];
        cond10Array(:,1) = xavgcond10;
        cond10Array(:,2) = yavgcond10;
        
        [m,n] = size(cond10Array); % Array dimensions
        
        for j=1:m
            cond10Array(j,3) = (cond10Array(j,2)/(MSVdisp1804*freshwaterdensity*gravconst));
        end
        
        x10 = cond10Array(:,1); y10 = cond10Array(:,3);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,9);
        
        cond11Array = [];
        cond11Array(:,1) = xavgcond11;
        cond11Array(:,2) = yavgcond11;
        
        [m,n] = size(cond11Array); % Array dimensions
        
        for j=1:m
            cond11Array(j,3) = (cond11Array(j,2)/(MSVdisp1804*freshwaterdensity*gravconst));
        end
        
        x11 = cond11Array(:,1); y11 = cond11Array(:,3);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,9);
        
        cond12Array = [];
        cond12Array(:,1) = xavgcond12;
        cond12Array(:,2) = yavgcond12;
        
        [m,n] = size(cond12Array); % Array dimensions
        
        for j=1:m
            cond12Array(j,3) = (cond12Array(j,2)/(MSVdisp1804*freshwaterdensity*gravconst));
        end
        
        x12 = cond12Array(:,1); y12 = cond12Array(:,3);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('$\frac{\bf{R_{Tm}}}{\bf{\nabla\;\rho\;g}}$ [-]','Interpreter','LaTex','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarkerCond7);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.08;
    maxX  = 0.52;
    incrX = 0.04;
    minY  = 0;
    maxY  = 0.08;
    incrY = 0.01;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    %# Legend
    %hleg1 = legend('1,500t (0 deg)','1,500t (-0.5 deg)','1,500t (0.5 deg)','1,804t (0 deg)','1,804t (-0.5 deg)','1,804t (0.5 deg)');
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. non dim ---------------------------------------------
    subplot(1,2,2)
    
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,9);
        
        cond7Array = [];
        cond7Array(:,1) = xavgcond7;
        cond7Array(:,2) = yavgcond7;
        
        [m,n] = size(cond7Array); % Array dimensions
        
        for j=1:m
            cond7Array(j,3) = (cond7Array(j,2)/(MSVdisp1500*freshwaterdensity*gravconst))*(1/cond7Array(j,1)^2);
        end
        
        x7 = cond7Array(:,1); y7 = cond7Array(:,3);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,9);
        
        cond8Array = [];
        cond8Array(:,1) = xavgcond8;
        cond8Array(:,2) = yavgcond8;
        
        [m,n] = size(cond8Array); % Array dimensions
        
        for j=1:m
            cond8Array(j,3) = (cond8Array(j,2)/(MSVdisp1500*freshwaterdensity*gravconst))*(1/cond8Array(j,1)^2);
        end
        
        x8 = cond8Array(:,1); y8 = cond8Array(:,3);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,9);
        
        cond9Array = [];
        cond9Array(:,1) = xavgcond9;
        cond9Array(:,2) = yavgcond9;
        
        [m,n] = size(cond9Array);        % Array dimensions
        
        for j=1:m
            cond9Array(j,3) = (cond9Array(j,2)/(MSVdisp1500*freshwaterdensity*gravconst))*(1/cond9Array(j,1)^2);
        end
        
        x9 = cond9Array(:,1); y9 = cond9Array(:,3);
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,9);
        
        cond10Array = [];
        cond10Array(:,1) = xavgcond10;
        cond10Array(:,2) = yavgcond10;
        
        [m,n] = size(cond10Array); % Array dimensions
        
        for j=1:m
            cond10Array(j,3) = (cond10Array(j,2)/(MSVdisp1804*freshwaterdensity*gravconst))*(1/cond10Array(j,1)^2);
        end
        
        x10 = cond10Array(:,1); y10 = cond10Array(:,3);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,9);
        
        cond11Array = [];
        cond11Array(:,1) = xavgcond11;
        cond11Array(:,2) = yavgcond11;
        
        [m,n] = size(cond11Array); % Array dimensions
        
        for j=1:m
            cond11Array(j,3) = (cond11Array(j,2)/(MSVdisp1804*freshwaterdensity*gravconst))*(1/cond11Array(j,1)^2);
        end
        
        x11 = cond11Array(:,1); y11 = cond11Array(:,3);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,9);
        
        cond12Array = [];
        cond12Array(:,1) = xavgcond12;
        cond12Array(:,2) = yavgcond12;
        
        [m,n] = size(cond12Array); % Array dimensions
        
        for j=1:m
            cond12Array(j,3) = (cond12Array(j,2)/(MSVdisp1804*freshwaterdensity*gravconst))*(1/cond12Array(j,1)^2);
        end
        
        x12 = cond12Array(:,1); y12 = cond12Array(:,3);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('$\frac{\bf{R_{Tm}}}{\bf{\nabla\;\rho\;g}}\;\frac{\bf{1}}{\bf{F_{r}^{2}}}$ [-]','Interpreter','LaTex','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarkerCond7);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.08;
    maxX  = 0.52;
    incrX = 0.04;
    minY  = 0.2;
    maxY  = 0.35;
    incrY = 0.03;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    %hleg1 = legend('1,500t (0 deg)','1,500t (-0.5 deg)','1,500t (0.5 deg)','1,804t (0 deg)','1,804t (-0.5 deg)','1,804t (0.5 deg)');
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# ********************************************************************
    %# Save plot as PNG
    %# ********************************************************************
    
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
    
    %# Save plots as PDF, PNG and EPS -------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Fr_vs_NonDim_Data_Averaged_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end
