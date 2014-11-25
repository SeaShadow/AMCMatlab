%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis: Result Comparison (dfferent wake fractions)
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 25, 2014
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
%# CHANGES    :  16/11/2014 - Created new script
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

% Profiler
enableProfiler              = 0;    % Use profiler to show execution times

% Plot titles, colours, etc.
enablePlotMainTitle         = 1;    % Show plot title in saved file
enablePlotTitle             = 1;    % Show plot title above plot
enableBlackAndWhitePlot     = 1;    % Show plot in black and white only

% Scaled to A4 paper
enableA4PaperSizePlot       = 1;    % Show plots scale to A4 size

% Enable individual plots
enableNumber1Plot           = 0;    % PD and OPE for Ca=0
enableNumber2Plot           = 0;    % PD and OPE for Ca=0.00035
enableNumber3Plot           = 0;    % PD and OPE for Ca=0.00059
enableNumber4Plot           = 1;    % PD and OPE using ws=wm(CFs/CFm) only
enableNumber5Plot           = 1;    % PD and OPE using ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)
enableNumber6Plot           = 0;    % Thrust deduction using Ca=0
enableNumber7Plot           = 0;    % Barplot showing Differences in results when
                                    % using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)
enableNumber8Plot           = 0;    % Wake fraction comparison
enableNumber9Plot           = 0;    % Corrected sea trials data (delivered power)

% Enable distinction between adjuste and not adjusted F vs. curves
enableAdjOrNotAdjCurvesPlot = 0;    % If enabled show BOTH adjust and not adjusted graphs
                                    % If disabled show adjusted graph only!

% Enable curves for delivered power (PD) using WJ benchmark data
enableWJBMDelPowerOPEPlot   = 0;    % Show delivered power calculated using WJBM data
                                    
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

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile on
end


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
%# START Load MARIN Data (variable name is Marin112mJHSVData by default)
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
    %[6]  Thrust deduction factor, (1-t) (-)
    
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
%# END Load MARIN Data (variable name is Marin112mJHSVData by default)
%# ************************************************************************


%# ************************************************************************
%# START Full scale results
%# ------------------------------------------------------------------------
% CONDITION 1
fsFilename = '_result_comparison_data/Cond_1/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond1 = csvread(fsFilename);
    fsrCond1(all(fsrCond1==0,2),:)=[];
else
    disp('WARNING: File Cond_1/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 2
fsFilename = '_result_comparison_data/Cond_2/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond2 = csvread(fsFilename);
    fsrCond2(all(fsrCond2==0,2),:)=[];
else
    disp('WARNING: File Cond_2/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 3
fsFilename = '_result_comparison_data/Cond_3/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond3 = csvread(fsFilename);
    fsrCond3(all(fsrCond3==0,2),:)=[];
else
    disp('WARNING: File Cond_3/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 4
fsFilename = '_result_comparison_data/Cond_4/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond4 = csvread(fsFilename);
    fsrCond4(all(fsrCond4==0,2),:)=[];
else
    disp('WARNING: File Cond_4/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 5
fsFilename = '_result_comparison_data/Cond_5/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond5 = csvread(fsFilename);
    fsrCond5(all(fsrCond5==0,2),:)=[];
else
    disp('WARNING: File Cond_5/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 6
fsFilename = '_result_comparison_data/Cond_6/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond6 = csvread(fsFilename);
    fsrCond6(all(fsrCond6==0,2),:)=[];
else
    disp('WARNING: File Cond_6/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 7
fsFilename = '_result_comparison_data/Cond_7/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond7 = csvread(fsFilename);
    fsrCond7(all(fsrCond7==0,2),:)=[];
else
    disp('WARNING: File Cond_7/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 8
fsFilename = '_result_comparison_data/Cond_8/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond8 = csvread(fsFilename);
    fsrCond8(all(fsrCond8==0,2),:)=[];
else
    disp('WARNING: File Cond_8/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 9
fsFilename = '_result_comparison_data/Cond_9/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond9 = csvread(fsFilename);
    fsrCond9(all(fsrCond9==0,2),:)=[];
else
    disp('WARNING: File Cond_9/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 10
fsFilename = '_result_comparison_data/Cond_10/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond10 = csvread(fsFilename);
    fsrCond10(all(fsrCond10==0,2),:)=[];
else
    disp('WARNING: File Cond_10/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 11
fsFilename = '_result_comparison_data/Cond_11/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond11 = csvread(fsFilename);
    fsrCond11(all(fsrCond11==0,2),:)=[];
else
    disp('WARNING: File Cond_11/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 12
fsFilename = '_result_comparison_data/Cond_12/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond12 = csvread(fsFilename);
    fsrCond12(all(fsrCond12==0,2),:)=[];
else
    disp('WARNING: File Cond_12/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 13
fsFilename = '_result_comparison_data/Cond_13/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond13 = csvread(fsFilename);
    fsrCond13(all(fsrCond13==0,2),:)=[];
else
    disp('WARNING: File Cond_13/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 14
fsFilename = '_result_comparison_data/Cond_14/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond14 = csvread(fsFilename);
    fsrCond14(all(fsrCond14==0,2),:)=[];
else
    disp('WARNING: File Cond_14/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 15
fsFilename = '_result_comparison_data/Cond_15/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond15 = csvread(fsFilename);
    fsrCond15(all(fsrCond15==0,2),:)=[];
else
    disp('WARNING: File Cond_15/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 16
fsFilename = '_result_comparison_data/Cond_16/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond16 = csvread(fsFilename);
    fsrCond16(all(fsrCond16==0,2),:)=[];
else
    disp('WARNING: File Cond_16/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 17
fsFilename = '_result_comparison_data/Cond_17/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond17 = csvread(fsFilename);
    fsrCond17(all(fsrCond17==0,2),:)=[];
else
    disp('WARNING: File Cond_17/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 18
fsFilename = '_result_comparison_data/Cond_18/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond18 = csvread(fsFilename);
    fsrCond18(all(fsrCond18==0,2),:)=[];
else
    disp('WARNING: File Cond_18/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 19
fsFilename = '_result_comparison_data/Cond_19/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond19 = csvread(fsFilename);
    fsrCond19(all(fsrCond19==0,2),:)=[];
else
    disp('WARNING: File Cond_19/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 20
fsFilename = '_result_comparison_data/Cond_20/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond20 = csvread(fsFilename);
    fsrCond20(all(fsrCond20==0,2),:)=[];
else
    disp('WARNING: File Cond_20/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 21
fsFilename = '_result_comparison_data/Cond_21/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond21 = csvread(fsFilename);
    fsrCond21(all(fsrCond21==0,2),:)=[];
else
    disp('WARNING: File Cond_21/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 22
fsFilename = '_result_comparison_data/Cond_22/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond22 = csvread(fsFilename);
    fsrCond22(all(fsrCond22==0,2),:)=[];
else
    disp('WARNING: File Cond_22/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 23
fsFilename = '_result_comparison_data/Cond_23/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond23 = csvread(fsFilename);
    fsrCond23(all(fsrCond23==0,2),:)=[];
else
    disp('WARNING: File Cond_23/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 24
fsFilename = '_result_comparison_data/Cond_24/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond24 = csvread(fsFilename);
    fsrCond24(all(fsrCond24==0,2),:)=[];
else
    disp('WARNING: File Cond_24/fullScaleDataArray.dat does not exist!');
    break;
end

%# Conditions added 21/11/2014 (using WJ benchmark data): -----------------

% CONDITION 25
fsFilename = '_result_comparison_data/Cond_25/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond25 = csvread(fsFilename);
    fsrCond25(all(fsrCond25==0,2),:)=[];
else
    disp('WARNING: File Cond_25/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 26
fsFilename = '_result_comparison_data/Cond_26/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond26 = csvread(fsFilename);
    fsrCond26(all(fsrCond26==0,2),:)=[];
else
    disp('WARNING: File Cond_26/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 27
fsFilename = '_result_comparison_data/Cond_27/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond27 = csvread(fsFilename);
    fsrCond27(all(fsrCond27==0,2),:)=[];
else
    disp('WARNING: File Cond_27/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 28
fsFilename = '_result_comparison_data/Cond_28/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond28 = csvread(fsFilename);
    fsrCond28(all(fsrCond28==0,2),:)=[];
else
    disp('WARNING: File Cond_28/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 29
fsFilename = '_result_comparison_data/Cond_29/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond29 = csvread(fsFilename);
    fsrCond29(all(fsrCond29==0,2),:)=[];
else
    disp('WARNING: File Cond_29/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 30
fsFilename = '_result_comparison_data/Cond_30/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond30 = csvread(fsFilename);
    fsrCond30(all(fsrCond30==0,2),:)=[];
else
    disp('WARNING: File Cond_30/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 31
fsFilename = '_result_comparison_data/Cond_31/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond31 = csvread(fsFilename);
    fsrCond31(all(fsrCond31==0,2),:)=[];
else
    disp('WARNING: File Cond_31/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 32
fsFilename = '_result_comparison_data/Cond_32/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond32 = csvread(fsFilename);
    fsrCond32(all(fsrCond32==0,2),:)=[];
else
    disp('WARNING: File Cond_32/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 33
fsFilename = '_result_comparison_data/Cond_33/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond33 = csvread(fsFilename);
    fsrCond33(all(fsrCond33==0,2),:)=[];
else
    disp('WARNING: File Cond_33/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 34
fsFilename = '_result_comparison_data/Cond_34/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond34 = csvread(fsFilename);
    fsrCond34(all(fsrCond34==0,2),:)=[];
else
    disp('WARNING: File Cond_34/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 35
fsFilename = '_result_comparison_data/Cond_35/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond35 = csvread(fsFilename);
    fsrCond35(all(fsrCond35==0,2),:)=[];
else
    disp('WARNING: File Cond_35/fullScaleDataArray.dat does not exist!');
    break;
end
% CONDITION 36
fsFilename = '_result_comparison_data/Cond_36/fullScaleDataArray.dat';
if exist(fsFilename, 'file') == 2
    fsrCond36 = csvread(fsFilename);
    fsrCond36(all(fsrCond36==0,2),:)=[];
else
    disp('WARNING: File Cond_36/fullScaleDataArray.dat does not exist!');
    break;
end
%# ------------------------------------------------------------------------
%# END Full scale results
%# ************************************************************************


%# ************************************************************************
%# START Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ------------------------------------------------------------------------
if exist('SeaTrials1500TonnesCorrPower.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('SeaTrials1500TonnesCorrPower.mat');
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
%# 1. Plotting Comparisons: Power and Propulsive Efficiency at Ca=0
%# ************************************************************************

if enableNumber1Plot == 1
    %# Plotting speed ---------------------------------------------------------
    figurename = 'Plot 1: Full Scale: Delivered Power and Propulsive Efficiency for Ca=0';
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
    setLegendFontSize  = 9;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    subplot(2,2,1)
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 1
    fsData = fsrCond1;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 4
    fsData = fsrCond4;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 7
    fsData = fsrCond7;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 10
    fsData = fsrCond10;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    subplot(2,2,2)
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 13
    fsData = fsrCond13;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 16
    fsData = fsrCond16;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    %# CONDITION 19
    fsData = fsrCond19;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x7 = fsData(:,3);
    y7 = delpowerMW;
    
    %# CONDITION 22
    fsData = fsrCond22;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x8 = fsData(:,3);
    y8 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    subplot(2,2,3)
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 1
    fsData = fsrCond1;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 4
    fsData = fsrCond4;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 7
    fsData = fsrCond7;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    subplot(2,2,4)
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 13
    fsData = fsrCond13;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 16
    fsData = fsrCond16;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    %# CONDITION 19
    fsData = fsrCond19;
    x7 = fsData(:,3);
    y7 = fsData(:,46);
    
    %# CONDITION 22
    fsData = fsrCond22;
    x8 = fsData(:,3);
    y8 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_1_Power_And_OPE_Ca_0.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber1Plot


%# ************************************************************************
%# 2. Plotting Comparisons: Power and Propulsive Efficiency at Ca=0.00035
%# ************************************************************************

if enableNumber2Plot == 1
    %# Plotting speed ---------------------------------------------------------
    figurename = 'Plot 2: Full Scale: Delivered Power and Propulsive Efficiency for Ca=0.00035';
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
    setLegendFontSize  = 9;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    subplot(2,2,1)
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 2
    fsData = fsrCond2;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 5
    fsData = fsrCond5;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 8
    fsData = fsrCond8;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 11
    fsData = fsrCond11;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    subplot(2,2,2)
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 14
    fsData = fsrCond14;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 17
    fsData = fsrCond17;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    %# CONDITION 20
    fsData = fsrCond20;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x7 = fsData(:,3);
    y7 = delpowerMW;
    
    %# CONDITION 23
    fsData = fsrCond23;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x8 = fsData(:,3);
    y8 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    subplot(2,2,3)
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 2
    fsData = fsrCond2;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 5
    fsData = fsrCond5;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 8
    fsData = fsrCond8;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 11
    fsData = fsrCond11;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    subplot(2,2,4)
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 14
    fsData = fsrCond14;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 17
    fsData = fsrCond17;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    %# CONDITION 20
    fsData = fsrCond20;
    x7 = fsData(:,3);
    y7 = fsData(:,46);
    
    %# CONDITION 23
    fsData = fsrCond23;
    x8 = fsData(:,3);
    y8 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_2_Power_And_OPE_Ca_00035.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber2Plot


%# ************************************************************************
%# 3. Plotting Comparisons: Power and Propulsive Efficiency at Ca=0.00059
%# ************************************************************************

if enableNumber3Plot == 1
    %# Plotting speed ---------------------------------------------------------
    figurename = 'Plot 3: Full Scale: Delivered Power and Propulsive Efficiency for Ca=0.00059';
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
    setLegendFontSize  = 9;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    subplot(2,2,1)
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 3
    fsData = fsrCond3;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 6
    fsData = fsrCond6;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 9
    fsData = fsrCond9;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 12
    fsData = fsrCond12;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    subplot(2,2,2)
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 15
    fsData = fsrCond15;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 18
    fsData = fsrCond18;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    %# CONDITION 21
    fsData = fsrCond21;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x7 = fsData(:,3);
    y7 = delpowerMW;
    
    %# CONDITION 24
    fsData = fsrCond24;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x8 = fsData(:,3);
    y8 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    subplot(2,2,3)
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 3
    fsData = fsrCond3;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 6
    fsData = fsrCond6;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 9
    fsData = fsrCond9;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 12
    fsData = fsrCond12;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    subplot(2,2,4)
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 15
    fsData = fsrCond15;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 18
    fsData = fsrCond18;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    %# CONDITION 21
    fsData = fsrCond21;
    x7 = fsData(:,3);
    y7 = fsData(:,46);
    
    %# CONDITION 24
    fsData = fsrCond24;
    x8 = fsData(:,3);
    y8 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Catamaran: Using w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})');
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_3_Power_And_OPE_Ca_00059.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber3Plot


%# ************************************************************************
%# 4. Plotting Comparisons: Power and Propulsive Efficiency
%# ************************************************************************

if enableNumber4Plot == 1
    %# ********************************************************************
    %# SIMPLE PLOT
    %# ********************************************************************
    figurename = 'Plot 4: Full Scale: Del. Power and Prop. Eff., w_{s}=w_{m}(C_{Fs}/C_{Fm})';
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
    setLegendFontSize  = 10;
    
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
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    if enableAdjOrNotAdjCurvesPlot == 1
        %# Delivered Power vs. Ship Speed /////////////////////////////////////
        subplot(2,2,1)
        
        x = SeaTrialsCorrectedPower(:,1);
        y = SeaTrialsCorrectedPower(:,3);
        
        % Fitting curve through sea trials delivered power
        fitobject = fit(x,y,'poly5');
        cvalues = coeffvalues(fitobject);
        
        % Sea Trials Data
        fittingSpeeds = [13:1:25];
        [mfs,nfs] = size(fittingSpeeds);
        delpowerMW = [];
        for k=1:nfs
            actSpeed = fittingSpeeds(k);
            delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
        end
        xst  = fittingSpeeds;
        yst  = delpowerMW;
        
        %# CONDITION 1
        fsData = fsrCond1;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x1 = fsData(:,3);
        y1 = delpowerMW;
        
        %# CONDITION 2
        fsData = fsrCond2;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x2 = fsData(:,3);
        y2 = delpowerMW;
        
        %# CONDITION 3
        fsData = fsrCond3;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x3 = fsData(:,3);
        y3 = delpowerMW;
        
        %# CONDITION 7
        fsData = fsrCond7;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x4 = fsData(:,3);
        y4 = delpowerMW;
        
        %# CONDITION 8
        fsData = fsrCond8;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x5 = fsData(:,3);
        y5 = delpowerMW;
        
        %# CONDITION 9
        fsData = fsrCond9;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x6 = fsData(:,3);
        y6 = delpowerMW;
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSStdevArray = [];
        fsData1 = fsrCond1;
        fsData2 = fsrCond2;
        fsData3 = fsrCond3;
        fsData4 = fsrCond7;
        fsData5 = fsrCond8;
        fsData6 = fsrCond9;
        for kl=1:meb
            delPower1  = ((fsData1(kl,42)+fsData1(kl,43))*2)/1000^2;
            delPower2  = ((fsData2(kl,42)+fsData2(kl,43))*2)/1000^2;
            delPower3  = ((fsData3(kl,42)+fsData3(kl,43))*2)/1000^2;
            delPower4  = ((fsData4(kl,42)+fsData4(kl,43))*2)/1000^2;
            delPower5  = ((fsData5(kl,42)+fsData5(kl,43))*2)/1000^2;
            delPower6  = ((fsData6(kl,42)+fsData6(kl,43))*2)/1000^2;
            powerArray1 = [delPower1 delPower2 delPower3];
            powerArray2 = [delPower4 delPower5 delPower6];
            % Standard deviation
            DSStdevArray(kl,1) = std(powerArray1,1);
            DSStdevArray(kl,2) = std(powerArray2,1);
            % Mean/average
            DSStdevArray(kl,3) = mean(powerArray1);
            DSStdevArray(kl,4) = mean(powerArray2);
        end
        
        %# Plotting -----------------------------------------------------------
        h = plot(xst,yst,'-',x2,y2,'*',x5,y5,'*');
        % Error bars based on STD
        hold on;
        h1 = errorbar(x2,y2,DSStdevArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x5,y5,DSStdevArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(3),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 20;
        incrY = 4;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('Corrected Power (Sea Trials)','P_{D} (FRM June 2013)','P_{D} (FRM Sept. 2014)');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
        subplot(2,2,2)
        
        %# X and Y axis -------------------------------------------------------
        
        %# CONDITION 1
        fsData = fsrCond1;
        x1 = fsData(:,3);
        y1 = fsData(:,46);
        
        %# CONDITION 2
        fsData = fsrCond2;
        x2 = fsData(:,3);
        y2 = fsData(:,46);
        
        %# CONDITION 3
        fsData = fsrCond3;
        x3 = fsData(:,3);
        y3 = fsData(:,46);
        
        %# CONDITION 7
        fsData = fsrCond7;
        x4 = fsData(:,3);
        y4 = fsData(:,46);
        
        %# CONDITION 8
        fsData = fsrCond8;
        x5 = fsData(:,3);
        y5 = fsData(:,46);
        
        %# CONDITION 9
        fsData = fsrCond9;
        x6 = fsData(:,3);
        y6 = fsData(:,46);
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSOPEArray = [];
        fsData1 = fsrCond1;
        fsData2 = fsrCond2;
        fsData3 = fsrCond3;
        fsData4 = fsrCond7;
        fsData5 = fsrCond8;
        fsData6 = fsrCond9;
        for kl=1:meb
            effArray1 = [fsData1(kl,46) fsData3(kl,46) fsData2(kl,46)];
            effArray2 = [fsData4(kl,46) fsData5(kl,46) fsData6(kl,46)];
            % Standard deviation
            DSOPEArray(kl,1) = std(effArray1,1);
            DSOPEArray(kl,2) = std(effArray2,1);
            % Mean/average
            DSOPEArray(kl,3) = mean(effArray1);
            DSOPEArray(kl,4) = mean(effArray2);
        end
        
        %# Plotting -----------------------------------------------------------
        h = plot(x2,y2,'*',x5,y5,'*');
        % Error bars based on STD
        hold on;
        h1 = errorbar(x2,y2,DSOPEArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x5,y5,DSOPEArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 1;
        incrY = 0.1;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('\eta_{D} (FRM June 2013)','\eta_{D} (FRM Sept. 2014)');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    end
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,3)
    else
        subplot(1,2,1)
    end
    
    %# X and Y axis -------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 4
    fsData = fsrCond5;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 5
    fsData = fsrCond5;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 6
    fsData = fsrCond6;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 10
    fsData = fsrCond10;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# CONDITION 11
    fsData = fsrCond11;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 12
    fsData = fsrCond12;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond4);
    DSStdevArray = [];
    fsData1 = fsrCond4;
    fsData2 = fsrCond5;
    fsData3 = fsrCond6;
    fsData4 = fsrCond10;
    fsData5 = fsrCond11;
    fsData6 = fsrCond12;
    for kl=1:meb
        delPower1  = ((fsData1(kl,42)+fsData1(kl,43))*2)/1000^2;
        delPower2  = ((fsData2(kl,42)+fsData2(kl,43))*2)/1000^2;
        delPower3  = ((fsData3(kl,42)+fsData3(kl,43))*2)/1000^2;
        delPower4  = ((fsData4(kl,42)+fsData4(kl,43))*2)/1000^2;
        delPower5  = ((fsData5(kl,42)+fsData5(kl,43))*2)/1000^2;
        delPower6  = ((fsData6(kl,42)+fsData6(kl,43))*2)/1000^2;
        powerArray1 = [delPower1 delPower2 delPower3];
        powerArray2 = [delPower4 delPower5 delPower6];
        % Standard deviation
        DSStdevArray(kl,1) = std(powerArray1,1);
        DSStdevArray(kl,2) = std(powerArray2,1);
        % Mean/average
        DSStdevArray(kl,3) = mean(powerArray1);
        DSStdevArray(kl,4) = mean(powerArray2);
        % Difference to mean (i.e. max()/mean())
        diffToMean1 = (1-(max(powerArray1)/mean(powerArray1)))*100;
        diffToMean2 = (1-(max(powerArray2)/mean(powerArray2)))*100;
        disp(sprintf('Plot 4: Del. Power: Speed: %s: Diff. to mean (ws=wm(CFs/CFm)): %s%%, Diff. to mean (ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)): %s%%',num2str(kl),sprintf('%.0f',diffToMean1),sprintf('%.0f',diffToMean2)));
    end
    
    if enableWJBMDelPowerOPEPlot == 1
        %# Conditions added 21/11/2014 (using WJ benchmark data): -------------------------------
        
        %# CONDITION 25
        fsData = fsrCond25;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x7 = fsData(:,3);
        y7 = delpowerMW;
        
        %# CONDITION 26
        fsData = fsrCond26;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x8 = fsData(:,3);
        y8 = delpowerMW;
        
        %# CONDITION 27
        fsData = fsrCond27;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x9 = fsData(:,3);
        y9 = delpowerMW;
        
        %# CONDITION 28
        fsData = fsrCond28;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x10 = fsData(:,3);
        y10 = delpowerMW;
        
        %# CONDITION 29
        fsData = fsrCond29;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x11 = fsData(:,3);
        y11 = delpowerMW;
        
        %# CONDITION 30
        fsData = fsrCond30;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x12 = fsData(:,3);
        y12 = delpowerMW;
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSStdevWJBMArray = [];
        fsData1 = fsrCond25;
        fsData2 = fsrCond26;
        fsData3 = fsrCond27;
        fsData4 = fsrCond28;
        fsData5 = fsrCond29;
        fsData6 = fsrCond30;
        for kl=1:meb
            delPower1  = ((fsData1(kl,42)+fsData1(kl,43))*2)/1000^2;
            delPower2  = ((fsData2(kl,42)+fsData2(kl,43))*2)/1000^2;
            delPower3  = ((fsData3(kl,42)+fsData3(kl,43))*2)/1000^2;
            delPower4  = ((fsData4(kl,42)+fsData4(kl,43))*2)/1000^2;
            delPower5  = ((fsData5(kl,42)+fsData5(kl,43))*2)/1000^2;
            delPower6  = ((fsData6(kl,42)+fsData6(kl,43))*2)/1000^2;
            powerArray1 = [delPower1 delPower2 delPower3];
            powerArray2 = [delPower4 delPower5 delPower6];
            % Standard deviation
            DSStdevWJBMArray(kl,1) = std(powerArray1,1);
            DSStdevWJBMArray(kl,2) = std(powerArray2,1);
            % Mean/average
            DSStdevWJBMArray(kl,3) = mean(powerArray1);
            DSStdevWJBMArray(kl,4) = mean(powerArray2);
        end
    end % enableWJBMDelPowerOPEPlot
    
    %# Plotting -----------------------------------------------------------
    if enableWJBMDelPowerOPEPlot == 1
        h = plot(xst,yst,'-',x2,y2,'*',x5,y5,'*',x8,y8,'*',x11,y11,'*');
    else
        h = plot(xst,yst,'-',x2,y2,'*',x5,y5,'*');
    end
    % Error bars based on STD
    hold on;
    h1 = errorbar(x2,y2,DSStdevArray(:,1),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    hold on;
    h1 = errorbar(x5,y5,DSStdevArray(:,2),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    if enableWJBMDelPowerOPEPlot == 1
        hold on;
        h1 = errorbar(x8,y8,DSStdevWJBMArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x11,y11,DSStdevWJBMArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    end
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableWJBMDelPowerOPEPlot == 1
        set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(5),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    end
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    if enableWJBMDelPowerOPEPlot == 1
        maxY  = 45;
    else
        maxY  = 20;
    end
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    if enableWJBMDelPowerOPEPlot == 1
        hleg1 = legend('Corrected Power (Sea Trials)','P_{D} (FRM June 2013) Momentum','P_{D} (FRM Sept. 2014) Momentum','P_{D} (FRM June 2013) WJ Benchmark','P_{D} (FRM Sept. 2014) WJ Benchmark');
    else
        hleg1 = legend('Corrected Power (Sea Trials)','P_{D} (FRM June 2013)','P_{D} (FRM Sept. 2014)');
    end
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,4)
    else
        subplot(1,2,2)
    end
    
    %# X and Y axis -------------------------------------------------------
    
    %# CONDITION 4
    fsData = fsrCond4;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 5
    fsData = fsrCond5;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 6
    fsData = fsrCond6;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 11
    fsData = fsrCond11;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond1);
    DSOPEArray = [];
    fsData1 = fsrCond4;
    fsData2 = fsrCond5;
    fsData3 = fsrCond6;
    fsData4 = fsrCond10;
    fsData5 = fsrCond11;
    fsData6 = fsrCond12;
    for kl=1:meb
        effArray1 = [fsData1(kl,46) fsData3(kl,46) fsData2(kl,46)];
        effArray2 = [fsData4(kl,46) fsData5(kl,46) fsData6(kl,46)];
        % Standard deviation
        DSOPEArray(kl,1) = std(effArray1,1);
        DSOPEArray(kl,2) = std(effArray2,1);
        % Mean/average
        DSOPEArray(kl,3) = mean(effArray1);
        DSOPEArray(kl,4) = mean(effArray2);
    end
    
    if enableWJBMDelPowerOPEPlot == 1
    %# Conditions added 21/11/2014 (using WJ benchmark data): -------------
    
    %# CONDITION 25
    fsData = fsrCond25;
    x7 = fsData(:,3);
    y7 = fsData(:,46);
    
    %# CONDITION 26
    fsData = fsrCond26;
    x8 = fsData(:,3);
    y8 = fsData(:,46);
    
    %# CONDITION 27
    fsData = fsrCond27;
    x9 = fsData(:,3);
    y9 = fsData(:,46);
    
    %# CONDITION 28
    fsData = fsrCond28;
    x10 = fsData(:,3);
    y10 = fsData(:,46);
    
    %# CONDITION 29
    fsData = fsrCond29;
    x11 = fsData(:,3);
    y11 = fsData(:,46);
    
    %# CONDITION 30
    fsData = fsrCond30;
    x12 = fsData(:,3);
    y12 = fsData(:,46);
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond1);
    DSOPEWJBMArray = [];
    fsData1 = fsrCond25;
    fsData2 = fsrCond25;
    fsData3 = fsrCond27;
    fsData4 = fsrCond28;
    fsData5 = fsrCond29;
    fsData6 = fsrCond30;
    for kl=1:meb
        effArray1 = [fsData1(kl,46) fsData3(kl,46) fsData2(kl,46)];
        effArray2 = [fsData4(kl,46) fsData5(kl,46) fsData6(kl,46)];
        % Standard deviation
        DSOPEWJBMArray(kl,1) = std(effArray1,1);
        DSOPEWJBMArray(kl,2) = std(effArray2,1);
        % Mean/average
        DSOPEWJBMArray(kl,3) = mean(effArray1);
        DSOPEWJBMArray(kl,4) = mean(effArray2);
    end
    end % enableWJBMDelPowerOPEPlot
    
    %# Plotting -----------------------------------------------------------
    if enableWJBMDelPowerOPEPlot == 1
        h = plot(x2,y2,'*',x5,y5,'*',x8,y8,'*',x11,y11,'*');
    else
        h = plot(x2,y2,'*',x5,y5,'*');
    end
    % Error bars based on STD
    hold on;
    h1 = errorbar(x2,y2,DSOPEArray(:,1),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    hold on;
    h1 = errorbar(x5,y5,DSOPEArray(:,2),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    if enableWJBMDelPowerOPEPlot == 1
        hold on;
        h1 = errorbar(x8,y8,DSOPEWJBMArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x11,y11,DSOPEWJBMArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    end
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableWJBMDelPowerOPEPlot == 1
        set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    end
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    if enableWJBMDelPowerOPEPlot == 1
        hleg1 = legend('P_{D} (FRM June 2013) Momentum','P_{D} (FRM Sept. 2014) Momentum','P_{D} (FRM June 2013) WJ Benchmark','P_{D} (FRM Sept. 2014) WJ Benchmark');
    else
        hleg1 = legend('P_{D} (FRM June 2013)','P_{D} (FRM Sept. 2014)');
    end
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_4_Power_Ca_0_000035_And_000059_WS_WO_Rudder_Components.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    %# ********************************************************************
    %# DETAILS PLOT
    %# ********************************************************************
    figurename = 'Plot 4.1: Full Scale: Del. Power and Prop. Eff., w_{s}=w_{m}(C_{Fs}/C_{Fm})';
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
    setLegendFontSize  = 9;
    
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
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    if enableAdjOrNotAdjCurvesPlot == 1
        %# Delivered Power vs. Ship Speed /////////////////////////////////////
        subplot(2,2,1)
        
        %# X and Y axis -------------------------------------------------------
        
        x = SeaTrialsCorrectedPower(:,1);
        y = SeaTrialsCorrectedPower(:,3);
        
        % Fitting curve through sea trials delivered power
        fitobject = fit(x,y,'poly5');
        cvalues = coeffvalues(fitobject);
        
        % Sea Trials Data
        fittingSpeeds = [13:1:25];
        [mfs,nfs] = size(fittingSpeeds);
        delpowerMW = [];
        for k=1:nfs
            actSpeed = fittingSpeeds(k);
            delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
        end
        xst  = fittingSpeeds;
        yst  = delpowerMW;
        
        %# CONDITION 1
        fsData = fsrCond1;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x1 = fsData(:,3);
        y1 = delpowerMW;
        
        %# CONDITION 2
        fsData = fsrCond2;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x2 = fsData(:,3);
        y2 = delpowerMW;
        
        %# CONDITION 3
        fsData = fsrCond3;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x3 = fsData(:,3);
        y3 = delpowerMW;
        
        %# CONDITION 7
        fsData = fsrCond7;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x4 = fsData(:,3);
        y4 = delpowerMW;
        
        %# CONDITION 8
        fsData = fsrCond8;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x5 = fsData(:,3);
        y5 = delpowerMW;
        
        %# CONDITION 9
        fsData = fsrCond9;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x6 = fsData(:,3);
        y6 = delpowerMW;
        
        %# Plotting -----------------------------------------------------------
        h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(6),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(7),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 20;
        incrY = 4;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
        subplot(2,2,2)
        
        %# X and Y axis -------------------------------------------------------
        
        %# CONDITION 1
        fsData = fsrCond1;
        x1 = fsData(:,3);
        y1 = fsData(:,46);
        
        %# CONDITION 2
        fsData = fsrCond2;
        x2 = fsData(:,3);
        y2 = fsData(:,46);
        
        %# CONDITION 3
        fsData = fsrCond3;
        x3 = fsData(:,3);
        y3 = fsData(:,46);
        
        %# CONDITION 7
        fsData = fsrCond7;
        x4 = fsData(:,3);
        y4 = fsData(:,46);
        
        %# CONDITION 8
        fsData = fsrCond8;
        x5 = fsData(:,3);
        y5 = fsData(:,46);
        
        %# CONDITION 9
        fsData = fsrCond9;
        x6 = fsData(:,3);
        y6 = fsData(:,46);
        
        %# Plotting -----------------------------------------------------------
        h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(5),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 1;
        incrY = 0.1;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    end
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,3)
    else
        subplot(1,2,1)
    end
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 4
    fsData = fsrCond5;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 5
    fsData = fsrCond5;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 6
    fsData = fsrCond6;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 10
    fsData = fsrCond10;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# CONDITION 11
    fsData = fsrCond11;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 12
    fsData = fsrCond12;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    %# Plotting -----------------------------------------------------------
    h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(6),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(7),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,4)
    else
        subplot(1,2,2)
    end
    
    %# X and Y axis -------------------------------------------------------
    
    %# CONDITION 4
    fsData = fsrCond4;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 5
    fsData = fsrCond5;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 6
    fsData = fsrCond6;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 11
    fsData = fsrCond11;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    %# Plotting -----------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_4_1_Power_Ca_0_000035_And_000059_WS_WO_Rudder_Components.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber4Plot


%# ************************************************************************
%# 5. Plotting Comparisons: Power and Propulsive Efficiency
%# ************************************************************************

if enableNumber5Plot == 1
    %# ********************************************************************
    %# SIMPLE PLOT
    %# ********************************************************************
    figurename = 'Plot 5: Full Scale: Del. Power and Prop. Eff., w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})';
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
    setLegendFontSize  = 10;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    if enableAdjOrNotAdjCurvesPlot == 1
        %# Delivered Power vs. Ship Speed /////////////////////////////////////////
        subplot(2,2,1)
        
        %# X and Y axis -----------------------------------------------------------
        
        x = SeaTrialsCorrectedPower(:,1);
        y = SeaTrialsCorrectedPower(:,3);
        
        % Fitting curve through sea trials delivered power
        fitobject = fit(x,y,'poly5');
        cvalues = coeffvalues(fitobject);
        
        % Sea Trials Data
        fittingSpeeds = [13:1:25];
        [mfs,nfs] = size(fittingSpeeds);
        delpowerMW = [];
        for k=1:nfs
            actSpeed = fittingSpeeds(k);
            delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
        end
        xst  = fittingSpeeds;
        yst  = delpowerMW;
        
        %# CONDITION 13
        fsData = fsrCond13;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x1 = fsData(:,3);
        y1 = delpowerMW;
        
        %# CONDITION 14
        fsData = fsrCond14;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x2 = fsData(:,3);
        y2 = delpowerMW;
        
        %# CONDITION 15
        fsData = fsrCond15;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x3 = fsData(:,3);
        y3 = delpowerMW;
        
        %# CONDITION 19
        fsData = fsrCond19;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x4 = fsData(:,3);
        y4 = delpowerMW;
        
        %# CONDITION 20
        fsData = fsrCond20;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x5 = fsData(:,3);
        y5 = delpowerMW;
        
        %# CONDITION 21
        fsData = fsrCond21;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x6 = fsData(:,3);
        y6 = delpowerMW;
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSStdevArray = [];
        fsData1 = fsrCond13;
        fsData2 = fsrCond14;
        fsData3 = fsrCond15;
        fsData4 = fsrCond19;
        fsData5 = fsrCond20;
        fsData6 = fsrCond21;
        for kl=1:meb
            delPower1  = ((fsData1(kl,42)+fsData1(kl,43))*2)/1000^2;
            delPower2  = ((fsData2(kl,42)+fsData2(kl,43))*2)/1000^2;
            delPower3  = ((fsData3(kl,42)+fsData3(kl,43))*2)/1000^2;
            delPower4  = ((fsData4(kl,42)+fsData4(kl,43))*2)/1000^2;
            delPower5  = ((fsData5(kl,42)+fsData5(kl,43))*2)/1000^2;
            delPower6  = ((fsData6(kl,42)+fsData6(kl,43))*2)/1000^2;
            powerArray1 = [delPower1 delPower2 delPower3];
            powerArray2 = [delPower4 delPower5 delPower6];
            % Standard deviation
            DSStdevArray(kl,1) = std(powerArray1,1);
            DSStdevArray(kl,2) = std(powerArray2,1);
            % Mean/average
            DSStdevArray(kl,3) = mean(powerArray1);
            DSStdevArray(kl,4) = mean(powerArray2);
        end
        
        %# Plotting ---------------------------------------------------------------
        h = plot(xst,yst,'-',x2,y2,'*',x5,y5,'*');
        % Error bars based on STD
        hold on;
        h1 = errorbar(x2,y2,DSStdevArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x5,y5,DSStdevArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(3),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 20;
        incrY = 4;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('Corrected Power (Sea Trials)','P_{D} (FRM June 2013)','P_{D} (FRM Sept. 2014)');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
        subplot(2,2,2)
        
        %# X and Y axis -----------------------------------------------------------
        
        %# CONDITION 13
        fsData = fsrCond13;
        x1 = fsData(:,3);
        y1 = fsData(:,46);
        
        %# CONDITION 14
        fsData = fsrCond14;
        x2 = fsData(:,3);
        y2 = fsData(:,46);
        
        %# CONDITION 15
        fsData = fsrCond15;
        x3 = fsData(:,3);
        y3 = fsData(:,46);
        
        %# CONDITION 19
        fsData = fsrCond19;
        x4 = fsData(:,3);
        y4 = fsData(:,46);
        
        %# CONDITION 20
        fsData = fsrCond20;
        x5 = fsData(:,3);
        y5 = fsData(:,46);
        
        %# CONDITION 21
        fsData = fsrCond21;
        x6 = fsData(:,3);
        y6 = fsData(:,46);
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSOPEArray = [];
        fsData1 = fsrCond13;
        fsData2 = fsrCond14;
        fsData3 = fsrCond15;
        fsData4 = fsrCond19;
        fsData5 = fsrCond20;
        fsData6 = fsrCond21;
        for kl=1:meb
            effArray1 = [fsData1(kl,46) fsData3(kl,46) fsData2(kl,46)];
            effArray2 = [fsData4(kl,46) fsData5(kl,46) fsData6(kl,46)];
            % Standard deviation
            DSOPEArray(kl,1) = std(effArray1,1);
            DSOPEArray(kl,2) = std(effArray2,1);
            % Mean/average
            DSOPEArray(kl,3) = mean(effArray1);
            DSOPEArray(kl,4) = mean(effArray2);
        end
        
        %# Plotting ---------------------------------------------------------------
        h = plot(x2,y2,'*',x5,y5,'*');
        % Error bars based on STD
        hold on;
        h1 = errorbar(x2,y2,DSOPEArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x5,y5,DSOPEArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 1;
        incrY = 0.1;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('\eta_{D} (FRM June 2013)','\eta_{D} (FRM Sept. 2014)');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    end
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,3)
    else
        subplot(1,2,1)
    end
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 16
    fsData = fsrCond16;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 17
    fsData = fsrCond17;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 18
    fsData = fsrCond18;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 22
    fsData = fsrCond22;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# CONDITION 23
    fsData = fsrCond23;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 24
    fsData = fsrCond24;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond1);
    DSStdevArray = [];
    fsData1 = fsrCond16;
    fsData2 = fsrCond17;
    fsData3 = fsrCond18;
    fsData4 = fsrCond22;
    fsData5 = fsrCond23;
    fsData6 = fsrCond24;
    for kl=1:meb
        delPower1  = ((fsData1(kl,42)+fsData1(kl,43))*2)/1000^2;
        delPower2  = ((fsData2(kl,42)+fsData2(kl,43))*2)/1000^2;
        delPower3  = ((fsData3(kl,42)+fsData3(kl,43))*2)/1000^2;
        delPower4  = ((fsData4(kl,42)+fsData4(kl,43))*2)/1000^2;
        delPower5  = ((fsData5(kl,42)+fsData5(kl,43))*2)/1000^2;
        delPower6  = ((fsData6(kl,42)+fsData6(kl,43))*2)/1000^2;
        powerArray1 = [delPower1 delPower2 delPower3];
        powerArray2 = [delPower4 delPower5 delPower6];
        % Standard deviation
        DSStdevArray(kl,1) = std(powerArray1,1);
        DSStdevArray(kl,2) = std(powerArray2,1);
        % Mean/average
        DSStdevArray(kl,3) = mean(powerArray1);
        DSStdevArray(kl,4) = mean(powerArray2);
        % Difference to mean (i.e. max()/mean())
        diffToMean1 = (1-(max(powerArray1)/mean(powerArray1)))*100;
        diffToMean2 = (1-(max(powerArray2)/mean(powerArray2)))*100;
        disp(sprintf('Plot 5: Del. Power: Speed: %s: Diff. to mean (ws=wm(CFs/CFm)): %s%%, Diff. to mean (ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)): %s%%',num2str(kl),sprintf('%.0f',diffToMean1),sprintf('%.0f',diffToMean2)));        
    end
    
    if enableWJBMDelPowerOPEPlot == 1
        %# Conditions added 21/11/2014 (using WJ benchmark data): -------------------------------
        
        %# CONDITION 31
        fsData = fsrCond31;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x7 = fsData(:,3);
        y7 = delpowerMW;
        
        %# CONDITION 32
        fsData = fsrCond32;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x8 = fsData(:,3);
        y8 = delpowerMW;
        
        %# CONDITION 33
        fsData = fsrCond33;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x9 = fsData(:,3);
        y9 = delpowerMW;
        
        %# CONDITION 34
        fsData = fsrCond34;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x10 = fsData(:,3);
        y10 = delpowerMW;
        
        %# CONDITION 35
        fsData = fsrCond35;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x11 = fsData(:,3);
        y11 = delpowerMW;
        
        %# CONDITION 36
        fsData = fsrCond36;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x12 = fsData(:,3);
        y12 = delpowerMW;
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSStdevWJBMArray = [];
        fsData1 = fsrCond31;
        fsData2 = fsrCond32;
        fsData3 = fsrCond33;
        fsData4 = fsrCond34;
        fsData5 = fsrCond35;
        fsData6 = fsrCond36;
        for kl=1:meb
            delPower1  = ((fsData1(kl,42)+fsData1(kl,43))*2)/1000^2;
            delPower2  = ((fsData2(kl,42)+fsData2(kl,43))*2)/1000^2;
            delPower3  = ((fsData3(kl,42)+fsData3(kl,43))*2)/1000^2;
            delPower4  = ((fsData4(kl,42)+fsData4(kl,43))*2)/1000^2;
            delPower5  = ((fsData5(kl,42)+fsData5(kl,43))*2)/1000^2;
            delPower6  = ((fsData6(kl,42)+fsData6(kl,43))*2)/1000^2;
            powerArray1 = [delPower1 delPower2 delPower3];
            powerArray2 = [delPower4 delPower5 delPower6];
            % Standard deviation
            DSStdevWJBMArray(kl,1) = std(powerArray1,1);
            DSStdevWJBMArray(kl,2) = std(powerArray2,1);
            % Mean/average
            DSStdevWJBMArray(kl,3) = mean(powerArray1);
            DSStdevWJBMArray(kl,4) = mean(powerArray2);
        end
    end % enableWJBMDelPowerOPEPlot

    %# Plotting ---------------------------------------------------------------
    if enableWJBMDelPowerOPEPlot == 1
        h = plot(xst,yst,'-',x2,y2,'*',x5,y5,'*',x8,y8,'*',x11,y11,'*');
    else
        h = plot(xst,yst,'-',x2,y2,'*',x5,y5,'*');
    end
    % Error bars based on STD
    hold on;
    h1 = errorbar(x2,y2,DSStdevArray(:,1),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    hold on;
    h1 = errorbar(x5,y5,DSStdevArray(:,2),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    if enableWJBMDelPowerOPEPlot == 1
        hold on;
        h1 = errorbar(x8,y8,DSStdevWJBMArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x11,y11,DSStdevWJBMArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    end
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableWJBMDelPowerOPEPlot == 1
        set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(5),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    end
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    if enableWJBMDelPowerOPEPlot == 1
        maxY  = 45;
    else
        maxY  = 20;
    end
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    if enableWJBMDelPowerOPEPlot == 1
        hleg1 = legend('Corrected Power (Sea Trials)','P_{D} (FRM June 2013) Momentum','P_{D} (FRM Sept. 2014) Momentum','P_{D} (FRM June 2013) WJ Benchmark','P_{D} (FRM Sept. 2014) WJ Benchmark');
    else
        hleg1 = legend('Corrected Power (Sea Trials)','P_{D} (FRM June 2013)','P_{D} (FRM Sept. 2014)');
    end
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,4)
    else
        subplot(1,2,2)
    end
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 16
    fsData = fsrCond16;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 17
    fsData = fsrCond17;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 18
    fsData = fsrCond18;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 22
    fsData = fsrCond22;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# CONDITION 23
    fsData = fsrCond23;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 24
    fsData = fsrCond24;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond1);
    DSOPEArray = [];
    fsData1 = fsrCond16;
    fsData2 = fsrCond17;
    fsData3 = fsrCond18;
    fsData4 = fsrCond22;
    fsData5 = fsrCond23;
    fsData6 = fsrCond24;
    for kl=1:meb
        effArray1 = [fsData1(kl,46) fsData3(kl,46) fsData2(kl,46)];
        effArray2 = [fsData4(kl,46) fsData5(kl,46) fsData6(kl,46)];
        % Standard deviation
        DSOPEArray(kl,1) = std(effArray1,1);
        DSOPEArray(kl,2) = std(effArray2,1);
        % Mean/average
        DSOPEArray(kl,3) = mean(effArray1);
        DSOPEArray(kl,4) = mean(effArray2);
    end
    
    if enableWJBMDelPowerOPEPlot == 1
        %# Conditions added 21/11/2014 (using WJ benchmark data): -------------------------------
        
        %# CONDITION 31
        fsData = fsrCond31;
        x7 = fsData(:,3);
        y7 = fsData(:,46);
        
        %# CONDITION 32
        fsData = fsrCond32;
        x8 = fsData(:,3);
        y8 = fsData(:,46);
        
        %# CONDITION 33
        fsData = fsrCond33;
        x9 = fsData(:,3);
        y9 = fsData(:,46);
        
        %# CONDITION 34
        fsData = fsrCond34;
        x10 = fsData(:,3);
        y10 = fsData(:,46);
        
        %# CONDITION 35
        fsData = fsrCond35;
        x11 = fsData(:,3);
        y11 = fsData(:,46);
        
        %# CONDITION 36
        fsData = fsrCond36;
        x12 = fsData(:,3);
        y12 = fsData(:,46);
        
        % Descriptive statistics: Calculate Standard Deviation (StDev)
        [meb,neb] = size(fsrCond1);
        DSOPEWJBMArray = [];
        fsData1 = fsrCond31;
        fsData2 = fsrCond32;
        fsData3 = fsrCond33;
        fsData4 = fsrCond34;
        fsData5 = fsrCond35;
        fsData6 = fsrCond36;
        for kl=1:meb
            effArray1 = [fsData1(kl,46) fsData3(kl,46) fsData2(kl,46)];
            effArray2 = [fsData4(kl,46) fsData5(kl,46) fsData6(kl,46)];
            % Standard deviation
            DSOPEWJBMArray(kl,1) = std(effArray1,1);
            DSOPEWJBMArray(kl,2) = std(effArray2,1);
            % Mean/average
            DSOPEWJBMArray(kl,3) = mean(effArray1);
            DSOPEWJBMArray(kl,4) = mean(effArray2);
        end
    end % enableWJBMDelPowerOPEPlot

    %# Plotting ---------------------------------------------------------------
    if enableWJBMDelPowerOPEPlot == 1
        h = plot(x2,y2,'*',x5,y5,'*',x8,y8,'*',x11,y11,'*');
    else
        h = plot(x2,y2,'*',x5,y5,'*');
    end
    % Error bars based on STD
    hold on;
    h1 = errorbar(x2,y2,DSOPEArray(:,1),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    hold on;
    h1 = errorbar(x5,y5,DSOPEArray(:,2),'k');
    set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    if enableWJBMDelPowerOPEPlot == 1
        hold on;
        h1 = errorbar(x8,y8,DSOPEWJBMArray(:,1),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
        hold on;
        h1 = errorbar(x11,y11,DSOPEWJBMArray(:,2),'k');
        set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    end
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableWJBMDelPowerOPEPlot == 1
        set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    end
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    if enableWJBMDelPowerOPEPlot == 1
        hleg1 = legend('P_{D} (FRM June 2013) Momentum','P_{D} (FRM Sept. 2014) Momentum','P_{D} (FRM June 2013) WJ Benchmark','P_{D} (FRM Sept. 2014) WJ Benchmark');
    else
        hleg1 = legend('\eta_{D} (FRM June 2013)','\eta_{D} (FRM Sept. 2014)');
    end
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_5_Power_Ca_0_000035_And_000059_WS_With_Rudder_Components.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    %# ********************************************************************
    %# DETAILS PLOT
    %# ********************************************************************
    figurename = 'Plot 5.1: Full Scale: Del. Power and Prop. Eff., w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})';
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
    setLegendFontSize  = 9;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    if enableAdjOrNotAdjCurvesPlot == 1
        %# Delivered Power vs. Ship Speed /////////////////////////////////////////
        subplot(2,2,1)
        
        %# X and Y axis -----------------------------------------------------------
        
        x = SeaTrialsCorrectedPower(:,1);
        y = SeaTrialsCorrectedPower(:,3);
        
        % Fitting curve through sea trials delivered power
        fitobject = fit(x,y,'poly5');
        cvalues = coeffvalues(fitobject);
        
        % Sea Trials Data
        fittingSpeeds = [13:1:25];
        [mfs,nfs] = size(fittingSpeeds);
        delpowerMW = [];
        for k=1:nfs
            actSpeed = fittingSpeeds(k);
            delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
        end
        xst  = fittingSpeeds;
        yst  = delpowerMW;
        
        %# CONDITION 13
        fsData = fsrCond13;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x1 = fsData(:,3);
        y1 = delpowerMW;
        
        %# CONDITION 14
        fsData = fsrCond14;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x2 = fsData(:,3);
        y2 = delpowerMW;
        
        %# CONDITION 15
        fsData = fsrCond15;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x3 = fsData(:,3);
        y3 = delpowerMW;
        
        %# CONDITION 19
        fsData = fsrCond19;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x4 = fsData(:,3);
        y4 = delpowerMW;
        
        %# CONDITION 20
        fsData = fsrCond20;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x5 = fsData(:,3);
        y5 = delpowerMW;
        
        %# CONDITION 21
        fsData = fsrCond21;
        [ma,na] = size(fsData);
        delpowerMW = [];
        for k=1:ma
            delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
        end
        x6 = fsData(:,3);
        y6 = delpowerMW;
        
        %# Plotting ---------------------------------------------------------------
        h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(6),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(7),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 20;
        incrY = 4;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
        subplot(2,2,2)
        
        %# X and Y axis -----------------------------------------------------------
        
        %# CONDITION 13
        fsData = fsrCond13;
        x1 = fsData(:,3);
        y1 = fsData(:,46);
        
        %# CONDITION 14
        fsData = fsrCond14;
        x2 = fsData(:,3);
        y2 = fsData(:,46);
        
        %# CONDITION 15
        fsData = fsrCond15;
        x3 = fsData(:,3);
        y3 = fsData(:,46);
        
        %# CONDITION 19
        fsData = fsrCond19;
        x4 = fsData(:,3);
        y4 = fsData(:,46);
        
        %# CONDITION 20
        fsData = fsrCond20;
        x5 = fsData(:,3);
        y5 = fsData(:,46);
        
        %# CONDITION 21
        fsData = fsrCond21;
        x6 = fsData(:,3);
        y6 = fsData(:,46);
        
        %# Plotting ---------------------------------------------------------------
        h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
        xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
        if enablePlotTitle == 1
            title('{\bf Catamaran: Not adj. F vs. T curves}','FontSize',setGeneralFontSize);
        end
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(5),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = 13;
        maxX  = 25;
        incrX = 1;
        minY  = 0;
        maxY  = 1;
        incrY = 0.1;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
        hleg1 = legend('FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
        set(hleg1,'Location','NorthWest');
        %set(hleg1,'Interpreter','none');
        set(hleg1, 'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border --------------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    end
    
    %# Delivered Power vs. Ship Speed /////////////////////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,3)
    else
        subplot(1,2,1)
    end
    
    %# X and Y axis -----------------------------------------------------------
    
    x = SeaTrialsCorrectedPower(:,1);
    y = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject = fit(x,y,'poly5');
    cvalues = coeffvalues(fitobject);
    
    % Sea Trials Data
    fittingSpeeds = [13:1:25];
    [mfs,nfs] = size(fittingSpeeds);
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
    end
    xst  = fittingSpeeds;
    yst  = delpowerMW;
    
    %# CONDITION 16
    fsData = fsrCond16;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x1 = fsData(:,3);
    y1 = delpowerMW;
    
    %# CONDITION 17
    fsData = fsrCond17;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x2 = fsData(:,3);
    y2 = delpowerMW;
    
    %# CONDITION 18
    fsData = fsrCond18;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x3 = fsData(:,3);
    y3 = delpowerMW;
    
    %# CONDITION 22
    fsData = fsrCond22;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x4 = fsData(:,3);
    y4 = delpowerMW;
    
    %# CONDITION 23
    fsData = fsrCond23;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x5 = fsData(:,3);
    y5 = delpowerMW;
    
    %# CONDITION 24
    fsData = fsrCond24;
    [ma,na] = size(fsData);
    delpowerMW = [];
    for k=1:ma
        delpowerMW(k) = ((fsData(k,42)+fsData(k,43))*2)/1000^2;
    end
    x6 = fsData(:,3);
    y6 = delpowerMW;
    
    %# Plotting ---------------------------------------------------------------
    h = plot(xst,yst,'-',x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(6),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(7),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 20;
    incrY = 4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Corrected Power (Sea Trials)','FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Propulsive Efficiency vs. Ship Speed ///////////////////////////
    if enableAdjOrNotAdjCurvesPlot == 1
        subplot(2,2,4)
    else
        subplot(1,2,2)
    end
    
    %# X and Y axis -----------------------------------------------------------
    
    %# CONDITION 16
    fsData = fsrCond16;
    x1 = fsData(:,3);
    y1 = fsData(:,46);
    
    %# CONDITION 17
    fsData = fsrCond17;
    x2 = fsData(:,3);
    y2 = fsData(:,46);
    
    %# CONDITION 18
    fsData = fsrCond18;
    x3 = fsData(:,3);
    y3 = fsData(:,46);
    
    %# CONDITION 22
    fsData = fsrCond22;
    x4 = fsData(:,3);
    y4 = fsData(:,46);
    
    %# CONDITION 23
    fsData = fsrCond23;
    x5 = fsData(:,3);
    y5 = fsData(:,46);
    
    %# CONDITION 24
    fsData = fsrCond24;
    x6 = fsData(:,3);
    y6 = fsData(:,46);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Propulsive Efficiency (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Catamaran: Adj. F vs. T curves}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013:: Ca=0','FRM 2013:: Ca=0.00035','FRM 2013:: Ca=0.00059','FRM 2014:: Ca=0','FRM 2014:: Ca=0.00035','FRM 2014:: Ca=0.00059');
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_5_1_Power_Ca_0_000035_And_000059_WS_With_Rudder_Components.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber5Plot


%# ************************************************************************
%# 6. Plotting Comparisons: Thrust Deduction
%# ************************************************************************

if enableNumber6Plot == 1
    %# Plotting speed -----------------------------------------------------
    figurename = 'Plot 6: Full Scale: Thrust Deduction';
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
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',12,...
        'LineWidth',2,...
        'FontName',setGeneralFontName,...
        'Clipping','off',...
        'Color',[1 1 1],...
        'LooseInset',get(gca,'TightInset'));
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# Thrust Deduction vs. Ship Speed ////////////////////////////////////
    subplot(1,1,1)
    
    %# X and Y axis -------------------------------------------------------
    
    %# MARIN JHSV Data
    mx1 = Marin112mJHSVData(1:28,4);
    my1 = Marin112mJHSVData(1:28,5);
    
    mx2 = Marin112mJHSVData(29:54,4);
    my2 = Marin112mJHSVData(29:54,5);
    
    %# CONDITION 1
    fsData = fsrCond1;
    x1 = fsData(:,1);
    y1 = fsData(:,18);
    
    %# CONDITION 4
    fsData = fsrCond4;
    x2 = fsData(:,1);
    y2 = fsData(:,18);
    
    %# CONDITION 7
    fsData = fsrCond7;
    x3 = fsData(:,1);
    y3 = fsData(:,18);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x4 = fsData(:,1);
    y4 = fsData(:,18);
    
    %# Plotting -----------------------------------------------------------
    h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',mx1,my1,mx2,my2);
    %xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Thrust deduction fraction, t (-)}','FontSize',setGeneralFontSize);
    %if enablePlotTitle == 1
    %    title('{\bf Ca=0}','FontSize',setGeneralFontSize);
    %end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{3},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(5),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
    set(h(6),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 0.14;
    maxX  = 0.54;
    incrX = 0.05;
    minY  = -0.6;
    maxY  = 0.8;
    incrY = 0.2;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2013: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})','FRM 2014: w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})','112m MARIN JHSV Cond. T5','112m MARIN JHSV Cond. T4');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_6_Thrust_Deduction_Ca_0.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber6Plot


%# ************************************************************************
%# 7. Differences due to usage of:
%#    ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm) or ws=wm(CFs/CFm)
%# ************************************************************************

if enableNumber7Plot == 1
    
    % Differences arary
    diffArray = [];
    [m,n] = size(fsrCond1);
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 1 and 13: FRM June 13, not adjusted F vs. T curve, Ca=0         !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond1;
    dataset2 = fsrCond13;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        diffArray(k,1) = 1;     % Overall condition
        diffArray(k,2) = WF;
        diffArray(k,3) = VFR;
        diffArray(k,4) = MFR;
        diffArray(k,5) = PEFF;
        diffArray(k,6) = JVEL;
        diffArray(k,7) = IVEL;
        diffArray(k,8) = OPE;
        diffArray(k,9) = dataset1(k,1);
        diffArray(k,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 2 and 14: FRM June 13, not adjusted F vs. T curve, Ca=0.00035   !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond2;
    dataset2 = fsrCond14;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+9;
        diffArray(row,1) = 2;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 3 and 15: FRM June 13, not adjusted F vs. T curve, Ca=0.00059   !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond3;
    dataset2 = fsrCond15;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+18;
        diffArray(row,1) = 3;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 4 and 16: FRM June 13, adjusted F vs. T curve, Ca=0             !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond4;
    dataset2 = fsrCond16;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+27;
        diffArray(row,1) = 4;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 5 and 17: FRM June 13, adjusted F vs. T curve, Ca=0.00035       !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond5;
    dataset2 = fsrCond17;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+36;
        diffArray(row,1) = 5;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 6 and 18: FRM June 13, adjusted F vs. T curve, Ca=0.00059       !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond6;
    dataset2 = fsrCond18;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+45;
        diffArray(row,1) = 6;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 7 and 19: FRM Sept. 14, not adjusted F vs. T curve, Ca=0        !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond7;
    dataset2 = fsrCond19;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+54;
        diffArray(row,1) = 7;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 8 and 20: FRM Sept. 14, not adjusted F vs. T curve, Ca=0.00035  !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond8;
    dataset2 = fsrCond20;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+63;
        diffArray(row,1) = 8;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 9 and 21: FRM Sept. 14, not adjusted F vs. T curve, Ca=0.00059  !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond9;
    dataset2 = fsrCond21;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+72;
        diffArray(row,1) = 9;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 10 and 22: FRM Sept. 14, not adjusted F vs. T curve, Ca=0        !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond10;
    dataset2 = fsrCond22;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+81;
        diffArray(row,1) = 10;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 11 and 23: FRM Sept. 14, not adjusted F vs. T curve, Ca=0.00035 !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond11;
    dataset2 = fsrCond23;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+90;
        diffArray(row,1) = 11;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end
    
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Conditions 12 and 24: FRM Sept. 14, not adjusted F vs. T curve, Ca=0.00059 !');
    disp('!Differences when using ws=wm(CFs/CFm) or ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dataset1 = fsrCond12;
    dataset2 = fsrCond24;
    for k=1:m
        WF   = (1-(dataset1(k,16)/dataset2(k,16)))*100;  % Wake fraction
        VFR  = (1-(dataset1(k,22)/dataset2(k,22)))*100;  % Volumetric flow rate
        MFR  = (1-(dataset1(k,24)/dataset2(k,24)))*100;  % Mass flow rate
        PEFF = (1-(dataset1(k,38)/dataset2(k,38)))*100;  % Pump efficiency
        JVEL = (1-(dataset1(k,26)/dataset2(k,26)))*100;  % Inlet velocity
        IVEL = (1-(dataset1(k,28)/dataset2(k,28)))*100;  % Jet velocity
        OPE  = (1-(dataset1(k,46)/dataset2(k,46)))*100;  % Porpulsive eff.
        row = k+99;
        diffArray(row,1) = 12;     % Overall condition
        diffArray(row,2) = WF;
        diffArray(row,3) = VFR;
        diffArray(row,4) = MFR;
        diffArray(row,5) = PEFF;
        diffArray(row,6) = JVEL;
        diffArray(row,7) = IVEL;
        diffArray(row,8) = OPE;
        diffArray(row,9) = dataset1(k,1);
        diffArray(row,10) = dataset1(k,3);
        disp(sprintf('Speed %s (Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',num2str(k),sprintf('%.1f',WF),sprintf('%.1f',VFR),sprintf('%.1f',MFR),sprintf('%.1f',PEFF),sprintf('%.1f',JVEL),sprintf('%.1f',IVEL),sprintf('%.1f',OPE)));
    end

    % AVERAGED DIFFERENCES: Condition 1-2 ---------------------------------
    runCond = '1-3';
    runRows = 1:27;
    % Min
    minWF   = min(diffArray(runRows,2));
    minVFR  = min(diffArray(runRows,3));
    minMFR  = min(diffArray(runRows,4));
    minPEFF = min(diffArray(runRows,5));
    minJVEL = min(diffArray(runRows,6));
    minIVEL = min(diffArray(runRows,7));
    minOPE  = min(diffArray(runRows,8)); 
    % Max
    maxWF   = max(diffArray(runRows,2));
    maxVFR  = max(diffArray(runRows,3));
    maxMFR  = max(diffArray(runRows,4));
    maxPEFF = max(diffArray(runRows,5));
    maxJVEL = max(diffArray(runRows,6));
    maxIVEL = max(diffArray(runRows,7));
    maxOPE  = max(diffArray(runRows,8));    
    % Mean
    avgWF   = mean(diffArray(runRows,2));
    avgVFR  = mean(diffArray(runRows,3));
    avgMFR  = mean(diffArray(runRows,4));
    avgPEFF = mean(diffArray(runRows,5));
    avgJVEL = mean(diffArray(runRows,6));
    avgIVEL = mean(diffArray(runRows,7));
    avgOPE  = mean(diffArray(runRows,8));
    disp('-----------------------------------------------------------------');
    disp(sprintf('Conditions %s (Min Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',minWF),sprintf('%.1f',minVFR),sprintf('%.1f',minMFR),sprintf('%.1f',minPEFF),sprintf('%.1f',minJVEL),sprintf('%.1f',minIVEL),sprintf('%.1f',minOPE)));
    disp(sprintf('Conditions %s (Max Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',maxWF),sprintf('%.1f',maxVFR),sprintf('%.1f',maxMFR),sprintf('%.1f',maxPEFF),sprintf('%.1f',maxJVEL),sprintf('%.1f',maxIVEL),sprintf('%.1f',maxOPE)));
    disp(sprintf('Conditions %s (Avg. Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',avgWF),sprintf('%.1f',avgVFR),sprintf('%.1f',avgMFR),sprintf('%.1f',avgPEFF),sprintf('%.1f',avgJVEL),sprintf('%.1f',avgIVEL),sprintf('%.1f',avgOPE)));
    
    % AVERAGED DIFFERENCES: Condition 3-6 ---------------------------------
    runCond = '4-6';
    runRows = 28:54;
    % Min
    minWF   = min(diffArray(runRows,2));
    minVFR  = min(diffArray(runRows,3));
    minMFR  = min(diffArray(runRows,4));
    minPEFF = min(diffArray(runRows,5));
    minJVEL = min(diffArray(runRows,6));
    minIVEL = min(diffArray(runRows,7));
    minOPE  = min(diffArray(runRows,8)); 
    % Max
    maxWF   = max(diffArray(runRows,2));
    maxVFR  = max(diffArray(runRows,3));
    maxMFR  = max(diffArray(runRows,4));
    maxPEFF = max(diffArray(runRows,5));
    maxJVEL = max(diffArray(runRows,6));
    maxIVEL = max(diffArray(runRows,7));
    maxOPE  = max(diffArray(runRows,8));    
    % Mean
    avgWF   = mean(diffArray(runRows,2));
    avgVFR  = mean(diffArray(runRows,3));
    avgMFR  = mean(diffArray(runRows,4));
    avgPEFF = mean(diffArray(runRows,5));
    avgJVEL = mean(diffArray(runRows,6));
    avgIVEL = mean(diffArray(runRows,7));
    avgOPE  = mean(diffArray(runRows,8));
    disp('-----------------------------------------------------------------');
    disp(sprintf('Conditions %s (Min Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',minWF),sprintf('%.1f',minVFR),sprintf('%.1f',minMFR),sprintf('%.1f',minPEFF),sprintf('%.1f',minJVEL),sprintf('%.1f',minIVEL),sprintf('%.1f',minOPE)));
    disp(sprintf('Conditions %s (Max Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',maxWF),sprintf('%.1f',maxVFR),sprintf('%.1f',maxMFR),sprintf('%.1f',maxPEFF),sprintf('%.1f',maxJVEL),sprintf('%.1f',maxIVEL),sprintf('%.1f',maxOPE)));
    disp(sprintf('Conditions %s (Avg. Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',avgWF),sprintf('%.1f',avgVFR),sprintf('%.1f',avgMFR),sprintf('%.1f',avgPEFF),sprintf('%.1f',avgJVEL),sprintf('%.1f',avgIVEL),sprintf('%.1f',avgOPE)));
    
    % AVERAGED DIFFERENCES: Condition 7-9 ---------------------------------
    runCond = '7-9';
    runRows = 55:81;
    % Min
    minWF   = min(diffArray(runRows,2));
    minVFR  = min(diffArray(runRows,3));
    minMFR  = min(diffArray(runRows,4));
    minPEFF = min(diffArray(runRows,5));
    minJVEL = min(diffArray(runRows,6));
    minIVEL = min(diffArray(runRows,7));
    minOPE  = min(diffArray(runRows,8)); 
    % Max
    maxWF   = max(diffArray(runRows,2));
    maxVFR  = max(diffArray(runRows,3));
    maxMFR  = max(diffArray(runRows,4));
    maxPEFF = max(diffArray(runRows,5));
    maxJVEL = max(diffArray(runRows,6));
    maxIVEL = max(diffArray(runRows,7));
    maxOPE  = max(diffArray(runRows,8));    
    % Mean
    avgWF   = mean(diffArray(runRows,2));
    avgVFR  = mean(diffArray(runRows,3));
    avgMFR  = mean(diffArray(runRows,4));
    avgPEFF = mean(diffArray(runRows,5));
    avgJVEL = mean(diffArray(runRows,6));
    avgIVEL = mean(diffArray(runRows,7));
    avgOPE  = mean(diffArray(runRows,8));
    disp('-----------------------------------------------------------------');
    disp(sprintf('Conditions %s (Min Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',minWF),sprintf('%.1f',minVFR),sprintf('%.1f',minMFR),sprintf('%.1f',minPEFF),sprintf('%.1f',minJVEL),sprintf('%.1f',minIVEL),sprintf('%.1f',minOPE)));
    disp(sprintf('Conditions %s (Max Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',maxWF),sprintf('%.1f',maxVFR),sprintf('%.1f',maxMFR),sprintf('%.1f',maxPEFF),sprintf('%.1f',maxJVEL),sprintf('%.1f',maxIVEL),sprintf('%.1f',maxOPE)));
    disp(sprintf('Conditions %s (Avg. Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',avgWF),sprintf('%.1f',avgVFR),sprintf('%.1f',avgMFR),sprintf('%.1f',avgPEFF),sprintf('%.1f',avgJVEL),sprintf('%.1f',avgIVEL),sprintf('%.1f',avgOPE)));
    
    % AVERAGED DIFFERENCES: Condition 10-12 -------------------------------
    runCond = '10-12';
    runRows = 82:108;
    % Min
    minWF   = min(diffArray(runRows,2));
    minVFR  = min(diffArray(runRows,3));
    minMFR  = min(diffArray(runRows,4));
    minPEFF = min(diffArray(runRows,5));
    minJVEL = min(diffArray(runRows,6));
    minIVEL = min(diffArray(runRows,7));
    minOPE  = min(diffArray(runRows,8)); 
    % Max
    maxWF   = max(diffArray(runRows,2));
    maxVFR  = max(diffArray(runRows,3));
    maxMFR  = max(diffArray(runRows,4));
    maxPEFF = max(diffArray(runRows,5));
    maxJVEL = max(diffArray(runRows,6));
    maxIVEL = max(diffArray(runRows,7));
    maxOPE  = max(diffArray(runRows,8));    
    % Mean
    avgWF   = mean(diffArray(runRows,2));
    avgVFR  = mean(diffArray(runRows,3));
    avgMFR  = mean(diffArray(runRows,4));
    avgPEFF = mean(diffArray(runRows,5));
    avgJVEL = mean(diffArray(runRows,6));
    avgIVEL = mean(diffArray(runRows,7));
    avgOPE  = mean(diffArray(runRows,8));
    disp('-----------------------------------------------------------------');
    disp(sprintf('Conditions %s (Min Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',minWF),sprintf('%.1f',minVFR),sprintf('%.1f',minMFR),sprintf('%.1f',minPEFF),sprintf('%.1f',minJVEL),sprintf('%.1f',minIVEL),sprintf('%.1f',minOPE)));
    disp(sprintf('Conditions %s (Max Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',maxWF),sprintf('%.1f',maxVFR),sprintf('%.1f',maxMFR),sprintf('%.1f',maxPEFF),sprintf('%.1f',maxJVEL),sprintf('%.1f',maxIVEL),sprintf('%.1f',maxOPE)));
    disp(sprintf('Conditions %s (Avg. Differences): ws=%s%%, VFR=%s%%, MFR=%s%%, PEFF=%s%%, JVEL=%s%%, IVEL=%s%%, OPE=%s%%',runCond,sprintf('%.1f',avgWF),sprintf('%.1f',avgVFR),sprintf('%.1f',avgMFR),sprintf('%.1f',avgPEFF),sprintf('%.1f',avgJVEL),sprintf('%.1f',avgIVEL),sprintf('%.1f',avgOPE)));
    
    %# Split array by overall condition (column 1)
    R = diffArray;
    A = arrayfun(@(x) R(R(:,1) == x, :), unique(R(:,1)), 'uniformoutput', false);
    [ma,na] = size(A);
    
    %# ------------------------------------------------------------------------
    %# Plotting differences: Condition 1 to 3
    %# ------------------------------------------------------------------------
    %# Settings:  Flow rate measurement data: June 2013
    %#            F vs. T curves            : Not adjusted
    %#            Form factor               : 1.18
    %#            Ca values                 : 0, 0.00035 and 0.00059
    %# ------------------------------------------------------------------------
    figurename = 'Plot 7.1-3: Comparison results using different w_{s}: FRM June 2013, not adjusted.';
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
    setLegendFontSize  = 10;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# X and Y axis -----------------------------------------------------------
    
    %# Condition 1 ////////////////////////////////////////////////////////////
    subplot(3,1,1)
    
    % Plotting
    subArray = 1;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 2 ////////////////////////////////////////////////////////////
    subplot(3,1,2)
    
    % Plotting
    subArray = 2;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00035}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 3 ////////////////////////////////////////////////////////////
    subplot(3,1,3)
    
    % Plotting
    subArray = 3;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00059}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_7_1_Differences_Conditions_1-3.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    %# ------------------------------------------------------------------------
    %# Plotting differences: Condition 4 to 6
    %# ------------------------------------------------------------------------
    %# Settings:  Flow rate measurement data: June 2013
    %#            F vs. T curves            : Adjusted
    %#            Form factor               : 1.18
    %#            Ca values                 : 0, 0.00035 and 0.00059
    %# ------------------------------------------------------------------------
    figurename = 'Plot 7.4-6: Comparison results using different w_{s}: FRM June 2013, adjusted.';
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
    setLegendFontSize  = 10;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# X and Y axis -----------------------------------------------------------
    
    %# Condition 4 ////////////////////////////////////////////////////////////
    subplot(3,1,1)
    
    % Plotting
    subArray = 4;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 5 ////////////////////////////////////////////////////////////
    subplot(3,1,2)
    
    % Plotting
    subArray = 5;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00035}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 6 ////////////////////////////////////////////////////////////
    subplot(3,1,3)
    
    % Plotting
    subArray = 6;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00059}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_7_2_Differences_Conditions_4-6.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    %# ------------------------------------------------------------------------
    %# Plotting differences: Condition 7 to 9
    %# ------------------------------------------------------------------------
    %# Settings:  Flow rate measurement data: September 2014
    %#            F vs. T curves            : Not adjusted
    %#            Form factor               : 1.18
    %#            Ca values                 : 0, 0.00035 and 0.00059
    %# ------------------------------------------------------------------------
    figurename = 'Plot 7.7-9: Comparison results using different w_{s}: FRM Sept. 2014, not adjusted.';
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
    setLegendFontSize  = 10;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# X and Y axis -----------------------------------------------------------
    
    %# Condition 7 ////////////////////////////////////////////////////////////
    subplot(3,1,1)
    
    % Plotting
    subArray = 7;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 8 ////////////////////////////////////////////////////////////
    subplot(3,1,2)
    
    % Plotting
    subArray = 8;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00035}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 9 ////////////////////////////////////////////////////////////
    subplot(3,1,3)
    
    % Plotting
    subArray = 9;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00059}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_7_3_Differences_Conditions_7-9.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    %# ------------------------------------------------------------------------
    %# Plotting differences: Condition 10 to 12
    %# ------------------------------------------------------------------------
    %# Settings:  Flow rate measurement data: September 2014
    %#            F vs. T curves            : Adjusted
    %#            Form factor               : 1.18
    %#            Ca values                 : 0, 0.00035 and 0.00059
    %# ------------------------------------------------------------------------
    figurename = 'Plot 7.10-12: Comparison of results using different w_{s}: FRM Sept. 2014, adjusted.';
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
    setLegendFontSize  = 10;
    
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
    setMarkerSize      = 10;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    
    %# X and Y axis -----------------------------------------------------------
    
    %# Condition 10 ///////////////////////////////////////////////////////////
    subplot(3,1,1)
    
    % Plotting
    subArray = 10;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 11 ///////////////////////////////////////////////////////////
    subplot(3,1,2)
    
    % Plotting
    subArray = 11;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00035}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Condition 12 ///////////////////////////////////////////////////////////
    subplot(3,1,3)
    
    % Plotting
    subArray = 12;
    bar(A{subArray}(:,10),[A{subArray}(:,3) A{subArray}(:,4) A{subArray}(:,5) A{subArray}(:,6) A{subArray}(:,7) A{subArray}(:,8)]);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Difference (%)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf Ca=0.00059}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    %axis square;
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 2;
    minY  = -20;
    maxY  = 20;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Volumetric flow rate','Mass flow rate','Pump efficiency','Jet velocity','Inlet velocity','Propulsive efficiency');
    set(hleg1,'Location','EastOutside');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_7_4_Differences_Conditions_10-12.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber7Plot


%# ************************************************************************
%# 8. Plotting Comparisons: Wake fractions
%# ************************************************************************

if enableNumber8Plot == 1
    figurename = 'Plot 8: Full Scale and Model Scale: Wake Fraction';
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
    setLegendFontSize  = 10;
    
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
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
 
    % Model scale wake fraction -------------------------------------------
    MS_W  = [0.188 0.190 0.189 0.188 0.185 0.185 0.182 0.176 0.168];
    MS_1W = [0.812 0.810 0.811 0.812 0.815 0.815 0.818 0.824 0.832];    
    
    %#Wake Fraction vs. Ship Speed ////////////////////////////////////////
    subplot(1,2,1)
    
    %# X and Y axis -------------------------------------------------------
    x = fsrCond4(:,3);
    y = MS_W;
    
    %# CONDITION 4
    fsData = fsrCond4;
    x1 = fsData(:,3);
    y1 = fsData(:,16);
    
    %# CONDITION 5
    fsData = fsrCond5;
    x2 = fsData(:,3);
    y2 = fsData(:,16);
    
    %# CONDITION 6
    fsData = fsrCond6;
    x3 = fsData(:,3);
    y3 = fsData(:,16);
    
    %# CONDITION 10
    fsData = fsrCond10;
    x4 = fsData(:,3);
    y4 = fsData(:,16);
    
    %# CONDITION 11
    fsData = fsrCond11;
    x5 = fsData(:,3);
    y5 = fsData(:,16);
    
    %# CONDITION 12
    fsData = fsrCond12;
    x6 = fsData(:,3);
    y6 = fsData(:,16);
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond4);
    WFArray = [];
    fsData1 = fsrCond4;
    fsData2 = fsrCond5;
    fsData3 = fsrCond6;
    fsData4 = fsrCond10;
    fsData5 = fsrCond11;
    fsData6 = fsrCond12;
    for kl=1:meb
        effArray1 = [fsData1(kl,16) fsData3(kl,16) fsData2(kl,16)];
        effArray2 = [fsData4(kl,16) fsData5(kl,16) fsData6(kl,16)];
        % Standard deviation
        WFArray(kl,1) = std(effArray1,1);
        WFArray(kl,2) = std(effArray2,1);
        % Mean/average
        WFArray(kl,3) = mean(effArray1);
        WFArray(kl,4) = mean(effArray2);
    end
    
    %# Plotting -----------------------------------------------------------
    h = plot(x,y,'*',x2,y2,'*',x5,y5,'*');
    % Error bars based on STD
    %hold on;
    %h1 = errorbar(x2,y2,WFArray(:,1),'k');
    %set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    %hold on;
    %h1 = errorbar(x5,y5,WFArray(:,2),'k');
    %set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Wake fraction, (1-w) (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf w_{s}=w_{m}(C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize); % ws=wm(CFs/CFm)+(t+0.04)(1-CFs/CFm)
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{1},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = -0.2;
    maxY  = 0.8;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('w_{m} (Model scale wake fraction)','w_{s1} (FRM June 2013)','w_{s2} (FRM Sept. 2014)');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
 
    %#Wake Fraction vs. Ship Speed ////////////////////////////////////////
    subplot(1,2,2)
    
    %# X and Y axis -------------------------------------------------------
    x = fsrCond4(:,3);
    y = MS_W;
    
    %# CONDITION 16
    fsData = fsrCond16;
    x1 = fsData(:,3);
    y1 = fsData(:,16);
    
    %# CONDITION 17
    fsData = fsrCond17;
    x2 = fsData(:,3);
    y2 = fsData(:,16);
    
    %# CONDITION 18
    fsData = fsrCond18;
    x3 = fsData(:,3);
    y3 = fsData(:,16);
    
    %# CONDITION 22
    fsData = fsrCond22;
    x4 = fsData(:,3);
    y4 = fsData(:,16);
    
    %# CONDITION 23
    fsData = fsrCond23;
    x5 = fsData(:,3);
    y5 = fsData(:,16);
    
    %# CONDITION 24
    fsData = fsrCond24;
    x6 = fsData(:,3);
    y6 = fsData(:,16);
    
    % Descriptive statistics: Calculate Standard Deviation (StDev)
    [meb,neb] = size(fsrCond4);
    WFArray = [];
    fsData1 = fsrCond16;
    fsData2 = fsrCond17;
    fsData3 = fsrCond19;
    fsData4 = fsrCond22;
    fsData5 = fsrCond23;
    fsData6 = fsrCond24;
    for kl=1:meb
        effArray1 = [fsData1(kl,16) fsData3(kl,16) fsData2(kl,16)];
        effArray2 = [fsData4(kl,16) fsData5(kl,16) fsData6(kl,16)];
        % Standard deviation
        WFArray(kl,1) = std(effArray1,1);
        WFArray(kl,2) = std(effArray2,1);
        % Mean/average
        WFArray(kl,3) = mean(effArray1);
        WFArray(kl,4) = mean(effArray2);
    end
    
    %# Plotting -----------------------------------------------------------
    h = plot(x,y,'*',x2,y2,'*',x5,y5,'*');
    % Error bars based on STD
    %hold on;
    %h1 = errorbar(x2,y2,WFArray(:,1),'k');
    %set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    %hold on;
    %h1 = errorbar(x5,y5,WFArray(:,2),'k');
    %set(h1,'Marker','none','LineStyle','none','LineWidth',1);
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Wake fraction, (1-w) (-)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1
        title('{\bf w_{s}=w_{m}(C_{Fs}/C_{Fm})+(t+0.04)(1-C_{Fs}/C_{Fm})}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(2),'Color',setColor{1},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h(3),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = -0.2;
    maxY  = 0.8;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('w_{m} (Model scale wake fraction)','w_{s1} (FRM June 2013)','w_{s2} (FRM Sept. 2014)');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_8_Wake_Fractions.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber8Plot


%# ************************************************************************
%# 9. Cprrected Sea Trials Data (Delivered Power)
%# ************************************************************************

if enableNumber9Plot == 1
    figurename = 'Plot 8: Full Scale and Model Scale: Wake Fraction';
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
    setLegendFontSize  = 10;
    
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
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 12;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineStyle       = '-';
    setLineStyle1      = '-.';

    %#FS PD (Sea Trials) vs. Ship Speed ///////////////////////////////////
    subplot(1,1,1)
    
    %# X and Y axis -------------------------------------------------------

    x1 = SeaTrialsCorrectedPower(:,1);
    y1 = SeaTrialsCorrectedPower(:,2);
    
    x2 = SeaTrialsCorrectedPower(:,1);
    y2 = SeaTrialsCorrectedPower(:,3);
    
    % Fitting curve through sea trials delivered power
    fitobject1 = fit(x1,y1,'poly5');
    cvalues1   = coeffvalues(fitobject1);
    
    fitobject2 = fit(x2,y2,'poly5');
    cvalues2   = coeffvalues(fitobject2);    
    
    % Sea Trials Data
    fittingSpeeds = [10:1:38];
    [mfs,nfs] = size(fittingSpeeds);
    
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues1(1)*actSpeed^5+cvalues1(2)*actSpeed^4+cvalues1(3)*actSpeed^3+cvalues1(4)*actSpeed^2+cvalues1(5)*actSpeed+cvalues1(6);
    end
    xst1  = fittingSpeeds;
    yst1  = delpowerMW;
    
    delpowerMW = [];
    for k=1:nfs
        actSpeed = fittingSpeeds(k);
        delpowerMW(k) = cvalues2(1)*actSpeed^5+cvalues2(2)*actSpeed^4+cvalues2(3)*actSpeed^3+cvalues2(4)*actSpeed^2+cvalues2(5)*actSpeed+cvalues2(6);
    end
    xst2  = fittingSpeeds;
    yst2  = delpowerMW;
    
    %# Plotting -----------------------------------------------------------
    h = plot(xst1,yst1,'-',xst2,yst2,'-');
    xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
    if enablePlotTitle == 1 && enableAdjOrNotAdjCurvesPlot == 1
        title('{\bf Sea Trials Data}','FontSize',setGeneralFontSize);
    end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    set(h(2),'Color',setColor{2},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    minX  = 10;
    maxX  = 38;
    incrX = 4;
    minY  = 0;
    maxY  = 35;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Uncorrected Power (Sea Trials)','Corrected Power (Sea Trials)');
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;    
    
    %# Font sizes and border ----------------------------------------------
    
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
        plotsavename = sprintf('_plots/%s/%s/FS_Result_Comp_Plot_9_Corrected_Sea_Trials_Data_Delivered_Power.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
end % enableNumber9Plot

    
% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile viewer
end
