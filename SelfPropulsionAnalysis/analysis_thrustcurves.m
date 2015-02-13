%# ------------------------------------------------------------------------
%# Self-Propulsion: Thrust Curves
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  February 10, 2015
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
%#               => analysis_spp_ccdott.m Self-propulsion points by CCDoTT
%#                                    ==> Creates resultsArraySPP_CCDoTT.dat
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
%# CHANGES    :  26/01/2015 - Created new script
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

% Plot titles, colours, etc.
enablePlotMainTitle         = 1;    % Show plot title in saved file
enablePlotTitle             = 1;    % Show plot title above plot
enableBlackAndWhitePlot     = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot       = 1;    % Show plots scale to A4 size

% Command window output
enableAdjustedCommandWindow = 1;    % Show command window output

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox'));
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

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'Wartsila Thrust Curves';


%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory


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

%# SPP directory ----------------------------------------------------------
setDirName = '_plots/SPP';

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

%# Thrust_Curves directory ------------------------------------------------
setDirName = '_plots/Thrust_Curves';

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
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START Wartsila Thrust Curve Data
%#       ENGINE: Caterpillar with 7,200kW at 100% MCR
%#       LOSSES: 2% mechanical losses
%#       >> Default variable name: Caterpillar7200kW2PercentLosses
%# ------------------------------------------------------------------------
if exist('TC_Caterpillar_7200kW_2_Percent_Losses.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('TC_Caterpillar_7200kW_2_Percent_Losses.mat');
    
    %# Results array columns:
    %[1]  Power MCR             (%)
    %[2]  Jet Power, PJet       (kW)
    %[3]  Ship speed            (knots)
    %[4]  Thrust, T             (kN)
    %[5]  Shaft speed           (RPM)
    TCDataArray = Caterpillar7200kW2PercentLosses;
    
    % Clear original variable
    clearvars Caterpillar7200kW2PercentLosses;
end
%# ------------------------------------------------------------------------
%# END Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%# ************************************************************************


%# ************************************************************************
%# START Full scale results
%# ------------------------------------------------------------------------
if exist('fullScaleDataArray_CCDoTT.dat', 'file') == 2
    %# Results array columns:
    % See analysis_spp_ccdott.m for column descriptions
    fullscaleresults = csvread('fullScaleDataArray_CCDoTT.dat');
    [mfsr,nfsr] = size(fullscaleresults);
    %# Remove zero rows
    fullscaleresults(all(fullscaleresults==0,2),:)=[];
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: File fullScaleDataArray_CCDoTT.dat does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    %break;
end
%# ------------------------------------------------------------------------
%# START Full scale results
%# ************************************************************************


%# ************************************************************************
%# START Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ------------------------------------------------------------------------
if exist('SeaTrials1500TonnesCorrPower.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('SeaTrials1500TonnesCorrPower.mat');
    [m,n] = size(SeaTrialsCorrectedPower);
    STCorrPowerArrray = [];
    %# STCorrPowerArrray columns:
    % [1]  Ship speed                               (knots)
    % Total catamaran
    % [2]  Corrected power (total catamaran)        (MW)
    % [3]  Corrected power (total catamaran)        (kW)
    % [4]  Corrected power (total catamaran)        (W)
    % Single demihull
    % [5]  Corrected power (single demihull)        (MW)
    % [6]  Corrected power (single demihull)        (kW)
    % [7]  Corrected power (single demihull)        (W)
    % Single waterjet
    % [8]  Corrected power (single waterjet)        (MW)
    % [9]  Corrected power (single waterjet)        (kW)
    % [10] Corrected power (single waterjet)        (W)
    for k=1:m
        STCorrPowerArrray(k,1)  = SeaTrialsCorrectedPower(k,1);
        % Total catamaran
        STCorrPowerArrray(k,2)  = SeaTrialsCorrectedPower(k,3);
        STCorrPowerArrray(k,3)  = SeaTrialsCorrectedPower(k,3)*1000;
        STCorrPowerArrray(k,4)  = SeaTrialsCorrectedPower(k,3)*1000^2;
        % Single demihull
        STCorrPowerArrray(k,5)  = SeaTrialsCorrectedPower(k,3)/2;
        STCorrPowerArrray(k,6)  = (SeaTrialsCorrectedPower(k,3)/2)*1000;
        STCorrPowerArrray(k,7)  = (SeaTrialsCorrectedPower(k,3)/2)*1000^2;
        % Single waterjet
        STCorrPowerArrray(k,8)  = SeaTrialsCorrectedPower(k,3)/4;
        STCorrPowerArrray(k,9)  = (SeaTrialsCorrectedPower(k,3)/4)*1000;
        STCorrPowerArrray(k,10) = (SeaTrialsCorrectedPower(k,3)/4)*1000^2;
    end
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (SeaTrials1500TonnesCorrPower.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ************************************************************************


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

%# Caterpillar Engine with 7,200kW at 1--% MCR and 2% mechanical losses
SingWJ100PerMCR = 7056;     % Single waterjet
SingDH100PerMCR = 7056*2;   % Single demihull (i.e. 2x single waterjet)
TotCat100PerMCR = 7056*4;   % Total catamaran (i.e. 4x single waterjet)

%# Waterjet self-propulsion speeds (full scale in knots)
WSPSpeed        = fullscaleresults(:,3);

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


%# ************************************************************************
%# Set Variables: Associate thrust curve data with % MCR
%# ************************************************************************

EoFTCArray = [];
%# EoFTCArray columns:
% [1]  % MCR            (%)
% [2]  P1 parameter     (-)
% [3]  P2 parameter     (-)
% [4]  P3 parameter     (-)
% [5]  P4 parameter     (-)
% [6]  Root squared     (-)

Pct5MCR   = TCDataArray(1:28,:);
Pct10MCR  = TCDataArray(29:65,:);
Pct15MCR  = TCDataArray(66:106,:);
Pct20MCR  = TCDataArray(107:147,:);
Pct25MCR  = TCDataArray(148:188,:);
Pct30MCR  = TCDataArray(189:229,:);
Pct35MCR  = TCDataArray(230:270,:);
Pct40MCR  = TCDataArray(271:308,:);
Pct45MCR  = TCDataArray(309:343,:);
Pct50MCR  = TCDataArray(344:375,:);
Pct55MCR  = TCDataArray(376:405,:);
Pct60MCR  = TCDataArray(406:433,:);
Pct65MCR  = TCDataArray(434:459,:);
Pct70MCR  = TCDataArray(460:483,:);
Pct75MCR  = TCDataArray(484:506,:);
Pct80MCR  = TCDataArray(507:527,:);
Pct85MCR  = TCDataArray(528:547,:);
Pct90MCR  = TCDataArray(548:566,:);
Pct95MCR  = TCDataArray(567:584,:);
Pct100MCR = TCDataArray(585:600,:);
SS1       = TCDataArray(601:626,:);

% Equations of fit (EoF) --------------------------------------------------

if enableAdjustedCommandWindow == 1
    disp('*****************************************************************************************');
    disp('1. Thrust Cruves Equations of Fit (for EoF see EoFTCArray)');
    disp('*****************************************************************************************');
end

%# 5% *********************************************************************

[fitobject1,gof1,output1]    = fit(Pct5MCR(:,3),Pct5MCR(:,4),'poly3');
cvalues5                     = coeffvalues(fitobject1);

if enableAdjustedCommandWindow == 1
    cval = cvalues5;
    gof  = gof1;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('5 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 1;
    EoFTCArray(setRow,1) = 5;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 10% ********************************************************************

[fitobject2,gof2,output2]    = fit(Pct10MCR(:,3),Pct10MCR(:,4),'poly3');
cvalues10                    = coeffvalues(fitobject2);

if enableAdjustedCommandWindow == 1
    cval = cvalues10;
    gof  = gof2;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('10 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 2;
    EoFTCArray(setRow,1) = 10;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 15% ********************************************************************

[fitobject3,gof3,output3]    = fit(Pct15MCR(:,3),Pct15MCR(:,4),'poly3');
cvalues15                    = coeffvalues(fitobject3);

if enableAdjustedCommandWindow == 1
    cval = cvalues15;
    gof  = gof3;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('15 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 3;
    EoFTCArray(setRow,1) = 15;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 20% ********************************************************************

[fitobject4,gof4,output4]    = fit(Pct20MCR(:,3),Pct20MCR(:,4),'poly3');
cvalues20                    = coeffvalues(fitobject4);

if enableAdjustedCommandWindow == 1
    cval = cvalues20;
    gof  = gof4;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('20 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 4;
    EoFTCArray(setRow,1) = 20;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 25% ********************************************************************

[fitobject5,gof5,output5]    = fit(Pct25MCR(:,3),Pct25MCR(:,4),'poly3');
cvalues25                    = coeffvalues(fitobject5);

if enableAdjustedCommandWindow == 1
    cval = cvalues25;
    gof  = gof5;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('25 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 5;
    EoFTCArray(setRow,1) = 25;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 30% ********************************************************************

[fitobject6,gof6,output6]    = fit(Pct30MCR(:,3),Pct30MCR(:,4),'poly3');
cvalues30                    = coeffvalues(fitobject6);

if enableAdjustedCommandWindow == 1
    cval = cvalues30;
    gof  = gof6;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('30 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 6;
    EoFTCArray(setRow,1) = 30;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 35% ********************************************************************

[fitobject7,gof7,output7]    = fit(Pct35MCR(:,3),Pct35MCR(:,4),'poly3');
cvalues35                    = coeffvalues(fitobject7);

if enableAdjustedCommandWindow == 1
    cval = cvalues35;
    gof  = gof7;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('35 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 7;
    EoFTCArray(setRow,1) = 35;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 40% ********************************************************************

[fitobject8,gof8,output8]    = fit(Pct40MCR(:,3),Pct40MCR(:,4),'poly3');
cvalues40                    = coeffvalues(fitobject8);

if enableAdjustedCommandWindow == 1
    cval = cvalues40;
    gof  = gof8;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('40 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 8;
    EoFTCArray(setRow,1) = 40;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 45% ********************************************************************

[fitobject9,gof9,output9]    = fit(Pct45MCR(:,3),Pct45MCR(:,4),'poly3');
cvalues45                    = coeffvalues(fitobject9);

if enableAdjustedCommandWindow == 1
    cval = cvalues45;
    gof  = gof9;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('45 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 9;
    EoFTCArray(setRow,1) = 45;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 50% ********************************************************************

[fitobject10,gof10,output10] = fit(Pct50MCR(:,3),Pct50MCR(:,4),'poly3');
cvalues50                    = coeffvalues(fitobject10);

if enableAdjustedCommandWindow == 1
    cval = cvalues50;
    gof  = gof10;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('50 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 10;
    EoFTCArray(setRow,1) = 50;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 55% ********************************************************************

[fitobject11,gof11,output11] = fit(Pct55MCR(:,3),Pct55MCR(:,4),'poly3');
cvalues55                    = coeffvalues(fitobject11);

if enableAdjustedCommandWindow == 1
    cval = cvalues55;
    gof  = gof11;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('55 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 11;
    EoFTCArray(setRow,1) = 55;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 60% ********************************************************************

[fitobject12,gof12,output12] = fit(Pct60MCR(:,3),Pct60MCR(:,4),'poly3');
cvalues60                    = coeffvalues(fitobject12);

if enableAdjustedCommandWindow == 1
    cval = cvalues60;
    gof  = gof12;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('60 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 12;
    EoFTCArray(setRow,1) = 60;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 65% ********************************************************************

[fitobject13,gof13,output13] = fit(Pct65MCR(:,3),Pct65MCR(:,4),'poly3');
cvalues65                    = coeffvalues(fitobject13);

if enableAdjustedCommandWindow == 1
    cval = cvalues65;
    gof  = gof13;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('65 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 13;
    EoFTCArray(setRow,1) = 65;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 70% ********************************************************************

[fitobject14,gof14,output14] = fit(Pct70MCR(:,3),Pct70MCR(:,4),'poly3');
cvalues70                    = coeffvalues(fitobject14);

if enableAdjustedCommandWindow == 1
    cval = cvalues70;
    gof  = gof14;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('70 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 14;
    EoFTCArray(setRow,1) = 70;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 75% ********************************************************************

[fitobject15,gof15,output15] = fit(Pct75MCR(:,3),Pct75MCR(:,4),'poly3');
cvalues75                    = coeffvalues(fitobject15);

if enableAdjustedCommandWindow == 1
    cval = cvalues75;
    gof  = gof15;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('75 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 15;
    EoFTCArray(setRow,1) = 75;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 80% ********************************************************************

[fitobject16,gof16,output16] = fit(Pct80MCR(:,3),Pct80MCR(:,4),'poly3');
cvalues80                    = coeffvalues(fitobject16);

if enableAdjustedCommandWindow == 1
    cval = cvalues80;
    gof  = gof16;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('80 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 16;
    EoFTCArray(setRow,1) = 80;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 85% ********************************************************************

[fitobject17,gof17,output17] = fit(Pct85MCR(:,3),Pct85MCR(:,4),'poly3');
cvalues85                    = coeffvalues(fitobject17);

if enableAdjustedCommandWindow == 1
    cval = cvalues85;
    gof  = gof17;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('85 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 17;
    EoFTCArray(setRow,1) = 85;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 90% ********************************************************************

[fitobject18,gof18,output18] = fit(Pct90MCR(:,3),Pct90MCR(:,4),'poly3');
cvalues90                    = coeffvalues(fitobject18);

if enableAdjustedCommandWindow == 1
    cval = cvalues90;
    gof  = gof18;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('90 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 18;
    EoFTCArray(setRow,1) = 90;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 95% ********************************************************************

[fitobject19,gof19,output19] = fit(Pct95MCR(:,3),Pct95MCR(:,4),'poly3');
cvalues95                    = coeffvalues(fitobject19);

if enableAdjustedCommandWindow == 1
    cval = cvalues95;
    gof  = gof19;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('95 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 19;
    EoFTCArray(setRow,1) = 95;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

%# 100% *******************************************************************

[fitobject20,gof20,output20] = fit(Pct100MCR(:,3),Pct100MCR(:,4),'poly3');
cvalues100                   = coeffvalues(fitobject20);

if enableAdjustedCommandWindow == 1
    cval = cvalues100;
    gof  = gof20;
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
    p1     = sprintf(setDecimals1,cval(1));
    p2     = sprintf(setDecimals2,cval(2));
    p3     = sprintf(setDecimals3,cval(3));
    p4     = sprintf(setDecimals4,cval(4));
    gofrs  = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('100 Percent Thrust Curve: y=%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,gofrs);
    disp(EoFEqn);
    
    % Write to EoF array
    setRow = 20;
    EoFTCArray(setRow,1) = 100;
    EoFTCArray(setRow,2) = cval(1);
    EoFTCArray(setRow,3) = cval(2);
    EoFTCArray(setRow,4) = cval(3);
    EoFTCArray(setRow,5) = cval(4);
    EoFTCArray(setRow,6) = gof.rsquare;
end

% Root square values ******************************************************
RSArray(1)  = gof1.rsquare;
RSArray(2)  = gof2.rsquare;
RSArray(3)  = gof3.rsquare;
RSArray(4)  = gof4.rsquare;
RSArray(5)  = gof5.rsquare;
RSArray(6)  = gof6.rsquare;
RSArray(7)  = gof7.rsquare;
RSArray(8)  = gof8.rsquare;
RSArray(9)  = gof9.rsquare;
RSArray(10) = gof10.rsquare;
RSArray(11) = gof11.rsquare;
RSArray(12) = gof12.rsquare;
RSArray(13) = gof13.rsquare;
RSArray(14) = gof14.rsquare;
RSArray(15) = gof15.rsquare;
RSArray(16) = gof16.rsquare;
RSArray(17) = gof17.rsquare;
RSArray(18) = gof18.rsquare;
RSArray(19) = gof19.rsquare;
RSArray(20) = gof20.rsquare;
RSArray = RSArray';

%# ************************************************************************
%# Calculations: Estimate % MCR based on sea trials power
%# ************************************************************************

%# 1. Polynomial fit for corrected sea trials power -----------------------

if enableAdjustedCommandWindow == 1
    disp('*****************************************************************************************');
    disp('2. Corrected Sea Trials Power Equations of Fit (EoF). For % MCR values see CalcMCRAArray.');
    disp('*****************************************************************************************');
end

% Total catamaran (knots and MW) ******************************************
xTotCat = STCorrPowerArrray(:,1);
yTotCat = STCorrPowerArrray(:,2);
[fitobjectTotCat,gofTotCat,outputTotCat] = fit(xTotCat,yTotCat,'poly5');
cvaluesTotCat                            = coeffvalues(fitobjectTotCat);

if enableAdjustedCommandWindow == 1
    cval = cvaluesTotCat;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    setDecimals6 = '+%0.4f';
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
    if cval(6) < 0
        setDecimals6 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    p6   = sprintf(setDecimals6,cval(6));
    gofrs = sprintf('%0.2f',gofTotCat.rsquare);
    EoFEqn = sprintf('Total catamaran: y=%sx^5%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,p6,gofrs);
    disp(EoFEqn);
end

% Single demihull (knots and MW) ******************************************
xSingDH = STCorrPowerArrray(:,1);
ySingDH = STCorrPowerArrray(:,5);
[fitobjectSingDH,gofSingDH,outputSingDH] = fit(xSingDH,ySingDH,'poly5');
cvaluesSingDH                            = coeffvalues(fitobjectSingDH);

if enableAdjustedCommandWindow == 1
    cval = cvaluesSingDH;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    setDecimals6 = '+%0.4f';
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
    if cval(6) < 0
        setDecimals6 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    p6   = sprintf(setDecimals6,cval(6));
    gofrs = sprintf('%0.2f',gofTotCat.rsquare);
    EoFEqn = sprintf('Single demihull: y=%sx^5%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,p6,gofrs);
    disp(EoFEqn);
end

% Single waterjet (knots and MW) ******************************************
xSingWJ = STCorrPowerArrray(:,1);
ySingWJ = STCorrPowerArrray(:,8);
[fitobjectSingWJ,gofSingWJ,outputSingWJ] = fit(xSingWJ,ySingWJ,'poly5');
cvaluesSingWJ                            = coeffvalues(fitobjectSingWJ);

if enableAdjustedCommandWindow == 1
    cval = cvaluesSingWJ;
    setDecimals1 = '%0.4f';
    setDecimals2 = '+%0.4f';
    setDecimals3 = '+%0.4f';
    setDecimals4 = '+%0.4f';
    setDecimals5 = '+%0.4f';
    setDecimals6 = '+%0.4f';
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
    if cval(6) < 0
        setDecimals6 = '%0.4f';
    end
    p1   = sprintf(setDecimals1,cval(1));
    p2   = sprintf(setDecimals2,cval(2));
    p3   = sprintf(setDecimals3,cval(3));
    p4   = sprintf(setDecimals4,cval(4));
    p5   = sprintf(setDecimals5,cval(5));
    p6   = sprintf(setDecimals6,cval(6));
    gofrs = sprintf('%0.2f',gofTotCat.rsquare);
    EoFEqn = sprintf('Single waterjet: y=%sx^5%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,p6,gofrs);
    disp(EoFEqn);
end

%# 2. Calculate % MCR usings self-propulsion speed range ------------------

[mfs,nfs] = size(WSPSpeed);

CalcMCRAArray = [];
% CalcMCRAArray columns:
% [1]  Ship speed                                   (knots)
% Total catamaran
% [2]  Power using poly fit of corrected ST power   (MW)
% [3]  % MCR                                        (%)
% Single demihull
% [4]  Power using poly fit of corrected ST power   (MW)
% [5]  % MCR                                        (%)
% Single waterjet
% [6]  Power using poly fit of corrected ST power   (MW)
% [7]  % MCR                                        (%)
for k=1:mfs
    CalcMCRAArray(k,1) = WSPSpeed(k);
    % Total catamaran
    EoF = cvaluesTotCat(1)*WSPSpeed(k)^5+cvaluesTotCat(2)*WSPSpeed(k)^4+cvaluesTotCat(3)*WSPSpeed(k)^3+cvaluesTotCat(4)*WSPSpeed(k)^2+cvaluesTotCat(5)*WSPSpeed(k)+cvaluesTotCat(6);
    CalcMCRAArray(k,2) = EoF;
    CalcMCRAArray(k,3) = EoF/(TotCat100PerMCR/1000);
    % Single demihull
    EoF = cvaluesSingDH(1)*WSPSpeed(k)^5+cvaluesSingDH(2)*WSPSpeed(k)^4+cvaluesSingDH(3)*WSPSpeed(k)^3+cvaluesSingDH(4)*WSPSpeed(k)^2+cvaluesSingDH(5)*WSPSpeed(k)+cvaluesSingDH(6);
    CalcMCRAArray(k,4) = EoF;
    CalcMCRAArray(k,5) = EoF/(SingDH100PerMCR/1000);
    % Single waterjet
    EoF = cvaluesSingWJ(1)*WSPSpeed(k)^5+cvaluesSingWJ(2)*WSPSpeed(k)^4+cvaluesSingWJ(3)*WSPSpeed(k)^3+cvaluesSingWJ(4)*WSPSpeed(k)^2+cvaluesSingWJ(5)*WSPSpeed(k)+cvaluesSingWJ(6);
    CalcMCRAArray(k,6) = EoF;
    CalcMCRAArray(k,7) = EoF/(SingWJ100PerMCR/1000);
end

%# 3. Interpol. thrust curve data for % MCR values (see CalcMCRAArray) ----

%# Create empty arrays
IntPolS1 = [];
IntPolS2 = [];
IntPolS3 = [];
IntPolS4 = [];
IntPolS5 = [];
IntPolS6 = [];
IntPolS7 = [];
IntPolS8 = [];
IntPolS9 = [];

IntPolThrustArray = [];
%# IntPolThrustArray columns:
% [1]  Ship speed                        (%)
% [2]  Single waterjet: Thrust at % MCR  (kN)
% [3]  % MCR                             (%)
% [4]  Single demihull: Thrust at % MCR  (kN)
% [5]  Total catamaran: Thrust at % MCR  (kN)

EoFTCInterpolArray = [];
%# EoFTCInterpolArray columns:
% [1]  % MCR                (%)
% [2]  P1 parameter         (-)
% [3]  P2 parameter         (-)
% [4]  P3 parameter         (-)
% [5]  P4 parameter         (-)
% [6]  Root squared         (-)

% Loop through speeds
if enableAdjustedCommandWindow == 1
    disp('*****************************************************************************************');
    disp('3. Calculation MCR Interpolation Ranges (for EoF see EoFTCInterpolArray)');
    disp('*****************************************************************************************');
end
for k=1:mfs
    
    % Start with empty array each iteration!!!!
    IntPol   = [];
    
    % Determine which interpolation range is required
    if CalcMCRAArray(k,3) > 0.05 && CalcMCRAArray(k,3) < 0.1
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 5%% > MCR < 10%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.05;
        maxMCR      = 0.10;
        minEoF      = cvalues5;
        maxEoF      = cvalues10;
        minMCRArray = Pct5MCR;
        maxMCRArray = Pct10MCR;
    elseif CalcMCRAArray(k,3) > 0.1 && CalcMCRAArray(k,3) < 0.15
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 10%% > MCR < 15%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.1;
        maxMCR      = 0.15;
        minEoF      = cvalues10;
        maxEoF      = cvalues15;
        minMCRArray = Pct10MCR;
        maxMCRArray = Pct15MCR;
    elseif CalcMCRAArray(k,3) > 0.15 && CalcMCRAArray(k,3) < 0.20
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 15%% > MCR < 20%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.15;
        maxMCR      = 0.20;
        minEoF      = cvalues15;
        maxEoF      = cvalues20;
        minMCRArray = Pct15MCR;
        maxMCRArray = Pct20MCR;
    elseif CalcMCRAArray(k,3) > 0.2 && CalcMCRAArray(k,3) < 0.25
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 20%% > MCR < 25%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.2;
        maxMCR      = 0.25;
        minEoF      = cvalues20;
        maxEoF      = cvalues25;
        minMCRArray = Pct20MCR;
        maxMCRArray = Pct25MCR;
    elseif CalcMCRAArray(k,3) > 0.25 && CalcMCRAArray(k,3) < 0.30
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 25%% > MCR < 30%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.25;
        maxMCR      = 0.3;
        minEoF      = cvalues25;
        maxEoF      = cvalues30;
        minMCRArray = Pct25MCR;
        maxMCRArray = Pct30MCR;
    elseif CalcMCRAArray(k,3) > 0.3 && CalcMCRAArray(k,3) < 0.35
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 30%% > MCR < 35%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.3;
        maxMCR      = 0.35;
        minEoF      = cvalues30;
        maxEoF      = cvalues35;
        minMCRArray = Pct30MCR;
        maxMCRArray = Pct35MCR;
    elseif CalcMCRAArray(k,3) > 0.35 && CalcMCRAArray(k,3) < 0.40
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 35%% > MCR < 40%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.35;
        maxMCR      = 0.40;
        minEoF      = cvalues35;
        maxEoF      = cvalues40;
        minMCRArray = Pct35MCR;
        maxMCRArray = Pct40MCR;
    elseif CalcMCRAArray(k,3) > 0.4 && CalcMCRAArray(k,3) < 0.45
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 40%% > MCR < 45%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.4;
        maxMCR      = 0.45;
        minEoF      = cvalues40;
        maxEoF      = cvalues45;
        minMCRArray = Pct40MCR;
        maxMCRArray = Pct45MCR;
    elseif CalcMCRAArray(k,3) > 0.45 && CalcMCRAArray(k,3) < 0.5
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 45%% > MCR < 50%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.45;
        maxMCR      = 0.5;
        minEoF      = cvalues45;
        maxEoF      = cvalues50;
        minMCRArray = Pct45MCR;
        maxMCRArray = Pct50MCR;
    elseif CalcMCRAArray(k,3) > 0.5 && CalcMCRAArray(k,3) < 0.55
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 50%% > MCR < 55%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.5;
        maxMCR      = 0.55;
        minEoF      = cvalues50;
        maxEoF      = cvalues55;
        minMCRArray = Pct50MCR;
        maxMCRArray = Pct55MCR;
    elseif CalcMCRAArray(k,3) > 0.55 && CalcMCRAArray(k,3) < 0.6
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 55%% > MCR < 60%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.55;
        maxMCR      = 0.60;
        minEoF      = cvalues55;
        maxEoF      = cvalues60;
        minMCRArray = Pct55MCR;
        maxMCRArray = Pct60MCR;
    elseif CalcMCRAArray(k,3) > 0.6 && CalcMCRAArray(k,3) < 0.65
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 60%% > MCR < 65%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.6;
        maxMCR      = 0.65;
        minEoF      = cvalues60;
        maxEoF      = cvalues65;
        minMCRArray = Pct60MCR;
        maxMCRArray = Pct65MCR;
    elseif CalcMCRAArray(k,3) > 0.65 && CalcMCRAArray(k,3) < 0.70
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 65%% > MCR < 70%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.65;
        maxMCR      = 0.70;
        minEoF      = cvalues65;
        maxEoF      = cvalues70;
        minMCRArray = Pct65MCR;
        maxMCRArray = Pct7-MCR;
    elseif CalcMCRAArray(k,3) > 0.7 && CalcMCRAArray(k,3) < 0.75
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 70%% > MCR < 75%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.7;
        maxMCR      = 0.75;
        minEoF      = cvalues70;
        maxEoF      = cvalues75;
        minMCRArray = Pct70MCR;
        maxMCRArray = Pct75MCR;
    elseif CalcMCRAArray(k,3) > 0.75 && CalcMCRAArray(k,3) < 0.8
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 75%% > MCR < 80%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.75;
        maxMCR      = 0.80;
        minEoF      = cvalues75;
        maxEoF      = cvalues80;
        minMCRArray = Pct75MCR;
        maxMCRArray = Pct80MCR;
    elseif CalcMCRAArray(k,3) > 0.8 && CalcMCRAArray(k,3) < 0.85
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 80%% > MCR < 85%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.8;
        maxMCR      = 0.85;
        minEoF      = cvalues80;
        maxEoF      = cvalues85;
        minMCRArray = Pct80MCR;
        maxMCRArray = Pct85MCR;
    elseif CalcMCRAArray(k,3) > 0.85 && CalcMCRAArray(k,3) < 0.9
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 85%% > MCR < 90%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.85;
        maxMCR      = 0.90;
        minEoF      = cvalues85;
        maxEoF      = cvalues90;
        minMCRArray = Pct85MCR;
        maxMCRArray = Pct90MCR;
    elseif CalcMCRAArray(k,3) > 0.90 && CalcMCRAArray(k,3) < 0.95
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 90%% > MCR < 95%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.9;
        maxMCR      = 0.95;
        minEoF      = cvalues90;
        maxEoF      = cvalues95;
        minMCRArray = Pct90MCR;
        maxMCRArray = Pct95MCR;
    elseif CalcMCRAArray(k,3) > 0.95 && CalcMCRAArray(k,3) < 1
        if enableAdjustedCommandWindow == 1
            disp(sprintf('>> Speed %s (%s knots): 95%% > MCR < 100%%, MCR using Sea Trials Power = %s%%',num2str(k),sprintf('%0.1f',WSPSpeed(k)),sprintf('%0.1f',CalcMCRAArray(k,3)*100)));
        end
        minMCR      = 0.95;
        maxMCR      = 1;
        minEoF      = cvalues95;
        maxEoF      = cvalues100;
        minMCRArray = Pct95MCR;
        maxMCRArray = Pct100MCR;
    end
    
    % Min
    min1 = min(round(minMCRArray(:,3)));
    min2 = min(round(maxMCRArray(:,3)));
    % Max
    max1 = max(round(minMCRArray(:,3)));
    max2 = max(round(maxMCRArray(:,3)));
    
    if min1 < min2
        minSpeed = min1;
    elseif min1 > min2
        minSpeed = min1;
    elseif min1 == min2
        minSpeed = min1;
    end
    
    if max1 < max2
        maxSpeed = max1;
    elseif max1 > max2
        maxSpeed = max2;
    elseif max1 == max2
        maxSpeed = max1;
    end
    
    for ks=minSpeed:1:maxSpeed
        EoFRes1 = minEoF(1)*ks^3+minEoF(2)*ks^2+minEoF(3)*ks+minEoF(4);
        EoFRes2 = maxEoF(1)*ks^3+maxEoF(2)*ks^2+maxEoF(3)*ks+maxEoF(4);
        IntPol(ks,1) = ks;
        IntPol(ks,2) = EoFRes1;
        IntPol(ks,3) = EoFRes2;
        IntPol(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        %disp(sprintf('Min MCR = %s, Max MCR = %s, Int. MCR = %s // Speed = %s, Min = %s, Max = %s, Interpol = %s',num2str(minMCR),num2str(maxMCR),num2str(CalcMCRAArray(k,3)),num2str(ks),num2str(EoFRes1),num2str(EoFRes2),num2str(IntPol(ks,4))));
    end
    
    % Remove zero rows
    IntPol(all(IntPol==0,2),:)=[];
    
    % Equation of fit
    [fitobjectEoFMCR,gofEoFMCR,outputEoFMCR] = fit(IntPol(:,1),IntPol(:,4),'poly3');
    cvaluesEoFMCR                            = coeffvalues(fitobjectEoFMCR);
    
    % Thrust at correct % MCR values
    EoFAtMCR = cvaluesEoFMCR(1)*WSPSpeed(k)^3+cvaluesEoFMCR(2)*WSPSpeed(k)^2+cvaluesEoFMCR(3)*WSPSpeed(k)+cvaluesEoFMCR(4);
    IntPolThrustArray(k,1) = WSPSpeed(k);           % Ship speeds                       (knots)
    IntPolThrustArray(k,2) = EoFAtMCR;              % Single waterjet: Thrust at % MCR  (kN)
    IntPolThrustArray(k,3) = CalcMCRAArray(k,3);    % % MCR                             (%)
    IntPolThrustArray(k,4) = EoFAtMCR*2;            % Single demihull: Thrust at % MCR  (kN)
    IntPolThrustArray(k,5) = EoFAtMCR*4;            % Total catamaran: Thrust at % MCR  (kN)
    
    %# Calculated % MCR Equation of Fit (EoF)
    if enableAdjustedCommandWindow == 1
        cval = cvaluesSingDH;
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
        p1   = sprintf(setDecimals1,cval(1));
        p2   = sprintf(setDecimals2,cval(2));
        p3   = sprintf(setDecimals3,cval(3));
        p4   = sprintf(setDecimals4,cval(4));
        gofrs = sprintf('%0.2f',gofTotCat.rsquare);
        EoFEqn = sprintf('%s%% Thrust Curve Equation of Fit (EoF): y=%sx^3%sx^2%sx%s | R^2: %s',sprintf('%0.1f',CalcMCRAArray(k,3)*100),p1,p2,p3,p4,gofrs);
        disp(EoFEqn);
    end
    
    % Write to EoF array
    EoFTCInterpolArray(k,1) = EoFAtMCR;
    EoFTCInterpolArray(k,2) = cvaluesEoFMCR(1);
    EoFTCInterpolArray(k,3) = cvaluesEoFMCR(2);
    EoFTCInterpolArray(k,4) = cvaluesEoFMCR(3);
    EoFTCInterpolArray(k,5) = cvaluesEoFMCR(4);
    EoFTCInterpolArray(k,6) = gofEoFMCR.rsquare;
    
    % Write to individual array
    if k == 1
        IntPolS1 = IntPol;
    elseif k == 2
        IntPolS2 = IntPol;
    elseif k == 3
        IntPolS3 = IntPol;
    elseif k == 4
        IntPolS4 = IntPol;
    elseif k == 5
        IntPolS5 = IntPol;
    elseif k == 6
        IntPolS6 = IntPol;
    elseif k == 7
        IntPolS7 = IntPol;
    elseif k == 8
        IntPolS8 = IntPol;
    elseif k == 9
        IntPolS9 = IntPol;
    end
    
end % k=1:mfs


% /////////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% -------------------------------------------------------------------------
M  = IntPolThrustArray;
M2 = M(any(M,2),:);                                                       % Remove zero rows
csvwrite('IntPolThrustArray.dat', M2)                                     % Export matrix M to a file delimited by the comma character
%dlmwrite('IntPolThrustArray.txt', M2, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% -------------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# Equation of Fit (EoF) for Interpolated Thrust Curves
%# ************************************************************************
if enableAdjustedCommandWindow == 1
    disp('*****************************************************************************************');
    disp('4. Thrust based on Sea Trials Shaft Power (for results see IntPolThrustArray)');
    disp('*****************************************************************************************');
    [m,n] = size(IntPolThrustArray);
    for k=1:m
        ThrustResults = sprintf('>> Speed %s (%s knots): Thrust = %s kN at %% MCR = %s%%',num2str(k),sprintf('%0.1f',IntPolThrustArray(k,1)),sprintf('%0.1f',IntPolThrustArray(k,2)),sprintf('%0.1f',IntPolThrustArray(k,3)*100));
        disp(ThrustResults);
    end
end % enableAdjustedCommandWindow == 1


%# ************************************************************************
%# Plot 1: Thrust Curve for LJ120E Waterjet Unit (Caterpillar Engines)
%#         100% MCR = 7200kW, transmission losses = 2%
%# ************************************************************************

% Create set of colours (function: distinguishable_colors.m)
% See: http://www.mathworks.com/matlabcentral/fileexchange/29702-generate-maximally-perceptually-distinct-colors?s_eid=PSM_4913
minc = 1;
maxc = 200;
c = distinguishable_colors(maxc,'w');

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 1: Thrust  Curve for LJ120E Waterjet Unit (Caterpillar Engines) 100% MCR = 7200kW, transmission losses = 2%';
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
setLegendFontSize  = 14;

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
% Create 20 random colors based on distinguishable_colors.m
setColor2 = {};
for kt=1:20
    rnr = randi([minc, maxc]);
    setColor2{kt,1} = [c(rnr,1) c(rnr,2) c(rnr,3)];
end
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    setColor2 = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

%# 5% **********************************************************************
x1  = Pct5MCR(:,3);
y1  = Pct5MCR(:,4);

%# 10% ********************************************************************
x2  = Pct10MCR(:,3);
y2  = Pct10MCR(:,4);

%# 15% ********************************************************************
x3  = Pct15MCR(:,3);
y3  = Pct15MCR(:,4);

%# 20% ********************************************************************
x4  = Pct20MCR(:,3);
y4  = Pct20MCR(:,4);

%# 25% ********************************************************************
x5  = Pct25MCR(:,3);
y5  = Pct25MCR(:,4);

%# 30% ********************************************************************
x6  = Pct30MCR(:,3);
y6  = Pct30MCR(:,4);

%# 35% ********************************************************************
x7  = Pct35MCR(:,3);
y7  = Pct35MCR(:,4);

%# 40% ********************************************************************
x8  = Pct40MCR(:,3);
y8  = Pct40MCR(:,4);

%# 45% ********************************************************************
x9  = Pct45MCR(:,3);
y9  = Pct45MCR(:,4);

%# 50% ********************************************************************
x10 = Pct50MCR(:,3);
y10 = Pct50MCR(:,4);

%# 55% ********************************************************************
x11 = Pct55MCR(:,3);
y11 = Pct55MCR(:,4);

%# 60% ********************************************************************
x12 = Pct60MCR(:,3);
y12 = Pct60MCR(:,4);

%# 65% ********************************************************************
x13 = Pct65MCR(:,3);
y13 = Pct65MCR(:,4);

%# 70% ********************************************************************
x14 = Pct70MCR(:,3);
y14 = Pct70MCR(:,4);

%# 75% ********************************************************************
x15 = Pct75MCR(:,3);
y15 = Pct75MCR(:,4);

%# 80% ********************************************************************
x16 = Pct80MCR(:,3);
y16 = Pct80MCR(:,4);

%# 85% ********************************************************************
x17 = Pct85MCR(:,3);
y17 = Pct85MCR(:,4);

%# 90% ********************************************************************
x18 = Pct90MCR(:,3);
y18 = Pct90MCR(:,4);

%# 95% ********************************************************************
x19 = Pct95MCR(:,3);
y19 = Pct95MCR(:,4);

%# 100% *******************************************************************
x20 = Pct100MCR(:,3);
y20 = Pct100MCR(:,4);

%# S/S1=1 *****************************************************************
x21 = SS1(:,3);
y21 = SS1(:,4);

%# Extrapolated Full Scale Data from Model Test ***************************
[m,n] = size(fullscaleresults);

% Sum up port and starboard thrust and convert to kN
PortInkNArray = [];
StbdInkNArray = [];
SingleDHInkNArray = [];
for k=1:m
    PortInkNArray(k)     = fullscaleresults(k,20)/1000;
    StbdInkNArray(k)     = fullscaleresults(k,21)/1000;
    SingleDHInkNArray(k) = (fullscaleresults(k,20)+fullscaleresults(k,21))/1000;
end

xEFS     = fullscaleresults(:,3);
yEFSPort = PortInkNArray;
yEFSStbd = StbdInkNArray;

%# Thrust at power measured at sea trials *********************************

xST = IntPolThrustArray(:,1);
yST = IntPolThrustArray(:,2);

%# Plotting ---------------------------------------------------------------
h = plot(x21,y21,'*',x20,y20,'*',x19,y19,'*',x18,y18,'*',x17,y17,'*',x16,y16,'*',x15,y15,'*',x14,y14,'*',x13,y13,'*',x12,y12,'*',x11,y11,'*',x10,y10,'*',...
    x9,y9,'*',x8,y8,'*',x7,y7,'*',x6,y6,'*',x5,y5,'*',x4,y4,'*',x3,y3,'*',x2,y2,'*',x1,y1,'*');
legendInfo{1}  = 'S/S1=1';
legendInfo{2}  = '100% MCR';
legendInfo{3}  = '95% MCR';
legendInfo{4}  = '90% MCR';
legendInfo{5}  = '85% MCR';
legendInfo{6}  = '80% MCR';
legendInfo{7}  = '75% MCR';
legendInfo{8}  = '70% MCR';
legendInfo{9}  = '65% MCR';
legendInfo{10} = '60% MCR';
legendInfo{11} = '55% MCR';
legendInfo{12} = '50% MCR';
legendInfo{13} = '45% MCR';
legendInfo{14} = '40% MCR';
legendInfo{15} = '35% MCR';
legendInfo{16} = '30% MCR';
legendInfo{17} = '25% MCR';
legendInfo{18} = '20% MCR';
legendInfo{19} = '15% MCR';
legendInfo{20} = '10% MCR';
legendInfo{21} = '5% MCR';
%# Port thrust ------------------------------------------------------------
hold on;
h1 = plot(xEFS,yEFSPort,'*k');
legendInfo{22} = 'Extrapolated Port Thrust';
%# Stbd thrust ------------------------------------------------------------
hold on;
h2 = plot(xEFS,yEFSStbd,'xk');
legendInfo{23} = 'Extrapolated Stbd Thrust';
%# Thrust based on sea trials power ---------------------------------------
hold on;
h3 = plot(xST,yST,'xk');
%# Show MCR lines for % MCR based on sea trials data ----------------------
hold on;
h4 = plot(IntPolS1(:,1),IntPolS1(:,4),'-',IntPolS2(:,1),IntPolS2(:,4),'-',IntPolS3(:,1),IntPolS3(:,4),...
    '-',IntPolS4(:,1),IntPolS4(:,4),'-',IntPolS5(:,1),IntPolS5(:,4),'-',IntPolS6(:,1),IntPolS6(:,4),'-',...
    IntPolS7(:,1),IntPolS7(:,4),'-',IntPolS8(:,1),IntPolS8(:,4),'-',IntPolS9(:,1),IntPolS9(:,4),'-');
legendInfo{24} = 'Sea trials power based thrust';
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust (kN)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Thrust curves and thrust comparison)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
%axis square;

%# Line, colors and markers
set(h(1),'Color',setColor2{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(2),'Color',setColor2{1},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(3),'Color',setColor2{2},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(4),'Color',setColor2{3},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(5),'Color',setColor2{4},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(6),'Color',setColor2{5},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(7),'Color',setColor2{6},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(8),'Color',setColor2{7},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(9),'Color',setColor2{8},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(10),'Color',setColor2{9},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(11),'Color',setColor2{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(12),'Color',setColor2{11},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(13),'Color',setColor2{12},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(14),'Color',setColor2{13},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(15),'Color',setColor2{14},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(16),'Color',setColor2{15},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(17),'Color',setColor2{16},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(18),'Color',setColor2{17},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(19),'Color',setColor2{18},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(20),'Color',setColor2{19},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(21),'Color',setColor2{20},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);

% Extrapolated full scale thrust
set(h1(1),'Color',setColor{10},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(1),'Color',setColor{10},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

% Thrust based on sea trials power
set(h3(1),'Color',setColor{10},'Marker',setMarker{3},'MarkerSize',setMarkerSize+2,'LineWidth',setLineWidthMarker);

%# Show MCR lines for % MCR based on sea trials data
set(h4(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(3),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(4),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(5),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(6),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(7),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(8),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h4(9),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
% Text on plot
text(max(x21)-1,max(y21)+6,'S/S1=1','FontSize',12,'color','k','FontWeight','bold');
text(24.5,max(yST),'Thrust using sea trials shaft power','FontSize',12,'color','k','FontWeight','bold');
text(24.5,max(yEFSPort),'Extrapolated PORT thrust','FontSize',12,'color','k','FontWeight','bold');
text(24.5,max(yEFSStbd),'Extrapolated STBD thrust','FontSize',12,'color','k','FontWeight','bold');
% MCR values
rightAxisText = 45.2;
text(max(Pct5MCR(:,3)),5,'5% MCR','FontSize',12,'color','k','FontWeight','bold');
text(max(Pct10MCR(:,3)),5,'10% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct15MCR(:,4)),'15% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct20MCR(:,4)),'20% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct25MCR(:,4)),'25% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct30MCR(:,4)),'30% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct35MCR(:,4)),'35% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct40MCR(:,4)),'40% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct45MCR(:,4)),'45% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct50MCR(:,4)),'50% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct55MCR(:,4)),'55% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct60MCR(:,4)),'60% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct65MCR(:,4)),'65% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct70MCR(:,4)),'70% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct75MCR(:,4)),'75% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct80MCR(:,4)),'80% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct85MCR(:,4)),'85% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct90MCR(:,4)),'90% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct95MCR(:,4)),'95% MCR','FontSize',12,'color','k','FontWeight','bold');
text(rightAxisText,min(Pct100MCR(:,4)),'100% MCR','FontSize',12,'color','k','FontWeight','bold');
% MCR values based on sea trials power
text(5.5,max(IntPolS1(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(1,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS2(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(2,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS3(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(3,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS4(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(4,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS5(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(5,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS6(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(6,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS7(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(7,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS8(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(8,3)*100)),'FontSize',12,'color','k','FontWeight','bold');
text(5.5,max(IntPolS9(:,4)),sprintf('%s%% MCR',sprintf('%0.1f',IntPolThrustArray(9,3)*100)),'FontSize',12,'color','k','FontWeight','bold');

% %# Axis limitations
minX  = 5;
maxX  = 45;
incrX = 5;
minY  = 0;
maxY  = 300;
incrY = 20;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
% %hleg1 = legend('5%','10%','15%','20%','25%','30%','35%','40%','45%','50%','55%','60%','65%','70%','75%','80%','85%','90%','95%','100%','S/S1');
% hleg1 = legend(legendInfo);
% set(hleg1,'Location','SouthEast');
% %set(hleg1,'Interpreter','none');
% set(hleg1, 'Interpreter','tex');
% set(hleg1,'LineWidth',1);
% set(hleg1,'FontSize',setLegendFontSize);
% %legend boxoff;

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

%# Plot title -------------------------------------------------------------
%if enablePlotMainTitle == 1
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
%end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Thrust_Curve_Showing_ST_Thrust_And_Extrapolated_Thrust_Plot.%s', 'Thrust_Curves', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ************************************************************************
%# Import Resistance Data
%# ************************************************************************

ResFilePath = '..\..\..\2013 August - Resistance test\_Run Files\_Matlab analysis\full_resistance_data.dat';
if exist(ResFilePath, 'file') == 2
    %# Read results file
    results = csvread(ResFilePath);
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('WARNING: Data file for full resistance data (full_resistance_data) does not exist!');
    %break;
end

%# ************************************************************************
%# START Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%#       >> Default variable name: FullScaleRT_ITTC1978_2011_Schuster_TempCorr
%# ------------------------------------------------------------------------
if exist('FullScaleRT_ITTC1978_2011_Schuster_TempCorr.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('FullScaleRT_ITTC1978_2011_Schuster_TempCorr.mat');
    %# Results array columns:
    %[1]  Froude length number                              (-)
    %[2]  Model speed                                       (m/s)
    %[3]  MS Reynolds number                                (-)
    %[4]  MS Total resistance (catamaran), RTm              (N)
    %[5]  MS Total resistance coeff., CTm                   (-)
    %[6]  GRIGSON:  MS Frictional resistance coeff., CFm    (-)
    %[7]  ITTC1957: MS Frictional resistance coeff., CFm    (-)
    %[8]  GRIGSON:  MS Residual resistance coeff., CRm      (-)
    %[9]  ITTC1957: MS Residual resistance coeff., CRm      (-)
    %[10] FS Ship speed                                     (m/s)
    %[11] FS Ship speed                                     (knots)
    %[12] FS Reynolds number                                (-)
    %[13] Roughness allowance, delta CF                     (-)
    %[14] Correlation coeff., Ca                            (-)
    %[15] FS Air resistance coefficient, CAAs               (-)
    %[16] GRIGSON:  FS Total resistance (catamaran), RTs    (N)
    %[17] ITTC1957: FS Total resistance (catamaran), RTs    (N)
    %[18] GRIGSON:  FS Total resistance coeff., CTs         (-)
    %[19] ITTC1957: FS Total resistance coeff., CTs         (-)
    %[20] GRIGSON:  FS Frictional resistance coeff., CFs    (-)
    %[21] ITTC1957: FS Frictional resistance coeff., CFs    (-)
    %[22] GRIGSON:  FS Residual resistance coeff., CRs      (-)
    %[23] ITTC1957: FS Residual resistance coeff., CRs      (-)
    %[24] GRIGSON:  FS Total resistance (catamaran), RTs    (kN)
    %[25] ITTC1957: FS Total resistance (catamaran), RTs    (kN)
    %[26] MS Total resistance (demihull), RTm               (N)
    ResResults = FullScaleRT_ITTC1978_2011_Schuster_TempCorr;
    clearvars FullScaleRT_ITTC1978_2011_Schuster_TempCorr
end
%# ------------------------------------------------------------------------
%# END Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%# ************************************************************************


%# ************************************************************************
%# Plot 2: Thrust and Resistance Comparison Plot
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 2: Thrust and Resistance Comparison Plot';
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
setLegendFontSize  = 14;

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

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Resistance
x1 = ResResults(:,11);
y1 = ResResults(:,24);

% Shorted resistasnce results (i.e. 13-25 knots only)
x1Short = x1(7:19);
y1Short = y1(7:19);

% Resistance fitting
[fitobject,gof,output] = fit(x1Short,y1Short,'poly4');
cvalues                = coeffvalues(fitobject);

% if enableAdjustedCommandWindow == 1
%     cval = cvalues;
%     setDecimals1 = '%0.4f';
%     setDecimals2 = '+%0.4f';
%     setDecimals3 = '+%0.4f';
%     setDecimals4 = '+%0.4f';
%     setDecimals5 = '+%0.4f';
%     if cval(1) < 0
%         setDecimals1 = '%0.4f';
%     end
%     if cval(2) < 0
%         setDecimals2 = '%0.4f';
%     end
%     if cval(3) < 0
%         setDecimals3 = '%0.4f';
%     end
%     if cval(4) < 0
%         setDecimals4 = '%0.4f';
%     end
%     if cval(5) < 0
%         setDecimals5 = '%0.4f';
%     end
%     p1   = sprintf(setDecimals1,cval(1));
%     p2   = sprintf(setDecimals2,cval(2));
%     p3   = sprintf(setDecimals3,cval(3));
%     p4   = sprintf(setDecimals4,cval(4));
%     p5   = sprintf(setDecimals5,cval(5));
%     gofrs = sprintf('%0.2f',gofTotCat.rsquare);
%     EoFEqn = sprintf('>> Resistance Equation of Fit (EoF): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
%     disp(EoFEqn);
% end

[m,n] = size(IntPolThrustArray(:,1));
for k=1:m
    FittedResistance(k,1) = IntPolThrustArray(k,1);
    FittedResistance(k,2) = cvalues(1)*IntPolThrustArray(k,1)^4+cvalues(2)*IntPolThrustArray(k,1)^3+cvalues(3)*IntPolThrustArray(k,1)^2+cvalues(4)*IntPolThrustArray(k,1)+cvalues(5);
end

% Fitted data
x1 = FittedResistance(:,1);
y1 = FittedResistance(:,2);

% Thrust based on sea trials power
x2 = IntPolThrustArray(:,1);
y2 = IntPolThrustArray(:,5);

% Extrapolated thrust from model tests
TotalCatamaranThrustArray = [];
for k=1:m
    TotalCatamaranThrustArray(k) = ((fullscaleresults(k,20)+fullscaleresults(k,21))/1000)*2;
end

x3 = fullscaleresults(:,3);
y3 = TotalCatamaranThrustArray;

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-',x3,y3,'*-');
% Equations of fit
%hold on;
%h1 = plot(fitobject,'-k',x1Short,y1Short,'dk');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust and resistance (kN)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Thrust and resistance comparison)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
%set(h(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle1,'linewidth',setLineWidth);
%set(h(3),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
%set(h(1),'Color',setColor{10},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidth);
set(h(2),'Color',setColor{10},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h(3),'Color',setColor{10},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle3,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 800;
incrY = 100;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend('Extrapolated resistance from model test, R_{TBH}','Thrust based on sea trials power, T_{SeaTrials}','Extrapolated thrust from model tests, T_{Extrapolated}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
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
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
%if enablePlotMainTitle == 1
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
%end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/Plot_2_Thrust_And_Resistance_Comparison_Plot.%s', 'Thrust_Curves', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# Differences is extrapolated thrust and thrust based on ST power
%# ************************************************************************
if enableAdjustedCommandWindow == 1
    disp('*****************************************************************************************');
    disp('5. Differences of extrapolated thrust and thrust based on ST power');
    disp('*****************************************************************************************');
    [m,n] = size(IntPolThrustArray);
    for k=1:m
        DiffInPercent = (1-(TotalCatamaranThrustArray(k)/IntPolThrustArray(k,5)))*100;
        var1 = num2str(k);
        var2 = sprintf('%0.1f',IntPolThrustArray(k,1));
        var3 = sprintf('%0.1f',IntPolThrustArray(k,5));
        var4 = sprintf('%0.1f',TotalCatamaranThrustArray(k));
        var5 = sprintf('%0.1f',DiffInPercent);
        ThrustResults = sprintf('>> Speed %s (%s knots): Thrust based on ST power = %s kN, extrapolated thrust = %s kN, difference = %s%%',var1,var2,var3,var4,var5);
        disp(ThrustResults);
    end
    disp('*****************************************************************************************');
    disp('6. Differences of resistance and thrust based on ST power');
    disp('*****************************************************************************************');    
    for k=1:m
        DiffInPercent = (1-(FittedResistance(k,2)/IntPolThrustArray(k,5)))*100;
        var1 = num2str(k);
        var2 = sprintf('%0.1f',IntPolThrustArray(k,1));
        var3 = sprintf('%0.1f',FittedResistance(k,2));
        var4 = sprintf('%0.1f',IntPolThrustArray(k,5));
        var5 = sprintf('%0.1f',DiffInPercent);
        ThrustResults = sprintf('>> Speed %s (%s knots): Resistance = %s kN, thrust based on ST power = %s kN, difference = %s%%',var1,var2,var3,var4,var5);
        disp(ThrustResults);
    end    
end % enableAdjustedCommandWindow == 1


%# ************************************************************************
%# Clear Variables
%# ************************************************************************
clearvars allPlots fPath ind mtb ntb runfilespath setDirName testName toolboxes v
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
