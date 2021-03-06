%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Mass flow rate vs. Kiel Probe Output
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Z�rcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  June 17, 2015
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Kiel probe (V) plotted against flow rate
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  09/09/2014 - File creation
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

% Plot titles, colours, etc.
enablePlotMainTitle     = 0;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot   = 0;    % Show plots scale to A4 size

% Special plot switches
enableTextOnPlot        = 0;    % Show equation of fit text on plot
enableAvgPortStbdPlot   = 0;    % Show averaged port and stbd curve

% Show curve fitting
enableCurveFittingPlot  = 1;    % Show curve fitting

% Show error plots based on standard deviation
enableErrorBarPlot      = 0;    % Show error bars based on standard deviations

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox2'));
[mtb,ntb] = size(ind);

% IF ntb > 0 Curve Fitting Toolbox is installed
enableCurveFittingToolboxCurvePlot = 0;    % Show fit curves when using Curve Fitting Toolbox
if ntb > 0
    enableCurveFittingToolboxPlot  = 1;
    enableEqnOfFitPlot             = 0;
else
    enableCurveFittingToolboxPlot  = 0;
    enableEqnOfFitPlot             = 1;
end

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
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (width & height)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (width & height)
%# ------------------------------------------------------------------------
%# END Define plot size
%# ************************************************************************


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

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


%# ************************************************************************
%# START Read results DAT file
%# ------------------------------------------------------------------------
if exist('resultsArray_copy.dat', 'file') == 2
    %# Results columns:
    %[1]  Run No.
    %[2]  FS                                                        (Hz)
    %[3]  No. of samples                                            (-)
    %[4]  Record time                                               (s)
    %[5]  Flow rate                                                 (Kg/s)
    %[6]  Kiel probe STBD                                           (V)
    %[7]  Kiel probe PORT                                           (V)
    %[8]  Thrust STBD                                               (N)
    %[9]  Thrust PORT                                               (N)
    %[10] Torque STBD                                               (Nm)
    %[11] Torque PORT                                               (Nm)
    %[12] Shaft Speed STBD                                          (RPM)
    %[13] Shaft Speed PORT                                          (RPM)
    %[14] Power STBD                                                (W)
    %[15] Power PORT                                                (W)
    %# Added columns: 18/8/2014
    %[16] Mass flow rate (1s only)                                  (Kg/s)
    %[17] Mass flow rate (mean, 1s intervals)                       (Kg/s)
    %[18] Mass flow rate (overall, Q/t)                             (Kg/s)
    %[19] Diff. Mass flow rate (mean, 1s intervals)/(overall, Q/t)  (%)
    %[20] Mass flow rate (CROSS-CHECK)                              (Kg/s)
    results = csvread('resultsArray_copy.dat');
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('-----------------------------------------------------------------');
    disp('File resultsArray_copy.dat does not exist!');
    disp('-----------------------------------------------------------------');
    break;
end
%# ------------------------------------------------------------------------
%# START Read results DAT file
%# ************************************************************************


%# ************************************************************************
%# START Create directories if not available
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# _kp_vs_mass_flow_rate directory ----------------------------------------
setDirName = '_plots/_kp_vs_mass_flow_rate';

%# Repeat directory
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

%# ------------------------------------------------------------------------
%# END Create directories if not available
%# ************************************************************************


%# ************************************************************************
%# 0. Set run numbers based on conditions
%# ************************************************************************

%# Array size -------------------------------------------------------------

[m,n] = size(results);

% Brake script if resultsArray not complete
if m ~= 67
    disp('-----------------------------------------------------------------');
    disp('Data in resultsArray_copy.dat not complete (i.e. 67 datasets)!');
    disp('-----------------------------------------------------------------');
    break;
end


%# ************************************************************************
%# START Distinguish between PORT and STBD
%# ------------------------------------------------------------------------
testRuns = 1:7;
portRuns = 8:37;
stbdRuns = 38:67;
%# ------------------------------------------------------------------------
%# END Distinguish between PORT and STBD
%# ************************************************************************


%# Shaft speeds and repeats -----------------------------------------------

%# Flow rate measurement test (June 2013) results for comparison
if exist('June2013FRMT.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('June2013FRMT.mat');
    
    % Split data into Port/Stbd and combined arrays
    June13Port = June2013FRMT(1:11,:);
    June13Stbd = June2013FRMT(12:22,:);
    June13Comb = June2013FRMT(23:33,:);
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file (June2013FRMT.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end


%# ************************************************************************
%# 1. Averaging PORT and STBD repeated runs
%# ************************************************************************

%# AvgPortArray and AvgStbdArray columns:
%[1]  Set shaft speed                       (RPM)
%[2]  Prop. system                          (1 = Port, 2 = Stbd)
%[3]  Measured shaft Speed STBD             (RPM)
%[4]  Measured shaft Speed PORT             (RPM)
%[5]  Mass flow rate                        (Kg/s)
%[6]  Kiel probe STBD                       (V)
%[7]  Kiel probe PORT                       (V)
%[8]  Thrust STBD                           (N)
%[9]  Thrust PORT                           (N)
%[10] Torque STBD                           (Nm)
%[11] Torque PORT                           (Nm)
%[12] Volumetric flow rate                  (m3/s)
%[13] Flow coefficient                      (-)
%[14] Jet velocity                          (m/s)
%# Values added: 10/09/2014
%[15] Mass flow rate (1s only)              (Kg/s)
%[16] Mass flow rate (mean, 1s intervals)   (Kg/s)
%[17] Mass flow rate (overall, Q/t)         (Kg/s)

%# PORT (averaged repeated runs) ------------------------------------------
AvgPortArray = [];
AvgPortArray = [AvgPortArray;stats_avg(1,800,results(8,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,1000,results(9:11,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,1200,results([12 16],:))];
AvgPortArray = [AvgPortArray;stats_avg(1,1400,results([13:15 17],:))];
AvgPortArray = [AvgPortArray;stats_avg(1,1600,results(18,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,1800,results(19:21,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,2000,results(22,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,2200,results(23:25,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,2400,results(26,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,2600,results(27:29,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,2800,results(30,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,3000,results(31:33,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,3200,results(34,:))];
AvgPortArray = [AvgPortArray;stats_avg(1,3400,results(35:37,:))];

%# STBD (averaged repeated runs) ------------------------------------------
AvgStbdArray = [];
AvgStbdArray = [AvgStbdArray;stats_avg(2,800,results(40,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,1000,results([38 41:43],:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,1200,results(44,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,1400,results(45:47,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,1600,results(48,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,1800,results(49:51,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,2000,results([39 52],:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,2200,results(53:55,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,2400,results(56,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,2600,results(57:59,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,2800,results(60,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,3000,results(61:63,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,3200,results(64,:))];
AvgStbdArray = [AvgStbdArray;stats_avg(2,3400,results(65:67,:))];

%# Write to summary array to save as file ---------------------------------

[mp,np] = size(AvgPortArray);
[ms,ns] = size(AvgStbdArray);

%# Summary array
SummaryMFRSept2014Array = [];
% SummaryMFRSept2014Array colums
%[1]  Set shaft speed                (RPM)
%[2]  PORT: Kiel probe               (V)
%[3]  PORT: Mass flow rate           (Kg/s)
%[4]  STBD: Kiel probe               (V)
%[5]  STBD: Mass flow rate           (Kg/s)
%# New columns: added 27/2/2015
%[6]  PORT: Measured shaft Speed     (RPM)
%[7]  STBD: Measured shaft Speed     (RPM)
%[8]  PORT: Measured shaft Speed     (PMS)
%[9]  STBD: Measured shaft Speed     (RPS)
%[10] PORT: Volumetric flow rate     (m^3/s)
%[10] STBD: Volumetric flow rate     (m^3/s)
for ks=1:mp
    SummaryMFRSept2014Array(ks,1)  = AvgStbdArray(ks,1);
    SummaryMFRSept2014Array(ks,2)  = AvgPortArray(ks,7);
    SummaryMFRSept2014Array(ks,3)  = AvgPortArray(ks,5);
    SummaryMFRSept2014Array(ks,4)  = AvgStbdArray(ks,6);
    SummaryMFRSept2014Array(ks,5)  = AvgStbdArray(ks,5);
    %# New columns: added 27/2/2015
    SummaryMFRSept2014Array(ks,6)  = AvgPortArray(ks,4);
    SummaryMFRSept2014Array(ks,7)  = AvgStbdArray(ks,3);
    SummaryMFRSept2014Array(ks,8)  = AvgPortArray(ks,4)/60;
    SummaryMFRSept2014Array(ks,9)  = AvgStbdArray(ks,3)/60;
    SummaryMFRSept2014Array(ks,10) = AvgPortArray(ks,4)/freshwaterdensity;
    SummaryMFRSept2014Array(ks,11) = AvgStbdArray(ks,3)/freshwaterdensity;
end

% /////////////////////////////////////////////////////////////////////////
% START Write results to DAT or TXT file
% -------------------------------------------------------------------------
M  = SummaryMFRSept2014Array;
M2 = M(any(M,2),:);                                                             % Remove zero rows
csvwrite('SummaryMFRSept2014Array.dat', M2)                                     % Export matrix M to a file delimited by the comma character
%dlmwrite('SummaryMFRSept2014Array.txt', M2, 'delimiter', '\t', 'precision', 4) % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% -------------------------------------------------------------------------
% END Write results to DAT or TXT file
% /////////////////////////////////////////////////////////////////////////

%# Averaged mean runs -----------------------------------------------------
stbdAvgPortArray = [];

[mpaa,npaa] = size(AvgPortArray);
[msaa,nsaa] = size(AvgStbdArray);

% Brake script when averaged arrays are not the same size
if mpaa ~= msaa
    disp('----------------------------------------------------');
    disp('AvgPortArray and AvgStbdArray are not the same size!');
    disp('----------------------------------------------------');
    break;
end

% Average AvgPortArray and AvgStbdArray arrays ----------------------------

%# Columns:
%[1]  Set shaft speed                       (RPM)
%[2]  Measured shaft Speed                  (RPM)
%[3]  Mass flow rate                        (Kg/s)
%[4]  Kiel probe                            (V)
%[5]  Torque                                (Nm)
%[6]  Volumetric flow rate                  (m^3/s)
%[7]  Flow coefficient                      (-)
%[8]  Jet velocity                          (m/s)

for k=1:mpaa
    stbdAvgPortArray(k,1) = mean([AvgStbdArray(k,1) AvgPortArray(k,1)]);
    stbdAvgPortArray(k,2) = round(mean([AvgStbdArray(k,3) AvgPortArray(k,4)]));
    stbdAvgPortArray(k,3) = mean([AvgStbdArray(k,5) AvgPortArray(k,5)]);
    stbdAvgPortArray(k,4) = mean([AvgStbdArray(k,6) AvgPortArray(k,7)]);
    stbdAvgPortArray(k,5) = mean([AvgStbdArray(k,10) AvgPortArray(k,11)]);
    stbdAvgPortArray(k,6) = mean([AvgStbdArray(k,12) AvgPortArray(k,12)]);
    stbdAvgPortArray(k,7) = mean([AvgStbdArray(k,13) AvgPortArray(k,13)]);
    stbdAvgPortArray(k,8) = mean([AvgStbdArray(k,14) AvgPortArray(k,14)]);
end


%# ************************************************************************
%# 2. Descriptive statistics for repeated runs
%# ************************************************************************

% Empty array
repeatedRunsDescStatArray = [];

%# repeatedRunsDescStatArray columns:

%# PORT: Mass flow rate ///////////////////////////////////////////////////

% MFR (1s only)
%[1]  Min                                   (Kg/s)
%[2]  Max                                   (Kg/s)
%[3]  Mean (or average)                     (Kg/s)
%[4]  Variance                              (Kg/s)
%[5]  Standard deviation                    (-)

% MFR (mean, 1s intervals)
%[6]  Min                                   (Kg/s)
%[7]  Max                                   (Kg/s)
%[8]  Mean (or average)                     (Kg/s)
%[9]  Variance                              (Kg/s)
%[10] Standard deviation                    (-)

% MFR (overall, Q/t)
%[11] Min                                   (Kg/s)
%[12] Max                                   (Kg/s)
%[13] Mean (or average)                     (Kg/s)
%[14] Variance                              (Kg/s)
%[15] Standard deviation                    (-)

%# STBD: Mass flow rate ///////////////////////////////////////////////////

% MFR (1s only)
%[16] Min                                   (Kg/s)
%[17] Max                                   (Kg/s)
%[18] Mean (or average)                     (Kg/s)
%[19] Variance                              (Kg/s)
%[20] Standard deviation                    (-)

% MFR (mean, 1s intervals)
%[21] Min                                   (Kg/s)
%[22] Max                                   (Kg/s)
%[23] Mean (or average)                     (Kg/s)
%[24] Variance                              (Kg/s)
%[25] Standard deviation                    (-)

% MFR (overall, Q/t)
%[26] Min                                   (Kg/s)
%[27] Max                                   (Kg/s)
%[28] Mean (or average)                     (Kg/s)
%[29] Variance                              (Kg/s)
%[30] Standard deviation                    (-)

% PORT: KIEL PROBE ////////////////////////////////////////////////////////
%[31] Min                                   (V)
%[32] Max                                   (V)
%[33] Mean (or average)                     (V)
%[34] Variance                              (V)
%[35] Standard deviation                    (-)

% STBD: KIEL PROBE ////////////////////////////////////////////////////////
%[36] Min                                   (V)
%[37] Max                                   (V)
%[38] Mean (or average)                     (V)
%[39] Variance                              (V)
%[40] Standard deviation                    (-)

% PORT --------------------------------------------------------------------
sortedByRPMPortArray = [];
sortedByRPMPortArray{1}  = results(8,:);
sortedByRPMPortArray{2}  = results(9:11,:);
sortedByRPMPortArray{3}  = results([12 16],:);
sortedByRPMPortArray{4}  = results([13:15 17],:);
sortedByRPMPortArray{5}  = results(18,:);
sortedByRPMPortArray{6}  = results(19:21,:);
sortedByRPMPortArray{7}  = results(22,:);
sortedByRPMPortArray{8}  = results(23:25,:);
sortedByRPMPortArray{9}  = results(26,:);
sortedByRPMPortArray{10} = results(27:29,:);
sortedByRPMPortArray{11} = results(30,:);
sortedByRPMPortArray{12} = results(31:33,:);
sortedByRPMPortArray{13} = results(34,:);
sortedByRPMPortArray{14} = results(35:37,:);
sortedByRPMPortArray     = sortedByRPMPortArray';

% STBD --------------------------------------------------------------------
sortedByRPMStbdArray = [];
sortedByRPMStbdArray{1}  = results(40,:);
sortedByRPMStbdArray{2}  = results([38 41:43],:);
sortedByRPMStbdArray{3}  = results(44,:);
sortedByRPMStbdArray{4}  = results(45:47,:);
sortedByRPMStbdArray{5}  = results(48,:);
sortedByRPMStbdArray{6}  = results(49:51,:);
sortedByRPMStbdArray{7}  = results([39 52],:);
sortedByRPMStbdArray{8}  = results(53:55,:);
sortedByRPMStbdArray{9}  = results(56,:);
sortedByRPMStbdArray{10} = results(57:59,:);
sortedByRPMStbdArray{11} = results(60,:);
sortedByRPMStbdArray{12} = results(61:63,:);
sortedByRPMStbdArray{13} = results(64,:);
sortedByRPMStbdArray{14} = results(65:67,:);
sortedByRPMStbdArray     = sortedByRPMStbdArray';

% Loop
for k=1:14
    %# PORT: Mass flow rate ///////////////////////////////////////////////
    
    % MFR (1s only)
    dataset = sortedByRPMPortArray{k}(:,16);
    repeatedRunsDescStatArray(k, 1)  = min(dataset);
    repeatedRunsDescStatArray(k, 2)  = max(dataset);
    repeatedRunsDescStatArray(k, 3)  = mean(dataset);
    repeatedRunsDescStatArray(k, 4)  = var(dataset,1);
    repeatedRunsDescStatArray(k, 5)  = std(dataset,1);
    
    % MFR (mean, 1s intervals)
    dataset = sortedByRPMPortArray{k}(:,17);
    repeatedRunsDescStatArray(k, 6)  = min(dataset);
    repeatedRunsDescStatArray(k, 7)  = max(dataset);
    repeatedRunsDescStatArray(k, 8)  = mean(dataset);
    repeatedRunsDescStatArray(k, 9)  = var(dataset,1);
    repeatedRunsDescStatArray(k, 10) = std(dataset,1);
    
    % MFR (overall, Q/t)
    dataset = sortedByRPMPortArray{k}(:,18);
    repeatedRunsDescStatArray(k, 11) = min(dataset);
    repeatedRunsDescStatArray(k, 12) = max(dataset);
    repeatedRunsDescStatArray(k, 13) = mean(dataset);
    repeatedRunsDescStatArray(k, 14) = var(dataset,1);
    repeatedRunsDescStatArray(k, 15) = std(dataset,1);
    
    %# STBD: Mass flow rate ///////////////////////////////////////////////
    
    % MFR (1s only)
    dataset = sortedByRPMStbdArray{k}(:,16);
    repeatedRunsDescStatArray(k, 16) = min(dataset);
    repeatedRunsDescStatArray(k, 17) = max(dataset);
    repeatedRunsDescStatArray(k, 18) = mean(dataset);
    repeatedRunsDescStatArray(k, 19) = var(dataset,1);
    repeatedRunsDescStatArray(k, 20) = std(dataset,1);
    
    % MFR (mean, 1s intervals)
    dataset = sortedByRPMStbdArray{k}(:,17);
    repeatedRunsDescStatArray(k, 21) = min(dataset);
    repeatedRunsDescStatArray(k, 22) = max(dataset);
    repeatedRunsDescStatArray(k, 23) = mean(dataset);
    repeatedRunsDescStatArray(k, 25) = var(dataset,1);
    repeatedRunsDescStatArray(k, 25) = std(dataset,1);
    
    % MFR (overall, Q/t)
    dataset = sortedByRPMStbdArray{k}(:,18);
    repeatedRunsDescStatArray(k, 26) = min(dataset);
    repeatedRunsDescStatArray(k, 27) = max(dataset);
    repeatedRunsDescStatArray(k, 28) = mean(dataset);
    repeatedRunsDescStatArray(k, 29) = var(dataset,1);
    repeatedRunsDescStatArray(k, 30) = std(dataset,1);
    
    %# PORT: KIEL PROBE ///////////////////////////////////////////////////
    dataset = sortedByRPMPortArray{k}(:,7);
    repeatedRunsDescStatArray(k, 31) = min(dataset);
    repeatedRunsDescStatArray(k, 32) = max(dataset);
    repeatedRunsDescStatArray(k, 33) = mean(dataset);
    repeatedRunsDescStatArray(k, 34) = var(dataset,1);
    repeatedRunsDescStatArray(k, 35) = std(dataset,1);
    
    %# STBD: KIEL PROBE ///////////////////////////////////////////////////
    dataset = sortedByRPMStbdArray{k}(:,8);
    repeatedRunsDescStatArray(k, 36) = min(dataset);
    repeatedRunsDescStatArray(k, 37) = max(dataset);
    repeatedRunsDescStatArray(k, 38) = mean(dataset);
    repeatedRunsDescStatArray(k, 39) = var(dataset,1);
    repeatedRunsDescStatArray(k, 40) = std(dataset,1);
end


%# ************************************************************************
%# 1. Plot kiel probe voltage against Mass flow rate
%# ************************************************************************

%# Plotting gross thrust vs. towing force
figurename = 'Plot 1: Kiel Probe Voltage vs. Mass flow rate';
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
setLegendFontSize  = 12;

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
%setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

% Markers sizes, etc.
setMarkerSize      = 12;
setLineWidth       = 1;
setLineWidth1      = 2;
setLineWidthMarker = 1;

setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '--';
setLineStyle3      = '-.';
setLineStyle4      = '-.';
setLineStyle5      = ':';

%# Subplot ////////////////////////////////////////////////////////////////
%subplot(1,1,1);

% X and Y values ----------------------------------------------------------

% Port WJ system (June 2013)
xPort13 = June13Port(:,4);
yPort13 = June13Port(:,3);

% Stbd (June 2013)
xStbd13 = June13Stbd(:,4);
yStbd13 = June13Stbd(:,3);

% Port WJ system (Sept. 2014)
xPort14 = AvgPortArray(:,7);
yPort14 = AvgPortArray(:,5);

% Stbd WJ system (Sept. 2014)
xStbd14 = AvgStbdArray(:,6);
yStbd14 = AvgStbdArray(:,5);

% Port and Stbd averaged (Sept. 2014)
if enableAvgPortStbdPlot == 1
    xPortStbdAvg14 = stbdAvgPortArray(:,4);
    yPortStbdAvg14 = stbdAvgPortArray(:,3);
end

% Equation of fit
EqnOfFitArray = [];
EqnOfFitKP    = [1:0.2:4.4];
[meof,neof]   = size(EqnOfFitKP);

%# Columns:
%[1]  Kiel probe output             (V)
%[2]  Stbd Mass flow rate           (Kg/s}
%[3]  Port Mass flow rate           (Kg/s}

for kj=1:neof
    KPValue = EqnOfFitKP(kj);
    EqnOfFitArray(kj, 1) = KPValue;
    EqnOfFitArray(kj, 2) = -0.0946*KPValue^4+1.1259*KPValue^3-5.0067*KPValue^2+11.0896*KPValue-6.8705;
    EqnOfFitArray(kj, 3) = -0.0421*KPValue^4+0.5718*KPValue^3-2.9517*KPValue^2+7.8517*KPValue-5.1976;
end

% Polynomial fit ----------------------------------------------------------

setPolyOrder = 4;

% Port WJ system (June 2013)
x = xPort13;
y = yPort13;

if enableCurveFittingToolboxPlot == 1
    % Curve Fitting Toolbox
    [fitobject1,gof1,output1] = fit(x,y,'poly4');
    cvalues1                  = coeffvalues(fitobject1);
else
    % Non-Curve Fitting Toolbox Fitting
    pfPort13 = polyfit(x,y,setPolyOrder);
    pvPort13 = polyval(pfPort13,x);
    
    ypred = pvPort13;           % Predictions
    dev = y - mean(y);          % Deviations - measure of spread
    SST = sum(dev.^2);          % Total variation to be accounted for
    resid = y - ypred;          % Residuals - measure of mismatch
    SSE = sum(resid.^2);        % Variation NOT accounted for
    Rsq1 = 1 - SSE/SST;         % Percent of error explained
end

% Stbd (June 2013)
x = xStbd13;
y = yStbd13;

if enableCurveFittingToolboxPlot == 1
    % Curve Fitting Toolbox
    [fitobject2,gof2,output2] = fit(x,y,'poly4');
    cvalues2                  = coeffvalues(fitobject2);
else
    % Non-Curve Fitting Toolbox Fitting
    pfStbd13 = polyfit(x,y,setPolyOrder);
    pvStbd13 = polyval(pfStbd13,x);
    
    ypred = pvStbd13;           % Predictions
    dev = y - mean(y);          % Deviations - measure of spread
    SST = sum(dev.^2);          % Total variation to be accounted for
    resid = y - ypred;          % Residuals - measure of mismatch
    SSE = sum(resid.^2);        % Variation NOT accounted for
    Rsq2 = 1 - SSE/SST;         % Percent of error explained
end

% Port WJ system (Sept. 2014)
x = xPort14;
y = yPort14;

if enableCurveFittingToolboxPlot == 1
    % Curve Fitting Toolbox
    [fitobject3,gof3,output3] = fit(x,y,'poly4');
    cvalues3                  = coeffvalues(fitobject3);
else
    % Non-Curve Fitting Toolbox Fitting
    pfPort14 = polyfit(x,y,setPolyOrder);
    pvPort14 = polyval(pfPort14,x);
    
    ypred = pvPort14;           % Predictions
    dev = y - mean(y);          % Deviations - measure of spread
    SST = sum(dev.^2);          % Total variation to be accounted for
    resid = y - ypred;          % Residuals - measure of mismatch
    SSE = sum(resid.^2);        % Variation NOT accounted for
    Rsq3 = 1 - SSE/SST;         % Percent of error explained
end

% Stbd WJ system (Sept. 2014)
x = xStbd14;
y = yStbd14;

if enableCurveFittingToolboxPlot == 1
    % Curve Fitting Toolbox
    [fitobject4,gof4,output4] = fit(x,y,'poly4');
    cvalues4                  = coeffvalues(fitobject4);
else
    % Non-Curve Fitting Toolbox Fitting
    pfStbd14 = polyfit(x,y,setPolyOrder);
    pvStbd14 = polyval(pfStbd14,x);
    
    ypred = pvStbd14;           % Predictions
    dev = y - mean(y);          % Deviations - measure of spread
    SST = sum(dev.^2);          % Total variation to be accounted for
    resid = y - ypred;          % Residuals - measure of mismatch
    SSE = sum(resid.^2);        % Variation NOT accounted for
    Rsq4 = 1 - SSE/SST;         % Percent of error explained
end

% Port and Stbd averaged (Sept. 2014)
if enableAvgPortStbdPlot == 1
    x = xPortStbdAvg14;
    y = yPortStbdAvg14;
    
    if enableCurveFittingToolboxPlot == 1
        % Curve Fitting Toolbox
        [fitobject5,gof5,output5] = fit(x,y,'poly4');
        cvalues5                  = coeffvalues(fitobject5);
    else
        % Non-Curve Fitting Toolbox Fitting
        pfPortStbd14 = polyfit(x,y,setPolyOrder);
        pvPortStbd14 = polyval(pfPortStbd14,x);
        
        ypred = pvPortStbd14;       % Predictions
        dev = y - mean(y);          % Deviations - measure of spread
        SST = sum(dev.^2);          % Total variation to be accounted for
        resid = y - ypred;          % Residuals - measure of mismatch
        SSE = sum(resid.^2);        % Variation NOT accounted for
        Rsq5 = 1 - SSE/SST;         % Percent of error explained
    end
end

%# ************************************************************************
%# Display in command window
%# ************************************************************************

% Set number of decimals in command window output
if enableCurveFittingToolboxPlot == 1
    % Decimals
    setDec1 = '%0.4f';
    setDec2 = '+%0.4f';
    setDec3 = '+%0.4f';
    setDec4 = '+%0.4f';
    setDec5 = '+%0.4f';
    
    % Port WJ system (June 2013)
    cval = cvalues1;
    gofa = gof1;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    if cval(3) < 0
        setDecimals3 = '%0.4f';
    end
    if cval(4) < 0
        setDecimals4 = '%0.4f';
    end
    if cval(5) < 0
        setDecimals5 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    gofa = sprintf('%0.2f',gofa.rsquare);
    EoFEqn = sprintf('Port WJ system (June 2013): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
    disp(EoFEqn);
    
    % Stbd (June 2013)
    cval = cvalues2;
    gofa = gof2;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    if cval(3) < 0
        setDecimals3 = '%0.4f';
    end
    if cval(4) < 0
        setDecimals4 = '%0.4f';
    end
    if cval(5) < 0
        setDecimals5 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    gofa = sprintf('%0.2f',gofa.rsquare);
    EoFEqn = sprintf('Stbd WJ system (June 2013): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
    disp(EoFEqn);
    
    % Port WJ system (Sept. 2014)
    cval = cvalues3;
    gofa = gof3;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    if cval(3) < 0
        setDecimals3 = '%0.4f';
    end
    if cval(4) < 0
        setDecimals4 = '%0.4f';
    end
    if cval(5) < 0
        setDecimals5 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    gofa = sprintf('%0.2f',gofa.rsquare);
    EoFEqn = sprintf('Port WJ system (Sept. 2014): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
    disp(EoFEqn);
    
    % Stbd WJ system (Sept. 2014)
    cval = cvalues4;
    gofa = gof4;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    if cval(1) < 0
        setDecimals1 = '%0.4f';
    end
    if cval(2) < 0
        setDecimals2 = '%0.4f';
    end
    if cval(3) < 0
        setDecimals3 = '%0.4f';
    end
    if cval(4) < 0
        setDecimals4 = '%0.4f';
    end
    if cval(5) < 0
        setDecimals5 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    gofa = sprintf('%0.2f',gofa.rsquare);
    EoFEqn = sprintf('Stbd WJ system (Sept. 2014): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
    disp(EoFEqn);
    
    % Port and Stbd averaged (Sept. 2014)
    if enableAvgPortStbdPlot == 1
        cval = cvalues5;
        gofa = gof5;
        setDecimals1 = '%0.4f';
        setDecimals2 = '+%0.4f';
        setDecimals3 = '+%0.4f';
        setDecimals4 = '+%0.4f';
        setDecimals5 = '+%0.4f';
        if cval(1) < 0
            setDecimals1 = '%0.4f';
        end
        if cval(2) < 0
            setDecimals2 = '%0.4f';
        end
        if cval(3) < 0
            setDecimals3 = '%0.4f';
        end
        if cval(4) < 0
            setDecimals4 = '%0.4f';
        end
        if cval(5) < 0
            setDecimals5 = '%0.4f';
        end
        p1   = sprintf(setDecimals1,cval(1));
        p2   = sprintf(setDecimals2,cval(2));
        p3   = sprintf(setDecimals3,cval(3));
        p4   = sprintf(setDecimals4,cval(4));
        p5   = sprintf(setDecimals5,cval(5));
        gofa = sprintf('%0.2f',gofa.rsquare);
        EoFEqn = sprintf('Avg. Port/Stbd WJ system (Sept. 2014): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
        disp(EoFEqn);
    end
else
    setPostDecimals = '+%0.2f';
    setNeutDecimals = '%0.2f';
    
    % Port WJ system (June 2013)
    fitEqn = pfPort13;
    if fitEqn(1) > 0
        var1 = sprintf(setPostDecimals,fitEqn(1));
    else
        var1 = sprintf(setNeutDecimals,fitEqn(1));
    end
    if fitEqn(2) > 0
        var2 = sprintf(setPostDecimals,fitEqn(2));
    else
        var2 = sprintf(setNeutDecimals,fitEqn(2));
    end
    if fitEqn(3) > 0
        var3 = sprintf(setPostDecimals,fitEqn(3));
    else
        var3 = sprintf(setNeutDecimals,fitEqn(3));
    end
    if fitEqn(4) > 0
        var4 = sprintf(setPostDecimals,fitEqn(4));
    else
        var4 = sprintf(setNeutDecimals,fitEqn(4));
    end
    if fitEqn(5) > 0
        var5 = sprintf(setPostDecimals,fitEqn(5));
    else
        var5 = sprintf(setNeutDecimals,fitEqn(5));
    end
    % Equation of fit (poly4)
    rSquared = sprintf('%0.1f',Rsq1);
    EQoFit1  = sprintf('Port WJ (Series 1): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
    disp(EQoFit1);
    
    % Stbd (June 2013)
    fitEqn = pfStbd13;
    if fitEqn(1) > 0
        var1 = sprintf(setPostDecimals,fitEqn(1));
    else
        var1 = sprintf(setNeutDecimals,fitEqn(1));
    end
    if fitEqn(2) > 0
        var2 = sprintf(setPostDecimals,fitEqn(2));
    else
        var2 = sprintf(setNeutDecimals,fitEqn(2));
    end
    if fitEqn(3) > 0
        var3 = sprintf(setPostDecimals,fitEqn(3));
    else
        var3 = sprintf(setNeutDecimals,fitEqn(3));
    end
    if fitEqn(4) > 0
        var4 = sprintf(setPostDecimals,fitEqn(4));
    else
        var4 = sprintf(setNeutDecimals,fitEqn(4));
    end
    if fitEqn(5) > 0
        var5 = sprintf(setPostDecimals,fitEqn(5));
    else
        var5 = sprintf(setNeutDecimals,fitEqn(5));
    end
    % Equation of fit (poly4)
    rSquared = sprintf('%0.1f',Rsq2);
    EQoFit2  = sprintf('Stbd WJ (Series 1): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
    disp(EQoFit2);
    
    % Port WJ system (Sept. 2014)
    fitEqn = pfPort14;
    if fitEqn(1) > 0
        var1 = sprintf(setPostDecimals,fitEqn(1));
    else
        var1 = sprintf(setNeutDecimals,fitEqn(1));
    end
    if fitEqn(2) > 0
        var2 = sprintf(setPostDecimals,fitEqn(2));
    else
        var2 = sprintf(setNeutDecimals,fitEqn(2));
    end
    if fitEqn(3) > 0
        var3 = sprintf(setPostDecimals,fitEqn(3));
    else
        var3 = sprintf(setNeutDecimals,fitEqn(3));
    end
    if fitEqn(4) > 0
        var4 = sprintf(setPostDecimals,fitEqn(4));
    else
        var4 = sprintf(setNeutDecimals,fitEqn(4));
    end
    if fitEqn(5) > 0
        var5 = sprintf(setPostDecimals,fitEqn(5));
    else
        var5 = sprintf(setNeutDecimals,fitEqn(5));
    end
    % Equation of fit (poly4)
    rSquared = sprintf('%0.1f',Rsq3);
    RS3      = sprintf('R^2: %s',rSquared);
    EoFit3   = sprintf('Curve fit: y=%sx^4%sx^3%sx^2%sx%s',var1,var2,var3,var4,var5);
    EQoFit3  = sprintf('Port WJ (Series 2): %s | %s',EoFit3,RS3);    
    disp(EQoFit3);
    
    % Stbd WJ system (Sept. 2014)
    fitEqn = pfStbd14;
    if fitEqn(1) > 0
        var1 = sprintf(setPostDecimals,fitEqn(1));
    else
        var1 = sprintf(setNeutDecimals,fitEqn(1));
    end
    if fitEqn(2) > 0
        var2 = sprintf(setPostDecimals,fitEqn(2));
    else
        var2 = sprintf(setNeutDecimals,fitEqn(2));
    end
    if fitEqn(3) > 0
        var3 = sprintf(setPostDecimals,fitEqn(3));
    else
        var3 = sprintf(setNeutDecimals,fitEqn(3));
    end
    if fitEqn(4) > 0
        var4 = sprintf(setPostDecimals,fitEqn(4));
    else
        var4 = sprintf(setNeutDecimals,fitEqn(4));
    end
    if fitEqn(5) > 0
        var5 = sprintf(setPostDecimals,fitEqn(5));
    else
        var5 = sprintf(setNeutDecimals,fitEqn(5));
    end
    % Equation of fit (poly4)
    rSquared = sprintf('%0.1f',Rsq4);
    RS4      = sprintf('R^2: %s',rSquared);
    EoFit4   = sprintf('Curve fit: y=%sx^4%sx^3%sx^2%sx%s',var1,var2,var3,var4,var5);
    EQoFit4  = sprintf('Stbd WJ (Series 2): %s | %s',EoFit4,RS4);
    disp(EQoFit4);
    
    % Port and Stbd averaged (Sept. 2014)
    if enableAvgPortStbdPlot == 1
        fitEqn = pfPortStbd14;
        if fitEqn(1) > 0
            var1 = sprintf(setPostDecimals,fitEqn(1));
        else
            var1 = sprintf(setNeutDecimals,fitEqn(1));
        end
        if fitEqn(2) > 0
            var2 = sprintf(setPostDecimals,fitEqn(2));
        else
            var2 = sprintf(setNeutDecimals,fitEqn(2));
        end
        if fitEqn(3) > 0
            var3 = sprintf(setPostDecimals,fitEqn(3));
        else
            var3 = sprintf(setNeutDecimals,fitEqn(3));
        end
        if fitEqn(4) > 0
            var4 = sprintf(setPostDecimals,fitEqn(4));
        else
            var4 = sprintf(setNeutDecimals,fitEqn(4));
        end
        if fitEqn(5) > 0
            var5 = sprintf(setPostDecimals,fitEqn(5));
        else
            var5 = sprintf(setNeutDecimals,fitEqn(5));
        end
        % Equation of fit (poly4)
        rSquared = sprintf('%0.2f',Rsq5);
        EQoFit5  = sprintf('Avg. Port/Stbd WJ (Series 2): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
        disp(EQoFit5);
    end
end

% Plotting ----------------------------------------------------------------
if enableCurveFittingToolboxPlot == 1
    
    % Port WJ system (June 2013)
    h = plot(xPort13,yPort13,'*');
    legendInfo{1} = 'Port WJ system (June 2013)';
    set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    % Fit
    h = plot(fitobject1,'-.');
    legendInfo{2} = 'Port WJ system (June 2013) Fit';
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
    hold on;
    
    % Stbd (June 2013)
    h = plot(xStbd13,yStbd13,'*');
    legendInfo{3} = 'Stbd WJ system (June 2013)';
    set(h(1),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    % Fit
    h = plot(fitobject2,'-.');
    legendInfo{4} = 'Stbd WJ system (June 2013) Fit';
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
    hold on;
    
    % Port WJ system (Sept. 2014)
    h = plot(xPort14,yPort14,'*');
    legendInfo{5} = 'Port WJ system (Sept. 2014)';
    set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    % Fit
    h = plot(fitobject3,'-.');
    legendInfo{6} = 'Port WJ system (Sept. 2014) Fit';
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle3,'linewidth',setLineWidth);
    hold on;
    
    % Stbd WJ system (Sept. 2014)
    h = plot(xStbd14,yStbd14,'*');
    legendInfo{7} = 'Stbd WJ system (Sept. 2014)';
    set(h(1),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    % Fit
    h = plot(fitobject4,'-.');
    legendInfo{8} = 'Stbd WJ system (Sept. 2014) Fit';
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle4,'linewidth',setLineWidth);
    hold on;
    
    % Averaged Port and Stbd WJ system (Sept. 2014)
    if enableAvgPortStbdPlot == 1
        h = plot(xPortStbdAvg14,yPortStbdAvg14,'*');
        legendInfo{9} = 'Averaged (Sept. 2014)';
        set(h(1),'Color',setColor{6},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        % Fit
        h = plot(fitobject5,'-');
        legendInfo{10} = 'Averaged (Sept. 2014) Fit';
        set(h(1),'Color',setColor{6},'LineStyle','--','LineWidth',setLineWidth);
    end % enableAvgPortStbdPlot
    
    % Error bars
    if enableErrorBarPlot == 1
        % Error Bars: Port WJ system (Sept. 2014)
        hold on;
        delta = repeatedRunsDescStatArray(:,5);
        h1    = errorbar(xPort14,yPort14,delta,'k');
        set(h1,'marker','+');
        set(h1,'linestyle','none');
        hold on;
        
        % Error Stbd: Port WJ system (Sept. 2014)
        hold on;
        delta = repeatedRunsDescStatArray(:,20);
        h1    = errorbar(xStbd14,yStbd14,delta,'k');
        set(h1,'marker','+');
        set(h1,'linestyle','none');
    end % enableErrorBarPlot
    
else

    h = plot(xPort13,yPort13,'*',xStbd13,yStbd13,'*',xPort14,yPort14,'*',xStbd14,yStbd14,'*');
    % Legend entries
    legendInfo{1} = 'Series 1: Port waterjet system';
    legendInfo{2} = 'Series 1: Stbd waterjet system';
    legendInfo{3} = 'Series 2: Port waterjet system';
    legendInfo{4} = 'Series 2: Stbd waterjet system';
    %# Line, colors and markers
    set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    hold on;
    
    % Curve fitting
    if enableCurveFittingPlot == 1
        % Patch min/max area
        patch([xStbd13;flipud(xPort13)],[pvStbd13;flipud(pvPort13)],[0.7,0.7,0.7],'EdgeColor','none'); %,'EdgeColor','none' [0.6,1,0.6]
        legendInfo{5} = 'Values covered by series 1 testing';
        patch([xStbd14;flipud(xPort14)],[pvStbd14;flipud(pvPort14)],[0.9,0.9,0.9],'EdgeColor','none'); %,'EdgeColor','none' [0.6,0.8,1]
        legendInfo{6} = 'Values covered by series 2 testing';        
        h1 = plot(xPort13,pvPort13,'-.',xStbd13,pvStbd13,'-.',xPort14,pvPort14,'-.',xStbd14,pvStbd14,'-.');
        %# Line, colors and markers
        set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
        set(h1(2),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
        set(h1(3),'Color',setColor{10},'LineStyle',setLineStyle3,'linewidth',setLineWidth);
        set(h1(4),'Color',setColor{10},'LineStyle',setLineStyle3,'linewidth',setLineWidth);
    end % enableCurveFittingPlot
    
end % enableCurveFittingToolboxPlot

% Cross check SummaryMFRSept2014Array data
%hold on;
%hx = plot(SummaryMFRSept2014Array(:,2),SummaryMFRSept2014Array(:,3),'-r',SummaryMFRSept2014Array(:,4),SummaryMFRSept2014Array(:,5),'-b');

if enablePlotTitle == 1
    title('{\bf Kiel Probe Output vs. Mass flow rate}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Kiel probe output (V)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass flow rate (Kg/s)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Text on plot -----------------------------------------------------------
if enableTextOnPlot == 1
    %text(2.5, 3.7, EQoFit1, 'Color', 'k');
    %text(2.5, 3.4, EQoFit2, 'Color', 'k');
    text(1.8, 1.8, '\bfPort waterjet (Series 2):', 'Color', 'k');
    text(1.8, 1.5, EoFit3, 'Color', 'k');
    text(1.8, 1.2, RS3, 'Color', 'k');
    text(1.8, 0.9, '\bfStbd waterjet (Series 2):', 'Color', 'k');
    text(1.8, 0.6, EoFit4, 'Color', 'k');
    text(1.8, 0.3, RS4, 'Color', 'k');
    if enableAvgPortStbdPlot == 1
        text(1.8, 0.2, EQoFit5, 'Color', 'k');
    end
end

%# Axis limitations -------------------------------------------------------
minX  = 1;
maxX  = 4.5;
incrX = 0.5;
minY  = 0;
maxY  = 5.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend -----------------------------------------------------------------
hleg1 = legend(legendInfo);
set(hleg1,'Location','SouthEast');
set(hleg1,'Interpreter','none');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);

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

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(portRuns(:,1));
maxRun = max(stbdRuns(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_1_MS_Kiel_Probe_vs_Mass_Flow_Rate_Plot.%s', '_kp_vs_mass_flow_rate', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 1.1 Plot kiel probe voltage against Mass flow rate (95% probability range)
%# ************************************************************************

%# Plotting gross thrust vs. towing force
figurename = 'Plot 1.1: Kiel Probe Voltage vs. Mass flow rate (95% probability range)';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ------------------------------------------------

%if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
%end

% Fonts and colours ---------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

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
%setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

% Markers sizes, etc.
setMarkerSize      = 12;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# Subplot ////////////////////////////////////////////////////////////////
%subplot(1,1,1);

% X and Y values ----------------------------------------------------------

% Port WJ system (June 2013)
xPort13 = June13Port(:,4);
yPort13 = June13Port(:,3);

% Stbd (June 2013)
xStbd13 = June13Stbd(:,4);
yStbd13 = June13Stbd(:,3);

% Port WJ system (Sept. 2014)
xPort14 = AvgPortArray(:,7);
yPort14 = AvgPortArray(:,5);

% Stbd WJ system (Sept. 2014)
xStbd14 = AvgStbdArray(:,6);
yStbd14 = AvgStbdArray(:,5);

% Port and Stbd averaged (Sept. 2014)
if enableAvgPortStbdPlot == 1
    xPortStbdAvg14 = stbdAvgPortArray(:,4);
    yPortStbdAvg14 = stbdAvgPortArray(:,3);
end

% Equation of fit
EqnOfFitArray = [];
EqnOfFitKP    = [1:0.2:4.4];
[meof,neof]   = size(EqnOfFitKP);

%# Columns:
%[1]  Kiel probe output             (V)
%[2]  Stbd Mass flow rate           (Kg/s}
%[3]  Port Mass flow rate           (Kg/s}

for kj=1:neof
    KPValue = EqnOfFitKP(kj);
    EqnOfFitArray(kj, 1) = KPValue;
    EqnOfFitArray(kj, 2) = -0.0946*KPValue^4+1.1259*KPValue^3-5.0067*KPValue^2+11.0896*KPValue-6.8705;
    EqnOfFitArray(kj, 3) = -0.0421*KPValue^4+0.5718*KPValue^3-2.9517*KPValue^2+7.8517*KPValue-5.1976;
end

% Polynomial fit ----------------------------------------------------------

setPolyOrder = 4;

% Port WJ system (June 2013)
x = xPort13;
y = yPort13;

[fitobject1,gof1,output1] = fit(x,y,'poly4');
cvalues1                  = coeffvalues(fitobject1);

% Stbd (June 2013)
x = xStbd13;
y = yStbd13;

[fitobject2,gof2,output2] = fit(x,y,'poly4');
cvalues2                  = coeffvalues(fitobject2);

% Port WJ system (Sept. 2014)
x = xPort14;
y = yPort14;

[fitobject3,gof3,output3] = fit(x,y,'poly4');
cvalues3                  = coeffvalues(fitobject3);

% Stbd WJ system (Sept. 2014)
x = xStbd14;
y = yStbd14;

% Curve Fitting Toolbox
[fitobject4,gof4,output4] = fit(x,y,'poly4');
cvalues4                  = coeffvalues(fitobject4);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

% Plotting ----------------------------------------------------------------
   
% Port WJ system (June 2013)
h = plot(xPort13,yPort13,'*');
legendInfo_1_1_1{1} = 'Port WJ system (June 2013)';
set(h(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
hold on;
% 95% propability range
hold on;
h = plot(fitobject1,'predobs',0.95);
legendInfo_1_1_1{2} = 'Fitted curve (poly4)';
legendInfo_1_1_1{3} = '95% probability (lower)';
legendInfo_1_1_1{4} = '95% probability (upper)';
setGT = 0.4;
set(h(1),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h(2),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h(3),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

% Stbd (June 2013)
h = plot(xStbd13,yStbd13,'*');
legendInfo_1_1_1{5} = 'Stbd WJ system (June 2013)';
set(h(1),'Color',setColor{5},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
hold on;
% 95% propability range
hold on;
h = plot(fitobject2,'predobs',0.95);
legendInfo_1_1_1{6} = 'Fitted curve (poly4)';
legendInfo_1_1_1{7} = '95% probability (lower)';
legendInfo_1_1_1{8} = '95% probability (upper)';
setGT = 0.7;
set(h(1),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h(2),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h(3),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

if enablePlotTitle == 1
    title('{\bf Kiel Probe Output vs. Mass flow rate}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Kiel probe output (V)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass flow rate (Kg/s)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 1;
maxX  = 4.5;
incrX = 0.5;
minY  = 0;
maxY  = 5.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo_1_1_1);
set(hleg1,'Location','SouthEast');
set(hleg1,'Interpreter','none');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,2)

% Plotting ----------------------------------------------------------------
   
% Port WJ system (Sept. 2014)
h = plot(xPort14,yPort14,'*');
legendInfo_1_1_2{1} = 'Port WJ system (Sept. 2014)';
set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
hold on;
% 95% propability range
hold on;
h = plot(fitobject3,'predobs',0.95);
legendInfo_1_1_2{2} = 'Fitted curve (poly4)';
legendInfo_1_1_2{3} = '95% probability (lower)';
legendInfo_1_1_2{4} = '95% probability (upper)';
setGT = 0.4;
set(h(1),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h(2),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h(3),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

% Stbd WJ system (Sept. 2014)
h = plot(xStbd14,yStbd14,'*');
legendInfo_1_1_2{5} = 'Stbd WJ system (Sept. 2014)';
set(h(1),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
hold on;
% 95% propability range
hold on;
h = plot(fitobject4,'predobs',0.95);
legendInfo_1_1_2{6} = 'Fitted curve (poly4)';
legendInfo_1_1_2{7} = '95% probability (lower)';
legendInfo_1_1_2{8} = '95% probability (upper)';
setGT = 0.7;
set(h(1),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h(2),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h(3),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

if enablePlotTitle == 1
    title('{\bf Kiel Probe Output vs. Mass flow rate}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Kiel probe output (V)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass flow rate (Kg/s)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 1;
maxX  = 4.5;
incrX = 0.5;
minY  = 0;
maxY  = 5.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo_1_1_2);
set(hleg1,'Location','SouthEast');
set(hleg1,'Interpreter','none');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);

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
minRun = min(portRuns(:,1));
maxRun = max(stbdRuns(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_1_1_MS_Kiel_Probe_vs_Mass_Flow_Rate_Plot.%s', '_kp_vs_mass_flow_rate', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 2. Flow rate vs. torque
%# ************************************************************************
figurename = 'Plot 2: Flow rate vs. torque';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

%     if enableA4PaperSizePlot == 1
%         set(gcf, 'PaperSize', [19 19]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 19 19]);
%
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperSize', [19 19]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 19 19]);
%     end

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

%# Line, colors and markers
setMarkerSize          = 14;
setLineWidthMarker     = 2;
setLineWidthMarkerThin = 1;
setLineWidth           = 2;
setLineWidthThin       = 1;
setLineStyle           = '-';
setLineStyle1          = '--';
setLineStyle2          = '-.';
setLineStyle3          = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,2,1)

% Port
x1 = AvgPortArray(:,5);
y1 = AvgPortArray(:,11);

% Curve fitting
[fitobjectp,gofp,outputp] = fit(x1,y1,'poly3');
cvaluesp                  = coeffvalues(fitobjectp);

cval         = cvaluesp;
setDecimals1 = '%0.4f';
setDecimals2 = '+%0.4f';
setDecimals3 = '+%0.4f';
setDecimals4 = '+%0.4f';
if cval(1) < 0
    setDecimals1 = '%0.4f';
end
if cval(2) < 0
    setDecimals2 = '%0.4f';
end
if cval(3) < 0
    setDecimals3 = '%0.4f';
end
if cval(4) < 0
    setDecimals4 = '%0.4f';
end
p1      = sprintf(setDecimals1,cval(1));
p2      = sprintf(setDecimals2,cval(2));
p3      = sprintf(setDecimals3,cval(3));
p4      = sprintf(setDecimals4,cval(4));
gofrs   = sprintf('%0.1f',gofp.rsquare);
EoFEqnP = sprintf('\\bf Port: \\rm y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
%disp(EoFEqnP);

% Starboard
x2 = AvgStbdArray(:,5);
y2 = AvgStbdArray(:,10);

% Curve fitting
[fitobjects,gofs,outputs] = fit(x2,y2,'poly3');
cvaluess                  = coeffvalues(fitobjects);

cval         = cvaluess;
setDecimals1 = '%0.4f';
setDecimals2 = '+%0.4f';
setDecimals3 = '+%0.4f';
setDecimals4 = '+%0.4f';
if cval(1) < 0
    setDecimals1 = '%0.4f';
end
if cval(2) < 0
    setDecimals2 = '%0.4f';
end
if cval(3) < 0
    setDecimals3 = '%0.4f';
end
if cval(4) < 0
    setDecimals4 = '%0.4f';
end
p1      = sprintf(setDecimals1,cval(1));
p2      = sprintf(setDecimals2,cval(2));
p3      = sprintf(setDecimals3,cval(3));
p4      = sprintf(setDecimals4,cval(4));
gofrs   = sprintf('%0.1f',gofs.rsquare);
EoFEqnS = sprintf('\\bf Stbd: \\rm y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
%disp(EoFEqnS);

%# Plotting ---------------------------------------------------------------
%# Port waterjet
h1 = plot(x1,y1,'*');
legendInfo_2{1} = 'Port waterjet';
% 95% propability range
hold on;
h2 = plot(fitobjectp,'predobs',0.95);
legendInfo_2{2} = 'Fitted curve (poly3)';
legendInfo_2{3} = '95% probability (lower)';
legendInfo_2{4} = '95% probability (upper)';
setGT = 0.4;
set(h2(1),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h2(2),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h2(3),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
%# Starboard waterjet
h3 = plot(x2,y2,'*');
legendInfo_2{5} = 'Starboard waterjet';
% 95% propability range
hold on;
h2 = plot(fitobjects,'predobs',0.95);
legendInfo_2{6} = 'Fitted curve (poly3)';
legendInfo_2{7} = '95% probability (lower)';
legendInfo_2{8} = '95% probability (upper)';
setGT = 0.7;
set(h2(1),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h2(2),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle3,'linewidth',setLineWidthThin);
set(h2(3),'Color',[setGT,setGT,setGT],'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
% if enablePlotTitle == 1
%     title('{\bf Torque}','FontSize',setGeneralFontSize);
% end
xlabel('{\bf Flow rate (Kg/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Torque (Nm)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations - text on plot
text(2.1,0.04,'Legend:','FontSize',12,'color','k','FontWeight','bold');
text(2.1,0.025,EoFEqnP,'FontSize',12,'color','k','FontWeight','normal');
text(2.1,0.01,EoFEqnS,'FontSize',12,'color','k','FontWeight','normal');

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarkerThin,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h3(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarkerThin,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Axis limitations
minX  = 1;
maxX  = 6;
incrX = 1;
minY  = 0;
maxY  = 0.3;
incrY = 0.05;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend(legendInfo_2);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','Tex');
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
%     if enableA4PaperSizePlot == 1
%         set(gcf, 'PaperUnits','centimeters');
%         set(gcf, 'PaperSize',[XPlot YPlot]);
%         set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%         set(gcf, 'PaperOrientation','portrait');
%     end

%# Plot title -------------------------------------------------------------
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
    plotsavename = sprintf('_plots/%s/%s/Plot_2_MS_Torque_vs_Flow_Rate_Plot.%s', '_kp_vs_mass_flow_rate', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ------------------------------------------------------------------------
%# Clear variables
%# ------------------------------------------------------------------------

% clearvars x y f h h1 h2 k kj
% clearvars setPostDecimals setNeutDecimals
% clearvars m n mpaa npaa msaa nsaa maaa naaa meof neof
% clearvars minRun maxRun fPath figurename hleg1 plotsavename
% clearvars setGeneralFontSize setBorderLineWidth setMarkerSize setSpeed
% clearvars setMarker setColor setFileFormat setGeneralFontName setSaveFormat setLineStyle setLineWidth setLineWidthMarker setPolyOrder
% clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize allPlots
% clearvars portSpeed1 portSpeed2 portSpeed3 portSpeed4 portSpeed5 portSpeed6 portSpeed7 portSpeed8 portSpeed9 portSpeed10 portSpeed11 portSpeed12 portSpeed13 portSpeed14
% clearvars stbdSpeed1 stbdSpeed2 stbdSpeed3 stbdSpeed4 stbdSpeed5 stbdSpeed6 stbdSpeed7 stbdSpeed8 stbdSpeed9 stbdSpeed10 stbdSpeed11 stbdSpeed12 stbdSpeed13 stbdSpeed14
% clearvars pfPort13 pvPort13 pfStbd13 pvStbd13 pfPort14 pvPort14 pfStbd14 pvStbd14 pfPortStbd14 pvPortStbd14
% clearvars EQoFit1 EQoFit2 EQoFit3 EQoFit4 EQoFit5 var1 var2 var3 var4 var5
% clearvars dev SST resid SSE rSquared fitEqn Rsq1 Rsq2 Rsq3 Rsq4 Rsq5
% clearvars June13Comb June13Port June13Stbd
% clearvars xPort13 yPort13 xStbd13 yStbd13 xPort14 yPort14 xStbd14 yStbd14 xPortStbdAvg14 yPortStbdAvg14 ypred
% clearvars EqnOfFitKP KPValue
