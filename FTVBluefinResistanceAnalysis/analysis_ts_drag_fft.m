%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Time Series analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  May 14, 2014
%#
%# Test date  :  April 8 to April 11, 2014
%# Facility   :  AMC, Towing Tank (TT)
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  14/05/2014 - Created new script
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
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
% testName = 'Turbulence Stud Investigation';
% testName = 'Trim Tab Optimistation';
testName = 'Resistance Test';

%# DAQ related settings ----------------------------------------------------
Fs = 200;                               % DAQ sampling frequency = 200Hz

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************

%# ------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# ------------------------------------------------------------------------
headerlines             = 22;  % Number of headerlines to data
headerlinesZeroAndCalib = 16;  % Number of headerlines to zero and calibration factors


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START: Omit first X seconds of data due to acceleration
%# ------------------------------------------------------------------------

% X seconds x sample frequency = X x FS = XFS samples (from start)
startSamplePos    = 1;
%startSamplePos    = 1000;   % Cut first 5 seconds

% X seconds x sample frequency = X x FS = XFS samples (from end)
cutSamplesFromEnd = 0;   
%cutSamplesFromEnd = 400;    % Cut last 2 seconds

%# ------------------------------------------------------------------------
%# END: Omit first 10 seconds of data due to acceleration
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% All runs
startRun = 2;       % Start at run x
endRun   = 18;      % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 18;                     % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
modelkinviscosity   = (((0.585*10^(-3))*(ttwatertemp-12)-0.03361)*(ttwatertemp-12)+1.235)*10^(-6); % Model scale kinetic viscosity at X (see ttwatertemp) degrees following ITTC (m2/s)
fullscalekinvi      = 0.000001034;            % Full scale kinetic viscosity     (m^2/s)
freshwaterdensity   = 1000;                   % Model scale water density        (Kg/m^3)
saltwaterdensity    = 1025;                   % Salt water scale water density   (Kg/m^3)
distbetwposts       = 950;                    % Distance between carriage posts  (mm)
FStoMSratio         = 20;                     % Full scale to model scale ratio  (-)

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: #1
%# ------------------------------------------------------------------------

MSlwl   = 1.608;                     % Model length waterline          (m)
MSwsa   = 0.96;                      % Model scale wetted surface area (m^2)
MSdraft = 0.174;                     % Model draft                     (m)
FSlwl   = MSlwl*FStoMSratio;         % Full scale length waterline     (m)
FSwsa   = MSwsa*FStoMSratio^2;       % Full scale wetted surface area  (m^2)
FSdraft = MSdraft*FStoMSratio;       % Full scale draft                (m)

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArray   = [];
freqArray      = [];
frequencyArray = [];
%w = waitbar(0,'Processed run files');
for k=startRun:endRun
    
    %# Allow for 1 to become 01 for run numbers
    if k < 10
        filename = sprintf('%sR0%s.run\\RR0%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    else
        filename = sprintf('%sR%s.run\\RR%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
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
    
%     fPath = '_time_series_data/';
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else
%         mkdir(fPath);
%     end
%     
%     fPath = '_time_series_plots/';
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else
%         mkdir(fPath);
%     end

    fPath = '_time_series_drag_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else
        mkdir(fPath);
    end    
    
%     %# Have directory
%     fPath = sprintf('_plots/%s', '_heave');
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else    
%         mkdir(fPath);
%     end
% 
%     %# Averaged directory
%     fPath = sprintf('_plots/%s', '_averaged');
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else    
%         mkdir(fPath);
%     end    
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % ///////////////////////////////////////////////////////////////////// 
    
    
    % /////////////////////////////////////////////////////////////////////
    %# START: Columns as variables (RAW DATA)
    %# --------------------------------------------------------------------
    
    timeData            = data(:,1);   % Timeline
    Raw_CH_0_Speed      = data(:,2);   % Speed             RU: m/s
    Raw_CH_1_LVDTFwd    = data(:,3);   % LVDT: Forward     RU: mm
    Raw_CH_2_LVDTAft    = data(:,4);   % LVDT: Aft         RU: mm
    Raw_CH_3_Drag       = data(:,5);   % Drag              RU: Grams (g)
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);   % Time: Zero
    Time_CF    = ZeroAndCalib(2);   % Time: Calibration factor
    CH_0_Zero  = ZeroAndCalib(3);   % Spped: Zero
    CH_0_CF    = ZeroAndCalib(4);   % Speed: Calibration factor
    CH_1_Zero  = ZeroAndCalib(5);   % Fwd LVDT: Zero
    CH_1_CF    = ZeroAndCalib(6);   % Fwd LVDT: Calibration factor
    CH_2_Zero  = ZeroAndCalib(7);   % Aft LVDT: Zero
    CH_2_CF    = ZeroAndCalib(8);   % Aft LVDT: Calibration factor
    CH_3_Zero  = ZeroAndCalib(9);   % Drag: Zero
    CH_3_CF    = ZeroAndCalib(10);  % Drag: Calibration factor
    
    %# --------------------------------------------------------------------
    %# END: Columns as variables (RAW DATA)
    % /////////////////////////////////////////////////////////////////////
    
    
    % /////////////////////////////////////////////////////////////////////
    % START: REAL UNITS COVNERSION
    % ---------------------------------------------------------------------    
    
    % Real units (i.e. m/s, mm and grams)
    [CH_0_Speed CH_0_Speed_Mean]     = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean] = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean] = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]       = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);    
    
    % Leave it as voltage but subtract zero value     
    %[CH_0_Speed_Volt CH_0_Speed_Mean_Volt]     = analysis_voltage(Raw_CH_0_Speed,CH_0_Zero);
    %[CH_1_LVDTFwd_Volt CH_1_LVDTFwd_Mean_Volt] = analysis_voltage(Raw_CH_1_LVDTFwd,CH_1_Zero);
    %[CH_2_LVDTAft_Volt CH_2_LVDTAft_Mean_Volt] = analysis_voltage(Raw_CH_2_LVDTAft,CH_2_Zero);
    %[CH_3_Drag_Volt CH_3_Drag_Mean_Volt]       = analysis_voltage(Raw_CH_3_Drag,CH_3_Zero);

    % /////////////////////////////////////////////////////////////////////
    % END: REAL UNITS COVNERSION
    % ---------------------------------------------------------------------        
    
    %# Results array columns: 
    %[1]  Run No.                                                                  (-)
    %[2]  FS                                                                       (Hz)
    %[3]  No. of samples                                                           (-)
    %[4]  Record time                                                              (s)
    %[5]  Model Averaged speed                                                     (m/s)
    %[6]  Model Averaged fwd LVDT                                                  (m)
    %[7]  Model Averaged aft LVDT                                                  (m)
    %[8]  Model Averaged drag                                                      (g)
    %[9]  Model (Rtm) Total resistance                                             (N)
    %[10] Model (Ctm) Total resistance Coefficient                                 (-)
    %[11] Model Froude length number                                               (-)
    %[12] Model Heave                                                              (mm)
    %[13] Model Trim                                                               (Degrees)
    %[14] Equivalent full scale speed                                              (m/s)
    %[15] Equivalent full scale speed                                              (knots)
    
    % ---------------------------------------------------------------------
    % Additional values added: 10/09/2013
    % ---------------------------------------------------------------------        
    %[16] Model (Rem) Reynolds Number                                              (-)
    %[17] Model (Cfm) Frictional Resistance Coefficient (ITTC'57)                  (-)
    %[18] Model (Cfm) Frictional Resistance Coefficient (Grigson)                  (-)
    %[19] Model (Crm) Residual Resistance Coefficient                              (-)
    %[20] Model (PEm) Model Effective Power                                        (W)
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    %[23] Full Scale (Cfs) Frictional Resistance Coefficient (ITTC'57)             (-)
    %[24] Full Scale (Cts) Total resistance Coefficient                            (-)
    %[25] Full Scale (Rts) Total resistance (Rt)                                   (N)
    %[26] Full Scale (PEs) Model Effective Power                                   (W)
    %[27] Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    %[28] Run condition                                                            (-)
    
    % ---------------------------------------------------------------------
    % Additional values added: 12/09/2013
    % ---------------------------------------------------------------------
    %[29] SPEED: Minimum value                                                      (m/s)
    %[30] SPEED: Maximum value                                                      (m/s)
    %[31] SPEED: Average value                                                      (m/s)
    %[32] SPEED: Percentage (max.-avg.) to max. value (exp. 3%)                     (m/s)
    %[33] LVDT (FWD): Minimum value                                                 (mm)
    %[34] LVDT (FWD): Maximum value                                                 (mm)
    %[35] LVDT (FWD): Average value                                                 (mm)
    %[36] LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%)                (mm)
    %[37] LVDT (AFT): Minimum value                                                 (mm)
    %[38] LVDT (AFT): Maximum value                                                 (mm)
    %[39] LVDT (AFT): Average value                                                 (mm)
    %[40] LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%)                (mm)
    %[41] DRAG: Minimum value                                                       (g)
    %[42] DRAG: Maximum value                                                       (g)
    %[43] DRAG: Average value                                                       (g)
    %[44] DRAG: Percentage (max.-avg.) to max. value (exp. 3%)                      (g)
    
    % ---------------------------------------------------------------------
    % Additional values added: 18/09/2013
    % ---------------------------------------------------------------------
    %[45] SPEED: Standard deviation                                                 (m/s)
    %[46] LVDT (FWD): Standard deviation                                            (mm)
    %[47] LVDT (AFT): Standard deviation                                            (mm)
    %[48] DRAG: Standard deviation                                                  (g)

    % Write data to array -------------------------------------------------
    resultsArray(k, 1)  = k;                                                        % Run No.
    resultsArray(k, 2)  = round(length(timeData) / timeData(end));                  % FS (Hz)    
    resultsArray(k, 3)  = length(timeData);                                         % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArray(k, 4)  = round(recordTime);                                        % Record time in seconds
    resultsArray(k, 5)  = CH_0_Speed_Mean;                                          % Model Averaged speed (m/s)
    resultsArray(k, 6)  = CH_1_LVDTFwd_Mean;                                        % Model Averaged forward LVDT (mm)
    resultsArray(k, 7)  = CH_2_LVDTAft_Mean;                                        % Model Averaged aft LVDT (mm)
    resultsArray(k, 8)  = CH_3_Drag_Mean;                                           % Model Averaged drag (g)
    resultsArray(k, 9)  = (resultsArray(k, 8) / 1000) * gravconst;                  % Model Averaged drag (Rtm) (N)
    resultsArray(k, 10) = resultsArray(k, 9) / (0.5*freshwaterdensity*MSwsa*resultsArray(k, 5)^2); % Model Averaged drag (Ctm) (-)
        
    roundedspeed   = str2num(sprintf('%.2f',resultsArray(k, 5)));                   % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl))); % Calculate Froude length number
    resultsArray(k, 11) = modelfrrounded;                                           % Froude length number (adjusted for Lwl change at different conditions) (-)
    
    resultsArray(k, 12) = (resultsArray(k, 6)+resultsArray(k, 7))/2;                % Model Heave (mm)
    resultsArray(k, 13) = atand((resultsArray(k, 6)-resultsArray(k, 7))/distbetwposts); % Model Trim (Degrees)
    resultsArray(k, 14) = resultsArray(k, 5) * sqrt(FStoMSratio);                   % Full scale speed (m/s)
    resultsArray(k, 15) = resultsArray(k, 14) / 0.5144;                             % Full scale speed (knots)
    resultsArray(k, 16) = (resultsArray(k, 5)*MSlwl)/modelkinviscosity;             % Model Reynolds Number (-)
    resultsArray(k, 17) = 0.075/(log10(resultsArray(k, 16))-2)^2;                   % Model Frictional Resistance Coefficient (ITTC'57) (-)
    if resultsArray(k, 16) < 10000000
        resultsArray(k, 18) = 10^(2.98651-10.8843*(log10(log10(resultsArray(k, 16))))+5.15283*(log10(log10(resultsArray(k, 16))))^2); % Model Frictional Resistance Coefficient (Grigson) (-)   
    else
        resultsArray(k, 18) = 10^(-9.57459+26.6084*(log10(log10(resultsArray(k, 16))))-30.8285*(log10(log10(resultsArray(k, 16))))^2+10.8914*(log10(log10(resultsArray(k, 16))))^3); % Model Frictional Resistance Coefficient (Grigson) (-)           
    end
    resultsArray(k, 19) = resultsArray(k, 10)-resultsArray(k, 17);           % Model (Crm) Residual Resistance Coefficient (-)
    resultsArray(k, 20) = resultsArray(k, 5)*resultsArray(k, 9);             % Model (PEm) Model Effective Power                                   (W)
    resultsArray(k, 21) = resultsArray(k, 20)/0.5;                           % Model (PBm) Model Brake Power (using 50% prop. efficiency estimate) (W)
    resultsArray(k, 22) = (resultsArray(k, 14)*FSlwl)/fullscalekinvi;        % Full Scale (Res) Reynolds Number (-)
    resultsArray(k, 23) = 0.075/(log10(resultsArray(k, 22))-2)^2;            % Full Scale (Cfs) Frictional Resistance Coefficient (ITTC'57) (-)
    resultsArray(k, 24) = resultsArray(k, 19)+resultsArray(k, 23);           % Full Scale (Cts) Total resistance Coefficient (-)
    resultsArray(k, 25) = 0.5*saltwaterdensity*(resultsArray(k, 14)^2)*FSwsa*resultsArray(k, 24); % Full Scale (Rts) Total resistance (Rt) (N)
    resultsArray(k, 26) = resultsArray(k, 14)*resultsArray(k, 25);           % Full Scale (PEs) Model Effective Power (W)
    resultsArray(k, 27) = resultsArray(k, 26)/0.5;                           % Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    resultsArray(k, 28) = 1;                                                 % Run condition (-)

    sdata               = CH_0_Speed(startSamplePos:end-cutSamplesFromEnd);
    tfwddata            = CH_1_LVDTFwd(startSamplePos:end-cutSamplesFromEnd);
    taftdata            = CH_2_LVDTAft(startSamplePos:end-cutSamplesFromEnd);
    ddata               = CH_3_Drag(startSamplePos:end-cutSamplesFromEnd);
    
    resultsArray(k, 29) = min(sdata);                                           % SPEED: Minimum value (m/s)
    resultsArray(k, 30) = max(sdata);                                           % SPEED: Maximum value (m/s)
    resultsArray(k, 31) = mean(sdata);                                          % SPEED: Average value (m/s)
    resultsArray(k, 32) = (max(sdata) - mean(sdata)) / max(sdata);              % SPEED: Percentage (max.-avg.) to max. value (exp. 3% (m/s)
    resultsArray(k, 33) = min(tfwddata);                                        % LVDT (FWD): Minimum value (mm)
    resultsArray(k, 34) = max(tfwddata);                                        % LVDT (FWD): Maximum value (mm)
    resultsArray(k, 35) = mean(tfwddata);                                       % LVDT (FWD): Average value (mm)
    resultsArray(k, 36) = abs(max(tfwddata) - mean(tfwddata)) / abs(max(tfwddata)-min(tfwddata));     % LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%) (mm)
    resultsArray(k, 37) = min(taftdata);                                        % LVDT (AFT): Minimum vaue (mm)
    resultsArray(k, 38) = max(taftdata);                                        % LVDT (AFT): Maximum value (mm)
    resultsArray(k, 39) = mean(taftdata);                                       % LVDT (AFT): Average value (mm)
    resultsArray(k, 40) = abs(max(taftdata) - mean(taftdata)) / abs(max(taftdata)-min(taftdata));     % LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%) (mm)
    resultsArray(k, 41) = min(ddata);                                           % DRAG: Minimum value (g)
    resultsArray(k, 42) = max(ddata);                                           % DRAG: Maximum value (g)
    resultsArray(k, 43) = mean(ddata);                                          % DRAG: Average value (g)
    resultsArray(k, 44) = (max(ddata) - mean(ddata)) / max(ddata);              % DRAG: Percentage (max.-avg.) to max. value (exp. 3%) (g)
    % ---------------------------------------------------------------------
    % Additional values added: 18/09/2013
    % --------------------------------------------------------------------- 
    resultsArray(k, 45) = std(sdata);                                           % SPEED: Standard deviation (-)
    resultsArray(k, 46) = std(tfwddata);                                        % LVDT (FWD): Standard deviation (-)
    resultsArray(k, 47) = std(taftdata);                                        % LVDT (AFT): Standard deviation (-)
    resultsArray(k, 48) = std(ddata);                                           % DRAG: Standard deviation (-)

    %# Prepare strings for display ----------------------------------------
    if k > 99
       name = name(2:5);
    else
       name = name(2:4);
    end    
    avgspeed          = sprintf('%s:: Model Averaged speed: %s [m/s]', name, sprintf('%.2f',resultsArray(k, 5)));
    avglvdtfdw        = sprintf('%s:: Model Averaged fwd LVDT: %s [mm]', name, sprintf('%.2f',resultsArray(k, 6)));
    avglvdtaft        = sprintf('%s:: Model Averaged aft LVDT: %s [mm]', name, sprintf('%.2f',resultsArray(k, 7)));
    avgdrag           = sprintf('%s:: Model Averaged drag: %s [g]', name, sprintf('%.2f',resultsArray(k, 8)));
    avgdragrt         = sprintf('%s:: Model Total resistance (Rtm): %s [N]', name, sprintf('%.2f',resultsArray(k, 9)));
    avgdragct         = sprintf('%s:: Model Total resistance coefficient (Ctm): %s [-]', name, sprintf('%.5f',resultsArray(k, 10)));
    froudlengthnumber = sprintf('%s:: Froude length number (Fr): %s [-]', name, sprintf('%.2f',resultsArray(k, 11)));
    heave             = sprintf('%s:: Model Heave: %s [mm]', name, sprintf('%.2f',resultsArray(k, 12)));
    trim              = sprintf('%s:: Model Trim: %s [Degrees]', name, sprintf('%.2f',resultsArray(k, 13)));
    % ---------------------------------------------------------------------
    % Additional values added: 10/09/2013
    % ---------------------------------------------------------------------  
    modelreynoldsno   = sprintf('%s:: Model Reynolds Number (Rem): %s [-]', name, sprintf('%.0f',resultsArray(k, 16)));
    modelcfmittc57    = sprintf('%s:: Model Frictional Resistance Coeff. (Cfm using ITTC 1957): %s [-]', name, sprintf('%.5f',resultsArray(k, 17)));
    modelcfmgrigson   = sprintf('%s:: Model Frictional Resistance Coeff. (Cfm using Grigson): %s [-]', name, sprintf('%.5f',resultsArray(k, 18)));
    modelcrm          = sprintf('%s:: Model Residual Resistance Coeff. (Crm): %s [-]', name, sprintf('%.5f',resultsArray(k, 19)));
    modeleffpower     = sprintf('%s:: Model Effective Power (PEm): %s [W]', name, sprintf('%.2f',resultsArray(k, 20)));
    modelbrakepower   = sprintf('%s:: Model Brake Power (PBm at an estimated 50 percent prop. efficiency): %s [W]', name, sprintf('%.2f',resultsArray(k, 21)));
    FSspeedms         = sprintf('%s:: Full Scale speed: %s [m/s]', name, sprintf('%.2f',resultsArray(k, 14)));
    FSspeedkts        = sprintf('%s:: Full Scale speed: %s [knots]', name, sprintf('%.2f',resultsArray(k, 15)));
    FSreynoldsno      = sprintf('%s:: Full Scale Reynolds Number (Res): %s [-]', name, sprintf('%.0f',resultsArray(k, 22)));
    FSCfsittc57       = sprintf('%s:: Full Scale Frictional Resistance Coeff. (Cfs using ITTC 1957): %s [-]', name, sprintf('%.5f',resultsArray(k, 23)));
    FSCts             = sprintf('%s:: Full Scale Total resistance coefficient (Cts): %s [-]', name, sprintf('%.5f',resultsArray(k, 24)));
    FSRts             = sprintf('%s:: Full Scale Total resistance (Rts): %s [N] / %s [kN]', name, sprintf('%.0f',resultsArray(k, 25)), sprintf('%.0f',resultsArray(k, 25)/1000));
    FSPEs             = sprintf('%s:: Full Scale Effective Power (PEs): %s [W] / %s [kW] / %s [mW]', name, sprintf('%.0f',resultsArray(k, 26)), sprintf('%.0f',resultsArray(k, 26)/1000), sprintf('%.2f',resultsArray(k, 26)/1000000));
    FSPBs             = sprintf('%s:: Full Scale Brake Power (PBs at an estimated 50 percent prop. efficiency): %s [W] / %s [kW] / %s [mW]', name, sprintf('%.0f',resultsArray(k, 27)), sprintf('%.0f',resultsArray(k, 27)/1000), sprintf('%.2f',resultsArray(k, 27)/1000000));
    
%     %# Display strings ----------------------------------------------------
%     disp('>>> MODEL SCALE');
%     disp(avgspeed);
%     disp(avglvdtfdw);
%     disp(avglvdtaft);
%     disp(avgdrag);
%     disp(avgdragrt);
%     disp(avgdragct);
%     disp(froudlengthnumber);
%     disp(heave);
%     disp(trim);
%     % ---------------------------------------------------------------------
%     % Additional values added: 10/09/2013
%     % ---------------------------------------------------------------------   
%     disp(modelreynoldsno);
%     disp(modelcfmittc57);
%     disp(modelcfmgrigson);
%     disp(modelcrm);
%     disp(modeleffpower);
%     disp(modelbrakepower);
%     disp('>>> FULL SCALE'); 
%     disp(FSspeedms);
%     disp(FSspeedkts);
%     disp(FSreynoldsno);
%     disp(FSCfsittc57);
%     disp(FSCts);
%     disp(FSRts);
%     disp(FSPEs);
%     disp(FSPBs);    
%     disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');   


    %# Plot FFT -------------------------------------------------------

    %# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    %# PLOT: FFT
    %# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    
    minRunNo = startRun;
    maxRunNo = endRun;
    FroudeNo = resultsArray(k, 11);
    RunCond  = 1;
    
    figurename = sprintf('FTV Bluefin (CWR test data 2014): Condition %s:: Run %s, Fr=%s, %s', num2str(RunCond), num2str(k), num2str(FroudeNo), 'FFT');
    fig = figure('Name',figurename,'NumberTitle','off');
    
    x = timeData;
    y = Raw_CH_3_Drag;
    %y = CH_3_Drag;
    
    [m,n] = size(y);
    
    % Create a matrix of mean values by replicating the mu vector for n rows
    MeanMat = repmat(mean(y),m,1);    
    
    % Subtract mean
    y1 = detrend(y,'constant');
    y2 = y - MeanMat;
    
    % Time series: drag ---------------------------------------------------    
    
    subplot(3,1,1);
    
    plot(x,y,'b-',x,y1,'r--',x,y2,'g-.'); % ,'MarkerSize',2
    set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
    title('{\bf Time series: drag}')
    xlabel('Time (s)')
    ylabel('Raw drag (V)')
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX = min(x);
    maxX = max(x);
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:2:maxX);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    

    % Legend
    hleg1 = legend(sprintf('Run %s',num2str(k)),'Subtracted mean (detrend)','Subtracted mean (y-mean)');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    %legend boxoff;
    
    % FFT -----------------------------------------------------------------    
    
    subplot(3,1,2);
    
    y = y1;    
    
    Fs = 200;               % Sampling frequency
    T = 1/Fs;               % Sample time
    L = length(x);          % Length of signal
    t = (0:L-1)*T;          % Time vector

    % Plot single-sided amplitude spectrum.

    NFFT = 2^nextpow2(L);   % Next power of 2 from length of y
    Y    = fft(y,NFFT)/L;
    f    = Fs/2*linspace(0,1,NFFT/2+1);
    
    % Identify peaks
    [maxtabstbd, mintabstbd] = peakdet(2*abs(Y(1:NFFT/2+1)), 0.03, f);
    [m,n] = size(maxtabstbd);
    
    % Remove zero x entries
    maxtabstbdnew = [];
    counter = 1;
    for l=1:m
        if maxtabstbd(l,1) ~= 0
            maxtabstbdnew(counter,1) = maxtabstbd(l,1);
            maxtabstbdnew(counter,2) = maxtabstbd(l,2);
            counter = counter + 1;
        end
    end
    
    % Array sizes
    [mm,nm] = size(maxtabstbdnew);    
    [mn,nn] = size(freqArray);

    % Add found frequencies to freqArray
    % Columns:
    %   [1] Run number              (-)
    %   [2] Froude length number    (-)
    %   [3] Frequency               (Hz)
    for kk=1:mm
       freqArray(mn+kk,:) = [k FroudeNo maxtabstbdnew(kk,2)];
    end 
    
    plot(f,2*abs(Y(1:NFFT/2+1)),'Color','b','Marker','x','MarkerSize',1,'LineStyle','-','linewidth',1);
    % Only show peaks when available
    if mm ~= 0
        hold on;
        plot(maxtabstbdnew(:,1),maxtabstbdnew(:,2),'ro');
    end
    set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
    title('{\bf Single-Sided Amplitude Spectrum of y(t)}')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    grid on;
    box on;
    %axis square;

    % Periodogram ---------------------------------------------------------
    
    subplot(3,1,3);
    
    y = y1;
    
    % Maximum frequency
    % See: http://www.mathworks.com.au/matlabcentral/answers/28239-get-frequencies-out-of-data-with-an-fft
    psdest = psd(spectrum.periodogram,y,'Fs',Fs,'NFFT',length(y));
    [~,I] = max(psdest.Data);
    h1 = plot(psdest);
    set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
    title('{\bf Averaged samples: Periodogram Power Spectral Density Estimate}')
    set(h1,'Color','b');
    
    % Write data to array -----------------------------------------
    
    %# frequencyArray columns:
    
    %[1]  Run No.                                              (-)
    %[2]  Length Froude Number                                 (-)
    %[3]  Condition                                            (-)
    %[4]  Max. frequency                                       (Hz)
    
    % The two highest frequencies:
    %[5]  Frequency #1                                         (Hz)
    %[6]  Frequency #2                                         (Hz)
    
    frequencyArray(k, 1) = k;
    frequencyArray(k, 2) = FroudeNo;
    frequencyArray(k, 3) = RunCond;
    frequencyArray(k, 4) = psdest.Frequencies(I);
    
    %# Save plot as PNG -------------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    
    %# Plot title -------------------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintf('%s/Cond_%s_Run_%s_Fr_%s_Time_Series_Drag_Plots_FFT.pdf', '_time_series_drag_plots', num2str(RunCond), num2str(k), num2str(FroudeNo));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('%s/Cond_%s_Run_%s_Fr_%s_Time_Series_Drag_Plots_FFT.png', '_time_series_drag_plots', num2str(RunCond), num2str(k), num2str(FroudeNo));
    saveas(fig, plotsavename);                % Save plot as PNG
    close;
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end
%# Close progress bar
%close(w);

%# ------------------------------------------------------------------------
%# Plot heave trim and drag
%# ------------------------------------------------------------------------

% Remove Zero rows from array
resultsArray(all(resultsArray==0,2),:) = [];

minRunNo = startRun;
maxRunNo = endRun;
RunCond  = 1;

figurename = sprintf('FTV Bluefin (CWR test data 2014): Condition %s:: Run %s to %s, %s', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), 'Time Series Data');
fig = figure('Name',figurename,'NumberTitle','off');

%# HEAVE ------------------------------------------------------------------
subplot(1,3,1)

plot(resultsArray(:,15),resultsArray(:,12),'x','MarkerSize',9);
set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
xlabel('Ship speed [knots]');
ylabel('Heave [mm]');
title('{\bf Heave}');
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# TRIM -------------------------------------------------------------------
subplot(1,3,2)

plot(resultsArray(:,15),resultsArray(:,13),'x','MarkerSize',9);
set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
xlabel('Ship speed [knots]');
ylabel('Trim [degrees]');
title('{\bf Trim}');
grid on;
box on;
axis square;

%# DRAG -------------------------------------------------------------------
subplot(1,3,3)

plot(resultsArray(:,15),resultsArray(:,8),'x','MarkerSize',9);
set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
xlabel('Ship speed [knots]');
ylabel('Drag [g]');
title('{\bf Drag}');
grid on;
box on;
axis square;

%# Save plot as PNG -------------------------------------------------------

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# Plot title -------------------------------------------------------------
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

%# Save plots as PDF and PNG
%plotsavenamePDF = sprintf('%s/Cond_%s_Run_%s_to_Run_%s_Heave_Trim_Drag_Plot.pdf', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo));
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('%s/Cond_%s_Run_%s_to_Run_%s_Heave_Trim_Drag_Plot.png', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo));
saveas(fig, plotsavename);                % Save plot as PNG
close;


%# ------------------------------------------------------------------------
%# Plot summary of identified frequencies (FFT)
%# ------------------------------------------------------------------------

figurename = sprintf('FTV Bluefin (CWR test data 2014): Condition %s:: Run %s to %s, %s', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), 'FFT Frequencies');
fig = figure('Name',figurename,'NumberTitle','off');

% Split array by Froude length number
sortedArray = arrayfun(@(x) freqArray(freqArray(:,2) == x, :), unique(freqArray(:,2)), 'uniformoutput', false);
[ml,nl] = size(sortedArray);

maxfreqArray = [];
for k=1:ml
    % Shorten variable name for convenience
    SA = sortedArray;
    
    % Findex index at max value (i.e. Frequency)
    [C,I] = max(SA{k}(:,3));
    
    % Write values to new array
    maxfreqArray(k,:) = [SA{k}(I,1) SA{k}(I,2) SA{k}(I,3)];
end

% All indentified frequencies
x = freqArray(:,2);
y = freqArray(:,3);

% Maximum indentified frequency only
xm = maxfreqArray(:,2);
ym = maxfreqArray(:,3);

% Plotting
% plot(xm,ym,'ro','MarkerSize',10); % ,'LineStyle','-.','linewidth',1
% hold on;
plot(x,y,'bx','MarkerSize',9);
set(gca,'FontSize',10,'FontWeight','normal','linewidth',2);
xlabel('Froude length number [-]');
ylabel('Frequency by FFT [Hz]');
%title('{\bf Drag}');
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
%minX = min(x)-1;
%maxX = max(x)+1;
minX = 0.1;
maxX = 0.43;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:0.05:maxX);
minY = 0;
maxY = max(ym)+0.05;
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:0.05:maxY);

%# Save plot as PNG -------------------------------------------------------

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# Plot title -------------------------------------------------------------
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

%# Save plots as PDF and PNG
%plotsavenamePDF = sprintf('%s/Cond_%s_FFT_Identified_Frequencies_Plot.pdf', '_time_series_drag_plots', num2str(RunCond));
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('%s/Cond_%s_FFT_Identified_Frequencies_Plot.png', '_time_series_drag_plots', num2str(RunCond));
saveas(fig, plotsavename);                % Save plot as PNG
%close;


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

M = resultsArray;                                           
csvwrite('resultsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('resultsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer    