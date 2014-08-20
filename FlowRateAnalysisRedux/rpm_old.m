%# -------------------------------------------------------------------------
%# RPM Analysis
%# -------------------------------------------------------------------------
%# -------------------------------------------------------------------------
%# CHANGES:   19/06/2013 - Created file
%#            dd/mm/yyyy - ...
%# -------------------------------------------------------------------------

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

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
%profile on

%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 29;  % Number of headerlines to data
headerlinesZeroAndCalib = 23;  % Number of headerlines to zero and calibration factors


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

startRun = 30;      % Start at run x
endRun   = 30;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArray = [];
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
    
    %# Columns as variables (RAW DATA)
    timeData             = data(:,1);       % Timeline
    Raw_CH_5_RPMStbd     = data(:,7);       % RPM stbd data
    Raw_CH_6_RPMPort     = data(:,8);       % RPM port data
    
    %# Stard and end of sample no. to be shown
    startData   = 8000;     % Start for plotting
    endData     = 8800;     % End for plotting
    
    %# All data variables
    omitaccsamples = 8000;	% 10 seconds x sample frequency = 10 x 800 = 8000 samples
    t   = timeData(omitaccsamples:end);
    y1  = Raw_CH_5_RPMStbd(omitaccsamples:end);
    y2  = Raw_CH_6_RPMPort(omitaccsamples:end);
    
    %# Plot only variables
    tplot  = timeData(startData:endData);           % Plotting shows only 1 second
    y1plot = Raw_CH_5_RPMStbd(startData:endData);   % Plotting shows only 1 second
    y2plot = Raw_CH_6_RPMPort(startData:endData);   % Plotting shows only 1 second
    
    %# All data PEAK identification
    [maxtab1, mintab1]   = peakdet(y1, 0.5, t);   % STBD all data stream
    [maxtab2, mintab2]   = peakdet(y2, 0.5, t);   % PORT all data stream

    %# Plot only PEAK identification
    [maxtab11, mintab11] = peakdet(y1plot, 0.5, tplot);   % STBD plot stream
    [maxtab22, mintab22] = peakdet(y2plot, 0.5, tplot);   % PORT plot stream    
    
    %# Total data time in seconds
    time    = length(timeData)/800;
    
    %# STBD and PORT RPM values
    rpmStbd = length(mintab1) / (time/60);
    rpmPort = length(mintab2) / (time/60);
    
    %# resultsArray columns: 
        %[1]  Run No.
        %[2]  STBD RPM
        %[3]  PORT RPM
        %[4]  STBD RPM ROUNDED
        %[5]  PORT RPM ROUNDED
    resultsArray(k, 1) = k;     
    resultsArray(k, 2) = str2double(sprintf('%.2f',rpmStbd));
    resultsArray(k, 3) = str2double(sprintf('%.2f',rpmPort));
    resultsArray(k, 4) = round(rpmStbd);
    resultsArray(k, 5) = round(rpmPort);
    
    %# Plotting curves
    figurename = sprintf('RPM Data: %s', name);
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# STARBOARD RPM DATA
    subplot(2,1,1); 
    plot(tplot,y1plot,'-k');
        
    if length(mintab11) > 0 && length(maxtab11) > 0
        hold on;
        plot(maxtab11(:,1),maxtab11(:,2),'r*',mintab11(:,1),mintab11(:,2),'g*');
        hleg1 = legend('Raw data','Max peaks','Min peaks');
    else
        hleg1 = legend('Raw data');        
    end
    
    set(hleg1,'Location','SouthEast');
    set(hleg1,'Interpreter','none');      
    xlabel('Time [s]');
    ylabel('Output [V]');
    title('{\bf STARBOARD RPM Data}');
    xlim([startData/800 endData/800]);
    grid on;
  
    %# PORT RPM DATA
    subplot(2,1,2); 
    plot(tplot,y2plot,'-k');
    
    if length(mintab22) > 0 && length(maxtab22) > 0
        hold on;
        plot(maxtab22(:,1),maxtab22(:,2),'r*',mintab22(:,1),mintab22(:,2),'g*');
        hleg1 = legend('Raw data','Max peaks','Min peaks');   
    else
        hleg1 = legend('Raw data');      
    end
    
    set(hleg1,'Location','SouthEast');
    set(hleg1,'Interpreter','none');   
    xlabel('Time [s]');
    ylabel('Output [V]');
    title('{\bf PORT RPM Data}');
    xlim([startData/800 endData/800]);
    grid on;  
    
    %# Save plots as PNGs
%     fPath = sprintf('_plots/%s', name);
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else    
%         mkdir(fPath);
%     end
    plotsavename = sprintf('_plots/%s_CH5_CH6_PEAKS_rpm_stbd_and_port.png', name);  % Assign save name
    print(gcf, '-djpeg', plotsavename);                                             % Save plot to _plots
    %close;
 
    %# Display RPM values
    disp(sprintf('%s:: STBD = %s RPM // PORT = %s RPM', name, num2str(round(rpmStbd)),num2str(round(rpmPort))));
    
end

% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

csvwrite('rpmArray.dat',resultsArray)

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////