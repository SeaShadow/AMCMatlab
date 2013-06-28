%# ------------------------------------------------------------------------
%# function [RPMStbd RPMPort] = analysis_rpm( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         June 20, 2013
%# 
%# Function   :  Analyse
%# 
%# Description:  Analyse voltage output of inductive proximity sensors
%#               and convert to RPM using peak values.
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

%# ------------------------------------------------------------------------
%# Establish RPM values ---------------------------------------------------
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

%# ####################################################################
%# STARBOARD RPM CALCULATION BASED ON PEAKS ###########################
%# ####################################################################
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

%# ####################################################################
%# PORT RPM CALCULATION BASED ON PEAKS ################################
%# ####################################################################
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
%# Plotting curves --------------------------------------------------------
%# ------------------------------------------------------------------------

figurename = sprintf('RPM Data: Run %s', name(2:3));
f = figure('Name',figurename,'NumberTitle','off');

%# PLOT: STARBOARD RPM DATA -----------------------------------------------
subplot(2,1,1);
if length(mintabstbd) > 0 && length(maxtabstbd) > 0
    plot(t1plot,y1plot,'-k');
    hold on;
    plot(mintabstbdplot(:,1),mintabstbdplot(:,2),'mo',...
            'LineWidth',2,...
            'MarkerEdgeColor','r',...
            'MarkerSize',8);
    hleg1 = legend('Raw data','Peak');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none'); 
    xlim([startpeakstbd/800 (startpeakstbd+Fs)/800]);
else
    plot(t(8000:end),y1(8000:end),'-k');   
    xlim([omitaccsamples/800 (omitaccsamples+800)/800]);      
end

xlabel('{\bf Time [s]}');
ylabel('{\bf Output [V]}');
title('{\bf STARBOARD RPM Data}');
grid on;

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');  

%# PLOT: PORT RPM DATA ----------------------------------------------------
subplot(2,1,2);
if length(mintabport) > 0 && length(mintabport) > 0 
    plot(t2plot,y2plot,'-k');
    hold on;
    plot(mintabportplot(:,1),mintabportplot(:,2),'mo',...
            'LineWidth',2,...
            'MarkerEdgeColor','r',...
            'MarkerSize',8);
    hleg1 = legend('Raw data','Peak');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');     
    xlim([startpeakport/800 (startpeakport+Fs)/800]);
else
    plot(t(8000:end),y2(8000:end),'-k');   
    xlim([omitaccsamples/800 (omitaccsamples+800)/800]);  
end

xlabel('{\bf Time [s]}');
ylabel('{\bf Output [V]}');
title('{\bf PORT RPM Data}');
grid on;  

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');  

%# ------------------------------------------------------------------------
%# Save plots as PDF and PNG ----------------------------------------------
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end    

%# RUN directory
fPath = sprintf('_plots/%s', name(1:3));
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end

%plotsavenamePDF = sprintf('_plots/%s/RPM_CH5_CH6_PEAKS_Stbd_and_Port.pdf', name(1:3));
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/%s/RPM_CH5_CH6_PEAKS_Stbd_and_Port.png', name(1:3)); % Assign save name
print(gcf, '-djpeg', plotsavename);                                                 % Save plot as PNG
close;                                                                              % Close current plot window