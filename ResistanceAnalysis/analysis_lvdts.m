%# ------------------------------------------------------------------------
%# Resistance Test Analysis - LVDT Comparisons
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 23, 2013
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
testName = 'LVDT Investigation';

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
% 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************     
if length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
    
    startRun = 81;
    endRun   = 231;
    
    % *********************************************************************
    % CONDITIONS 7 and 10
    % *********************************************************************
    figurename = sprintf('%s (using repeated runs):: 1,500 and 1,804 tonnes, level, Run %s to %s, Cond. 7 and 10', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)    
    
    x7       = avgcond7(:,11);
    y7heave  = avgcond7(:,12);
    y7fwd    = avgcond7(:,6);
    y7aft    = avgcond7(:,7);
    
    x8       = avgcond8(:,11);
    y8heave  = avgcond8(:,12);    
    y8fwd    = avgcond8(:,6);
    y8aft    = avgcond8(:,7);
    
    x9       = avgcond9(:,11);
    y9heave  = avgcond9(:,12);    
    y9fwd    = avgcond9(:,6);
    y9aft    = avgcond9(:,7);
    
    x10      = avgcond10(:,11);
    y10heave = avgcond10(:,12);    
    y10fwd   = avgcond10(:,6);
    y10aft   = avgcond10(:,7);
    
    x11      = avgcond11(:,11);
    y11heave = avgcond11(:,12);    
    y11fwd   = avgcond11(:,6);
    y11aft   = avgcond11(:,7);
    
    x12      = avgcond12(:,11);
    y12heave = avgcond12(:,12);    
    y12fwd   = avgcond12(:,6);
    y12aft   = avgcond12(:,7);
    
    h = plot(x7,y7heave,x7,y7fwd,'+',x7,y7aft,'x',x10,y10heave,x10,y10fwd,'s',x10,y10aft,'d','MarkerSize',8);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf LVDT measurement [m]}');
    %title('{\bf Conditions 7 & 10: 1,500 & 1,804 tonnes, level}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'LineStyle','-','linewidth',2); %,'Marker','*'
    set(h(2),'Color',[0 0 1],'Marker','+','LineStyle','--','linewidth',1);
    set(h(3),'Color',[0 0 1],'Marker','x','LineStyle','-.','linewidth',1);
    set(h(4),'Color',[1 0 0],'LineStyle','-','linewidth',2); %,'Marker','o'
    set(h(5),'Color',[1 0 0],'Marker','s','LineStyle','--','linewidth',1);
    set(h(6),'Color',[1 0 0],'Marker','d','LineStyle','-.','linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);

    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-20 10]);
    set(gca,'YTick',[-20:2:10]);
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t, level (heave)','Cond. 7: 1,500t, level (fwd LVDT)','Cond. 7: 1,500t, level (aft LVDT)','Cond. 10: 1,804t, level (heave)','Cond. 10: 1,804t, level (fwd LVDT)','Cond. 10: 1,804t, level (aft LVDT)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    % Model speed vs. trim (degrees) ----------------------------------------
    subplot(1,2,2)     
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xcond8 = cond8(:,11); ycond8 = cond8(:,13);
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
        x8 = xcond8; y8 = ycond8;        
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xcond9 = cond9(:,11); ycond9 = cond9(:,13);
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
        xcond11 = cond11(:,11); ycond11 = cond11(:,13);
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
        x11 = xcond11; y11 = ycond11;         
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xcond12 = cond12(:,11); ycond12 = cond12(:,13);
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
        x12 = xcond12; y12 = ycond12;        
    else
        x12 = 0; y12 = 0;
    end     

    h = plot(x7,y7,'-*',x10,y10,'--o','MarkerSize',8);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Running trim [deg]}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'Marker','*','LineStyle','-','linewidth',1);
    set(h(2),'Color',[1 0 0],'Marker','o','LineStyle','-','linewidth',1);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);

    %# Legend
    %hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    hleg1 = legend('Cond. 7: 1,500t, level','Cond. 10: 1,804t, level');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;    

    %# Save plot as PNG -------------------------------------------------------

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
      
    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_LVDT_Data_Plots_Averaged_Cond_7_11.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_LVDT_Data_Plots_Averaged_Cond_7_11.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG    
    
    % *********************************************************************
    % CONDITIONS 8 and 11
    % *********************************************************************
    figurename = sprintf('%s (using repeated runs):: 1,500 and 1,804 tonnes, -0.5 degrees, Run %s to %s, Cond. 8 and 11', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');    
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)    
    
    x7       = avgcond7(:,11);
    y7heave  = avgcond7(:,12);
    y7fwd    = avgcond7(:,6);
    y7aft    = avgcond7(:,7);
    
    x8       = avgcond8(:,11);
    y8heave  = avgcond8(:,12);    
    y8fwd    = avgcond8(:,6);
    y8aft    = avgcond8(:,7);
    
    x9       = avgcond9(:,11);
    y9heave  = avgcond9(:,12);    
    y9fwd    = avgcond9(:,6);
    y9aft    = avgcond9(:,7);
    
    x10      = avgcond10(:,11);
    y10heave = avgcond10(:,12);    
    y10fwd   = avgcond10(:,6);
    y10aft   = avgcond10(:,7);
    
    x11      = avgcond11(:,11);
    y11heave = avgcond11(:,12);    
    y11fwd   = avgcond11(:,6);
    y11aft   = avgcond11(:,7);
    
    x12      = avgcond12(:,11);
    y12heave = avgcond12(:,12);    
    y12fwd   = avgcond12(:,6);
    y12aft   = avgcond12(:,7);
    
    h = plot(x8,y8heave,x8,y8fwd,'+',x8,y8aft,'x',x11,y11heave,x11,y11fwd,'s',x11,y11aft,'d','MarkerSize',8);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf LVDT measurement [m]}');
    %title('{\bf Conditions 8 & 11: 1,500 & 1,804 tonnes, -0.5 degrees}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'LineStyle','-','linewidth',2); %,'Marker','*'
    set(h(2),'Color',[0 0 1],'Marker','+','LineStyle','--','linewidth',1);
    set(h(3),'Color',[0 0 1],'Marker','x','LineStyle','-.','linewidth',1);
    set(h(4),'Color',[1 0 0],'LineStyle','-','linewidth',2); %,'Marker','o'
    set(h(5),'Color',[1 0 0],'Marker','s','LineStyle','--','linewidth',1);
    set(h(6),'Color',[1 0 0],'Marker','d','LineStyle','-.','linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    

    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-25 5]);
    set(gca,'YTick',[-25:2:5]);
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t, -0.5 deg (heave)','Cond. 8: 1,500t, -0.5 deg (fwd LVDT)','Cond. 8: 1,500t, -0.5 deg (aft LVDT)','Cond. 11: 1,804t, -0.5 deg (heave)','Cond. 11: 1,804t, -0.5 deg (fwd LVDT)','Cond. 11: 1,804t, -0.5 deg (aft LVDT)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    % Model speed vs. trim (degrees) ----------------------------------------
    subplot(1,2,2)     
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xcond8 = cond8(:,11); ycond8 = cond8(:,13);
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
        x8 = xcond8; y8 = ycond8;        
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xcond9 = cond9(:,11); ycond9 = cond9(:,13);
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
        xcond11 = cond11(:,11); ycond11 = cond11(:,13);
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
        x11 = xcond11; y11 = ycond11;         
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xcond12 = cond12(:,11); ycond12 = cond12(:,13);
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
        x12 = xcond12; y12 = ycond12;        
    else
        x12 = 0; y12 = 0;
    end     

    h = plot(x8,y8,'-*',x11,y11,'--o','MarkerSize',8);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Running trim [deg]}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'Marker','*','LineStyle','-','linewidth',1);
    set(h(2),'Color',[1 0 0],'Marker','o','LineStyle','-','linewidth',1);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);

    %# Legend
    %hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    hleg1 = legend('Cond. 8: 1,500t, -0.5 deg','Cond. 11: 1,804t, -0.5 deg');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;    
    
    %# Save plot as PNG -------------------------------------------------------

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
      
    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_LVDT_Data_Plots_Averaged_Cond_8_11.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_LVDT_Data_Plots_Averaged_Cond_8_11.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG    
    
    % *********************************************************************
    % CONDITIONS 9 and 12
    % *********************************************************************    
    figurename = sprintf('%s (using repeated runs):: 1,500 and 1,804 tonnes, 0.5 degrees, Run %s to %s, Cond. 9 and 12', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');    
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(1,2,1)    
    
    x7       = avgcond7(:,11);
    y7heave  = avgcond7(:,12);
    y7fwd    = avgcond7(:,6);
    y7aft    = avgcond7(:,7);
    
    x8       = avgcond8(:,11);
    y8heave  = avgcond8(:,12);    
    y8fwd    = avgcond8(:,6);
    y8aft    = avgcond8(:,7);
    
    x9       = avgcond9(:,11);
    y9heave  = avgcond9(:,12);    
    y9fwd    = avgcond9(:,6);
    y9aft    = avgcond9(:,7);
    
    x10      = avgcond10(:,11);
    y10heave = avgcond10(:,12);    
    y10fwd   = avgcond10(:,6);
    y10aft   = avgcond10(:,7);
    
    x11      = avgcond11(:,11);
    y11heave = avgcond11(:,12);    
    y11fwd   = avgcond11(:,6);
    y11aft   = avgcond11(:,7);
    
    x12      = avgcond12(:,11);
    y12heave = avgcond12(:,12);    
    y12fwd   = avgcond12(:,6);
    y12aft   = avgcond12(:,7);
    
    h = plot(x9,y9heave,x9,y9fwd,'+',x9,y9aft,'x',x12,y12heave,x12,y12fwd,'s',x12,y12aft,'d','MarkerSize',8);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf LVDT measurement [m]}');
    %title('{\bf Conditions 8 & 11: 1,500 & 1,804 tonnes, -0.5 degrees}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'LineStyle','-','linewidth',2); %,'Marker','*'
    set(h(2),'Color',[0 0 1],'Marker','+','LineStyle','--','linewidth',1);
    set(h(3),'Color',[0 0 1],'Marker','x','LineStyle','-.','linewidth',1);
    set(h(4),'Color',[1 0 0],'LineStyle','-','linewidth',2); %,'Marker','o'
    set(h(5),'Color',[1 0 0],'Marker','s','LineStyle','--','linewidth',1);
    set(h(6),'Color',[1 0 0],'Marker','d','LineStyle','-.','linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    

    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-20 10]);
    set(gca,'YTick',[-20:2:10]);
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t, 0.5 deg (heave)','Cond. 9: 1,500t, 0.5 deg (fwd LVDT)','Cond. 9: 1,500t, 0.5 deg (aft LVDT)','Cond. 12: 1,804t, 0.5 deg (heave)','Cond. 12: 1,804t, 0.5 deg (fwd LVDT)','Cond. 12: 1,804t, 0.5 deg (aft LVDT)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;    
    
    % Model speed vs. trim (degrees) ----------------------------------------
    subplot(1,2,2)     
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xcond8 = cond8(:,11); ycond8 = cond8(:,13);
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
        x8 = xcond8; y8 = ycond8;        
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xcond9 = cond9(:,11); ycond9 = cond9(:,13);
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
        xcond11 = cond11(:,11); ycond11 = cond11(:,13);
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y-0.5, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
        x11 = xcond11; y11 = ycond11;         
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xcond12 = cond12(:,11); ycond12 = cond12(:,13);
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y+0.5, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
        x12 = xcond12; y12 = ycond12;        
    else
        x12 = 0; y12 = 0;
    end     

    h = plot(x9,y9,'-*',x12,y12,'--o','MarkerSize',8);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Running trim [deg]}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'Marker','*','LineStyle','-','linewidth',1);
    set(h(2),'Color',[1 0 0],'Marker','o','LineStyle','-','linewidth',1);
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);

    %# Legend
    %hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    hleg1 = legend('Cond. 9: 1,500t, 0.5 deg','Cond. 12: 1,804t, 0.5 deg');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    %# Save plot as PNG -------------------------------------------------------

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
      
    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_LVDT_Data_Plots_Averaged_Cond_9_12.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_LVDT_Data_Plots_Averaged_Cond_9_12.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    
end