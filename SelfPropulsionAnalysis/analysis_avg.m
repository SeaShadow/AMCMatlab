%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  June 30, 2014
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
%# CHANGES    :  12/11/2013 - Created new script
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


%# ************************************************************************
%# START: DAQ related settings
%# ------------------------------------------------------------------------

Fs = 800;                               % DAQ sampling frequency = 200Hz

%# ------------------------------------------------------------------------
%# END: DAQ related settings
%# ************************************************************************


% /////////////////////////////////////////////////////////////////////
% START: CREATE PLOTS AND RUN DIRECTORY
% ---------------------------------------------------------------------

%# _PLOTS directory
% fPath = '_plots/';
% if isequal(exist(fPath, 'dir'),7)
%     % Do nothing as directory exists
% else
%     mkdir(fPath);
% end

%# RUN directory
% fPath = sprintf('_plots/%s', name(1:3));
% if isequal(exist(fPath, 'dir'),7)
%     % Do nothing as directory exists
% else
%     mkdir(fPath);
% end

% ---------------------------------------------------------------------
% END: CREATE PLOTS AND RUN DIRECTORY
% /////////////////////////////////////////////////////////////////////


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

% Waterjet constants (FS = full scale and MS = model scale)

% Pump diameter, Dp, (m)
FS_PumpDia = 1.2;
MS_PumpDia = 0.056;

% Effective nozzle diamter, Dn, (m)
FS_EffNozzDia = 0.72;
MS_EffNozzDia = 0.033;

% Nozzle area, An, (m^2)
FS_NozzArea = 0.41;
MS_NozzArea = 0.00087;

% Impeller diameter, Di, (m)
FS_ImpDia = 1.582;
MS_ImpDia = 0.073;

% Pump inlet area, A4, (m^2)
FS_PumpInlArea = 1.99;
MS_PumpInlArea = 0.004;

% Pump maximum area, A5, (m^2)
FS_PumpMaxArea = 0.67;
MS_PumpMaxArea = 0.001;

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
%# ////////////////////////////////////////////////////////////////////////

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


% *************************************************************************
%# RESULTS SPT ARRAY COLUMNS
% *************************************************************************

%# Results SPT array columns:

%[1]  Run No.                               (-)
%[2]  FS                                    (Hz)
%[3]  No. of samples                        (-)
%[4]  Record time                           (s)
%[5]  Speed                                 (m/s)
%[6]  Forward LVDT                          (mm)
%[7]  Aft LVDT                              (mm)
%[8]  Drag                                  (g)
%[9]  Froude length number                  (-)

%[10] Shaft Speed PORT                      (RPM)
%[11] Shaft Speed STBD                      (RPM)
%[12] Thrust PORT                           (N)
%[13] Torque PORT                           (Nm)
%[14] Thrust STBD                           (N)
%[15] Torque STBD                           (Nm)
%[16] Kiel probe PORT                       (V)
%[17] Kiel probe STBD                       (V)
%[18] PORT static pressure ITTC station 6   (mmH20)
%[19] STBD static pressure ITTC station 6   (mmH20)
%[20] STBD static pressure ITTC station 5   (mmH20)
%[21] STBD static pressure ITTC station 4   (mmH20)
%[22] STBD static pressure ITTC station 3   (mmH20)
%[23] PORT static pressure ITTC station 1a  (mmH20)
%[24] STBD static pressure ITTC station 1a  (mmH20)

%# ------------------------------------------------------------------------
%# Read results DAT file
%# ------------------------------------------------------------------------

if exist('full_self_propulsion_data.dat', 'file') == 2
    %# Read results file
    results = csvread('full_self_propulsion_data.dat');
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('WARNING: Data file for self-propulsion data (full_self_propulsion_data) does not exist!');
    %break;
end

%# Stop script if required data unavailble --------------------------------
if exist('results','var') == 0
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required propulsion data file does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end

%# ------------------------------------------------------------------------
%# Split results array depending on Length Froude Number
%# ------------------------------------------------------------------------

% R = results;            % Results array
% R(all(R==0,2),:) = [];  % Remove Zero rows from array
% [m,n] = size(R);        % Array dimensions
%
% % Split results array based on column 28 (test condition)
% A = arrayfun(@(x) R(R(:,9) == x, :), unique(R(:,9)), 'uniformoutput', false);
% [ma,na] = size(A);      % Array dimensions


%# ------------------------------------------------------------------------
%# Repeat runs
%# ------------------------------------------------------------------------

SPTSpeed1 = 125:127;
SPTSpeed2 = 129:131;
SPTSpeed3 = 133:136;
SPTSpeed4 = 138:140;
SPTSpeed5 = 142:144;
SPTSpeed6 = 146:148;
SPTSpeed7 = 150:152;
SPTSpeed8 = 154:156;
SPTSpeed9 = 158:160;


%# ------------------------------------------------------------------------
%# Run/loop through runs
%# ------------------------------------------------------------------------
[m,n] = size(results);        % Array dimensions

% Speed arrays ------------------------------------------------------------
SPTSpeedArray = [];

% Loop combine repeats of the same speed ----------------------------------
for k=1:m
    
    [ms,ns] = size(SPTSpeedArray);
    x = 1; if ms > 0; x = ms+1; end;
    
    runno = results(k, 1);
    if any(SPTSpeed1==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed2==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed3==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed4==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed5==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed6==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed7==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed8==runno)
        SPTSpeedArray(x,:) = results(k,:);
    elseif any(SPTSpeed9==runno)
        SPTSpeedArray(x,:) = results(k,:);
    end
    
end

% Take averages -----------------------------------------------------------

R = SPTSpeedArray;      % Results array
R(all(R==0,2),:) = [];  % Remove Zero rows from array
[m,n] = size(R);        % Array dimensions

% Split results array based on column 9 (Length Froude Number)
A = arrayfun(@(x) R(R(:,9) == x, :), unique(R(:,9)), 'uniformoutput', false);
[ma,na] = size(A);      % Array dimensions

% Excempted columns
exmpCols = 1:4;

avgResultsArray = [];
% Loop through speeds
for j=1:ma
    
    % Loop through columns
    for l=1:n
        if any(exmpCols==l)
            avgResultsArray(j, l) = 0;
        else
            avgResultsArray(j, l) = mean(A{j}(:,l));
        end
    end
    
end

% Adjust averaged results array -------------------------------------------

R = avgResultsArray;    % Results array
[m,n] = size(R);        % Array dimensions

% Remove useless columns (Fr, FS, sample no., record time)

% Excempted columns
exmpCols = 1:4;

B = [];
for k=1:m
    
    for l=1:n
        if any(exmpCols==l)
            % Do nothing
        else
            B(k, l-4) = R(k, l);
        end
    end
    
end

%# New/adjusted results array columns:

%[1]  Speed                                 (m/s)
%[2]  Forward LVDT                          (mm)
%[3]  Aft LVDT                              (mm)
%[4]  Drag                                  (g)
%[5]  Froude length number                  (-)

%[6]  PORT Shaft Speed                      (RPM)
%[7]  STBD Shaft Speed                      (RPM)
%[8]  PORT Thrust                           (N)
%[9]  PORT Torque                           (Nm)
%[10] STBD Thrust                           (N)
%[11] STBD Torque                           (Nm)
%[12] PORT Kiel probe                       (V)
%[13] STBD Kiel probe                       (V)
%[14] PORT static pressure ITTC station 6   (mmH20)
%[15] STBD static pressure ITTC station 6   (mmH20)
%[16] STBD static pressure ITTC station 5   (mmH20)
%[17] STBD static pressure ITTC station 4   (mmH20)
%[18] STBD static pressure ITTC station 3   (mmH20)
%[19] PORT static pressure ITTC station 1a  (mmH20)
%[20] STBD static pressure ITTC station 1a  (mmH20)

%[21] Heave                                 (mm)
%[22] Trim                                  (degrees)

%[23] PORT mass flow rate                   (Kg/s)
%[24] STBD mass flow rate                   (Kg/s)
%[25] PORT volume flow rate                 (m^3/s)
%[26] STBD volume flow rate                 (m^3/s)
%[27] PORT jet velocity                     (m/s)
%[28] STBD jet velocity                     (m/s)

%[29] Bare hull resistance (resistance test)(N)

%[30] PORT Shaft Speed                      (RPS)
%[31] STBD Shaft Speed                      (RPS)

%[32] Full scale speed                      (m/s)
%[33] Full scale speed                      (knots)

% Add calculated values to array ------------------------------------------

R = B;                  % Results array
[m,n] = size(R);        % Array dimensions

for k=1:m
    % Heave and trim
    R(k, 21) = (R(k, 2)+R(k, 3))/2;                      % Model Heave (mm)
    R(k, 22) = atand((R(k, 2)-R(k, 3))/distbetwposts);   % Model Trim (Degrees)
    
    % Short variables for PORT and STBD kiel probe output *****************
    PKP = R(k, 12);
    SKP = R(k, 13);
    
    % Mass flow rate based on best fit
    if PKP > 1.86
        PORTMfr = 0.1133*PKP^3-1.0326*PKP^2+4.3652*PKP-2.6737;
    else
        PORTMfr = 0.4186*PKP^5-4.5094*PKP^4+19.255*PKP^3-41.064*PKP^2+45.647*PKP-19.488;
    end
    if SKP > 1.86
        STBDMfr = 0.1133*SKP^3-1.0326*SKP^2+4.3652*SKP-2.6737;
    else
        STBDMfr = 0.4186*SKP^5-4.5094*SKP^4+19.255*SKP^3-41.064*SKP^2+45.647*SKP-19.488;
    end
    
    R(k, 23) = PORTMfr;                                 % PORT mass flow rate (Kg/s)
    R(k, 24) = STBDMfr;                                 % STBD mass flow rate (Kg/s)
    R(k, 25) = PORTMfr/freshwaterdensity;               % PORT volume flow rate (m^3/s)
    R(k, 26) = STBDMfr/freshwaterdensity;               % STBD volume flow rate (m^3/s)
    R(k, 27) = R(k, 25)/MS_NozzArea;                    % PORT jet velocity (m/s)
    R(k, 28) = R(k, 26)/MS_NozzArea;                    % STBD jet velocity (m/s)
    
    % Bare hull resistance base on best fit *******************************
    LFR = R(k, 5);
    RCW = -7932.12*LFR^5+13710.12*LFR^4-9049.96*LFR^3+2989.46*LFR^2-386.61*LFR+18.6;
    
    R(k, 29) = RCW;
    
    % Shaft speed (RPS) ***************************************************
    
    R(k, 30) = R(k, 6)/60;
    R(k, 31) = R(k, 7)/60;
    
    % Full scale speed ****************************************************
    
    R(k, 32) = R(k, 1)*sqrt(FStoMSratio);
    R(k, 33) = R(k, 32)/0.514444;
    
end

% NOTE: Array R at this point contains the averaged data for further
% processing!!!


%# ------------------------------------------------------------------------
%# Clear variables
%# ------------------------------------------------------------------------
clearvars allPlots
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
clearvars SPTSpeed1 SPTSpeed2 SPTSpeed3 SPTSpeed4 SPTSpeed5 SPTSpeed6 SPTSpeed7 SPTSpeed8 SPTSpeed9
