%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis: Full Scale Comparisons
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 12, 2014
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
%# SCRIPTS  :    => analysis.m        First iteration analysis
%#                                    ==> Creates resultsArray.dat
%#
%#               => analysis_calib.m  PST calibration run data
%#                                    ==> Creates resultsArrayCALIB.dat
%#
%#               => analysis_rt.m    Flow visualistation and resistance
%#                                    ==> Creates resultsArrayRT.dat
%#
%#               => analysis_bl.m    Bondary layer measurements
%#                                    ==> Creates resultsArrayBL.dat
%#
%#               => analysis_spp.m    Self-propulsion points
%#                                    ==> Creates resultsArraySPP.dat
%#
%#               => analysis_spt.m    Self-propulsion test
%#                                    ==> Creates resultsArraySPT.dat
%#
%#               => analysis_avg.m    Averages self-propulsion test repeats
%#                                    ==> Creates avgResultsArray.dat
%#
%#               => analysis_ts.m    Time series data
%#                                    ==> Creates resultsArrayTS.dat
%#
%#               => analysis_fscomp.m  Full Scale Results Comparison
%#                                     ==> Uses fullScaleDataArray.dat
%#                                     ==> Uses SeaTrials1500TonnesCorrPower
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  16/09/2014 - Created new script
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
enablePlotMainTitle         = 1;    % Show plot title in saved file
enablePlotTitle             = 1;    % Show plot title above plot
enableBlackAndWhitePlot     = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot       = 1;    % Show plots scale to A4 size

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox'));
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

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ************************************************************************
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
%# ************************************************************************


%# ************************************************************************
%# START Full scale results
%# ------------------------------------------------------------------------
if exist('fullScaleDataArraySetsOriginalFit.dat', 'file') == 2
    %# Results array columns:
    % See 4. Extrapolation to full scale for column descriptions
    fullscaleresults = csvread('fullScaleDataArraySetsOriginalFit.dat');
    [mfsr,nfsr] = size(fullscaleresults);
    %# Remove zero rows
    fullscaleresults(all(fullscaleresults==0,2),:)=[];
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: File fullScaleDataArraySets.dat does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Full scale results
%# ************************************************************************


%# ************************************************************************
%# START Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ------------------------------------------------------------------------
if exist('SeaTrials1500TonnesCorrPower.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('SeaTrials1500TonnesCorrPower.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (SeaTrials1500TonnesCorrPower.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ************************************************************************


%# ************************************************************************
%# 1. Splitting fullscaleresults by Ca Values
%# ************************************************************************

% Split results array based on column 70 (correlcation coefficient)
R = fullscaleresults;   % Results array
A = arrayfun(@(x) R(R(:,71) == x, :), unique(R(:,71)), 'uniformoutput', false);
[mfsr,nfsr] = size(A);      % Array dimensions
if mfsr ~= 3
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: There are not three (3) datasets in fullscaleresults!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break; 
end

%# ************************************************************************
%# 2. Plotting Comparisons: Power and Overall Propulsive Efficiency
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 1: Full Scale Comparisons: Delivered Power and Overall Propulsive Efficiency';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineStyle       = '-';

%# Delivered Power vs. Ship Speed /////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

x = SeaTrialsCorrectedPower(:,1);
y = SeaTrialsCorrectedPower(:,3);

% Fitting curve through sea trials delivered power
fitobject = fit(x,y,'poly5');
cvalues = coeffvalues(fitobject);

% Sea Trials Data
fittingSpeeds = [13:1:25];
[mfs,nfs] = size(fittingSpeeds);
delpowerMW = [];
for k=1:nfs
    actSpeed = fittingSpeeds(k);
    delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
end
xst  = fittingSpeeds;
yst  = delpowerMW;

% Ca = 0
activeArray = A{1};
[ma,na] = size(activeArray);
delpowerMW = [];
for k=1:ma
    delpowerMW(k) = ((activeArray(k,42)+activeArray(k,43))*2)/1000^2;
end
x1  = A{1}(:,3);
y1  = delpowerMW;

% Ca = 0.00035
activeArray = A{2};
[ma,na] = size(activeArray); 
delpowerMW = [];
for k=1:ma
    delpowerMW(k) = ((activeArray(k,42)+activeArray(k,43))*2)/1000^2;
end
x2  = A{2}(:,3);
y2  = delpowerMW;

% Ca = 0.00059
activeArray = A{3};
[ma,na] = size(activeArray); 
delpowerMW = [];
for k=1:ma
    delpowerMW(k) = ((activeArray(k,42)+activeArray(k,43))*2)/1000^2;
end
x3  = A{3}(:,3);
y3  = delpowerMW;

%# Plotting ---------------------------------------------------------------
h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Two Demi Hulls (Catamaran)}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 18;
incrY = 2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('Corrected Power (Sea Trials)','P_{D} using Ca=0','P_{D} using Ca=0.00035','P_{D} using Ca=0.00059');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Overall Propulsive Efficiency vs. Ship Speed ///////////////////////////
subplot(1,2,2)

%# X and Y axis -----------------------------------------------------------

% Ca = 0
x1  = A{1}(:,3);
y1  = A{1}(:,46);

% Ca = 0.00035
x2  = A{2}(:,3);
y2  = A{2}(:,46);

% Ca = 0.00059
x3  = A{3}(:,3);
y3  = A{3}(:,46);

% Ca = 0
x4  = A{1}(:,3);
y4  = A{1}(:,68);

% Ca = 0.00035
x5  = A{2}(:,3);
y5  = A{2}(:,68);

% Ca = 0.00059
x6  = A{3}(:,3);
y6  = A{3}(:,68);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Overall propulsive efficiency (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Two Demi Hulls (Catamaran)}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 1;
incrY = 0.1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('\eta_{D} using Ca=0 where P_{D}=P_{PE}/\eta_{Pump}','\eta_{D} using Ca=0.00035 where P_{D}=P_{PE}/\eta_{Pump}','\eta_{D} using Ca=0.00059 where P_{D}=P_{PE}/\eta_{Pump}','\eta_{D} using Ca=0 where P_{D}=P_{JSE}/\eta_{JS}','\eta_{D} using Ca=0.00035 where P_{D}=P_{JSE}/\eta_{JS}','\eta_{D} using Ca=0.00059 where P_{D}=P_{JSE}/\eta_{JS}');
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
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Comparison_Power_And_OPE_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 3. Plotting Comparisons: Resistance, Thrust vs. Ship Speed
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 2: Full Scale Comparisons: Power and Energy Flux (Stations 0, 1 and 7)';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineStyle       = '-';

%# Resistance, Thrust vs. Ship Speed //////////////////////////////////////

%# X and Y axis -----------------------------------------------------------

% Inlet velocity ratio, IVR

% Ca = 0
x1 = A{1}(:,3);
y1 = A{1}(:,47);

% Ca = 0.00035
x2 = A{3}(:,3);
y2 = A{2}(:,47);

% Ca = 0.00059
x3 = A{3}(:,3);
y3 = A{3}(:,47);

% Jet velocity ratio, JVR

% Ca = 0
x4 = A{1}(:,3);
y4 = A{1}(:,49);

% Ca = 0.00035
x5 = A{3}(:,3);
y5 = A{2}(:,49);

% Ca = 0.00059
x6 = A{3}(:,3);
y6 = A{3}(:,49);

% Nozzle velocity ratio, NVR

% Ca = 0
x7 = A{1}(:,3);
y7 = A{1}(:,51);

% Ca = 0.00035
x8 = A{3}(:,3);
y8 = A{2}(:,51);

% Ca = 0.00059
x9 = A{3}(:,3);
y9 = A{3}(:,51);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*',x9,y9,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Velocity ratio (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Single Waterjet System}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{9},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(6),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(7),'Color',setColor{1},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(8),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(9),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 2.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('IVR (Ca=0)','IVR (Ca=0.00035)','IVR (Ca=0.00059)','JVR (Ca=0)','JVR (Ca=0.00035)','JVR (Ca=0.00059)','NVR (Ca=0)','NVR (Ca=0.00035)','NVR (Ca=0.00059)');
set(hleg1,'Location','SouthEast');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
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
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Comparison_IVR_JVR_NVR_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 3. Plotting Comparisons: Thrust Deduction vs. Ship Speed
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 3: Full Scale Comparisons: Thrust Deduction';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineStyle       = '-';

%# Resistance, Thrust vs. Ship Speed //////////////////////////////////////

%# X and Y axis -----------------------------------------------------------

% Ca = 0
x1 = A{1}(:,3);
y1 = A{1}(:,18);

% Ca = 0.00035
x2 = A{3}(:,3);
y2 = A{2}(:,18);

% Ca = 0.00059
x3 = A{3}(:,3);
y3 = A{3}(:,18);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Velocity ratio (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Single Waterjet System}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{9},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = -1;
maxY  = 1;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('IVR (Ca=0)','IVR (Ca=0.00035)','IVR (Ca=0.00059)','JVR (Ca=0)','JVR (Ca=0.00035)','JVR (Ca=0.00059)','NVR (Ca=0)','NVR (Ca=0.00035)','NVR (Ca=0.00059)');
set(hleg1,'Location','SouthEast');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
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
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Comparison_Thrust_Deduction_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 5. Plotting Comparisons: Power and Energy Flux
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 4: Full Scale Comparisons: Power and Energy Flux (Stations 0, 1 and 7)';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineStyle       = '-';

%# Power vs. Ship Speed ///////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

activeArray = A{1};
[ma,na] = size(activeArray);

% Ca = 0, Pump effective power (PPE)
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,40)/1000^2;
end
x1  = A{1}(:,3);
y1  = powerMW;

% Ca = 0, Delivered power (PD)
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,42)/1000^2;
end
x2  = A{1}(:,3);
y2  = powerMW;

% Ca = 0, Brake power (PB)
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,44)/1000^2;
end
x3  = A{1}(:,3);
y3  = powerMW;

% Ca = 0, Effective jet system power (PJSE)
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,58)/1000^2;
end
x4  = A{1}(:,3);
y4  = powerMW;

% Ca = 0, Effective thrust power (PTE)
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,60)/1000^2;
end
x5  = A{1}(:,3);
y5  = powerMW;

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Power (MW)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Single Waterjet System, Ca=0}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 4.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('Pump effective power (P_{PE})','Delivered power (P_{D})','Brake power (P_{B})','Effective jet system power (P_{JSE})','Effective thrust power (P_{TE})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Energy Flux vs. Ship Speed /////////////////////////////////////////////
subplot(1,2,2)

%# X and Y axis -----------------------------------------------------------

% Ca = 0, E0
activeArray = A{1};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,57)/1000^2;
end
x1  = activeArray(:,3);
y1  = powerMW;

% Ca = 0.00035, E0
activeArray = A{2};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,57)/1000^2;
end
x2  = activeArray(:,3);
y2  = powerMW;

% Ca = 0.00059, E0
activeArray = A{3};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,57)/1000^2;
end
x3  = activeArray(:,3);
y3  = powerMW;

% Ca = 0, E1
activeArray = A{1};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,53)/1000^2;
end
x4  = activeArray(:,3);
y4  = powerMW;

% Ca = 0.00035, E1
activeArray = A{2};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,53)/1000^2;
end
x5  = activeArray(:,3);
y5  = powerMW;

% Ca = 0.00059, E1
activeArray = A{3};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,53)/1000^2;
end
x6  = activeArray(:,3);
y6  = powerMW;

% Ca = 0, E7
activeArray = A{1};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,55)/1000^2;
end
x7  = activeArray(:,3);
y7  = powerMW;

% Ca = 0.00035, E7
activeArray = A{2};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,55)/1000^2;
end
x8  = activeArray(:,3);
y8  = powerMW;

% Ca = 0.00059, E7
activeArray = A{3};
[ma,na] = size(activeArray);
powerMW = [];
for k=1:ma
    powerMW(k) = activeArray(k,55)/1000^2;
end
x9  = activeArray(:,3);
y9  = powerMW;

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*',x9,y9,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Energy flux (MW)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Single Waterjet System}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{9},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(6),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(7),'Color',setColor{1},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(8),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(9),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 3.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('E0 (Station 0) using Ca=0','E0 (Station 0) using Ca=0.00035','E0 (Station 0) using Ca=00059','E1 (Station 1) using Ca=0','E1 (Station 1) using Ca=0.00035','E1 (Station 1) using Ca=00059','E7 (Station 7) using Ca=0','E7 (Station 7) using Ca=00035','E7 (Station 7) using Ca=00059');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
%set(hleg1, 'Interpreter','tex');
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
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Comparison_Power_And_Energy_Flux_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ************************************************************************
%# 6. Command Window Output
%# ************************************************************************
for k=1:mfsr
    if A{k}(1,69) == 1
        setCurve = 'Original';
    else
        setCurve = 'Adjusted';
    end
    if A{k}(1,70) == 1
        setPEEqn = 'PPE=(E7/nn)-niE1 (Bose 2008) => PD=PPE/nPump => nD=PE/PD';
    else
        setPEEqn = 'PPE=p g QJ H35 (ITTC) => PD=PPE/nPump => nD=PE/PD';
    end
    setText = sprintf('Ca=%s: Curve fitting of T vs. F: %s, Pump effective power using: %s',sprintf('%.5f',A{k}(1,71)),setCurve,setPEEqn);
    disp(setText);
end
