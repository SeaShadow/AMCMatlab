%# ------------------------------------------------------------------------
%# Self-Propulsion: Sensor Calibrations
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  February 20, 2015
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
%# CHANGES    :  17/02/2015 - Created new script
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
enablePlotMainTitle     = 1;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 0;    % Show plots scale to A4 size

% Special plot switches
enableTextOnPlot        = 0;    % Show equation of fit text on plot

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

%# Calibrations directory ------------------------------------------------
setDirName = '_plots/Calibrations';

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
%# START Import Calibration Files
%# ------------------------------------------------------------------------

% Number of headerlines and filespath
headerlines  = 15;           % Number of headerlines to data
runfilespath = '..\\..\\';   % Relative path from Matlab directory

% Filepath and filenames

% LVDTs
filename1 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 06112013_41.cal');
filename2 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '02_CH2 AftLVDT Gain 2.5 1 Hz 06112013_41.cal');

% Load cell
filename3 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '03_Ch3 Force Trans Gain 2x10 Filter 1Hz 06112013_77.cal');

% Thrust
filename4 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '06_Ch6 Port Thrust Gain 8x1.5 Filter 1Hz 05112013_01.cal');
filename5 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '08_Ch8 Stbd Thrust Gain 8x1.5 Filter 1Hz 05112013_01.cal');

% Thrust
filename6 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '07_Ch7 Port Torque Gain 10x2 +CCW Filter 1Hz 05112013_02.cal');
filename7 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '09_Ch9 Stbd Torque Gain 10x2 +CCW Filter 1Hz 05112013_02.cal');

% Pitot static tube
filename8 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '19_ch19 Inboard PST G2 F1Hz unity calibr 07112013_02.cal');
filename9 = sprintf('%s%s\\%s', runfilespath, 'DAQ Cal Files', '20_ch20 Outboard PST G2 F1Hz unity calibr 07112013_02.cal');

%# ------------------------------------------------------------------------
%# Break Analysis if Calibration Files Do Not Exist
%# ------------------------------------------------------------------------

if exist(filename1, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\01_Ch1_FwdLVDT_ Gain 2.5 Filter 1Hz 06112013_41.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename2, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\02_CH2 AftLVDT Gain 2.5 1 Hz 06112013_41.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename3, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\03_Ch3 Force Trans Gain 2x10 Filter 1Hz 06112013_77.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename4, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\06_Ch6 Port Thrust Gain 8x1.5 Filter 1Hz 05112013_01.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename5, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\08_Ch8 Stbd Thrust Gain 8x1.5 Filter 1Hz 05112013_01.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename6, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\07_Ch7 Port Torque Gain 10x2 +CCW Filter 1Hz 05112013_02.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename7, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\09_Ch9 Stbd Torque Gain 10x2 +CCW Filter 1Hz 05112013_02.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename8, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\19_ch19 Inboard PST G2 F1Hz unity calibr 07112013_02.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

if exist(filename9, 'file') ~= 2
    disp('--------------------------------------------------------------------------------------------');
    disp('File ..\..\DAQ Cal Files\20_ch20 Outboard PST G2 F1Hz unity calibr 07112013_02.cal does not exist');
    disp('--------------------------------------------------------------------------------------------');
    break;
end

%# ------------------------------------------------------------------------
%# Forward LVDT Calibration - 06/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename1);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename1, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename1, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_1_Dist_Incr   = data(:,1);       % Change in LVDT distance
Raw_CH_1_FwdLVDT = data(:,2);       % Voltage change
Raw_CH_1_Slope   = data(:,3);       % Slope

FwdLVDTCalibration = data;

%# ------------------------------------------------------------------------
%# Forward LVDT Calibration - 06/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename2);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename2, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename2, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_2_Dist_Incr  = data(:,1);       % Change in LVDT distance
Raw_CH_2_AftVDT = data(:,2);       % Voltage change
Raw_CH_2_Slope  = data(:,3);       % Slope

AftLVDTCalibration = data;

%# ------------------------------------------------------------------------
%# Load Cell Calibration - 06/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename3);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename3, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename3, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_3_Mass_Incr    = data(:,1);       % Change in mass (g)
Raw_CH_3_LoadCell = data(:,2);       % Voltage change
Raw_CH_3_Slope    = data(:,3);       % Slope

LoadCellCalibration = data;

%# ------------------------------------------------------------------------
%# Port Thrust - 05/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename4);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename4, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename4, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_6_Mass_Incr      = data(:,1);       % Change in mass
Raw_CH_6_PortThrust = data(:,2);       % Voltage change
Raw_CH_6_Slope      = data(:,3);       % Slope

PortThrustCalibration = data;

%# ------------------------------------------------------------------------
%# Starboard Thrust - 05/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename5);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename5, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename5, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_8_Mass_Incr      = data(:,1);       % Change in mass
Raw_CH_8_StbdThrust = data(:,2);       % Voltage change
Raw_CH_8_Slope      = data(:,3);       % Slope

StbdThrustCalibration = data;

%# ------------------------------------------------------------------------
%# Port Torque - 05/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename6);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename6, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename6, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_7_Mass_Incr      = data(:,1);       % Change in mass
Raw_CH_7_PortTorque = data(:,2);       % Voltage change
Raw_CH_7_Slope      = data(:,3);       % Slope

PortTorqueCalibration = data;

%# ------------------------------------------------------------------------
%# Starboard Torque - 05/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename7);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename7, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename7, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_9_Mass_Incr      = data(:,1);       % Change in mass
Raw_CH_9_StbdTorque = data(:,2);       % Voltage change
Raw_CH_9_Slope      = data(:,3);       % Slope

StbdTorqueCalibration = data;

%# ------------------------------------------------------------------------
%# Inboard PST - 075/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename8);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename8, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename8, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_19_Speed_Incr = data(:,1);       % Change in speed
Raw_CH_19_Speed  = data(:,2);       % Voltage change
Raw_CH_19_Slope  = data(:,3);       % Slope

InboardPSTCalibration = data;

%# ------------------------------------------------------------------------
%# Outboard PST - 075/11/2013
%# ------------------------------------------------------------------------

[pathstr, name, ext] = fileparts(filename9);     % Get file details like path, filename and extension

%# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
zAndCFData = importdata(filename9, ' ', headerlines);
zAndCF     = zAndCFData.data;

%# Time series
AllRawChannelData = importdata(filename9, ' ', headerlines);

%# Create new variables in the base workspace from those fields.
vars = fieldnames(AllRawChannelData);
for i = 1:length(vars)
    assignin('base', vars{i}, AllRawChannelData.(vars{i}));
end

%# Columns as variables (RAW DATA)
CH_20_Speed_Incr = data(:,1);       % Change in speed
Raw_CH_20_Speed  = data(:,2);       % Voltage change
Raw_CH_20_Slope  = data(:,3);       % Slope

OutboardPSTCalibration = data;

%# ------------------------------------------------------------------------
%# END Import Calibration Files
%# ************************************************************************


%# ************************************************************************
%# Plot 1: Wave Probe Calibrations 02/09/2014 and 04/09/2014
%# ************************************************************************
figurename = 'Plot 1: LVDT Calibration';
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
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

x1 = FwdLVDTCalibration(:,2);
y1 = FwdLVDTCalibration(:,1);

% Model data - Linear fit
[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1     = coeffvalues(fitobject1);
FirstCalText = sprintf('\\bf Fwd LVDT (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues1(1)),sprintf('%.2f',cvalues1(2)),sprintf('%.1f',gof1.rsquare));

x2 = AftLVDTCalibration(:,2);
y2 = AftLVDTCalibration(:,1);

% Model data - Linear fit
[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2      = coeffvalues(fitobject2);
SecondCalText = sprintf('\\bf Aft LVDT (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues2(1)),sprintf('%.2f',cvalues2(2)),sprintf('%.1f',gof2.rsquare));

%# Plotting ---------------------------------------------------------------
% First calibration (02/09/2014) and second calibration (04/09/2014)
h1 = plot(x1,y1,'*',x2,y2,'*');
legendInfo1{1} = 'Forward LVDT';
legendInfo1{2} = 'Aft LVDT';
% Linear fit
hold on;
h2 = plot(fitobject1,'k--');
hold on;
h3 = plot(fitobject2,'k-.');
xlabel('{\bf Output (Volt)}','FontSize',setGeneralFontSize);
ylabel('{\bf Distance (mm)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf LVDT Calibration}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize-2,'LineWidth',setLineWidthMarker);
% set(h1,'marker','+');
% set(h1,'linestyle','none');

%# Annotations (i.e. custom text on plot)
text(-9,-45,FirstCalText,'FontSize',12,'color','k','FontWeight','normal');
text(-9,-55,SecondCalText,'FontSize',12,'color','k','FontWeight','normal');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = -10;
maxX  = 10;
incrX = 5;
minY  = -60;
maxY  = 60;
incrY = 20;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo1);
set(hleg1,'Location','NorthEast');
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
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Fwd_and_Aft_LVDT_Calibration_Plot.%s', 'Calibrations', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# Plot 2: Load Cell Calibration (06/11/2013)
%# ************************************************************************
figurename = 'Plot 2: Load Cell Calibration';
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
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

x1 = LoadCellCalibration(:,2);
y1 = LoadCellCalibration(:,1);

% Model data - Linear fit
[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1     = coeffvalues(fitobject1);
FirstCalText = sprintf('\\bf Load Cell (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues1(1)),sprintf('%.2f',cvalues1(2)),sprintf('%.1f',gof1.rsquare));

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'*');
legendInfo2{1} = 'Load Cell';
% Linear fit
hold on;
h2 = plot(fitobject1,'k--');
%hold on;
%h3 = plot(fitobject2,'k-.');
xlabel('{\bf Output (Volt)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass (g)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf Load Cell Calibration}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% set(h1,'marker','+');
% set(h1,'linestyle','none');

%# Annotations (i.e. custom text on plot)
text(-10.5,200,FirstCalText,'FontSize',12,'color','k','FontWeight','normal');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = -11;
maxX  = 1;
incrX = 2;
minY  = -400;
maxY  = 5200;
incrY = 800;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo2);
set(hleg1,'Location','NorthEast');
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
    plotsavename = sprintf('_plots/%s/%s/Plot_2_Load_Cell_Calibration_Plot.%s', 'Calibrations', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# Plot 3: Port and Stbd Thrust (05/09/2014)
%# ************************************************************************
figurename = 'Plot 3: Port and Stbd Thrust';
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
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

x1 = PortThrustCalibration(:,2);
y1 = PortThrustCalibration(:,1);

% Model data - Linear fit
[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1     = coeffvalues(fitobject1);
FirstCalText = sprintf('\\bf Port Thrust (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues1(1)),sprintf('%.2f',cvalues1(2)),sprintf('%.1f',gof1.rsquare));

x2 = StbdThrustCalibration(:,2);
y2 = StbdThrustCalibration(:,1);

% Model data - Linear fit
[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2      = coeffvalues(fitobject2);
SecondCalText = sprintf('\\bf Stbd Thrust (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues2(1)),sprintf('%.2f',cvalues2(2)),sprintf('%.1f',gof2.rsquare));

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'*',x2,y2,'*');
legendInfo1{1} = 'Port Thrust (Dynamometer)';
legendInfo1{2} = 'Stbd Thrust (Dynamometer)';
% Linear fit
hold on;
h2 = plot(fitobject1,'k--');
hold on;
h3 = plot(fitobject2,'k-.');
xlabel('{\bf Output (Volt)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass (g)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf Thrust Calibration}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize-2,'LineWidth',setLineWidthMarker);
% set(h1,'marker','+');
% set(h1,'linestyle','none');

%# Annotations (i.e. custom text on plot)
text(1.5,250,FirstCalText,'FontSize',12,'color','k','FontWeight','normal');
text(1.5,-250,SecondCalText,'FontSize',12,'color','k','FontWeight','normal');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = -1;
maxX  = 11;
incrX = 2;
minY  = -500;
maxY  = 6000;
incrY = 500;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo1);
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
    plotsavename = sprintf('_plots/%s/%s/Plot_3_Port_and_Stbd_Thrust_Calibration_Plot.%s', 'Calibrations', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# Plot 4: Port and Stbd Torque (05/09/2014)
%# ************************************************************************
figurename = 'Plot 4: Port and Stbd Torque';
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
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

x1 = PortTorqueCalibration(:,2);
y1 = PortTorqueCalibration(:,1);

% Model data - Linear fit
[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1     = coeffvalues(fitobject1);
FirstCalText = sprintf('\\bf Port Torque (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues1(1)),sprintf('%.2f',cvalues1(2)),sprintf('%.1f',gof1.rsquare));

x2 = StbdTorqueCalibration(:,2);
y2 = StbdTorqueCalibration(:,1);

% Model data - Linear fit
[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2      = coeffvalues(fitobject2);
SecondCalText = sprintf('\\bf Stbd Torque (EoF): \\rm y = %sx+%s, R^2=%s',sprintf('%.2f',cvalues2(1)),sprintf('%.2f',cvalues2(2)),sprintf('%.1f',gof2.rsquare));

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'*',x2,y2,'*');
legendInfo1{1} = 'Port Torque (Dynamometer)';
legendInfo1{2} = 'Stbd Torque (Dynamometer)';
% Linear fit
hold on;
h2 = plot(fitobject1,'k--');
hold on;
h3 = plot(fitobject2,'k-.');
xlabel('{\bf Output (Volt)}','FontSize',setGeneralFontSize);
ylabel('{\bf Torque (Nm)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf Torque Calibration}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize-2,'LineWidth',setLineWidthMarker);
% set(h1,'marker','+');
% set(h1,'linestyle','none');

%# Annotations (i.e. custom text on plot)
text(-8.5,-0.05,FirstCalText,'FontSize',12,'color','k','FontWeight','normal');
text(-8.5,-0.15,SecondCalText,'FontSize',12,'color','k','FontWeight','normal');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = -9;
maxX  = 1;
incrX = 2;
minY  = -0.2;
maxY  = 1.2;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo1);
set(hleg1,'Location','NorthEast');
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
    plotsavename = sprintf('_plots/%s/%s/Plot_4_Port_and_Stbd_Torque_Calibration_Plot.%s', 'Calibrations', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# Plot 5: Inboard and Outboard PST (07/09/2014)
%# ************************************************************************
figurename = 'Plot 5: Inboard and Outboard PST';
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
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

x1 = InboardPSTCalibration(:,2);
y1 = InboardPSTCalibration(:,1);

% Model data - Linear fit
[fitobject1,gof1,output1] = fit(x1,y1,'poly3');
cvalues1     = coeffvalues(fitobject1);
FirstCalText = sprintf('\\bf Inboard PST (EoF): \\rm y = %sx^3+%sx^2+%sx+%s, R^2=%s',sprintf('%.2f',cvalues1(1)),sprintf('%.2f',cvalues1(2)),sprintf('%.2f',cvalues1(3)),sprintf('%.2f',cvalues1(4)),sprintf('%.1f',gof1.rsquare));

x2 = OutboardPSTCalibration(:,2);
y2 = OutboardPSTCalibration(:,1);

% Model data - Linear fit
[fitobject2,gof2,output2] = fit(x2,y2,'poly3');
cvalues2      = coeffvalues(fitobject2);
SecondCalText = sprintf('\\bf Outboard PST (EoF): \\rm y = %sx^3+%sx^2+%sx+%s, R^2=%s',sprintf('%.2f',cvalues1(1)),sprintf('%.2f',cvalues1(2)),sprintf('%.2f',cvalues1(3)),sprintf('%.2f',cvalues1(4)),sprintf('%.1f',gof1.rsquare));

%# Plotting ---------------------------------------------------------------
h1 = plot(x1,y1,'*',x2,y2,'*');
legendInfo1{1} = 'Inboard PST';
legendInfo1{2} = 'Outboard PST';
% Linear fit
hold on;
h2 = plot(fitobject1,'k--');
hold on;
h3 = plot(fitobject2,'k-.');
xlabel('{\bf Output (Volt)}','FontSize',setGeneralFontSize);
ylabel('{\bf Speed (m/s)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf PST Calibration}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize-2,'LineWidth',setLineWidthMarker);
% set(h1,'marker','+');
% set(h1,'linestyle','none');

%# Annotations (i.e. custom text on plot)
text(0.05,-0.15,FirstCalText,'FontSize',12,'color','k','FontWeight','normal');
text(0.05,-0.35,SecondCalText,'FontSize',12,'color','k','FontWeight','normal');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 0;
maxX  = 3;
incrX = 0.5;
minY  = -0.5;
maxY  = 3.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo1);
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
    plotsavename = sprintf('_plots/%s/%s/Plot_5_Inboard_and_Outboard_PST_Calibration_Plot.%s', 'Calibrations', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;
