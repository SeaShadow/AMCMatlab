%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  October 28, 2014
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
%# CHANGES    :  16/09/2014 - Created new script
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

% Decide if June 2013 or September 2014 data is used for calculations
enableSept2014FRMValues = 1;    % Use enable uses flow rate values established September 2014

% Plot titles, colours, etc.
enablePlotMainTitle     = 0;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only
enableTowingForceFDPlot = 1;    % Show towing force (FD)

% Decide which plot to show TG=p QJ vj (Allison) or TG=p QJ (vj-vi) (Bose)
enableTGAllisonPlot     = 0;    % Show plots where TG = p Q vj
enableTGBosePlot        = 1;    % Show plots where TG = p Q (vj - vi)

% Scaled to A4 paper
enableA4PaperSizePlot   = 0;    % Show plots scale to A4 size

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
ttwatertemp         = 18.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

%# ************************************************************************
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl           = 4.30;                          % Model length waterline          (m)
MSwsa           = 1.501;                         % Model scale wetted surface area (m^2)
MSdraft         = 0.133;                         % Model draft                     (m)
MSAx            = 0.024;                         % Model area of max. transverse section (m^2)
BlockCoeff      = 0.592;                         % Mode block coefficient          (-)
FSlwl           = MSlwl*FStoMSratio;             % Full scale length waterline     (m)
FSwsa           = MSwsa*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft         = MSdraft*FStoMSratio;           % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************

% Form factors and correlaction coefficient
FormFactor = 1.18;                            % Form factor (1+k)
CorrCoeff  = 0;                               % Correlation coefficient, Ca
% Correlation coefficient, typical value. See Bose (2008), equation 2-4, page 6.
%CorrCoeff  = (105*((150*10^(-6))/MSlwl)^(1/3)-0.64)*10^(-3);

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

% Boundary layer: Power law factors (-)
BLPLFactorArray  = [6.672 6.672 6.672 6.672 6.672 6.672 6.672 6.672 6.672];

% Boundary layer: Thickness (m)
BLThicknessArray = [0.04546 0.04548 0.04519 0.04459 0.04369 0.04248 0.04097 0.03915 0.03702];

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
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
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

%startRun = 70;      % Start run
%endRun   = 70;      % Stop run

startRun = 70;       % Start run
endRun   = 109;      % Stop run

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
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


%# ************************************************************************
%# START Load shaft speed list (variable name is shaftSpeedList by default)
%# ------------------------------------------------------------------------
if exist('shaftSpeedListRuns90to109.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('shaftSpeedListRuns90to109.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (shaftSpeedListRuns90to109.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load shaft speed list (variable name is shaftSpeedList by default)
%# ************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# START REPEAT RUN NUMBERS
%# ------------------------------------------------------------------------
RunsForSpeed1 = [101 102 103 107];          % Fr = 0.24
RunsForSpeed2 = [98 99 100 108];            % Fr = 0.26
RunsForSpeed3 = [95 96 97 109];             % Fr = 0.28
RunsForSpeed4 = [70 104 71 72 73 74];       % Fr = 0.30
RunsForSpeed5 = [75 76 78 77];              % Fr = 0.32
RunsForSpeed6 = [79 80 81];                 % Fr = 0.34
RunsForSpeed7 = [82 83 84];                 % Fr = 0.36
RunsForSpeed8 = [85 86 87 88 89 105 106];   % Fr = 0.38
RunsForSpeed9 = [90 91 92 93 94];           % Fr = 0.40
%# ------------------------------------------------------------------------
%# END REPEAT RUN NUMBERS
%# ////////////////////////////////////////////////////////////////////////


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

%# _plots/SPP directory
fPath = sprintf('_plots/%s', 'SPP');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', 'SPP', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', 'SPP', 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', 'SPP', 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ////////////////////////////////////////////////////////////////////////


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

% If resultsArraySPP.dat does NOT EXIST loop through DAQ files
if exist('resultsArraySPP.dat', 'file') == 0
    
    resultsArraySPP = [];
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
        
        %# Columns as variables (RAW DATA)
        timeData             = data(:,1);       % Timeline
        Raw_CH_0_Speed       = data(:,2);       % Speed
        Raw_CH_1_LVDTFwd     = data(:,3);       % Forward LVDT
        Raw_CH_2_LVDTAft     = data(:,4);       % Aft LVDT
        Raw_CH_3_Drag        = data(:,5);       % Load cell (drag)
        Raw_CH_4_PortRPM     = data(:,6);       % Port RPM
        Raw_CH_5_StbdRPM     = data(:,7);       % Starboard RPM
        Raw_CH_6_PortThrust  = data(:,8);       % Port thrust
        Raw_CH_7_PortTorque  = data(:,9);       % Port torque
        Raw_CH_8_StbdThrust  = data(:,10);      % Starboard thrust
        Raw_CH_9_StbdTorque  = data(:,11);      % Starboard torque
        Raw_CH_10_PortKP     = data(:,12);      % Port kiel probe
        Raw_CH_11_StbdKP     = data(:,13);      % Starboard kiel probe
        
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
        CH_11_Zero = ZeroAndCalib(25);
        CH_11_CF   = ZeroAndCalib(26);
        
        %# --------------------------------------------------------------------
        %# Real units ---------------------------------------------------------
        %# --------------------------------------------------------------------
        
        [CH_0_Speed CH_0_Speed_Mean]           = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
        [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]       = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
        [CH_2_LVDTAft CH_2_LVDTAft_Mean]       = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
        [CH_3_Drag CH_3_Drag_Mean]             = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
        
        [CH_6_PortThrust CH_6_PortThrust_Mean] = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
        [CH_7_PortTorque CH_7_PortTorque_Mean] = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
        [CH_8_StbdThrust CH_8_StbdThrust_Mean] = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
        [CH_9_StbdTorque CH_9_StbdTorque_Mean] = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);
        
        [RPMStbd RPMPort]                      = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);
        
        % /////////////////////////////////////////////////////////////////////
        % DISPLAY RESULTS
        % /////////////////////////////////////////////////////////////////////
        
        %# Add results to dedicated array for simple export
        %# Results array columns:
        
        %[1]  Run No.
        %[2]  FS                          (Hz)
        %[3]  No. of samples              (-)
        %[4]  Record time                 (s)
        
        %[5]  Froude length number        (-)
        %[6]  Speed (vm)                  (m/s)
        %[7]  Forward LVDT                (mm)
        %[8]  Aft LVDT                    (mm)
        %[9]  Drag                        (g)
        %[10] Drag                        (N)
        
        %[11] PORT: Shaft Speed           (RPM)
        %[12] STBD: Shaft Speed           (RPM)
        %[13] PORT: Thrust                (N)
        %[14] STBD: Thrust                (N)
        %[15] PORT: Torque                (Nm)
        %[16] STBD: Torque                (Nm)
        %[17] PORT: Kiel probe            (V)
        %[18] STBD: Kiel probe            (V)
        
        % New columns added 15/7/2014
        %[19] Shaft/motor speed           (RPM)
        %[20] Ship speed (vs)             (m/s)
        %[21] Ship speed (vs)             (knots)
        
        %[22] Model scale Reynolds number (Rem) (-)
        %[23] Full scale Reynolds number (Res)  (-)
        
        %[24] Model scale frictional resistance coefficient (Grigson), CFm (-)
        %[25] Full scale Frictional resistance coefficient (Grigson), CFs  (-)
        %[26] Correleation coefficient, Ca                                 (-)
        %[27] Form factor (1+k)                                            (-)
        %[28] Towing force, (FD)                                           (N)
        %[29] Towing force coefficient, (CFD)                              (-)
        
        % Mass flow rate and jet velocity
        %[30] PORT: Mass flow rate (pQJ)  (Kg/s)
        %[31] STBD: Mass flow rate (pQJ)  (Kg/s)
        %[32] PORT: Mass flow rate (QJ)   (m^3/s)
        %[33] STBD: Mass flow rate (QJ)   (m^3/s)
        
        %[34] PORT: Jet velocity (vj)     (m/s)
        %[35] STBD: Jet velocity (vj)     (m/s)
        
        % Wake fraction
        %[36] PORT: Wake fraction (1-w)   (-)
        %[37] STBD: Wake fraction (1-w)   (-)
        
        %[38] PORT: Inlet velocity, vi    (m/s)
        %[39] STBD: Inlet velocity, vi    (m/s)
        
        % Gross thrust = TG = p Q (vj - vi)
        %[40] PORT: Gross thrust, TG      (N)
        %[41] STBD: Gross thrust, TG      (N)
        %[42] Total gross thrust, TG      (N)
        
        % Gross thrust = TG = p Q vj
        %[43] PORT: Gross thrust, TG      (N)
        %[44] STBD: Gross thrust, TG      (N)
        %[45] Total gross thrust, TG      (N)
        
        % New values added on 24/9/2014
        %[46] Power law factor                             (-)
        %[47] Boundary layer thickness                     (m)
        %[48] Volume flow rate inside boundary layer (Qbl) (m^3/s)
        %[49] PORT: Wake fraction (w)                      (-)
        %[50] STBD: Wake fraction (w)                      (-)
        
        % General data
        resultsArraySPP(k, 1)  = k;                                                     % Run No.
        resultsArraySPP(k, 2)  = round(length(timeData) / timeData(end));               % FS (Hz)
        resultsArraySPP(k, 3)  = length(timeData);                                      % Number of samples
        recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
        resultsArraySPP(k, 4)  = round(recordTime);                                     % Record time in seconds
        
        roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                      % Round averaged speed to two (2) decimals only
        modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl))); % Calculate Froude length number
        resultsArraySPP(k, 5) = modelfrrounded;                                         % Froude length number (adjusted for Lwl change at different conditions) (-)
        
        % Resistance data
        resultsArraySPP(k, 6)  = CH_0_Speed_Mean;                                       % Speed (m/s)
        resultsArraySPP(k, 7)  = CH_1_LVDTFwd_Mean;                                     % Forward LVDT (mm)
        resultsArraySPP(k, 8)  = CH_2_LVDTAft_Mean;                                     % Aft LVDT (mm)
        resultsArraySPP(k, 9)  = CH_3_Drag_Mean;                                        % Drag (g)
        resultsArraySPP(k, 10) = (CH_3_Drag_Mean/1000)*gravconst;                       % Drag (N)
        
        % RPM data
        resultsArraySPP(k, 11) = RPMPort;                                               % Shaft Speed PORT (RPM)
        resultsArraySPP(k, 12) = RPMStbd;                                               % Shaft Speed STBD (RPM)
        
        % Thrust and torque data
        resultsArraySPP(k, 13) = abs(CH_6_PortThrust_Mean/1000)*9.806;                  % Thrust PORT (N)
        resultsArraySPP(k, 14) = abs(CH_8_StbdThrust_Mean/1000)*9.806;                  % Thrust STBD (N)
        resultsArraySPP(k, 15) = CH_7_PortTorque_Mean;                                  % Torque PORT (Nm)
        resultsArraySPP(k, 16) = CH_9_StbdTorque_Mean;                                  % Torque STBD (Nm)
        
        % Kie; probe data
        resultsArraySPP(k, 17)  = mean(Raw_CH_10_PortKP);                               % Kiel probe PORT (V)
        resultsArraySPP(k, 18)  = mean(Raw_CH_11_StbdKP);                               % Kiel probe STBD (V)
        
        % New columns added 15/7/2014
        sslIndex = find(shaftSpeedList == k);
        if isempty(sslIndex) == 1
            shaftSpeedRPM = 0;
        else
            %shaftSpeedRPM = shaftSpeedList(sslIndex,2);
            % Actual (averaged PORT and STBD) shaft speed (i.e. measured shaft speed)
            shaftSpeedRPM = (RPMStbd+RPMPort)/2;
        end
        resultsArraySPP(k, 19)  = shaftSpeedRPM;                                        % Shaft/motor speed (RPM)
        
        MSspeed = CH_0_Speed_Mean;
        FSspeed = CH_0_Speed_Mean*sqrt(FStoMSratio);
        
        resultsArraySPP(k, 20)  = FSspeed;                                              % Ship speed (m/s)
        resultsArraySPP(k, 21)  = FSspeed/0.514444;                                     % Ship speed (knots)
        
        resultsArraySPP(k, 22)  = (MSspeed*MSlwl)/MSKinVis;                             % Model scale Reynolds number (-)
        resultsArraySPP(k, 23)  = (FSspeed*FSlwl)/FSKinVis;                             % Full scale Reynolds number (-)
        
        MSReynoldsNo = resultsArraySPP(k, 22);
        FSReynoldsNo = resultsArraySPP(k, 23);
        
        % Model scale frictional resistance coefficient (Grigson), CFm (-)
        if MSReynoldsNo < 10000000
            resultsArraySPP(k, 24) = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
        else
            resultsArraySPP(k, 24) = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
        end
        
        % Full scale frictional resistance coefficient (Grigson), CFs (-)
        if FSReynoldsNo < 10000000
            resultsArraySPP(k, 25) = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2);
        else
            resultsArraySPP(k, 25) = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3);
        end
        
        resultsArraySPP(k, 26)  = CorrCoeff;                                            % Correlation coefficient, Ca (-)
        resultsArraySPP(k, 27)  = FormFactor;                                           % Form factor (-)
        
        % Towing force and twoing force coefficient
        setCFm = resultsArraySPP(k, 24);
        setCFs = resultsArraySPP(k, 25);
        resultsArraySPP(k, 28)  = 0.5*freshwaterdensity*(MSspeed^2)*MSwsa*(FormFactor*(setCFm-setCFs)-CorrCoeff);  % Towing force, FD (N)
        resultsArraySPP(k, 29)  = FormFactor*(setCFm-setCFs)-CorrCoeff;                                            % Towing force coefficient, CFD (-)
        
        % Kiel probes
        PortKP = resultsArraySPP(k, 17);                                                % PORT: Kiel probe (V)
        StbdKP = resultsArraySPP(k, 18);                                                % STBD: Kiel probe (V)
        
        %# START Handle mass flow rate ------------------------------------
        if enableSept2014FRMValues == 1
            % PORT and STBD (September 2014 FRM test): Mass flow rate (Kg/s)
            PortMfr = -0.0421*PortKP^4+0.5718*PortKP^3-2.9517*PortKP^2+7.8517*PortKP-5.1976;
            StbdMfr = -0.0946*StbdKP^4+1.1259*StbdKP^3-5.0067*StbdKP^2+11.0896*StbdKP-6.8705;
        else
            % PORT (June 2013 FRM test): Mass flow rate (Kg/s)
            if PortKP > 1.86
                PortMfr = 0.1133*PortKP^3-1.0326*PortKP^2+4.3652*PortKP-2.6737;
            else
                PortMfr = 0.4186*PortKP^5-4.5094*PortKP^4+19.255*PortKP^3-41.064*PortKP^2+45.647*PortKP-19.488;
            end
            % STBD (June 2013 FRM test): Mass flow rate (Kg/s)
            if StbdKP > 1.86
                StbdMfr = 0.1133*StbdKP^3-1.0326*StbdKP^2+4.3652*StbdKP-2.6737;
            else
                StbdMfr = 0.4186*StbdKP^5-4.5094*StbdKP^4+19.255*StbdKP^3-41.064*StbdKP^2+45.647*StbdKP-19.488;
            end
        end
        %# END Handle mass flow rate --------------------------------------
        
        % Mass flow rate and jet velocity
        resultsArraySPP(k, 30)  = PortMfr;                                   % PORT: Mass flow rate (Kg/s)
        resultsArraySPP(k, 31)  = StbdMfr;                                   % STBD: Mass flow rate (Kg/s)
        
        % Volume flow rate
        PortVfr = PortMfr/freshwaterdensity;
        StbdVfr = StbdMfr/freshwaterdensity;
        resultsArraySPP(k, 32)  = PortVfr;                                   % PORT: Volume flow rate (m^3/s)
        resultsArraySPP(k, 33)  = StbdVfr;                                   % STBD: Volume flow rate (m^3/s)
        
        % Jet velocity
        resultsArraySPP(k, 34)  = PortVfr/MS_NozzArea;                       % PORT: Jet velocity (m/s)
        resultsArraySPP(k, 35)  = StbdVfr/MS_NozzArea;                       % STBD: Jet velocity (m/s)
        
        % Wake fraction and gross thrust
        if any(k==RunsForSpeed1)
            setSpeed = 1;
        elseif any(k==RunsForSpeed2)
            setSpeed = 2;
        elseif any(k==RunsForSpeed3)
            setSpeed = 3;
        elseif any(k==RunsForSpeed4)
            setSpeed = 4;
        elseif any(k==RunsForSpeed5)
            setSpeed = 5;
        elseif any(k==RunsForSpeed6)
            setSpeed = 6;
        elseif any(k==RunsForSpeed7)
            setSpeed = 7;
        elseif any(k==RunsForSpeed8)
            setSpeed = 8;
        elseif any(k==RunsForSpeed9)
            setSpeed = 9;
        else
            disp('Oops.. something is wrong here, run is not in speed list!');
        end
        
        if any(k==RunsForSpeed1) || any(k==RunsForSpeed2) || any(k==RunsForSpeed3) || any(k==RunsForSpeed4) || any(k==RunsForSpeed5) || any(k==RunsForSpeed6) || any(k==RunsForSpeed7) || any(k==RunsForSpeed8) || any(k==RunsForSpeed9)
            %disp(sprintf('Speed: %s',num2str(setSpeed)));
            BLPLFactor  = BLPLFactorArray(setSpeed);
            BLThickness = BLThicknessArray(setSpeed);
            QBL         = CH_0_Speed_Mean*WidthFactor*MS_PumpDia*BLThickness*(BLPLFactor/(BLPLFactor+1));
            setPortWF   = 1-((BLPLFactor+1)/(BLPLFactor+2))*(PortVfr/QBL)^(1/(BLPLFactor+1));
            setStbdWF   = 1-((BLPLFactor+1)/(BLPLFactor+2))*(StbdVfr/QBL)^(1/(BLPLFactor+1));
        else
            BLPLFactor  = 0;
            BLThickness = 0;
            QBL         = 0;
            setPortWF   = 1;
            setStbdWF   = 1;
        end
        
        % Wake fraction (1-w)
        resultsArraySPP(k, 36)  = 1-setPortWF;       % PORT: Wake fraction (1-w) (-)
        resultsArraySPP(k, 37)  = 1-setStbdWF;       % STBD: Wake fraction (1-w) (-)
        
        % Inlet velocity
        resultsArraySPP(k, 38)  = MSspeed*resultsArraySPP(k, 36); % PORT: Inlet velocity, vi (m/s)
        resultsArraySPP(k, 39)  = MSspeed*resultsArraySPP(k, 37); % STBD: Inlet velocity, vi (m/s)
        
        % Variables for gross thrust (TG)
        PortJetVel = resultsArraySPP(k, 34);         % Port jet velocity (m/s)
        StbdJetVel = resultsArraySPP(k, 35);         % Stbd jet velocity (m/s)
        PortInlVel = resultsArraySPP(k, 38);         % Port inlet velocity (m/s)
        StbdInlVel = resultsArraySPP(k, 39);         % Stbd inlet velocity (m/s)
        
        % Gross thrust = TG = p Q (vj - vi)
        TG1Port = PortMfr*(PortJetVel-PortInlVel);
        TG1Stbd = StbdMfr*(StbdJetVel-StbdInlVel);
        resultsArraySPP(k, 40)  = TG1Port;           % PORT: Gross thrust, TG (N)
        resultsArraySPP(k, 41)  = TG1Stbd;           % STBD: Gross thrust, TG (N)
        resultsArraySPP(k, 42)  = TG1Port+TG1Stbd;   % TOTAL gross thrust, TG (N)
        
        % Gross thrust = TG = p Q vj
        TG2Port  = PortMfr*PortJetVel;
        TG2Stbd  = StbdMfr*StbdJetVel;
        resultsArraySPP(k, 43)  = TG2Port;           % PORT: Gross thrust, TG (N)
        resultsArraySPP(k, 44)  = TG2Stbd;           % STBD: Gross thrust, TG (N)
        resultsArraySPP(k, 45)  = TG2Port+TG2Stbd;   % TOTAL gross thrust, TG (N)
        
        % New values added on 24/9/2014
        resultsArraySPP(k, 46) = BLPLFactor;
        resultsArraySPP(k, 47) = BLThickness;
        resultsArraySPP(k, 48) = QBL;
        
        % Wake fraction w
        resultsArraySPP(k, 49) = setPortWF;
        resultsArraySPP(k, 50) = setStbdWF;
        
        %# Prepare strings for display ----------------------------------------
        
        % Change from 2 to 3 digits
        if k > 99
            name = name(1:4);
        else
            name = name(1:3);
        end
        
        % Prepare strings  ----------------------------------------------------
        
        setRPM       = sprintf('%s:: Set motor/shaft speed: %s [RPM]', name, sprintf('%.0f',shaftSpeedRPM));
        shaftrpmport = sprintf('%s:: Measured motor/shaft speed PORT: %s [RPM]', name, sprintf('%.0f',RPMPort));
        shaftrpmstbd = sprintf('%s:: Measured motor/speed STBD: %s [RPM]', name, sprintf('%.0f',RPMStbd));
        
        %# Display strings ---------------------------------------------------
        
        disp(setRPM);
        disp(shaftrpmport);
        disp(shaftrpmstbd);
        
        disp('/////////////////////////////////////////////////');
        
        %wtot = endRun - startRun;
        %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
    end
    
    %# Close progress bar
    %close(w);
    
    % /////////////////////////////////////////////////////////////////////
    % START: Write results to DAT and TXT
    % ---------------------------------------------------------------------
    
    resultsArraySPP = resultsArraySPP(any(resultsArraySPP,2),:);           % Remove zero rows
    M = resultsArraySPP;
    %M = M(any(M,2),:);                                                    % remove zero rows only in resultsArraySPP text file
    csvwrite('resultsArraySPP.dat', M)                                     % Export matrix M to a file delimited by the comma character
    %dlmwrite('resultsArraySPP.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
    
    % ---------------------------------------------------------------------
    % END: Write results to DAT and TXT
    % /////////////////////////////////////////////////////////////////////
    
else
    
    %# As we know that resultsArraySPP.dat exits, read it
    resultsArraySPP = csvread('resultsArraySPP.dat');
    
    %# Remove zero rows
    resultsArraySPP(all(resultsArraySPP==0,2),:)=[];
    
end

%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 1. Plot gross thrust (TG) vs. towing force (F)
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

% Remove zero rows
resultsArraySPP = resultsArraySPP(any(resultsArraySPP,2),:);

% Split results array based on column 9 (Length Froude Number)
R = resultsArraySPP;
A = arrayfun(@(x) R(R(:,5) == x, :), unique(R(:,5)), 'uniformoutput', false);
[ma,na] = size(A);      % Array dimensions

% Froude numbers for nine (9) speeds
Froude_Numbers = [];
for k=1:ma
    Froude_Numbers(k,1) = A{k}(1,5);
    Froude_Numbers(k,2) = mean(A{k}(:,6));
end

% Bare hull resistance

%# calBHResistanceBasedOnFr results array columns:
%[1]  Froude length number             (-)
%[2]  Resistance (uncorrected)         (N)
%[resistance] = calBHResistanceBasedOnFr(Froude_Numbers);

%# calBHResistanceBasedOnFrTempCorr results array columns:
%[1]  Froude length number             (-)
%[2]  Resistance (uncorrected)         (N)
%[3]  Resistance (corrected for temp.) (N) -> See ITTC 7.5-02-03-01.4 (2008)
[resistance] = calBHResistanceBasedOnFrTempCorr(Froude_Numbers,FormFactor,MSwsa,MSlwl);

% Loop through speeds
TGA_at_FDArray = [];        % Gross thrust = TG = p Q vj
TGB_at_FDArray = [];        % Gross thrust = TG = p Q (vj - vi)
FA_at_TGZero   = [];        % Gross thrust = TG = p Q vj
FB_at_TGZero   = [];        % Gross thrust = TG = p Q (vj - vi)
thrustDedFracArrayA = [];   % Thrust deduction array where TG = p Q vj
thrustDedFracArrayB = [];   % Thrust deduction array where TG = p Q (vj - vi)
shaftSpeedConvArray = [];   % Shaft speed array where TG = p Q (vj - vi)
for k=1:ma
    [mb,nb] = size(A{k});
    
    % Corrected resistance (RC) at current Froude length number -----------
    correctedResistance = resistance(k,3);
    
    %# TG at FD -----------------------------------------------------------
    y1       = A{k}(:,45);   % Gross thrust = TG = p Q vj        (N)
    y2       = A{k}(:,42);   % Gross thrust = TG = p Q (vj - vi) (N)
    
    yPortSS  = A{k}(:,11);   % PORT: Shaft speed                 (PRM)
    yStbdSS  = A{k}(:,12);   % STBD: Shaft speed                 (PRM)
    
    x        = A{k}(:,10);   % Bare hull resistance              (N)
    towForce = A{k}(1,28);   % Towing force, FD                  (N)
    xq       = 0;            % Intersection of x for TG at zero drag
    
    %# --------------------------------------------------------------------
    %# Gross thrust = TG = p Q vj
    %# --------------------------------------------------------------------
    polyf                = polyfit(x,y1,1);
    polyv                = polyval(polyf,x);
    ThrustAtZeroDrag     = spline(x,polyv,0);
    ThrustAtSPP          = ThrustAtZeroDrag-towForce;
    TGA_at_FDArray(k, 1) = ThrustAtZeroDrag;        % Gross thrust, TG   (x-axis)
    TGA_at_FDArray(k, 2) = 0;                       % Towing force, Drag (y-axis)
    TGA_at_FDArray(k, 3) = towForce;                % Towing force, FD
    TGA_at_FDArray(k, 4) = ThrustAtSPP;             % Thrust at self. propulsion point = TG at zero drag - FD
    
    % Towing force at zero gross thrust -----------------------------------
    TowingForceAtZeroThrust = spline(polyv,x,0);
    FA_at_TGZero(k, 1) = 0;                         % Gross thrust, TG (x-axis)
    FA_at_TGZero(k, 2) = TowingForceAtZeroThrust;   % Towing force     (y-axis)
    
    % Thrust deduction fraction (t) ---------------------------------------
    thrustDedFracArrayA(k, 1) = Froude_Numbers(k,1);
    % t=(TM+FD-RC)/TM
    thrustDedFracArrayA(k, 2) = (ThrustAtSPP+towForce-correctedResistance)/ThrustAtSPP;
    % RCW=TG(1-t)+FD ==>> t=1-((RC-FD)/T)
    thrustDedFracArrayA(k, 3) = 1-((correctedResistance-towForce)/ThrustAtSPP);
    % t = ((FD-FatT=0)/TG@SPP)+1
    thrustDedFracArrayA(k, 4) = ((towForce-TowingForceAtZeroThrust)/ThrustAtSPP)+1;
    % t = 1-((FatT=0-FD)/TG@SPP)
    thrustDedFracArrayA(k, 5) = 1-((TowingForceAtZeroThrust-towForce)/ThrustAtSPP);
    
    %# --------------------------------------------------------------------
    %# Gross thrust = TG = p Q (vj - vi)
    %# --------------------------------------------------------------------
    polyf                = polyfit(x,y2,1);
    polyv                = polyval(polyf,x);
    ThrustAtZeroDrag     = spline(x,polyv,0);
    ThrustAtSPP          = ThrustAtZeroDrag-towForce;
    TGB_at_FDArray(k, 1) = ThrustAtZeroDrag;        % Gross thrust, TG   (x-axis)
    TGB_at_FDArray(k, 2) = 0;                       % Towing force, Drag (y-axis)
    TGB_at_FDArray(k, 3) = towForce;                % Towing force, FD
    TGB_at_FDArray(k, 4) = ThrustAtSPP;             % Thrust at self. propulsion point = TG at zero drag - FD
    
    % Towing force at zero gross thrust -----------------------------------
    TowingForceAtZeroThrust = spline(polyv,x,0);
    FB_at_TGZero(k, 1) = 0;                         % Gross thrust, TG (x-axis)
    FB_at_TGZero(k, 2) = TowingForceAtZeroThrust;   % Towing force     (y-axis)
    
    % Thrust deduction fraction (t) ---------------------------------------
    thrustDedFracArrayB(k, 1) = Froude_Numbers(k,1);
    % t=(TM+FD-RC)/TM
    thrustDedFracArrayB(k, 2) = (ThrustAtSPP+towForce-correctedResistance)/ThrustAtSPP;
    % RCW=TG(1-t)+FD ==>> t=1-((RC-FD)/T)
    thrustDedFracArrayB(k, 3) = 1-((correctedResistance-towForce)/ThrustAtSPP);
    % t = ((FD-FatT=0)/TG@SPP)+1
    thrustDedFracArrayB(k, 4) = ((towForce-TowingForceAtZeroThrust)/ThrustAtSPP)+1;
    % t = 1-((FatT=0-FD)/TG@SPP)
    thrustDedFracArrayB(k, 5) = 1-((TowingForceAtZeroThrust-towForce)/ThrustAtSPP);
    
    % Shaft speed ---------------------------------------------------------
    %[1] Froude length number             (-)
    %[2] PORT (MS): Shaft speed at SPP    (RPM)
    %[3] PORT (MS): Shaft speed at SPP    (RPM)
    %[4] PORT (FS): Shaft speed at SPP    (RPM)
    %[5] PORT (FS): Shaft speed at SPP    (RPM)
    
    x = A{k}(:,42);     % Gross thrust = TG = p Q (vj - vi)    (N)
    
    % Port
    polyfPORT2             = polyfit(x,yPortSS,1);
    polyvPORT2             = polyval(polyfPORT2,x);
    MSPortShaftSpeed       = spline(x,polyvPORT2,ThrustAtSPP);
    % Stbd
    polyfSTBD2             = polyfit(x,yStbdSS,1);
    polyvSTBD2             = polyval(polyfSTBD2,x);
    MSStbdShaftSpeed       = spline(x,polyvSTBD2,ThrustAtSPP);
    
    shaftSpeedConvArray(k, 1) = Froude_Numbers(k,1);
    shaftSpeedConvArray(k, 2) = MSPortShaftSpeed;
    shaftSpeedConvArray(k, 3) = MSStbdShaftSpeed;
    shaftSpeedConvArray(k, 4) = MSPortShaftSpeed/sqrt(FStoMSratio);
    shaftSpeedConvArray(k, 5) = MSStbdShaftSpeed/sqrt(FStoMSratio);
end

%# Only plot if all (9) datasets are available
if ma == 9
    
    % TG = p Q vj
    slopesArrayA = [];
    % TG = p Q (vj - vi)
    slopesArrayB = [];
    
    if enableTGAllisonPlot ~= 0 || enableTGBosePlot ~= 0
        
        %# Plotting gross thrust vs. towing force
        figurename = 'Self-Propulsion Points: Gross Thrust vs. Towing Force';
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
        %setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
        setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Gross thrust = TG = p Q vj -----------------------------------------
        if enableTGAllisonPlot == 1
            
            if enableTGAllisonPlot == 1 && enableTGBosePlot == 1
                subplot(1,2,1);
            end
            
            %# X and Y axes data, create variables for speeds 1 to 9
            %# Note for future self: Next time use structures or arrays!!!!
            disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            disp('!Equations of fit                                        !');
            disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            for k=1:ma
                x = A{k}(:,45);
                y = A{k}(:,10);
                eval(sprintf('x%d = x;', k));
                eval(sprintf('y%d = y;', k));
                
                % Linear fit
                P = polyfit(x,y,1);
                V = polyval(P,x);
                eval(sprintf('polyv%d = V;', k));
                % Record slopes
                % Columns:
                %[1]  Froude number                 (-)
                %[2]  Slope (i.e. -(1-t))           (-)
                %[3]  Thrust deduction, t           (-)
                if P(2) < 0
                    setDecimals = '%0.3f';
                else
                    setDecimals = '+%0.3f';
                end
                slopesArrayA(k,1) = Froude_Numbers(k,1);
                slopesArrayA(k,2) = P(1);
                slopesArrayA(k,3) = P(1)+1;
                disp(sprintf('Speed %s (TG = p QJ vj): Equation of fit = %sx%s',num2str(k),sprintf('%0.3f',P(1)),sprintf(setDecimals,P(2))));
                
                % Extend linear fit using equation of fit
                xx = 0:max(x)*1.1;
                yy = P(1)*xx+P(2);
                eval(sprintf('xLF%d = xx;', k));
                eval(sprintf('yLF%d = yy;', k));
            end
            
            % Model self-propulsion points (i.e. gross thrus TG at towing force FD)
            TGatFD = TGA_at_FDArray;
            
            % Towing force at zero thrust
            FatTGZ = FA_at_TGZero;
            
            %# Set marker and line sizes
            setMarkerSize      = 12;
            setLineWidthMarker = 1;
            setLineWidth       = 1;
            setLineStyle       = '-';
            
            %# Plotting
            h1 = plot(x1,y1,setMarker{1},x2,y2,setMarker{2},x3,y3,setMarker{3},x4,y4,setMarker{4},x5,y5,setMarker{5},x6,y6,setMarker{6},x7,y7,setMarker{7},x8,y8,setMarker{8},x9,y9,setMarker{9});
            %# Gross thrus TG at towing force FD
            if enableTowingForceFDPlot == 1
                hold on;
                h3 = plot(TGatFD(:,1),TGatFD(:,2),'o');
                hold on;
                %# Towing force at zero thrust
                h5 = plot(FatTGZ(:,1),FatTGZ(:,2),'s');
            end
            hold on;
            %# Extended linear fit
            h4 = plot(xLF1,yLF1,xLF2,yLF2,xLF3,yLF3,xLF4,yLF4,xLF5,yLF5,xLF6,yLF6,xLF7,yLF7,xLF8,yLF8,xLF9,yLF9);
            if enablePlotTitle == 1
                title('{\bf Gross thrust defined as T_{G} = p Q v_{j}}','FontSize',setGeneralFontSize);
            end
            xlabel('{\bf Gross thrust, T_{G} (N)}','FontSize',setGeneralFontSize);
            ylabel('{\bf Towing force (N)}','FontSize',setGeneralFontSize);
            grid on;
            box on;
            axis square;
            
            %# Font sizes and border
            set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
            
            %# Line, colors and markers
            setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=4;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=5;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=6;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=7;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=8;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=9;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            
            %# Extended linear curve fit
            if enableTowingForceFDPlot == 1
                setMarkerSize      = 12;
                setLineWidthMarker = 2;
                set(h3(1),'Color',setColor{10},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'MarkerFaceColor',setColor{10}
                set(h5(1),'Color',setColor{10},'Marker',setMarker{11},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            end
            
            setSpeed=1;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=2;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=3;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=4;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=5;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=6;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=7;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=8;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=9;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            
            %# Set plot figure background to a defined color
            %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
            set(gcf,'Color',[1,1,1]);
            
            %# Axis limitations
            set(gca,'XLim',[0 55]);
            set(gca,'XTick',[0:5:55]);
            set(gca,'YLim',[-5 35]);
            set(gca,'YTick',[-5:5:35]);
            
            %# Legend
            %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
            hleg1 = legend('Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','none');
            if enableTowingForceFDPlot == 1
                [LEGH,OBJH,OUTH,OUTM] = legend;
                legend([OUTH;h3],OUTM{:},'Thrust at zero drag');
                [LEGH,OBJH,OUTH,OUTM] = legend;
                legend([OUTH;h5],OUTM{:},'Force at TG=0');
            end
            %legend boxoff;
            
        end
        
        %# Gross thrust = TG = p Q (vj - vi) ----------------------------------
        if enableTGBosePlot == 1
            
            if enableTGAllisonPlot == 1 && enableTGBosePlot == 1
                subplot(1,2,2);
            end
            
            %# X and Y axes data, create variables for speeds 1 to 9
            %# Note for future self: Next time use structures or arrays!!!!
            for k=1:ma
                x = A{k}(:,42);
                y = A{k}(:,10);
                eval(sprintf('x%d = x;', k));
                eval(sprintf('y%d = y;', k));
                
                % Linear fit
                P = polyfit(x,y,1);
                V = polyval(P,x);
                eval(sprintf('polyv%d = V;', k));
                % Record slopes
                % Columns:
                %[1]  Froude number                 (-)
                %[2]  Slope (i.e. -(1-t))           (-)
                %[3]  Thrust deduction, t           (-)
                if P(2) < 0
                    setDecimals = '%0.3f';
                else
                    setDecimals = '+%0.3f';
                end
                slopesArrayB(k,1) = Froude_Numbers(k,1);
                slopesArrayB(k,2) = P(1);
                slopesArrayB(k,3) = P(1)+1;
                disp(sprintf('Speed %s (TG = p QJ (vj - vi)): Equation of fit = %sx%s',num2str(k),sprintf('%0.3f',P(1)),sprintf(setDecimals,P(2))));
                
                % Extend linear fit using equation of fit
                xx = 0:max(x)*1.1;
                yy = P(1)*xx+P(2);
                eval(sprintf('xLF%d = xx;', k));
                eval(sprintf('yLF%d = yy;', k));
            end
            
            % Model self-propulsion points (i.e. gross thrus TG at towing force FD)
            TGatFD = TGB_at_FDArray;
            
            % Towing force at zero thrust
            FatTGZ = FB_at_TGZero;
            
            %# Set marker and line sizes
            setMarkerSize      = 12;
            setLineWidthMarker = 1;
            setLineWidth       = 1;
            setLineStyle       = '-';
            
            %# Plotting
            h1 = plot(x1,y1,setMarker{1},x2,y2,setMarker{2},x3,y3,setMarker{3},x4,y4,setMarker{4},x5,y5,setMarker{5},x6,y6,setMarker{6},x7,y7,setMarker{7},x8,y8,setMarker{8},x9,y9,setMarker{9});
            %# Gross thrus TG at towing force FD
            if enableTowingForceFDPlot == 1
                hold on;
                h3 = plot(TGatFD(:,1),TGatFD(:,2),'o');
                hold on;
                %# Towing force at zero thrust
                h5 = plot(FatTGZ(:,1),FatTGZ(:,2),'s');
            end
            hold on;
            %# Extended linear fit
            h4 = plot(xLF1,yLF1,xLF2,yLF2,xLF3,yLF3,xLF4,yLF4,xLF5,yLF5,xLF6,yLF6,xLF7,yLF7,xLF8,yLF8,xLF9,yLF9);
            if enablePlotTitle == 1
                title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
            end
            xlabel('{\bf Gross thrust, T_{G} (N)}','FontSize',setGeneralFontSize);
            ylabel('{\bf Towing force (N)}','FontSize',setGeneralFontSize);
            grid on;
            box on;
            axis square;
            
            %# Font sizes and border
            set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
            
            %# Set plot figure background to a defined color
            %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
            set(gcf,'Color',[1,1,1]);
            
            %# Line, colors and markers
            setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=4;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=5;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=6;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=7;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=8;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            setSpeed=9;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{setSpeed},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            
            %# Extended linear curve fit
            if enableTowingForceFDPlot == 1
                setMarkerSize      = 12;
                setLineWidthMarker = 2;
                set(h3(1),'Color',setColor{10},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'MarkerFaceColor',setColor{10}
                set(h5(1),'Color',setColor{10},'Marker',setMarker{11},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            end
            
            setSpeed=1;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=2;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=3;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=4;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=5;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=6;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=7;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=8;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            setSpeed=9;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            
            %# Axis limitations
            %set(gca,'XLim',[0 40]);
            %set(gca,'XTick',[0:5:40]);
            %set(gca,'YLim',[-5 25]);
            %set(gca,'YTick',[-5:5:25]);
            set(gca,'XLim',[0 35]);
            set(gca,'XTick',[0:5:35]);
            set(gca,'YLim',[-5 30]);
            set(gca,'YTick',[-5:5:30]);
            
            %# Legend
            %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
            hleg1 = legend('Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','none');
            if enableTowingForceFDPlot == 1
                [LEGH,OBJH,OUTH,OUTM] = legend;
                legend([OUTH;h3],OUTM{:},'Thrust at zero drag');
                [LEGH,OBJH,OUTH,OUTM] = legend;
                legend([OUTH;h5],OUTM{:},'Force at TG=0');
            end
            %legend boxoff;
            
        end
        
        %# ********************************************************************
        %# Save plot as PNG
        %# ********************************************************************
        
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
        
        %# Save plots as PDF, PNG and EPS -------------------------------------
        minRun = min(resultsArraySPP(:,1));
        maxRun = max(resultsArraySPP(:,1));
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for k=1:3
            plotsavename = sprintf('_plots/%s/%s/Run_%s_to_%s_Thrust_vs_Towing_Force_Plot.%s', 'SPP', setFileFormat{k}, num2str(minRun), num2str(maxRun), setFileFormat{k});
            print(gcf, setSaveFormat{k}, plotsavename);
        end
        %close;
        
    end
    
    % ---------------------------------------------------------------------
    % Display gross thrust at towing force, FD
    % ---------------------------------------------------------------------
    
    %# Gross thrust = TG = p Q vj -----------------------------------------
    
    %TGA_at_FDArray = TGA_at_FDArray';
    [mc,nc] = size(TGA_at_FDArray);
    
    ATG_and_F_at_T0 = [];
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Self-propulsion points at model scale                   !');
    disp('!Gross thrust (TG = p Q vj) at towing force, FD          !');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    for k=1:mc
        disp1 = A{k}(1,5);
        disp2 = TGA_at_FDArray(k, 1);
        disp3 = FA_at_TGZero(k, 2);
        disp4 = TGA_at_FDArray(k, 4);
        TF    = TGA_at_FDArray(k, 3);
        
        % Froude length number
        ATG_and_F_at_T0(k,1) = disp1;
        
        % TG at zero drag
        ATG_and_F_at_T0(k,2) = disp2;
        
        % Towing force at zero thrust
        ATG_and_F_at_T0(k,3) = disp3;
        
        % Thrust at self-propulsion point TG=TG@F=0-FD
        ATG_and_F_at_T0(k,4) = disp4;
        
        % Towing force, FD
        ATG_and_F_at_T0(k,5) = TF;
        
        dispString = sprintf('Fr = %s; TG at zero drag = %sN; Towing force (FD) = %sN; TG at SPP: %sN; F at zero T = %sN',sprintf('%.2f',disp1),sprintf('%.2f',disp2),sprintf('%.2f',TF),sprintf('%.2f',disp4),sprintf('%.2f',disp3));
        disp(dispString);
    end
    
    %# Gross thrust = TG = p Q (vj - vi) ----------------------------------
    
    %TGB_at_FDArray = TGB_at_FDArray';
    [mc,nc] = size(TGB_at_FDArray);
    
    BTG_and_F_at_T0 = [];
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Self-propulsion points at model scale                   !');
    disp('!Gross thrust (TG = p Q (vj - vi)) at towing force, FD   !');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    for k=1:mc
        disp1 = A{k}(1,5);
        disp2 = TGB_at_FDArray(k, 1);
        disp3 = FB_at_TGZero(k, 2);
        disp4 = TGB_at_FDArray(k, 4);
        TF    = TGB_at_FDArray(k, 3);
        
        % Froude length number
        BTG_and_F_at_T0(k,1) = disp1;
        
        % TG at zero drag
        BTG_and_F_at_T0(k,2) = disp2;
        
        % Towing force at zero thrust
        BTG_and_F_at_T0(k,3) = disp3;
        
        % Thrust at self-propulsion point TG=TG@F=0-FD
        BTG_and_F_at_T0(k,4) = disp4;
        
        % Towing force, FD
        BTG_and_F_at_T0(k,5) = TF;
        
        dispString = sprintf('Fr = %s; TG at zero drag = %sN; Towing force (FD) = %sN; TG at SPP: %sN; F at zero T = %sN',sprintf('%.2f',disp1),sprintf('%.2f',disp2),sprintf('%.2f',TF),sprintf('%.2f',disp4),sprintf('%.2f',disp3));
        disp(dispString);
    end
    
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Plotting not possible as dataset is not complete (i.e. data for 9 speeds)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
end

%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 2. Thrust deduction fractions
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

%# ************************************************************************
%# START Load shaft speed list (variable name is shaftSpeedList by default)
%# ------------------------------------------------------------------------
if exist('Marin112mJHSVData.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('Marin112mJHSVData.mat');
    %# Results array columns:
    %[1]  Full scale ship speed          (knots)
    %[2]  Full scale ship speed          (m/s)
    %[3]  Model scale ship speed         (m/s)
    %[4]  Froude length number           (-)
    %[5]  Thrust deduction fraction, t   (-)
    %[5]  Thrust deduction factor, (1-t) (-)
    
    %# Conditions:
    %# T5 (datasets 1-28)
    %# T5 (datasets 29-54)
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for MARIN 112m JHSV data (Marin112mJHSVData.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load shaft speed list (variable name is shaftSpeedList by default)
%# ************************************************************************

%# ************************************************************************

if enableTGAllisonPlot ~= 0 || enableTGBosePlot ~= 0
    
    %# Plotting gross thrust vs. towing force
    figurename = 'Thrust Deduction Fractions';
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
    setGeneralFontSize = 14;
    setBorderLineWidth = 2;
    
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
    setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Gross thrust = TG = p Q vj ---------------------------------------------
    if enableTGAllisonPlot == 1
        
        if enableTGAllisonPlot == 1 && enableTGBosePlot == 1
            subplot(1,2,1);
        end
        
        %# X and Y axis data
        mx1 = Marin112mJHSVData(1:28,4);
        my1 = Marin112mJHSVData(1:28,5);
        
        mx2 = Marin112mJHSVData(29:54,4);
        my2 = Marin112mJHSVData(29:54,5);
        
        % t based on slope
        tx1 = slopesArrayA(:,1);
        ty1 = slopesArrayA(:,3);
        
        % t=(TM+FD-RC)/TM
        tx2 = thrustDedFracArrayA(:,1);
        ty2 = thrustDedFracArrayA(:,2);
        
        % RCW=TG(1-t)+FD ==>> t=1-((RCW-FD)/T)
        tx3 = thrustDedFracArrayA(:,1);
        ty3 = thrustDedFracArrayA(:,3);
        
        % t = ((FD-FatT=0)/TG@SPP)+1
        tx4 = thrustDedFracArrayA(:,1);
        ty4 = thrustDedFracArrayA(:,4);
        
        % t = 1-((FatT=0-FD)/TG@SPP)
        tx5 = thrustDedFracArrayA(:,1);
        ty5 = thrustDedFracArrayA(:,5);
        
        %# Plotting
        h1 = plot(tx1,ty1,'x',tx2,ty2,'o',tx3,ty3,'+',tx4,ty4,'s',tx5,ty5,'*',mx1,my1,mx2,my2);
        if enablePlotTitle == 1
            title('{\bf Gross thrust defined as T_{G} = p Q v_{j}}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Thrust deduction fraction, t (N)}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Font sizes and border
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Line, colors and markers
        setLineWidthMarker = 2;
        setMarkerSize      = 10;
        setLineWidth       = 1;
        setLineStyle1      = '--';
        setLineStyle2      = '-.';
        set(h1(1),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize);
        set(h1(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize);
        set(h1(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize);
        set(h1(5),'Color',setColor{5},'Marker',setMarker{7},'MarkerSize',setMarkerSize);
        set(h1(6),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
        set(h1(7),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
        
        %# Axis limitations
        setXLL = 0.14;
        setXUL = 0.70;
        set(gca,'XLim',[setXLL setXUL]);
        set(gca,'XTick',[setXLL:0.04:setXUL]);
        setYLL = -0.6;
        setYUL = 0.7;
        set(gca,'YLim',[setYLL setYUL]);
        set(gca,'YTick',[setYLL:0.1:setYUL]);
        
        % t = ((FD-FatT=0)/TG@SPP)+1
        % t = 1-((FatT=0-FD)/TG@SPP)
        
        %# Legend
        hleg1 = legend('98m t by slope','98m t=(TM+FD-RC)/TM','98m using RCW=TG(1-t)+FD','98m F=TM(t-1)+FatT=0 (Øyan 2012)','98m FM=FatT=0-TM(1-t) (Bose 2008)','112m MARIN JHSV Cond. T5','112m MARIN JHSV Cond. T4');
        set(hleg1,'Location','SouthEast');
        set(hleg1,'Interpreter','none');
        %legend boxoff;
        
    end
    
    %# Gross thrust = TG = p Q (vj - vi) --------------------------------------
    if enableTGBosePlot == 1
        
        if enableTGAllisonPlot == 1 && enableTGBosePlot == 1
            subplot(1,2,2);
        end
        
        %# X and Y axis data
        mx1 = Marin112mJHSVData(1:28,4);
        my1 = Marin112mJHSVData(1:28,5);
        
        mx2 = Marin112mJHSVData(29:54,4);
        my2 = Marin112mJHSVData(29:54,5);
        
        % t based on slope
        tx1 = slopesArrayB(:,1);
        ty1 = slopesArrayB(:,3);
        
        % t=(TM+FD-RC)/TM
        tx2 = thrustDedFracArrayB(:,1);
        ty2 = thrustDedFracArrayB(:,2);
        
        % RCW=TG(1-t)+FD ==>> t=1-((RCW-FD)/T)
        tx3 = thrustDedFracArrayB(:,1);
        ty3 = thrustDedFracArrayB(:,3);
        
        % t = ((FD-FatT=0)/TG@SPP)+1
        tx4 = thrustDedFracArrayB(:,1);
        ty4 = thrustDedFracArrayB(:,4);
        
        % t = 1-((FatT=0-FD)/TG@SPP)
        tx5 = thrustDedFracArrayB(:,1);
        ty5 = thrustDedFracArrayB(:,5);
        
        %# Plotting
        h1 = plot(tx1,ty1,'x',tx2,ty2,'o',tx3,ty3,'+',tx4,ty4,'s',tx5,ty5,'*',mx1,my1,mx2,my2);
        if enablePlotTitle == 1
            title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Thrust deduction fraction, t (N)}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Font sizes and border
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Line, colors and markers
        setLineWidthMarker = 2;
        setMarkerSize      = 10;
        setLineWidth       = 1;
        setLineStyle1      = '--';
        setLineStyle2      = '-.';
        set(h1(1),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize);
        set(h1(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize);
        set(h1(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize);
        set(h1(5),'Color',setColor{5},'Marker',setMarker{7},'MarkerSize',setMarkerSize);
        set(h1(6),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
        set(h1(7),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
        
        %# Axis limitations
        setXLL = 0.14;
        setXUL = 0.70;
        set(gca,'XLim',[setXLL setXUL]);
        set(gca,'XTick',[setXLL:0.04:setXUL]);
        setYLL = -0.6;
        setYUL = 0.7;
        set(gca,'YLim',[setYLL setYUL]);
        set(gca,'YTick',[setYLL:0.1:setYUL]);
        
        %# Legend
        hleg1 = legend('98m t by slope','98m t=(TM+FD-RC)/TM','98m using RCW=TG(1-t)+FD','98m F=TM(t-1)+FatT=0 (Øyan 2012)','98m FM=FatT=0-TM(1-t) (Bose 2008)','112m MARIN JHSV Cond. T5','112m MARIN JHSV Cond. T4');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        %legend boxoff;
        
    end
    
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
    minRun = min(resultsArraySPP(:,1));
    maxRun = max(resultsArraySPP(:,1));
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_%s_Fr_vs_Thrust_Deduction_Fraction_Plot.%s', 'SPP', setFileFormat{k}, num2str(minRun), num2str(maxRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 3. Resistance vs. TG at Towing Force (FD) and F at zero Thrust (FT=0)
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

if enableTGAllisonPlot ~= 0 || enableTGBosePlot ~= 0
    
    %# Plotting gross thrust vs. towing force
    figurename = 'Resistance vs. Gross Thrust at Towing Force F_{D} and Force at Zero Thrust F_{T=0}';
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
    setGeneralFontSize = 14;
    setBorderLineWidth = 2;
    
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
    
    %# Gross thrust = TG = p Q vj ---------------------------------------------
    if enableTGAllisonPlot == 1
        
        if enableTGAllisonPlot == 1 && enableTGBosePlot == 1
            subplot(1,2,1);
        end
        
        %# X and Y axis data
        TA = ATG_and_F_at_T0;
        
        % Resistance uncorrected
        %xr = resistance(:,1);
        %yr = resistance(:,2);
        
        % Resistance corrected for temp. diff. RES and SPT test
        xr = resistance(:,1);
        yr = resistance(:,3);
        
        % TG at zero drag
        x1 = TA(:,1);
        y1 = TA(:,2);
        
        % Towing force at zero thrust
        x2 = TA(:,1);
        y2 = TA(:,3);
        
        % Thrust at self-propulsion point TG=TG@F=0-FD
        x3 = TA(:,1);
        y3 = TA(:,4);
        
        % Towing force, FD
        x4 = TA(:,1);
        y4 = TA(:,5);
        
        %# Plotting
        h1 = plot(xr,yr,x1,y1,'s',x2,y2,'*',x3,y3,'o',x4,y4,'^');
        if enablePlotTitle == 1
            title('{\bf Gross thrust defined as T_{G} = p Q v_{j}}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force, force at T=0 and gross thrust (N)}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Font sizes and border
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Line, colors and markers
        setMarkerSize1     = 12;
        setMarkerSize2     = 11;
        setLineWidth       = 2;
        setLineWidthMarker = 1;
        setLineStyle       = '-';
        set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        set(h1(2),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
        set(h1(3),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
        set(h1(4),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
        set(h1(5),'Color',setColor{4},'Marker',setMarker{8},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
        
        %# Axis limitations
        set(gca,'XLim',[0.22 0.42]);
        set(gca,'XTick',[0.22:0.02:0.42]);
        set(gca,'YLim',[0 50]);
        set(gca,'YTick',[0:5:50]);
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('Resistance (RC)','Gross thrust (TG) at zero drag','Towing force at zero thrust','Thrust at SPP','Towing force, FD');
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');
        %legend boxoff;
    end
    
    %# Gross thrust = TG = p Q (vj - vi) --------------------------------------
    if enableTGBosePlot == 1
        
        if enableTGAllisonPlot == 1 && enableTGBosePlot == 1
            subplot(1,2,2);
        end
        
        %# X and Y axis data
        TA = BTG_and_F_at_T0;
        
        % Resistance uncorrected
        %xr = resistance(:,1);
        %yr = resistance(:,2);
        
        % Resistance corrected for temp. diff. RES and SPT test
        xr = resistance(:,1);
        yr = resistance(:,3);
        
        % TG at zero drag
        x1 = TA(:,1);
        y1 = TA(:,2);
        
        % Towing force at zero thrust
        x2 = TA(:,1);
        y2 = TA(:,3);
        
        % Thrust at self-propulsion point TG=TG@F=0-FD
        x3 = TA(:,1);
        y3 = TA(:,4);
        
        % Towing force, FD
        x4 = TA(:,1);
        y4 = TA(:,5);
        
        %# Plotting
        h1 = plot(xr,yr,x1,y1,'s',x2,y2,'*',x3,y3,'o',x4,y4,'^');
        if enablePlotTitle == 1
            title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force, force at T=0 and gross thrust (N)}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Font sizes and border
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Line, colors and markers
        setMarkerSize1     = 12;
        setMarkerSize2     = 11;
        setLineWidth       = 2;
        setLineWidthMarker = 1;
        setLineStyle       = '-';
        set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        set(h1(2),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
        set(h1(3),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
        set(h1(4),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
        set(h1(5),'Color',setColor{4},'Marker',setMarker{8},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
        
        %# Axis limitations
        set(gca,'XLim',[0.22 0.42]);
        set(gca,'XTick',[0.22:0.02:0.42]);
        set(gca,'YLim',[0 40]);
        set(gca,'YTick',[0:5:40]);
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('Resistance (RC)','Gross thrust (TG) at zero drag','Towing force at zero thrust','Thrust at SPP','Towing force, FD');
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');
        %legend boxoff;
    end
    
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
    minRun = min(resultsArraySPP(:,1));
    maxRun = max(resultsArraySPP(:,1));
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/Run_%s_to_%s_Fr_vs_Towing_Force_and_F_at_Zero_Thrust_Plot.%s', 'SPP', setFileFormat{k}, num2str(minRun), num2str(maxRun), setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end

%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 4. Extrapolation to full scale.
%$ NOTE: Calculations for TG = p Q (vj - vi) method only!
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

% Columns:
% [1] Froude length number                              (-)
% [2] TG at zero drag                                   (N)
% [3] Towing force at zero thrust                       (N)
% [4] Thrust at self-propulsion point TG=TG@F=0-FD      (N)
% [5] Towing force, FD                                  (N)

ThrustDedFracArray = thrustDedFracArrayB;
[mt,nt] = size(ThrustDedFracArray);

ForcesArray = BTG_and_F_at_T0;
[m,n] = size(ForcesArray);

fullScaleDataArray = [];
for k=1:m
    
    % Model scale variables
    MSSpeed      = mean(A{k}(:,6));           % Model scale speed (m/s)
    MSReynoldsNo = (MSSpeed*MSlwl)/MSKinVis;  % Full scale reynolds number (-)
    MSRT         = resistance(k,3);
    MSCT         = MSRT/(0.5*freshwaterdensity*MSwsa*MSSpeed^2);
    if MSReynoldsNo < 10000000
        MSCF = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
    else
        MSCF = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
    end
    MSCR         = MSCT-MSCF;
    MSThrustDed  = ThrustDedFracArray(k,4);
    
    % Full scale variables
    FSSpeed      = MSSpeed*sqrt(FStoMSratio); % Full scale speed (m/s)
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;  % Full scale reynolds number (-)
    FSCR         = MSCR;
    
    % 1. Speed and reynolds number ----------------------------------------
    
    % [1]  Froude length number                              (-)
    % [2]  Full scale speed                                  (m/s)
    % [3]  Full scale speed                                  (knots)
    % [4]  Full scale reynolds number                        (-)
    
    fullScaleDataArray(k,1)  = ForcesArray(k,1);
    fullScaleDataArray(k,2)  = FSSpeed;
    fullScaleDataArray(k,3)  = FSSpeed/0.51444;
    fullScaleDataArray(k,4)  = FSReynoldsNo;
    
    % 2. Shaft speed ------------------------------------------------------
    
    % [5] PORT: Shaft speed                                  (RPM)
    % [6] STBD: Shaft speed                                  (RPM)
    % [7] PORT: Shaft speed                                  (RPS)
    % [8] STBD: Shaft speed                                  (RPS)
    
    FSPortSS = shaftSpeedConvArray(k,4);
    FSStbdSS = shaftSpeedConvArray(k,5);
    fullScaleDataArray(k,5) = FSPortSS;
    fullScaleDataArray(k,6) = FSStbdSS;
    fullScaleDataArray(k,7) = FSPortSS/60;
    fullScaleDataArray(k,8) = FSStbdSS/60;
    
    % 3. Resistance -------------------------------------------------------
    
    % [9]  Frictional resistance coefficient, CFs            (-)
    % [10] Residual resistannce coefficient, CRs             (-)
    % [11] Total resistannce coefficient, CTs                (-)
    % [12] Total resistance, RT                              (-)
    
    if FSReynoldsNo < 10000000
        FSCF = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2);
    else
        FSCF = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3);
    end
    FSCT = FSCF+FSCR;
    FSRT = 0.5*saltwaterdensity*FSSpeed^2*FSwsa*FSCT;
    fullScaleDataArray(k,9)  = FSCF;
    fullScaleDataArray(k,10) = FSCR;
    fullScaleDataArray(k,11) = FSCT;
    fullScaleDataArray(k,12) = FSRT;
    
    % 4. Effective power, PE ----------------------------------------------
    
    % [13] Effective power, PE                               (W)
    % [14] Effective power, PE                               (kW)
    % [15] Effective power, PE                               (mW)
    
    PEW  = FSRT*FSSpeed;
    PEkW = PEW/1000;
    PEmW = PEkW/1000;
    fullScaleDataArray(k,13) = PEW;
    fullScaleDataArray(k,14) = PEkW;
    fullScaleDataArray(k,15) = PEmW;
    
    % 5. Wake fraction (w) and thrust deduction (t) -----------------------
    
    % [16] Wake fraction, ws                                 (-)
    % [17] Wake fraction, 1-ws                               (-)
    % [18] Thrust deduction, t                               (-)
    % [19] Thrust deduction, 1-t                             (-)
    
    MSWakeFraction = 1-((A{k}(1,36)+A{k}(1,37))/2);
    %FSWakeFraction = (MSWakeFraction*(FSCF/MSCF))+(MSThrustDed+0.04)*(1-(FSCF/MSCF));
    FSWakeFraction = (MSWakeFraction*(FSCF/MSCF));
    fullScaleDataArray(k,16) = FSWakeFraction;
    fullScaleDataArray(k,17) = 1-FSWakeFraction;
    fullScaleDataArray(k,18) = MSThrustDed;
    fullScaleDataArray(k,19) = 1-MSThrustDed;
    
    % 6. Gross thrust, TG = TGm ?3 (?s/?m) --------------------------------
    
    % [20] PORT: Gross thrust, TGs                           (N)
    % [21] STBD: Gross thrust, TGs                           (N)
    
    % Neglect run 70 and 71 (as faulty)
    if k == 4
        ratioRow = 3;
    else
        ratioRow = 1;
    end
    PortStbdRatio = A{k}(ratioRow,40)/A{k}(ratioRow,42);
    FSPortGrosThrust = (TGB_at_FDArray(k,4)*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    PortStbdRatio = A{k}(ratioRow,41)/A{k}(ratioRow,42);
    FSStbdGrosThrust = (TGB_at_FDArray(k,4)*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    fullScaleDataArray(k,20) = FSPortGrosThrust;
    fullScaleDataArray(k,21) = FSStbdGrosThrust;
    
    % 7. Mass flow rate (pQJ) and volumetric flow rate (QJ) ---------------
    
    % [22] PORT: Volumetric flow rate, QJ                    (m^3/s)
    % [22] STBD: Volumetric flow rate, QJ                    (m^3/s)
    % [23] PORT: Mass flow rate, pQJ                         (Kg/s)
    % [24] STBD: flow rate, pQJ                              (Kg/s)
    
    % Port
    var_A         = saltwaterdensity/FS_NozzArea;
    var_B         = saltwaterdensity*((1-FSWakeFraction)*FSSpeed)*-1;
    var_C         = FSPortGrosThrust*-1;
    MSPortVolFR   = (((-1)*var_B)+sqrt(var_B^2-4*var_A*var_C))/(2*var_A);
    % Stbd
    var_C         = FSStbdGrosThrust*-1;
    MSStbdVolFR   = (((-1)*var_B)+sqrt(var_B^2-4*var_A*var_C))/(2*var_A);
    
    % Show variables A,B and C for quadratic equation
    %disp(sprintf('Fr=%s | TP=%s | TS=%s | A=%s | B=%s | CP=%s | CS=%s | VFRP=%s | VFRP=%s',sprintf('%.2f',ForcesArray(k,1)),num2str(FSPortGrosThrust),num2str(FSStbdGrosThrust),num2str(var_A),num2str(var_B),num2str(FSPortGrosThrust*-1),num2str(FSStbdGrosThrust*-1),num2str(MSPortVolFR),num2str(MSStbdVolFR)));
    
    MSPortMasFR = MSPortVolFR*saltwaterdensity;
    MSStbdMasFR = MSStbdVolFR*saltwaterdensity;
    fullScaleDataArray(k,22) = MSPortVolFR;
    fullScaleDataArray(k,23) = MSStbdVolFR;
    fullScaleDataArray(k,24) = MSPortMasFR;
    fullScaleDataArray(k,25) = MSStbdMasFR;
    
    % 8. Jet and inlet velocities -----------------------------------------
    
    % [26] PORT: Jet velocity, vj                            (m/s)
    % [27] STBD: Jet velocity, vj                            (m/s)
    % [28] PORT: Inlet velocity, vi                          (m/s)
    % [29] STBD: Inlet velocity, vi                          (m/s)\
    
    MSPortJetVel = MSPortVolFR/FS_NozzArea;
    MSStbdJetVel = MSStbdVolFR/FS_NozzArea;
    MSPortInlVel = (1-FSWakeFraction)*FSSpeed;
    MSStbdInlVel = (1-FSWakeFraction)*FSSpeed;
    fullScaleDataArray(k,26) = MSPortJetVel;
    fullScaleDataArray(k,27) = MSStbdJetVel;
    fullScaleDataArray(k,28) = MSPortInlVel;
    fullScaleDataArray(k,29) = MSStbdInlVel;
    
    % 9. Efficiencies ---------------------------------------------------------
    
    % [30] Hull efficiency, nh                               (-)
    % [31] Optimum efficiency, ni                            (-)
    
    fullScaleDataArray(k,30) = (1-MSThrustDed)/(1-FSWakeFraction);
    fullScaleDataArray(k,31) = 1-((MSPortJetVel/FSSpeed)-1)^2;
    
    % 10. Pump related data -----------------------------------------------
    
    % [32] PORT: Flow coefficient                            (-)
    % [33] STBD: Flow coefficient                            (-)
    % [34] PORT: Pump head, H                                (m)
    % [35] STBD: Pump head, H                                (m)
    % [36] PORT: Head coefficient                            (-)
    % [37] STBD: Head coefficient                            (-)
    % [38] PORT: Pump efficieny, npump                       (-)
    % [39] STBD: Pump efficieny, npump                       (-)
    
    fullScaleDataArray(k,32) = MSPortVolFR/((FSPortSS/60)*FS_PumpDia^3);
    fullScaleDataArray(k,33) = MSStbdVolFR/((FSStbdSS/60)*FS_PumpDia^3);
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# TOTO: Replace arrays with function that looks up pump head (m)
    %#       from WJ benchmark data.
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    PortPH = [24.69 27.57 31.01 34.98 38.61 42.33 44.76 51.15 58.71];
    StbdPH = [24.62 27.50 31.00 34.93 38.59 42.26 44.76 51.04 58.55];
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    FSPortPumphead = PortPH(k);
    FSStbdPumphead = StbdPH(k);
    fullScaleDataArray(k,34) = FSPortPumphead;
    fullScaleDataArray(k,35) = FSStbdPumphead;
    
    fullScaleDataArray(k,36) = gravconst*FSPortPumphead/((FSPortSS/60)*FS_PumpDia)^2;
    fullScaleDataArray(k,37) = gravconst*FSStbdPumphead/((FSStbdSS/60)*FS_PumpDia)^2;
    
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# TOTO: Replace arrays with function that looks up pump efficiency (-)
    %#       from WJ benchmark data.
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    PortPE = [0.66 0.66 0.65 0.65 0.65 0.65 0.65 0.66 0.66];
    StbdPE = [0.65 0.65 0.65 0.65 0.65 0.65 0.65 0.65 0.65];
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    FSPortPumpEff  = StbdPE(k);
    FSStbdPumpEff  = StbdPE(k);
    fullScaleDataArray(k,38) = FSPortPumpEff;
    fullScaleDataArray(k,39) = FSStbdPumpEff;
    
    % 11. Overall prop. eff., delivered and brake power (ns=0.98) ---------
    
    % [40] PORT: Pump effective power, PPE                   (W)
    % [41] PORT: Pump effective power, PPE                   (W)
    % [42] PORT: Delivered power, PD                         (W)
    % [43] PORT: Delivered power, PD                         (W)
    % [44] PORT: Brake power, PB                             (W)
    % [45] PORT: Brake power, PB                             (W)
    % [46] Overall propulsive efficieny, nD=PE/PD            (-)
    
    % Energy fluxes at stations 0, 1 and 7
    FSPortEFStat1 = 0.5*saltwaterdensity*MSPortVolFR*(MSPortInlVel^2)*(1-FSWakeFraction)^2;
    FSStbdEFStat1 = 0.5*saltwaterdensity*MSStbdVolFR*(MSStbdInlVel^2)*(1-FSWakeFraction)^2;
    FSPortEFStat7 = 0.5*saltwaterdensity*MSPortVolFR*MSPortJetVel^2;
    FSStbdEFStat7 = 0.5*saltwaterdensity*MSPortVolFR*MSStbdJetVel^2;
    FSEFStat0     = 0.5*saltwaterdensity*FSSpeed^2;    
    
    % Nozzle and ideal efficiency
    FSPortNozzleEff = 0.98;
    FSStbdNozzleEff = 0.98;
    FSPortIdealEff  = 2/(1+(MSPortJetVel/MSPortInlVel));
    FSStbdIdealEff  = 2/(1+(MSStbdJetVel/MSStbdInlVel));    
    
    % Pump effective power, PPE
    FSPortPumpEffPower = (FSPortEFStat7/FSPortNozzleEff)-FSPortIdealEff*FSPortEFStat1;
    FSStbdPumpEffPower = (FSStbdEFStat7/FSStbdNozzleEff)-FSStbdIdealEff*FSStbdEFStat1;
    fullScaleDataArray(k,40) = FSPortPumpEffPower;
    fullScaleDataArray(k,41) = FSStbdPumpEffPower;
    
    % Delivered power, PD
    FSPortDelPower = FSPortPumpEffPower/FSPortPumpEff;
    FSStbdDelPower = FSStbdPumpEffPower/FSStbdPumpEff;
    fullScaleDataArray(k,42) = FSPortDelPower;
    fullScaleDataArray(k,43) = FSStbdDelPower;
    
    % Brake power (assumed shaft loss 2% and gear box 2%), PB
    FSPortBrakePower = FSPortDelPower/0.98;
    FSStbdBrakePower = FSStbdDelPower/0.98;
    FSPortBrakePower = FSPortBrakePower/0.98;
    FSStbdBrakePower = FSStbdBrakePower/0.98;
    fullScaleDataArray(k,44) = FSPortBrakePower;
    fullScaleDataArray(k,45) = FSStbdBrakePower;
    
    % Overall propulsive efficiency based on nD = PE/PD where PD = PPE/hpump
    fullScaleDataArray(k,46) = PEW/(FSPortDelPower+FSStbdDelPower);
    
    % 12. IVR, JVR and NVR ------------------------------------------------
    
    % [47] PORT: Inlet velocity ratio, IVR=Vin/Vm            (-)
    % [48] STBD: Inlet velocity ratio, IVR=Vin/Vm            (-)
    % [49] PORT: Jet velocity ratio, JVR=Vj/Vm               (-)
    % [50] STBD: Jet velocity ratio, JVR=Vj/Vm               (-)
    % [51] PORT: Nozzle velocity ratio, NVR=Vj/Vin           (-)
    % [52] STBD: Nozzle velocity ratio, NVR=Vj/Vin           (-)
    
    FSPortIVR = MSPortInlVel/FSSpeed;
    FSStbdIVR = MSStbdInlVel/FSSpeed;
    FSPortJVR = MSPortJetVel/FSSpeed;
    FSStbdJVR = MSStbdJetVel/FSSpeed;
    FSPortNVR = MSPortJetVel/FSSpeed; %MSPortInlVel
    FSStbdNVR = MSStbdJetVel/FSSpeed; %MSStbdInlVel
    fullScaleDataArray(k,47) = FSPortIVR;
    fullScaleDataArray(k,48) = FSStbdIVR;
    fullScaleDataArray(k,49) = FSPortJVR;
    fullScaleDataArray(k,50) = FSStbdJVR;
    fullScaleDataArray(k,51) = FSPortNVR;
    fullScaleDataArray(k,52) = FSStbdNVR;
    
    % 13. Energy flux at Station 1 and 7, PJSE ----------------------------
    
    % [53] PORT: Energy flux at Station 1, E1                (W)
    % [54] STBD: Energy flux at Station 1, E1                (W)
    % [55] PORT: Energy flux at Station 7, E7                (W)
    % [56] STBD: Energy flux at Station 7, E7                (W)
    % [57] Energy flux at Station 0, E0                      (W)
    % [58] PORT: Eff. jet system power, PJSE                 (W)
    % [59] STBD: Eff. jet system power, PJSE                 (W)
    
    FSPortPJSE    = FSPortEFStat7-FSPortEFStat1;
    FSStbdPJSE    = FSStbdEFStat7-FSStbdEFStat1;
    fullScaleDataArray(k,53) = FSPortEFStat1;
    fullScaleDataArray(k,54) = FSStbdEFStat1;
    fullScaleDataArray(k,55) = FSPortEFStat7;
    fullScaleDataArray(k,56) = FSStbdEFStat7;
    fullScaleDataArray(k,57) = FSEFStat0;
    fullScaleDataArray(k,58) = FSPortPJSE;
    fullScaleDataArray(k,59) = FSStbdPJSE;
    
    % 14. Thrust effective power, PTE -------------------------------------
    
    % [60] PORT: Thrust effective power, PTE                 (W)
    % [61] STBD: Thrust effective power, PTE                 (W)
    
    FSPortPTE = FSPortGrosThrust*FSSpeed;
    FSStbdPTE = FSStbdGrosThrust*FSSpeed;
    fullScaleDataArray(k,60) = FSPortPTE;
    fullScaleDataArray(k,61) = FSStbdPTE;
    
    % 15. Additional efficiencies -----------------------------------------
    
    % [62] PORT: Nozzle efficiency, nn                       (-)
    % [63] STBD: Nozzle efficiency, nn                       (-)
    % [64] PORT: Ideal efficiency, nI                        (-)
    % [65] STBD: Ideal efficiency, nI                        (-)
    % [66] PORT: Jet system efficiency, nJS                  (-)
    % [67] STBD: Jet system efficiency, nJS                  (-)
    
    FSPortJetSysEff = FSPortPTE/FSPortPJSE;
    FSStbdJetSysEff = FSStbdPTE/FSStbdPJSE;
    fullScaleDataArray(k,62) = FSPortNozzleEff;
    fullScaleDataArray(k,63) = FSStbdNozzleEff;
    fullScaleDataArray(k,64) = FSPortIdealEff;
    fullScaleDataArray(k,65) = FSStbdIdealEff;
    fullScaleDataArray(k,66) = FSPortJetSysEff;
    fullScaleDataArray(k,67) = FSStbdJetSysEff;
    
    % Overall propulsive efficiency based on nD = PE/PD where PD = PJSE/hJS
    FSPortPDETemp = FSPortPJSE/FSPortJetSysEff;
    FSStbdPDETemp = FSStbdPJSE/FSStbdJetSysEff;
    fullScaleDataArray(k,68) = PEW/(FSPortPDETemp+FSStbdPDETemp);
    
end


%# ************************************************************************
%# Plotting full scale results
%# ************************************************************************

%# ------------------------------------------------------------------------
%# 1. Overall propulsive efficiency, nD
%# ------------------------------------------------------------------------

figurename = 'Full Scale Extrapolation: Propulsive efficiency';
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
setGeneralFontSize = 14;
setBorderLineWidth = 2;

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
%setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# ************************************************************************
%# SUBPLOT #1: Overall propulsive efficiency
%# ************************************************************************
%subplot(1,2,1);

%# X and Y axis -----------------------------------------------------------

%# Overall propulsive efficiency where nD = PE/PD where PD = PPE/hpump
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,46);

%# Overall propulsive efficiency where nD = PE/PD where PD = PJSE/hJS
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,68);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*');
%xlabel('{\bf Froude length number, F_{R} (-)}','FontSize',setGeneralFontSize);
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Overall propulsive efficiency, \eta_{D} (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Overall propulsive efficiency}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineStyle       = '-.';
set(h(1),'Color',setColor{3},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{1},'Marker',setMarker{11},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
%set(gca,'XLim',[0.22 0.42]);
%set(gca,'XTick',[0.22:0.02:0.42]);
set(gca,'XLim',[13 25]);
set(gca,'XTick',[13:1:25]);
set(gca,'YLim',[0 1]);
set(gca,'YTick',[0:0.1:1]);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('\eta_{D}=P_{E}/P_{D} where P_{D}=P_{PE}/\eta_{pump}','\eta_{D}=P_{E}/P_{D} where P_{D}=P_{JSE}/\eta_{JS}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# SUBPLOT #2: Flow and head coefficients
%# ************************************************************************
% subplot(1,2,2);
% 
% %# X and Y axis -----------------------------------------------------------
% 
% % Port
% x1 = fullScaleDataArray(:,32);
% x1 = [0.9986 0.9616 0.9246 0.8876 0.8506 0.8136 0.7767 0.7397 0.5548];
% y1 = fullScaleDataArray(:,34);
% y1 = [2.2694 2.6225 2.9896 3.3148 3.6135 3.9261 4.1299 4.2653 4.3965];
% 
% % Starboard
% x2 = fullScaleDataArray(:,33);
% x2 = [0.9986 0.9616 0.9246 0.8876 0.8506 0.8136 0.7767 0.7397 0.5548];
% y2 = fullScaleDataArray(:,35);
% y2 = [2.1694 2.5225 2.8896 3.2148 3.5135 3.8261 4.0299 4.1653 4.2965];
% 
% %# Plotting ---------------------------------------------------------------
% h = plot(x1,y1,'*',x2,y2,'*');
% xlabel('{\bf Flow coefficient, \phi (-)}','FontSize',setGeneralFontSize);
% ylabel('{\bf Head coefficient, \psi (-)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Flow and head coefficients}','FontSize',setGeneralFontSize);
% end
% grid on;
% box on;
% axis square;
% 
% %# Line, colors and markers
% setMarkerSize      = 11;
% setLineWidthMarker = 2;
% setLineWidth       = 1;
% setLineStyle       = '-.';
% set(h(1),'Color',setColor{2},'Marker',setMarker{11},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% set(h(2),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% 
% %# Set plot figure background to a defined color
% %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
% set(gcf,'Color',[1,1,1]);
% 
% %# Axis limitations
% xStart = str2num(sprintf('%.1f',min(x1)))-0.1;
% xEnd   = str2num(sprintf('%.1f',max(x1)))+0.1;
% yStart = str2num(sprintf('%.1f',min(y1)))-0.1;
% yEnd   = str2num(sprintf('%.1f',max(y1)))+0.1;
% set(gca,'XLim',[xStart xEnd]);
% set(gca,'XTick',[xStart:0.1:xEnd]);
% if mod(yEnd-yStart,0.2)== 0
%     SetyEnd = yEnd;
% else
%     SetyEnd = yEnd+0.1;
% end
% set(gca,'YLim',[yStart SetyEnd]);
% set(gca,'YTick',[yStart:0.2:SetyEnd]);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))
% 
% %# Legend
% %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
% hleg1 = legend('Port WJ','Starboard WJ');
% set(hleg1,'Location','NorthEast');
% set(hleg1,'Interpreter','none');
% %legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ********************************************************************
%# Save plot as PNG
%# ********************************************************************

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

%# Save plots as PDF, PNG and EPS -------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Overall_Propulsive_Efficiency_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ------------------------------------------------------------------------
%# 2. Power plots (two propulsion systems ==>> a single demihull)
%# ------------------------------------------------------------------------

figurename = 'Full Scale Extrapolation: Power plots (two propulsion systems for a single demihull)';
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
setGeneralFontSize = 14;
setBorderLineWidth = 2;

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

%# X and Y axis -----------------------------------------------------------

[m,n] = size(fullScaleDataArray);

%# Effective power, PE
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,15);

%# Delivered power, PD
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,42)+fullScaleDataArray(kx,43))/1000^2;
end
x2 = fullScaleDataArray(:,3);
y2 = TotalPower;

%# Delivered power, PD (Sea Trials Data)
%x3 = XXX;
%y3 = YYY;

%# Pump effective power, PPE
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,40)+fullScaleDataArray(kx,41))/1000^2;
end
x4 = fullScaleDataArray(:,3);
y4 = TotalPower;

%# Effective jet system power, PJSE
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,58)+fullScaleDataArray(kx,59))/1000^2;
end
x5 = fullScaleDataArray(:,3);
y5 = TotalPower;

%# Thrust effective power, PTE
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,60)+fullScaleDataArray(kx,61))/1000^2;
end
x6 = fullScaleDataArray(:,3);
y6 = TotalPower;

%# Plotting ---------------------------------------------------------------
%h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
h = plot(x1,y1,'*',x2,y2,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
%xlabel('{\bf Froude length number, F_{R} (-)}','FontSize',setGeneralFontSize);
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Power (MW)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Power estimates}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineStyle       = '-.';
setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%setCurveNo=6;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{setCurveNo},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
set(gca,'XLim',[13 25]);
set(gca,'XTick',[13:1:25]);
set(gca,'YLim',[0 6]);
set(gca,'YTick',[0:1:6]);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend('Effective power (P_{E})','Delivered power (P_{D})','Delivered power (P_{D}) from sea trials data)','Pump effective power (P_{PE})','Effective jet system power (P_{JSE})','Thrust effective power (P_{TE})');
hleg1 = legend('Effective power (P_{E})','Delivered power (P_{D})','Pump effective power (P_{PE})','Effective jet system power (P_{JSE})','Thrust effective power (P_{TE})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ********************************************************************
%# Save plot as PNG
%# ********************************************************************

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

%# Save plots as PDF, PNG and EPS -------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Power_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ------------------------------------------------------------------------
%# 3. Speed plots
%# ------------------------------------------------------------------------

figurename = 'Full Scale Extrapolation: Jet velocitiy and inlet velocity';
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
setGeneralFontSize = 14;
setBorderLineWidth = 2;

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

%# X and Y axis -----------------------------------------------------------

[m,n] = size(fullScaleDataArray);

%# Effective power, PE
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,2);

%# Delivered power, PD
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,26);

%# Delivered power, PD
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,27);

%# Delivered power, PD
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,28);

%# Delivered power, PD
x5 = fullScaleDataArray(:,3);
y5 = fullScaleDataArray(:,29);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Jet and inlet velocity (m/s)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Jet velocitiy and inlet velocity}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
setMarkerSize      = 11;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineStyle       = '-.';
setCurveNo=1;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=2;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=3;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=4;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
setCurveNo=5;set(h(setCurveNo),'Color',setColor{setCurveNo},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
set(gca,'XLim',[13 25]);
set(gca,'XTick',[13:1:25]);
set(gca,'YLim',[0 24]);
set(gca,'YTick',[0:4:24]);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('Ship speed (v_{s})','Port: Jet velocity (v_{j})','Stbd: Jet velocity (v_{j})','Port: Inlet velocity (v_{i})','Stbd: Inlet velocity (v_{i})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ********************************************************************
%# Save plot as PNG
%# ********************************************************************

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

%# Save plots as PDF, PNG and EPS -------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Full_Scale_Speed_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# START: Write results to DAT and TXT
%# ------------------------------------------------------------------------

fullScaleDataArray = fullScaleDataArray(any(fullScaleDataArray,2),:);       % Remove zero rows
M = fullScaleDataArray;
%M = M(any(M,2),:);                                                         % remove zero rows only in resultsArraySPP text file
csvwrite('fullScaleDataArray.dat', M)                                       % Export matrix M to a file delimited by the comma character
%dlmwrite('fullScaleDataArray.txt', M, 'delimiter', '\t', 'precision', 4)   % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

%# ------------------------------------------------------------------------
%# END: Write results to DAT and TXT
%# ************************************************************************


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer
