%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Time Series Investigation, Statistics
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 11, 2014
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Repeated flow rate measurement test for validation and
%#               uncertainty analysis reasons.
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  11/11/2014 - File creation
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
%# START PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle         = 1;    % Show plot title in saved file
enablePlotTitle             = 1;    % Show plot title above plot
enableBlackAndWhitePlot     = 0;    % Show plot in black and white only

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

%# ------------------------------------------------------------------------
%# END PLOT SWITCHES
%# ************************************************************************

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
%profile on

%# ------------------------------------------------------------------------
%# Path where run directories are located
%# ------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# ------------------------------------------------------------------------
%# GENERAL SETTINGS
%# ------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# ------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# ------------------------------------------------------------------------
headerlines             = 27;  % Number of headerlines to data
headerlinesZeroAndCalib = 21;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 8000;
%startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 8000;
%cutSamplesFromEnd = 0;

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% startRun = 27;      % Start at run x
% endRun   = 29;      % Stop at run y

startRun = 1;       % Start at run x
endRun   = 67;      % Stop at run y

startRun = 8;       % Start at run x
endRun   = 8;       % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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


%# ************************************************************************
%# START CREATE PLOTS AND RUN DIRECTORY
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _time_series_data directory --------------------------------------------
% fPath = '_plots/_time_series_data/';
% if isequal(exist(fPath, 'dir'),7)
%     % Do nothing as directory exists
% else
%     mkdir(fPath);
% end

%# _wave_probe directory --------------------------------------------------
setDirName = '_plots/_time_series';

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
%# END CREATE PLOTS AND RUN DIRECTORY
%# ************************************************************************


%# ************************************************************************
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ************************************************************************

%# Run distinctions
TestRunArray = [1:7];
PortRunArray = [8:37];
StbdRunArray = [38:67];

%# Loop runs
cfArray = [];
for k=startRun:endRun
    
    %# Allow for 1 to become 01 for run numbers
    if k < 10
        filename = sprintf('%s0%s.run\\R0%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    else
        filename = sprintf('%s%s.run\\R%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    end
    [pathstr, name, ext] = fileparts(filename);     % Get file details like path, filename and extension
    
    %# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
    zAndCFData = importdata(filename, ' ', headerlines);
    zAndCF     = zAndCFData.data;
    
    %# Calibration factors and zeros
    ZeroAndCalibData = importdata(filename, ' ', headerlinesZeroAndCalib);
    ZeroAndCalib     = ZeroAndCalibData.data;
    
    %# Time series
    AllRawChannelData = importdata(filename, ' ', headerlines);
    
    %# Create new variables in the base workspace from those fields.
    vars = fieldnames(AllRawChannelData);
    for i = 1:length(vars)
        assignin('base', vars{i}, AllRawChannelData.(vars{i}));
    end
    
    %# ********************************************************************
    %# START Columns as variables (RAW DATA)
    %# --------------------------------------------------------------------
    
    timeData             = data(:,1);       % Timeline
    Raw_CH_0_WaveProbe   = data(:,2);       % Wave probe data
    Raw_CH_1_KPStbd      = data(:,3);       % Kiel probe stbd data
    Raw_CH_2_KPPort      = data(:,4);       % Kiel probe port data
    %Raw_CH_3_StaticStbd  = data(:,5);       % Static stbd data
    %Raw_CH_4_StaticPort  = data(:,6);       % Static port data
    Raw_CH_5_RPMStbd     = data(:,5);       % RPM stbd data
    Raw_CH_6_RPMPort     = data(:,6);       % RPM port data
    Raw_CH_7_ThrustStbd  = data(:,7);       % Thrust stbd data
    Raw_CH_8_ThrustPort  = data(:,8);       % Thrust port data
    Raw_CH_9_TorqueStbd  = data(:,9);       % Torque stbd data
    Raw_CH_10_TorquePort = data(:,10);      % Torque port data
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
    %CH_0_CF    = 46.001;                % Custom calibration factor
    CH_1_Zero  = ZeroAndCalib(5);
    CH_1_CF    = ZeroAndCalib(6);
    CH_2_Zero  = ZeroAndCalib(7);
    CH_2_CF    = ZeroAndCalib(8);
    %CH_3_Zero  = ZeroAndCalib(9);
    %CH_3_CF    = ZeroAndCalib(10);
    %CH_4_Zero  = ZeroAndCalib(11);
    %CH_4_CF    = ZeroAndCalib(12);
    CH_5_Zero  = ZeroAndCalib(9);
    CH_5_CF    = ZeroAndCalib(10);
    CH_6_Zero  = ZeroAndCalib(11);
    CH_6_CF    = ZeroAndCalib(12);
    CH_7_Zero  = ZeroAndCalib(13);
    CH_7_CF    = ZeroAndCalib(14);
    CH_8_Zero  = ZeroAndCalib(15);
    CH_8_CF    = ZeroAndCalib(16);
    CH_9_Zero  = ZeroAndCalib(17);
    CH_9_CF    = ZeroAndCalib(18);
    CH_10_Zero = ZeroAndCalib(19);
    CH_10_CF   = ZeroAndCalib(20);
    
    %# --------------------------------------------------------------------
    %# END Columns as variables (RAW DATA)
    %# ********************************************************************
    
    
    %# ********************************************************************
    %# START Columns as variables (REAL UNITS)
    %# --------------------------------------------------------------------
    
    timeDataShort                            = timeData(startSamplePos:end-cutSamplesFromEnd);
    
    %# Wave probe
    [CH_0_WaveProbe CH_0_WaveProbe_Mean]     = analysis_realunits(Raw_CH_0_WaveProbe,CH_0_Zero,CH_0_CF);
    %
    %     %# DPT with kiel probe
    %     CH_1_KPStbd                              = Raw_CH_1_KPStbd;   % 5 PSI DPT
    %     CH_2_KPPort                              = Raw_CH_2_KPPort;   % 5 PSI DPT
    %
    %     %# Dynamometer: Thrust
    %     [CH_7_ThrustStbd CH_7_ThrustStbd_Mean]   = analysis_realunits(Raw_CH_7_ThrustStbd,CH_7_Zero,CH_7_CF);
    %     [CH_8_ThrustPort CH_8_ThrustPort_Mean]   = analysis_realunits(Raw_CH_8_ThrustPort,CH_8_Zero,CH_8_CF);
    %
    %     %# Dynamometer: Torque
    %     [CH_9_TorqueStbd CH_9_TorqueStbd_Mean]   = analysis_realunits(Raw_CH_9_TorqueStbd,CH_9_Zero,CH_9_CF);
    %     [CH_10_TorquePort CH_10_TorquePort_Mean] = analysis_realunits(Raw_CH_10_TorquePort,CH_10_Zero,CH_10_CF);
    %
    %     %[RPMStbd RPMPort]                        = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);
    %
    %     %# Cut first X and last X seconds from data
    %     WaveProbe                                = CH_0_WaveProbe(startSamplePos:end-cutSamplesFromEnd);
    %     KPStbd                                   = CH_1_KPStbd(startSamplePos:end-cutSamplesFromEnd);
    %     KPPort                                   = CH_2_KPPort(startSamplePos:end-cutSamplesFromEnd);
    %     ThrustStbd                               = CH_7_ThrustStbd(startSamplePos:end-cutSamplesFromEnd);
    %     ThrustPort                               = abs(CH_8_ThrustPort(startSamplePos:end-cutSamplesFromEnd));
    %     TorqueStbd                               = CH_9_TorqueStbd(startSamplePos:end-cutSamplesFromEnd);
    %     TorquePort                               = abs(CH_10_TorquePort(startSamplePos:end-cutSamplesFromEnd));
    
    %# --------------------------------------------------------------------
    %# END Columns as variables (REAL UNITS)
    %# ********************************************************************
    
    
    %# ********************************************************************
    %# START Time Series Objects
    %# --------------------------------------------------------------------
    
    % Time Series
    tsvo = timeseries(Raw_CH_0_WaveProbe,timeData,'name','WPVoltage');
    tsru = timeseries(CH_0_WaveProbe,timeData,'name','WPRealUnits');
    
    disp('*************************************************');
    disp(sprintf('Run %s; Descriptive Statistics',num2str(k)));
    disp('*************************************************');
    disp('-------------------------------------------------');
    disp('Time Series (Voltage) Descriptive Statistics ');
    disp('-------------------------------------------------');
    vo_max    = max(tsvo);
    vo_mean   = mean(tsvo);
    vo_median = median(tsvo);
    vo_min    = min(tsvo);
    vo_std    = std(tsvo);
    vo_sum    = sum(tsvo);
    vo_var    = var(tsvo);
    disp(sprintf('max    = %s',num2str(vo_max)));
    disp(sprintf('mean   = %s',num2str(vo_mean)));
    disp(sprintf('median = %s',num2str(vo_median)));
    disp(sprintf('min    = %s',num2str(vo_min)));
    disp(sprintf('std    = %s',num2str(vo_std)));
    disp(sprintf('sum    = %s',num2str(vo_sum)));
    disp(sprintf('var    = %s',num2str(vo_var)));
    disp('-------------------------------------------------');
    disp('Time Series (Real units) Descriptive Statistics ');
    disp('-------------------------------------------------');
    ru_max    = max(tsru);
    ru_mean   = mean(tsru);
    ru_median = median(tsru);
    ru_min    = min(tsru);
    ru_std    = std(tsru);
    ru_sum    = sum(tsru);
    ru_var    = var(tsru);
    disp(sprintf('max    = %s',num2str(ru_max)));
    disp(sprintf('mean   = %s',num2str(ru_mean)));
    disp(sprintf('median = %s',num2str(ru_median)));
    disp(sprintf('min    = %s',num2str(ru_min)));
    disp(sprintf('std    = %s',num2str(ru_std)));
    disp(sprintf('sum    = %s',num2str(ru_sum)));
    disp(sprintf('var    = %s',num2str(ru_var)));
    
    % Time Series Collection (arrays have to be of the same length!)
    tsc = tscollection({tsvo tsru},'name', 'count_coll');
    
    %# Plotting -----------------------------------------------------------
    figurename = sprintf('Wave probe: Run %s, Wave Probe Time Series', num2str(k));
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
    setGeneralFontName  = 'Helvetica';
    setGeneralFontSize  = 14;
    setBorderLineWidth  = 2;
    setLegendFontSize   = 12;
    setPlotTextFontSize = 12;
    
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
    
    %# Markes and colors --------------------------------------------------
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
    setLineWidth1      = 1;
    setLineWidth2      = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# Voltage plotting ***************************************************
    subplot(1,2,1);
    
    %# X and Y axis -------------------------------------------------------
    
    x = tsvo.time;
    y = tsvo.data;
    
    %# Plotting -----------------------------------------------------------
    h = plot(tsc.WPVoltage,'-',x,y-detrend(y),'-');
    if enablePlotTitle == 1
        title('{\bf Voltage}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Output [V]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line width
    set(h(1),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth1);
    set(h(2),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth2);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = round(timeData(1));
    maxX  = round(timeData(end));
    incrX = 20;
    minY  = vo_min;
    maxY  = vo_max;
    incrY = 0.5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

    %# Legend
    hleg1 = legend('Wave probe output','Trendline');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    %set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Real units plotting ************************************************
    subplot(1,2,2);
    
    %# X and Y axis -------------------------------------------------------
    
    x = tsru.time;
    y = tsru.data;
    
    %# Plotting -----------------------------------------------------------
    h = plot(tsc.WPRealUnits,'-',x,y-detrend(y),'-');
    if enablePlotTitle == 1
        title('{\bf Real Units}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Output [Kg]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line width
    set(h(1),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth1);
    set(h(2),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth2);    
    
    %# Axis limitations
    minX  = round(timeData(1));
    maxX  = round(timeData(end));
    incrX = 20;
    minY  = round(ru_min);
    maxY  = round(ru_max);
    incrY = 20;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

    %# Legend
    hleg1 = legend('Wave probe output','Trendline');
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
    for kl=1:3
        plotsavename = sprintf('_plots/%s/%s/Run_%s_Wave_Probe_Time_Series_Stats_Plot.%s', '_time_series', setFileFormat{kl}, num2str(k), setFileFormat{kl});
        print(gcf, setSaveFormat{kl}, plotsavename);
    end
    %close;
    
    
    %# Plotting -----------------------------------------------------------
    figurename = sprintf('Wave probe: Run %s, Compute Mean of each 1-Second Interval of Time Series', num2str(k));
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
    setGeneralFontName  = 'Helvetica';
    setGeneralFontSize  = 14;
    setBorderLineWidth  = 2;
    setLegendFontSize   = 12;
    setPlotTextFontSize = 12;
    
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
    
    %# Markes and colors --------------------------------------------------
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
    setLineWidth1      = 1;
    setLineWidth2      = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# Voltage error bars plotting ****************************************
    subplot(1,2,1);
    
    %# X and Y axis -------------------------------------------------------
    
    x = tsvo.time;
    y = tsvo.data;
    t = x;
    x = y;
    
    % Compute mean of each 1-minute interval of a time-series
    % See: http://stackoverflow.com/questions/2323031/matlab-compute-mean-of-each-1-minute-interval-of-a-time-series
    % Parametric interval (window_size)
    window_size = 1;

    int = 1 + floor((t - t(1))/window_size);
    tt = ( floor(t(1)):window_size:ceil(t(end)) )';
    
    % Mean val and std dev of the accelerations at speed
    mu = accumarray(int,x,[],@mean);
    sd = accumarray(int,x,[],@std);
    
    % Resolving some issue with sizes (for i.e. window_size = 1 in stead of 60)
    while ( sum(size(tt) > size(mu)) > 0 )
        tt(end)=[];
    end

    %# Plotting -----------------------------------------------------------    
    h = errorbar(tt,mu,sd,'r');
    hold on;
    h = plot(tt,mu,'-b','linewidth',2);
    if enablePlotTitle == 1
        title('{\bf Voltage}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Output [V]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Axis limitations
    minX  = round(timeData(1));
    maxX  = round(timeData(end));
    incrX = 20;
    minY  = vo_min;
    maxY  = vo_max;
    incrY = 0.5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));    
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);    
    
    %# Real units error bars plotting *************************************
    subplot(1,2,2);
    
    %# X and Y axis -------------------------------------------------------
    
    x = tsru.time;
    y = tsru.data;
    t = x;
    x = y;
    
    % Compute mean of each 1-minute interval of a time-series
    % See: http://stackoverflow.com/questions/2323031/matlab-compute-mean-of-each-1-minute-interval-of-a-time-series
    % Parametric interval (window_size)
    window_size = 2;

    int = 1 + floor((t - t(1))/window_size);
    tt = ( floor(t(1)):window_size:ceil(t(end)) )';
    
    % Mean val and std dev of the accelerations at speed
    mu = accumarray(int,x,[],@mean);
    sd = accumarray(int,x,[],@std);
    
    % Resolving some issue with sizes (for i.e. window_size = 1 in stead of 60)
    while ( sum(size(tt) > size(mu)) > 0 )
        tt(end)=[];
    end

    %# Plotting -----------------------------------------------------------    
    h = errorbar(tt,mu,sd,'r');
    hold on;
    h = plot(tt,mu,'-b','linewidth',2);
    if enablePlotTitle == 1
        title('{\bf Real Units}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
    ylabel('{\bf Output [Kg]}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;   
    
    %# Axis limitations
    minX  = round(timeData(1));
    maxX  = round(timeData(end));
    incrX = 20;
    minY  = round(ru_min);
    maxY  = round(ru_max);
    incrY = 20;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));    
    
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
    for kl=1:3
        plotsavename = sprintf('_plots/%s/%s/Run_%s_Wave_Probe_Time_Series_Stats_Error_Plot.%s', '_time_series', setFileFormat{kl}, num2str(k), setFileFormat{kl});
        print(gcf, setSaveFormat{kl}, plotsavename);
    end
    %close;    
    
    %# --------------------------------------------------------------------
    %# END Time Series Objects
    %# ********************************************************************
    
end

% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
