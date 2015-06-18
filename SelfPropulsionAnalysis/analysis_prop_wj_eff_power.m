%# ------------------------------------------------------------------------
%# Self-Propulsion: Comparison of Propeller and Waterjet Results
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  June 18, 2015
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
%#               => analysis_bl.m    Bondary layer measurements
%#                                    ==> Creates resultsArrayBL.dat
%#
%#               => analysis_spp.m    Self-propulsion points
%#                                    ==> Creates resultsArraySPP.dat
%#
%#               => analysis_spp_ccdott.m Self-propulsion points by CCDoTT
%#                                    ==> Creates resultsArraySPP_CCDoTT.dat
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
%# CHANGES    :  18/06/2015 - Created new script
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

% Profiler
enableProfiler            = 0;    % Use profiler to show execution times

% Plot titles, colours, etc.
enablePlotMainTitle       = 0;    % Show plot title in saved file
enablePlotTitle           = 0;    % Show plot title above plot
enableBlackAndWhitePlot   = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot     = 1;    % Show plots scale to A4 size

% Adjusted fitting for towing force vs. thrust plot and F at T=0 as well as
enableAdjustedFitting     = 1;    % Show adjusted fitting for speeds 6,8 and 9
enableCommandWindowOutput = 1;    % Show command window output

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


%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'Waterjet Self-Propulsion Test';

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile on
end

%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                       % Towing Tank: Length            (m)
ttwidth             = 3.5;                       % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                      % Towing Tank: Water depth       (m)
ttcsa               = ttwidth*ttwaterdepth;      % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 18.5;                      % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                     % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;              % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s)  -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;              % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s)  -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;                  % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;                 % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                      % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                      % Full scale to model scale ratio               (-)

%# ************************************************************************
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl           = 4.30;                          % Model length waterline          (m)
MSwsa           = 1.501;                         % Model scale wetted surface area (m^2)
MSdraft         = 0.133;                         % Model draft                     (m)
MSAx            = 0.024;                         % Model area of max. transverse section (m^2)
BlockCoeff      = 0.592;                         % Mode block coefficient          (-)
AreaRatio       = MSAx/(ttwaterdepth*ttwidth);   % Area ratio                      (-)
FSlwl           = MSlwl*FStoMSratio;             % Full scale length waterline     (m)
FSwsa           = MSwsa*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft         = MSdraft*FStoMSratio;           % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************

% (1+k) determine using slow speed Prohaska runs
FormFactor = 1.14;

% Correlation coefficients: No Ca (AMC), typical Ca (Bose 2008) and MARIN Ca
CorrCoeff  = 0.00035;                                           % Ca value as used by MARIN for JHSV testing (USE AS DEFAULT)
%CorrCoeff  = 0;                                                % Correlation coefficient, Ca as used by AMC
%CorrCoeff  = (105*((150*10^(-6))/FSlwl)^(1/3)-0.64)*10^(-3);   % Ca calculcation for typical value as shown in Bose (2008), equation 2-4, page 6

% Waterjet constants (FS = full scale and MS = model scale) ---------------

% Width factor (typical value, source??)
WidthFactor    = 1.3;

% Pump diameter, Dp, (m)
FS_PumpDia     = 1.2;
%MS_PumpDia     = 0.056;
MS_PumpDia     = FS_PumpDia/FStoMSratio;

% Effective nozzle diameter, Dn, (m)
FS_EffNozzDia  = 0.72;
%MS_EffNozzDia  = 0.033;
MS_EffNozzDia  = FS_EffNozzDia/FStoMSratio;

% Nozzle area, An, (m^2)
FS_NozzArea    = 0.4072;
%MS_NozzArea    = 0.00087;
MS_NozzArea    = ((FS_EffNozzDia/2)/FStoMSratio)^2*pi;

% Impeller diameter, Di, (m)
FS_ImpDia      = 1.582;
%MS_ImpDia      = 0.073;
MS_ImpDia      = FS_ImpDia/FStoMSratio;

% Pump inlet area, A4, (m^2)
FS_PumpInlArea = 1.99;
MS_PumpInlArea = 0.004;

% Pump maximum area, A5, (m^2)
FS_PumpMaxArea = 0.67;
MS_PumpMaxArea = 0.001;

%# ************************************************************************
%# Start Boundary layer related constants
%# ------------------------------------------------------------------------

% Boundary layer: Power law factors (-)
% NOTE: See Matlab file "analysis_bl.m" for values
BLPLFactorArray  = [6.6467 6.6467 6.6467 6.6467 6.6467 6.6467 6.6467 6.6467 6.6467];

% Boundary layer: Thickness (m)
% NOTE: See Excel file "Run Sheet - Self-Propulsion Test.xlsx" WS "3 BL and wake fraction" for values
BLThicknessArray = [0.0452 0.0453 0.0451 0.0445 0.0436 0.0424 0.0408 0.0389 0.0367];

%# ------------------------------------------------------------------------
%# End Boundary layer related constants
%# ************************************************************************

% Installation efficiency (typical value)
InstEff = 1;

% ITTC 1978 Related Values ------------------------------------------------

% Drag coefficient
% See: Oura, T. & Ikeda, Y. 2007, 'Maneuverability Of A Wavepiercing High-Speed
%      Catamaran At Low Speed In Strong Wind', Proceedings of the The
%      2nd International Conference on Marine Research and Transportation
%      28/6/2007, Ischia, Naples, Italy.
DragCoeff = 0.446;

% Roughness of hull surface (ks), typical value
RoughnessOfHullSurface = 150*10^(-6);

% Air density at 20 °C and 101.325 kPa
airDensity = 1.2041;

% FULL SCALE: Demihull, projected area of the ship above the water line
% to the transverse plane, AVS (m^2)
% Established using Incat GA drawing and extracting transverse area then scaling to full scale size.
FSProjectedArea = 341.5/2;

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


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

%# Propeller_vs_Waterjet directory ----------------------------------------
setDirName = '_plots/Propeller_vs_Waterjet';

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
%# 1. Propeller vs. Waterjet Comparison
%# ************************************************************************
figurename = 'Plot 1: Propeller vs. Waterjet Comparison';
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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize1     = 12;
setMarkerSize2     = 11;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineWidthMarker = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

%# 98m: 1,500 tonnes
x1 = [0.24;0.26;0.28;0.30;0.32;0.34;0.36;0.38;0.40];
y1 = [0.48;0.51;0.51;0.51;0.53;0.58;0.60;0.60;0.56];
Raw_Data = num2cell(y1); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

%# 130m: 2,500 tonnes
x2 = [0.26;0.29;0.32;0.35;0.38;0.40;0.44];
y2 = [0.71;0.66;0.71;0.74;0.72;0.67;0.68];
Raw_Data = num2cell(y2); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

%# 130m: 3,640 tonnes
x3 = [0.26;0.29;0.33;0.36;0.39;0.40;0.45];
y3 = [0.60;0.57;0.66;0.71;0.73;0.67;0.63];
Raw_Data = num2cell(y3); Raw_Data = cellfun(@(y) y*100, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'-',x2,y2,'*',x3,y3,'*');
Plot1LegendInfo_1{1} = '98m: 1,500 tonnes';
Plot1LegendInfo_1{2} = '130m: 2,500 tonnes';
Plot1LegendInfo_1{3} = '130m: 3,640 tonnes';
%if enablePlotTitle == 1
%    title('{\bf Overall Propulsive Efficiency}','FontSize',setGeneralFontSize);
%end
xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Overall propulsive efficiency, \eta_{D} (%)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{8},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(3),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);

%# Axis limitations
minX  = 0.2;
maxX  = 0.5;
incrX = 0.05;
minY  = 0;
maxY  = 100;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
hleg1 = legend(Plot1LegendInfo_1);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,2)

%# X and Y axis -----------------------------------------------------------

%# 98m: 1,500 tonnes: Effective Power
x1 = [0.24;0.26;0.28;0.30;0.32;0.34;0.36;0.38;0.40];
y1 = [0.74;0.97;1.21;1.49;1.80;2.15;2.53;2.96;3.44];

%# 130m: 2,500 tonnes: Effective Power
x2 = [0.26;0.29;0.32;0.35;0.38;0.40;0.44];
y2 = [0.93;1.34;1.72;2.16;3.04;4.00;6.11];

%# 130m: 3,640 tonnes: Effective Power
x3 = [0.26;0.29;0.33;0.36;0.39;0.40;0.45];
y3 = [1.71;2.43;3.04;3.67;4.98;6.41;10.06];

%# 98m: 1,500 tonnes: Delivered Power
x4 = [0.24;0.26;0.28;0.30;0.32;0.34;0.36;0.38;0.40];
y4 = [1.55;1.89;2.36;2.89;3.39;3.72;4.23;4.92;6.11];

%# 130m: 2,500 tonnes: Delivered Power
x5 = [0.26;0.29;0.32;0.35;0.38;0.40;0.44];
y5 = [1.32;2.03;2.42;2.90;4.20;5.93;9.04];

%# 130m: 3,640 tonnes: Delivered Power
x6 = [0.26;0.29;0.33;0.36;0.39;0.40;0.45];
y6 = [2.87;4.27;4.64;5.20;6.85;9.52;15.88];

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'-',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
Plot1LegendInfo_2{1} = '98m: 1,500 tonnes (P_{E})';
Plot1LegendInfo_2{2} = '130m: 2,500 tonnes (P_{E})';
Plot1LegendInfo_2{3} = '130m: 3,640 tonnes (P_{E})';
Plot1LegendInfo_2{4} = '98m: 1,500 tonnes (P_{D})';
Plot1LegendInfo_2{5} = '130m: 3,640 tonnes (P_{D})';
Plot1LegendInfo_2{6} = '130m: 3,640 tonnes (P_{D})';
%if enablePlotTitle == 1
%    title('{\bf Overall Propulsive Efficiency}','FontSize',setGeneralFontSize);
%end
xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Effective and delivered power (MW)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line, colors and markers
%setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h1(4),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(5),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(6),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);

%# Axis limitations
minX  = 0.2;
maxX  = 0.5;
incrX = 0.05;
minY  = 0;
maxY  = 18;
incrY = 2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
hleg1 = legend(Plot1LegendInfo_2);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1,'Interpreter','tex');
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
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Propeller_vs_Waterjet_Comparison_Plot.%s', 'Propeller_vs_Waterjet', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 2. Propeller vs. Waterjet Resistance Comparison
%# ************************************************************************
figurename = 'Plot 2: Propeller vs. Waterjet Resistance Comparison';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%     
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

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
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize1     = 12;
setMarkerSize2     = 11;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineWidthMarker = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

%# 98m: 1,500 tonnes
x1 = [0.24;0.26;0.28;0.30;0.32;0.34;0.36;0.38;0.40];
y1 = [9.5;11.9;14.1;16.4;18.7;21.1;23.3;25.3;27.2];

%# 130m: 2,500 tonnes
x2 = [0.26;0.29;0.32;0.35;0.38;0.40;0.44];
y2 = [11.2;14.4;16.6;19.1;24.9;31.5;43.3];

%# 130m: 3,640 tonnes
x3 = [0.26;0.29;0.33;0.36;0.39;0.40;0.45];
y3 = [13.9;17.7;19.9;22.0;27.5;34.1;48.2];

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'-',x2,y2,'*',x3,y3,'*');
Plot2LegendInfo{1} = 'Waterjet vessel: 1,500 tonnes';
Plot2LegendInfo{2} = 'Propeller vessel: 1,031 tonnes (unscaled 2,500 tonnes)';
Plot2LegendInfo{3} = 'Propeller vessel: 1,583 tonnes (unscaled 3,640 tonnes)';
%if enablePlotTitle == 1
%    title('{\bf Scaled resistance}','FontSize',setGeneralFontSize);
%end
xlabel('{\bf Length Froude number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf (R_{T}/\Delta g)x10^{3} (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{8},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(3),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);

%# Axis limitations
minX  = 0.2;
maxX  = 0.5;
incrX = 0.05;
minY  = 0;
maxY  = 60;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
hleg1 = legend(Plot2LegendInfo);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1,'Interpreter','tex');
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
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

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
    plotsavename = sprintf('_plots/%s/%s/Plot_2_Propeller_vs_Waterjet_Scaled_Resistance_Comparison_Plot.%s', 'Propeller_vs_Waterjet', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile viewer
end
