%# ------------------------------------------------------------------------
%# Self-Propulsion: Thrust Curves
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  January 26, 2015
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
enableBlackAndWhitePlot     = 0;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot       = 1;    % Show plots scale to A4 size

% Command window output
enableAdjustedCommandWindow = 0;    % Show command window output

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

[fitobject1,gof1,output1]    = fit(Pct5MCR(:,3),Pct5MCR(:,4),'poly4');
cvalues5                     = coeffvalues(fitobject1);

if enableAdjustedCommandWindow == 1
    cval = cvalues5;
    gof  = gof1;
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
    gofrs = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('5 Percent Curve: y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
    disp(EoFEqn);
end

[fitobject2,gof2,output2]    = fit(Pct10MCR(:,3),Pct10MCR(:,4),'poly4');
cvalues10                    = coeffvalues(fitobject2);

[fitobject3,gof3,output3]    = fit(Pct15MCR(:,3),Pct15MCR(:,4),'poly4');
cvalues15                    = coeffvalues(fitobject3);

[fitobject4,gof4,output4]    = fit(Pct20MCR(:,3),Pct20MCR(:,4),'poly4');
cvalues20                    = coeffvalues(fitobject4);

[fitobject5,gof5,output5]    = fit(Pct25MCR(:,3),Pct25MCR(:,4),'poly4');
cvalues25                    = coeffvalues(fitobject5);

[fitobject6,gof6,output6]    = fit(Pct30MCR(:,3),Pct30MCR(:,4),'poly4');
cvalues30                    = coeffvalues(fitobject6);

[fitobject7,gof7,output7]    = fit(Pct35MCR(:,3),Pct35MCR(:,4),'poly4');
cvalues35                    = coeffvalues(fitobject7);

if enableAdjustedCommandWindow == 1
    cval = cvalues35;
    gof  = gof7;
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
    gofrs = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('35 Percent Curve: y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
    disp(EoFEqn);
end

[fitobject8,gof8,output8]    = fit(Pct40MCR(:,3),Pct40MCR(:,4),'poly4');
cvalues40                    = coeffvalues(fitobject8);

if enableAdjustedCommandWindow == 1
    cval = cvalues40;
    gof  = gof8;
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
    gofrs = sprintf('%0.2f',gof.rsquare);
    EoFEqn = sprintf('40 Percent Curve: y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
    disp(EoFEqn);
end

[fitobject9,gof9,output9]    = fit(Pct45MCR(:,3),Pct45MCR(:,4),'poly4');
cvalues45                    = coeffvalues(fitobject9);

[fitobject10,gof10,output10] = fit(Pct50MCR(:,3),Pct50MCR(:,4),'poly4');
cvalues50                    = coeffvalues(fitobject10);

[fitobject11,gof11,output11] = fit(Pct55MCR(:,3),Pct55MCR(:,4),'poly4');
cvalues55                    = coeffvalues(fitobject11);

[fitobject12,gof12,output12] = fit(Pct60MCR(:,3),Pct60MCR(:,4),'poly4');
cvalues60                    = coeffvalues(fitobject12);

[fitobject13,gof13,output13] = fit(Pct65MCR(:,3),Pct65MCR(:,4),'poly4');
cvalues65                    = coeffvalues(fitobject13);

[fitobject14,gof14,output14] = fit(Pct70MCR(:,3),Pct70MCR(:,4),'poly4');
cvalues70                    = coeffvalues(fitobject14);

[fitobject15,gof15,output15] = fit(Pct75MCR(:,3),Pct75MCR(:,4),'poly4');
cvalues75                    = coeffvalues(fitobject15);

[fitobject16,gof16,output16] = fit(Pct80MCR(:,3),Pct80MCR(:,4),'poly4');
cvalues80                    = coeffvalues(fitobject16);

[fitobject17,gof17,output17] = fit(Pct85MCR(:,3),Pct85MCR(:,4),'poly4');
cvalues85                    = coeffvalues(fitobject17);

[fitobject18,gof18,output18] = fit(Pct90MCR(:,3),Pct90MCR(:,4),'poly4');
cvalues90                    = coeffvalues(fitobject18);

[fitobject19,gof19,output19] = fit(Pct95MCR(:,3),Pct95MCR(:,4),'poly4');
cvalues95                    = coeffvalues(fitobject19);

[fitobject20,gof20,output20] = fit(Pct100MCR(:,3),Pct100MCR(:,4),'poly4');
cvalues100                   = coeffvalues(fitobject20);

% Root square values
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

% Total catamaran (knots and MW)
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
    EoFEqn = sprintf('Corrected ST power, EoF for total catamaran: y=%sx^5%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,p6,gofrs);
    disp(EoFEqn);
end

% Single demihull (knots and MW)
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
    EoFEqn = sprintf('Corrected ST power, EoF for single demihull: y=%sx^5%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,p6,gofrs);
    disp(EoFEqn);
end

% Single waterjet (knots and MW)
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
    EoFEqn = sprintf('Corrected ST power, EoF for single waterjet: y=%sx^5%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,p6,gofrs);
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
clearvars EoF

%# 3. Interpol. thrust curve data for % MCR values (see CalcMCRAArray) ----

IPolSpeeds = 5:1:45;
[mips,nips] = size(IPolSpeeds);

IntPolS1 = [];
IntPolS2 = [];
IntPolS3 = [];
IntPolS4 = [];
IntPolS5 = [];
IntPolS6 = [];
IntPolS7 = [];
IntPolS8 = [];
IntPolS9 = [];

IntPolThrust = [];

% Loop through speeds
for k=1:mfs
    if CalcMCRAArray(k,3) > 0.05 && CalcMCRAArray(k,3) < 0.1
        disp(sprintf('Speed %s: 5 > MCR < 10, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.05;
        maxMCR      = 0.10;
        minEoF      = cvalues5;
        maxEoF      = cvalues10;
        minMCRArray = Pct5MCR;
        maxMCRArray = Pct10MCR;
    elseif CalcMCRAArray(k,3) > 0.1 && CalcMCRAArray(k,3) < 0.15
        disp(sprintf('Speed %s: 10 > MCR < 15, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.1;
        maxMCR      = 0.15;
        minEoF      = cvalues10;
        maxEoF      = cvalues15;
        minMCRArray = Pct10MCR;
        maxMCRArray = Pct15MCR;
    elseif CalcMCRAArray(k,3) > 0.15 && CalcMCRAArray(k,3) < 0.20
        disp(sprintf('Speed %s: 15 > MCR < 20, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.15;
        maxMCR      = 0.20;
        minEoF      = cvalues15;
        maxEoF      = cvalues20;
        minMCRArray = Pct15MCR;
        maxMCRArray = Pct20MCR;
    elseif CalcMCRAArray(k,3) > 0.2 && CalcMCRAArray(k,3) < 0.25
        disp(sprintf('Speed %s: 20 > MCR < 25, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.2;
        maxMCR      = 0.25;
        minEoF      = cvalues20;
        maxEoF      = cvalues25;
        minMCRArray = Pct20MCR;
        maxMCRArray = Pct25MCR;
    elseif CalcMCRAArray(k,3) > 0.25 && CalcMCRAArray(k,3) < 0.30
        disp(sprintf('Speed %s: 25 > MCR < 30, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.25;
        maxMCR      = 0.3;
        minEoF      = cvalues25;
        maxEoF      = cvalues30;
        minMCRArray = Pct25MCR;
        maxMCRArray = Pct30MCR;
    elseif CalcMCRAArray(k,3) > 0.3 && CalcMCRAArray(k,3) < 0.35
        disp(sprintf('Speed %s: 30 > MCR < 35, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.3;
        maxMCR      = 0.35;
        minEoF      = cvalues30;
        maxEoF      = cvalues35;
        minMCRArray = Pct30MCR;
        maxMCRArray = Pct35MCR;
    elseif CalcMCRAArray(k,3) > 0.35 && CalcMCRAArray(k,3) < 0.40
        disp(sprintf('Speed %s: 35 > MCR < 40, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.35;
        maxMCR      = 0.40;
        minEoF      = cvalues35;
        maxEoF      = cvalues40;
        minMCRArray = Pct35MCR;
        maxMCRArray = Pct40MCR;
    elseif CalcMCRAArray(k,3) > 0.4 && CalcMCRAArray(k,3) < 0.45
        disp(sprintf('Speed %s: 40 > MCR < 45, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.4;
        maxMCR      = 0.45;
        minEoF      = cvalues40;
        maxEoF      = cvalues45;
        minMCRArray = Pct40MCR;
        maxMCRArray = Pct45MCR;
    elseif CalcMCRAArray(k,3) > 0.45 && CalcMCRAArray(k,3) < 0.5
        disp(sprintf('Speed %s: 45 > MCR < 50, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.45;
        maxMCR      = 0.5;
        minEoF      = cvalues45;
        maxEoF      = cvalues50;
        minMCRArray = Pct45MCR;
        maxMCRArray = Pct50MCR;
    elseif CalcMCRAArray(k,3) > 0.5 && CalcMCRAArray(k,3) < 0.55
        disp(sprintf('Speed %s: 50 > MCR < 55, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.5;
        maxMCR      = 0.55;
        minEoF      = cvalues50;
        maxEoF      = cvalues55;
        minMCRArray = Pct50MCR;
        maxMCRArray = Pct55MCR;
    elseif CalcMCRAArray(k,3) > 0.55 && CalcMCRAArray(k,3) < 0.6
        disp(sprintf('Speed %s: 55 > MCR < 60, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.55;
        maxMCR      = 0.60;
        minEoF      = cvalues55;
        maxEoF      = cvalues60;
        minMCRArray = Pct55MCR;
        maxMCRArray = Pct60MCR;
    elseif CalcMCRAArray(k,3) > 0.6 && CalcMCRAArray(k,3) < 0.65
        disp(sprintf('Speed %s: 60 > MCR < 65, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.6;
        maxMCR      = 0.65;
        minEoF      = cvalues60;
        maxEoF      = cvalues65;
        minMCRArray = Pct60MCR;
        maxMCRArray = Pct65MCR;
    elseif CalcMCRAArray(k,3) > 0.65 && CalcMCRAArray(k,3) < 0.70
        disp(sprintf('Speed %s: 65 > MCR < 70, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.65;
        maxMCR      = 0.70;
        minEoF      = cvalues65;
        maxEoF      = cvalues70;
        minMCRArray = Pct65MCR;
        maxMCRArray = Pct7-MCR;
    elseif CalcMCRAArray(k,3) > 0.7 && CalcMCRAArray(k,3) < 0.75
        disp(sprintf('Speed %s: 70 > MCR < 75, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.7;
        maxMCR      = 0.75;
        minEoF      = cvalues70;
        maxEoF      = cvalues75;
        minMCRArray = Pct70MCR;
        maxMCRArray = Pct75MCR;
    elseif CalcMCRAArray(k,3) > 0.75 && CalcMCRAArray(k,3) < 0.8
        disp(sprintf('Speed %s: 75 > MCR < 80, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.75;
        maxMCR      = 0.80;
        minEoF      = cvalues75;
        maxEoF      = cvalues80;
        minMCRArray = Pct75MCR;
        maxMCRArray = Pct80MCR;
    elseif CalcMCRAArray(k,3) > 0.8 && CalcMCRAArray(k,3) < 0.85
        disp(sprintf('Speed %s: 80 > MCR < 85, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.8;
        maxMCR      = 0.85;
        minEoF      = cvalues80;
        maxEoF      = cvalues85;
        minMCRArray = Pct80MCR;
        maxMCRArray = Pct85MCR;
    elseif CalcMCRAArray(k,3) > 0.85 && CalcMCRAArray(k,3) < 0.9
        disp(sprintf('Speed %s: 85 > MCR < 90, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.85;
        maxMCR      = 0.90;
        minEoF      = cvalues85;
        maxEoF      = cvalues90;
        minMCRArray = Pct85MCR;
        maxMCRArray = Pct90MCR;
    elseif CalcMCRAArray(k,3) > 0.90 && CalcMCRAArray(k,3) < 0.95
        disp(sprintf('Speed %s: 90 > MCR < 95, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.9;
        maxMCR      = 0.95;
        minEoF      = cvalues90;
        maxEoF      = cvalues95;
        minMCRArray = Pct90MCR;
        maxMCRArray = Pct95MCR;
    elseif CalcMCRAArray(k,3) > 0.95 && CalcMCRAArray(k,3) < 1
        disp(sprintf('Speed %s: 95 > MCR < 100, Act. MCR = %s',num2str(k),num2str(CalcMCRAArray(k,3)*100)));
        minMCR      = 0.95;
        maxMCR      = 1;
        minEoF      = cvalues95;
        maxEoF      = cvalues100;
        minMCRArray = Pct95MCR;
        maxMCRArray = Pct100MCR;
    end
    
    if k == 1
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS1(ks,1) = ks;
            IntPolS1(ks,2) = EoFRes1;
            IntPolS1(ks,3) = EoFRes2;
            IntPolS1(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS1(all(IntPolS1==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR1,gofEoFMCR1,outputEoFMCR1] = fit(IntPolS1(:,1),IntPolS1(:,4),'poly3');
        cvaluesEoFMCR1                              = coeffvalues(fitobjectEoFMCR1);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR1(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR1(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR1(3)*WSPSpeed(mfs)+cvaluesEoFMCR1(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;
    elseif k == 2
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS2(ks,1) = ks;
            IntPolS2(ks,2) = EoFRes1;
            IntPolS2(ks,3) = EoFRes2;
            IntPolS2(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS2(all(IntPolS2==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR2,gofEoFMCR2,outputEoFMCR2] = fit(IntPolS2(:,1),IntPolS2(:,4),'poly3');
        cvaluesEoFMCR2                              = coeffvalues(fitobjectEoFMCR2);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR2(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR2(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR2(3)*WSPSpeed(mfs)+cvaluesEoFMCR2(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;        
    elseif k == 3
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS3(ks,1) = ks;
            IntPolS3(ks,2) = EoFRes1;
            IntPolS3(ks,3) = EoFRes2;
            IntPolS3(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS3(all(IntPolS3==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR3,gofEoFMCR3,outputEoFMCR3] = fit(IntPolS3(:,1),IntPolS3(:,4),'poly3');
        cvaluesEoFMCR3                              = coeffvalues(fitobjectEoFMCR3);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR3(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR3(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR3(3)*WSPSpeed(mfs)+cvaluesEoFMCR3(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;          
    elseif k == 4
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS4(ks,1) = ks;
            IntPolS4(ks,2) = EoFRes1;
            IntPolS4(ks,3) = EoFRes2;
            IntPolS4(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS4(all(IntPolS4==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR4,gofEoFMCR4,outputEoFMCR4] = fit(IntPolS4(:,1),IntPolS4(:,4),'poly3');
        cvaluesEoFMCR4                              = coeffvalues(fitobjectEoFMCR4);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR4(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR4(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR4(3)*WSPSpeed(mfs)+cvaluesEoFMCR4(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;            
    elseif k == 5
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS5(ks,1) = ks;
            IntPolS5(ks,2) = EoFRes1;
            IntPolS5(ks,3) = EoFRes2;
            IntPolS5(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS5(all(IntPolS5==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR5,gofEoFMCR5,outputEoFMCR5] = fit(IntPolS5(:,1),IntPolS5(:,4),'poly3');
        cvaluesEoFMCR5                              = coeffvalues(fitobjectEoFMCR5);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR5(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR5(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR5(3)*WSPSpeed(mfs)+cvaluesEoFMCR5(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;          
    elseif k == 6
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS6(ks,1) = ks;
            IntPolS6(ks,2) = EoFRes1;
            IntPolS6(ks,3) = EoFRes2;
            IntPolS6(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS6(all(IntPolS6==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR6,gofEoFMCR6,outputEoFMCR6] = fit(IntPolS6(:,1),IntPolS6(:,4),'poly3');
        cvaluesEoFMCR6                              = coeffvalues(fitobjectEoFMCR6);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR6(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR6(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR6(3)*WSPSpeed(mfs)+cvaluesEoFMCR6(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;            
    elseif k == 7
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS7(ks,1) = ks;
            IntPolS7(ks,2) = EoFRes1;
            IntPolS7(ks,3) = EoFRes2;
            IntPolS7(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS7(all(IntPolS7==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR7,gofEoFMCR7,outputEoFMCR7] = fit(IntPolS7(:,1),IntPolS7(:,4),'poly3');
        cvaluesEoFMCR7                              = coeffvalues(fitobjectEoFMCR7);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR7(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR7(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR7(3)*WSPSpeed(mfs)+cvaluesEoFMCR7(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;            
    elseif k == 8
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS8(ks,1) = ks;
            IntPolS8(ks,2) = EoFRes1;
            IntPolS8(ks,3) = EoFRes2;
            IntPolS8(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS8(all(IntPolS8==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR8,gofEoFMCR8,outputEoFMCR8] = fit(IntPolS8(:,1),IntPolS8(:,4),'poly3');
        cvaluesEoFMCR8                              = coeffvalues(fitobjectEoFMCR8);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR8(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR8(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR8(3)*WSPSpeed(mfs)+cvaluesEoFMCR8(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;           
    elseif k == 9
        % Min
        min1 = min(round(minMCRArray(:,3)));
        min2 = min(round(maxMCRArray(:,3)));
        % Max
        max1 = max(round(minMCRArray(:,3)));
        max2 = max(round(maxMCRArray(:,3)));
        
        if min1 < min2
            minSpeed = 1;
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
            EoFRes1 = minEoF(1)*ks^4+minEoF(2)*ks^3+minEoF(3)*ks^2+minEoF(4)*ks+minEoF(5);
            EoFRes2 = maxEoF(1)*ks^4+maxEoF(2)*ks^3+maxEoF(3)*ks^2+maxEoF(4)*ks+maxEoF(5);
            IntPolS9(ks,1) = ks;
            IntPolS9(ks,2) = EoFRes1;
            IntPolS9(ks,3) = EoFRes2;
            IntPolS9(ks,4) = ((CalcMCRAArray(k,3)-minMCR)/(maxMCR-minMCR))*(EoFRes2-EoFRes1)+EoFRes1;
        end
        
        % Remove zero rows
        IntPolS9(all(IntPolS9==0,2),:)=[];
        
        % Equation of fit
        [fitobjectEoFMCR9,gofEoFMCR9,outputEoFMCR9] = fit(IntPolS9(:,1),IntPolS9(:,4),'poly3');
        cvaluesEoFMCR9                              = coeffvalues(fitobjectEoFMCR9);
        
        % Thrust at correct % MCR values
        EoFAtMCR = cvaluesEoFMCR9(1)*WSPSpeed(mfs)^3+cvaluesEoFMCR9(2)*WSPSpeed(mfs)^2+cvaluesEoFMCR9(3)*WSPSpeed(mfs)+cvaluesEoFMCR9(4);
        IntPolThrust(k,1) = WSPSpeed(k);
        IntPolThrust(k,2) = EoFAtMCR;          
    end % k == 1
    
end

%# ************************************************************************
%# Plot 1: Thrust curves and estimated thrust
%# ************************************************************************

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 1: Thrust curves and estimated thrust';
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
setMarkerSize      = 11;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

%# 1 **********************************************************************
x1  = Pct5MCR(:,3);
y1  = Pct5MCR(:,4);

%# 2 **********************************************************************
x2  = Pct10MCR(:,3);
y2  = Pct10MCR(:,4);

%# 3 **********************************************************************
x3  = Pct15MCR(:,3);
y3  = Pct15MCR(:,4);

%# 4 **********************************************************************
x4  = Pct20MCR(:,3);
y4  = Pct20MCR(:,4);

%# 5 **********************************************************************
x5  = Pct25MCR(:,3);
y5  = Pct25MCR(:,4);

%# 6 **********************************************************************
x6  = Pct30MCR(:,3);
y6  = Pct30MCR(:,4);

%# 7 **********************************************************************
x7  = Pct35MCR(:,3);
y7  = Pct35MCR(:,4);

%# 8 **********************************************************************
x8  = Pct40MCR(:,3);
y8  = Pct40MCR(:,4);

%# 9 **********************************************************************
x9  = Pct45MCR(:,3);
y9  = Pct45MCR(:,4);

%# 10 *********************************************************************
x10 = Pct50MCR(:,3);
y10 = Pct50MCR(:,4);

%# 11 *********************************************************************
x11 = Pct55MCR(:,3);
y11 = Pct55MCR(:,4);

%# 12 *********************************************************************
x12 = Pct60MCR(:,3);
y12 = Pct60MCR(:,4);

%# 13 *********************************************************************
x13 = Pct65MCR(:,3);
y13 = Pct65MCR(:,4);

%# 14 *********************************************************************
x14 = Pct70MCR(:,3);
y14 = Pct70MCR(:,4);

%# 15 *********************************************************************
x15 = Pct75MCR(:,3);
y15 = Pct75MCR(:,4);

%# 16 *********************************************************************
x16 = Pct80MCR(:,3);
y16 = Pct80MCR(:,4);

%# 17 *********************************************************************
x17 = Pct85MCR(:,3);
y17 = Pct85MCR(:,4);

%# 18 *********************************************************************
x18 = Pct90MCR(:,3);
y18 = Pct90MCR(:,4);

%# 19 *********************************************************************
x19 = Pct95MCR(:,3);
y19 = Pct95MCR(:,4);

%# 20 *********************************************************************
x20 = Pct100MCR(:,3);
y20 = Pct100MCR(:,4);

%# 21 *********************************************************************
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

%# Thrust at power measured at sea trials ***************************

xST = IntPolThrust(:,1);
yST = IntPolThrust(:,2);

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
hold on;
h1 = plot(xEFS,yEFSPort,'*k');
legendInfo{22} = 'Extr. Port Thrust';
hold on;
h2 = plot(xEFS,yEFSStbd,'xk');
legendInfo{23} = 'Extr. Stbd Thrust';
hold on;
h3 = plot(xST,yST,'xk');
legendInfo{24} = 'Using sea trials power';
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust (kN)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Thrust curves and thrust comparison)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
%axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(3),'Color',setColor{9},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(4),'Color',setColor{8},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(5),'Color',setColor{7},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(6),'Color',setColor{6},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(7),'Color',setColor{5},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(8),'Color',setColor{4},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(9),'Color',setColor{3},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(10),'Color',setColor{2},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(11),'Color',setColor{1},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(12),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(13),'Color',setColor{9},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(14),'Color',setColor{8},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(15),'Color',setColor{7},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(16),'Color',setColor{6},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(17),'Color',setColor{5},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(18),'Color',setColor{4},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(19),'Color',setColor{3},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(20),'Color',setColor{2},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(21),'Color',setColor{1},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);
% Extrapolated full scale thrust
set(h1(1),'Color',setColor{10},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(1),'Color',setColor{10},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% Uisng sea trials power
set(h3(1),'Color',setColor{10},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%set(h(3),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

% %# Axis limitations
minX  = 5;
maxX  = 45;
incrX = 5;
minY  = 0;
maxY  = 300;
incrY = 50;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
%hleg1 = legend('5%','10%','15%','20%','25%','30%','35%','40%','45%','50%','55%','60%','65%','70%','75%','80%','85%','90%','95%','100%','S/S1');
hleg1 = legend(legendInfo);
set(hleg1,'Location','SouthEast');
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
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_11_FS_Resistance_vs_Extrapolated_Thrust_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ************************************************************************
%# Clear Variables
%# ************************************************************************
clearvars allPlots fPath ind mtb ntb runfilespath setDirName testName toolboxes v
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize
