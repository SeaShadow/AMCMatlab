%# ------------------------------------------------------------------------
%# PST and DPT Calibration
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  December 10, 2013
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
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  10/12/2013 - Created new script
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

%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'PST and DPT Calibration';
% testName = 'Resistance Test';
% testName = 'Boundary Layer Investigation';
% testName = 'Waterjet Self-Propulsion Points';
%testName = 'Waterjet Self-Propulsion Test';

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

%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 17.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500           = 4.30;                              % Model length waterline          (m)
MSwsa1500           = 1.501;                             % Model scale wetted surface area (m^2)
MSdraft1500         = 0.133;                             % Model draft                     (m)
MSAx1500            = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500      = 0.592;                             % Mode block coefficient          (-)
FSlwl1500           = MSlwl1500*FStoMSratio;             % Full scale length waterline     (m)
FSwsa1500           = MSwsa1500*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft1500         = MSdraft1500*FStoMSratio;           % Full scale draft                (m)

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 39;  % Number of headerlines to data
headerlinesZeroAndCalib = 33;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration ----------------------------
%# ------------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 0;

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%startRun = 4;      % Start at run x
%endRun   = 4;      % Stop at run y

startRun = 4;      % Start at run x
endRun   = 15;     % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableDISP   = 1; % Enable or disable values in command window
enableTSPlot = 1; % Enable or disable time series plot

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArrayCalib = [];
%w = waitbar(0,'Processed run files');
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
    
    %# RUN directory
    fPath = sprintf('_plots/%s', 'Calibration');
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % /////////////////////////////////////////////////////////////////////
    
    %# Columns as variables (RAW DATA)
    timeData               = data(:,1);       % Timeline
    Raw_CH_0_Speed         = data(:,2);       % Speed
    Raw_CH_19_Inb_PST      = data(:,3);       % Inboard PST
    Raw_CH_20_Outb_PST     = data(:,4);       % Outboard PST
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
    CH_19_Zero = ZeroAndCalib(5);
    CH_19_CF   = ZeroAndCalib(6);
    CH_20_Zero = ZeroAndCalib(7);
    CH_20_CF   = ZeroAndCalib(8);
    
    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    [CH_0_Speed CH_0_Speed_Mean]         = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    
    [CH_19_Inb_PST CH_19_Inb_PST_Mean]   = analysis_realunits(Raw_CH_19_Inb_PST,CH_19_Zero,CH_19_CF);
    [CH_20_Outb_PST CH_20_Outb_PST_Mean] = analysis_realunits(Raw_CH_20_Outb_PST,CH_20_Zero,CH_20_CF);
    
    %     [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]             = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    %     [CH_2_LVDTAft CH_2_LVDTAft_Mean]             = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    %     [CH_3_Drag CH_3_Drag_Mean]                   = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
    %
    %     [RPMStbd RPMPort]                            = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);
    %
    %     [CH_6_PortThrust CH_6_PortThrust_Mean]       = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
    %     [CH_7_PortTorque CH_7_PortTorque_Mean]       = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
    %     [CH_8_StbdThrust CH_8_StbdThrust_Mean]       = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
    %     [CH_9_StbdTorque CH_9_StbdTorque_Mean]       = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);
    %
    %     [CH_12_Port_Stat_6 CH_12_Port_Stat_6_Mean]   = analysis_realunits(Raw_CH_12_Port_Stat_6,CH_12_Zero,CH_12_CF);
    %     [CH_13_Stbd_Stat_6 CH_13_Stbd_Stat_6_Mean]   = analysis_realunits(Raw_CH_13_Stbd_Stat_6,CH_13_Zero,CH_13_CF);
    %     [CH_14_Stbd_Stat_5 CH_14_Stbd_Stat_5_Mean]   = analysis_realunits(Raw_CH_14_Stbd_Stat_5,CH_14_Zero,CH_14_CF);
    %     [CH_15_Stbd_Stat_4 CH_15_Stbd_Stat_4_Mean]   = analysis_realunits(Raw_CH_15_Stbd_Stat_4,CH_15_Zero,CH_15_CF);
    %     [CH_16_Stbd_Stat_3 CH_16_Stbd_Stat_3_Mean]   = analysis_realunits(Raw_CH_16_Stbd_Stat_3,CH_16_Zero,CH_16_CF);
    %     [CH_17_Port_Stat_1a CH_17_Port_Stat_1a_Mean] = analysis_realunits(Raw_CH_17_Port_Stat_1a,CH_17_Zero,CH_17_CF);
    %     [CH_18_Stbd_Stat_1a CH_18_Stbd_Stat_1a_Mean] = analysis_realunits(Raw_CH_18_Stbd_Stat_1a,CH_18_Zero,CH_18_CF);
    
    
    % /////////////////////////////////////////////////////////////////////
    % DISPLAY RESULTS
    % /////////////////////////////////////////////////////////////////////
    
    %# Add results to dedicated array for simple export
    %# Results array columns:
    %[1]  Run No.
    %[2]  FS                              (Hz)
    %[3]  No. of samples                  (-)
    %[4]  Record time                     (s)
    
    %[5]  Model speed                     (m/s)
    %[6]  Froude length number            (-)
    
    %[7]  CH_19: PST: TS mean             (V)
    %[8]  CH_19: PST: Calibration factor  (-)
    %[9]  CH_19: PST: Zero value          (V)
    
    %[10] CH_19: PST: CF*(x-zero) mean    (V)
    %[11] CH_19: PST: Minimum             (V)
    %[12] CH_19: PST: Maximum             (V)
    %[13] CH_19: PST: Diff. min to avg    (percent)
    %[14] CH_19: PST: Standard deviation  (V)
    
    % General data
    resultsArrayCalib(k, 1)  = k;                                                       % Run No.
    resultsArrayCalib(k, 2)  = round(length(timeData) / timeData(end));                 % FS (Hz)
    resultsArrayCalib(k, 3)  = length(timeData);                                        % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArrayCalib(k, 4)  = round(recordTime);                                       % Record time in seconds
    
    % Speed data
    resultsArrayCalib(k, 5)  = CH_0_Speed_Mean;                                         % Speed (m/s)
    roundedspeed   = str2num(sprintf('%.2f',resultsArrayCalib(k, 5)));                  % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArrayCalib(k, 6)  = modelfrrounded;                                          % Froude length number (adjusted for Lwl change at different conditions) (-)
    
    % Variables
    MeanData                 = CH_19_Inb_PST_Mean;
    CHData                   = CH_19_Inb_PST;
    
    % CH_19: PST data
    resultsArrayCalib(k, 7)  = mean(Raw_CH_19_Inb_PST);
    resultsArrayCalib(k, 8)  = CH_19_CF;
    resultsArrayCalib(k, 9)  = CH_19_Zero;
    
    % CH_19: Stats
    resultsArrayCalib(k, 10) = MeanData;
    resultsArrayCalib(k, 11) = min(CHData);
    resultsArrayCalib(k, 12) = max(CHData);
    resultsArrayCalib(k, 13) = abs(1-(min(CHData)/MeanData));
    resultsArrayCalib(k, 14) = std(CHData);
    
    
    % Change from 2 to 3 digits -------------------------------------------
    if k > 99
        runno = name(2:4);
    else
        runno = name(1:3);
    end
    
    %# ********************************************************************
    %# Time series plot
    %# ********************************************************************
    if enableTSPlot == 1
        
        figurename = sprintf('%s:: Time Series Plot, Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        % Calibration PST: Times series -----------------------------------
        subplot(2,1,1);
        
        % Axis data
        x = timeData;
        y = Raw_CH_19_Inb_PST;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Times series}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Output (V)}');
        grid on;
        box on;
        %axis square;
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (time series)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % Calibration PST: Times series -----------------------------------
        subplot(2,1,2);
        
        % Axis data
        x = timeData;
        y = CH_19_Inb_PST;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Real units}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf Output (V)}');
        grid on;
        box on;
        %axis square;
        
        %# Axis limitations
        xlim([min(x) max(x)]);
        %set(gca,'XTick',[min(x):0.2:max(x)]);
        %set(gca,'YLim',[0 75]);
        %set(gca,'YTick',[0:5:75]);
        
        %# Line width
        set(h(1),'linewidth',1);
        set(h(2),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        %# ********************************************************************
        %# Save plot as PNG
        %# ********************************************************************
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
        
        %# Plot title ---------------------------------------------------------
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
        
        %# Save plots as PDF and PNG
        %plotsavenamePDF = sprintf('_plots/%s/Run_%s_CH_19-20_PST_Calibration.pdf', 'Calibration', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_CH_19-20_PST_Calibration.png', 'Calibration', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
        
    end
    
    %# ********************************************************************
    %# Command Window Output
    %# ********************************************************************
    if enableDISP == 1
        
        froudeno      = sprintf('%s:: Froude length number: %s [-]', runno, sprintf('%.2f',modelfrrounded));
        
        % Time series data
        inbpst        = sprintf('%s::Inboard PST (time series mean): %s [V]', runno, sprintf('%.2f',mean(Raw_CH_19_Inb_PST)));
        %outbpst       = sprintf('%s::Outboard PST (time series mean): %s [V]', runno, sprintf('%.2f',mean(Raw_CH_20_Outb_PST)));
        
        % Calibration factors and zero values
        inbpstCFZero  = sprintf('%s::Inboard PST: CF = %s, Zero = %s', runno, num2str(CH_19_CF), num2str(CH_19_Zero));
        %outbpstCFZero = sprintf('%s::Outboard PST: CF = %s, Zero = %s', runno, num2str(CH_20_CF), num2str(CH_20_Zero));
        
        % Averaged values with CF*(x-zero) applied
        inbpstAvgMean  = sprintf('%s::Inboard PST (CF*(x-zero) mean): %s [V]', runno, sprintf('%.2f',CH_19_Inb_PST_Mean));
        %outbpstAvgMean = sprintf('%s::Outboard PST (CF*(x-zero) mean): %s [V]', runno, sprintf('%.2f',CH_20_Outb_PST_Mean));
        
        %# Display strings ---------------------------------------------------
        
        disp(froudeno);
        
        disp('-------------------------------------------------');
        
        % CH_19
        disp(inbpst);
        disp(inbpstCFZero);
        disp(inbpstAvgMean);
        
        %         disp('-------------------------------------------------');
        %
        %         % CH_20
        %         disp(outbpst);
        %         disp(outbpstCFZero);
        %         disp(outbpstAvgMean);
        
        disp('/////////////////////////////////////////////////');
        
    end
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
M = resultsArrayCalib;
csvwrite('resultsArrayCalib.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsArrayCalib.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
