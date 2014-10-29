%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Statistics and averaged run data
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  October 29, 2014
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
%# CHANGES    :  10/09/2013 - Created new script
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

% Individual plots
enableTurbStimPlot      = 0; % Turbulence stimulator investigation
enableTrimTabPlot       = 0; % Trim tab investigation
enableResistancePlot    = 0; % Resistance plots, Ctm, power, heave and trim
enableProhaskaPlot      = 0; % Prohaska plot, form factor at deep transom
enableErrorPlot         = 0; % Error plots (% of max-avg to magnitude)
enableMeanStdPlot       = 0; % Show Fr vs. mean of standard deviation
enableStdPlot           = 0; % Show Fr vs. standard deviation
enableRemVSCFmPlot      = 1; % Show Re vs. Cfm plot

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


% *************************************************************************
%# RESULTS ARRAY COLUMNS
% *************************************************************************
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
%# ERROR ANALYSIS ------------------------------------------------------------------
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

%# ------------------------------------------------------------------------
%# Read results DAT file
%# ------------------------------------------------------------------------

if exist('full_resistance_data.dat', 'file') == 2
    %# Read results file
    results = csvread('full_resistance_data.dat');
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('WARNING: Data file for full resistance data (full_resistance_data) does not exist!');
    %break;
end

%# Stop script if required data unavailble --------------------------------
if exist('results','var') == 0
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required resistance data file does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end

%# ************************************************************************
%# START: PLOTTING AVERAGED DATA
%# ************************************************************************

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
testName = 'Resistance Test Summary';


%# *********************************************************************
%# Calculate averages for conditions
%# *********************************************************************

% NOTE: Averaging functions adds new columns which are:
%[49] SPEED: Mean of standard deviation                                 (-)
%[50] LVDT (FWD): Mean of standard deviation                            (-)
%[51] LVDT (AFT): Mean of standard deviation                            (-)
%[52] DRAG: Mean of standard deviation                                  (-)
%[53] Number how many times run has been repeated                       (-)

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


%# ************************************************************************
%# TURBULENCE STIMULATOR CONDITIONS
%# ************************************************************************
if enableTurbStimPlot == 1 && (length(cond1) ~= 0 || length(cond2) ~= 0 || length(cond3) ~= 0)
    
    startRun = 1;
    endRun   = 35;
    
    figurename = sprintf('Resistance Test:: Turbulence Stimulator Investigation, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    %# Plot repeat data ---------------------------------------------------
    subplot(1,2,1)
    
    if length(cond1) ~= 0
        xcond1 = cond1(:,11); ycond1 = cond1(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond1); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond1 = cell2mat(Raw_Data);
        
        x1 = xcond1; y1 = ycond1;
    else
        x1 = 0; y1 = 0;
    end
    if length(cond2) ~= 0
        xcond2 = cond2(:,11); ycond2 = cond2(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond2); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond2 = cell2mat(Raw_Data);
        
        x2 = xcond2; y2 = ycond2;
    else
        x2 = 0; y2 = 0;
    end
    if length(cond3) ~= 0
        xcond3 = cond3(:,11); ycond3 = cond3(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond3); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond3 = cell2mat(Raw_Data);
        
        x3 = xcond3; y3 = ycond3;
    else
        x3 = 0; y3 = 0;
    end
    
    % Plotting
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
    if enablePlotTitle == 1
        title('{\bf Repeated runs}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line, colors and markers
    setMarkerSize      = 10;
    setLineWidthMarker = 2;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.45]);
    set(gca,'XTick',[0.2:0.05:0.45]);
    set(gca,'YLim',[5.9 6.6]);
    set(gca,'YTick',[5.9:0.1:6.6]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 1: 1,500t (Barehull)','Cond. 2: 1,500t (1st row)','Cond. 3: 1,500t (1st and 2nd row)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Plot averaged data -----------------------------------------------------
    subplot(1,2,2)
    
    if length(avgcond1) ~= 0
        xavgcond1 = avgcond1(:,11); yavgcond1 = avgcond1(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond1); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond1 = cell2mat(Raw_Data);
        
        x1 = xavgcond1; y1 = yavgcond1;
    else
        x1 = 0; y1 = 0;
    end
    if length(avgcond2) ~= 0
        xavgcond2 = avgcond2(:,11); yavgcond2 = avgcond2(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond2); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond2 = cell2mat(Raw_Data);
        
        x2 = xavgcond2; y2 = yavgcond2;
    else
        x2 = 0; y2 = 0;
    end
    if length(avgcond3) ~= 0
        xavgcond3 = avgcond3(:,11); yavgcond3 = avgcond3(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond3); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond3 = cell2mat(Raw_Data);
        
        x3 = xavgcond3; y3 = yavgcond3;
    else
        x3 = 0; y3 = 0;
    end
    
    % Plotting
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
    if enablePlotTitle == 1
        title('{\bf Average of repeated runs}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 10;
    setLineWidthMarker = 2;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle,'linewidth',setLineWidth
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.45]);
    set(gca,'XTick',[0.2:0.05:0.45]);
    set(gca,'YLim',[5.9 6.6]);
    set(gca,'YTick',[5.9:0.1:6.6]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 1: 1,500t (Barehull)','Cond. 2: 1,500t (1st row)','Cond. 3: 1,500t (1st and 2nd row)');
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Turbulence_Stimulator_Resistance_Data_Plots_Repeats_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% TRIM TAB CONDITIONS
% *************************************************************************
if enableTrimTabPlot == 1 && (length(cond4) ~= 0 || length(cond5) ~= 0 || length(cond6) ~= 0)
    
    startRun = 36;
    endRun   = 62;
    
    figurename = sprintf('Resistance Test:: Trim Tab Investigation, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    %# Plot repeat data: Fr vs. Ctm ---------------------------------------
    subplot(2,2,1)
    
    if length(cond4) ~= 0
        xcond4 = cond4(:,11); ycond4 = cond4(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond4); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond4 = cell2mat(Raw_Data);
        
        x4 = xcond4; y4 = ycond4;
    else
        x4 = 0; y4 = 0;
    end
    if length(cond5) ~= 0
        xcond5 = cond5(:,11); ycond5 = cond5(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond5); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond5 = cell2mat(Raw_Data);
        
        x5 = xcond5; y5 = ycond5;
    else
        x5 = 0; y5 = 0;
    end
    if length(cond6) ~= 0
        xcond6 = cond6(:,11); ycond6 = cond6(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond6); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond6 = cell2mat(Raw_Data);
        
        x6 = xcond6; y6 = ycond6;
    else
        x6 = 0; y6 = 0;
    end
    
    % Plotting
    h = plot(x4,y4,'*',x5,y5,'*',x6,y6,'*');
    if enablePlotTitle == 1
        title('{\bf C_{Tm} vs. F_{r} (repeated runs)}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.42 0.48]);
    set(gca,'XTick',[0.42:0.01:0.48]);
    set(gca,'YLim',[6.2 6.6]);
    set(gca,'YTick',[6.2:0.05:6.6]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Cond. 4: 1,500t (5 degrees)','Cond. 5: 1,500t (0 degrees)','Cond. 6: 1,500t (10 degrees)');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Plot averaged data: Fr vs. Ctm -------------------------------------
    subplot(2,2,2)
    
    if length(avgcond4) ~= 0
        xavgcond4 = avgcond4(:,11); yavgcond4 = avgcond4(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond4); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond4 = cell2mat(Raw_Data);
        
        x4 = xavgcond4; y4 = yavgcond4;
    else
        x4 = 0; y4 = 0;
    end
    if length(avgcond5) ~= 0
        xavgcond5 = avgcond5(:,11); yavgcond5 = avgcond5(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond5); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond5 = cell2mat(Raw_Data);
        
        x5 = xavgcond5; y5 = yavgcond5;
    else
        x5 = 0; y5 = 0;
    end
    if length(avgcond6) ~= 0
        xavgcond6 = avgcond6(:,11); yavgcond6 = avgcond6(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond6); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond6 = cell2mat(Raw_Data);
        
        x6 = xavgcond6; y6 = yavgcond6;
    else
        x6 = 0; y6 = 0;
    end
    
    % Plotting
    h = plot(x4,y4,'*',x5,y5,'*',x6,y6,'*');
    if enablePlotTitle == 1
        title('{\bf C_{Tm} vs. F_{r} (averaged runs)}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.42 0.48]);
    set(gca,'XTick',[0.42:0.01:0.48]);
    set(gca,'YLim',[6.2 6.6]);
    set(gca,'YTick',[6.2:0.05:6.6]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Cond. 4: 1,500t (5 degrees)','Cond. 5: 1,500t (0 degrees)','Cond. 6: 1,500t (10 degrees)');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Plot Fr vs. Trim  -----------------------------------------------------
    subplot(2,2,3)
    
    if length(avgcond4) ~= 0
        xavgcond4 = avgcond4(:,11); yavgcond4 = avgcond4(:,13);
        x4 = xavgcond4; y4 = yavgcond4;
    else
        x4 = 0; y4 = 0;
    end
    if length(avgcond5) ~= 0
        xavgcond5 = avgcond5(:,11); yavgcond5 = avgcond5(:,13);
        x5 = xavgcond5; y5 = yavgcond5;
    else
        x5 = 0; y5 = 0;
    end
    if length(avgcond6) ~= 0
        xavgcond6 = avgcond6(:,11); yavgcond6 = avgcond6(:,13);
        x6 = xavgcond6; y6 = yavgcond6;
    else
        x6 = 0; y6 = 0;
    end
    
    % Plotting
    h = plot(x4,y4,'*',x5,y5,'*',x6,y6,'*');
    if enablePlotTitle == 1
        title('{\bf Trim vs. F_{r}}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Trim [deg]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.42 0.48]);
    set(gca,'XTick',[0.42:0.01:0.48]);
    set(gca,'YLim',[0.4 1.3]);
    set(gca,'YTick',[0.4:0.1:1.3]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 4: 1,500t (5 degrees)','Cond. 5: 1,500t (0 degrees)','Cond. 6: 1,500t (10 degrees)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Plot Trim vs. Crm  -----------------------------------------------------
    subplot(2,2,4)
    
    if length(avgcond4) ~= 0
        xavgcond4 = avgcond4(:,13); yavgcond4 = avgcond4(:,19);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond4); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond4 = cell2mat(Raw_Data);
        
        x4 = xavgcond4; y4 = yavgcond4;
    else
        x4 = 0; y4 = 0;
    end
    if length(avgcond5) ~= 0
        xavgcond5 = avgcond5(:,13); yavgcond5 = avgcond5(:,19);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond5); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond5 = cell2mat(Raw_Data);
        
        x5 = xavgcond5; y5 = yavgcond5;
    else
        x5 = 0; y5 = 0;
    end
    if length(avgcond6) ~= 0
        xavgcond6 = avgcond6(:,13); yavgcond6 = avgcond6(:,19);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond6); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond6 = cell2mat(Raw_Data);
        
        x6 = xavgcond6; y6 = yavgcond6;
    else
        x6 = 0; y6 = 0;
    end
    
    % Fr = 0.43 only
    fr043 = [];
    fr043(1,1) = x4(1);           % Condition 4, Fr = 0.43
    fr043(1,2) = y4(1);           % Condition 4, Fr = 0.43
    fr043(2,1) = x5(1);           % Condition 5, Fr = 0.43
    fr043(2,2) = y5(1);           % Condition 5, Fr = 0.43
    fr043(3,1) = x6(1);           % Condition 6, Fr = 0.43
    fr043(3,2) = y6(1);           % Condition 6, Fr = 0.43
    fr043l = [];
    fr043l(1,1) = avgcond7(20,13);      % Condition 7: 1,500t, level trim, Fr = 0.43
    fr043l(1,2) = avgcond7(20,19)*1000; % Condition 7: 1,500t, level trim, Fr = 0.43
    fr041b = [];
    fr041b(1,1) = avgcond8(4,13)-0.5;   % Condition 7: 1,500t, -0.5 by bow, Fr = 0.41
    fr041b(1,2) = avgcond8(4,19)*1000;  % Condition 7: 1,500t, -0.5 by bow, Fr = 0.41
    fr041s = [];
    fr041s(1,1) = avgcond9(5,13)+0.5;   % Condition 7: 1,500t, 0.5 by stern, Fr = 0.41
    fr041s(1,2) = avgcond9(5,19)*1000;  % Condition 7: 1,500t, 0.5 by stern, Fr = 0.41
    
    % Sort arrays by rows
    fr043 = sortrows(fr043);
    
    % Plotting
    h = plot(fr043(:,1),fr043(:,2),'*',fr043l(:,1),fr043l(:,2),'*',fr041b(:,1),fr041b(:,2),'*',fr041s(:,1),fr041s(:,2),'*');
    if enablePlotTitle == 1
        title('{\bf C_{Rm} vs. trim}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Trim [deg]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coefficient C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[-0.2 1.2]);
    set(gca,'XTick',[-0.2:0.2:1.2]);
    set(gca,'YLim',[3 3.8]);
    set(gca,'YTick',[3:0.1:3.8]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend('Fr=0.43');
    hleg1 = legend('Cond.4/5/6: Fr=0.43','Cond.7: Fr=0.43, level','Cond.8: Fr=0.41, -0.5 deg','Cond.9: Fr=0.42, 0.5 deg');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Trim_Tab_Resistance_Data_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% REPEATS: 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if enableResistancePlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Repeated Runs):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % Fr vs. Rtm (#9) or Ctm (#10) ---------------------------------------------------------
    %subplot(2,2,1:2) % Merged plot over two columns
    subplot(2,2,1)
    
    if length(cond7) ~= 0
        xcond7 = cond7(:,11); ycond7 = cond7(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond7 = cell2mat(Raw_Data);
        
        x7 = xcond7; y7 = ycond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        xcond8 = cond8(:,11); ycond8 = cond8(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
        
        x8 = xcond8; y8 = ycond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        xcond9 = cond9(:,11); ycond9 = cond9(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond9 = cell2mat(Raw_Data);
        
        x9 = xcond9; y9 = ycond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(cond10) ~= 0
        xcond10 = cond10(:,11); ycond10 = cond10(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond10 = cell2mat(Raw_Data);
        
        x10 = xcond10; y10 = ycond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        xcond11 = cond11(:,11); ycond11 = cond11(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
        
        x11 = xcond11; y11 = ycond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        xcond12 = cond12(:,11); ycond12 = cond12(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
        
        x12 = xcond12; y12 = ycond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Total ressitance coeff.}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[5 8]);
    set(gca,'YTick',[5:0.5:8]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Full scale speed vs. full scale effective power -------------------------
    subplot(2,2,2)
    
    if length(cond7) ~= 0
        x7 = cond7(:,15); y7 = cond7(:,26);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        x8 = cond8(:,15); y8 = cond8(:,26);
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        x9 = cond9(:,15); y9 = cond9(:,26);
    else
        x9 = 0; y9 = 0;
    end
    if length(cond10) ~= 0
        x10 = cond10(:,15); y10 = cond10(:,26);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        x11 = cond11(:,15); y11 = cond11(:,26);
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        x12 = cond12(:,15); y12 = cond12(:,26);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Effective power}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Full scale speed [knots]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Full scale effective power [W]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[10 30]);
    set(gca,'XTick',[10:5:30]);
    % set(gca,'YLim',[0 24]);
    % set(gca,'YTick',[0:4:24]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(2,2,3)
    
    if length(cond7) ~= 0
        x7 = cond7(:,11); y7 = cond7(:,12);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        x8 = cond8(:,11); y8 = cond8(:,12);
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        x9 = cond9(:,11); y9 = cond9(:,12);
    else
        x9 = 0; y9 = 0;
    end
    if length(cond10) ~= 0
        x10 = cond10(:,11); y10 = cond10(:,12);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        x11 = cond11(:,11); y11 = cond11(:,12);
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        x12 = cond12(:,11); y12 = cond12(:,12);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Heave}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[-15 5]);
    set(gca,'YTick',[-15:5:5]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model trim (degrees) ------------------------------------
    subplot(2,2,4)
    
    if length(cond7) ~= 0
        x7 = cond7(:,11); y7 = cond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        %x8 = cond8(:,11); y8 = cond8(:,13);
        xcond8 = cond8(:,11); ycond8 = cond8(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
        
        x8 = xcond8; y8 = ycond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        %x9 = cond9(:,11); y9 = cond9(:,13);
        xcond9 = cond9(:,11); ycond9 = cond9(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond9); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond9 = cell2mat(Raw_Data);
        
        x9 = xcond9; y9 = ycond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(cond10) ~= 0
        x10 = cond10(:,11); y10 = cond10(:,13);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        %x11 = cond11(:,11); y11 = cond11(:,13);
        xcond11 = cond11(:,11); ycond11 = cond11(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
        
        x11 = xcond11; y11 = ycond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        %x12 = cond12(:,11); y12 = cond12(:,13);
        xcond12 = cond12(:,11); ycond12 = cond12(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
        
        x12 = xcond12; y12 = ycond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Running trim}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Running trim [deg]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[-1 2]);
    set(gca,'YTick',[-1:0.5:2]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Summary_Resistance_Data_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% AVERAGED: 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if enableResistancePlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    %startRun = R(1:1);
    %endRun   = R(end, 1);
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Averaged Runs):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % Fr vs. Ctm ----------------------------------------------------------
    subplot(2,2,1)
    
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
        
        x7 = xavgcond7; y7 = yavgcond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
        
        x8 = xavgcond8; y8 = yavgcond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
        
        x9 = xavgcond9; y9 = yavgcond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
        
        x10 = xavgcond10; y10 = yavgcond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
        
        x11 = xavgcond11; y11 = yavgcond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
        
        x12 = xavgcond12; y12 = yavgcond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Total ressitance coeff.}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[5 8]);
    set(gca,'YTick',[5:0.5:8]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Full scale speed vs. full scale effective power ---------------------
    subplot(2,2,2)
    
    %x = R(:,15);
    %y = R(:,26);
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,15); y7 = avgcond7(:,26);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        x8 = avgcond8(:,15); y8 = avgcond8(:,26);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        x9 = avgcond9(:,15); y9 = avgcond9(:,26);
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        x10 = avgcond10(:,15); y10 = avgcond10(:,26);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        x11 = avgcond11(:,15); y11 = avgcond11(:,26);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        x12 = avgcond12(:,15); y12 = avgcond12(:,26);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Effective power}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Full scale speed [knots]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Full scale effective power [W]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[10 30]);
    set(gca,'XTick',[10:5:30]);
    % set(gca,'YLim',[0 24]);
    % set(gca,'YTick',[0:4:24]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ------------------------------------
    subplot(2,2,3)
    
    %x = R(:,11);
    %y = R(:,12);
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,12);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        x8 = avgcond8(:,11); y8 = avgcond8(:,12);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        x9 = avgcond9(:,11); y9 = avgcond9(:,12);
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        x10 = avgcond10(:,11); y10 = avgcond10(:,12);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        x11 = avgcond11(:,11); y11 = avgcond11(:,12);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        x12 = avgcond12(:,11); y12 = avgcond12(:,12);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Heave}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[-15 5]);
    set(gca,'YTick',[-15:5:5]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model trim (degrees) --------------------------------
    subplot(2,2,4)
    
    %x = R(:,11);
    %y = R(:,13);
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        %x8 = avgcond8(:,11); y8 = avgcond8(:,13);
        xcond8 = cond8(:,11); ycond8 = cond8(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
        
        x8 = xcond8; y8 = ycond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        %x9 = avgcond9(:,11); y9 = avgcond9(:,13);
        xcond9 = cond9(:,11); ycond9 = cond9(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond9); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond9 = cell2mat(Raw_Data);
        
        x9 = xcond9; y9 = ycond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        x10 = avgcond10(:,11); y10 = avgcond10(:,13);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        %x11 = avgcond11(:,11); y11 = avgcond11(:,13);
        xcond11 = cond11(:,11); ycond11 = cond11(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
        
        x11 = xcond11; y11 = ycond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        %x12 = avgcond12(:,11); y12 = avgcond12(:,13);
        xcond12 = cond12(:,11); ycond12 = cond12(:,13);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
        
        x12 = xcond12; y12 = ycond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Running trim}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Running trim [deg]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[-1 2]);
    set(gca,'YTick',[-1:0.5:2]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Averaged_Resistance_Data_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% REPEATS: 1,500 AND 1,804, Fr vs. Ctm and Fr vs. Crm
% *************************************************************************
if enableResistancePlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Averaged):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % Fr vs. Rtm ----------------------------------------------------------
    subplot(2,2,1)
    
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,9);
        %Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
        x7 = xavgcond7; y7 = yavgcond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,9);
        %Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
        x8 = xavgcond8; y8 = yavgcond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,9);
        %Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
        x9 = xavgcond9; y9 = yavgcond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,9);
        %Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
        x10 = xavgcond10; y10 = yavgcond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,9);
        %Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
        x11 = xavgcond11; y11 = yavgcond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,9);
        %Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
        x12 = xavgcond12; y12 = yavgcond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Total resistance R_{Tm}}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance R_{tm} [N]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    %set(gca,'YLim',[0 70]);
    %set(gca,'YTick',[0:10:70]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Fr vs. Ctm ----------------------------------------------------------
    subplot(2,2,2)
    
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,10);
        Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
        x7 = xavgcond7; y7 = yavgcond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,10);
        Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
        x8 = xavgcond8; y8 = yavgcond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,10);
        Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
        x9 = xavgcond9; y9 = yavgcond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,10);
        Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
        x10 = xavgcond10; y10 = yavgcond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,10);
        Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
        x11 = xavgcond11; y11 = yavgcond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,10);
        Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
        x12 = xavgcond12; y12 = yavgcond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Total resistance coeff. C_{Tm}}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance coefficient C_{Tm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[5 8.5]);
    set(gca,'YTick',[5:0.5:8.5]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Fr vs. Ctm ----------------------------------------------------------
    subplot(2,2,3:4)
    
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,19);
        Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
        x7 = xavgcond7; y7 = yavgcond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,19);
        Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
        x8 = xavgcond8; y8 = yavgcond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,19);
        Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
        x9 = xavgcond9; y9 = yavgcond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,19);
        Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
        x10 = xavgcond10; y10 = yavgcond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,19);
        Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
        x11 = xavgcond11; y11 = yavgcond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,19);
        Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
        x12 = xavgcond12; y12 = yavgcond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    if enablePlotTitle == 1
        title('{\bf Residual resistance coeff. C_{Rm}}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coefficient C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[1.5 5.5]);
    set(gca,'YTick',[1.5:0.5:5.5]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Resistance_Data_Fr_vs_Ctm_and_Crm_Averaged_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
% if length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
%     disp('Conditions 10 to 12 available');
% end

% *************************************************************************
% DEEP TRANSOM PROHASKA CONDITION
% *************************************************************************
if enableProhaskaPlot == 1 && length(cond13) ~= 0
    
    startRun = 232;
    endRun   = 249;
    
    % Array dimensions
    [m,n]    = size(cond13);
    
    %# --------------------------------------------------------------------
    %# Prohaska array columns ---------------------------------------------
    %# --------------------------------------------------------------------
    %  [1]  X-Axis; Fr^4/Cfm (Using ITTC 1957 for Cfm)
    %  [2]  Y-Axis; Ctm/Cfm  (Using ITTC 1957 for Cfm)
    %  [3]  X-Axis; Fr^4/Cfm (Using Grigson for Cfm)
    %  [4]  Y-Axis; Ctm/Cfm  (Using Grigson for Cfm)
    %# --------------------------------------------------------------------
    
    %# Fr^4/Cfm
    ittcprohaskadata = [];
    for q=1:m
        ittcprohaskadata(q,1) = (cond13(q,11)^4)/cond13(q,17);
        ittcprohaskadata(q,2) = cond13(q,10)/cond13(q,17);
        ittcprohaskadata(q,3) = (cond13(q,11)^4)/cond13(q,18);
        ittcprohaskadata(q,4) = cond13(q,10)/cond13(q,18);
    end
    
    figurename = sprintf('Resistance Test:: Prohaska Runs, Form Factor, Deep Transom, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    %# Plot repeat data: fr^4/Cfm vs. Ctm/Cfm -----------------------------
    subplot(1,2,1)
    
    %# ITTC 1957 Friction Line
    x1 = ittcprohaskadata(:,1);
    y1 = ittcprohaskadata(:,2);
    
    %# Grigson Friction Line
    x2 = ittcprohaskadata(:,3);
    y2 = ittcprohaskadata(:,4);
    
    %# START: Trendline for ITTC 1957 Friction Line -----------------------
    
    polyf1 = polyfit(x1,y1,1);
    polyv1 = polyval(polyf1,x1);
    % Slope of trendline => Y = (slope1 * X ) + slope2
    slopeITTC     = polyf1(1,1);    % Slope
    interceptITTC = polyf1(1,2);    % Intercept
    if interceptITTC > 0
        chooseSign = '+';
        interceptITTC = interceptITTC;
    else
        chooseSign = '-';
        interceptITTC = abs(interceptITTC);
    end
    slopeTextITTC = sprintf('ITTC 1957: y = %s*x %s %s', sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC));
    
    %# Use CC1(1,2)
    %# NOTE: A correlation coefficient with a magnitude near 1 (as in this case)
    %#       represents a good fit.  As the fit gets worse, the correlation
    %#       coefficient approaches zero.
    CC1    = corrcoef(x1,y1);
    
    %# END: Trendline for ITTC 1957 Friction Line -------------------------
    
    %# START: Trendline for Grigson Friction Line -------------------------
    
    polyf2 = polyfit(x2,y2,1);
    polyv2 = polyval(polyf2,x2);
    % Slope of trendline => Y = (slope1 * X ) + slope2
    slopeGrigson     = polyf2(1,1);    % Slope
    interceptGrigson = polyf2(1,2);    % Intercept
    if interceptGrigson > 0
        chooseSign = '+';
        interceptGrigson = interceptGrigson;
    else
        chooseSign = '-';
        interceptGrigson = abs(interceptGrigson);
    end
    slopeTextGrigson = sprintf('Grigson: y = %s*x %s %s', sprintf('%.3f',slopeGrigson), chooseSign, sprintf('%.3f',interceptGrigson));
    
    %# Use CC2(1,2)
    %# NOTE: A correlation coefficient with a magnitude near 1 (as in this case)
    %#       represents a good fit.  As the fit gets worse, the correlation
    %#       coefficient approaches zero.
    CC2    = corrcoef(x2,y2);
    
    %# END: Trendline for Grigson Friction Line ---------------------------
    
    % Plotting
    h = plot(x1,y1,'*b',x2,y2,'xg',x1,polyv1,'-b',x2,polyv2,'-g');
    xlabel('{\bf F_{r}^4/C_{Fm} [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf C_{Tm}/C_{Fm} [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Annotations
    text(0.23,1.05,slopeTextITTC,'FontSize',12,'color','k','FontWeight','normal');
    text(0.23,1.24,slopeTextGrigson,'FontSize',12,'color','k','FontWeight','normal');
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0 0.8]);
    set(gca,'XTick',[0:0.1:0.8]);
    set(gca,'YLim',[1 1.3]);
    set(gca,'YTick',[1:0.02:1.3]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Cond. 13: ITTC 1957','Cond. 13: Grigson','Cond. 13: ITTC 1957 (Fit)','Cond. 13: Grigson (Fit)');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Plot repeat data: Trim vs. Crm -----------------------------
    subplot(1,2,2)
    
    if length(avgcond13) ~= 0
        xavgcond13 = avgcond13(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        yavgcond131 = avgcond13(:,32); Raw_Data = num2cell(yavgcond131); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond131 = cell2mat(Raw_Data);
        yavgcond132 = avgcond13(:,36); Raw_Data = num2cell(yavgcond132); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond132 = cell2mat(Raw_Data);
        yavgcond133 = avgcond13(:,40); Raw_Data = num2cell(yavgcond133); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond133 = cell2mat(Raw_Data);
        yavgcond134 = avgcond13(:,44); Raw_Data = num2cell(yavgcond134); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond134 = cell2mat(Raw_Data);
        
        x13  = xavgcond13;
        y131 = yavgcond131;
        y132 = yavgcond132;
        y133 = yavgcond133;
        y134 = yavgcond134;
    else
        x13  = 0;
        y131 = 0;
        y132 = 0;
        y133 = 0;
        y134 = 0;
    end
    
    % Plotting
    h = plot(x13,y131,'*',x13,y132,'*',x13,y133,'*',x13,y134,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.24]);
    set(gca,'XTick',[0.1:0.02:0.24]);
    %set(gca,'YLim',[0 60]);
    %set(gca,'YTick',[0:5:60]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 13: Speed','Cond. 13: Fwd LVDT','Cond. 13: Aft LVDT','Cond. 13: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Prohaska_Form_Factor_Resistance_Data_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% ERRORS (REPEATS): 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if enableErrorPlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Errors, Repeated Runs):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % COND 7: Fr vs. Errors -----------------------------------------------
    subplot(2,3,1)
    
    if length(cond7) ~= 0
        xcond7 = cond7(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        ycond71 = cond7(:,32); Raw_Data = num2cell(ycond71); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond71 = cell2mat(Raw_Data);
        ycond72 = cond7(:,36); Raw_Data = num2cell(ycond72); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond72 = cell2mat(Raw_Data);
        ycond73 = cond7(:,40); Raw_Data = num2cell(ycond73); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond73 = cell2mat(Raw_Data);
        ycond74 = cond7(:,44); Raw_Data = num2cell(ycond74); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond74 = cell2mat(Raw_Data);
        
        x7  = xcond7;
        y71 = ycond71;
        y72 = ycond72;
        y73 = ycond73;
        y74 = ycond74;
    else
        x7  = 0;
        y71 = 0;
        y72 = 0;
        y73 = 0;
        y74 = 0;
    end
    
    % Plotting
    h = plot(x7,y71,'*',x7,y72,'*',x7,y73,'*',x7,y74,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 7: 1,500 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: Speed','Cond. 7: Fwd LVDT','Cond. 7: Aft LVDT','Cond. 7: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % COND 8: Fr vs. Errors -----------------------------------------------
    subplot(2,3,2)
    
    if length(cond8) ~= 0
        xcond8 = cond8(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        ycond81 = cond8(:,32); Raw_Data = num2cell(ycond81); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond81 = cell2mat(Raw_Data);
        ycond82 = cond8(:,36); Raw_Data = num2cell(ycond82); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond82 = cell2mat(Raw_Data);
        ycond83 = cond8(:,40); Raw_Data = num2cell(ycond83); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond83 = cell2mat(Raw_Data);
        ycond84 = cond8(:,44); Raw_Data = num2cell(ycond84); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond84 = cell2mat(Raw_Data);
        
        x8  = xcond8;
        y81 = ycond81;
        y82 = ycond82;
        y83 = ycond83;
        y84 = ycond84;
    else
        x8  = 0;
        y81 = 0;
        y82 = 0;
        y83 = 0;
        y84 = 0;
    end
    
    % Plotting
    h = plot(x8,y81,'*',x8,y82,'*',x8,y83,'*',x8,y84,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 8: 1,500 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 8: Speed','Cond. 8: Fwd LVDT','Cond. 8: Aft LVDT','Cond. 8: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % COND 9: Fr vs. Errors -----------------------------------------------
    subplot(2,3,3)
    
    if length(cond9) ~= 0
        xcond9 = cond9(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        ycond91 = cond9(:,32); Raw_Data = num2cell(ycond91); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond91 = cell2mat(Raw_Data);
        ycond92 = cond9(:,36); Raw_Data = num2cell(ycond92); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond92 = cell2mat(Raw_Data);
        ycond93 = cond9(:,40); Raw_Data = num2cell(ycond93); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond93 = cell2mat(Raw_Data);
        ycond94 = cond9(:,44); Raw_Data = num2cell(ycond94); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond94 = cell2mat(Raw_Data);
        
        x9  = xcond9;
        y91 = ycond91;
        y92 = ycond92;
        y93 = ycond93;
        y94 = ycond94;
    else
        x9  = 0;
        y91 = 0;
        y92 = 0;
        y93 = 0;
        y94 = 0;
    end
    
    % Plotting
    h = plot(x9,y91,'*',x9,y92,'*',x9,y93,'*',x9,y94,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 9: 1,500 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 9: Speed','Cond. 9: Fwd LVDT','Cond. 9: Aft LVDT','Cond. 9: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % COND 10: Fr vs. Errors -----------------------------------------------
    subplot(2,3,4)
    
    if length(cond10) ~= 0
        xcond10 = cond10(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        ycond101 = cond10(:,32); Raw_Data = num2cell(ycond101); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond101 = cell2mat(Raw_Data);
        ycond102 = cond10(:,36); Raw_Data = num2cell(ycond102); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond102 = cell2mat(Raw_Data);
        ycond103 = cond10(:,40); Raw_Data = num2cell(ycond103); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond103 = cell2mat(Raw_Data);
        ycond104 = cond10(:,44); Raw_Data = num2cell(ycond104); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); ycond104 = cell2mat(Raw_Data);
        
        x10  = xcond10;
        y101 = ycond101;
        y102 = ycond102;
        y103 = ycond103;
        y104 = ycond104;
    else
        x10  = 0;
        y101 = 0;
        y102 = 0;
        y103 = 0;
        y104 = 0;
    end
    
    % Plotting
    h = plot(x10,y101,'*',x10,y102,'*',x10,y103,'*',x10,y104,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 10: 1,804 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 10: Speed','Cond. 10: Fwd LVDT','Cond. 10: Aft LVDT','Cond. 10: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % COND 11: Fr vs. Errors -----------------------------------------------
    subplot(2,3,5)
    
    if length(cond11) ~= 0
        xcond11 = cond11(:,11);
        
        %# Multiply resistance data by 1100 for better readibility
        ycond111 = cond11(:,32); Raw_Data = num2cell(ycond111); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); ycond111 = cell2mat(Raw_Data);
        ycond112 = cond11(:,36); Raw_Data = num2cell(ycond112); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); ycond112 = cell2mat(Raw_Data);
        ycond113 = cond11(:,40); Raw_Data = num2cell(ycond113); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); ycond113 = cell2mat(Raw_Data);
        ycond114 = cond11(:,44); Raw_Data = num2cell(ycond114); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); ycond114 = cell2mat(Raw_Data);
        
        x11  = xcond11;
        y111 = ycond111;
        y112 = ycond112;
        y113 = ycond113;
        y114 = ycond114;
    else
        x11  = 0;
        y111 = 0;
        y112 = 0;
        y113 = 0;
        y114 = 0;
    end
    
    % Plotting
    h = plot(x11,y111,'*',x11,y112,'*',x11,y113,'*',x11,y114,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 11: 1,804 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 11: Speed','Cond. 11: Fwd LVDT','Cond. 11: Aft LVDT','Cond. 11: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % COND 12: Fr vs. Errors -----------------------------------------------
    subplot(2,3,6)
    
    if length(cond12) ~= 0
        xcond12 = cond12(:,11);
        
        %# Multiply resistance data by 100 for better readibility
        ycond121 = cond12(:,32); Raw_Data = num2cell(ycond121); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); ycond121 = cell2mat(Raw_Data);
        ycond122 = cond12(:,36); Raw_Data = num2cell(ycond122); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); ycond122 = cell2mat(Raw_Data);
        ycond123 = cond12(:,40); Raw_Data = num2cell(ycond123); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); ycond123 = cell2mat(Raw_Data);
        ycond124 = cond12(:,44); Raw_Data = num2cell(ycond124); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); ycond124 = cell2mat(Raw_Data);
        
        x12  = xcond12;
        y121 = ycond121;
        y122 = ycond122;
        y123 = ycond123;
        y124 = ycond124;
    else
        x12  = 0;
        y121 = 0;
        y122 = 0;
        y123 = 0;
        y124 = 0;
    end
    
    % Plotting
    h = plot(x12,y121,'*',x12,y122,'*',x12,y123,'*',x12,y124,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 12: 1,804 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 12: Speed','Cond. 12: Fwd LVDT','Cond. 12: Aft LVDT','Cond. 12: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Errors_Resistance_Data_Repeated_Runs_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

% *************************************************************************
% ERRORS (AVERAGED): 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if enableErrorPlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Errors, Averaged Runs):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % COND 7: Fr vs. Errors -----------------------------------------------
    subplot(2,3,1)
    
    if length(cond7) ~= 0
        xavgcond7 = avgcond7(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        yavgcond71 = avgcond7(:,32); Raw_Data = num2cell(yavgcond71); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond71 = cell2mat(Raw_Data);
        yavgcond72 = avgcond7(:,36); Raw_Data = num2cell(yavgcond72); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond72 = cell2mat(Raw_Data);
        yavgcond73 = avgcond7(:,40); Raw_Data = num2cell(yavgcond73); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond73 = cell2mat(Raw_Data);
        yavgcond74 = avgcond7(:,44); Raw_Data = num2cell(yavgcond74); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond74 = cell2mat(Raw_Data);
        
        x7  = xavgcond7;
        y71 = yavgcond71;
        y72 = yavgcond72;
        y73 = yavgcond73;
        y74 = yavgcond74;
    else
        x7  = 0;
        y71 = 0;
        y72 = 0;
        y73 = 0;
        y74 = 0;
    end
    
    % Plotting
    h = plot(x7,y71,'*',x7,y72,'*',x7,y73,'*',x7,y74,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 7: 1,500 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: Speed','Cond. 7: Fwd LVDT','Cond. 7: Aft LVDT','Cond. 7: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % COND 8: Fr vs. Errors -----------------------------------------------
    subplot(2,3,2)
    
    if length(cond8) ~= 0
        xavgcond8 = avgcond8(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        yavgcond81 = avgcond8(:,32); Raw_Data = num2cell(yavgcond81); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond81 = cell2mat(Raw_Data);
        yavgcond82 = avgcond8(:,36); Raw_Data = num2cell(yavgcond82); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond82 = cell2mat(Raw_Data);
        yavgcond83 = avgcond8(:,40); Raw_Data = num2cell(yavgcond83); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond83 = cell2mat(Raw_Data);
        yavgcond84 = avgcond8(:,44); Raw_Data = num2cell(yavgcond84); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond84 = cell2mat(Raw_Data);
        
        x8  = xavgcond8;
        y81 = yavgcond81;
        y82 = yavgcond82;
        y83 = yavgcond83;
        y84 = yavgcond84;
    else
        x8  = 0;
        y81 = 0;
        y82 = 0;
        y83 = 0;
        y84 = 0;
    end
    
    % Plotting
    h = plot(x8,y81,'*',x8,y82,'*',x8,y83,'*',x8,y84,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 8: 1,500 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 8: Speed','Cond. 8: Fwd LVDT','Cond. 8: Aft LVDT','Cond. 8: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % COND 9: Fr vs. Errors -----------------------------------------------
    subplot(2,3,3)
    
    if length(cond9) ~= 0
        xavgcond9 = avgcond9(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        yavgcond91 = avgcond9(:,32); Raw_Data = num2cell(yavgcond91); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond91 = cell2mat(Raw_Data);
        yavgcond92 = avgcond9(:,36); Raw_Data = num2cell(yavgcond92); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond92 = cell2mat(Raw_Data);
        yavgcond93 = avgcond9(:,40); Raw_Data = num2cell(yavgcond93); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond93 = cell2mat(Raw_Data);
        yavgcond94 = avgcond9(:,44); Raw_Data = num2cell(yavgcond94); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond94 = cell2mat(Raw_Data);
        
        x9  = xavgcond9;
        y91 = yavgcond91;
        y92 = yavgcond92;
        y93 = yavgcond93;
        y94 = yavgcond94;
    else
        x9  = 0;
        y91 = 0;
        y92 = 0;
        y93 = 0;
        y94 = 0;
    end
    
    % Plotting
    h = plot(x9,y91,'*',x9,y92,'*',x9,y93,'*',x9,y94,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 9: 1,500 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 9: Speed','Cond. 9: Fwd LVDT','Cond. 9: Aft LVDT','Cond. 9: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % COND 10: Fr vs. Errors -----------------------------------------------
    subplot(2,3,4)
    
    if length(cond10) ~= 0
        xavgcond10 = avgcond10(:,11);
        
        %# Multiply resistance data by 1000 for better readibility
        yavgcond101 = avgcond10(:,32); Raw_Data = num2cell(yavgcond101); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond101 = cell2mat(Raw_Data);
        yavgcond102 = avgcond10(:,36); Raw_Data = num2cell(yavgcond102); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond102 = cell2mat(Raw_Data);
        yavgcond103 = avgcond10(:,40); Raw_Data = num2cell(yavgcond103); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond103 = cell2mat(Raw_Data);
        yavgcond104 = avgcond10(:,44); Raw_Data = num2cell(yavgcond104); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); yavgcond104 = cell2mat(Raw_Data);
        
        x10  = xavgcond10;
        y101 = yavgcond101;
        y102 = yavgcond102;
        y103 = yavgcond103;
        y104 = yavgcond104;
    else
        x10  = 0;
        y101 = 0;
        y102 = 0;
        y103 = 0;
        y104 = 0;
    end
    
    % Plotting
    h = plot(x10,y101,'*',x10,y102,'*',x10,y103,'*',x10,y104,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 10: 1,804 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 10: Speed','Cond. 10: Fwd LVDT','Cond. 10: Aft LVDT','Cond. 10: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % COND 11: Fr vs. Errors -----------------------------------------------
    subplot(2,3,5)
    
    if length(cond11) ~= 0
        xavgcond11 = avgcond11(:,11);
        
        %# Multiply resistance data by 1100 for better readibility
        yavgcond111 = avgcond11(:,32); Raw_Data = num2cell(yavgcond111); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); yavgcond111 = cell2mat(Raw_Data);
        yavgcond112 = avgcond11(:,36); Raw_Data = num2cell(yavgcond112); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); yavgcond112 = cell2mat(Raw_Data);
        yavgcond113 = avgcond11(:,40); Raw_Data = num2cell(yavgcond113); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); yavgcond113 = cell2mat(Raw_Data);
        yavgcond114 = avgcond11(:,44); Raw_Data = num2cell(yavgcond114); Raw_Data = cellfun(@(y) y*110, Raw_Data, 'UniformOutput', false); yavgcond114 = cell2mat(Raw_Data);
        
        x11  = xavgcond11;
        y111 = yavgcond111;
        y112 = yavgcond112;
        y113 = yavgcond113;
        y114 = yavgcond114;
    else
        x11  = 0;
        y111 = 0;
        y112 = 0;
        y113 = 0;
        y114 = 0;
    end
    
    % Plotting
    h = plot(x11,y111,'*',x11,y112,'*',x11,y113,'*',x11,y114,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 11: 1,804 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 11: Speed','Cond. 11: Fwd LVDT','Cond. 11: Aft LVDT','Cond. 11: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % COND 12: Fr vs. Errors -----------------------------------------------
    subplot(2,3,6)
    
    if length(cond12) ~= 0
        xavgcond12 = avgcond12(:,11);
        
        %# Multiply resistance data by 100 for better readibility
        yavgcond121 = avgcond12(:,32); Raw_Data = num2cell(yavgcond121); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); yavgcond121 = cell2mat(Raw_Data);
        yavgcond122 = avgcond12(:,36); Raw_Data = num2cell(yavgcond122); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); yavgcond122 = cell2mat(Raw_Data);
        yavgcond123 = avgcond12(:,40); Raw_Data = num2cell(yavgcond123); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); yavgcond123 = cell2mat(Raw_Data);
        yavgcond124 = avgcond12(:,44); Raw_Data = num2cell(yavgcond124); Raw_Data = cellfun(@(y) y*120, Raw_Data, 'UniformOutput', false); yavgcond124 = cell2mat(Raw_Data);
        
        x12  = xavgcond12;
        y121 = yavgcond121;
        y122 = yavgcond122;
        y123 = yavgcond123;
        y124 = yavgcond124;
    else
        x12  = 0;
        y121 = 0;
        y122 = 0;
        y123 = 0;
        y124 = 0;
    end
    
    % Plotting
    h = plot(x12,y121,'*',x12,y122,'*',x12,y123,'*',x12,y124,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Error to average [%]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 12: 1,804 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 90]);
    set(gca,'YTick',[0:10:90]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 12: Speed','Cond. 12: Fwd LVDT','Cond. 12: Aft LVDT','Cond. 12: Drag');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;

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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Errors_Resistance_Data_Averaged_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;    
    
end

% *************************************************************************
% MEAN STANDARD DEVIATION: 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if enableMeanStdPlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Avg. Mean of StdDev):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % Fr vs. Mean of Standard Deviation -----------------------------------
    subplot(2,3,1)
    
    x7 = []; y7 = [];
    if length(avgcond7) ~= 0
        x7(:,1) = avgcond7(:,11);
        x7(:,2) = avgcond7(:,11);
        x7(:,3) = avgcond7(:,11);
        x7(:,4) = avgcond7(:,11);
        y7(:,1) = avgcond7(:,49);
        y7(:,2) = avgcond7(:,50);
        y7(:,3) = avgcond7(:,51);
        y7(:,4) = avgcond7(:,52);
    end
    
    % Plotting
    bar(x7,y7,0.5);
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Mean of standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 7: 1,500 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[0 20]);
    set(gca,'YTick',[0:2:20]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed','Fwd LVDT',' Aft LVDT','Drag');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Mean of Standard Deviation -----------------------------------
    subplot(2,3,2)
    
    x8 = []; y8 = [];
    if length(avgcond8) ~= 0
        x8(:,1) = avgcond8(:,11);
        x8(:,2) = avgcond8(:,11);
        x8(:,3) = avgcond8(:,11);
        x8(:,4) = avgcond8(:,11);
        y8(:,1) = avgcond8(:,49);
        y8(:,2) = avgcond8(:,50);
        y8(:,3) = avgcond8(:,51);
        y8(:,4) = avgcond8(:,52);
    end
    
    % Plotting
    bar(x8,y8,0.5);
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Mean of standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 8: 1,500 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 20]);
    set(gca,'YTick',[0:2:20]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed','Fwd LVDT',' Aft LVDT','Drag');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Mean of Standard Deviation -----------------------------------
    subplot(2,3,3)
    
    x9 = []; y9 = [];
    if length(avgcond9) ~= 0
        x9(:,1) = avgcond9(:,11);
        x9(:,2) = avgcond9(:,11);
        x9(:,3) = avgcond9(:,11);
        x9(:,4) = avgcond9(:,11);
        y9(:,1) = avgcond9(:,49);
        y9(:,2) = avgcond9(:,50);
        y9(:,3) = avgcond9(:,51);
        y9(:,4) = avgcond9(:,52);
    end
    
    % Plotting
    bar(x9,y9,0.5);
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Mean of standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 9: 1,500 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 20]);
    set(gca,'YTick',[0:2:20]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed','Fwd LVDT',' Aft LVDT','Drag');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Mean of Standard Deviation -----------------------------------
    subplot(2,3,4)
    
    x10 = []; y10 = [];
    if length(avgcond10) ~= 0
        x10(:,1) = avgcond10(:,11);
        x10(:,2) = avgcond10(:,11);
        x10(:,3) = avgcond10(:,11);
        x10(:,4) = avgcond10(:,11);
        y10(:,1) = avgcond10(:,49);
        y10(:,2) = avgcond10(:,50);
        y10(:,3) = avgcond10(:,51);
        y10(:,4) = avgcond10(:,52);
    end
    
    % Plotting
    bar(x10,y10,0.5);
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Mean of standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 10: 1,804 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 20]);
    set(gca,'YTick',[0:2:20]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed','Fwd LVDT',' Aft LVDT','Drag');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Mean of Standard Deviation -----------------------------------
    subplot(2,3,5)
    
    x11 = []; y11 = [];
    if length(avgcond11) ~= 0
        x11(:,1) = avgcond11(:,11);
        x11(:,2) = avgcond11(:,11);
        x11(:,3) = avgcond11(:,11);
        x11(:,4) = avgcond11(:,11);
        y11(:,1) = avgcond11(:,49);
        y11(:,2) = avgcond11(:,50);
        y11(:,3) = avgcond11(:,51);
        y11(:,4) = avgcond11(:,52);
    end
    
    % Plotting
    bar(x11,y11,0.5);
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Mean of standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 11: 1,804 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 20]);
    set(gca,'YTick',[0:2:20]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed','Fwd LVDT',' Aft LVDT','Drag');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Mean of Standard Deviation -----------------------------------
    subplot(2,3,6)
    
    x12 = []; y12 = [];
    if length(avgcond12) ~= 0
        x12(:,1) = avgcond12(:,11);
        x12(:,2) = avgcond12(:,11);
        x12(:,3) = avgcond12(:,11);
        x12(:,4) = avgcond12(:,11);
        y12(:,1) = avgcond12(:,49);
        y12(:,2) = avgcond12(:,50);
        y12(:,3) = avgcond12(:,51);
        y12(:,4) = avgcond12(:,52);
    end
    
    % Plotting
    bar(x12,y12,0.5);
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Mean of standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 12: 1,804 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 20]);
    set(gca,'YTick',[0:2:20]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed','Fwd LVDT',' Aft LVDT','Drag');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Fr_vs_Standard_Deviation_Mean_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;    
    
end

% *************************************************************************
% STANDARD DEVIATION: 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************
if enableStdPlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (Avg. StdDev):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setLegendFontSize  = 9;
    
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
    
    % Fr vs. Standard Deviation -------------------------------------------
    subplot(2,3,1)
    
    if length(avgcond7) ~= 0
        x7sp = avgcond7(:,11);
        x7fl = avgcond7(:,11);
        x7al = avgcond7(:,11);
        x7dr = avgcond7(:,11);
        
        y7sp = avgcond7(:,45);
        Raw_Data = num2cell(y7sp); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); y7sp = cell2mat(Raw_Data);
        y7fl = avgcond7(:,46);
        y7al = avgcond7(:,47);
        y7dr = avgcond7(:,48);
        Raw_Data = num2cell(y7dr); Raw_Data = cellfun(@(y) y/100, Raw_Data, 'UniformOutput', false); y7dr = cell2mat(Raw_Data);
    end
    
    % Plotting
    h = plot(x7sp,y7sp,'*',x7fl,y7fl,'*',x7al,y7al,'*',x7dr,y7dr,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 7: 1,500 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[0 0.45]);
    set(gca,'YTick',[0:0.05:0.45]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed*100 (m/s)','Fwd LVDT (mm)',' Aft LVDT (mm)','Drag/100 (g)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Standard Deviation -------------------------------------------
    subplot(2,3,2)
    
    if length(avgcond8) ~= 0
        x8sp = avgcond8(:,11);
        x8fl = avgcond8(:,11);
        x8al = avgcond8(:,11);
        x8dr = avgcond8(:,11);
        
        y8sp = avgcond8(:,45);
        Raw_Data = num2cell(y8sp); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); y8sp = cell2mat(Raw_Data);
        y8fl = avgcond8(:,46);
        y8al = avgcond8(:,47);
        y8dr = avgcond8(:,48);
        Raw_Data = num2cell(y8dr); Raw_Data = cellfun(@(y) y/100, Raw_Data, 'UniformOutput', false); y8dr = cell2mat(Raw_Data);
    end
    
    % Plotting
    h = plot(x8sp,y8sp,'*',x8fl,y8fl,'*',x8al,y8al,'*',x8dr,y8dr,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 8: 1,500 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 0.45]);
    set(gca,'YTick',[0:0.05:0.45]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed*100 (m/s)','Fwd LVDT (mm)',' Aft LVDT (mm)','Drag/100 (g)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Standard Deviation -------------------------------------------
    subplot(2,3,3)
    
    if length(avgcond9) ~= 0
        x9sp = avgcond9(:,11);
        x9fl = avgcond9(:,11);
        x9al = avgcond9(:,11);
        x9dr = avgcond9(:,11);
        
        y9sp = avgcond9(:,45);
        Raw_Data = num2cell(y9sp); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); y9sp = cell2mat(Raw_Data);
        y9fl = avgcond9(:,46);
        y9al = avgcond9(:,47);
        y9dr = avgcond9(:,48);
        Raw_Data = num2cell(y9dr); Raw_Data = cellfun(@(y) y/100, Raw_Data, 'UniformOutput', false); y9dr = cell2mat(Raw_Data);
    end
    
    % Plotting
    h = plot(x9sp,y9sp,'*',x9fl,y9fl,'*',x9al,y9al,'*',x9dr,y9dr,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 9: 1,500 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 0.45]);
    set(gca,'YTick',[0:0.05:0.45]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed*100 (m/s)','Fwd LVDT (mm)',' Aft LVDT (mm)','Drag/100 (g)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Standard Deviation -------------------------------------------
    subplot(2,3,4)
    
    if length(avgcond10) ~= 0
        x10sp = avgcond10(:,11);
        x10fl = avgcond10(:,11);
        x10al = avgcond10(:,11);
        x10dr = avgcond10(:,11);
        
        y10sp = avgcond10(:,45);
        Raw_Data = num2cell(y10sp); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); y10sp = cell2mat(Raw_Data);
        y10fl = avgcond10(:,46);
        y10al = avgcond10(:,47);
        y10dr = avgcond10(:,48);
        Raw_Data = num2cell(y10dr); Raw_Data = cellfun(@(y) y/100, Raw_Data, 'UniformOutput', false); y10dr = cell2mat(Raw_Data);
    end
    
    % Plotting
    h = plot(x10sp,y10sp,'*',x10fl,y10fl,'*',x10al,y10al,'*',x10dr,y10dr,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 10: 1,804 tonnes, level}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 0.45]);
    set(gca,'YTick',[0:0.05:0.45]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed*100 (m/s)','Fwd LVDT (mm)',' Aft LVDT (mm)','Drag/100 (g)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Standard Deviation -------------------------------------------
    subplot(2,3,5)
    
    if length(avgcond11) ~= 0
        x11sp = avgcond11(:,11);
        x11fl = avgcond11(:,11);
        x11al = avgcond11(:,11);
        x11dr = avgcond11(:,11);
        
        y11sp = avgcond11(:,45);
        Raw_Data = num2cell(y11sp); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); y11sp = cell2mat(Raw_Data);
        y11fl = avgcond11(:,46);
        y11al = avgcond11(:,47);
        y11dr = avgcond11(:,48);
        Raw_Data = num2cell(y11dr); Raw_Data = cellfun(@(y) y/100, Raw_Data, 'UniformOutput', false); y11dr = cell2mat(Raw_Data);
    end
    
    % Plotting
    h = plot(x11sp,y11sp,'*',x11fl,y11fl,'*',x11al,y11al,'*',x11dr,y11dr,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 11: 1,804 tonnes, -0.5 by bow}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 0.45]);
    set(gca,'YTick',[0:0.05:0.45]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed*100 (m/s)','Fwd LVDT (mm)',' Aft LVDT (mm)','Drag/100 (g)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
	%# Font sizes and border --------------------------------------------------

	set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    % Fr vs. Standard Deviation -------------------------------------------
    subplot(2,3,6)
    
    if length(avgcond12) ~= 0
        x12sp = avgcond12(:,11);
        x12fl = avgcond12(:,11);
        x12al = avgcond12(:,11);
        x12dr = avgcond12(:,11);
        
        y12sp = avgcond12(:,45);
        Raw_Data = num2cell(y12sp); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false); y12sp = cell2mat(Raw_Data);
        y12fl = avgcond12(:,46);
        y12al = avgcond12(:,47);
        y12dr = avgcond12(:,48);
        Raw_Data = num2cell(y12dr); Raw_Data = cellfun(@(y) y/100, Raw_Data, 'UniformOutput', false); y12dr = cell2mat(Raw_Data);
    end
    
    % Plotting
    h = plot(x12sp,y12sp,'*',x12fl,y12fl,'*',x12al,y12al,'*',x12dr,y12dr,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Standard deviation [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Condition 12: 1,804 tonnes, 0.5 by stern}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.1:0.5]);
    set(gca,'YLim',[0 0.45]);
    set(gca,'YTick',[0:0.05:0.45]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
    
    %# Legend
    hleg1 = legend('Speed*100 (m/s)','Fwd LVDT (mm)',' Aft LVDT (mm)','Drag/100 (g)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Fr_vs_Standard_Deviation_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;    
    
end

% *************************************************************************
% REYNOLDS NUMBER VS FRICTIONAL RESISTANCE COEFFICIENT
% *************************************************************************
if enableRemVSCFmPlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)
    
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Resistance Test (C_{Fm} vs. R_{em}):: 1,500 and 1,804 tonnes, Run %s to %s', num2str(startRun), num2str(endRun));
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
    setMarker = {'*';'+';'x';'v';'o';'^';'s';'<';'d';'>';'p';'h'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end    
    
    % Rem vs. Cfm (ITTC'57) -----------------------------------------------
    %subplot(1,2,1)
    
    % Plotting: ITTC 1957
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,16); yavgcond7 = avgcond7(:,17);
        Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
        x7 = xavgcond7; y7 = yavgcond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,16); yavgcond8 = avgcond8(:,17);
        Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
        x8 = xavgcond8; y8 = yavgcond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,16); yavgcond9 = avgcond9(:,17);
        Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
        x9 = xavgcond9; y9 = yavgcond9;
    else
        x9 = 0; y9 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,16); yavgcond10 = avgcond10(:,17);
        Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
        x10 = xavgcond10; y10 = yavgcond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,16); yavgcond11 = avgcond11(:,17);
        Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
        x11 = xavgcond11; y11 = yavgcond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,16); yavgcond12 = avgcond12(:,17);
        Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
        x12 = xavgcond12; y12 = yavgcond12;
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting: Grigson
    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,16); yavgcond7 = avgcond7(:,18);
        Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
        x13 = xavgcond7; y13 = yavgcond7;
    else
        x13 = 0; y13 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,16); yavgcond8 = avgcond8(:,18);
        Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
        x14 = xavgcond8; y14 = yavgcond8;
    else
        x14 = 0; y14 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,16); yavgcond9 = avgcond9(:,18);
        Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
        x15 = xavgcond9; y15 = yavgcond9;
    else
        x15 = 0; y15 = 0;
    end
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,16); yavgcond10 = avgcond10(:,18);
        Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
        x16 = xavgcond10; y16 = yavgcond10;
    else
        x16 = 0; y16 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,16); yavgcond11 = avgcond11(:,18);
        Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
        x17 = xavgcond11; y17 = yavgcond11;
    else
        x17 = 0; y17 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,16); yavgcond12 = avgcond12(:,18);
        Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
        x18 = xavgcond12; y18 = yavgcond12;
    else
        x18 = 0; y18 = 0;
    end    
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*',x13,y13,'*',x14,y14,'*',x15,y15,'*',x16,y16,'*',x17,y17,'*',x18,y18,'*');
    xlabel('{\bf Reynolds Number, R_{em} [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Frictional resistance coefficient, C_{Fm}*10^{3} [-]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    setCurveNo=7;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=8;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=9;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=10;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=11;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=12;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[[2E6 13E6]]);
    set(gca,'XTick',[2E6:1E6:13E6]);
    set(gca,'YLim',[2.5 4]);
    set(gca,'YTick',[2.5:0.3:4]);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7 (ITTC''57): 1,500t (0 deg)','Cond. 8 (ITTC''57): 1,500t (-0.5 deg)','Cond. 9 (ITTC''57): 1,500t (0.5 deg)','Cond. 10 (ITTC''57): 1,804t (0 deg)','Cond. 11 (ITTC''57): 1,804t (-0.5 deg)','Cond. 12 (ITTC''57): 1,804t (0.5 deg)','Cond. 7 (Grigson): 1,500t (0 deg)','Cond. 8 (Grigson): 1,500t (-0.5 deg)','Cond. 9 (Grigson): 1,500t (0.5 deg)','Cond. 10 (Grigson): 1,804t (0 deg)','Cond. 11 (Grigson): 1,804t (-0.5 deg)','Cond. 12 (Grigson): 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
    %if enablePlotMainTitle == 1
    %    annotation('textbox', [0 0.9 1 0.1], ...
    %        'String', strcat('{\bf ', figurename, '}'), ...
    %        'EdgeColor', 'none', ...
    %        'HorizontalAlignment', 'center');
    %end
    
    %# Save plots as PDF, PNG and EPS -------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_Run_%s_Rem_vs_Cfm_Resistance_Data_Plot.%s', '_averaged', setFileFormat{k}, num2str(startRun), num2str(endRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;    
    
end
