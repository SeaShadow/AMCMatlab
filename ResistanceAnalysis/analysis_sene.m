%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Sensor Errors / Statistics
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  June 8, 2015
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
%# CHANGES    :  13/02/2014 - Created new script
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
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle     = 0;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 0;    % Show plots scale to A4 size

% Special plots
enableCompOverlayPlot   = 1;    % Comparison overlay plots

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
%profile on

%# ------------------------------------------------------------------------
%# Path where run directories are located
%# ------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\..\\';      % Relative path from Matlab directory


%# ////////////////////////////////////////////////////////////////////////
%# GENERAL SETTINGS AND CONSTANTS
%# ////////////////////////////////////////////////////////////////////////

%# Test name
testName = 'Sensor Calibration';

%# ************************************************************************
%# START DEFINE PLOT SIZE
% -------------------------------------------------------------------------

%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)

% -------------------------------------------------------------------------
%# END DEFINE PLOT SIZE
%# ************************************************************************


%# ************************************************************************
% START: CHECK IF DIRECTORY FOR CALIBRATION FILES EXITS
% -------------------------------------------------------------------------

%# _PLOTS directory
fPath = sprintf('%sDAQ CAL Files\\', runfilespath);
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required DAQ CAL Files directory does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end

% -------------------------------------------------------------------------
% END: CHECK IF DIRECTORY FOR CALIBRATION FILES EXITS
%# ************************************************************************


%# ************************************************************************
%# START: CREATE PLOTS AND RUN DIRECTORY
%# ------------------------------------------------------------------------

%# _sensor_error_statistics directory -------------------------------------
setDirName = '_sensor_error_statistics';

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


%# ////////////////////////////////////////////////////////////////////////
%# Read data from files
%# ////////////////////////////////////////////////////////////////////////

%# ------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# ------------------------------------------------------------------------

headerlines             = 15;  % Number of headerlines to data
headerlinesZeroAndCalib = 15;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------
%# Calibration files
%# ------------------------------------------------------------------------
calFileArray = {
    % Load cell
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 270813_67.cal';
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 280813_68.cal';
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 290813_69.cal';
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 300813_70.cal';
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 020913_72.cal';
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 030913_73.cal';
    '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 050913_76.cal';
    % Aft LVDT
    '02_Ch2_AftLVDT Gain 2.5 Filter 1Hz280813_36.cal';
    '02_Ch2_AftLVDT Gain 2.5 Filter 1Hz290813_37.cal';
    '02_Ch2_AftLVDT Gain 2.5 Filter 1Hz300813_38.cal';
    '02_Ch2_AftLVDT Gain 2.5 Filter 1Hz020913_39.cal';
    '02_Ch2_AftLVDT Gain 2.5 Filter 1Hz030913_40.cal'
    % Fwd LVDT
    '01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 280813_36.cal';
    '01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 290813_37.cal';
    '01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 300813_38.cal';
    '01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 020913_39.cal';
    '01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 030913_40.cal'
    };

%# ------------------------------------------------------------------------
%# Loop through calibration files
%# ------------------------------------------------------------------------

% Number of files = 18 (7 for load cell, 5 for aft LVDT and 5 for fwd LVDT)
startRun = 1;
endRun   = 17;

resultsArray = [];
%w = waitbar(0,'Processed run files');
for k=startRun:endRun
    
    % Retrieve current filename from calFileArray
    currentFileName = calFileArray(k);
    
    % Display message
    showMessage = sprintf('>>> Processing <<< (%s) %s',num2str(k),currentFileName{1});
    disp(showMessage);
    
    % Define title based on calibration file
    if any(1:7 == k);
        setTitle      = 'Load cell';
        setSensorType = 1;
    elseif any(8:12 == k);
        setTitle      = 'Aft LVDT';
        setSensorType = 2;
    elseif any(13:17 == k);
        setTitle      = 'Fwd LVDT';
        setSensorType = 3;
    else
        setTitle      = 'Undefined title';
        setSensorType = 0;
    end
    
    %# Allow for 1 to become 01 for run numbers
    filename = sprintf('%sDAQ CAL Files\\%s', runfilespath, currentFileName{1});
    
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
    
    %# ********************************************************************
    %# START: Columns as variables (RAW DATA)
    %# --------------------------------------------------------------------
    
    % Access variables using colValue{1}, colValue{2}, etc.
    colValue{k}   = data(:,1);   % Value
    colVoltage{k} = data(:,2);   % Voltage
    colSlope{k}   = data(:,3);   % Slope
    
    % Array size; where m = rows and n = columns
    [m,n] = size(data);
    
    %# --------------------------------------------------------------------
    %# END: Columns as variables (RAW DATA)
    %# ********************************************************************
    
    % Convert Grams to Newtons (load cell only!)
    if any(1:7 == k);
        useColumn = colValue{k};
        colRealValue{k} = num2cell(useColumn); colRealValue{k} = cellfun(@(y) (y/1000)*9.806, colRealValue{k}, 'UniformOutput', false); useColumn = cell2mat(colRealValue{k});
        % Concert cell array to numeric array
        colRealValue{k} = cell2mat(colRealValue{k});
    else
        colRealValue{k} = colValue{k};
    end;
    
    % Linear fit (voltage vs. force or distance) --------------------------
    x = colVoltage{k};
    y = colRealValue{k};
    
    polyf = polyfit(x,y,1);
    polyv = polyval(polyf,x);
    
    % Calculate R^2 (RSQ)
    % See: http://www.mathworks.com.au/help/matlab/data_analysis/linear-regression.html
    yresid  = y - polyv;
    SSresid = sum(yresid.^2);
    SStotal = (length(y)-1) * var(y);
    rsq     = 1 - SSresid/SStotal;
    rsq_adj = 1 - SSresid/SStotal * (length(y)-1)/(length(y)-length(polyf));
    
    % Define valiables
    fitSlopeVvsFD     = polyf(1,1);    % Slope
    fitInterceptVvsFD = polyf(1,2);    % Intercept
    r2VvsFD           = rsq;           % Compute simple R2
    r2AdjVvsFD        = rsq_adj;       % Compute simple R2 adjusted for degrees of freedom
    
    % Linear fit (voltage vs. grams or distance) --------------------------
    x = colVoltage{k};
    y = colValue{k};
    
    polyf = polyfit(x,y,1);
    polyv = polyval(polyf,x);
    
    % Calculate R^2(RSQ)
    % See: http://www.mathworks.com.au/help/matlab/data_analysis/linear-regression.html
    yresid  = y - polyv;
    SSresid = sum(yresid.^2);
    SStotal = (length(y)-1) * var(y);
    rsq     = 1 - SSresid/SStotal;
    rsq_adj = 1 - SSresid/SStotal * (length(y)-1)/(length(y)-length(polyf));
    
    fitSlopeVvsGD     = polyf(1,1);    % Slope
    fitInterceptVvsGD = polyf(1,2);    % Intercept
    r2VvsGD           = rsq;           % Compute simple R2
    r2AdjVvsGD        = rsq_adj;       % Compute simple R2 adjusted for degrees of freedom
    
    % Calculate fit values ------------------------------------------------
    x = colVoltage{k};
    y = colRealValue{k};
    
    % Fit values and error values
    fitValuesArray = [];
    errorArray     = [];
    for kk=1:m
        fitValuesArray(kk, 1) = x(kk)*fitSlopeVvsFD+fitInterceptVvsFD;
        errorArray(kk, 1)     = y(kk)-fitValuesArray(kk, 1);
    end
    
    % Error: Mean and standard deviation
    meanVvsFD   = mean(errorArray);
    stddevVvsFD = std(errorArray);
    
    % Calculate standard error --------------------------------------------
    % Note: Standard error of the predicted y-value for each x in the regression
    
    % Regression analysis
    % See: http://www.mathworks.com.au/help/stats/regress.html
    x = colVoltage{k};
    y = colRealValue{k};
    
    % Regression data
    %X = [ones(size(x)) x];
    %[b,bint,r,rint,stats] = regress(y,X);
    %rsquared = stats(1)
    
    % Linear regression model #1
    %     a    = fitSlopeVvsFD;
    %     Sxx  = sum((x-mean(x)).^2);
    %     Syy  = sum((y-mean(y)).^2);
    %     Sxy  = sum((x-mean(x)).*(y-mean(y)));
    %     SSE  = Syy-a*Sxy;
    %     S2yx = SSE/(n-2);
    %     Syx = sqrt(SSE/(n-2));
    
    % Linear regression model #2 (better than using existing functionality))
    % See: http://www.mathworks.com.au/help/stats/linearmodel.fit.html
    lm = LinearModel.fit(x,y,'linear');
    
    %# ////////////////////////////////////////////////////////////////////
    %# Populate resultsArray
    %# ////////////////////////////////////////////////////////////////////
    
    %# Results array columns:
    %[1]  Calibration file no                                           (-)
    %[2]  Sensor type                                                   (-)
    % 1 = Load cell
    % 2 = Aft LVDT
    % 3 = Aft LVDT
    
    % Error
    %[3]  Error, mean                                                   (-)
    %[4]  Error, standard deviation                                     (-)
    
    % Standard error
    %[5]  1 x standard error (1SEE)                                     (-)
    %[6]  2 x standard error (2SEE) (i.e. approx 95% confidencce)       (-)
    %[7]  3 x standard error (3SEE) (i.e. greater 99% confidencce)      (-)
    
    % Voltage vs. force or distance
    %[8]  Fit intercept                                                 (-)
    %[9]  Fit slope                                                     (-)
    %[10] R2                                                            (-)
    %[11] R2 adjusted for degrees of freedom:                           (-)
    
    % Voltage vs. grams or distance
    %[12] Fit intercept                                                 (-)
    %[13] Fit slope                                                     (-)
    %[14] R2                                                            (-)
    %[15] R2 adjusted for degrees of freedom:                           (-)
    
    %# Calibration --------------------------------------------------------
    resultsArray(k, 1)  = k;
    resultsArray(k, 2)  = setSensorType;
    
    %# Error --------------------------------------------------------------
    resultsArray(k, 3)  = meanVvsFD;
    resultsArray(k, 4)  = stddevVvsFD;
    
    %# Standard Error -----------------------------------------------------
    resultsArray(k, 5)  = lm.SSE;
    resultsArray(k, 6)  = 2*lm.SSE;
    resultsArray(k, 7)  = 3*lm.SSE;
    
    %# Voltage vs. force or distance --------------------------------------
    resultsArray(k, 8)  = fitInterceptVvsFD;
    resultsArray(k, 9)  = fitSlopeVvsFD;
    resultsArray(k, 10) = r2VvsFD;
    resultsArray(k, 11) = r2AdjVvsFD;
    
    %# Voltage vs. grams or distance --------------------------------------
    resultsArray(k, 12) = fitInterceptVvsGD;
    resultsArray(k, 13) = fitSlopeVvsGD;
    resultsArray(k, 14) = r2VvsGD;
    resultsArray(k, 15) = r2AdjVvsGD;
    
end

%# ////////////////////////////////////////////////////////////////////////
%# Split results array based on column 2 (i.e. sensor type)
%# ////////////////////////////////////////////////////////////////////////

% R = resultsArray;
% A = arrayfun(@(x) R(R(:,2) == x, :), unique(R(:,2)), 'uniformoutput', false);
%
% dataLoadCell = A{1};
% dataAftLVDT  = A{2};
% dataFwdLVDT  = A{3};

dataLoadCell = resultsArray(1:7,:);
dataAftLVDT  = resultsArray(8:12,:);
dataFwdLVDT  = resultsArray(13:17,:);

% /////////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% -------------------------------------------------------------------------

M = resultsArray;
csvwrite('resultsArraySensorError.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsArraySensorError.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% -------------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////////


%# ////////////////////////////////////////////////////////////////////////
%# Comparison Overlay Plotting
%# ////////////////////////////////////////////////////////////////////////
if enableCompOverlayPlot == 1
    
    %# ********************************************************************
    %# 1. Comparison Overlay Plotting: Load cell
    %# ********************************************************************
    figurename = 'Plot 1: Load Cell: Calibration Comparison';
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
    
    % X and Y axis values -------------------------------------------------
    x1 = colVoltage{1}; y1 = colRealValue{1};
    polyf1 = polyfit(x1,y1,1); polyv1 = polyval(polyf1,x1);
    
    x2 = colVoltage{2}; y2 = colRealValue{2};
    polyf2 = polyfit(x2,y2,1); polyv2 = polyval(polyf2,x2);
    
    x3 = colVoltage{3}; y3 = colRealValue{3};
    polyf3 = polyfit(x3,y3,1); polyv3 = polyval(polyf3,x3);
    
    x4 = colVoltage{4}; y4 = colRealValue{4};
    polyf4 = polyfit(x4,y4,1); polyv4 = polyval(polyf4,x4);
    
    x5 = colVoltage{5}; y5 = colRealValue{5};
    polyf5 = polyfit(x5,y5,1); polyv5 = polyval(polyf5,x5);
    
    x6 = colVoltage{6}; y6 = colRealValue{6};
    polyf6 = polyfit(x6,y6,1); polyv6 = polyval(polyf6,x6);
    
    x7 = colVoltage{7}; y7 = colRealValue{7};
    polyf7 = polyfit(x7,y7,1); polyv7 = polyval(polyf7,x7);
    
    % Plotting ------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*',x7,y7,'*');
    
    % Markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(7),'Color',setColor{7},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    hold on;
    h = plot(x1,polyv1,'-',x2,polyv2,'-',x3,polyv3,'-',x4,polyv4,'-',x5,polyv5,'-',x6,polyv6,'-',x7,polyv7,'-');
    
    % Lines
    set(h(1),'Color',setColor{1},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{2},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(3),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(4),'Color',setColor{4},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(5),'Color',setColor{5},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(6),'Color',setColor{6},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(7),'Color',setColor{7},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    xlabel('{\bf Sensor output (V)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Force (N)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Load Cell: Calibration Comparison}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[-10 0]);
    set(gca,'XTick',-10:1:0);
    set(gca,'YLim',[0 55]);
    set(gca,'YTick',0:5:55);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend('Cal. 67:: Gain: 2x10, Filter: 1Hz, Date: 27/08/13','Cal. 68:: Gain: 2x10, Filter: 1Hz, Date: 28/08/13','Cal. 69:: Gain: 2x10, Filter: 1Hz, Date: 29/08/13','Cal. 70:: Gain: 2x10, Filter: 1Hz, Date: 30/08/13','Cal. 72:: Gain: 2x10, Filter: 1Hz, Date: 02/09/13','Cal. 73:: Gain: 2x10, Filter: 1Hz, Date: 03/09/13','Cal. 76:: Gain: 2x10, Filter: 1Hz, Date: 05/09/13','Cal. 67:: Curve fit','Cal. 68:: Curve fit','Cal. 69:: Curve fit','Cal. 70:: Curve fit','Cal. 72:: Curve fit','Cal. 73:: Curve fit','Cal. 76:: Curve fit');
    hleg1 = legend('Cal. 67:: Gain: 2x10, Filter: 1Hz, Date: 27/08/13','Cal. 68:: Gain: 2x10, Filter: 1Hz, Date: 28/08/13','Cal. 69:: Gain: 2x10, Filter: 1Hz, Date: 29/08/13','Cal. 70:: Gain: 2x10, Filter: 1Hz, Date: 30/08/13','Cal. 72:: Gain: 2x10, Filter: 1Hz, Date: 02/09/13','Cal. 73:: Gain: 2x10, Filter: 1Hz, Date: 03/09/13','Cal. 76:: Gain: 2x10, Filter: 1Hz, Date: 05/09/13');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/Plot_1_Load_Cell_Calibration_Comparison_Plot.%s', '_sensor_error_statistics', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ********************************************************************
    %# 2. Comparison Overlay Plotting: Aft LVDT
    %# ********************************************************************
    figurename = 'Plot 2: Aft LVDT: Calibration Comparison';
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
    
    % X and Y axis values -------------------------------------------------
    x1 = colVoltage{8};  y1 = colRealValue{8};
    polyf1 = polyfit(x1,y1,1); polyv1 = polyval(polyf1,x1);
    
    x2 = colVoltage{9};  y2 = colRealValue{9};
    polyf2 = polyfit(x2,y2,1); polyv2 = polyval(polyf2,x2);
    
    x3 = colVoltage{10}; y3 = colRealValue{10};
    polyf3 = polyfit(x3,y3,1); polyv3 = polyval(polyf3,x3);
    
    x4 = colVoltage{11}; y4 = colRealValue{11};
    polyf4 = polyfit(x4,y4,1); polyv4 = polyval(polyf4,x4);
    
    x5 = colVoltage{12}; y5 = colRealValue{12};
    polyf5 = polyfit(x5,y5,1); polyv5 = polyval(polyf5,x5);
    
    % Plotting ------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*');
    
    % Markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    hold on;
    h = plot(x1,polyv1,'-',x2,polyv2,'-',x3,polyv3,'-',x4,polyv4,'-',x5,polyv5,'-');
    
    % Lines
    set(h(1),'Color',setColor{1},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{2},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(3),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(4),'Color',setColor{4},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(5),'Color',setColor{5},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    xlabel('{\bf Sensor output (V)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Distance (mm)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Aft LVDT: Calibration Comparison}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[-10 10]);
    set(gca,'XTick',-10:2:10);
    set(gca,'YLim',[-40 40]);
    set(gca,'YTick',-40:10:40);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend('Cal. 36:: Gain: 2.5, Filter: 1Hz, Date: 28/08/13','Cal. 37:: Gain: 2.5, Filter: 1Hz, Date: 29/08/13','Cal. 38:: Gain: 2.5, Filter: 1Hz, Date: 30/08/13','Cal. 39:: Gain: 2.5, Filter: 1Hz, Date: 02/09/13','Cal. 40:: Gain: 2.5, Filter: 1Hz, Date: 03/09/13','Cal. 36:: Curve fit','Cal. 37:: Curve fit','Cal. 38:: Curve fit','Cal. 39:: Curve fit','Cal. 40:: Curve fit');
    hleg1 = legend('Cal. 36:: Gain: 2.5, Filter: 1Hz, Date: 28/08/13','Cal. 37:: Gain: 2.5, Filter: 1Hz, Date: 29/08/13','Cal. 38:: Gain: 2.5, Filter: 1Hz, Date: 30/08/13','Cal. 39:: Gain: 2.5, Filter: 1Hz, Date: 02/09/13','Cal. 40:: Gain: 2.5, Filter: 1Hz, Date: 03/09/13');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/Plot_2_Aft_LVDT_Calibration_Comparison_Plots.%s', '_sensor_error_statistics', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ********************************************************************
    %# 3. Comparison Overlay Plotting: Aft LVDT
    %# ********************************************************************
    figurename = 'Plot 3: Fwd LVDT: Calibration Comparison';
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
    
    % X and Y axis values -------------------------------------------------
    x1 = colVoltage{13}; y1 = colRealValue{13};
    polyf1 = polyfit(x1,y1,1); polyv1 = polyval(polyf1,x1);
    
    x2 = colVoltage{14}; y2 = colRealValue{14};
    polyf2 = polyfit(x2,y2,1); polyv2 = polyval(polyf2,x2);
    
    x3 = colVoltage{15}; y3 = colRealValue{15};
    polyf3 = polyfit(x3,y3,1); polyv3 = polyval(polyf3,x3);
    
    x4 = colVoltage{16}; y4 = colRealValue{16};
    polyf4 = polyfit(x4,y4,1); polyv4 = polyval(polyf4,x4);
    
    x5 = colVoltage{17}; y5 = colRealValue{17};
    polyf5 = polyfit(x5,y5,1); polyv5 = polyval(polyf5,x5);
    
    % Plotting ------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*');
    
    % Markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    hold on;
    h = plot(x1,polyv1,'-',x2,polyv2,'-',x3,polyv3,'-',x4,polyv4,'-',x5,polyv5,'-');
    
    % Lines
    set(h(1),'Color',setColor{1},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{2},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(3),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(4),'Color',setColor{4},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(5),'Color',setColor{5},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    xlabel('{\bf Sensor output (V)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Distance (mm)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Fwd LVDT: Calibration Comparison}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[-10 10]);
    set(gca,'XTick',-10:2:10);
    set(gca,'YLim',[-40 40]);
    set(gca,'YTick',-40:10:40);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend('Cal. 36:: Gain: 2.5, Filter: 1Hz, Date: 28/08/13','Cal. 37:: Gain: 2.5, Filter: 1Hz, Date: 29/08/13','Cal. 38:: Gain: 2.5, Filter: 1Hz, Date: 30/08/13','Cal. 39:: Gain: 2.5, Filter: 1Hz, Date: 02/09/13','Cal. 40:: Gain: 2.5, Filter: 1Hz, Date: 03/09/13','Cal. 36:: Curve fit','Cal. 37:: Curve fit','Cal. 38:: Curve fit','Cal. 39:: Curve fit','Cal. 40:: Curve fit');
    hleg1 = legend('Cal. 36:: Gain: 2.5, Filter: 1Hz, Date: 28/08/13','Cal. 37:: Gain: 2.5, Filter: 1Hz, Date: 29/08/13','Cal. 38:: Gain: 2.5, Filter: 1Hz, Date: 30/08/13','Cal. 39:: Gain: 2.5, Filter: 1Hz, Date: 02/09/13','Cal. 40:: Gain: 2.5, Filter: 1Hz, Date: 03/09/13');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/Plot_3_Fwd_LVDT_Calibration_Comparison_Plots.%s', '_sensor_error_statistics', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ********************************************************************
    %# 4. Standard error (SEE)
    %# ********************************************************************
    figurename = 'Plot 4: Standard error (SEE)';
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
    
    % SUBPLOT /////////////////////////////////////////////////////////////
    subplot(2,1,1)
    
    % X and Y axis values -------------------------------------------------
    
    % Load cell
    x = dataLoadCell(:,1);
    y = dataLoadCell(:,5);
    
    % Plotting ------------------------------------------------------------
    hb = bar(x,y,0.5,'b');
    xlabel('{\bf Calibration no. (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf SEE (N)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %title('{\bf Load cell}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    %     minX  = 1;
    %     maxX  = 7;
    %     incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.2;
    %     set(gca,'XLim',[minX maxX]);
    %     set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Load cell');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////
    subplot(2,1,2)
    
    % X and Y axis values -------------------------------------------------
    
    % Aft LVDT
    %x1 = dataAftLVDT(:,1);
    y1 = dataAftLVDT(:,5);
    
    % Fwd LVDT
    %x2 = dataFwdLVDT(:,1);
    y2 = dataFwdLVDT(:,5);    
    
    % Combine aft and fwd Y values
    %x = [x1 x2];
    y = [y1 y2];
    
    % Plotting ------------------------------------------------------------
    hb = bar(y);
    xlabel('{\bf Calibration no. (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf SEE (N)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %title('{\bf Aft and fwd LVDT}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Source: http://www.mathworks.com/matlabcentral/answers/137221-change-bar-graph-legend-color
    hbc = get(hb, 'Children');
    set(hbc{1}, 'FaceColor', 'r');
    set(hbc{2}, 'FaceColor', 'g');
    
    %# Axis limitations
    %     minX  = 1;
    %     maxX  = 7;
    %     incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.2;
    %     set(gca,'XLim',[minX maxX]);
    %     set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend([hbc{:}],'Aft LVDT','Fwd LVDT');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;

    %# Font sizes and border --------------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/Plot_4_Load_Cell_and_LVDT_Calibration_Standard_Error_SEE_Plot.%s', '_sensor_error_statistics', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ********************************************************************
    %# 4.1 Standard error (2SEE) - 95% confidence
    %# ********************************************************************
    figurename = 'Plot 4.1: Standard error (2SEE) - 95% confidence';
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
    
    % SUBPLOT /////////////////////////////////////////////////////////////
    subplot(2,1,1)
    
    % X and Y axis values -------------------------------------------------
    
    % Load cell
    x = dataLoadCell(:,1);
    y = dataLoadCell(:,6);
    
    % Plotting ------------------------------------------------------------
    hb = bar(x,y,0.5,'b');
    xlabel('{\bf Calibration no. (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf 2SEE (mm)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %title('{\bf Load cell}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    %     minX  = 1;
    %     maxX  = 7;
    %     incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.2;
    %     set(gca,'XLim',[minX maxX]);
    %     set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Load cell');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////
    subplot(2,1,2)
    
    % X and Y axis values -------------------------------------------------
    
    % Aft LVDT
    %x1 = dataAftLVDT(:,1);
    y1 = dataAftLVDT(:,6);
    
    % Fwd LVDT
    %x2 = dataFwdLVDT(:,1);
    y2 = dataFwdLVDT(:,6);    
    
    % Combine aft and fwd Y values
    %x = [x1 x2];
    y = [y1 y2];
    
    % Plotting ------------------------------------------------------------
    hb = bar(y);
    xlabel('{\bf Calibration no. (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf 2SEE (mm)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %title('{\bf Aft and fwd LVDT}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Source: http://www.mathworks.com/matlabcentral/answers/137221-change-bar-graph-legend-color
    hbc = get(hb, 'Children');
    set(hbc{1}, 'FaceColor', 'r');
    set(hbc{2}, 'FaceColor', 'g');
    
    %# Axis limitations
    %     minX  = 1;
    %     maxX  = 7;
    %     incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.2;
    %     set(gca,'XLim',[minX maxX]);
    %     set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend([hbc{:}],'Aft LVDT','Fwd LVDT');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;

    %# Font sizes and border --------------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/Plot_4_1_Load_Cell_and_LVDT_Calibration_Standard_Error_2_SEE_Plot.%s', '_sensor_error_statistics', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ********************************************************************
    %# 4.2 Standard error (3SEE) - 99% confidence
    %# ********************************************************************
    figurename = 'Plot 4.2: Standard error (3SEE) - 99% confidence';
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
    
    % SUBPLOT /////////////////////////////////////////////////////////////
    subplot(2,1,1)
    
    % X and Y axis values -------------------------------------------------
    
    % Load cell
    x = dataLoadCell(:,1);
    y = dataLoadCell(:,7);
    
    % Plotting ------------------------------------------------------------
    hb = bar(x,y,0.5,'b');
    xlabel('{\bf Calibration no. (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf 3SEE (mm)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %title('{\bf Load cell}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    %     minX  = 1;
    %     maxX  = 7;
    %     incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.2;
    %     set(gca,'XLim',[minX maxX]);
    %     set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Load cell');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % SUBPLOT /////////////////////////////////////////////////////////////
    subplot(2,1,2)
    
    % X and Y axis values -------------------------------------------------
    
    % Aft LVDT
    %x1 = dataAftLVDT(:,1);
    y1 = dataAftLVDT(:,7);
    
    % Fwd LVDT
    %x2 = dataFwdLVDT(:,1);
    y2 = dataFwdLVDT(:,7);    
    
    % Combine aft and fwd Y values
    %x = [x1 x2];
    y = [y1 y2];
    
    % Plotting ------------------------------------------------------------
    hb = bar(y);
    xlabel('{\bf Calibration no. (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf 3SEE (mm)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %title('{\bf Aft and fwd LVDT}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % Source: http://www.mathworks.com/matlabcentral/answers/137221-change-bar-graph-legend-color
    hbc = get(hb, 'Children');
    set(hbc{1}, 'FaceColor', 'r');
    set(hbc{2}, 'FaceColor', 'g');
    
    %# Axis limitations
    %     minX  = 1;
    %     maxX  = 7;
    %     incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.2;
    %     set(gca,'XLim',[minX maxX]);
    %     set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend([hbc{:}],'Aft LVDT','Fwd LVDT');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;

    %# Font sizes and border --------------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/Plot_4_2_Load_Cell_and_LVDT_Calibration_Standard_Error_3_SEE_Plot.%s', '_sensor_error_statistics', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

%# ////////////////////////////////////////////////////////////////////////
%# Clear variables
%# ////////////////////////////////////////////////////////////////////////
clearvars enableCompOverlayPlot
clearvars ext A R a i k kk h f m n X figurename str setMarkerSize setLineWidth plotsavename showMessage hleg1 polyf polyv x y rsq rsq_adj yresid SSresid SStotal setSensorType setTitle
clearvars startRun endRun headerlines headerlinesZeroAndCalib filename testName runfilespath allPlots colheaders pathstr vars name currentFileName fPath calFileArray
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
clearvars zAndCFData zAndCF ZeroAndCalibData ZeroAndCalib AllRawChannelData
clearvars colVoltage colValue colSlope colRealValue useColumn
clearvars x1 x2 x3 x4 x5 x6 x7 y1 y2 y3 y4 y5 y6 y7 m1 m2 m3 m4 m5 m6 m7
clearvars fitSlopeVvsFD fitInterceptVvsFD r2VvsFD r2AdjVvsFD fitSlopeVvsGD fitInterceptVvsGD r2VvsGD r2AdjVvsGD meanVvsFD stddevVvsFD
clearvars b bint r rint stats
clearvars Sxx Syy Sxy SSE S2yx Syx lm
