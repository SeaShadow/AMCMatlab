%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Sensor Errors / Statistics
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  February 13, 2014
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
testName = 'Senstor Calibration';

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

fPath = sprintf('_plots/%s', '_sensor_error_statistics');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ************************************************************************


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED 
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableCompOverlayPlot = 0;      % Comparison overlay plots

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************  


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
    %showMessage = sprintf('%s. Processing >>> %s...',num2str(k),currentFileName{1});
    showMessage = sprintf('%s. Filename: %s >>> Processing <<<',num2str(k),currentFileName{1});
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
   
    % Linear regression model #2 (better as using existing functionality))
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
    %[10]  R2                                                            (-)
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
    resultsArray(k, 10)  = r2VvsFD;
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

R = resultsArray;
A = arrayfun(@(x) R(R(:,2) == x, :), unique(R(:,2)), 'uniformoutput', false);

dataLoadCell = A{1};
dataAftLVDT  = A{2};
dataFwdLVDT  = A{3};

% TODO: Plotting?

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

    %# ////////////////////////////////////////////////////////////////////
    %# Comparison Overlay Plotting: Load cell
    %# ////////////////////////////////////////////////////////////////////
    
    %figurename = sprintf('%s filename: %s', 'Calibration', currentFileName{1});
    figurename = 'Load Cell: Calibration comparison overlay';
    f = figure('Name',figurename,'NumberTitle','off');
    
    x1 = colVoltage{1}; y1 = colRealValue{1}; m1 = 'rs'; l1 = 'r--';
    polyf1 = polyfit(x1,y1,1); polyv1 = polyval(polyf1,x1);
    
    % slope1     = polyf1(1,1);    % Slope
    % intercept1 = polyf1(1,2);    % Intercept
    
    x2 = colVoltage{2}; y2 = colRealValue{2}; m2 = 'gv'; l2 = 'g--';
    polyf2 = polyfit(x2,y2,1); polyv2 = polyval(polyf2,x2);
    
    x3 = colVoltage{3}; y3 = colRealValue{3}; m3 = 'bo'; l3 = 'b--';
    polyf3 = polyfit(x3,y3,1); polyv3 = polyval(polyf3,x3);
    
    x4 = colVoltage{4}; y4 = colRealValue{4}; m4 = 'cd'; l4 = 'c--';
    polyf4 = polyfit(x4,y4,1); polyv4 = polyval(polyf4,x4);
    
    x5 = colVoltage{5}; y5 = colRealValue{5}; m5 = 'mp'; l5 = 'm--';
    polyf5 = polyfit(x5,y5,1); polyv5 = polyval(polyf5,x5);
    
    x6 = colVoltage{6}; y6 = colRealValue{6}; m6 = 'yh'; l6 = 'y--';
    polyf6 = polyfit(x6,y6,1); polyv6 = polyval(polyf6,x6);
    
    x7 = colVoltage{7}; y7 = colRealValue{7}; m7 = 'k>'; l7 = 'k--';
    polyf7 = polyfit(x7,y7,1); polyv7 = polyval(polyf7,x7);
    
    % Plot
    h = plot(x1,y1,m1,x2,y2,m2,x3,y3,m3,x4,y4,m4,x5,y5,m5,x6,y6,m6,x7,y7,m7,'MarkerSize',10);
    hold on;
    h = plot(x1,polyv1,l1,x2,polyv2,l2,x3,polyv3,l3,x4,polyv4,l4,x5,polyv5,l5,x6,polyv6,l6,x7,polyv7,l7);
    xlabel('{\bf Sensor output [V]}');
    ylabel('{\bf Force [N]}');
    %setTitle = sprintf('%s',currentFileName{1});
    % str = strcat('{\bf ',setTitle,'}');
    % title(str);
    % title('{\bf Load cell calibration}');
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
    
    %# Legend
    hleg1 = legend('Cal. 67:: Gain: 2x10, Filter: 1Hz, Date: 27/08/13','Cal. 68:: Gain: 2x10, Filter: 1Hz, Date: 28/08/13','Cal. 69:: Gain: 2x10, Filter: 1Hz, Date: 29/08/13','Cal. 70:: Gain: 2x10, Filter: 1Hz, Date: 30/08/13','Cal. 72:: Gain: 2x10, Filter: 1Hz, Date: 02/09/13','Cal. 73:: Gain: 2x10, Filter: 1Hz, Date: 03/09/13','Cal. 76:: Gain: 2x10, Filter: 1Hz, Date: 05/09/13','Cal. 67:: Curve fit','Cal. 68:: Curve fit','Cal. 69:: Curve fit','Cal. 70:: Curve fit','Cal. 72:: Curve fit','Cal. 73:: Curve fit','Cal. 76:: Curve fit');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    %legend boxoff;
    
    %# --------------------------------------------------------------------
    %# Save plot as PNG
    %# --------------------------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    
    %# --------------------------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    %# --------------------------------------------------------------------
    %# Save plots as PDF and PNG
    %# --------------------------------------------------------------------
    %plotsavenamePDF = sprintf('_plots/%s/Load_Cell_Calibration_Comparison_Plots.pdf', '_sensor_error_statistics');
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Load_Cell_Calibration_Comparison_Plots.png', '_sensor_error_statistics');
    saveas(f, plotsavename);                % Save plot as PNG
    %close;
    
    
    %# ////////////////////////////////////////////////////////////////////
    %# Comparison Overlay Plotting: Aft LVDT
    %# ////////////////////////////////////////////////////////////////////
    
    %figurename = sprintf('%s filename: %s', 'Calibration', currentFileName{1});
    figurename = 'Aft LVDT: Calibration comparison overlay';
    f = figure('Name',figurename,'NumberTitle','off');
    
    x1 = colVoltage{8};  y1 = colRealValue{8};  m1 = 'rs'; l1 = 'r--';
    polyf1 = polyfit(x1,y1,1); polyv1 = polyval(polyf1,x1);
    
    x2 = colVoltage{9};  y2 = colRealValue{9};  m2 = 'gv'; l2 = 'g--';
    polyf2 = polyfit(x2,y2,1); polyv2 = polyval(polyf2,x2);
    
    x3 = colVoltage{10}; y3 = colRealValue{10}; m3 = 'bo'; l3 = 'h--';
    polyf3 = polyfit(x3,y3,1); polyv3 = polyval(polyf3,x3);
    
    x4 = colVoltage{11}; y4 = colRealValue{11}; m4 = 'cd'; l4 = 'c--';
    polyf4 = polyfit(x4,y4,1); polyv4 = polyval(polyf4,x4);
    
    x5 = colVoltage{12}; y5 = colRealValue{12}; m5 = 'mp'; l5 = 'm--';
    polyf5 = polyfit(x5,y5,1); polyv5 = polyval(polyf5,x5);
    
    % Plot
    h = plot(x1,y1,m1,x2,y2,m2,x3,y3,m3,x4,y4,m4,x5,y5,m5,'MarkerSize',10);
    hold on;
    h = plot(x1,polyv1,l1,x2,polyv2,l2,x3,polyv3,l3,x4,polyv4,l4,x5,polyv5,l5);
    xlabel('{\bf Sensor output [V]}');
    ylabel('{\bf Distance [mm]}');
    %setTitle = sprintf('%s',currentFileName{1});
    % str = strcat('{\bf ',setTitle,'}');
    % title(str);
    % title('{\bf Aft LVDT calibration}');
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
    
    %# Legend
    hleg1 = legend('Cal. 36:: Gain: 2.5, Filter: 1Hz, Date: 28/08/13','Cal. 37:: Gain: 2.5, Filter: 1Hz, Date: 29/08/13','Cal. 38:: Gain: 2.5, Filter: 1Hz, Date: 30/08/13','Cal. 39:: Gain: 2.5, Filter: 1Hz, Date: 02/09/13','Cal. 40:: Gain: 2.5, Filter: 1Hz, Date: 03/09/13','Cal. 36:: Curve fit','Cal. 37:: Curve fit','Cal. 38:: Curve fit','Cal. 39:: Curve fit','Cal. 40:: Curve fit');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    %legend boxoff;
    
    %# --------------------------------------------------------------------
    %# Save plot as PNG
    %# --------------------------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    
    %# --------------------------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    %# --------------------------------------------------------------------
    %# Save plots as PDF and PNG
    %# --------------------------------------------------------------------
    %plotsavenamePDF = sprintf('_plots/%s/Aft_LVDT_Calibration_Comparison_Plots.pdf', '_sensor_error_statistics');
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Aft_LVDT_Calibration_Comparison_Plots.png', '_sensor_error_statistics');
    saveas(f, plotsavename);                % Save plot as PNG
    %close;
    
    
    %# ////////////////////////////////////////////////////////////////////
    %# Comparison Overlay Plotting: Aft LVDT
    %# ////////////////////////////////////////////////////////////////////
    
    %figurename = sprintf('%s filename: %s', 'Calibration', currentFileName{1});
    figurename = 'Fwd LVDT: Calibration comparison overlay';
    f = figure('Name',figurename,'NumberTitle','off');
    
    x1 = colVoltage{13}; y1 = colRealValue{13}; m1 = 'rs'; l1 = 'r--';
    polyf1 = polyfit(x1,y1,1); polyv1 = polyval(polyf1,x1);
    
    x2 = colVoltage{14}; y2 = colRealValue{14}; m2 = 'gv'; l2 = 'g--';
    polyf2 = polyfit(x2,y2,1); polyv2 = polyval(polyf2,x2);
    
    x3 = colVoltage{15}; y3 = colRealValue{15}; m3 = 'bo'; l3 = 'b--';
    polyf3 = polyfit(x3,y3,1); polyv3 = polyval(polyf3,x3);
    
    x4 = colVoltage{16}; y4 = colRealValue{16}; m4 = 'cd'; l4 = 'c--';
    polyf4 = polyfit(x4,y4,1); polyv4 = polyval(polyf4,x4);
    
    x5 = colVoltage{17}; y5 = colRealValue{17}; m5 = 'mp'; l5 = 'm--';
    polyf5 = polyfit(x5,y5,1); polyv5 = polyval(polyf5,x5);
    
    % Plot
    h = plot(x1,y1,m1,x2,y2,m2,x3,y3,m3,x4,y4,m4,x5,y5,m5,'MarkerSize',10);
    hold on;
    h = plot(x1,polyv1,l1,x2,polyv2,l2,x3,polyv3,l3,x4,polyv4,l4,x5,polyv5,l5);
    xlabel('{\bf Sensor output [V]}');
    ylabel('{\bf Distance [mm]}');
    %setTitle = sprintf('%s',currentFileName{1});
    % str = strcat('{\bf ',setTitle,'}');
    % title(str);
    % title('{\bf Aft LVDT calibration}');
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
    
    %# Legend
    hleg1 = legend('Cal. 36:: Gain: 2.5, Filter: 1Hz, Date: 28/08/13','Cal. 37:: Gain: 2.5, Filter: 1Hz, Date: 29/08/13','Cal. 38:: Gain: 2.5, Filter: 1Hz, Date: 30/08/13','Cal. 39:: Gain: 2.5, Filter: 1Hz, Date: 02/09/13','Cal. 40:: Gain: 2.5, Filter: 1Hz, Date: 03/09/13','Cal. 36:: Curve fit','Cal. 37:: Curve fit','Cal. 38:: Curve fit','Cal. 39:: Curve fit','Cal. 40:: Curve fit');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    %legend boxoff;
    
    %# --------------------------------------------------------------------
    %# Save plot as PNG
    %# --------------------------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    
    %# Plot title ---------------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    %# --------------------------------------------------------------------
    %# Save plots as PDF and PNG
    %# --------------------------------------------------------------------
    %plotsavenamePDF = sprintf('_plots/%s/Fwd_LVDT_Calibration_Comparison_Plots.pdf', '_sensor_error_statistics');
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Fwd_LVDT_Calibration_Comparison_Plots.png', '_sensor_error_statistics');
    saveas(f, plotsavename);                % Save plot as PNG
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