%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Time Series analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 27, 2013
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
%# CHANGES    :  27/09/2013 - Created new script
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

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% All runs for cond 7
startRun = 81;    % Start at run x
endRun   = 141;   % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Loop through data
for k=startRun:endRun
    
    timeSeriesData = [];
    
    % Correct for run numbers below 10
    if k < 10
        runnumber = sprintf('0%s',num2str(k));
    else
        runnumber = sprintf('%s',num2str(k));
    end
    
    % Set general filename
    filename = sprintf('_time_series_data/R%s.dat',runnumber);
    
    % Read DAT file
    if exist(filename, 'file') == 2
        timeSeriesData = csvread(filename);
        timeSeriesData(all(timeSeriesData==0,2),:)=[];
    end
    
    eval(['tsdr' num2str(k) '= timeSeriesData;']);
    
end

% Time series data array
%[1] Time           (s)
%[2] Speed          (m/s)
%[3] Forward LVDT   (mm)
%[4] Aft LVDT       (mm)
%[5] Drag           (g)

% Plot data

% *************************************************************************
% CONDITION 7: Fr=0.23, runs 84 - 86
% *************************************************************************
froudeNo = '0.23';
sr       = 84;
er       = 86;
setCond  = 7;
figurename = sprintf('%s:: Run %s to %s, Fr=%s, Condition %s', 'Repateded Runs Time Series Data', num2str(sr), num2str(er), froudeNo, num2str(setCond));
f = figure('Name',figurename,'NumberTitle','off');

% Time vs. Speed -------------------------------------------
subplot(2,2,1)

x1 = tsdr84(:,1);
y1 = tsdr84(:,3);

x2 = tsdr85(:,1);
y2 = tsdr85(:,3);

x3 = tsdr86(:,1);
y3 = tsdr86(:,3);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Aft LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 84','Run 85','Run 86');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,2)

x1 = tsdr84(:,1);
y1 = tsdr84(:,2);

x2 = tsdr85(:,1);
y2 = tsdr85(:,2);

x3 = tsdr86(:,1);
y3 = tsdr86(:,2);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Speed [m/s]}');
title('{\bf Speed}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 84','Run 85','Run 86');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,3)

x1 = tsdr84(:,1);
y1 = tsdr84(:,4);

x2 = tsdr85(:,1);
y2 = tsdr85(:,4);

x3 = tsdr86(:,1);
y3 = tsdr86(:,4);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Fwd LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 84','Run 85','Run 86');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,4)

x1 = tsdr84(:,1);
y1 = tsdr84(:,5);

x2 = tsdr85(:,1);
y2 = tsdr85(:,5);

x3 = tsdr86(:,1);
y3 = tsdr86(:,5);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Drag [g]}');
title('{\bf Drag}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 84','Run 85','Run 86');
set(hleg1,'Location','NorthEast');
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
%plotsavenamePDF = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.pdf', '_time_series_data', num2str(sr), num2str(es), froudeNo);
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.png', '_time_series_data', num2str(sr), num2str(er), froudeNo);
saveas(f, plotsavename);                % Save plot as PNG
%close;

% *************************************************************************
% CONDITION 7: Fr=0.32, runs 93 - 95
% *************************************************************************
froudeNo = '0.32';
sr       = 93;
er       = 95;
setCond  = 7;
figurename = sprintf('%s:: Run %s to %s, Fr=%s, Condition %s', 'Repateded Runs Time Series Data', num2str(sr), num2str(er), froudeNo, num2str(setCond));
f = figure('Name',figurename,'NumberTitle','off');

% Time vs. Speed -------------------------------------------
subplot(2,2,1)

x1 = tsdr93(:,1);
y1 = tsdr93(:,3);

x2 = tsdr94(:,1);
y2 = tsdr94(:,3);

x3 = tsdr95(:,1);
y3 = tsdr95(:,3);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Aft LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 93','Run 94','Run 95');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,2)

x1 = tsdr93(:,1);
y1 = tsdr93(:,2);

x2 = tsdr94(:,1);
y2 = tsdr94(:,2);

x3 = tsdr95(:,1);
y3 = tsdr95(:,2);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Speed [m/s]}');
title('{\bf Speed}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 93','Run 94','Run 95');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,3)

x1 = tsdr93(:,1);
y1 = tsdr93(:,4);

x2 = tsdr94(:,1);
y2 = tsdr94(:,4);

x3 = tsdr95(:,1);
y3 = tsdr95(:,4);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Fwd LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 93','Run 94','Run 95');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,4)

x1 = tsdr93(:,1);
y1 = tsdr93(:,5);

x2 = tsdr94(:,1);
y2 = tsdr94(:,5);

x3 = tsdr95(:,1);
y3 = tsdr95(:,5);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Drag [g]}');
title('{\bf Drag}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 93','Run 94','Run 95');
set(hleg1,'Location','NorthEast');
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
%plotsavenamePDF = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.pdf', '_time_series_data', num2str(sr), num2str(es), froudeNo);
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.png', '_time_series_data', num2str(sr), num2str(er), froudeNo);
saveas(f, plotsavename);                % Save plot as PNG
%close;

% *************************************************************************
% CONDITION 7: Fr=0.35, runs 96 - 98
% *************************************************************************
froudeNo = '0.35';
sr       = 96;
er       = 98;
setCond  = 7;
figurename = sprintf('%s:: Run %s to %s, Fr=%s, Condition %s', 'Repateded Runs Time Series Data', num2str(sr), num2str(er), froudeNo, num2str(setCond));
f = figure('Name',figurename,'NumberTitle','off');

% Time vs. Speed -------------------------------------------
subplot(2,2,1)

x1 = tsdr96(:,1);
y1 = tsdr96(:,3);

x2 = tsdr97(:,1);
y2 = tsdr97(:,3);

x3 = tsdr98(:,1);
y3 = tsdr98(:,3);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Aft LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 96','Run 97','Run 98');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,2)

x1 = tsdr96(:,1);
y1 = tsdr96(:,2);

x2 = tsdr97(:,1);
y2 = tsdr97(:,2);

x3 = tsdr98(:,1);
y3 = tsdr98(:,2);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Speed [m/s]}');
title('{\bf Speed}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 96','Run 97','Run 98');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,3)

x1 = tsdr96(:,1);
y1 = tsdr96(:,4);

x2 = tsdr97(:,1);
y2 = tsdr97(:,4);

x3 = tsdr98(:,1);
y3 = tsdr98(:,4);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Fwd LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 96','Run 97','Run 98');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,4)

x1 = tsdr96(:,1);
y1 = tsdr96(:,5);

x2 = tsdr97(:,1);
y2 = tsdr97(:,5);

x3 = tsdr98(:,1);
y3 = tsdr98(:,5);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Drag [g]}');
title('{\bf Drag}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 96','Run 97','Run 98');
set(hleg1,'Location','NorthEast');
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
%plotsavenamePDF = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.pdf', '_time_series_data', num2str(sr), num2str(es), froudeNo);
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.png', '_time_series_data', num2str(sr), num2str(er), froudeNo);
saveas(f, plotsavename);                % Save plot as PNG
%close;

% *************************************************************************
% CONDITION 7: Fr=0.41, runs 102 - 104
% *************************************************************************
froudeNo = '0.41';
sr       = 102;
er       = 104;
setCond  = 7;
figurename = sprintf('%s:: Run %s to %s, Fr=%s, Condition %s', 'Repateded Runs Time Series Data', num2str(sr), num2str(er), froudeNo, num2str(setCond));
f = figure('Name',figurename,'NumberTitle','off');

% Time vs. Speed -------------------------------------------
subplot(2,2,1)

x1 = tsdr102(:,1);
y1 = tsdr102(:,3);

x2 = tsdr103(:,1);
y2 = tsdr103(:,3);

x3 = tsdr104(:,1);
y3 = tsdr104(:,3);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Aft LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 102','Run 103','Run 104');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,2)

x1 = tsdr102(:,1);
y1 = tsdr102(:,2);

x2 = tsdr103(:,1);
y2 = tsdr103(:,2);

x3 = tsdr104(:,1);
y3 = tsdr104(:,2);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Speed [m/s]}');
title('{\bf Speed}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 102','Run 103','Run 104');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,3)

x1 = tsdr102(:,1);
y1 = tsdr102(:,4);

x2 = tsdr103(:,1);
y2 = tsdr103(:,4);

x3 = tsdr104(:,1);
y3 = tsdr104(:,4);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf LVDT output [mm]}');
title('{\bf Fwd LVDT}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 102','Run 103','Run 104');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
legend boxoff;

% Time vs. Speed -------------------------------------------
subplot(2,2,4)

x1 = tsdr102(:,1);
y1 = tsdr102(:,5);

x2 = tsdr103(:,1);
y2 = tsdr103(:,5);

x3 = tsdr104(:,1);
y3 = tsdr104(:,5);

h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
xlabel('{\bf Time [s]}');
ylabel('{\bf Drag [g]}');
title('{\bf Drag}');
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line width
set(h(1),'Color',[0 0 1],'Marker','*','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(2),'Color',[0 1 0],'Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
set(h(3),'Color',[1 0 0],'Marker','x','MarkerSize',1,'LineStyle',':','linewidth',1);
%set(h(4),'Color',[0 1 1],'Marker','o','MarkerSize',1,'LineStyle','--','linewidth',1);
%set(h(5),'Color',[1 0 1],'Marker','o','MarkerSize',1,'LineStyle','-.','linewidth',1);
%set(h(6),'Color',[1 1 0],'Marker','o','MarkerSize',1,'LineStyle',':','linewidth',1);

%# Axis limitations
% set(gca,'XLim',[0.2 0.5]);
% set(gca,'XTick',[0.2:0.05:0.5]);
% set(gca,'YLim',[0 75]);
% set(gca,'YTick',[0:5:75]);

%# Legend
hleg1 = legend('Run 102','Run 103','Run 104');
set(hleg1,'Location','NorthEast');
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
%plotsavenamePDF = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.pdf', '_time_series_data', num2str(sr), num2str(es), froudeNo);
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('%s/Run%s_to_Run%s_Fr_%s_Time_Series_Run_Comparison_Plots.png', '_time_series_data', num2str(sr), num2str(er), froudeNo);
saveas(f, plotsavename);                % Save plot as PNG
%close;