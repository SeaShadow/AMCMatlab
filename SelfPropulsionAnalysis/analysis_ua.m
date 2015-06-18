%# ------------------------------------------------------------------------
%# Self-Propulsion: Uncertainty Analysis Plots
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  May 12, 2015
%#
%# Test date  :  November 5 to November 18, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs CT    :  1-15    PST + DPT Calibration Test               (CT)
%# Runs RT    :  16-28   Resistance Test / Transom Streamlines    (RT)
%# Runs BLM   :  29-69   Boundary Layer Measurements              (BLM)
%# Runs SPP   :  70-110  Self-Propulsion Points                   (SPP)
%# Runs SPT   :  111-180 Self-Propulsion Test                     (SPT)
%#
%# Speeds (FR)    :  0.3-0.4 (18-24 knots)
%#
%# Description    :  Waterjet self-propulsion test based on test setups
%#                   using literature and ITTC.
%#
%# ITTC Guidelines:  7.5-02-02-03.1
%#                   7.5-02-02-03.2
%#                   7.5-02-02-03.3
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  26/05/2015 - File creation
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
enablePlotMainTitle     = 0;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 1;    % Show plots scale to A4 size

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
%# START Define plot size
%# ------------------------------------------------------------------------
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END Define plot size
%# ************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# START: CREATE PLOTS AND RUN DIRECTORY
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _uncertainty_analysis directory ----------------------------------------
setDirName = '_plots/_uncertainty_analysis';

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
%# ////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START Load PORT Uncertainty Result
%# ------------------------------------------------------------------------
if exist('ITTC_UA_Results_Jet_Thrust_PORT.mat', 'file') == 2
    % Load file into variable
    load('ITTC_UA_Results_Jet_Thrust_PORT.mat');
    resultsUAPORT = ITTC_UA_Results_Jet_Thrust_PORT;
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for uncertainty analysis (ITTC_UA_Results_Jet_Thrust_PORT.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load PORT Uncertainty Result
%# ************************************************************************


%# ************************************************************************
%# START Load STBD Uncertainty Result
%# ------------------------------------------------------------------------
if exist('ITTC_UA_Results_Jet_Thrust_STBD.mat', 'file') == 2
    % Load file into variable
    load('ITTC_UA_Results_Jet_Thrust_STBD.mat');
    resultsUASTBD = ITTC_UA_Results_Jet_Thrust_STBD;
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for uncertainty analysis (ITTC_UA_Results_Jet_Thrust_STBD.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load STBD Uncertainty Result
%# ************************************************************************


%# ------------------------------------------------------------------------
%# Plot Uncertainty Analysis Data
%# ------------------------------------------------------------------------

%# ************************************************************************
%# 1. Total uncertainty of K_T plotted against length Froude number
%# ************************************************************************
figurename = 'Plot 1: Total uncertainty of K_{T}';
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
    'FontSize',14,...
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
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,1,1)

% X and Y values ----------------------------------------------------------

x  = resultsUASTBD(:,1);
y1 = resultsUASTBD(:,29);
y2 = resultsUAPORT(:,29);

% Plotting ----------------------------------------------------------------
h = bar(x, [y1 y2], 1);
legendInfo1{1} = 'Starboard waterjet system';
legendInfo1{2} = 'Port waterjet system';
xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Jet thrust uncertainty (%)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Jet thrust uncertainty','FontSize',setGeneralFontSize);
% end
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Colors and markers
set(h(1),'FaceColor',[0.4,0.4,0.4]);
set(h(2),'FaceColor',[0.6,0.6,0.6]);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 5;
incrY = 1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo1);
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
% % %legend boxoff;

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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Jet_Thrust_Uncertainty_Analysis_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 2. PORT: Relative importance of errors
%# ************************************************************************
figurename = 'Plot 2: PORT: Relative importance of errors';
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
    'FontSize',14,...
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
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,1,1)

% X and Y values ----------------------------------------------------------

SR = 1;
v1 = resultsUAPORT(SR,20);
v2 = resultsUAPORT(SR,21);
v3 = resultsUAPORT(SR,22);
v4 = resultsUAPORT(SR,23);
v5 = resultsUAPORT(SR,24);
v6 = resultsUAPORT(SR,25);

x  = [1 2 3 4 5 6]';
y1 = [v1 0 0 0 0 0]';
y2 = [0 v2 0 0 0 0]';
y3 = [0 0 v3 0 0 0]';
y4 = [0 0 0 v4 0 0]';
y5 = [0 0 0 0 v5 0]';
y6 = [0 0 0 0 0 v6]';

% Plotting ----------------------------------------------------------------
h = bar(x, [y1 y2 y3 y4 y5 y6], 3);
legendInfo1{1} = 'Flow rate, (Q_{J})';
legendInfo1{2} = 'Shaft speed (n)';
legendInfo1{3} = 'Nozzle diameter (D)';
legendInfo1{4} = 'Pump centre inclination (\alpha)';
legendInfo1{5} = 'Density (\rho)';
legendInfo1{6} = 'Temperature(tw)';
%xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Relative contribution to error (%)}','FontSize',setGeneralFontSize);
title('{\bf Port waterjet propulsion system at Fr = 0.24}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Colors and markers
set(h,'EdgeColor','none');
set(h(1),'FaceColor',[0.85,0.85,0.85]);
set(h(2),'FaceColor',[0.7,0.7,0.7]);
set(h(3),'FaceColor',[0.55,0.55,0.55]);
set(h(4),'FaceColor',[0.4,0.4,0.4]);
set(h(5),'FaceColor',[0.25,0.25,0.25]);
set(h(6),'FaceColor',[0.1,0.1,0.1]);
% set(h(1),'FaceColor','r');
% set(h(2),'FaceColor','g');
% set(h(3),'FaceColor','b');
% set(h(4),'FaceColor','y');
% set(h(5),'FaceColor','m');
% set(h(6),'FaceColor','c');

%# Axis limitations
minY  = 0;
maxY  = 50;
incrY = 10;
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca, 'XTick', []);

%# Legend
hleg1 = legend(legendInfo1);
set(hleg1,'Location','SouthOutside');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
set(hleg1,'Orientation','horizontal');
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,1,2)

% X and Y values ----------------------------------------------------------

SR = 1;
v1 = resultsUASTBD(SR,20);
v2 = resultsUASTBD(SR,21);
v3 = resultsUASTBD(SR,22);
v4 = resultsUASTBD(SR,23);
v5 = resultsUASTBD(SR,24);
v6 = resultsUASTBD(SR,25);

x  = [1 2 3 4 5 6]';
y1 = [v1 0 0 0 0 0]';
y2 = [0 v2 0 0 0 0]';
y3 = [0 0 v3 0 0 0]';
y4 = [0 0 0 v4 0 0]';
y5 = [0 0 0 0 v5 0]';
y6 = [0 0 0 0 0 v6]';

% Plotting ----------------------------------------------------------------
h = bar(x, [y1 y2 y3 y4 y5 y6], 3);
legendInfo1{1} = 'Flow rate, (Q_{J})';
legendInfo1{2} = 'Shaft speed (n)';
legendInfo1{3} = 'Nozzle diameter (D)';
legendInfo1{4} = 'Pump centre inclination (\alpha)';
legendInfo1{5} = 'Density (\rho)';
legendInfo1{6} = 'Temperature(tw)';
%xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Relative contribution to error (%)}','FontSize',setGeneralFontSize);
title('{\bf Starboard waterjet propulsion system at Fr = 0.24}','FontSize',setGeneralFontSize);
grid on;
box on;
%axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Colors and markers
set(h,'EdgeColor','none');
set(h(1),'FaceColor',[0.85,0.85,0.85]);
set(h(2),'FaceColor',[0.7,0.7,0.7]);
set(h(3),'FaceColor',[0.55,0.55,0.55]);
set(h(4),'FaceColor',[0.4,0.4,0.4]);
set(h(5),'FaceColor',[0.25,0.25,0.25]);
set(h(6),'FaceColor',[0.1,0.1,0.1]);
% set(h(1),'FaceColor','r');
% set(h(2),'FaceColor','g');
% set(h(3),'FaceColor','b');
% set(h(4),'FaceColor','y');
% set(h(5),'FaceColor','m');
% set(h(6),'FaceColor','c');

%# Axis limitations
minY  = 0;
maxY  = 50;
incrY = 10;
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca, 'XTick', []);

%# Legend
hleg1 = legend(legendInfo1);
set(hleg1,'Location','SouthOutside');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
set(hleg1,'Orientation','horizontal');
legend boxoff;
    
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_2_Port_Important_of_Error_Sources_Plot.%s', '_uncertainty_analysis', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

