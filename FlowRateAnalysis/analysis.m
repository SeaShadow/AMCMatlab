%# ------------------------------------------------------------------------
%# Flow Rate Analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 18, 2014
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  Analyse flow rate measurement data and save results as
%#               array and DAT file for further analysis.
%#
%# ------------------------------------------------------------------------
%#
%# SCRIPTS  :    => analysis.m                Real units, save date to result array
%#
%#               ==> Copy data from resultsArray.dat to resultsArray_copy.dat
%#
%#               => analysis_compare.m        Compare repeats of repeated runs and plot data
%#                                            NOTE: Time plots of repeats
%#
%#               => analysis_curvefit.m       Curve fitting and error estimate
%#                                            NOTE: Creates cfArray.dat showing curve fitting data
%#
%#               => analysis_fft.m            Fast Fourier Transform (FFT)
%#                                            NOTE: Created FFT plots for all channels
%#
%#               => analysis_plot.m           Plotting V vs. Q
%#                                            NOTE: Plot data directly from resultsArray
%#
%#               => analysis_stats.m          Averaged plots V vs. Q
%#                                            NOTE: Create averaged flow rate plots
%#
%#               => analysis_statistics.m     Statistics
%#                                            NOTE: Creates statisticsArray.dat which includes STDEV, etc.
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  11/06/2013 - Removed RPM results due to 2007 Matlab version
%#               17/06/2013 - Added switches for plotting and RPM results
%#               20/06/2013 - Removed Excel related code, save as DAT file
%#               28/06/2013 - Added tab delimeted saving for plotting
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
headerlines             = 29;  % Number of headerlines to data
headerlinesZeroAndCalib = 23;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 8000;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 8000;   

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

startRun = 9;      % Start at run x
endRun   = 9;      % Stop at run y

%startRun = 1;      % Start at run x
%endRun   = 86;      % Stop at run y

%startRun = 1;      % Start at run x
%endRun   = 86;      % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS
%# ------------------------------------------------------------------------

% RunNosTest = [1:8];          % Prelimnary testing only
% RunNosPort = [9:29 59:63];   % Port propulsion system only
% RunNosComb = [30:50 55:58];  % Combined propulsion systems
% RunNosStbd = [64:86];        % Starboard propulsion system only
% RunNosStat = [51:53];        % Static flow rates due to head difference of waterlevels of basin and bucket

% NOTE: If statement bellow is for use in LOOPS only!!!!
%
% if any(RunNosTest==k)
%     disp('TEST');
% elseif any(RunNosPort==k)
%     disp('PORT');
% elseif any(RunNosComb==k)
%     disp('COMBINED');    
% elseif any(RunNosStbd==k)
%     disp('STBD');    
% elseif any(RunNosStat==k)
%     disp('STATIC');    
% else
%     disp('OTHER');        
% end

%# ------------------------------------------------------------------------
%# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# PLOTTING & SAVING SWITCH
%# ------------------------------------------------------------------------

plotting_on = 1;    %TRUE (1) or FALSE (0)

%# ------------------------------------------------------------------------
%# PLOTTING & SAVING SWITCH
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArray = [];
slopesArray  = [];
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
    Raw_CH_0_WaveProbe   = data(:,2);       % Wave probe data
    Raw_CH_1_KPStbd      = data(:,3);       % Kiel probe stbd data
    Raw_CH_2_KPPort      = data(:,4);       % Kiel probe port data
    Raw_CH_3_StaticStbd  = data(:,5);       % Static stbd data
    Raw_CH_4_StaticPort  = data(:,6);       % Static port data
    Raw_CH_5_RPMStbd     = data(:,7);       % RPM stbd data
    Raw_CH_6_RPMPort     = data(:,8);       % RPM port data
    Raw_CH_7_ThrustStbd  = data(:,9);       % Thrust stbd data
    Raw_CH_8_ThrustPort  = data(:,10);      % Thrust port data
    Raw_CH_9_TorqueStbd  = data(:,11);      % Torque stbd data
    Raw_CH_10_TorquePort = data(:,12);      % Torque port data
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    %CH_0_CF    = ZeroAndCalib(4);
    CH_0_CF    = 46.001;                % Custom calibration factor
    CH_1_Zero  = ZeroAndCalib(5);
    CH_1_CF    = ZeroAndCalib(6);
    CH_2_Zero  = ZeroAndCalib(7);
    CH_2_CF    = ZeroAndCalib(8);
    CH_3_Zero  = ZeroAndCalib(9);
    CH_3_CF    = ZeroAndCalib(10);
    CH_4_Zero  = ZeroAndCalib(11);
    CH_4_CF    = ZeroAndCalib(12);
    CH_5_Zero  = ZeroAndCalib(13);
    CH_5_CF    = ZeroAndCalib(14);
    CH_6_Zero  = ZeroAndCalib(15);
    CH_6_CF    = ZeroAndCalib(16);
    CH_7_Zero  = ZeroAndCalib(17);
    CH_7_CF    = ZeroAndCalib(18);
    CH_8_Zero  = ZeroAndCalib(19);
    CH_8_CF    = ZeroAndCalib(20);
    CH_9_Zero  = ZeroAndCalib(21);
    CH_9_CF    = ZeroAndCalib(22);
    CH_10_Zero = ZeroAndCalib(23);
    CH_10_CF   = ZeroAndCalib(24);
   
    
    %# --------------------------------------------------------------------
    %# Exception case for cutting samples when sample length is only 20 seconds
    %# --------------------------------------------------------------------
    if k == 5 || k == 6 || k == 7 || k == 8
        %# 2 seconds x sample frequency = 2 x 800 = 1600 samples
        startSamplePos    = 1600;
        %# 2 seconds x sample frequency = 2 x 800 = 1600 samples
        cutSamplesFromEnd = 1600;   
    end
    %# --------------------------------------------------------------------
    
    
    % /////////////////////////////////////////////////////////////////////
    % START: CREATE PLOTS AND RUN DIRECTORY
    % ---------------------------------------------------------------------

    %# _PLOTS directory
    fPath = '_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else    
        mkdir(fPath);
    end    
    
%     %# RUN directory
%     fPath = sprintf('_plots/%s', name(1:3));
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else    
%         mkdir(fPath);
%     end
    
    %# Time series directory
    fPath = sprintf('_plots/%s', '_time_series');
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else    
        mkdir(fPath);
    end    
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % ///////////////////////////////////////////////////////////////////// 
    
    
    % /////////////////////////////////////////////////////////////////////
    % START: WAVE PROBE ANALYSIS
    % ---------------------------------------------------------------------
    
    %# Get real units by applying calibration factors and zeros    
    [CH_0_WaveProbe CH_0_WaveProbe_Mean] = analysis_realunits(Raw_CH_0_WaveProbe,CH_0_Zero,CH_0_CF);
    
    x = timeData(startSamplePos:end-cutSamplesFromEnd);
    y = CH_0_WaveProbe(startSamplePos:end-cutSamplesFromEnd);
    
    %# Linear fit
    p  = polyfit(x,y,1);
    p2 = polyval(p,x);
        
    % Slope of Linear fit => Y = (slope1 * X ) + slope2
    slope{i}   = polyfit(x,y,1);
    slope1     = slope{1,2}(1);   % Slope
    intercept1 = slope{1,2}(2);   % Intercept
    
    %# Mass flow rate (Equation of fit)
    dispeqn = sprintf('R%s:: Mass flow rate (Equation of fit): y = %sx - %s', num2str(k), num2str(slope1), num2str(intercept1));
    disp(dispeqn);
    
    %# Calulcate flow rate based on Linear fit
    flowrate = abs((slope1 * 1) + intercept1) - abs((slope1 * 0) + intercept1);     % Difference between flow rate at 1 and 0 second
    
    
    %# START: MFR BASED ON 1s INTERVALS AND OVERALL ***********************
    
    %# MFR based on 1s intervals ------------------------------------------
    resultIntMFRArray = [];
    setCounter = 1;
    SL = round(min(timeData(startSamplePos:end-cutSamplesFromEnd)));
    EL = round(max(timeData(startSamplePos:end-cutSamplesFromEnd)));
    for kk=SL:EL
        upper = kk;
        lower = kk-1;
        mfr = abs((slope1 * upper) + intercept1) - abs((slope1 * lower) + intercept1);
        %dispmfr = sprintf('R%s:: Mass flow rate (%s-%ss): %s [Kg/s]', num2str(k), num2str(lower), num2str(upper), sprintf('%.2f',abs(mfr)));
        %disp(dispmfr);
        
        %# Write to array
        resultIntMFRArray(setCounter, 1) = mfr;
        setCounter = setCounter+1;
    end
    %# MFR for 1s
    dispmfr1s   = sprintf('R%s:: Mass flow rate (1s):                 %s [Kg/s]', num2str(k), sprintf('%.2f',abs(abs(flowrate))));
    disp(dispmfr1s);
    %# Mean of 1s intervals
    dispmfrmean = sprintf('R%s:: Mass flow rate (Mean, 1s intervals): %s [Kg/s]', num2str(k), sprintf('%.2f',abs(mean(resultIntMFRArray(:,1)))));
    disp(dispmfrmean);
    
    %# MFR based on collected mass over time  -----------------------------
    timeoverall    = max(x)-min(x);
    mfroverall     = max(y)-min(y);
    mfrresulting   = mfroverall/timeoverall;
    dispmfroverall = sprintf('R%s:: Mass flow rate (Overall, mfr/time):  %s [Kg/s]', num2str(k), sprintf('%.2f',abs(mfrresulting)));
    disp(dispmfroverall);
    
    %# Difference in MFT  -------------------------------------------------
    getMeanMFR    = abs(mean(resultIntMFRArray(:,1)));
    getOverallMFR = abs(mfrresulting);
    getCalDiffMFR = getMeanMFR/getOverallMFR;
    if getCalDiffMFR > 1
        getCalDiffMFR = getCalDiffMFR-1;
    else
        getCalDiffMFR = 1-getCalDiffMFR;
    end
    dispmfrdiff = sprintf('R%s:: Mass flow rate (Diff., mean/overall): %s%%', num2str(k), sprintf('%.1f',abs(getCalDiffMFR*100)));
    disp(dispmfrdiff);
    disp('-------------------------------------------------');
    
    %# END: MFR BASED ON 1s INTERVALS AND OVERALL *************************
    
    
    %# --------------------------------------------------------------------
    %# TIME SRIES PLOTS
    %# --------------------------------------------------------------------
    if plotting_on == 1
        
        %# Plotting curves
        figurename = sprintf('Sensors: Time Series and Wave Probe Data: Run %s', num2str(k));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# /////////////////////////////////////////////////////////////////
        %# START: WAVE PROBE ANALYSIS
        %# ----------------------------------------------------------------
        subplot(2,2,1);
        
        %# Plotting curves
        h = plot(x,y,'-',x,p2,'-k');
        title('{\bf Wave probe output}');
        xlabel('{\bf Time [s]}');
        ylabel('{\bf Mass flow rate [Kg]}');
        grid on;
        box on;
        axis square;

        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Axis limitations
        xlim([x(1) x(end)]);
                
        %# Add results to array for comparison and save as TXT and DAT file
        % Slope of Linear fit => Y = (slope1 * X ) + slope2
        slopesArray(k, 1) = k;          % Run number
        slopesArray(k, 2) = slope1;     % X-constant
        slopesArray(k, 3) = intercept1;     % Value
        slopesArray(k, 4) = flowrate;   % Flow rate
        
        %# For display only
        if intercept1 > 0
            chooseSign = '+';
            intercept1 = intercept1;
        else
            chooseSign = '-';
            intercept1 = abs(intercept1);
        end
        linfiteqn    = sprintf('y=%sx%s%s', sprintf('%.2f',slope1), chooseSign, sprintf('%.2f',intercept1));
        linfiteqntxt = sprintf('R%s:: Mass flow rate (slope): %s', num2str(k), linfiteqn);
        %disp(linfiteqntxt);
        
        %# Legend
        linfittxt = sprintf('Linear fit, %s',linfiteqn);
        hleg1 = legend('Wave probe',linfittxt);
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');
        %legend boxoff;        
        
        %# ----------------------------------------------------------------
        %# END: WAVE PROBE ANALYSIS
        %# ////////////////////////////////////////////////////////////////
    
        %# ////////////////////////////////////////////////////////////////
        %# START: KIEL PROBE
        %# ----------------------------------------------------------------
        subplot(2,2,2);
        
        x  = timeData(startSamplePos:end-cutSamplesFromEnd);
        y1 = Raw_CH_1_KPStbd(startSamplePos:end-cutSamplesFromEnd);   % 5 PSI DPT
        y2 = Raw_CH_2_KPPort(startSamplePos:end-cutSamplesFromEnd);   % 5 PSI DPT
        
        %# Linear fit
        kppolyfitstbd = polyfit(x,y1,1);
        kppolyvalstbd = polyval(kppolyfitstbd,x);
        kppolyfitport = polyfit(x,y2,1);
        kppolyvalport = polyval(kppolyfitport,x);
        
        %# Plotting curves
        h = plot(x,y1,'-',x,kppolyvalstbd,'-k',x,y2,'-',x,kppolyvalport,'-k');
        title('{\bf Kiel probe output}');
        xlabel('{\bf Time [s]}');
        ylabel('{\bf Output [V]}');
        grid on;
        box on;
        axis square;
        
        %# Axis limitations
        xlim([x(1) x(end)]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        set(h(3),'linewidth',1);
        set(h(4),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Kiel probe (Stbd)','Linear fit (Stbd)','Kiel probe (Port)','Linear fit (Port)');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        %legend boxoff;

        %# ----------------------------------------------------------------
        %# END: KIEL PROBE
        %# ////////////////////////////////////////////////////////////////
        
        %# ////////////////////////////////////////////////////////////////
        %# START: THRUST
        %# ----------------------------------------------------------------
        subplot(2,2,3);
        
        %# Get real units by applying calibration factors and zeros
        [CH_7_ThrustStbd CH_7_ThrustStbd_Mean] = analysis_realunits(Raw_CH_7_ThrustStbd,CH_7_Zero,CH_7_CF);
        [CH_8_ThrustPort CH_8_ThrustPort_Mean] = analysis_realunits(Raw_CH_8_ThrustPort,CH_8_Zero,CH_8_CF);
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        y1 = CH_7_ThrustStbd(startSamplePos:end-cutSamplesFromEnd);
        y2 = abs(CH_8_ThrustPort(startSamplePos:end-cutSamplesFromEnd)); % Absolute values due to negative output of dyno
        
        %# Linear fit
        thrustpolyfitstbd = polyfit(x,y1,1);
        thrustpolyvalstbd = polyval(thrustpolyfitstbd,x);
        thrustpolyfitport = polyfit(x,y2,1);
        thrustpolyvalport = polyval(thrustpolyfitport,x);
        
        %# Plotting curves
        h = plot(x,y1,'-',x,thrustpolyvalstbd,'-k',x,y2,'-',x,thrustpolyvalport,'-k');
        title('{\bf Dynamometer: Thrust}');
        xlabel('{\bf Time [s]}');
        ylabel('{\bf Thrust [g]}');
        grid on;
        box on;
        axis square;
        
        %# Axis limitations
        xlim([x(1) x(end)]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        set(h(3),'linewidth',1);
        set(h(4),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Thrust (Stbd)','Linear fit (Stbd)','Thrust (Port)','Linear fit (Port)');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        %legend boxoff;

        %# ----------------------------------------------------------------
        %# END: THRUST
        %# ////////////////////////////////////////////////////////////////
    
        %# ////////////////////////////////////////////////////////////////
        %# START: TORQUE
        %# ----------------------------------------------------------------
        subplot(2,2,4);
        
        %# Get real units by applying calibration factors and zeros
        [CH_9_TorqueStbd CH_9_TorqueStbd_Mean]   = analysis_realunits(Raw_CH_9_TorqueStbd,CH_9_Zero,CH_9_CF);
        [CH_10_TorquePort CH_10_TorquePort_Mean] = analysis_realunits(Raw_CH_10_TorquePort,CH_10_Zero,CH_10_CF);
        
        x = timeData(startSamplePos:end-cutSamplesFromEnd);
        y1 = CH_9_TorqueStbd(startSamplePos:end-cutSamplesFromEnd);
        y2 = abs(CH_10_TorquePort(startSamplePos:end-cutSamplesFromEnd)); % Absolute values due to negative output of dyno
        
        %# Linear fit
        torquepolyfitstbd = polyfit(x,y1,1);
        torquepolyvalstbd = polyval(torquepolyfitstbd,x);
        torquepolyfitport = polyfit(x,y2,1);
        torquepolyvalport = polyval(torquepolyfitport,x);
        
        %# Plotting curves
        h = plot(x,y1,'-',x,torquepolyvalstbd,'-k',x,y2,'-',x,torquepolyvalport,'-k');
        title('{\bf Dynamometer: Torque}');
        xlabel('{\bf Time [s]}');
        ylabel('{\bf Torque [Nm]}');
        grid on;
        box on;
        axis square;
        
        %# Axis limitations
        xlim([x(1) x(end)]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        set(h(3),'linewidth',1);
        set(h(4),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Torque (Stbd)','Linear fit (Stbd)','Torque (Port)','Linear fit (Port)');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        %legend boxoff;
                
        %# ----------------------------------------------------------------
        %# END: TORQUE
        %# ////////////////////////////////////////////////////////////////
        
        %# ****************************************************************
        %# Save plot as PNG
        %# ****************************************************************
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
        
        %# Plot title -----------------------------------------------------
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
        
        %# Save plots as PDF and PNG
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_Wave_Probe_and_Time_Series_Plot.pdf', '_time_series', num2str(k));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_Wave_Probe_and_Time_Series_Plot.png', '_time_series', num2str(k));
        saveas(f, plotsavename);                % Save plot as PNG
        close;                                  % Close current plot window
        
    end    
       
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# RPM AND POWER SWITCH SWITCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    rpm_power_on = 1;    % TRUE (1) or FALSE (0)
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# RPM AND POWER SWITCH SWITCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    %# ////////////////////////////////////////////////////////////////////
    %# START: RPM Analysis
    %# --------------------------------------------------------------------
    
    if rpm_power_on == 1
        [RPMStbd RPMPort] = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);
    end
    
    %# --------------------------------------------------------------------
    %# END: RPM Analysis
    %# ////////////////////////////////////////////////////////////////////
    
    
    %# ////////////////////////////////////////////////////////////////////
    %# CREATE RESULTS ARRAY
    %# ////////////////////////////////////////////////////////////////////    
        
    %# Add results to dedicated array for simple export
    %# Results array columns: 
        %[1]  Run No.
        %[2]  FS                    (Hz)
        %[3]  No. of samples        (-)
        %[4]  Record time           (s)
        %[5]  Mass flow rate        (Kg/s)
        %[6]  Kiel probe STBD       (V)
        %[7]  Kiel probe PORT       (V)
        %[8]  Thrust STBD           (N)
        %[9]  Thrust PORT           (N)
        %[10] Torque STBD           (Nm)
        %[11] Torque PORT           (Nm)
        %[12] Shaft Speed STBD      (RPM)
        %[13] Shaft Speed PORT      (RPM)
        %[14] Power STBD            (W)
        %[15] Power PORT            (W)
    %# Added columns: 18/8/2014
        %[16] Mass flow rate (1s only)                                  (Kg/s)
        %[17] Mass flow rate (mean, 1s intervals)                       (Kg/s)
        %[18] Mass flow rate (overall, Q/t)                             (Kg/s)
        %[19] Diff. mass flow rate (mean, 1s intervals)/(overall, Q/t)  (%)
        
    resultsArray(k, 1) = k;                                                          % Run No.
    resultsArray(k, 2) = round(length(timeData) / timeData(end));                    % FS (Hz)    
    resultsArray(k, 3) = length(timeData);                                           % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArray(k, 4) = round(recordTime);                                          % Record time in seconds
    resultsArray(k, 5) = abs(flowrate);                                              % Mass flow rate (1s) (Kg/s)
    resultsArray(k, 6) = mean(Raw_CH_1_KPStbd);                                      % Kiel probe STBD (V)
    resultsArray(k, 7) = mean(Raw_CH_2_KPPort);                                      % Kiel probe PORT (V)
    resultsArray(k, 8) = abs(((CH_7_ThrustStbd_Mean/1000)*9.806));                   % Thrust STBD (N)
    resultsArray(k, 9) = abs(((CH_8_ThrustPort_Mean/1000)*9.806));                   % Thrust PORT (N)
    resultsArray(k, 10) = abs(CH_9_TorqueStbd_Mean);                                 % Torque STBD (Nm)      
    resultsArray(k, 11) = abs(CH_10_TorquePort_Mean);                                % Torque PORT (Nm)
    if rpm_power_on == 1
        resultsArray(k, 12) = RPMStbd;                                               % Shaft Speed STBD (RPM)
        resultsArray(k, 13) = RPMPort;                                               % Shaft Speed PORT (RPM)
        resultsArray(k, 14) = ((abs(CH_9_TorqueStbd_Mean)*RPMStbd)/9549)*1000;       % Power STBD (W) where 9,549 = (60 ? 1000)/2?
        resultsArray(k, 15) = ((abs(CH_10_TorquePort_Mean)*RPMPort)/9549)*1000;      % Power PORT (W) where 9,549 = (60 ? 1000)/2?
    end
    resultsArray(k, 16) = abs(flowrate);                                             % Mass flow rate (1s) (Kg/s)
    resultsArray(k, 17) = abs(getMeanMFR);                                           % Mass flow rate (mean, 1s intervals) (Kg/s)
    resultsArray(k, 18) = abs(getOverallMFR);                                        % Mass flow rate (overall, Q/t) (Kg/s)
    resultsArray(k, 19) = abs(getCalDiffMFR*100);                                    % Diff. mass flow rate (mean, 1s intervals)/(overall, Q/t) (%) 
    
    %# Prepare strings for display
    name = num2str(k);
    massflowrate     = sprintf('R%s:: Mass flow rate: %s [Kg/s]', name, sprintf('%.2f',abs(flowrate)));
    kielprobestbd    = sprintf('R%s:: Kiel probe STBD (mean): %s [V]', name, sprintf('%.2f',mean(Raw_CH_1_KPStbd)));
    kielprobeport    = sprintf('R%s:: Kiel probe PORT (mean): %s [V]', name, sprintf('%.2f',mean(Raw_CH_2_KPPort)));
    thruststbd       = sprintf('R%s:: Thrust STBD (mean): %s [N]', name, sprintf('%.2f',abs(((CH_7_ThrustStbd_Mean/1000)*9.806))));
    thrustport       = sprintf('R%s:: Thrust PORT (mean): %s [N]', name, sprintf('%.2f',abs(((CH_8_ThrustPort_Mean/1000)*9.806))));
    torquestbd       = sprintf('R%s:: Torque STBD (mean): %s [Nm]', name, sprintf('%.2f',abs(CH_9_TorqueStbd_Mean)));
    torqueport       = sprintf('R%s:: Torque PORT (mean): %s [Nm]', name, sprintf('%.2f',abs(CH_10_TorquePort_Mean)));
    if rpm_power_on == 1
        shaftrpmstbd     = sprintf('R%s:: Shaft speed STBD: %s [RPM]', name, sprintf('%.0f',RPMStbd));
        shaftrpmport     = sprintf('R%s:: Shaft speed PORT: %s [RPM]', name, sprintf('%.0f',RPMPort));    
        powerstbd        = sprintf('R%s:: Power STBD: %s [W]', name, sprintf('%.2f',((abs(CH_9_TorqueStbd_Mean)*RPMStbd)/9549)*1000));
        powerport        = sprintf('R%s:: Power PORT: %s [W]', name, sprintf('%.2f',((abs(CH_10_TorquePort_Mean)*RPMPort)/9549)*1000)); 
    end
    
    %# Display strings
    disp(massflowrate);  
    %disp('-------------------------------------------------');  
    disp(kielprobestbd);
    disp(kielprobeport);
    %disp('-------------------------------------------------');  
    disp(thruststbd);
    disp(thrustport);
    %disp('-------------------------------------------------');  
    disp(torquestbd);
    disp(torqueport);        
    if rpm_power_on == 1
        %disp('-------------------------------------------------');  
        disp(shaftrpmstbd);
        disp(shaftrpmport);
        %disp('-------------------------------------------------');  
        disp(powerstbd);
        disp(powerport);    
    end
    
    disp('/////////////////////////////////////////////////');
    
end

%# ////////////////////////////////////////////////////////////////////////
%# START: Write results to CVS
%# ------------------------------------------------------------------------
M = resultsArray;
csvwrite('resultsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('resultsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
M = slopesArray;
csvwrite('slopesArray.dat', M)                                      % Export matrix M to a file delimited by the comma character      
dlmwrite('slopesArray.txt', M, 'delimiter', '\t', 'precision', 4)   % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
%# ------------------------------------------------------------------------
%# END: Write results to CVS
%# ////////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer