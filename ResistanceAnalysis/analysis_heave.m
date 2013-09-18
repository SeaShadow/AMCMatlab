%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Heave Averaging Investigation
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 16, 2013
%#
%# Test date  :  August 27 to September 6, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  01-35   Turbulence Studs Investigation               (TSI)
%# Runs TTI   :  36-62   Trim Tab Optimisation                        (TTI)
%# Runs FF1   :  63-80   Form Factor Estimation using Prohaska Method (FF)
%# Runs RT    :  81-231  Resistance Test                              (RT)
%# Runs FF2   :  231-249 Form Factor Estimation using Prohaska Method (FF)
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
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  16/09/2013 - Created new script
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
% 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *************************************************************************     
if length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
    
    startRun = 81;
    endRun   = 231;
    
    % *********************************************************************
    % Averaged values using data from all repeat runs
    % *********************************************************************
    figurename = sprintf('%s (using all repeat runs):: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');   
    
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
    
    h = plot(x7,y7,'*',x7avg,y7avg,'-',x8,y8,'+',x8avg,y8avg,'-',x9,y9,'x',x9avg,y9avg,'-',x10,y10,'o',x10avg,y10avg,'-',x11,y11,'s',x11avg,y11avg,'-',x12,y12,'d',x12avg,y12avg,'-','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Repeated and averaged runs}');
    grid on;
    box on;
    axis square;
    
    % Colors and markers
    set(h(1),'Color',[0 0 1],'Marker','*');
    set(h(2),'Color',[0 0 1],'LineStyle',':','linewidth',1);
    set(h(3),'Color',[0 0.5 0],'Marker','+');
    set(h(4),'Color',[0 0.5 0],'LineStyle',':','linewidth',1);
    set(h(5),'Color',[1 0 0],'Marker','x');
    set(h(6),'Color',[1 0 0],'LineStyle',':','linewidth',1);
    set(h(7),'Color',[0 0.75 0.75],'Marker','o');
    set(h(8),'Color',[0 0.75 0.75],'LineStyle',':','linewidth',1);
    set(h(9),'Color',[0.75 0 0.75],'Marker','s');
    set(h(10),'Color',[0.75 0 0.75],'LineStyle',':','linewidth',1);
    set(h(11),'Color',[0.75 0.75 0],'Marker','d');
    set(h(12),'Color',[0.75 0.75 0],'LineStyle',':','linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-14 2]);
    set(gca,'YTick',[-14:2:2]);
    
    %# Legend
    hleg1 = legend([h(1) h(3) h(5) h(7) h(9) h(11)],'Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;
    
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
    
    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'+',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged runs only}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'LineStyle','--','linewidth',1);
    set(h(2),'Color',[0 0.5 0],'LineStyle','-.','linewidth',1);
    set(h(3),'Color',[1 0 0],'LineStyle','-.','linewidth',1);
    set(h(4),'Color',[0 0.75 0.75],'LineStyle','--','linewidth',1);
    set(h(5),'Color',[0.75 0 0.75],'LineStyle','-.','linewidth',1);
    set(h(6),'Color',[0.75 0.75 0],'LineStyle','-.','linewidth',1);  
    
    %# Line width
    %set(h(1),'linewidth',2);
    %set(h(2),'linewidth',2);
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-14 2]);
    set(gca,'YTick',[-14:2:2]);

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;   
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;
    
    % *********************************************************************
    % Min, Max and Averaged min/max
    % *********************************************************************
    figurename = sprintf('%s (min & max values only):: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');
    
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
    
    h = plot(x7,y7avg,'--*',x7avgall,y7avgall,':x',x10,y10avg,'--+',x10avgall,y10avgall,':o','MarkerSize',7);
    %hold on;
    %h = plot(x10,y10avg,'-.*',x10avgall,y10avgall,'--x','MarkerSize',7);
    %hold off;
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged min/max compared to average of all repeats (level)}');
    grid on;
    box on;
    %axis square;

    %# Line width
    %set(h(1),'linewidth',1);
    %set(h(2),'linewidth',1);
    
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
    %legend boxoff;
    
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
    
    h = plot(x7,y7min,'--*',x10,y10min,'-.x','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Lowest values only (level)}');
    grid on;
    box on;
    %axis square;

    %# Line width
    %set(h(2),'linewidth',2);
    %set(h(7),'linewidth',2);    
    
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
    %legend boxoff;

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
    
    h = plot(x8,y8avg,'--*',x8avgall,y8avgall,'-.x',x11,y11avg,'-.+',x11avgall,y11avgall,'--o','MarkerSize',7);
    %hold on;
    %h = plot(x10,y10avg,'-.*',x10avgall,y10avgall,'--x','MarkerSize',7);
    %hold off;
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged min/max compared to average of all repeats (-0.5 deg)}');
    grid on;
    box on;
    %axis square;

    %# Line width
    %set(h(1),'linewidth',1);
    %set(h(2),'linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) min/max','Cond. 8: 1,500t (-0.5 deg) All repeats','Cond. 11: 1,804t (-0.5 deg) min/max','Cond. 11: 1,804t (-0.5 deg) All repeats');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;
    
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
    
    h = plot(x8,y8min,'--*',x11,y11min,'-.x','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Lowest values only (-0.5 deg)}');
    grid on;
    box on;
    %axis square;

    %# Line width
    %set(h(2),'linewidth',2);
    %set(h(7),'linewidth',2);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) Min','Cond. 11: 1,804t (-0.5 deg) Min');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;     
   
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
    
    h = plot(x9,y9avg,'--*',x9avgall,y9avgall,'-.x',x12,y12avg,'-.+',x12avgall,y12avgall,'--o','MarkerSize',7);
    %hold on;
    %h = plot(x10,y10avg,'-.*',x10avgall,y10avgall,'--x','MarkerSize',7);
    %hold off;
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged min/max compared to average of all repeats (0.5 deg)}');
    grid on;
    box on;
    %axis square;

    %# Line width
    %set(h(1),'linewidth',1);
    %set(h(2),'linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-10 0]);
    set(gca,'YTick',[-10:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) min/max','Cond. 9: 1,500t (0.5 deg) All repeats','Cond. 12: 1,804t (0.5 deg) min/max','Cond. 12: 1,804t (0.5 deg) All repeats');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;
    
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
    
    h = plot(x9,y9min,'--*',x12,y12min,'-.x','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Lowest values only (0.5 deg)}');
    grid on;
    box on;
    %axis square;

    %# Line width
    %set(h(2),'linewidth',2);
    %set(h(7),'linewidth',2);    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    set(gca,'XLim',[0.1 0.5]);
    set(gca,'XTick',[0.1:0.05:0.5]);
    set(gca,'YLim',[-10 0]);
    set(gca,'YTick',[-10:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) Min','Cond. 12: 1,804t (0.5 deg) Min');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Min_Max.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Min_Max.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;
    
    % *********************************************************************
    % Fitting lines (level static trim)
    % *********************************************************************
    figurename = sprintf('%s (curve fitting, level static trim):: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');

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
    
    h = plot(x7,y7avg,'*',x7avgall,y7avgall,'o',x7,polyv7,'-sk',x10,y10avg,'+',x10avgall,y10avgall,'v',x10,polyv10,'-dk','MarkerSize',10);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged min/max, Curve fitting}');
    grid on;
    box on;
    axis square;

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
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg) min/max','Cond. 7: 1,500t (0 deg) All repeats','Cond. 7: 1,500t Curve fitting','Cond. 10: 1,804t (0 deg) min/max','Cond. 10: 1,804t (0 deg) All repeats','Cond. 10: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    
    h = plot(x7,y7min,'*',x7,polyv7,'-sk',x10,y10min,'x',x10,polyv10,'-dk','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Lowest values only}');
    grid on;
    box on;
    axis square;

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
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg) Min','Cond. 7: 1,500t Curve fitting','Cond. 10: 1,804t (0 deg) Min','Cond. 10: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Fitting_Curves_Level.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Fitting_Curves_Level.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;    
   
    % *********************************************************************
    % Fitting lines (-0.5 degrees by bow)
    % *********************************************************************
    figurename = sprintf('%s (curve fitting, -0.5 degrees by bow):: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');

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
    
    h = plot(x8,y8avg,'*',x8avgall,y8avgall,'o',x8,polyv8,'-sk',x11,y11avg,'+',x11avgall,y11avgall,'v',x11,polyv11,'-dk','MarkerSize',10);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged min/max, Curve fitting}');
    grid on;
    box on;
    axis square;

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
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) min/max','Cond. 8: 1,500t (-0.5 deg) All repeats','Cond. 8: 1,500t Curve fitting','Cond. 11: 1,804t (-0.5 deg) min/max','Cond. 11: 1,804t (-0.5 deg) All repeats','Cond. 11: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    
    h = plot(x8,y8min,'*',x8,polyv8,'-sk',x11,y11min,'x',x11,polyv11,'-dk','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Lowest values only}');
    grid on;
    box on;
    axis square;

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
    
    %# Legend
    hleg1 = legend('Cond. 8: 1,500t (-0.5 deg) Min','Cond. 8: 1,500t Curve fitting','Cond. 11: 1,804t (-0.5 deg) Min','Cond. 11: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Fitting_Curves_05_By_Bow.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Fitting_Curves_05_By_Bow.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;
    
    % *********************************************************************
    % Fitting lines (0.5 degrees by stern)
    % *********************************************************************
    figurename = sprintf('%s (curve fitting, 0.5 degrees by stern):: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');

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
    
    h = plot(x9,y9avg,'*',x9avgall,y9avgall,'o',x9,polyv9,'-sk',x12,y12avg,'+',x12avgall,y12avgall,'v',x12,polyv12,'-dk','MarkerSize',10);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Averaged min/max, Curve fitting}');
    grid on;
    box on;
    axis square;

    % Annotations
    text(0.41,-7,sprintf('%.1f',min(polyv9)),'FontSize',11,'color','k','FontWeight','normal');
    text(0.41,-8.5,sprintf('%.1f',min(polyv12)),'FontSize',11,'color','k','FontWeight','normal');
    
    %# Line width
    %set(h(1),'linewidth',1);
    %set(h(2),'linewidth',1);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    set(gca,'XLim',[0.2 0.5]);
    set(gca,'XTick',[0.2:0.05:0.5]);
    set(gca,'YLim',[-14 0]);
    set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) min/max','Cond. 9: 1,500t (0.5 deg) All repeats','Cond. 9: 1,500t Curve fitting','Cond. 12: 1,804t (0.5 deg) min/max','Cond. 12: 1,804t (0.5 deg) All repeats','Cond. 12: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    
    h = plot(x9,y9min,'*',x9,polyv9,'-sk',x12,y12min,'x',x12,polyv12,'-dk','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    title('{\bf Lowest values only}');
    grid on;
    box on;
    axis square;

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
    
    %# Legend
    hleg1 = legend('Cond. 9: 1,500t (0.5 deg) Min','Cond. 9: 1,500t Curve fitting','Cond. 12: 1,804t (0.5 deg) Min','Cond. 12: 1,804t Curve fitting');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;    
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Fitting_Curves_05_By_Stern.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Heave_Data_Plots_Fitting_Curves_05_By_Stern.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;    
    
    % *********************************************************************
    % Heave vs. Crm for conditions 7 - 12
    % *********************************************************************
    figurename = sprintf('%s (using averaged min/max values):: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');   

    % Heave vs. Crm ----------------------------------------
    subplot(1,2,1)    
    
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
    
    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'x',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Heave [mm]}');
    ylabel('{\bf Residual resistance coefficient C_{rm}*1000 [-]}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    %set(h(1),'Color',[0 0 1],'Marker','*','LineStyle',':','linewidth',1);
    %set(h(2),'Color',[0 0.5 0],'Marker','+','LineStyle',':','linewidth',1);
    %set(h(3),'Color',[1 0 0],'Marker','x','LineStyle',':','linewidth',1);
    %set(h(4),'Color',[0 0.75 0.75],'Marker','o','LineStyle',':','linewidth',1);
    %set(h(5),'Color',[0.75 0 0.75],'Marker','s','LineStyle',':','linewidth',1);
    %set(h(6),'Color',[0.75 0.75 0],'Marker','d','LineStyle',':','linewidth',1);

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    %set(gca,'XLim',[0.2 0.5]);
    %set(gca,'XTick',[0.2:0.05:0.5]);
    %set(gca,'YLim',[-14 0]);
    %set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;      
    
    % Fr vs. Crm ----------------------------------------
    subplot(1,2,2)    
    
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
    
    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'x',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Residual resistance coefficient C_{rm}*1000 [-]}');
    grid on;
    box on;
    axis square;

    % Colors and markers
    set(h(1),'Color',[0 0 1],'Marker','*','LineStyle','-','linewidth',1);
    set(h(2),'Color',[0 0.5 0],'Marker','+','LineStyle','-.','linewidth',1);
    set(h(3),'Color',[1 0 0],'Marker','x','LineStyle','-.','linewidth',1);
    set(h(4),'Color',[0 0.75 0.75],'Marker','o','LineStyle','-','linewidth',1);
    set(h(5),'Color',[0.75 0 0.75],'Marker','s','LineStyle',':','linewidth',1);
    set(h(6),'Color',[0.75 0.75 0],'Marker','d','LineStyle',':','linewidth',1);

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    %set(gca,'XLim',[0.2 0.5]);
    %set(gca,'XTick',[0.2:0.05:0.5]);
    %set(gca,'YLim',[-14 0]);
    %set(gca,'YTick',[-14:2:0]);
    
    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    %legend boxoff;     
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Heave_vs_Crm_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Heave_vs_Crm_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;    
    
end