%# ------------------------------------------------------------------------
%# Self-Propulsion Test - Boundary Layer Measurements
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  November 12, 2013
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
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  02/12/2013 - Created new script
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
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
% testName = 'Resistance Test';
testName = 'Boundary Layer Measurements';
% testName = 'Waterjet Self-Propulsion Points';
% testName = 'Waterjet Self-Propulsion Test';

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

startRun = 29;      % Start at run x
endRun   = 29;      % Stop at run y

startRun = 29;      % Start at run x
endRun   = 69;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ************************************************************************
%# START: START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 17.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
modelkinviscosity   = (((0.585*10^(-3))*(ttwatertemp-12)-0.03361)*(ttwatertemp-12)+1.235)*10^(-6); % Model scale kinetic viscosity at X (see ttwatertemp) degrees following ITTC (m2/s)
fullscalekinvi      = 0.000001034;            % Full scale kinetic viscosity     (m^2/s)
freshwaterdensity   = 1000;                   % Model scale water density        (Kg/m^3)
saltwaterdensity    = 1025;                   % Salt water scale water density   (Kg/m^3)
distbetwposts       = 1150;                   % Distance between carriage posts  (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio  (-)

%# ------------------------------------------------------------------------
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

%# ------------------------------------------------------------------------
%# END: START CONSTANTS AND PARTICULARS
%# ************************************************************************


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED 
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableDISP         = 1; % Enable or disable values in command window

enableVolAndRDSave = 1; % Enable voltage and real data save
enableTSDataSave   = 1; % Enable time series data saving
%enableZeroDataSave = 1; % Enable zero data saving

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

% Arrays; save to file
resultsArrayBlm          = [];   % BL Data
%resultsArrayBlmZero      = [];   % BL ZERO data
resultsArrayBlmTS        = [];   % BL TS data
resultsArrayBlmVandRData = [];   % Voltage and real data using CF est. in PST calibration runs

%w = waitbar(0,'Processed run files'); 
for k=startRun:endRun
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % NOTE: If statement bellow is for use in LOOPS only!!!!
    
    % Runs at respective speeds
    RunsAtFr30 = [56 58 59 45 61 48 63 51 65 54 68];                              % i.e. Fr=0.30
    RunsAtFr35 = [41 42 43 38 39 40 44 35 36 37 47 32 33 34 50 52 66 29 30 31];   % i.e. Fr=0.35
    RunsAtFr40 = [57 60 46 62 49 64 53 67 55 69];                                 % i.e. Fr=0.40
    
    % Runs at respective depths
    Depth1 = [41 42 43 56 57 58];       % i.e.  3 mm
    Depth2 = [38 39 40 59 60];          % i.e. 13 mm
    Depth3 = [44 45 56];                % i.e. 23 mm
    Depth4 = [35 36 37 61 62];          % i.e. 33 mm
    Depth5 = [47 48 49];                % i.e. 43 mm
    Depth6 = [32 33 34 63 64];          % i.e. 53 mm
    Depth7 = [50 51 52 53 65 66 67];    % i.e. 63 mm
    Depth8 = [29 30 31 54 55 68 69];    % i.e. 73 mm
    
    % SPEED: IF, ELSE statement
    if any(RunsAtFr30==k)
        setSpeedCond = 1;
    elseif any(RunsAtFr35==k)
        setSpeedCond = 2;
    elseif any(RunsAtFr40==k)
        setSpeedCond = 3;
    else
        %disp('OTHER');
    end
    
    % DEPTH: IF, ELSE statement
    if any(Depth1==k)
        %setDepthCond = 1;
        setDepthCond = 3;
    elseif any(Depth2==k)
        %setDepthCond = 2;
        setDepthCond = 13;
    elseif any(Depth3==k)
        %setDepthCond = 3;
        setDepthCond = 23;
    elseif any(Depth4==k)
        %setDepthCond = 4;
        setDepthCond = 33;
    elseif any(Depth5==k)
        %setDepthCond = 5;
        setDepthCond = 43;
    elseif any(Depth6==k)
        %setDepthCond = 6;
        setDepthCond = 53;
    elseif any(Depth7==k)
        %setDepthCond = 7;
        setDepthCond = 63;
    elseif any(Depth8==k)
        %setDepthCond = 8;
        setDepthCond = 73;
    else
        %disp('OTHER');
    end    
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!!!
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
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
    fPath = sprintf('_plots/%s', 'BLM');
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
    Raw_CH_1_LVDTFwd       = data(:,3);       % Forward LVDT
    Raw_CH_2_LVDTAft       = data(:,4);       % Aft LVDT
    Raw_CH_3_Drag          = data(:,5);       % Load cell (drag)
    Raw_CH_19_PSTInboard   = data(:,6);       % Inboard PST for BL measurements
    Raw_CH_20_PSTOutboard  = data(:,7);       % Outboard PST for BL measurements
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
    CH_1_Zero  = ZeroAndCalib(5);
    CH_1_CF    = ZeroAndCalib(6);
    CH_2_Zero  = ZeroAndCalib(7);
    CH_2_CF    = ZeroAndCalib(8);
    CH_3_Zero  = ZeroAndCalib(9);
    CH_3_CF    = ZeroAndCalib(10);
    CH_19_Zero = ZeroAndCalib(11);
    CH_19_CF   = ZeroAndCalib(12);    
    CH_20_Zero = ZeroAndCalib(13);
    CH_20_CF   = ZeroAndCalib(14);
    
    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    % CWR Data
    [CH_0_Speed CH_0_Speed_Mean]                 = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]             = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean]             = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]                   = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);   
    
    % PST Data for BL Measurements
    [CH_19_PSTInboard CH_19_PSTInboard_Mean]     = analysis_realunits(Raw_CH_19_PSTInboard,CH_19_Zero,CH_19_CF);
    [CH_20_PSTOutboard CH_20_PSTOutboard_Mean]   = analysis_realunits(Raw_CH_20_PSTOutboard,CH_20_Zero,CH_20_CF);
    
    % Change from 2 to 3 digits -------------------------------------------
    if k > 99
        runno = name(2:4);
    else
        runno = name(1:3);
    end

    %# ////////////////////////////////////////////////////////////////////
    %# ////////////////////////////////////////////////////////////////////
    %# Boundary Layer - Real data, plots, etc.
    %# ////////////////////////////////////////////////////////////////////
    %# ////////////////////////////////////////////////////////////////////
    
    if enableVolAndRDSave == 1
    
        %# ********************************************************************
        %# Save data to aray then save to file
        %# ********************************************************************

        %# Add results to dedicated array for simple export
        %# Results array columns: 
            %[1]  Run No.
            %[2]  Froude length Number                     (-)
            
            %[3]  Speed no. (i.e. 1=0.30, 2=0.35, 3=0.40)  (-)
            %[4]  Depth no. (i.e. 1 to 8)                  (-)
            
            %[5]  Inboard: Averaged zero value             (V)
            %[6]  Inboard: Averaged zero value             (V)

            %[7]  Outboard: Calibration factor CF          (V to m/s)
            %[8]  Outboard: Calibration factor CF          (V to m/s)

            %[9]  Inboard PST: Voltage                     (V)
            %[10] Outboard PST: Voltage                    (V)

            %[11] Inboard PST: Real units using CF         (m/s)
            %[12] Outboard PST:Real units using CF         (m/s)

        % General data
        resultsArrayBlmVandRData(k, 1)  = k;

        % Froude length number
        roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
        modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number        
        resultsArrayBlmVandRData(k, 2)  = modelfrrounded;

        % Speed and depth number
        resultsArrayBlmVandRData(k, 3)  = setSpeedCond;
        resultsArrayBlmVandRData(k, 4)  = setDepthCond;
        
        % Zero values
        resultsArrayBlmVandRData(k, 5)  = CH_19_Zero;
        resultsArrayBlmVandRData(k, 6)  = CH_20_Zero;

        % Calibration factors
        resultsArrayBlmVandRData(k, 7)  = CH_19_CF;
        resultsArrayBlmVandRData(k, 8)  = CH_20_CF;

        % Voltage values
        resultsArrayBlmVandRData(k, 9)  = CH_19_PSTInboard_Mean;
        resultsArrayBlmVandRData(k, 10) = CH_20_PSTOutboard_Mean;    

        % Real unit values (m/s) based on PST calibration curve

        x1 = CH_19_PSTInboard_Mean;
        x2 = CH_20_PSTOutboard_Mean;

        resultsArrayBlmVandRData(k, 11) = -0.0328*x1^4+0.2521*x1^3-0.7873*x1^2+1.7721*x1+0.4389;
        resultsArrayBlmVandRData(k, 12) = -0.0328*x2^4+0.2521*x2^3-0.7873*x2^2+1.7721*x2+0.4389;
    
    end
    
    %# ////////////////////////////////////////////////////////////////////
    %# ////////////////////////////////////////////////////////////////////
    %# PST (Boundary Layer Measurements): Time Series Output
    %# ////////////////////////////////////////////////////////////////////
    %# ////////////////////////////////////////////////////////////////////
    
    if enableTSDataSave == 1
    
        figurename = sprintf('%s:: Boundary Layer Time Series Plot, Run %s', testName, num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        % Inboard PST ---------------------------------------------------------
        subplot(3,1,1);
        
        % Axis data
        x = timeData;
        y = Raw_CH_19_PSTInboard;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-b',x,polyv,'-k');
        title('{\bf Inboard PST}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf PST output (V)}');
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
        hleg1 = legend('Output (real units)','Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        % Outboard PST --------------------------------------------------------
        subplot(3,1,2);
        
        % Axis data
        x = timeData;
        y = Raw_CH_20_PSTOutboard;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        h = plot(x,y,'-g',x,polyv,'-k');
        title('{\bf Outboard PST}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf PST output (V)}');
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
        
        % Compared Inboard/Outboard PST ---------------------------------------
        subplot(3,1,3);
        
        % Axis data
        x = timeData;
        y1 = Raw_CH_19_PSTInboard;
        y2 = Raw_CH_20_PSTOutboard;
        
        %# Trendline
        polyf1 = polyfit(x,y1,1);
        polyv1 = polyval(polyf1,x);
        
        polyf2 = polyfit(x,y2,1);
        polyv2 = polyval(polyf2,x);
        
        h = plot(x,y1,'-b',x,y2,'-g',x,polyv1,'-k',x,polyv2,'--k');
        title('{\bf Overlayed Inboard/Outboard PST}');
        xlabel('{\bf Time (seconds)}');
        ylabel('{\bf PST output (V)}');
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
        set(h(2),'linewidth',1);
        set(h(3),'linewidth',2);
        set(h(4),'linewidth',2);
        
        %# Legend
        hleg1 = legend('Inboard Output','Outboard Output','Inboard Trendline','Outboard Trendline');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        
        %# ********************************************************************
        %# Command Window Output
        %# ********************************************************************
        if enableDISP == 1
            
            % Inboard PST
            MeanData = CH_19_PSTInboard_Mean;
            CHData   = CH_19_PSTInboard;
            
            avginbpst = sprintf('%s:: Inboard PST (Averaged): %s (V)', runno, sprintf('%.2f',MeanData));
            mininbpst = sprintf('%s:: Inboard PST (Minimum): %s (V)', runno, sprintf('%.2f',min(CHData)));
            maxinbpst = sprintf('%s:: Inboard PST (Maximum): %s (V)', runno, sprintf('%.2f',max(CHData)));
            ptainbpst = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
            stdinbpst = sprintf('%s:: Standard deviation: %s (V)', runno, sprintf('%.4f',std(CHData)));
            
            disp(avginbpst);
            disp(mininbpst);
            disp(maxinbpst);
            disp(ptainbpst);
            disp(stdinbpst);
            
            disp('-------------------------------------------------');
            
            % Outboard PST
            MeanData = CH_20_PSTOutboard_Mean;
            CHData   = CH_20_PSTOutboard;
            
            avgoutbbpst = sprintf('%s:: Outboard PST (Averaged): %s (V)', runno, sprintf('%.2f',MeanData));
            minoutbbpst = sprintf('%s:: Outboard PST (Minimum): %s (V)', runno, sprintf('%.2f',min(CHData)));
            maxoutbbpst = sprintf('%s:: Outboard PST (Maximum): %s (V)', runno, sprintf('%.2f',max(CHData)));
            ptaoutbbpst = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
            stdoutbbpst = sprintf('%s:: Standard deviation: %s (V)', runno, sprintf('%.4f',std(CHData)));
            
            disp(avgoutbbpst);
            disp(minoutbbpst);
            disp(maxoutbbpst);
            disp(ptaoutbbpst);
            disp(stdoutbbpst);
            
            disp('/////////////////////////////////////////////////');
            
        end
        
        %# ********************************************************************
        %# Save data to aray then save to file
        %# ********************************************************************
        
        %# Add results to dedicated array for simple export
        %# Results array columns:
        %[1]  Run No.
        
        %[2]  Froude length Number                     (-)
        %[3]  Speed no. (i.e. 1=0.30, 2=0.35, 3=0.40)  (-)
        %[4]  Depth no. (i.e. 1 to 8)                  (-)             
        
        %[5]  Channel
        %[6]  Inboard PST: Averaged            (V)
        %[7]  Inboard PST: Minimum             (V)
        %[8]  Inboard PST: Maximum             (V)
        %[9]  Inboard PST: Diff. min to avg    (percent)
        %[10] Inboard PST: Standard deviation  (V)
        
        %[11] Inboard PST: Zero value          (V)
        %[12] Inboard PST: Calibration factor  (-)        
        
        %[13] Channel
        %[14] Outboard PST: Averaged           (V)
        %[15] Outboard PST: Minimum            (V)
        %[16] Outboard PST: Maximum            (V)
        %[17] Outboard PST: Diff. min to avg   (percent)
        %[18] Outboard PST: Standard deviation (V)
        
        %[19] Outboard PST: Zero value         (V)
        %[20] Outboard PST: Calibration factor (-)        
        
        % General data
        resultsArrayBlmTS(k, 1)  = k;
        
        % Froude length number
        roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
        modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number        
        resultsArrayBlmTS(k, 2)  = modelfrrounded;

        % Speed and depth number
        resultsArrayBlmTS(k, 3)  = setSpeedCond;
        resultsArrayBlmTS(k, 4)  = setDepthCond;
        
        % Inboard ---------------------------------------------------------
        MeanData = CH_19_PSTInboard_Mean;
        CHData   = CH_19_PSTInboard;
        
        resultsArrayBlmTS(k, 5)  = 19;
        resultsArrayBlmTS(k, 6)  = MeanData;
        resultsArrayBlmTS(k, 7)  = min(CHData);
        resultsArrayBlmTS(k, 8)  = max(CHData);
        resultsArrayBlmTS(k, 9)  = abs(1-(min(CHData)/MeanData));
        resultsArrayBlmTS(k, 10) = std(CHData);
        
        % Inboard CF and zero
        resultsArrayBlmTS(k, 11)  = CH_19_Zero;
        resultsArrayBlmTS(k, 12)  = CH_19_CF;    
        
        % Outboard --------------------------------------------------------
        MeanData = CH_20_PSTOutboard_Mean;
        CHData   = CH_20_PSTOutboard;
        
        resultsArrayBlmTS(k, 13) = 20;
        resultsArrayBlmTS(k, 14) = MeanData;
        resultsArrayBlmTS(k, 15) = min(CHData);
        resultsArrayBlmTS(k, 16) = max(CHData);
        resultsArrayBlmTS(k, 17) = abs(1-(min(CHData)/MeanData));
        resultsArrayBlmTS(k, 18) = std(CHData);

        % Outboard CF and zero
        resultsArrayBlmTS(k, 19)  = CH_20_Zero;   
        resultsArrayBlmTS(k, 20) = CH_20_CF;        
        
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
        %plotsavenamePDF = sprintff('_plots/%s/Run_%s_CH_19-20_Bounday_Layer.pdf', 'TS', num2str(runno));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/%s/Run_%s_CH_19-20_Bounday_Layer.png', 'TS', num2str(runno));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
    
    end
    
    %# ////////////////////////////////////////////////////////////////////
    %# ////////////////////////////////////////////////////////////////////
    %# ZERO: Save data to aray then save to file
    %# ////////////////////////////////////////////////////////////////////
    %# ////////////////////////////////////////////////////////////////////
    
%     if enableZeroDataSave == 1
%     
%         %# Add results to dedicated array for simple export
%         %# Results array columns: 
%             %[1]  Run No.
% 
%             %[2]  Froude length Number                     (-)
%             %[3]  Speed no. (i.e. 1=0.30, 2=0.35, 3=0.40)  (-)
%             %[4]  Depth no. (i.e. 1 to 8)                  (-)            
%             
%             %[5]  Channel
%             %[6]  Inboard PST: Zero value           (V)
%             %[7]  Inboard PST: Calibration factor   (-)
% 
%             %[8]  Channel
%             %[9]  Outboard PST: Zero value          (V)
%             %[10] Outboard PST: Calibration factor  (-)
% 
%         % General data
%         resultsArrayBlmZero(k, 1)  = k;
% 
%         % Froude length number
%         roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
%         modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number        
%         resultsArrayBlmZero(k, 2)  = modelfrrounded;
% 
%         % Speed and depth number
%         resultsArrayBlmZero(k, 3)  = setSpeedCond;
%         resultsArrayBlmZero(k, 4)  = setDepthCond;
%         
%         % Inboard PST
%         resultsArrayBlmZero(k, 5)  = 19;
%         resultsArrayBlmZero(k, 6)  = CH_19_Zero;
%         resultsArrayBlmZero(k, 7)  = CH_19_CF; 
% 
%         % Outboard PST
%         resultsArrayBlmZero(k, 8)  = 20;
%         resultsArrayBlmZero(k, 9)  = CH_20_Zero;   
%         resultsArrayBlmZero(k, 10) = CH_20_CF; 
%     
%     end
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


%# ------------------------------------------------------------------------
%# START: PLOT VOLTAGE AND REAL DATA
%# ------------------------------------------------------------------------

if enableVolAndRDSave == 1
    
    figurename = sprintf('%s:: Voltage and Real Data Plot Plot, Run 29 to 69', testName);
    f = figure('Name',figurename,'NumberTitle','off');
    
    RA = resultsArrayBlmVandRData;
    RA = RA(any(RA,2),:);
    A  = arrayfun(@(x) RA(RA(:,3) == x, :), unique(RA(:,3)), 'uniformoutput', false);
    
    % Voltage
    subplot(1,2,1);
    
    % Axis data. Subscript i = inboard and o = outboard
    x1i = A{1}(:,9);
    x1o = A{1}(:,10);
    
    x2i = A{2}(:,9);
    x2o = A{2}(:,10);
    
    x3i = A{3}(:,9);
    x3o = A{3}(:,10);
    
    y1i = A{1}(:,4);
    y1o = A{1}(:,4);
    
    y2i = A{2}(:,4);
    y2o = A{2}(:,4);
    
    y3i = A{3}(:,4);
    y3o = A{3}(:,4);
    
    h = plot(x1i,y1i,'sr',x1o,y1o,'^r',x2i,y2i,'sg',x2o,y2o,'^g',x3i,y3i,'sb',x3o,y3o,'^b');
    title('{\bf Voltage Output}');
    xlabel('{\bf Output (V)}');
    ylabel('{\bf Depth (m)}');
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);     
    
    %# Axis limitations
    %xlim([min(x) max(x)]);
    %set(gca,'XTick',[min(x):0.2:max(x)]);
    %set(gca,'YLim',[0 75]);
    %set(gca,'YTick',[0:5:75]);
    
    %# Line width
    %set(h(1),'linewidth',1);
    %set(h(2),'linewidth',1);
    %set(h(3),'linewidth',2);
    %set(h(4),'linewidth',2);
    
    %# Legend
    hleg1 = legend('Fr=0.30 Inboard','Fr=0.30 Outboard','Fr=0.35 Inboard','Fr=0.35 Outboard','Fr=0.40 Inboard','Fr=0.40 Outboard');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    
    % Real units
    subplot(1,2,2);
    
    % Axis data. Subscript i = inboard and o = outboard
    x1i = A{1}(:,11);
    x1o = A{1}(:,12);
    
    x2i = A{2}(:,11);
    x2o = A{2}(:,12);
    
    x3i = A{3}(:,11);
    x3o = A{3}(:,12);
    
    y1i = A{1}(:,4);
    y1o = A{1}(:,4);
    
    y2i = A{2}(:,4);
    y2o = A{2}(:,4);
    
    y3i = A{3}(:,4);
    y3o = A{3}(:,4);
    
    h = plot(x1i,y1i,'sr',x1o,y1o,'^r',x2i,y2i,'sg',x2o,y2o,'^g',x3i,y3i,'sb',x3o,y3o,'^b');
    title('{\bf Real Units Output}');
    xlabel('{\bf Speed (m/s)}');
    ylabel('{\bf Depth (mm)}');
    grid on;
    box on;
    axis square;
    
    %# Axis limitations
    %xlim([min(x) max(x)]);
    %set(gca,'XTick',[min(x):0.2:max(x)]);
    %set(gca,'YLim',[0 75]);
    %set(gca,'YTick',[0:5:75]);
    
    %# Line width
    %set(h(1),'linewidth',1);
    %set(h(2),'linewidth',1);
    %set(h(3),'linewidth',2);
    %set(h(4),'linewidth',2);
    
    %# Legend
    hleg1 = legend('Fr=0.30 Inboard','Fr=0.30 Outboard','Fr=0.35 Inboard','Fr=0.35 Outboard','Fr=0.40 Inboard','Fr=0.40 Outboard');
    set(hleg1,'Location','NorthWest');
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
    %plotsavenamePDF = sprintf('_plots/%s/Boundary_Layer_Profiles_Fr_030_to_0.40.pdf', 'BLM');
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Boundary_Layer_Profiles_Fr_030_to_0.40.png', 'BLM');
    saveas(f, plotsavename);                % Save plot as PNG
    close;
    
end

%# ------------------------------------------------------------------------
%# END: PLOT VOLTAGE AND REAL DATA
%# ------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

% Boundary layer measurement data
M = resultsArrayBlm;
M = M(any(M,2),:);                           % Remove zero rows
csvwrite('resultsArrayBlm.dat', M)           % Export matrix M to a file delimited by the comma character  

% Velocities and read unit data -------------------------------------------
if enableVolAndRDSave == 1
    % Boundary layer measurement zero data
    M = resultsArrayBlmVandRData;
    M = M(any(M,2),:);                           % Remove zero rows
    csvwrite('resultsArrayBlmVandRData.dat', M)  % Export matrix M to a file delimited by the comma character
end

% Time series data, min, max, diff. to avg., STDev, CF and zero values ----
if enableTSDataSave == 1
    % Boundary layer measurement TS data
    M = resultsArrayBlmTS;
    M = M(any(M,2),:);                           % Remove zero rows
    csvwrite('resultsArrayBlmTS.dat', M)         % Export matrix M to a file delimited by the comma character  
end
    
% if enableZeroDataSave == 1    
%     % Boundary layer measurement zero data
%     M = resultsArrayBlmZero;
%     M = M(any(M,2),:);                           % Remove zero rows
%     csvwrite('resultsArrayBlmZero.dat', M)       % Export matrix M to a file delimited by the comma character
% end

%dlmwrite('resultsArrayBlm.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer