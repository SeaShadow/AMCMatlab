%# ------------------------------------------------------------------------
%# Self-Propulsion Test - Boundary Layer Measurements
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  June 10, 2015
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
%# CHANGES    :  02/12/2013 - Created new script
%#               01/10/2014 - Script update and changed plots
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
%# START: PLOT SWITCHES: 1 = ENABLED
%#                       0 = DISABLED
%# ------------------------------------------------------------------------

% Time series data
enableTSDataSave          = 1;    % Enable time series data saving

% Main and plot titles
enablePlotMainTitle       = 0;    % Show plot title in saved file
enablePlotTitle           = 0;    % Show plot title above plot
enableTextOnPlot          = 0;    % Show text on plot
enableBlackAndWhitePlot   = 1;    % Show plot in black and white
enableEqnOfFitPlot        = 0;    % Show equations of fit
enableCommandWindowOutput = 1;    % Show command windown ouput

% Averaged run data and BL depth marker
enableAveragedRunsPlot1   = 1;    % Show averaged runs in plot 1 (Y vs. speed)
enableAveragedRunsPlot2   = 1;    % Show averaged runs in plot 2 (u/U0 vs. Y)
enableBLDepthMarker       = 1;    % Show marker for estimated BL depth

% Comparison data
enableMARINBLData         = 1;    % Show MARIN 112m BL data (cond. T1)
enableAMCLJ120EBLData     = 0;    % Show AMC LJ120E BL data (Brandner 2007)

% Scaled to A4 paper
enableA4PaperSizePlot     = 1;    % Show plots scale to A4 size

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


%# ************************************************************************
%# START Define plot size
%# ------------------------------------------------------------------------
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END Define plot size
%# ************************************************************************


%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'Boundary Layer Measurements';

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
headerlines             = 39;  % Number of headerlines to data
headerlinesZeroAndCalib = 33;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 0;


%# ************************************************************************
%# START File loop for runs, startRun to endRun
%# ------------------------------------------------------------------------

%startRun = 29;      % Start at run x
%endRun   = 29;      % Stop at run y

startRun = 29;      % Start at run x
endRun   = 69;      % Stop at run y

%# ------------------------------------------------------------------------
%# END File loop for runs, startRun to endRun
%# ************************************************************************


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
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

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
%# END START CONSTANTS AND PARTICULARS
%# ************************************************************************


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

%# Bounday_Layer_TS directory ---------------------------------------------
setDirName = '_plots/Bounday_Layer_TS';

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

%# Bounday_Layer directory ------------------------------------------------
setDirName = '_plots/Bounday_Layer';

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

% -------------------------------------------------------------------------
% END CREATE PLOTS AND RUN DIRECTORY
% /////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START MARIN 112m boundary layer data (variable name is MARIN112mBLData)
%# ------------------------------------------------------------------------
if exist('MARIN112mBLData.mat', 'file') == 2
    
    %# MARIN T1 conditions and particulars --------------------------------
    
    % Model to full scale ratio (?): 17.1
    
    % Length WL (FS):   103.33 m
    % Length WL (MS):     6.04 m
    % Speed (FS):        35.0  m/s
    % Speed (MS):         4.35 m/s
    % BL thickness (?):   73.0 mm
    
    %# Columns: -----------------------------------------------------------
    
    %[1]  Distance (Y) from model hull      (mm)
    %[2]  u/Uo ratio                        (-)
    %[3]  Speed at distance Y from hull     (m/s)
    
    load('MARIN112mBLData.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for MARIN 112m boundary layer data (MARIN112mBLData.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END MARIN 112m boundary layer data (variable name is LJ120EPCData)
%# ************************************************************************


%# ************************************************************************
%# START AMC LJ120E Brandner data (variable name is AMCLJ120EBLData)
%# ------------------------------------------------------------------------
if exist('AMCLJ120EBLData.mat', 'file') == 2
    
    %# Columns: -----------------------------------------------------------
    
    %[1]  Distance (Y) from model hull      (mm)
    %[2]  u/Uo ratio: Upstream BL           (-)
    %[3]  Distance (Y) from model hull      (mm)
    %[4]  u/Uo ratio: IVR 1.0               (-)
    %[5]  Distance (Y) from model hull      (mm)
    %[6]  u/Uo ratio: IVR 1.25              (-)
    %[7]  Distance (Y) from model hull      (mm)
    %[8]  u/Uo ratio: IVR 1.5               (-)
    %[9]  Distance (Y) from model hull      (mm)
    %[10] u/Uo ratio: IVR 1.75              (-)
    %[11] Distance (Y) from model hull      (mm)
    %[12] u/Uo ratio: IVR 2.0               (-)
    
    load('AMCLJ120EBLData.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for AMC LJ120E waterjet BL data (AMCLJ120EBLData.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END AMC LJ120E Brandner data (variable name is AMCLJ120EBLData)
%# ************************************************************************


%# ------------------------------------------------------------------------
%# Read results DAT file
%# ------------------------------------------------------------------------
if exist('resultsArrayBlm_Repo.dat', 'file') == 2
    
    %# Results array columns:
    %[1]  Run No.
    %[2]  Froude length Number                     (-)
    %[3]  Speed no. (i.e. 1=0.30, 2=0.35, 3=0.40)  (-)
    %[4]  Distance from model hull (Y)             (mm)
    %[5]  Averaged zero value (Inboard)            (V)
    %[6]  Averaged zero value (Outboard)           (V)
    %[7]  Outboard: Calibration factor CF          (V to m/s)
    %[8]  Outboard: Calibration factor CF          (V to m/s)
    %[9]  PST: Voltage (Inboard)                   (V)
    %[10] PST: Voltage (Outboard)                  (V)
    %[11] PST: Real units using CF (Inboard)       (m/s)
    %[12] PST: Real units using CF (Outboard)      (m/s)
    %[13] u/U0 (Inboard)                           (-)
    %[14] u/U0 (Outboard)                          (-)
    %[15] Estimated boundary layer depth           (mm)
    %[16] Model speed                              (m/s)
    
    resultsArrayBlm = csvread('resultsArrayBlm_Repo.dat');
    
    %# Remove zero rows
    resultsArrayBlm(all(resultsArrayBlm==0,2),:)=[];
    
else
    
    %# ////////////////////////////////////////////////////////////////////////
    %# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
    %# ////////////////////////////////////////////////////////////////////////
    
    % Arrays; save to file
    resultsArrayBlmTS = [];     % BL TS data
    resultsArrayBlm   = [];     % Voltage and real data using CF est. in PST calibration runs
    
    %w = waitbar(0,'Processed run files');
    for k=startRun:endRun
        
        %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        %# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS
        %# --------------------------------------------------------------------
        
        % NOTE: If statement bellow is for use in LOOPS only!!!!
        
        % Runs at respective speeds -------------------------------------------
        
        % Speed: Fr = 0.30
        RunsAtFr30 = [56 58 59 45 61 48 63 51 65 54 68];
        
        % Speed: Fr = 0.35
        RunsAtFr35 = [41 42 43 38 39 40 44 35 36 37 47 32 33 34 50 52 66 29 30 31];
        
        % Speed: Fr = 0.40
        RunsAtFr40 = [57 60 46 62 49 64 53 67 55 69];
        
        % Runs at respective depths -------------------------------------------
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
        end
        
        %# --------------------------------------------------------------------
        %# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS
        %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
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
        %# Boundary Layer - Real data, plots, etc.
        %# ////////////////////////////////////////////////////////////////////
        
        %# ****************************************************************
        %# Save data to aray then save to file
        %# ****************************************************************
        
        %# Add results to dedicated array for simple export
        %# Results array columns:
        %[1]  Run No.
        %[2]  Froude length Number                      (-)
        
        %[3]  Speed no. (i.e. 1=0.30, 2=0.35, 3=0.40)   (-)
        %[4]  Depth no. (i.e. 1 to 8)                   (-)
        
        %[5]  INBOARD:  Averaged zero value             (V)
        %[6]  OUTBOARD: Averaged zero value             (V)
        
        %[7]  INBOARD:  Outboard: Calibration factor CF (V to m/s)
        %[8]  OUTBOARD: Calibration factor CF           (V to m/s)
        
        %[9]  INBOARD PST:  Voltage                     (V)
        %[10] OUTBOARD PST: Voltage                     (V)
        
        %[11] INBOARD PST: Real units using CF          (m/s)
        %[12] OUTBOARD PST: Real units using CF         (m/s)
        
        %[13] INBOARD:  u/U0                            (-)
        %[14] OUTBOARD: u/U0                            (-)
        
        %[15] Estimated boundary layer depth            (mm)
        %[16] Model speed                               (m/s)
        
        % General data
        resultsArrayBlm(k, 1)  = k;
        
        % Froude length number
        roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
        modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
        resultsArrayBlm(k, 2)  = modelfrrounded;
        
        % Speed and depth number
        resultsArrayBlm(k, 3)  = setSpeedCond;
        resultsArrayBlm(k, 4)  = setDepthCond;
        
        % Zero values
        resultsArrayBlm(k, 5)  = CH_19_Zero;
        resultsArrayBlm(k, 6)  = CH_20_Zero;
        
        % Calibration factors
        resultsArrayBlm(k, 7)  = CH_19_CF;
        resultsArrayBlm(k, 8)  = CH_20_CF;
        
        % Voltage values
        resultsArrayBlm(k, 9)  = CH_19_PSTInboard_Mean;
        resultsArrayBlm(k, 10) = CH_20_PSTOutboard_Mean;
        
        % Real unit values (m/s) based on PST calibration curve
        x1 = CH_19_PSTInboard_Mean;
        x2 = CH_20_PSTOutboard_Mean;
        
        % Start Curve fitting based on EoF --------------------------------
        
        % New values (Matlab based)
        InbVTSFittingM = -0.0305*x1^4+0.2396*x1^3-0.7659*x1^2+1.7608*x1+0.4403;
        OubVTSFittingM = -0.0305*x2^4+0.2396*x2^3-0.7659*x2^2+1.7608*x2+0.4403;
        
        %disp(sprintf('INBOARD:  Old: %s m/s, New: %s m/s', num2str(InbVTSFittingE), num2str(InbVTSFittingM)));
        %disp(sprintf('OUTBOARD: Old: %s m/s, New: %s m/s', num2str(OubVTSFittingE), num2str(OubVTSFittingM)));
        
        % End Curve fitting based on EoF ----------------------------------
        
        resultsArrayBlm(k, 11) = InbVTSFittingM;
        resultsArrayBlm(k, 12) = OubVTSFittingM;
        
        % u/U0 ratio
        resultsArrayBlm(k, 13) = resultsArrayBlm(k, 11)/roundedspeed;
        resultsArrayBlm(k, 14) = resultsArrayBlm(k, 12)/roundedspeed;
        
        % Est. BL depth and speed
        if setSpeedCond == 1
            EstBLDepth = 44.55;
        elseif setSpeedCond == 2
            EstBLDepth = 41.67;
        elseif setSpeedCond == 3
            EstBLDepth = 36.71;
        end
        resultsArrayBlm(k, 15) = EstBLDepth;
        resultsArrayBlm(k, 16) = roundedspeed;
        
        %# ////////////////////////////////////////////////////////////////
        %# PST (Boundary Layer Measurements): Time Series Output
        %# ////////////////////////////////////////////////////////////////
        
        if enableTSDataSave == 1
            
            figurename = sprintf('Run %s: Boundary Layer Time Series', num2str(k));
            f = figure('Name',figurename,'NumberTitle','off');
            
            %# Paper size settings ----------------------------------------
            
            if enableA4PaperSizePlot == 1
                set(gcf, 'PaperSize', [19 19]);
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperPosition', [0 0 19 19]);
                
                set(gcf, 'PaperUnits', 'centimeters');
                set(gcf, 'PaperSize', [19 19]);
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperPosition', [0 0 19 19]);
            end
            
            % Fonts and colours -------------------------------------------
            setGeneralFontName = 'Helvetica';
            setGeneralFontSize = 14;
            setBorderLineWidth = 2;
            setLegendFontSize  = 12;
            
            %# Change default text fonts for plot title
            set(0,'DefaultTextFontname',setGeneralFontName);
            set(0,'DefaultTextFontSize',14);
            
            %# Box thickness, axes font size, etc. ------------------------
            set(gca,'TickDir','in',...
                'FontSize',10,...
                'LineWidth',2,...
                'FontName',setGeneralFontName,...
                'Clipping','off',...
                'Color',[1 1 1],...
                'LooseInset',get(gca,'TightInset'));
            
            %# Markes and colors ------------------------------------------
            setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
            % Colored curves
            setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
            %if enableBlackAndWhitePlot == 1
            %    % Black and white curves
            %    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
            %end
            
            %# Line, colors and markers
            setMarkerSize      = 4;
            setLineWidthMarker = 1;
            setLineWidth       = 1;
            setLineStyle       = '-';
            setLineStyle1      = '--';
            setLineStyle2      = '-.';
            
            %# Set plot figure background to a defined color --------------
            %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
            set(gcf,'Color',[1,1,1]);
            
            % Inboard PST -------------------------------------------------
            subplot(3,1,1);
            
            % Axis data
            x = timeData;
            y = Raw_CH_19_PSTInboard;
            
            %# Trendline
            polyf = polyfit(x,y,1);
            polyv = polyval(polyf,x);
            
            h = plot(x,y,'-',x,polyv,'-');
            title('{\bf Inboard Pitot-Static Tube}','FontSize',setGeneralFontSize);
            xlabel('{\bf Time (seconds)}','FontSize',setGeneralFontSize);
            ylabel('{\bf PST output (V)}','FontSize',setGeneralFontSize);
            grid on;
            box on;
            %axis square;
            
            %# Line, colors and markers
            setCurveNo=1;set(h(setCurveNo),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setCurveNo=2;set(h(setCurveNo),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
            
            %# Set plot figure background to a defined color
            %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
            set(gcf,'Color',[1,1,1]);
            
            %# Axis limitations
            xlim([min(x) max(x)]);
            %set(gca,'XTick',[min(x):0.2:max(x)]);
            %set(gca,'YLim',[0 75]);
            %set(gca,'YTick',[0:5:75]);
            % Limit decimals in X and Y axis numbers
            set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
            set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))
            
            %# Line width
            set(h(1),'linewidth',1);
            set(h(2),'linewidth',2);
            
            %# Legend
            hleg1 = legend('Output (real units)','Trendline');
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','tex');
            set(hleg1,'LineWidth',1);
            set(hleg1,'FontSize',setLegendFontSize);
            %legend boxoff;
            
            %# Font sizes and border --------------------------------------------------
            
            set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
            
            % Outboard PST ------------------------------------------------
            subplot(3,1,2);
            
            % Axis data
            x = timeData;
            y = Raw_CH_20_PSTOutboard;
            
            %# Trendline
            polyf = polyfit(x,y,1);
            polyv = polyval(polyf,x);
            
            h = plot(x,y,'-',x,polyv,'-');
            title('{\bf Outboard Pitot-Static Tube}','FontSize',setGeneralFontSize);
            xlabel('{\bf Time (seconds)}','FontSize',setGeneralFontSize);
            ylabel('{\bf PST output (V)}','FontSize',setGeneralFontSize);
            grid on;
            box on;
            %axis square;
            
            %# Line, colors and markers
            setCurveNo=1;set(h(setCurveNo),'Color',setColor{2},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setCurveNo=2;set(h(setCurveNo),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
            
            %# Axis limitations
            xlim([min(x) max(x)]);
            %set(gca,'XTick',[min(x):0.2:max(x)]);
            %set(gca,'YLim',[0 75]);
            %set(gca,'YTick',[0:5:75]);
            % Limit decimals in X and Y axis numbers
            set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
            set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))
            
            %# Line width
            set(h(1),'linewidth',1);
            set(h(2),'linewidth',2);
            
            %# Legend
            hleg1 = legend('Output (real units)','Trendline');
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','tex');
            set(hleg1,'LineWidth',1);
            set(hleg1,'FontSize',setLegendFontSize);
            %legend boxoff;
            
            %# Font sizes and border --------------------------------------------------
            
            set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
            
            % Compared Inboard/Outboard PST -------------------------------
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
            
            h = plot(x,y1,'-',x,y2,'-',x,polyv1,'-',x,polyv2,'-');
            title('{\bf Overlayed Inboard/Outboard Pitot-Static Tube}','FontSize',setGeneralFontSize);
            xlabel('{\bf Time (seconds)}','FontSize',setGeneralFontSize);
            ylabel('{\bf PST output (V)}','FontSize',setGeneralFontSize);
            grid on;
            box on;
            %axis square;
            
            %# Line, colors and markers
            setCurveNo=1;set(h(setCurveNo),'Color',setColor{3},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setCurveNo=2;set(h(setCurveNo),'Color',setColor{2},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setCurveNo=3;set(h(setCurveNo),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
            setCurveNo=4;set(h(setCurveNo),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
            
            %# Axis limitations
            xlim([min(x) max(x)]);
            %set(gca,'XTick',[min(x):0.2:max(x)]);
            %set(gca,'YLim',[0 75]);
            %set(gca,'YTick',[0:5:75]);
            % Limit decimals in X and Y axis numbers
            set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
            set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))
            
            %# Line width
            set(h(1),'linewidth',1);
            set(h(2),'linewidth',1);
            set(h(3),'linewidth',2);
            set(h(4),'linewidth',2);
            
            %# Legend
            hleg1 = legend('Inboard Output','Outboard Output','Inboard Trendline','Outboard Trendline');
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','tex');
            set(hleg1,'LineWidth',1);
            set(hleg1,'FontSize',setLegendFontSize);
            %legend boxoff;
            
            %# Font sizes and border --------------------------------------------------
            
            set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
            
            %# ************************************************************
            %# Command Window Output
            %# ************************************************************
            if enableCommandWindowOutput == 1
                
                % Inboard PST
                MeanData = CH_19_PSTInboard_Mean;
                CHData   = CH_19_PSTInboard;
                
                avginbpst = sprintf('%s:: Inboard PST (Averaged): %s (V)', runno, sprintf('%.2f',MeanData));
                mininbpst = sprintf('%s:: Inboard PST (Minimum): %s (V)', runno, sprintf('%.2f',min(CHData)));
                maxinbpst = sprintf('%s:: Inboard PST (Maximum): %s (V)', runno, sprintf('%.2f',max(CHData)));
                ptainbpst = sprintf('%s:: Diff. min to avg: %s (percent)%', runno, sprintf('%.2f',100*abs(1-(min(CHData)/MeanData))));
                stdinbpst = sprintf('%s:: Standard deviation: %s (V)', runno, sprintf('%.4f',std(CHData,1)));
                
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
                stdoutbbpst = sprintf('%s:: Standard deviation: %s (V)', runno, sprintf('%.4f',std(CHData,1)));
                
                disp(avgoutbbpst);
                disp(minoutbbpst);
                disp(maxoutbbpst);
                disp(ptaoutbbpst);
                disp(stdoutbbpst);
                
                disp('/////////////////////////////////////////////////');
                
            end
            
            %# ************************************************************
            %# Save data to aray then save to file
            %# ************************************************************
            
            %# Add results to dedicated array for simple export
            %# Results array columns:
            %[1]  Run No.
            
            %[2]  Froude length Number                     (-)
            %[3]  Speed no. (i.e. 1=0.30, 2=0.35, 3=0.40)  (-)
            %[4]  Depth no. (i.e. 1 to 8)                  (-)
            
            %[5]  Channel
            %[6]  INBOARD PST: Averaged            (V)
            %[7]  INBOARD PST: Minimum             (V)
            %[8]  INBOARD PST: Maximum             (V)
            %[9]  INBOARD PST: Diff. min to avg    (percent)
            %[10] INBOARD PST: Standard deviation  (V)
            
            %[11] INBOARD PST: Zero value          (V)
            %[12] INBOARD PST: Calibration factor  (-)
            
            %[13] Channel
            %[14] OUTBOARD PST: Averaged           (V)
            %[15] OUTBOARD PST: Minimum            (V)
            %[16] OUTBOARD PST: Maximum            (V)
            %[17] OUTBOARD PST: Diff. min to avg   (percent)
            %[18] OUTBOARD PST: Standard deviation (V)
            
            %[19] OUTBOARD PST: Zero value         (V)
            %[20] OUTBOARD PST: Calibration factor (-)
            
            % General data
            resultsArrayBlmTS(k, 1)  = k;
            
            % Froude length number
            roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                          % Round averaged speed to two (2) decimals only
            modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
            resultsArrayBlmTS(k, 2)  = modelfrrounded;
            
            % Speed and depth number
            resultsArrayBlmTS(k, 3)  = setSpeedCond;
            resultsArrayBlmTS(k, 4)  = setDepthCond;
            
            % Inboard -----------------------------------------------------
            MeanData = CH_19_PSTInboard_Mean;
            CHData   = CH_19_PSTInboard;
            
            resultsArrayBlmTS(k, 5)  = 19;
            resultsArrayBlmTS(k, 6)  = MeanData;
            resultsArrayBlmTS(k, 7)  = min(CHData);
            resultsArrayBlmTS(k, 8)  = max(CHData);
            resultsArrayBlmTS(k, 9)  = abs(1-(min(CHData)/MeanData));
            resultsArrayBlmTS(k, 10) = std(CHData,1);
            
            % Inboard CF and zero
            resultsArrayBlmTS(k, 11)  = CH_19_Zero;
            resultsArrayBlmTS(k, 12)  = CH_19_CF;
            
            % Outboard ----------------------------------------------------
            MeanData = CH_20_PSTOutboard_Mean;
            CHData   = CH_20_PSTOutboard;
            
            resultsArrayBlmTS(k, 13) = 20;
            resultsArrayBlmTS(k, 14) = MeanData;
            resultsArrayBlmTS(k, 15) = min(CHData);
            resultsArrayBlmTS(k, 16) = max(CHData);
            resultsArrayBlmTS(k, 17) = abs(1-(min(CHData)/MeanData));
            resultsArrayBlmTS(k, 18) = std(CHData,1);
            
            % Outboard CF and zero
            resultsArrayBlmTS(k, 19) = CH_20_Zero;
            resultsArrayBlmTS(k, 20) = CH_20_CF;
            
            %# ************************************************************
            %# Save plot as PNG
            %# ************************************************************
            
            %# Figure size on screen (50% scaled, but same aspect ratio)
            set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
            
            %# Figure size printed on paper
            if enableA4PaperSizePlot == 1
                set(gcf, 'PaperUnits','centimeters');
                set(gcf, 'PaperSize',[XPlot YPlot]);
                set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
                set(gcf, 'PaperOrientation','portrait');
            end
            
            %# Plot title -------------------------------------------------
            annotation('textbox', [0 0.9 1 0.1], ...
                'String', strcat('{\bf ', figurename, '}'), ...
                'EdgeColor', 'none', ...
                'HorizontalAlignment', 'center');
            
            %# Save plots as PDF, PNG and EPS -----------------------------
            
            % Enable renderer for vector graphics output
            set(gcf, 'renderer', 'painters');
            setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
            setFileFormat = {'PDF' 'PNG' 'EPS'};
            for kl=1:3
                plotsavename = sprintf('_plots/%s/%s/Run_%s_CH_19-20_Bounday_Layer.%s', 'Bounday_Layer_TS', setFileFormat{kl}, num2str(k), setFileFormat{kl});
                print(gcf, setSaveFormat{kl}, plotsavename);
            end
            close;
            
        end
        
        %wtot = endRun - startRun;
        %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
    end
    
    %# ////////////////////////////////////////////////////////////////////////
    %# START: Write results to CVS
    %# ------------------------------------------------------------------------
    
    % Velocities and read unit data
    M = resultsArrayBlm;
    M = M(any(M,2),:);                           % Remove zero rows
    csvwrite('resultsArrayBlm.dat', M)           % Export matrix M to a file delimited by the comma character
    if exist('resultsArrayBlm_Repo.dat', 'file') == 0
        csvwrite('resultsArrayBlm_Repo.dat', M)  % Export matrix M to a file delimited by the comma character
    end
    
    % Time series data, min, max, diff. to avg., STDev, CF and zero values
    M = resultsArrayBlmTS;
    M = M(any(M,2),:);                           % Remove zero rows
    csvwrite('resultsArrayBlmTS.dat', M)         % Export matrix M to a file delimited by the comma character
    
    %# ------------------------------------------------------------------------
    %# END Write results to CVS
    %# ////////////////////////////////////////////////////////////////////////
    
    %# Close progress bar
    %close(w);
    
end

%# ////////////////////////////////////////////////////////////////////////
%# START Plotting boundary layer
%# ------------------------------------------------------------------------

% Array manipulations -----------------------------------------------------

%# Array manipulation: Split by speed
RA = resultsArrayBlm;
RA = RA(any(RA,2),:);
A  = arrayfun(@(x) RA(RA(:,3) == x, :), unique(RA(:,3)), 'uniformoutput', false);

% Array manipulations -----------------------------------------------------

if enableAveragedRunsPlot1 == 1 || enableAveragedRunsPlot2 == 1
    
    %# Array manipulation: Split by Distance from model hull (for repeated runs)
    
    %# Results array columns:
    %[1]  Distance from model hull                  (mm)
    
    %[2]  INBOARD:  Averaged zero value             (V)
    %[3]  OUTBOARD: veraged zero value              (V)
    
    %[4]  INBOARD PST: Voltage (Inboard)            (V)
    %[5]  OUTBOARD PST: Voltage (Outboard)          (V)
    
    %[6]  INBOARD PST: Real units using CF          (m/s)
    %[7]  OUTBOARD PST: Real units using CF         (m/s)
    
    %[8]  INBOARD: U/U0                             (-)
    %[9]  OUTBOARD: U/U0                            (-)
    
    %[10] Averaged inboard and outboard speed       (m/s)
    %[11] u/U0 using averaged speed                 (-)
    
    %[12] INBOARD: log10(V/Vm)                      (-)
    %[13] INBOARD: Log(y)                           (-)
    
    %[14] OUTBOARD: log10(V/Vm)                     (-)
    %[15] OUTBOARD: Log(y)                          (-)
    
    %[16] AVERAGED: log10(V/Vm)                     (-)
    %[17] AVERAGED: Log(y)                          (-)
    
    %[18] Ship speed                                (m/s)
    
    SpeedFr30Avg = [];
    SpeedFr35Avg = [];
    SpeedFr40Avg = [];
    
    %# Fr=0.30 ----------------------------------------------------------------
    RA1 = A{1};
    A1  = arrayfun(@(x) RA1(RA1(:,4) == x, :), unique(RA1(:,4)), 'uniformoutput', false);
    [m1,n1] = size(A1);
    
    % Average repeated runs
    for k=1:m1
        InBSpeed  = mean(A1{k}(:,11));
        OuBSpeed  = mean(A1{k}(:,12));
        avgSpeed  = mean([InBSpeed OuBSpeed]);
        shipSpeed = mean(A1{k}(:,16));
        distHull  = A1{k}(1,4);
        SpeedFr30Avg(k, 1)  = distHull;
        SpeedFr30Avg(k, 2)  = mean(A1{k}(:,5));
        SpeedFr30Avg(k, 3)  = mean(A1{k}(:,6));
        SpeedFr30Avg(k, 4)  = mean(A1{k}(:,9));
        SpeedFr30Avg(k, 5)  = mean(A1{k}(:,10));
        SpeedFr30Avg(k, 6)  = InBSpeed;
        SpeedFr30Avg(k, 7)  = OuBSpeed;
        SpeedFr30Avg(k, 8)  = mean(A1{k}(:,13));
        SpeedFr30Avg(k, 9)  = mean(A1{k}(:,14));
        SpeedFr30Avg(k, 10) = avgSpeed;
        SpeedFr30Avg(k, 11) = avgSpeed/shipSpeed;
        SpeedFr30Avg(k, 12) = log10(InBSpeed/shipSpeed);
        SpeedFr30Avg(k, 13) = log10(distHull);
        SpeedFr30Avg(k, 14) = log10(OuBSpeed/shipSpeed);
        SpeedFr30Avg(k, 15) = log10(distHull);
        SpeedFr30Avg(k, 16) = log10(avgSpeed/shipSpeed);
        SpeedFr30Avg(k, 17) = log10(distHull);
        SpeedFr30Avg(k, 18) = shipSpeed;
    end
    
    %# Fr=0.35 ----------------------------------------------------------------
    RA2 = A{2};
    A2 = arrayfun(@(x) RA2(RA2(:,4) == x, :), unique(RA2(:,4)), 'uniformoutput', false);
    [m2,n2] = size(A2);
    
    % Average repeated runs
    for k=1:m2
        InBSpeed  = mean(A2{k}(:,11));
        OuBSpeed  = mean(A2{k}(:,12));
        avgSpeed  = mean([InBSpeed OuBSpeed]);
        shipSpeed = mean(A2{k}(:,16));
        distHull  = A2{k}(1,4);
        SpeedFr35Avg(k, 1)  = distHull;
        SpeedFr35Avg(k, 2)  = mean(A2{k}(:,5));
        SpeedFr35Avg(k, 3)  = mean(A2{k}(:,6));
        SpeedFr35Avg(k, 4)  = mean(A2{k}(:,9));
        SpeedFr35Avg(k, 5)  = mean(A2{k}(:,10));
        SpeedFr35Avg(k, 6)  = InBSpeed;
        SpeedFr35Avg(k, 7)  = OuBSpeed;
        SpeedFr35Avg(k, 8)  = mean(A2{k}(:,13));
        SpeedFr35Avg(k, 9)  = mean(A2{k}(:,14));
        SpeedFr35Avg(k, 10) = avgSpeed;
        SpeedFr35Avg(k, 11) = avgSpeed/shipSpeed;
        SpeedFr35Avg(k, 12) = log10(InBSpeed/shipSpeed);
        SpeedFr35Avg(k, 13) = log10(distHull);
        SpeedFr35Avg(k, 14) = log10(OuBSpeed/shipSpeed);
        SpeedFr35Avg(k, 15) = log10(distHull);
        SpeedFr35Avg(k, 16) = log10(avgSpeed/shipSpeed);
        SpeedFr35Avg(k, 17) = log10(distHull);
        SpeedFr35Avg(k, 18) = shipSpeed;
    end
    
    %# Fr=0.40 ----------------------------------------------------------------
    RA3 = A{3};
    A3  = arrayfun(@(x) RA3(RA3(:,4) == x, :), unique(RA3(:,4)), 'uniformoutput', false);
    [m3,n3] = size(A3);
    
    % Average repeated runs
    for k=1:m3
        InBSpeed  = mean(A3{k}(:,11));
        OuBSpeed  = mean(A3{k}(:,12));
        avgSpeed  = mean([InBSpeed OuBSpeed]);
        shipSpeed = mean(A3{k}(:,16));
        distHull  = A3{k}(1,4);
        SpeedFr40Avg(k, 1)  = distHull;
        SpeedFr40Avg(k, 2)  = mean(A3{k}(:,5));
        SpeedFr40Avg(k, 3)  = mean(A3{k}(:,6));
        SpeedFr40Avg(k, 4)  = mean(A3{k}(:,9));
        SpeedFr40Avg(k, 5)  = mean(A3{k}(:,10));
        SpeedFr40Avg(k, 6)  = InBSpeed;
        SpeedFr40Avg(k, 7)  = OuBSpeed;
        SpeedFr40Avg(k, 8)  = mean(A3{k}(:,13));
        SpeedFr40Avg(k, 9)  = mean(A3{k}(:,14));
        SpeedFr40Avg(k, 10) = avgSpeed;
        SpeedFr40Avg(k, 11) = avgSpeed/shipSpeed;
        SpeedFr40Avg(k, 12) = log10(InBSpeed/shipSpeed);
        SpeedFr40Avg(k, 13) = log10(distHull);
        SpeedFr40Avg(k, 14) = log10(OuBSpeed/shipSpeed);
        SpeedFr40Avg(k, 15) = log10(distHull);
        SpeedFr40Avg(k, 16) = log10(avgSpeed/shipSpeed);
        SpeedFr40Avg(k, 17) = log10(distHull);
        SpeedFr40Avg(k, 18) = shipSpeed;
    end
    
end % enableAveragedRunsPlot1 == 1 || enableAveragedRunsPlot2 == 1


%# ************************************************************************
%# 1. Log10(y) vs. log10(V/Vm)
%# ************************************************************************

slopeInterceptArray = [];

figurename = 'Plot 1: Log10(y) vs. log10(V/Vm)';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

%if enableA4PaperSizePlot == 1
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);
%end

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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end
setLineStyle  = {'-';'--';'-.';':';'-';'--';'-.';':';'-';'--'};

%# Line, colors and markers
setMarkerSize      = 10;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
subplot(2,2,1)

% X and Y values ----------------------------------------------------------

% Axis data:
%    Subscript i = inboard and
%    Subscript o = outboard

%# Fr=0.30 ----------------------------------------------------------------
x1  = SpeedFr30Avg(1:5,12);
y1  = SpeedFr30Avg(1:5,13);

[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1                  = coeffvalues(fitobject1);

if enableCommandWindowOutput == 1
    cval = cvalues1;
    gof  = gof1;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn1 = sprintf('F_{r}=0.30 (Inboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn1);
end

% Write to array
slopeInterceptArray(1,1) = 0.30;
slopeInterceptArray(1,2) = cvalues1(1);
slopeInterceptArray(1,3) = cvalues1(2);

%# Fr=0.35 ----------------------------------------------------------------
x2  = SpeedFr35Avg(1:5,12);
y2  = SpeedFr35Avg(1:5,13);

[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2                  = coeffvalues(fitobject2);

if enableCommandWindowOutput == 1
    cval = cvalues2;
    gof  = gof2;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn2 = sprintf('F_{r}=0.35 (Inboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn2);
end

% Write to array
slopeInterceptArray(2,1) = 0.35;
slopeInterceptArray(2,2) = cvalues2(1);
slopeInterceptArray(2,3) = cvalues2(2);

%# Fr=0.40 ----------------------------------------------------------------
x3  = SpeedFr40Avg(1:5,12);
y3  = SpeedFr40Avg(1:5,13);

[fitobject3,gof3,output3] = fit(x3,y3,'poly1');
cvalues3                  = coeffvalues(fitobject3);

if enableCommandWindowOutput == 1
    cval = cvalues3;
    gof  = gof3;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn3 = sprintf('F_{r}=0.40 (Inboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn3);
end

% Write to array
slopeInterceptArray(3,1) = 0.30;
slopeInterceptArray(3,2) = cvalues3(1);
slopeInterceptArray(3,3) = cvalues3(2);

% Plotting ----------------------------------------------------------------
%# Fr=0.30
h1 = plot(fitobject1,'-',x1,y1,'*');
legendInfo{1}  = 'F_{r}=0.30';
legendInfo{2}  = 'F_{r}=0.30 Linear fit';
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle1,'linewidth',setLineWidth);
%# Fr=0.35
hold on;
h2 = plot(fitobject2,'-',x2,y2,'*');
legendInfo{3}  = 'F_{r}=0.35';
legendInfo{4}  = 'F_{r}=0.35 Linear fit';
set(h2(1),'Color',setColor{1},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
%# Fr=0.40
hold on;
h3 = plot(fitobject3,'-',x3,y3,'*');
legendInfo{5}  = 'F_{r}=0.40';
legendInfo{6}  = 'F_{r}=0.40 Linear fit';
set(h3(1),'Color',setColor{1},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h3(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidth);
%if enablePlotTitle == 1
title('{\bf Inboard}','FontSize',setGeneralFontSize);
%end
xlabel('{\bf log10(V/Vm) (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf log10(y) (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
% setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
% setSpeed=2;set(h2(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% setSpeed=3;set(h3(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(-0.2,0.15,EoFEqn1,'FontSize',12,'color','k','FontWeight','normal');
text(-0.2,0.05,EoFEqn2,'FontSize',12,'color','k','FontWeight','normal');
text(-0.2,-0.05,EoFEqn3,'FontSize',12,'color','k','FontWeight','normal');

% Axis limitations
minX  = -0.2;
maxX  = 0.05;
incrX = 0.05;
minY  = 0.4;
maxY  = 2;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%hleg1 = legend('F_{r}=0.30','F_{r}=0.35','F_{r}=0.40');
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

% SUBPLOT /////////////////////////////////////////////////////////////////
subplot(2,2,2)

% X and Y values ----------------------------------------------------------

% Axis data:
%    Subscript i = inboard and
%    Subscript o = outboard

%# Fr=0.30 ----------------------------------------------------------------
x1  = SpeedFr30Avg(1:5,14);
y1  = SpeedFr30Avg(1:5,15);

[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1                  = coeffvalues(fitobject1);

if enableCommandWindowOutput == 1
    cval = cvalues1;
    gof  = gof1;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn1 = sprintf('F_{r}=0.30 (Outboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn1);
end

%# Fr=0.35 ----------------------------------------------------------------
x2  = SpeedFr35Avg(1:5,14);
y2  = SpeedFr35Avg(1:5,15);

[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2                  = coeffvalues(fitobject2);

if enableCommandWindowOutput == 1
    cval = cvalues2;
    gof  = gof2;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn2 = sprintf('F_{r}=0.35 (Outboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn2);
end

%# Fr=0.40 ----------------------------------------------------------------
x3  = SpeedFr40Avg(1:5,14);
y3  = SpeedFr40Avg(1:5,15);

[fitobject3,gof3,output3] = fit(x3,y3,'poly1');
cvalues3                  = coeffvalues(fitobject3);

if enableCommandWindowOutput == 1
    cval = cvalues3;
    gof  = gof3;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn3 = sprintf('F_{r}=0.40 (Outboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn3);
end

% Plotting ----------------------------------------------------------------
%# Fr=0.30
h1 = plot(fitobject1,'-',x1,y1,'*');
legendInfo{1}  = 'F_{r}=0.30';
legendInfo{2}  = 'F_{r}=0.30 Linear fit';
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle1,'linewidth',setLineWidth);
%# Fr=0.35
hold on;
h2 = plot(fitobject2,'-',x2,y2,'*');
legendInfo{3}  = 'F_{r}=0.35';
legendInfo{4}  = 'F_{r}=0.35 Linear fit';
set(h2(1),'Color',setColor{1},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
%# Fr=0.40
hold on;
h3 = plot(fitobject3,'-',x3,y3,'*');
legendInfo{5}  = 'F_{r}=0.40';
legendInfo{6}  = 'F_{r}=0.40 Linear fit';
set(h3(1),'Color',setColor{1},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h3(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidth);
%if enablePlotTitle == 1
title('{\bf Outboard}','FontSize',setGeneralFontSize);
%end
xlabel('{\bf log10(V/Vm) (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf log10(y) (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
%setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
%setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(-0.2,0.15,EoFEqn1,'FontSize',12,'color','k','FontWeight','normal');
text(-0.2,0.05,EoFEqn2,'FontSize',12,'color','k','FontWeight','normal');
text(-0.2,-0.05,EoFEqn3,'FontSize',12,'color','k','FontWeight','normal');

% Axis limitations
minX  = -0.2;
maxX  = 0.05;
incrX = 0.05;
minY  = 0.4;
maxY  = 2;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%hleg1 = legend('F_{r}=0.30','F_{r}=0.35','F_{r}=0.40');
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

% SUBPLOT /////////////////////////////////////////////////////////////////
subplot(2,2,[3 4])

% X and Y values ----------------------------------------------------------

% Axis data:
%    Subscript i = inboard and
%    Subscript o = outboard

%# Fr=0.30 ----------------------------------------------------------------
x1  = SpeedFr30Avg(1:5,16);
y1  = SpeedFr30Avg(1:5,17);

[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1                  = coeffvalues(fitobject1);

if enableCommandWindowOutput == 1
    cval = cvalues1;
    gof  = gof1;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn1 = sprintf('F_{r}=0.30 (Averaged): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn1);
end

%# Fr=0.35 ----------------------------------------------------------------
x2  = SpeedFr35Avg(1:5,16);
y2  = SpeedFr35Avg(1:5,17);

[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2                  = coeffvalues(fitobject2);

if enableCommandWindowOutput == 1
    cval = cvalues2;
    gof  = gof2;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn2 = sprintf('F_{r}=0.35 (Averaged): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn2);
end

%# Fr=0.40 ----------------------------------------------------------------
x3  = SpeedFr40Avg(1:5,16);
y3  = SpeedFr40Avg(1:5,17);

[fitobject3,gof3,output3] = fit(x3,y3,'poly1');
cvalues3                  = coeffvalues(fitobject3);

if enableCommandWindowOutput == 1
    cval = cvalues3;
    gof  = gof3;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.2f',gof.rsquare);
    EoFEqn3 = sprintf('F_{r}=0.40 (Averaged): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn3);
end

% Plotting ----------------------------------------------------------------
%# Fr=0.30
h1 = plot(fitobject1,'-',x1,y1,'*');
legendInfo{1}  = 'F_{r}=0.30';
legendInfo{2}  = 'F_{r}=0.30 Linear fit';
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle1,'linewidth',setLineWidth);
%# Fr=0.35
hold on;
h2 = plot(fitobject2,'-',x2,y2,'*');
legendInfo{3}  = 'F_{r}=0.35';
legendInfo{4}  = 'F_{r}=0.35 Linear fit';
set(h2(1),'Color',setColor{1},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
%# Fr=0.40
hold on;
h3 = plot(fitobject3,'-',x3,y3,'*');
legendInfo{5}  = 'F_{r}=0.40';
legendInfo{6}  = 'F_{r}=0.40 Linear fit';
set(h3(1),'Color',setColor{1},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h3(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidth);
%if enablePlotTitle == 1
title('{\bf Averaged speeds}','FontSize',setGeneralFontSize);
%end
xlabel('{\bf log10(V/Vm) (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf log10(y) (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
%setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
%setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(-0.2,0.15,EoFEqn1,'FontSize',12,'color','k','FontWeight','normal');
text(-0.2,0.05,EoFEqn2,'FontSize',12,'color','k','FontWeight','normal');
text(-0.2,-0.05,EoFEqn3,'FontSize',12,'color','k','FontWeight','normal');

% Axis limitations
minX  = -0.2;
maxX  = 0.05;
incrX = 0.05;
minY  = 0.4;
maxY  = 2;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%hleg1 = legend('F_{r}=0.30','F_{r}=0.35','F_{r}=0.40');
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
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
%if enableA4PaperSizePlot == 1
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');
%end

%# Plot title ---------------------------------------------------------
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
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Log10_y_vs_Log10_V_Vm_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 1.1 Log10(y) vs. log10(V/Vm) - Thesis Plot
%# ************************************************************************

slopeInterceptArray = [];

figurename = sprintf('Plot 1.1: %s:: Log10(y) vs. log10(V/Vm)', testName);
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end
setLineStyle  = {'-';'--';'-.';':';'-';'--';'-.';':';'-';'--'};

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Axis data:
%    Subscript i = inboard and
%    Subscript o = outboard

%# Fr=0.30 ----------------------------------------------------------------
x1  = SpeedFr30Avg(1:5,12);
y1  = SpeedFr30Avg(1:5,13);

[fitobject1,gof1,output1] = fit(x1,y1,'poly1');
cvalues1                  = coeffvalues(fitobject1);

if enableCommandWindowOutput == 1
    cval = cvalues1;
    gof  = gof1;
    setDecimals1 = '%0.2f';
    setDecimals2 = '+%0.2f';
    if cval(1) < 0
        setDecimals1 = '%0.2f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.2f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.1f',gof.rsquare);
    EoFEqn1 = sprintf('F_{r}=0.30 (Inboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn1);
end

% Write to array
slopeInterceptArray(1,1) = 0.30;
slopeInterceptArray(1,2) = cvalues1(1);
slopeInterceptArray(1,3) = cvalues1(2);

%# Fr=0.35 ----------------------------------------------------------------
x2  = SpeedFr35Avg(1:5,12);
y2  = SpeedFr35Avg(1:5,13);

[fitobject2,gof2,output2] = fit(x2,y2,'poly1');
cvalues2                  = coeffvalues(fitobject2);

if enableCommandWindowOutput == 1
    cval = cvalues2;
    gof  = gof2;
    setDecimals1 = '%0.2f';
    setDecimals2 = '+%0.2f';
    if cval(1) < 0
        setDecimals1 = '%0.2f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.2f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.1f',gof.rsquare);
    %EoFEqn2 = sprintf('F_{r}=0.35 (Inboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    EoFEqn2 = sprintf('\\bf Linear fit: \\rm y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn2);
end

% Write to array
slopeInterceptArray(2,1) = 0.35;
slopeInterceptArray(2,2) = cvalues2(1);
slopeInterceptArray(2,3) = cvalues2(2);

%# Fr=0.40 ----------------------------------------------------------------
x3  = SpeedFr40Avg(1:5,12);
y3  = SpeedFr40Avg(1:5,13);

[fitobject3,gof3,output3] = fit(x3,y3,'poly1');
cvalues3                  = coeffvalues(fitobject3);

if enableCommandWindowOutput == 1
    cval = cvalues3;
    gof  = gof3;
    setDecimals1 = '%0.2f';
    setDecimals2 = '+%0.2f';
    if cval(1) < 0
        setDecimals1 = '%0.2f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.2f';
    end
    p1      = sprintf(setDecimals1,cval(1));
    p2      = sprintf(setDecimals2,cval(2));
    gofrs   = sprintf('%0.1f',gof.rsquare);
    EoFEqn3 = sprintf('F_{r}=0.40 (Inboard): y=%sx%s | R^2: %s',p1,p2,gofrs);
    disp(EoFEqn3);
end

% Write to array
slopeInterceptArray(3,1) = 0.30;
slopeInterceptArray(3,2) = cvalues3(1);
slopeInterceptArray(3,3) = cvalues3(2);

% Plotting ----------------------------------------------------------------
%# Fr=0.35
h2 = plot(fitobject2,'-',x2,y2,'*');
legendInfo11{1}  = 'Speed #2: F_{r}=0.35';
legendInfo11{2}  = 'Speed #2: F_{r}=0.35, linear fit';
set(h2(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
% if enablePlotTitle == 1
%     title('{\bf Inboard}','FontSize',setGeneralFontSize);
% end
xlabel('{\bf log_{10}(V/V_{m}) (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf log_{10}(Y) (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(-0.09,0.9,EoFEqn2,'FontSize',12,'color','k','FontWeight','normal');

% Axis limitations
minX  = -0.2;
maxX  = 0.05;
incrX = 0.05;
minY  = 0.4;
maxY  = 1.8;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo11);
set(hleg1,'Location','NorthWest');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_1_1_Single_Log10_y_vs_Log10_V_Vm_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ------------------------------------------------------------------------
%# END Plotting boundary layer
%# ************************************************************************


%# ************************************************************************
%# Calculate Boundary Layer Thickness (BLT)
%# ************************************************************************
%# NOTE: See Excel file:
%#       >> "Run Sheet - Self-Propulsion Test.xlsx"
%#       -> Worksheet "3 Boundary Layer PP"
%# ************************************************************************
[m,n] = size(slopeInterceptArray);

Log10VVInfArray = -0.1:0.01:0.02;
[ml,nl] = size(Log10VVInfArray);

Fr30SA = [];
Fr35SA = [];
Fr40SA = [];
% FrXXSA columns (BLT where Log10(V/VInf)=0):
%[1] Log10(V/VInf)      (-)
%[2] Log10(Y)           (-)
%[3] Inv Log10 Y        (-)
%[4] Inv Log10 X        (-)
%[5] V                  (m/s)
BLTArray = [];
% BLTArray columns:
%[1] Froude length number       (-)
%[2] Speed                      (m/s)
%[3] Boundary layer thickness   (mm)
for k=1:m
    Slope        = slopeInterceptArray(k,2);
    Intercept    = slopeInterceptArray(k,3);
    AvgShipSpeed = mean(A{k}(:,16));
    for kl=1:nl
        LogV_Vm  = Log10VVInfArray(kl);
        LogY     = Slope*Log10VVInfArray(kl)+Intercept;
        InvLogY  = 10^LogY;
        InvLogX  = 10^LogV_Vm;
        ResSpeed = InvLogX*AvgShipSpeed;
        if k == 1
            Fr30SA(kl,1) = LogV_Vm;
            Fr30SA(kl,2) = LogY;
            Fr30SA(kl,3) = InvLogY;
            Fr30SA(kl,4) = InvLogX;
            Fr30SA(kl,5) = ResSpeed;
        elseif k == 2
            Fr35SA(kl,1) = LogV_Vm;
            Fr35SA(kl,2) = LogY;
            Fr35SA(kl,3) = InvLogY;
            Fr35SA(kl,4) = InvLogX;
            Fr35SA(kl,5) = ResSpeed;
        else
            Fr40SA(kl,1) = LogV_Vm;
            Fr40SA(kl,2) = LogY;
            Fr40SA(kl,3) = InvLogY;
            Fr40SA(kl,4) = InvLogX;
            Fr40SA(kl,5) = ResSpeed;
        end
        % Write estimated boundary layer thickness to array
        if LogV_Vm == 0
            BLTArray(k,1) = mean(A{k}(:,2));
            BLTArray(k,2) = ResSpeed;
            BLTArray(k,3) = InvLogY;
        end % LogV_Vm = 0
    end % kl=1:nl
end % k=1:m

% Display boundary layer thickness in command window
if enableCommandWindowOutput == 1
    disp(sprintf('Boundary layer thickness: Fr=0.30 = %s mm, Fr=0.35 = %s mm, Fr=0.40 = %s mm',sprintf('%0.1f',BLTArray(1,3)),sprintf('%0.1f',BLTArray(2,3)),sprintf('%0.1f',BLTArray(3,3))));
end

%# ************************************************************************
%# 2. Plot distance from hull vs. speed
%# ************************************************************************

figurename = 'Plot 2: Plot distance from hull vs. speed';
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>';'p';'h'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Axis data. Subscript i = inboard and o = outboard

%# Results array columns:
%[1]  Distance from model hull                 (mm)
%[2]  Averaged zero value (Inboard)            (V)
%[3]  Averaged zero value (Outboard)           (V)
%[4]  PST: Voltage (Inboard)                   (V)
%[5]  PST: Voltage (Outboard)                  (V)
%[6]  PST: Real speed using CF (Inboard)       (m/s)
%[7]  PST: Real speed using CF (Outboard)      (m/s)
%[8]  u/U0 (Inboard)                           (-)
%[9]  u/U0 (Outboard)                          (-)

%# Fr=0.30 ----------------------------------------------------------------
if enableAveragedRunsPlot1 == 1
    x1i = SpeedFr30Avg(:,6);
    y1i = SpeedFr30Avg(:,1);
    
    x1o = SpeedFr30Avg(:,7);
    y1o = SpeedFr30Avg(:,1);
else
    x1i  = A{1}(:,11);
    y1i  = A{1}(:,4);
    
    x1o  = A{1}(:,12);
    y1o  = A{1}(:,4);
end

%# Fr=0.35 ----------------------------------------------------------------
if enableAveragedRunsPlot1 == 1
    x2i = SpeedFr35Avg(:,6);
    y2i = SpeedFr35Avg(:,1);
    
    x2o = SpeedFr35Avg(:,7);
    y2o = SpeedFr35Avg(:,1);
else
    x2i  = A{2}(:,11);
    y2i  = A{2}(:,4);
    
    x2o  = A{2}(:,12);
    y2o  = A{2}(:,4);
end

%# Fr=0.40 ----------------------------------------------------------------
if enableAveragedRunsPlot1 == 1
    x3i = SpeedFr40Avg(:,6);
    y3i = SpeedFr40Avg(:,1);
    
    x3o = SpeedFr40Avg(:,7);
    y3o = SpeedFr40Avg(:,1);
else
    x3i  = A{3}(:,11);
    y3i  = A{3}(:,4);
    
    x3o  = A{3}(:,12);
    y3o  = A{3}(:,4);
end

%# Boundary layer data ----------------------------------------------------
%xBL = [A{1}(1,16) A{2}(1,16) A{3}(1,16)];
%yBL = [A{1}(1,15) A{2}(1,15) A{3}(1,15)];

xBL = [BLTArray(1,2) BLTArray(2,2) BLTArray(3,2)];
yBL = [BLTArray(1,3) BLTArray(2,3) BLTArray(3,3)];

% Plotting ----------------------------------------------------------------
h1 = plot(x1i,y1i,'*',x1o,y1o,'*',x2i,y2i,'*',x2o,y2o,'*',x3i,y3i,'*',x3o,y3o,'*');
if enableBLDepthMarker == 1
    hold on;
    h2 = plot(xBL,yBL,'*');
end
if enablePlotTitle == 1
    title('{\bf Speed vs. distance (Y) below hull}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Measured speed (m/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Vertical distance from model hull, Y (mm)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=4;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=5;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=6;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

% Boundary layer depth marker
if enableBLDepthMarker == 1
    set(h2(1),'Color',setColor{10},'Marker',setMarker{7},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker+1); %,'MarkerFaceColor',setColor{10}
end

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Axis limitations
minX  = 0.8;
maxX  = 2.8;
incrX = 0.2;
minY  = 0;
maxY  = 80;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
if enableBLDepthMarker == 1
    hleg1 = legend('F_{r}=0.30 Inboard','F_{r}=0.30 Outboard','F_{r}=0.35 Inboard','F_{r}=0.35 Outboard','F_{r}=0.40 Inboard','F_{r}=0.40 Outboard','Boundary layer thickness');
else
    hleg1 = legend('F_{r}=0.30 Inboard','F_{r}=0.30 Outboard','F_{r}=0.35 Inboard','F_{r}=0.35 Outboard','F_{r}=0.40 Inboard','F_{r}=0.40 Outboard');
end
set(hleg1,'Location','NorthWest');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_2_Boundary_Layer_Y_vs_Speed_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 3. Plot distance from hull vs. averaged speed
%# ************************************************************************

figurename = 'Plot 3: Plot distance from hull vs. averaged speed';
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>';'p';'h'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Averaged speeds ---------------------------------------------------------

%# Fr=0.30
x1  = SpeedFr30Avg(:,10);
y1  = SpeedFr30Avg(:,1);

%# Fr=0.35
x2  = SpeedFr35Avg(:,10);
y2  = SpeedFr35Avg(:,1);

%# Fr=0.40
x3  = SpeedFr40Avg(:,10);
y3  = SpeedFr40Avg(:,1);

% Boundary layer thickness markers ----------------------------------------
xBL = [A{1}(1,16) A{2}(1,16) A{3}(1,16)];
yBL = [A{1}(1,15) A{2}(1,15) A{3}(1,15)];

% Plotting ----------------------------------------------------------------
h1 = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
if enableBLDepthMarker == 1
    hold on;
    h2 = plot(xBL,yBL,'*');
end
if enablePlotTitle == 1
    title('{\bf Speed vs. distance (Y) below hull}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Measured speed (m/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Vertical distance from model hull, Y (mm)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

% Boundary layer depth marker
if enableBLDepthMarker == 1
    set(h2(1),'Color',setColor{10},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker+1); %,'MarkerFaceColor',setColor{10}
end

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Axis limitations
minX  = 0.8;
maxX  = 2.8;
incrX = 0.2;
minY  = 0;
maxY  = 80;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
if enableBLDepthMarker == 1
    hleg1 = legend('Speed #1: F_{r}=0.30','Speed #2: F_{r}=0.35','Speed #3: F_{r}=0.40','Boundary layer thickness (\delta)');
else
    hleg1 = legend('Speed #1: F_{r}=0.30','Speed #2: F_{r}=0.35','Speed #3: F_{r}=0.40');
end
set(hleg1,'Location','NorthWest');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_3_Boundary_Layer_Y_vs_Averaged_Speed_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 4. Plot speed vs. u/U0
%# ************************************************************************

figurename = 'Plot 4: Speed vs. u/U0';
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end
setLineStyle  = {'-';'--';'-.';':';'-';'--';'-.';':';'-';'--'};

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Axis data. Subscript i = inboard and o = outboard

%# Fr=0.30
if enableAveragedRunsPlot2 == 1
    x1i = SpeedFr30Avg(:,1);
    y1i = SpeedFr30Avg(:,8);
    
    x1o = SpeedFr30Avg(:,1);
    y1o = SpeedFr30Avg(:,9);
else
    x1i = A{1}(:,4);
    y1i = A{1}(:,13);
    
    x1o = A{1}(:,4);
    y1o = A{1}(:,14);
end

%# Fr=0.35
if enableAveragedRunsPlot2 == 1
    x2i = SpeedFr35Avg(:,1);
    y2i = SpeedFr35Avg(:,8);
    
    x2o = SpeedFr35Avg(:,1);
    y2o = SpeedFr35Avg(:,9);
else
    x2i = A{2}(:,4);
    y2i = A{2}(:,13);
    
    x2o = A{2}(:,4);
    y2o = A{2}(:,14);
end

%# Fr=0.40
if enableAveragedRunsPlot2 == 1
    x3i = SpeedFr40Avg(:,1);
    y3i = SpeedFr40Avg(:,8);
    
    x3o = SpeedFr40Avg(:,1);
    y3o = SpeedFr40Avg(:,9);
else
    x3i = A{3}(:,4);
    y3i = A{3}(:,13);
    
    x3o = A{3}(:,4);
    y3o = A{3}(:,14);
end

%# MARIN 112m BL data
if enableMARINBLData == 1
    xM = MARIN112mBLData(:,1);
    yM = MARIN112mBLData(:,2);
end

%# AMC LJ120E BL data (Brandner 2007)
if enableAMCLJ120EBLData == 1
    xAMCUS  = AMCLJ120EBLData(:,1);
    yAMCUS  = AMCLJ120EBLData(:,2);
    
    xAMC1   = AMCLJ120EBLData(:,3);
    yAMC1   = AMCLJ120EBLData(:,4);
    
    xAMC125 = AMCLJ120EBLData(:,5);
    yAMC125 = AMCLJ120EBLData(:,6);
    
    xAMC15  = AMCLJ120EBLData(:,7);
    yAMC15  = AMCLJ120EBLData(:,8);
    
    xAMC175 = AMCLJ120EBLData(:,9);
    yAMC175 = AMCLJ120EBLData(:,10);
    
    xAMC2   = AMCLJ120EBLData(:,11);
    yAMC2   = AMCLJ120EBLData(:,12);
end

% Plotting ----------------------------------------------------------------
h1 = plot(x1i,y1i,'*',x1o,y1o,'*',x2i,y2i,'*',x2o,y2o,'*',x3i,y3i,'*',x3o,y3o,'*');
%# MARIN 112m BL data
if enableMARINBLData == 1
    hold on;
    h2 = plot(xM,yM,'*');
end
%# AMC LJ120E BL data (Brandner 2007)
if enableAMCLJ120EBLData == 1
    hold on;
    h3 = plot(xAMCUS,yAMCUS,'*-',xAMC1,yAMC1,'*-',xAMC125,yAMC125,'*-',xAMC15,yAMC15,'*-',xAMC175,yAMC175,'*-',xAMC2,yAMC2,'*-');
end
if enablePlotTitle == 1
    title('{\bf Speed vs. distance (Y) below hull}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Vertical distance from model hull, Y (mm)}','FontSize',setGeneralFontSize);
ylabel('{\bf U/U_{0} (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=4;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=5;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=6;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# MARIN 112m BL data
if enableMARINBLData == 1
    setMarkerSize      = 8;
    setLineWidthMarker = 2;
    set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
    %set(h2(1),'Color',setColor{10},'Marker','<','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{10}
end

%# AMC LJ120E BL data (Brandner 2007)
if enableAMCLJ120EBLData == 1
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setSpeed=1;set(h3(setSpeed),'Color',setColor{10},'Marker','o','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--'); % ,'MarkerFaceColor',setColor{10}
    setSpeed=2;set(h3(setSpeed),'Color',setColor{10},'Marker','s','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.');
    setSpeed=3;set(h3(setSpeed),'Color',setColor{10},'Marker','d','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--');
    setSpeed=4;set(h3(setSpeed),'Color',setColor{10},'Marker','>','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.');
    setSpeed=5;set(h3(setSpeed),'Color',setColor{10},'Marker','p','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--');
    setSpeed=6;set(h3(setSpeed),'Color',setColor{10},'Marker','h','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.');
end

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Axis limitations
minX  = 0;
maxX  = 100;
incrX = 10;
minY  = 0.6;
maxY  = 1.1;
incrY = 0.1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%# MARIN boundary layer data
if enableMARINBLData == 1 && enableAMCLJ120EBLData == 0
    hleg1 = legend('Speed #1 (F_{r}=0.30 Inboard)','Speed #1 (F_{r}=0.30 Outboard)','Speed #2 (F_{r}=0.35 Inboard)','Speed #2 (F_{r}=0.35 Outboard)','Speed #3 (F_{r}=0.40 Inboard)','Speed #3 (F_{r}=0.40 Outboard)','MARIN 112m JHSV Cond. T1');
elseif enableMARINBLData == 0 && enableAMCLJ120EBLData == 1
    hleg1 = legend('Speed #1 (F_{r}=0.30 Inboard)','Speed #1 (F_{r}=0.30 Outboard)','Speed #2 (F_{r}=0.35 Inboard)','Speed #2 (F_{r}=0.35 Outboard)','Speed #3 (F_{r}=0.40 Inboard)','Speed #3 (F_{r}=0.40 Outboard)','AMC, Brandner (2007), Upstream BL','AMC, Brandner (2007), IVR 1.0','AMC, Brandner (2007), IVR 1.25','AMC, Brandner (2007), IVR 1.5','AMC, Brandner (2007), IVR 1.75','AMC, Brandner (2007), IVR 2.0');
elseif enableMARINBLData == 1 && enableAMCLJ120EBLData == 1
    hleg1 = legend('Speed #1 (F_{r}=0.30 Inboard)','Speed #1 (F_{r}=0.30 Outboard)','Speed #2 (F_{r}=0.35 Inboard)','Speed #2 (F_{r}=0.35 Outboard)','Speed #3 (F_{r}=0.40 Inboard)','Speed #3 (F_{r}=0.40 Outboard)','MARIN 112m JHSV Cond. T1','AMC, Brandner (2007), Upstream BL','AMC, Brandner (2007), IVR 1.0','AMC, Brandner (2007), IVR 1.25','AMC, Brandner (2007), IVR 1.5','AMC, Brandner (2007), IVR 1.75','AMC, Brandner (2007), IVR 2.0');
else
    hleg1 = legend('Speed #1 (F_{r}=0.30 Inboard)','Speed #1 (F_{r}=0.30 Outboard)','Speed #2 (F_{r}=0.35 Inboard)','Speed #2 (F_{r}=0.35 Outboard)','Speed #3 (F_{r}=0.40 Inboard)','Speed #3 (F_{r}=0.40 Outboard)');
end
set(hleg1,'Location','SouthEast');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_4_Boundary_Layer_Speed_vs_u_Uo_Ratio_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 5. Plot speed vs. (averaged) u/U0
%# ************************************************************************

figurename = 'Plot 5: Plot speed vs. (averaged) u/U0';
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end
setLineStyle  = {'-';'--';'-.';':';'-';'--';'-.';':';'-';'--'};

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Axis data. Subscript i = inboard and o = outboard

%# Fr=0.30
x1  = SpeedFr30Avg(:,1);
y1  = SpeedFr30Avg(:,11);

%# Fr=0.35
x2  = SpeedFr35Avg(:,1);
y2  = SpeedFr35Avg(:,11);

%# Fr=0.40
x3  = SpeedFr40Avg(:,1);
y3  = SpeedFr40Avg(:,11);

%# MARIN 112m BL data
if enableMARINBLData == 1
    xM = MARIN112mBLData(:,1);
    yM = MARIN112mBLData(:,2);
end

%# AMC LJ120E BL data (Brandner 2007)
if enableAMCLJ120EBLData == 1
    xAMCUS  = AMCLJ120EBLData(:,1);
    yAMCUS  = AMCLJ120EBLData(:,2);
    
    xAMC1   = AMCLJ120EBLData(:,3);
    yAMC1   = AMCLJ120EBLData(:,4);
    
    xAMC125 = AMCLJ120EBLData(:,5);
    yAMC125 = AMCLJ120EBLData(:,6);
    
    xAMC15  = AMCLJ120EBLData(:,7);
    yAMC15  = AMCLJ120EBLData(:,8);
    
    xAMC175 = AMCLJ120EBLData(:,9);
    yAMC175 = AMCLJ120EBLData(:,10);
    
    xAMC2   = AMCLJ120EBLData(:,11);
    yAMC2   = AMCLJ120EBLData(:,12);
end

% Plotting ----------------------------------------------------------------
h1 = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
%# MARIN 112m BL data
if enableMARINBLData == 1
    hold on;
    h2 = plot(xM,yM,'*');
end
%# AMC LJ120E BL data (Brandner 2007)
if enableAMCLJ120EBLData == 1
    hold on;
    h3 = plot(xAMCUS,yAMCUS,'*-',xAMC1,yAMC1,'*-',xAMC125,yAMC125,'*-',xAMC15,yAMC15,'*-',xAMC175,yAMC175,'*-',xAMC2,yAMC2,'*-');
end
if enablePlotTitle == 1
    title('{\bf Speed vs. distance (Y) below hull}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Vertical distance from model hull, Y (mm)}','FontSize',setGeneralFontSize);
ylabel('{\bf U/U_{0} (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# MARIN 112m BL data
if enableMARINBLData == 1
    setMarkerSize      = 8;
    setLineWidthMarker = 2;
    set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
end

%# AMC LJ120E BL data (Brandner 2007)
if enableAMCLJ120EBLData == 1
    setMarkerSize      = 8;
    setLineWidthMarker = 1;
    setSpeed=1;set(h3(setSpeed),'Color',setColor{10},'Marker','o','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--'); % ,'MarkerFaceColor',setColor{10}
    setSpeed=2;set(h3(setSpeed),'Color',setColor{10},'Marker','s','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.');
    setSpeed=3;set(h3(setSpeed),'Color',setColor{10},'Marker','d','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--');
    setSpeed=4;set(h3(setSpeed),'Color',setColor{10},'Marker','>','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.');
    setSpeed=5;set(h3(setSpeed),'Color',setColor{10},'Marker','p','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','--');
    setSpeed=6;set(h3(setSpeed),'Color',setColor{10},'Marker','h','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle','-.');
end

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Axis limitations
minX  = 0;
maxX  = 100;
incrX = 10;
minY  = 0.6;
maxY  = 1.1;
incrY = 0.1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%# MARIN boundary layer data
if enableMARINBLData == 1 && enableAMCLJ120EBLData == 0
    hleg1 = legend('Speed #1: F_{r}=0.30, Re=8.05x10^{6}','Speed #2: F_{r}=0.35, Re=9.39x10^{6}','Speed #3: F_{r}=0.40, Re=1.07x10^{7}','MARIN 112m JHSV: F_{r}=0.57, Re=2.53x10^{7}');
elseif enableMARINBLData == 0 && enableAMCLJ120EBLData == 1
    hleg1 = legend('Speed #1 (F_{r}=0.30)','Speed #2 (F_{r}=0.35)','Speed #3 (F_{r}=0.40)','AMC, Brandner (2007), Upstream BL','AMC, Brandner (2007), IVR 1.0','AMC, Brandner (2007), IVR 1.25','AMC, Brandner (2007), IVR 1.5','AMC, Brandner (2007), IVR 1.75','AMC, Brandner (2007), IVR 2.0');
elseif enableMARINBLData == 1 && enableAMCLJ120EBLData == 1
    hleg1 = legend('Speed #1 (F_{r}=0.30)','Speed #2 (F_{r}=0.35)','Speed #3 (F_{r}=0.40)','MARIN 112m JHSV Cond. T1','AMC, Brandner (2007), Upstream BL','AMC, Brandner (2007), IVR 1.0','AMC, Brandner (2007), IVR 1.25','AMC, Brandner (2007), IVR 1.5','AMC, Brandner (2007), IVR 1.75','AMC, Brandner (2007), IVR 2.0');
else
    hleg1 = legend('Speed #1 (F_{r}=0.30)','Speed #2 (F_{r}=0.35)','Speed #3 (F_{r}=0.40)');
end
set(hleg1,'Location','SouthEast');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_5_Boundary_Layer_Speed_vs_Averaged_u_Uo_Ratio_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 6. Boundary Layer Thickness
%# ************************************************************************

figurename = 'Plot 6: Boundary Layer Thickness';
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end
setLineStyle  = {'-';'--';'-.';':';'-';'--';'-.';':';'-';'--'};

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Averaged speeds ---------------------------------------------------------

%# Fr=0.30
x1  = SpeedFr30Avg(:,10);
y1  = SpeedFr30Avg(:,1);

%# Fr=0.35
x2  = SpeedFr35Avg(:,10);
y2  = SpeedFr35Avg(:,1);

%# Fr=0.40
x3  = SpeedFr40Avg(:,10);
y3  = SpeedFr40Avg(:,1);

% Estimated BLT for three speeds ------------------------------------------

xBL = BLTArray(:,2);
yBL = BLTArray(:,3);

% Curve fitting
[fitobject,gof,output] = fit(xBL,yBL,'poly2');
cvalues                = coeffvalues(fitobject);

if enableCommandWindowOutput == 1
    cval = cvalues;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    if cval(3) < 0
        setDecimals3 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    gofrs = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('EoF: y=%sx^2%sx%s | R^2: %s',p1,p2,p3,gofrs);
    disp(EoFEqn);
end

% Fitted BLT points -------------------------------------------------------
SpeedList = [1.6:0.1:2.7];
[mfr,nfr] = size(SpeedList);

FPArray = [];
for kfr=1:nfr
    FPArray(kfr,1) = SpeedList(kfr);
    FPArray(kfr,2) = cvalues(1)*SpeedList(kfr)^2+cvalues(2)*SpeedList(kfr)+cvalues(3);
end

% Fitted BLT for custom speed range
xF = FPArray(:,1);
yF = FPArray(:,2);

% Plotting ----------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
legendInfo1{1} = 'Speed #1 (F_{r}=0.30)';
legendInfo1{2} = 'Speed #2 (F_{r}=0.35)';
legendInfo1{3} = 'Speed #3 (F_{r}=0.40)';
% Boundary layer thicknesses of three measured speeds
hold on;
h1 = plot(xBL,yBL,'*');
legendInfo1{4} = 'Boundary layer thickness \delta';
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker+1);
% Fitted BLT points
hold on;
h2 = plot(xF,yF,'-');
%legendInfo{5} = 'Fitted \delta values';
if enablePlotTitle == 1
    title('{\bf BLT}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Measured speed (m/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Boundry layer thickness (mm)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
set(h(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'MarkerFaceColor',setColor{10}
% Fitted BLT points
set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(1.2,48,EoFEqn,'FontSize',setGeneralFontSize,'color','k','FontWeight','normal');

% Axis limitations
minX  = 0.8;
maxX  = 2.8;
incrX = 0.2;
minY  = 0;
maxY  = 80;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo1);
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_6_Boundary_Layer_Thickness_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 7. Distance from Hull vs. Speed and Power Law
%# ************************************************************************

figurename = 'Plot 7: Distance from Hull vs. Speed and Power Law';
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
setLegendFontSize  = 11;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>';'p';'h'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Axis data. Subscript i = inboard and o = outboard

%# Results array columns:
%[1]  Distance from model hull                 (mm)
%[2]  Averaged zero value (Inboard)            (V)
%[3]  Averaged zero value (Outboard)           (V)
%[4]  PST: Voltage (Inboard)                   (V)
%[5]  PST: Voltage (Outboard)                  (V)
%[6]  PST: Real speed using CF (Inboard)       (m/s)
%[7]  PST: Real speed using CF (Outboard)      (m/s)
%[8]  u/U0 (Inboard)                           (-)
%[9]  u/U0 (Outboard)                          (-)

%# Fr=0.30 ----------------------------------------------------------------

x1i = SpeedFr30Avg(:,6);
y1i = SpeedFr30Avg(:,1);

x1o = SpeedFr30Avg(:,7);
y1o = SpeedFr30Avg(:,1);

%# Fr=0.35 ----------------------------------------------------------------

x2i = SpeedFr35Avg(:,6);
y2i = SpeedFr35Avg(:,1);

x2o = SpeedFr35Avg(:,7);
y2o = SpeedFr35Avg(:,1);

%# Fr=0.40 ----------------------------------------------------------------

x3i = SpeedFr40Avg(:,6);
y3i = SpeedFr40Avg(:,1);

x3o = SpeedFr40Avg(:,7);
y3o = SpeedFr40Avg(:,1);

%# Boundary layer data ----------------------------------------------------

xBL = [BLTArray(1,2) BLTArray(2,2) BLTArray(3,2)];
yBL = [BLTArray(1,3) BLTArray(2,3) BLTArray(3,3)];

%# Power Law --------------------------------------------------------------

% Power law index, n
PLIndexn = 7;

% Speeds
Speed30 = SpeedFr30Avg(1,18);
Speed35 = SpeedFr35Avg(1,18);
Speed40 = SpeedFr40Avg(1,18);

% Boundary layer thickness
BLT30 = BLTArray(1,3);
BLT35 = BLTArray(2,3);
BLT40 = BLTArray(3,3);

%# Fr=0.30
Temp30YArray = 0:0.2:BLT30;
Temp30YArray = Temp30YArray';
[m30,n30]    = size(Temp30YArray);
Temp30VArray = [];
for kx=1:m30
    %# Fr=0.30
    Temp30VArray(kx,1) = Speed30*(Temp30YArray(kx,1)/BLT30)^(1/PLIndexn);
end

%# Fr=0.35
Temp35YArray = 0:0.2:BLT35;
Temp35YArray = Temp35YArray';
[m35,n35]    = size(Temp35YArray);
Temp35VArray = [];
for kx=1:m35
    %# Fr=0.35
    Temp35VArray(kx,1) = Speed35*(Temp35YArray(kx,1)/BLT35)^(1/PLIndexn);
end

%# Fr=0.40
Temp40YArray = 0:0.2:BLT40;
Temp40YArray = Temp40YArray';
[m40,n40]    = size(Temp40YArray);
Temp40VArray = [];
for kx=1:m40
    Temp40VArray(kx,1) = Speed40*(Temp40YArray(kx,1)/BLT40)^(1/PLIndexn);
end

%# Fr=0.30
xPL30 = Temp30VArray;
yPL30 = Temp30YArray;

%# Fr=0.35
xPL35 = Temp35VArray;
yPL35 = Temp35YArray;

%# Fr=0.40
xPL40 = Temp40VArray;
yPL40 = Temp40YArray;

% Plotting ----------------------------------------------------------------
h1 = plot(x1i,y1i,'*',x1o,y1o,'*',x2i,y2i,'*',x2o,y2o,'*',x3i,y3i,'*',x3o,y3o,'*');
%# Inboard and outboard plots
legendInfo{1} = 'Speed #1 (F_{r}=0.30 Inboard)';
legendInfo{2} = 'Speed #1 (F_{r}=0.30 Outboard)';
legendInfo{3} = 'Speed #2 (F_{r}=0.35 Inboard)';
legendInfo{4} = 'Speed #2 (F_{r}=0.35 Outboard)';
legendInfo{5} = 'Speed #3 (F_{r}=0.40 Inboard)';
legendInfo{6} = 'Speed #3 (F_{r}=0.40 Outboard)';
%# Boundary layer thickness marker
hold on;
h2 = plot(xBL,yBL,'*');
legendInfo{7} = 'Boundary layer thickness (\delta)';
%# Power law curves
hold on;
h3 = plot(xPL30,yPL30,'*',xPL35,yPL35,'*',xPL40,yPL40,'*');
legendInfo{8}  = 'F_{r}=0.30 (power law, n=7)';
legendInfo{9}  = 'F_{r}=0.35 (power law, n=7)';
legendInfo{10} = 'F_{r}=0.40 (power law, n=7)';
if enablePlotTitle == 1
    title('{\bf Speed vs. distance (Y) below hull}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Measured speed (m/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Vertical distance from model hull, Y (mm)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
set(h1(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% Boundary layer depth marker
set(h2(1),'Color',setColor{10},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker+1); %,'MarkerFaceColor',setColor{10}
%# Power law curves
set(h3(1),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidth);
set(h3(2),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);
set(h3(3),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidth);

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Axis limitations
minX  = 0.8;
maxX  = 2.8;
incrX = 0.2;
minY  = 0;
maxY  = 80;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_7_Boundary_Layer_Y_vs_Speed_and_Power_Law_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 8. Distance from Hull vs. Speed and Power Law
%# ************************************************************************

figurename = 'Plot 8: Distance from Hull vs. Averaged Speed and Power Law';
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
    'FontSize',10,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>';'p';'h'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

% SUBPLOT /////////////////////////////////////////////////////////////////
%subplot(1,1,1)

% X and Y values ----------------------------------------------------------

% Averaged speeds ---------------------------------------------------------

%# Fr=0.30
x1  = SpeedFr30Avg(:,10);
y1  = SpeedFr30Avg(:,1);

%# Fr=0.35
x2  = SpeedFr35Avg(:,10);
y2  = SpeedFr35Avg(:,1);

%# Fr=0.40
x3  = SpeedFr40Avg(:,10);
y3  = SpeedFr40Avg(:,1);

% Boundary layer thickness markers ----------------------------------------

xBL = [BLTArray(1,2) BLTArray(2,2) BLTArray(3,2)];
yBL = [BLTArray(1,3) BLTArray(2,3) BLTArray(3,3)];

%# Power Law --------------------------------------------------------------

% Power law index, n
PLIndexn = 7;

% Speeds
Speed30 = SpeedFr30Avg(1,18);
Speed35 = SpeedFr35Avg(1,18);
Speed40 = SpeedFr40Avg(1,18);

% Boundary layer thickness
BLT30 = BLTArray(1,3);
BLT35 = BLTArray(2,3);
BLT40 = BLTArray(3,3);

%# Fr=0.30
Temp30YArray = 0:0.2:BLT30;
Temp30YArray = Temp30YArray';
[m30,n30]    = size(Temp30YArray);
Temp30VArray = [];
for kx=1:m30
    %# Fr=0.30
    Temp30VArray(kx,1) = Speed30*(Temp30YArray(kx,1)/BLT30)^(1/PLIndexn);
end

%# Fr=0.35
Temp35YArray = 0:0.2:BLT35;
Temp35YArray = Temp35YArray';
[m35,n35]    = size(Temp35YArray);
Temp35VArray = [];
for kx=1:m35
    %# Fr=0.35
    Temp35VArray(kx,1) = Speed35*(Temp35YArray(kx,1)/BLT35)^(1/PLIndexn);
end

%# Fr=0.40
Temp40YArray = 0:0.2:BLT40;
Temp40YArray = Temp40YArray';
[m40,n40]    = size(Temp40YArray);
Temp40VArray = [];
for kx=1:m40
    Temp40VArray(kx,1) = Speed40*(Temp40YArray(kx,1)/BLT40)^(1/PLIndexn);
end

%# Fr=0.30
xPL30 = Temp30VArray;
yPL30 = Temp30YArray;

%# Fr=0.35
xPL35 = Temp35VArray;
yPL35 = Temp35YArray;

%# Fr=0.40
xPL40 = Temp40VArray;
yPL40 = Temp40YArray;

% Plotting ----------------------------------------------------------------
h1 = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*');
legendInfo2{1} = 'Speed #1: F_{r}=0.30';
legendInfo2{2} = 'Speed #2: F_{r}=0.35';
legendInfo2{3} = 'Speed #3: F_{r}=0.40';
%# Boundary layer thickness marker
hold on;
h2 = plot(xBL,yBL,'*');
legendInfo2{4} = 'Boundary layer thickness (\delta)';
%# Power law curves
hold on;
h3 = plot(xPL30,yPL30,'*',xPL35,yPL35,'*',xPL40,yPL40,'*');
legendInfo2{5} = 'F_{r}=0.30 (power law, n=7)';
legendInfo2{6} = 'F_{r}=0.35 (power law, n=7)';
legendInfo2{7} = 'F_{r}=0.40 (power law, n=7)';
if enablePlotTitle == 1
    title('{\bf Speed vs. distance (Y) below hull}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Measured speed (m/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Vertical distance from hull, Y (mm)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{setSpeed}
set(h1(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% Boundary layer depth marker
set(h2(1),'Color',setColor{10},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker+1); %,'MarkerFaceColor',setColor{10}
%# Power law curves
set(h3(1),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidth);
set(h3(2),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);
set(h3(3),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidth);

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% Axis limitations
minX  = 0.8;
maxX  = 2.8;
incrX = 0.2;
minY  = 0;
maxY  = 80;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
hleg1 = legend(legendInfo2);
set(hleg1,'Location','NorthWest');
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

%# Plot title ---------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------

% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_8_Boundary_Layer_Y_vs_Averaged_Speed_Plot.%s', 'Bounday_Layer', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
