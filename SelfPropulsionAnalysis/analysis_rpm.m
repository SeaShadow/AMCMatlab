%# ------------------------------------------------------------------------
%# function [RPMStbd RPMPort] = analysis_rpm( input )
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  January 8, 2015
%#
%# Function   :  Analyse inductive proximity sensor data
%#
%# Description:  Analyse voltage output of inductive proximity sensors
%#               and convert to RPM using peak values.
%#
%# Definition:   Port and ptarboard are defined as seen from stern of vessel.
%#
%# Parameters :  k           = Run number
%#               name        = Run file name (e.g. R12-02_moving)
%#               Fs          = Sample rate in Hz
%#               timeData    = Time series data
%#               rawStbdData = STARBOARD RPM data
%#               rawPortData = PORT RPM data
%#
%# Return     :  RPMStbd     = (int) Rounded starboard RPM value
%#               RPMPort     = (int) Rounded port RPM value
%#
%# Examples of Usage:
%#
%#    >> k           = 1;
%#    >> name        = 'R09';
%#    >> Fs          = 800;
%#    >> rawData     = [ 1 2 3 4 5 6 7 8 9 10 ];
%#    >> rawStbdData = [ 5 6 7 8 9 10 11 12 13 14 ];
%#    >> rawPortData = [ 5 6 7 8 9 10 11 12 13 14 ];
%#    >> [ans1 ans2] = analysis_rpm(k,name,Fs,timeData,rawStbdData,rawPortData)
%#    ans1 =
%#           499
%#    ans2 =
%#           500
%#
%# ------------------------------------------------------------------------

function [RPMStbd RPMPort] = analysis_rpm(k,name,Fs,timeData,rawStbdData,rawPortData)

%# ************************************************************************
%# START: PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle     = 1;    % Show plot title in saved file
enablePlotTitle         = 1;    % Show plot title above plot

% Scaled to A4 paper
enableA4PaperSizePlot   = 1;    % Show plots scale to A4 size

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************

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

%# ------------------------------------------------------------------------
%# Save plots as PDF and PNG
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# RUN directory
fPath = sprintf('_plots/%s', 'RPM');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# ESTABLISH RPM VALUES
%# ------------------------------------------------------------------------

RPMStbd = 0;    % Default Starboard RPM value
RPMPort = 0;    % Default Port RPM value

%# All data variables
omitaccsamples = 8000;	% 10 seconds x sample frequency = 10 x 800 = 8000 samples
t   = timeData(omitaccsamples:end);
y1  = rawStbdData(omitaccsamples:end);
y2  = rawPortData(omitaccsamples:end);

%# All data PEAK identification
[maxtabstbd, mintabstbd] = peakdet(y1, 0.5, t);     % STBD all data stream
[maxtabport, mintabport] = peakdet(y2, 0.5, t);     % PORT all data stream

%# ------------------------------------------------------------------------
%# STARBOARD RPM CALCULATION BASED ON PEAKS
%# ------------------------------------------------------------------------
if length(mintabstbd) > 0 && length(maxtabstbd) > 0
    
    %# Create variable for first and last min peak (in terms of sample numbers)
    %# NOTE: +2/-2 is necessary to allow for correct first and last peak identification!!!
    startpeakstbd = round(mintabstbd(1) * Fs)-2;
    endpeakstbd   = round(mintabstbd(length(mintabstbd)) * Fs)+2;
    
    %# Get data so that first peak at start and last at end of time series
    t1 = timeData(startpeakstbd:endpeakstbd);
    y1 = rawStbdData(startpeakstbd:endpeakstbd);
    
    %# Plot only variables
    t1plot = timeData(startpeakstbd:(startpeakstbd+Fs));                % Plotting shows only 1 second
    y1plot = rawStbdData(startpeakstbd:(startpeakstbd+Fs));        % Plotting shows only 1 second
    
    %# Plot only PEAK identification
    [maxtabstbdplot, mintabstbdplot] = peakdet(y1plot, 0.5, t1plot);    % STBD plot stream
    
    %# Total data time in seconds
    timestbd = length(t1)/800;
    
    %# STBD RPM values
    RPMStbd = round(length(mintabstbd) / (timestbd/60));
    
end

%# ------------------------------------------------------------------------
%# PORT RPM CALCULATION BASED ON PEAKS
%# ------------------------------------------------------------------------
if length(mintabport) > 0 && length(mintabport) > 0
    
    %# Create variable for first and last min peak (in terms of sample numbers)
    %# NOTE: +2/-2 is necessary to allow for correct first and last peak identification!!!
    startpeakport = round(mintabport(1) * Fs)-2;
    endpeakport   = round(mintabport(length(mintabport)) * Fs)+2;
    
    %# Get data so that first peak at start and last at end of time series
    t2 = timeData(startpeakport:endpeakport);
    y2 = rawPortData(startpeakport:endpeakport);
    
    %# Plot only variables
    t2plot = timeData(startpeakport:(startpeakport+Fs));                % Plotting shows only 1 second
    y2plot = rawPortData(startpeakport:(startpeakport+Fs));        % Plotting shows only 1 second
    
    %# Plot only PEAK identification
    [maxtabportplot, mintabportplot] = peakdet(y2plot, 0.5, t2plot);    % PORT plot stream
    
    %# Total data time in seconds
    timeport = length(t2)/800;
    
    %# PORT RPM values
    RPMPort = round(length(mintabport) / (timeport/60));
    
end

%# ------------------------------------------------------------------------
%# Plotting curves
%# ------------------------------------------------------------------------

% Change from 2 to 3 digits
if k > 99
    name = name(2:4);
else
    name = name(2:3);
end

% Plotting
figurename = sprintf('Run %s: Inductive Proximity Sensor Data', name);
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
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};

%# Line, colors and markers
setMarkerSize      = 10;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineStyle       = '-';

%# PLOT: STARBOARD RPM DATA -----------------------------------------------
subplot(2,1,1);
if length(mintabstbd) > 0 && length(maxtabstbd) > 0
    % Plotting
    h1 = plot(t1plot,y1plot,'-');
    hold on;
    h2 = plot(mintabstbdplot(:,1),mintabstbdplot(:,2),'o',...
        'LineWidth',2,...
        'MarkerEdgeColor','r',...
        'MarkerSize',8);
    
    %# Line, colors and markers
    set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h2(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'MarkerFaceColor',setColor{1}
    
    %# Legend
    hleg1 = legend('Raw data','Peak');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    
    %# Axis limitations
    xlim([startpeakstbd/800 (startpeakstbd+Fs)/800]);
else
    % Plotting
    h1 = plot(t(8000:end),y1(8000:end),'-k');
    
    %# Line, colors and markers
    set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    %# Axis limitations
    xlim([omitaccsamples/800 (omitaccsamples+800)/800]);
end
xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
ylabel('{\bf Output [V]}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf STBD Propulsion System}','FontSize',setGeneralFontSize);
end
grid on;
%axis square;

%# Axis limitations
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# PLOT: PORT RPM DATA ----------------------------------------------------
subplot(2,1,2);
if length(mintabport) > 0 && length(mintabport) > 0
    % Plotting
    h1 = plot(t2plot,y2plot,'-');
    hold on;
    h2 = plot(mintabportplot(:,1),mintabportplot(:,2),'o',...
        'LineWidth',2,...
        'MarkerEdgeColor','r',...
        'MarkerSize',8);
    
    %# Line, colors and markers
    set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h2(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'MarkerFaceColor',setColor{1}
    
    %# Legend
    hleg1 = legend('Raw data','Peak');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    
    %# Axis limitations
    xlim([startpeakport/800 (startpeakport+Fs)/800]);
else
    % Plotting
    h1 = plot(t(8000:end),y2(8000:end),'-k');
    
    %# Line, colors and markers
    set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    %# Axis limitations
    xlim([omitaccsamples/800 (omitaccsamples+800)/800]);
end
xlabel('{\bf Time [s]}','FontSize',setGeneralFontSize);
ylabel('{\bf Output [V]}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf PORT Propulsion System}','FontSize',setGeneralFontSize);
end
grid on;
%axis square;

%# Axis limitations
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

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
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%plotsavenamePDF = sprintf('_plots/RPM/Run_%s_Stbd_and_Port_RPM_Plot.png', pdf); % Assign save name
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/RPM/Run_%s_Stbd_and_Port_RPM_Plot.png', name); % Assign save name
print(gcf, '-djpeg', plotsavename);                                                 % Save plot as PNG
close;                                                                              % Close current plot window
