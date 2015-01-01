%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Calibrations
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  January 1, 2015
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Kiel probe (V) plotted against flow rate
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  23/12/2014 - File creation
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
%# START DEFINE PLOT SIZE
%# ------------------------------------------------------------------------
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END DEFINE PLOT SIZE
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ************************************************************************
%# START: PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle     = 0;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 0;    % Show plots scale to A4 size

% Special plot switches
enableTextOnPlot        = 0;    % Show equation of fit text on plot

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox2'));
[mtb,ntb] = size(ind);

% IF ntb > 0 Curve Fitting Toolbox is installed
enableCurveFittingToolboxCurvePlot = 0;    % Show fit curves when using Curve Fitting Toolbox
if ntb > 0
    enableCurveFittingToolboxPlot  = 1;
    enableEqnOfFitPlot             = 0;
else
    enableCurveFittingToolboxPlot  = 0;
    enableEqnOfFitPlot             = 1;
end

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


%# ************************************************************************
%# START Create directories if not available
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _calibrations directory ------------------------------------------------
setDirName = '_plots/_calibrations';

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
%# END Create directories if not available
%# ************************************************************************


%# ************************************************************************
%# START First and second wave prove calibration results
%# ------------------------------------------------------------------------
if exist('WPCalibrations.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('WPCalibrations.mat');
    
    WPCalStart = [];
    WPCalEnd   = [];
    
    % First Calibration (Start)
    WPCalStart(:,1) = WPCalibrations(:,1);
    WPCalStart(:,2) = WPCalibrations(:,2);
    
    % Second Calibration (Start)
    WPCalEnd(:,1)   = WPCalibrations(:,1);
    WPCalEnd(:,2)   = WPCalibrations(:,3);
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file (June2013FRMT.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# START First and second wave prove calibration results
%# ************************************************************************


%# ************************************************************************
%# Plot 1: Wave Probe Calibrations
%# ************************************************************************
figurename = 'Plot 1: Wave Probe Calibration';
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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineStyle       = '-';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

x1 = WPCalStart(:,2);
y1 = WPCalStart(:,1);

% Model data - Linear fit
[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1 = coeffvalues(fitobject1);
cnames1  = coeffnames(fitobject1);
output1  = formula(fitobject1);

FirstCalText = sprintf('\\bf First equation of fit: \\rm y = %sx+%s, R^2=%s',sprintf('%.1f',cvalues1(1)),sprintf('%.1f',cvalues1(2)),sprintf('%.1f',gof1.rsquare));

x2 = WPCalEnd(:,2);
y2 = WPCalEnd(:,1);

% Model data - Linear fit
[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2 = coeffvalues(fitobject2);
cnames2  = coeffnames(fitobject2);
output2  = formula(fitobject2);

SecondCalText = sprintf('\\bf Second equation of fit: \\rm y = %sx+%s, R^2=%s',sprintf('%.1f',cvalues2(1)),sprintf('%.1f',cvalues2(2)),sprintf('%.1f',gof2.rsquare));

%# Plotting ---------------------------------------------------------------
h1 = plot(fitobject1,'k--',x1,y1,'*');
legendInfo{1} = 'Calibration 1';
legendInfo{2} = 'Calibration 1 (linear fit)';
hold on;
h2 = plot(fitobject2,'k-.',x2,y2,'*');
legendInfo{3} = 'Calibration 2';
legendInfo{4} = 'Calibration 2 (linear fit)';
xlabel('{\bf Analog wave probe output (Volt)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass of water (Kg)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf Wave Probe Calibration}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h1(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h2(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h2(1),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% set(h1,'marker','+');
% set(h1,'linestyle','none');

%# Annotations
text(-6.5,80,FirstCalText,'FontSize',12,'color','k','FontWeight','normal');
text(-6.5,30,SecondCalText,'FontSize',12,'color','k','FontWeight','normal');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = -10;
maxX  = 4;
incrX = 1;
minY  = -100;
maxY  = 600;
incrY = 100;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend('First calibration (start of test)','Second calibration (end of testing)');
hleg1 = legend(legendInfo);
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
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
% annotation('textbox', [0 0.9 1 0.1], ...
%    'String', strcat('{\bf ', figurename, '}'), ...
%    'EdgeColor', 'none', ...
%    'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Wave_Probe_Calibration_Plot.%s', '_calibrations', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;
