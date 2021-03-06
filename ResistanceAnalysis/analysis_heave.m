%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Heave Averaging Investigation
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
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
%# CHANGES    :  16/09/2013 - Created new script
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

%# _heave directory -------------------------------------------------------
setDirName = '_plots/_heave';

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

%# *********************************************************************
%# Testname
%# *********************************************************************
testName = 'Heave Investigation';

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


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableHeaveMinMaxAvgPlot = 1;   % Heave, min, max and averaged values

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


% *************************************************************************
% 1,500 AND 1,804 TONNES: Heave, min, max and averages
% *************************************************************************
if enableHeaveMinMaxAvgPlot == 1 && (length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0)

    % *********************************************************************
    % 1. Averaged values using data from all repeat runs
    % *********************************************************************
    figurename = 'Plot 1: (Repeated Runs):: 1,500 and 1,804 tonnes';
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
    setMarker = {'*';'+';'x';'v';'o';'^';'s';'<';'d';'>';'p';'h'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)
    
    if length(cond7) ~= 0
        x7 = cond7(:,11); y7 = cond7(:,12);
        x7avg = avgcond7(:,11); y7avg = avgcond7(:,12);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        x8 = cond8(:,11); y8 = cond8(:,12);
        x8avg = avgcond8(:,11); y8avg = avgcond8(:,12);
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        x9 = cond9(:,11); y9 = cond9(:,12);
        x9avg = avgcond9(:,11); y9avg = avgcond9(:,12);
    else
        x9 = 0; y9 = 0;
    end
    if length(cond10) ~= 0
        x10 = cond10(:,11); y10 = cond10(:,12);
        x10avg = avgcond10(:,11); y10avg = avgcond10(:,12);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        x11 = cond11(:,11); y11 = cond11(:,12);
        x11avg = avgcond11(:,11); y11avg = avgcond11(:,12);
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        x12 = cond12(:,11); y12 = cond12(:,12);
        x12avg = avgcond12(:,11); y12avg = avgcond12(:,12);
    else
        x12 = 0; y12 = 0;
    end
    
    % Plotting
    h = plot(x7,y7,'*',x7avg,y7avg,'*',x8,y8,'*',x8avg,y8avg,'*',x9,y9,'*',x9avg,y9avg,'*',x10,y10,'*',x10avg,y10avg,'*',x11,y11,'*',x11avg,y11avg,'*',x12,y12,'*',x12avg,y12avg,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Repeated runs}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = ':';
    % Markers
    setCurveNo=1;set(h(1),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(3),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(5),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(7),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(9),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(11),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    % Lines
    setCurveNo=7;set(h(2),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=8;set(h(4),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=9;set(h(6),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=10;set(h(8),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=11;set(h(10),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=12;set(h(12),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-14 2]);
    set(gca,'YTick',[-14:2:2]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend([h(1) h(3) h(5) h(7) h(9) h(11)],'Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ------------------------------------
    subplot(1,2,2)
    
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
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged runs only}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    % Markers
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-14 2]);
    set(gca,'YTick',[-14:2:2]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
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
        plotsavename = sprintf('_plots/%s/%s/Plot_1_Heave_Data_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    % *********************************************************************
    % 2. Min, Max and Averaged min/max
    % *********************************************************************
    figurename = 'Plot 2: (Min, Max Only):: 1,500 and 1,804 tonnes';
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
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(3,2,1)
    
    x7        = minmaxcond7(:,2);
    y7min     = minmaxcond7(:,3);
    y7max     = minmaxcond7(:,4);
    y7avg     = minmaxcond7(:,5);
    x7avgall  = avgcond7(:,11);
    y7avgall  = avgcond7(:,12);
    
    x10       = minmaxcond10(:,2);
    y10min    = minmaxcond10(:,3);
    y10max    = minmaxcond10(:,4);
    y10avg    = minmaxcond10(:,5);
    x10avgall = avgcond10(:,11);
    y10avgall = avgcond10(:,12);
    
    % Plotting
    h = plot(x7,y7avg,'*',x7avgall,y7avgall,'*',x10,y10avg,'*',x10avgall,y10avgall,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged min/max compared to average of all repeats (level)}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);  
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-12 2]);
    set(gca,'YTick',[-12:2:2]);
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg) min/max','Cond. 7: 1,500t (0 deg) All repeats','Cond. 10: 1,804t (0 deg) min/max','Cond. 10: 1,804t (0 deg) All repeats');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);    
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(3,2,2)
    
    x7     = minmaxcond7(:,2);
    y7min  = minmaxcond7(:,3);
    y7max  = minmaxcond7(:,4);
    y7avg  = minmaxcond7(:,5);
    
    x10    = minmaxcond10(:,2);
    y10min = minmaxcond10(:,3);
    y10max = minmaxcond10(:,4);
    y10avg = minmaxcond10(:,5);
    
    h = plot(x7,y7min,'*',x10,y10min,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Lowest values only (level)}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-12 2]);
    set(gca,'YTick',[-12:2:2]);
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg) Min','Cond. 10: 1,804t (0 deg) Min');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(3,2,3)
    
    x8        = minmaxcond8(:,2);
    y8min     = minmaxcond8(:,3);
    y8max     = minmaxcond8(:,4);
    y8avg     = minmaxcond8(:,5);
    x8avgall  = avgcond8(:,11);
    y8avgall  = avgcond8(:,12);
    
    x11       = minmaxcond11(:,2);
    y11min    = minmaxcond11(:,3);
    y11max    = minmaxcond11(:,4);
    y11avg    = minmaxcond11(:,5);
    x11avgall = avgcond11(:,11);
    y11avgall = avgcond11(:,12);
    
    % Plotting
    h = plot(x8,y8avg,'*',x8avgall,y8avgall,'*',x11,y11avg,'*',x11avgall,y11avgall,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged min/max compared to average of all repeats (-0.5 deg)}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) min/max','Cond. 8: 1,500t (-0.5 deg) All repeats','Cond. 11: 1,804t (-0.5 deg) min/max','Cond. 11: 1,804t (-0.5 deg) All repeats');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(3,2,4)
    
    x8        = minmaxcond8(:,2);
    y8min     = minmaxcond8(:,3);
    y8max     = minmaxcond8(:,4);
    y8avg     = minmaxcond8(:,5);
    
    x11       = minmaxcond11(:,2);
    y11min    = minmaxcond11(:,3);
    y11max    = minmaxcond11(:,4);
    y11avg    = minmaxcond11(:,5);
    
    % Plotting
    h = plot(x8,y8min,'*',x11,y11min,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Lowest values only (-0.5 deg)}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) Min','Cond. 11: 1,804t (-0.5 deg) Min');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(3,2,5)
    
    x9        = minmaxcond9(:,2);
    y9min     = minmaxcond9(:,3);
    y9max     = minmaxcond9(:,4);
    y9avg     = minmaxcond9(:,5);
    x9avgall  = avgcond9(:,11);
    y9avgall  = avgcond9(:,12);
    
    x12        = minmaxcond12(:,2);
    y12min     = minmaxcond12(:,3);
    y12max     = minmaxcond12(:,4);
    y12avg     = minmaxcond12(:,5);
    x12avgall  = avgcond12(:,11);
    y12avgall  = avgcond12(:,12);
    
    % Plotting
    h = plot(x9,y9avg,'*',x9avgall,y9avgall,'*',x12,y12avg,'*',x12avgall,y12avgall,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged min/max compared to average of all repeats (0.5 deg)}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-10 0]);
    set(gca,'YTick',[-10:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) min/max','Cond. 9: 1,500t (0.5 deg) All repeats','Cond. 12: 1,804t (0.5 deg) min/max','Cond. 12: 1,804t (0.5 deg) All repeats');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(3,2,6)
    
    x9        = minmaxcond9(:,2);
    y9min     = minmaxcond9(:,3);
    y9max     = minmaxcond9(:,4);
    y9avg     = minmaxcond9(:,5);
    
    x12        = minmaxcond12(:,2);
    y12min     = minmaxcond12(:,3);
    y12max     = minmaxcond12(:,4);
    y12avg     = minmaxcond12(:,5);
    
    % Plotting
    h = plot(x9,y9min,'*',x12,y12min,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Lowest values only (0.5 deg)}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-10 0]);
    set(gca,'YTick',[-10:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) Min','Cond. 12: 1,804t (0.5 deg) Min');
    set(hleg1,'Location','SouthWest');
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
        plotsavename = sprintf('_plots/%s/%s/Plot_2_Heave_Data_Plots_Min_Max_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    % *********************************************************************
    % 3. Fitting lines (level static trim)
    % *********************************************************************
    figurename = 'Plot 3: (Curve Fitting, Level Static Trim):: 1,500 and 1,804 tonnes';
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
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)
    
    % Degrees for curve fitting
    poldegr = 7;
    
    x7        = minmaxcond7(:,2);
    y7min     = minmaxcond7(:,3);
    y7max     = minmaxcond7(:,4);
    y7avg     = minmaxcond7(:,5);
    
    polyf7     = polyfit(x7,y7avg,poldegr); polyv7 = polyval(polyf7,x7);
    
    x7avgall  = avgcond7(:,11);
    y7avgall  = avgcond7(:,12);
    
    x10       = minmaxcond10(:,2);
    y10min    = minmaxcond10(:,3);
    y10max    = minmaxcond10(:,4);
    y10avg    = minmaxcond10(:,5);
    
    polyf10   = polyfit(x10,y10avg,poldegr); polyv10 = polyval(polyf10,x10);
    
    x10avgall = avgcond10(:,11);
    y10avgall = avgcond10(:,12);
    
    % Plotting
    h = plot(x7,y7avg,'*',x7avgall,y7avgall,'*',x7,polyv7,'-',x10,y10avg,'*',x10avgall,y10avgall,'*',x10,polyv10,'-');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged min/max, curve fitting}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    % Annotations
    text(0.41,-8.5,sprintf('%.1f',min(polyv7)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.41,-11,sprintf('%.1f',min(polyv10)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-12 2]);
    set(gca,'YTick',[-12:2:2]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg) min/max','Cond. 7: 1,500t (0 deg) All repeats','Cond. 7: 1,500t Curve fitting','Cond. 10: 1,804t (0 deg) min/max','Cond. 10: 1,804t (0 deg) All repeats','Cond. 10: 1,804t Curve fitting');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,2)
    
    x7        = minmaxcond7(:,2);
    y7min     = minmaxcond7(:,3);
    y7max     = minmaxcond7(:,4);
    y7avg     = minmaxcond7(:,5);
    
    polyf7     = polyfit(x7,y7min,poldegr); polyv7 = polyval(polyf7,x7);
    
    x10       = minmaxcond10(:,2);
    y10min    = minmaxcond10(:,3);
    y10max    = minmaxcond10(:,4);
    y10avg    = minmaxcond10(:,5);
    
    polyf10   = polyfit(x10,y10min,poldegr); polyv10 = polyval(polyf10,x10);
    
    % Plotting
    h = plot(x7,y7min,'*',x7,polyv7,'-',x10,y10min,'*',x10,polyv10,'-');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Lowest values only}','FontSize',setGeneralFontSize);
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
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);    
    
    % Annotations
    text(0.41,-9,sprintf('%.1f',min(polyv7)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.41,-11,sprintf('%.1f',min(polyv10)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-12 2]);
    set(gca,'YTick',[-12:2:2]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg) Min','Cond. 7: 1,500t Curve fitting','Cond. 10: 1,804t (0 deg) Min','Cond. 10: 1,804t Curve fitting');
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
        plotsavename = sprintf('_plots/%s/%s/Plot_3_Heave_Data_Plots_Fitting_Curves_Level_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    % *********************************************************************
    % 4. Fitting lines (-0.5 degrees by bow)
    % *********************************************************************
    figurename = 'Plot 4: (Curve Fitting, -0.5 by Bow):: 1,500 and 1,804 tonnes';
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
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)
    
    % Degrees for curve fitting
    poldegr = 4;
    
    x8        = minmaxcond8(:,2);
    y8min     = minmaxcond8(:,3);
    y8max     = minmaxcond8(:,4);
    y8avg     = minmaxcond8(:,5);
    
    polyf8     = polyfit(x8,y8avg,poldegr); polyv8 = polyval(polyf8,x8);
    
    x8avgall  = avgcond8(:,11);
    y8avgall  = avgcond8(:,12);
    
    x11       = minmaxcond11(:,2);
    y11min    = minmaxcond11(:,3);
    y11max    = minmaxcond11(:,4);
    y11avg    = minmaxcond11(:,5);
    
    polyf11   = polyfit(x11,y11avg,poldegr); polyv11 = polyval(polyf11,x11);
    
    x11avgall = avgcond11(:,11);
    y11avgall = avgcond11(:,12);
    
    % Plotting
    h = plot(x8,y8avg,'*',x8avgall,y8avgall,'*',x8,polyv8,'-',x11,y11avg,'*',x11avgall,y11avgall,'*',x11,polyv11,'-');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged min/max, curve fitting}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);    
    
    % Annotations
    text(0.4,-10,sprintf('%.1f',min(polyv8)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.4,-13,sprintf('%.1f',min(polyv11)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) min/max','Cond. 8: 1,500t (-0.5 deg) All repeats','Cond. 8: 1,500t Curve fitting','Cond. 11: 1,804t (-0.5 deg) min/max','Cond. 11: 1,804t (-0.5 deg) All repeats','Cond. 11: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,2)
    
    x8        = minmaxcond8(:,2);
    y8min     = minmaxcond8(:,3);
    y8max     = minmaxcond8(:,4);
    y8avg     = minmaxcond8(:,5);
    
    polyf8     = polyfit(x8,y8min,poldegr); polyv8 = polyval(polyf8,x8);
    
    x11       = minmaxcond11(:,2);
    y11min    = minmaxcond11(:,3);
    y11max    = minmaxcond11(:,4);
    y11avg    = minmaxcond11(:,5);
    
    polyf11   = polyfit(x11,y11min,poldegr); polyv11 = polyval(polyf11,x11);
    
    % Plotting
    h = plot(x8,y8min,'*',x8,polyv8,'-',x11,y11min,'*',x11,polyv11,'-');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Lowest values only}','FontSize',setGeneralFontSize);
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
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);     
    
    % Annotations
    text(0.4,-10.5,sprintf('%.1f',min(polyv8)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.4,-13,sprintf('%.1f',min(polyv11)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) Min','Cond. 8: 1,500t Curve fitting','Cond. 11: 1,804t (-0.5 deg) Min','Cond. 11: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
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
        plotsavename = sprintf('_plots/%s/%s/Plot_4_Heave_Data_Plots_Fitting_Curves_05_By_Bow_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    % *********************************************************************
    % 5. Fitting lines (0.5 degrees by stern)
    % *********************************************************************
    figurename = 'Plot 5: (Curve Fitting, 0.5 by Stern):: 1,500 and 1,804 tonnes';
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
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)
    
    % Degrees for curve fitting
    poldegr = 4;
    
    x9        = minmaxcond9(:,2);
    y9min     = minmaxcond9(:,3);
    y9max     = minmaxcond9(:,4);
    y9avg     = minmaxcond9(:,5);
    
    polyf9     = polyfit(x9,y9avg,poldegr); polyv9 = polyval(polyf9,x9);
    
    x9avgall  = avgcond9(:,11);
    y9avgall  = avgcond9(:,12);
    
    x12       = minmaxcond12(:,2);
    y12min    = minmaxcond12(:,3);
    y12max    = minmaxcond12(:,4);
    y12avg    = minmaxcond12(:,5);
    
    polyf12   = polyfit(x12,y12avg,poldegr); polyv12 = polyval(polyf12,x12);
    
    x12avgall = avgcond12(:,11);
    y12avgall = avgcond12(:,12);
    
    % Plotting
    h = plot(x9,y9avg,'*',x9avgall,y9avgall,'*',x9,polyv9,'-',x12,y12avg,'*',x12avgall,y12avgall,'*',x12,polyv12,'-');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Averaged min/max, Curve fitting}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-.';
    setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);     
    
    % Annotations
    text(0.41,-7,sprintf('%.1f',min(polyv9)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.41,-8.5,sprintf('%.1f',min(polyv12)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) min/max','Cond. 9: 1,500t (0.5 deg) All repeats','Cond. 9: 1,500t Curve fitting','Cond. 12: 1,804t (0.5 deg) min/max','Cond. 12: 1,804t (0.5 deg) All repeats','Cond. 12: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,2)
    
    x9        = minmaxcond9(:,2);
    y9min     = minmaxcond9(:,3);
    y9max     = minmaxcond9(:,4);
    y9avg     = minmaxcond9(:,5);
    
    polyf9     = polyfit(x9,y9min,poldegr); polyv9 = polyval(polyf9,x9);
    
    x9avgall  = avgcond9(:,11);
    y9avgall  = avgcond9(:,12);
    
    x12       = minmaxcond12(:,2);
    y12min    = minmaxcond12(:,3);
    y12max    = minmaxcond12(:,4);
    y12avg    = minmaxcond12(:,5);
    
    polyf12   = polyfit(x12,y12min,poldegr); polyv12 = polyval(polyf12,x12);
    
    % Plotting
    h = plot(x9,y9min,'*',x9,polyv9,'-',x12,y12min,'*',x12,polyv12,'-');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Lowest values only}','FontSize',setGeneralFontSize);
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
    setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'LineStyle',setLineStyle,'linewidth',setLineWidth);    
    
    % Annotations
    text(0.41,-7,sprintf('%.1f',min(polyv9)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.41,-9,sprintf('%.1f',min(polyv12)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) Min','Cond. 9: 1,500t Curve fitting','Cond. 12: 1,804t (0.5 deg) Min','Cond. 12: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
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
        plotsavename = sprintf('_plots/%s/%s/Plot_5_Heave_Data_Plots_Fitting_Curves_05_By_Stern_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    % *********************************************************************
    % 6. Heave vs. Crm for conditions 7 - 12
    % *********************************************************************
    figurename = 'Plot 6: (Averaged Min, Max):: 1,500 and 1,804 tonnes';
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
    
    % Heave vs. Crm ----------------------------------------
    subplot(2,3,1)
    
    x7  = minmaxcond7(20,5);
    y7  = minmaxcond7(20,6);
    
    x8  = minmaxcond8(4,5);
    y8  = minmaxcond8(4,6);
    
    x9  = minmaxcond9(5,5);
    y9  = minmaxcond9(5,6);
    
    x10 = minmaxcond10(8,5);
    y10 = minmaxcond10(8,6);
    
    x11 = minmaxcond11(4,5);
    y11 = minmaxcond11(4,6);
    
    x12 = minmaxcond12(5,5);
    y12 = minmaxcond12(5,6);
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coeff. C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Heave vs. C_{Rm} at F_{r}=0.42 for cond. 7-12}','FontSize',setGeneralFontSize);
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
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
	%# Axis limitations
    set(gca,'XLim',[-13 -2]);
    set(gca,'XTick',[-13:1:-2]);
    set(gca,'YLim',[2 7]);
    set(gca,'YTick',[2:1:7]);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Trim vs. Crm ----------------------------------------
    subplot(2,3,2)
    
    x7  = minmaxcond7(20,10);
    y7  = minmaxcond7(20,6);
    
    x8  = minmaxcond8(4,10)-0.5;
    y8  = minmaxcond8(4,6);
    
    x9  = minmaxcond9(5,10)+0.5;
    y9  = minmaxcond9(5,6);
    
    x10 = minmaxcond10(8,10);
    y10 = minmaxcond10(8,6);
    
    x11 = minmaxcond11(4,10)-0.5;
    y11 = minmaxcond11(4,6);
    
    x12 = minmaxcond12(5,10)+0.5;
    y12 = minmaxcond12(5,6);
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Trim [deg]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coeff. C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Trim vs. C_{Rm} at F_{r}=0.42 for cond. 7-12}','FontSize',setGeneralFontSize);
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
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
	%# Axis limitations
    %set(gca,'XLim',[0.1 0.5]);
    %set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[2 7]);
    set(gca,'YTick',[2:1:7]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));    
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Fr vs. Crm ----------------------------------------
    subplot(2,3,3)
    
    x7  = minmaxcond7(:,7);
    y7  = minmaxcond7(:,6);
    
    x8  = minmaxcond8(:,7);
    y8  = minmaxcond8(:,6);
    
    x9  = minmaxcond9(:,7);
    y9  = minmaxcond9(:,6);
    
    x10 = minmaxcond10(:,7);
    y10 = minmaxcond10(:,6);
    
    x11 = minmaxcond11(:,7);
    y11 = minmaxcond11(:,6);
    
    x12 = minmaxcond12(:,7);
    y12 = minmaxcond12(:,6);
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Froude length number [-]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coeff. C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf C_{Rm} plot for cond. 7-12}','FontSize',setGeneralFontSize);
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
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[1 5]);
    set(gca,'YTick',[1:1:5]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Heave vs. Crm ----------------------------------------
    subplot(2,3,4)
    
    x7  = minmaxcond7(10,5);
    y7  = minmaxcond7(10,6);
    
    x8  = minmaxcond8(2,5);
    y8  = minmaxcond8(2,6);
    
    x9  = minmaxcond9(2,5);
    y9  = minmaxcond9(2,6);
    
    x10 = minmaxcond10(4,5);
    y10 = minmaxcond10(4,6);
    
    x11 = minmaxcond11(2,5);
    y11 = minmaxcond11(2,6);
    
    x12 = minmaxcond12(3,5);
    y12 = minmaxcond12(3,6);
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Heave [mm]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coeff. C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Heave vs. C_{Rm} at F_{r}=0.29 for cond. 7-12}','FontSize',setGeneralFontSize);
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
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
	%# Axis limitations
    %set(gca,'XLim',[0.1 0.5]);
    %set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[3 6]);
    set(gca,'YTick',[3:1:6]);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));    
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    % Trim vs. Crm ----------------------------------------
    subplot(2,3,5)
    
    x7  = minmaxcond7(10,10);
    y7  = minmaxcond7(10,6);
    
    x8  = minmaxcond8(2,10)-0.5;
    y8  = minmaxcond8(2,6);
    
    x9  = minmaxcond9(2,10)+0.5;
    y9  = minmaxcond9(2,6);
    
    x10 = minmaxcond10(4,10);
    y10 = minmaxcond10(4,6);
    
    x11 = minmaxcond11(2,10)-0.5;
    y11 = minmaxcond11(2,6);
    
    x12 = minmaxcond12(3,10)+0.5;
    y12 = minmaxcond12(3,6);
    
    % Plotting
    h = plot(x7,y7,'*',x8,y8,'*',x9,y9,'*',x10,y10,'*',x11,y11,'*',x12,y12,'*');
    xlabel('{\bf Trim [deg]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Residual resistance coeff. C_{Rm}*1000 [-]}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Trim vs. C_{Rm} at F_{r}=0.29 for cond. 7-12}','FontSize',setGeneralFontSize);
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
    setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);    
    
    %# Axis limitations
    %set(gca,'XLim',[0.1 0.5]);
    %set(gca,'XTick',[0.1:0.1:0.5]);
    set(gca,'YLim',[3 6]);
    set(gca,'YTick',[3:1:6]);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','Northwest');
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
        plotsavename = sprintf('_plots/%s/%s/Plot_6_Heave_vs_Crm_Data_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ************************************************************************
    %# 7. Averaged forward and aft LVDT plots
    %# ************************************************************************
    
    %# Plotting power ---------------------------------------------------------
    figurename = 'Plot 7: Averaged forward and aft LVDT plots';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ----------------------------------------------------
    
%     if enableA4PaperSizePlot == 1
%         set(gcf, 'PaperSize', [19 19]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 19 19]);
%         
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperSize', [19 19]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 19 19]);
%     end
    
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
    setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>';'x'};
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
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# X and Y axis -----------------------------------------------------------

    %# Forward LVDT
    x1 = avgcond7(:,15);
    y1 = avgcond7(:,6);

    %# Forward LVDT
    x2 = avgcond7(:,15);
    y2 = avgcond7(:,7);
    
    %# Heave
    x3 = avgcond7(:,15);
    y3 = avgcond7(:,12);    
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
    xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf LVDT output and calculated heave (mm)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Averaged forward and aft LVDT}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize+2,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize+2,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 5;
    maxX  = 30;
    incrX = 5;
    minY  = -20;
    maxY  = 10;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))
    
    %# Legend
    hleg1 = legend('Forward LVDT','Aft LVDT','Heave');
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
%     if enableA4PaperSizePlot == 1
%         set(gcf, 'PaperUnits','centimeters');
%         set(gcf, 'PaperSize',[XPlot YPlot]);
%         set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%         set(gcf, 'PaperOrientation','portrait');
%     end
    
    %# Plot title -------------------------------------------------------------
%     if enablePlotMainTitle == 1
%         annotation('textbox', [0 0.9 1 0.1], ...
%             'String', strcat('{\bf ', figurename, '}'), ...
%             'EdgeColor', 'none', ...
%             'HorizontalAlignment', 'center');
%     end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_7_Foward_and_Aft_Averaged_LVDT_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ************************************************************************
    %# 8. Forward and aft LVDT plots
    %# ************************************************************************
    
    %# Plotting power ---------------------------------------------------------
    figurename = 'Plot 8: Forward and aft LVDT plots';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ----------------------------------------------------
    
%     if enableA4PaperSizePlot == 1
%         set(gcf, 'PaperSize', [19 19]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 19 19]);
%         
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperSize', [19 19]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 19 19]);
%     end
    
    % Fonts and colours -------------------------------------------------------
    setGeneralFontName = 'Helvetica';
    setGeneralFontSize = 16;
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
    setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>';'x'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 14;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# X and Y axis -----------------------------------------------------------

    %# Forward LVDT
    x1 = cond7(:,15);
    y1 = cond7(:,6);

    %# Forward LVDT
    x2 = cond7(:,15);
    y2 = cond7(:,7);
    
    %# Heave
    x3 = cond7(:,15);
    y3 = cond7(:,12);    
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
    xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf LVDT output and calculated heave (mm)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Forward and aft LVDT}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize+2,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize+2,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 5;
    maxX  = 30;
    incrX = 5;
    minY  = -20;
    maxY  = 10;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))
    
    %# Legend
    hleg1 = legend('Forward LVDT','Aft LVDT','Heave');
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
%     if enableA4PaperSizePlot == 1
%         set(gcf, 'PaperUnits','centimeters');
%         set(gcf, 'PaperSize',[XPlot YPlot]);
%         set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%         set(gcf, 'PaperOrientation','portrait');
%     end
    
    %# Plot title -------------------------------------------------------------
%     if enablePlotMainTitle == 1
%         annotation('textbox', [0 0.9 1 0.1], ...
%             'String', strcat('{\bf ', figurename, '}'), ...
%             'EdgeColor', 'none', ...
%             'HorizontalAlignment', 'center');
%     end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Plot_8_Foward_and_Aft_Averaged_LVDT_Plot.%s', '_heave', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;    
    
end
