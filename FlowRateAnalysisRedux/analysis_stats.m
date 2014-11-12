%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Simple statistics
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 12, 2014
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
enableEqnOfFitPlot      = 1;    % Show equations of fit

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
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END Define plot size
%# ************************************************************************


%# ************************************************************************
%# START Read results DAT file
%# ------------------------------------------------------------------------
if exist('resultsArray_copy.dat', 'file') == 2
    %# Results array columns:
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
    %[19] Diff. mass flow rate (mean, 1s intervals)/(overall, Q/t)  (%)
    
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

%# Repeat directory
fPath = sprintf('_plots/%s', '_kp_vs_mass_flow_rate');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', '_kp_vs_mass_flow_rate', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', '_kp_vs_mass_flow_rate', 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', '_kp_vs_mass_flow_rate', 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END Create directories if not available
%# ************************************************************************


%# ------------------------------------------------------------------------
%# Set run numbers based on conditions
%# ------------------------------------------------------------------------

%# Array size -------------------------------------------------------------

[m,n] = size(results);

% Brake script if resultsArray not complete
if m ~= 67
    disp('-----------------------------------------------------------------');
    disp('Data in resultsArray_copy.dat not complete (i.e. 67 datasets)!');
    disp('-----------------------------------------------------------------');
    break;
end

%# Distinguish between PORT and STBD --------------------------------------
testRuns = results(1:7,:);
portRuns = results(8:37,:);
stbdRuns = results(38:end,:);

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
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for June 2013 Flow Rate Measurement Test (June2013FRMT.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end

%# Averaging port and stbd repeated runs ----------------------------------

%# Columns:
%[1]  Set shaft speed                       (RPM)
%[2]  Prop. system                          (1 = Port, 2 = Stbd)
%[3]  Measured shaft Speed STBD             (RPM)
%[4]  Measured shaft Speed PORT             (RPM)
%[5]  Mass Flow rate                        (Kg/s)
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
%[15] Mass Flow rate (1s only)              (Kg/s)
%[16] Mass flow rate (mean, 1s intervals)   (Kg/s)
%[17] Mass flow rate (overall, Q/t)         (Kg/s)

%# PORT (averaged repeated runs) ------------------------------------------
portAvgArray = [];
portAvgArray = [portAvgArray;stats_avg(1,800,results(8,:))];
portAvgArray = [portAvgArray;stats_avg(1,1000,results(9:11,:))];
portAvgArray = [portAvgArray;stats_avg(1,1200,results([12 16],:))];
portAvgArray = [portAvgArray;stats_avg(1,1400,results([13:15 17],:))];
portAvgArray = [portAvgArray;stats_avg(1,1600,results(18,:))];
portAvgArray = [portAvgArray;stats_avg(1,1800,results(19:21,:))];
portAvgArray = [portAvgArray;stats_avg(1,2000,results(22,:))];
portAvgArray = [portAvgArray;stats_avg(1,2200,results(23:25,:))];
portAvgArray = [portAvgArray;stats_avg(1,2400,results(26,:))];
portAvgArray = [portAvgArray;stats_avg(1,2600,results(27:29,:))];
portAvgArray = [portAvgArray;stats_avg(1,2800,results(30,:))];
portAvgArray = [portAvgArray;stats_avg(1,3000,results(31:33,:))];
portAvgArray = [portAvgArray;stats_avg(1,3200,results(34,:))];
portAvgArray = [portAvgArray;stats_avg(1,3400,results(35:37,:))];

%# STBD (averaged repeated runs) ------------------------------------------
stbdAvgArray = [];
stbdAvgArray = [stbdAvgArray;stats_avg(2,800,results(40,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,1000,results([38 41:43],:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,1200,results(44,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,1400,results(45:47,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,1600,results(48,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,1800,results(49:51,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,2000,results([39 52],:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,2200,results(53:55,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,2400,results(56,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,2600,results(57:59,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,2800,results(60,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,3000,results(61:63,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,3200,results(64,:))];
stbdAvgArray = [stbdAvgArray;stats_avg(2,3400,results(65:67,:))];

%# Averaged mean runs -----------------------------------------------------
stbdportAvgArray = [];

[mpaa,npaa] = size(portAvgArray);
[msaa,nsaa] = size(stbdAvgArray);

% Brake script averaged arrays are not the same size
if mpaa ~= msaa
    disp('----------------------------------------------------');
    disp('portAvgArray and stbdAvgArray are not the same size!');
    disp('----------------------------------------------------');
    break;
end

% Average portAvgArray and stbdAvgArray arrays ----------------------------

%# Columns:
%[1]  Set shaft speed                       (RPM)
%[2]  Measured shaft Speed                  (RPM)
%[3]  Mass Flow rate                        (Kg/s)
%[4]  Kiel probe                            (V)
%[5]  Torque                                (Nm)
%[6]  Volumetric flow rate                  (m3/s)
%[7]  Flow coefficient                      (-)
%[8]  Jet velocity                          (m/s)

for k=1:mpaa
    stbdportAvgArray(k,1) = mean([stbdAvgArray(k,1) portAvgArray(k,1)]);
    stbdportAvgArray(k,2) = round(mean([stbdAvgArray(k,3) portAvgArray(k,4)]));
    stbdportAvgArray(k,3) = mean([stbdAvgArray(k,5) portAvgArray(k,5)]);
    stbdportAvgArray(k,4) = mean([stbdAvgArray(k,6) portAvgArray(k,7)]);
    stbdportAvgArray(k,5) = mean([stbdAvgArray(k,10) portAvgArray(k,11)]);
    stbdportAvgArray(k,6) = mean([stbdAvgArray(k,12) portAvgArray(k,12)]);
    stbdportAvgArray(k,7) = mean([stbdAvgArray(k,13) portAvgArray(k,13)]);
    stbdportAvgArray(k,8) = mean([stbdAvgArray(k,14) portAvgArray(k,14)]);
end

%# ------------------------------------------------------------------------
%# Plot kiel probe voltage against mass flow rate
%# ------------------------------------------------------------------------

%# Plotting gross thrust vs. towing force
figurename = 'Flow Rate Measurement Test: Kiel Probe Voltage vs. Mass Flow Rate';
%figurename = sprintf('%s:: RPM Logger (Raw Data), Run %s', testName, num2str(runno));
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
setMarkerSize      = 10;
setLineWidth       = 1;
setLineWidth1      = 2;
setLineWidthMarker = 2;

setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';
setLineStyle4      = '--';

% X and Y values ----------------------------------------------------------

% Port (June 2013)
xPort13 = June13Port(:,4);
yPort13 = June13Port(:,3);

% Stbd (June 2013)
xStbd13 = June13Stbd(:,4);
yStbd13 = June13Stbd(:,3);

% Port (Sept. 2014)
xPort14 = portAvgArray(:,7);
yPort14 = portAvgArray(:,5);

% Stbd (Sept. 2014)
xStbd14 = stbdAvgArray(:,6);
yStbd14 = stbdAvgArray(:,5);

% Port and Stbd averaged (Sept. 2014)
if enableAvgPortStbdPlot == 1
    xPortStbdAvg14 = stbdportAvgArray(:,4);
    yPortStbdAvg14 = stbdportAvgArray(:,3);
end

% Equation of fit
EqnOfFitArray = [];
EqnOfFitKP    = [1:0.2:4.4];
[meof,neof]   = size(EqnOfFitKP);

%# Columns:
%[1]  Kiel probe output             (V)
%[2]  Stbd mass flow rate           (Kg/s}
%[3]  Port mass flow rate           (Kg/s}

for kj=1:neof
    KPValue = EqnOfFitKP(kj);
    EqnOfFitArray(kj, 1) = KPValue;
    EqnOfFitArray(kj, 2) = -0.0946*KPValue^4+1.1259*KPValue^3-5.0067*KPValue^2+11.0896*KPValue-6.8705;
    EqnOfFitArray(kj, 3) = -0.0421*KPValue^4+0.5718*KPValue^3-2.9517*KPValue^2+7.8517*KPValue-5.1976;
end

% Polynomial fit ----------------------------------------------------------

setPolyOrder = 4;

% Port (June 2013)
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

% Port (Sept. 2014)
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

% Stbd (Sept. 2014)
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

% Display in command window -----------------------------------------------

% Set number of decimals in command window output
if enableCurveFittingToolboxPlot == 1
    % Decimals
    setDec1 = '%0.4f';
    setDec2 = '+%0.4f';
    setDec3 = '+%0.4f';
    setDec4 = '+%0.4f';
    setDec5 = '+%0.4f';
    
    % Port (June 2013)
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
    gofa = sprintf('%0.3f',gofa.rsquare);
    EoFEqn = sprintf('Port (June 2013): %sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
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
    gofa = sprintf('%0.3f',gofa.rsquare);
    EoFEqn = sprintf('Stbd (June 2013): %sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
    disp(EoFEqn);
    
    % Port (Sept. 2014)
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
    gofa = sprintf('%0.3f',gofa.rsquare);
    EoFEqn = sprintf('Port (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
    disp(EoFEqn);
    
    % Stbd (Sept. 2014)
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
    gofa = sprintf('%0.3f',gofa.rsquare);
    EoFEqn = sprintf('Stbd (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
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
        gofa = sprintf('%0.3f',gofa.rsquare);
        EoFEqn = sprintf('Avg. Port/Stbd (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofa);
        disp(EoFEqn);
    end
else
    setPostDecimals = '+%0.4f';
    setNeutDecimals = '%0.4f';
    
    % Port (June 2013)
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
    rSquared = sprintf('%0.3f',Rsq1);
    EQoFit1  = sprintf('Port (June 2013): %sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
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
    rSquared = sprintf('%0.3f',Rsq2);
    EQoFit2  = sprintf('Stbd (June 2013): %sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
    disp(EQoFit2);
    
    % Port (Sept. 2014)
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
    rSquared = sprintf('%0.3f',Rsq3);
    EQoFit3  = sprintf('Port (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
    disp(EQoFit3);
    
    % Stbd (Sept. 2014)
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
    rSquared = sprintf('%0.3f',Rsq4);
    EQoFit4  = sprintf('Stbd (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
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
        rSquared = sprintf('%0.3f',Rsq5);
        EQoFit5  = sprintf('Avg. Port/Stbd (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
        disp(EQoFit5);
    end
end

% Plotting ----------------------------------------------------------------
if enableCurveFittingToolboxPlot == 1
    if enableAvgPortStbdPlot == 1
        % Port (June 2013)
        h = plot(xPort13,yPort13,'*');
        legendInfo{1} = 'Port (June 2013)';
        set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject1,'-.');
        legendInfo{2} = 'Port (June 2013) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
        hold on;
        
        % Stbd (June 2013)
        h = plot(xStbd13,yStbd13,'*');
        legendInfo{3} = 'Stbd (June 2013)';
        set(h(1),'Color',setColor{5},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject2,'-.');
        legendInfo{4} = 'Stbd (June 2013) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
        hold on;
        
        % Port (Sept. 2014)
        h = plot(xPort14,yPort14,'*');
        legendInfo{5} = 'Port (Sept. 2014)';
        set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject3,'-.');
        legendInfo{6} = 'Port (Sept. 2014) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle3,'linewidth',setLineWidth);
        hold on;
        
        % Stbd (Sept. 2014)
        h = plot(xStbd14,yStbd14,'*');
        legendInfo{7} = 'Stbd (Sept. 2014)';
        set(h(1),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject4,'-.');
        legendInfo{8} = 'Stbd (Sept. 2014) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle4,'linewidth',setLineWidth);
        hold on;
        
        % Port and Stbd averaged (Sept. 2014)
        h = plot(xPortStbdAvg14,yPortStbdAvg14,'*');
        legendInfo{9} = 'Port and Stbd averaged (Sept. 2014)';
        set(h(1),'Color',setColor{6},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject5,'-');
        legendInfo{10} = 'Port and Stbd averaged (Sept. 2014) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth1);
    else
        % Port (June 2013)
        h = plot(xPort13,yPort13,'*');
        legendInfo{1} = 'Port (June 2013)';
        set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject1,'-.');
        legendInfo{2} = 'Port (June 2013) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
        hold on;
        
        % Stbd (June 2013)
        h = plot(xStbd13,yStbd13,'*');
        legendInfo{3} = 'Stbd (June 2013)';
        set(h(1),'Color',setColor{5},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject2,'-.');
        legendInfo{4} = 'Stbd (June 2013) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);
        hold on;
        
        % Port (Sept. 2014)
        h = plot(xPort14,yPort14,'*');
        legendInfo{5} = 'Port (Sept. 2014)';
        set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject3,'-.');
        legendInfo{6} = 'Port (Sept. 2014) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle3,'linewidth',setLineWidth);
        hold on;
        
        % Stbd (Sept. 2014)
        h = plot(xStbd14,yStbd14,'*');
        legendInfo{7} = 'Stbd (Sept. 2014)';
        set(h(1),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        hold on;
        h = plot(fitobject4,'-.');
        legendInfo{8} = 'Stbd (Sept. 2014) Fit';
        set(h(1),'Color',setColor{10},'LineStyle',setLineStyle4,'linewidth',setLineWidth);
    end
else
    if enableAvgPortStbdPlot == 1
        h1 = plot(xPort13,yPort13,setMarker{1},...
            xStbd13,yStbd13,setMarker{2},...
            xPort14,yPort14,setMarker{5},...
            xStbd14,yStbd14,setMarker{8},...
            xPortStbdAvg14,yPortStbdAvg14,setMarker{4});
        if enableEqnOfFitPlot == 1
            hold on;
            h2 = plot(xPort13,pvPort13,'-.',...
                xStbd13,pvStbd13,'-.',...
                xPort14,pvPort14,'-.',...
                xStbd14,pvStbd14,'-.',...
                xPortStbdAvg14,pvPortStbd14,'--');
        end
    else
        h1 = plot(xPort13,yPort13,setMarker{1},...
            xStbd13,yStbd13,setMarker{2},...
            xPort14,yPort14,setMarker{5},...
            xStbd14,yStbd14,setMarker{8});
        if enableEqnOfFitPlot == 1
            hold on;
            h2 = plot(xPort13,pvPort13,'-.',...
                xStbd13,pvStbd13,'-.',...
                xPort14,pvPort14,'-.',...
                xStbd14,pvStbd14,'-.');
        end
    end
end
if enablePlotTitle == 1
    title('{\bf Kiel Probe Output vs. Mass Flow Rate}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Kiel probe output (V)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass flow rate (Kg/s)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

% Box thickness, axes font size, etc. -------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line, colors and markers -----------------------------------------------

% Port (June 2013)
if enableCurveFittingToolboxPlot == 0
    
    % Overwrite line style
    setLineStyle = '-.';
    
    set(h1(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableEqnOfFitPlot == 1
        set(h2(1),'Color',setColor{2},'LineStyle',setLineStyle,'LineWidth',setLineWidth);
    end
    
    % Stbd (June 2013)
    set(h1(2),'Color',setColor{5},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableEqnOfFitPlot == 1
        set(h2(2),'Color',setColor{5},'LineStyle',setLineStyle,'LineWidth',setLineWidth);
    end
    
    % Port (Sept. 2014)
    set(h1(3),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableEqnOfFitPlot == 1
        set(h2(3),'Color',setColor{1},'LineStyle',setLineStyle,'LineWidth',setLineWidth);
    end
    
    % Stbd (Sept. 2014)
    set(h1(4),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    if enableEqnOfFitPlot == 1
        set(h2(4),'Color',setColor{3},'LineStyle',setLineStyle,'LineWidth',setLineWidth);
    end
    
    % Port and Stbd averaged (Sept. 2014)
    if enableAvgPortStbdPlot == 1
        set(h1(5),'Color',setColor{6},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        if enableEqnOfFitPlot == 1
            set(h2(5),'Color',setColor{6},'LineStyle','--','LineWidth',setLineWidth);
        end
    end
end

%# Text on plot -----------------------------------------------------------
if enableTextOnPlot == 1
    text(1.5, 1.0, EQoFit1, 'Color', 'k');
    text(1.5, 0.8, EQoFit2, 'Color', 'k');
    text(1.5, 0.6, EQoFit3, 'Color', 'k');
    text(1.5, 0.4, EQoFit4, 'Color', 'k');
    if enableAvgPortStbdPlot == 1
        text(1.5, 0.2, EQoFit5, 'Color', 'k');
    end
end

%# Axis limitations -------------------------------------------------------
xlim([1 4.5]);
%ylim([y(1) y(end)]);
ylim([0 5.5]);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend -----------------------------------------------------------------

%hleg1 = legend('Port (June 2013)','Fit','Starboard (June 2013)','Fit','Port (Sept. 2014)','Fit','Starboard (Sept. 2014)','Fit');
if enableCurveFittingToolboxPlot == 1
    hleg1 = legend(legendInfo);
    legendLoc = 'SouthEast';
else
    legendLoc = 'NorthWest';
    if enableAvgPortStbdPlot == 1
        hleg1 = legend(h1, 'Port (June 2013)','Starboard (June 2013)','Port (Sept. 2014)','Starboard (Sept. 2014)','Averaged Port/Starboard (Sept. 2014)');
        legendLoc = 'SouthEast';
    else
        hleg1 = legend(h1, 'Port (June 2013)','Starboard (June 2013)','Port (Sept. 2014)','Starboard (Sept. 2014)');
    end
end
set(hleg1,'Location',legendLoc);
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
    plotsavename = sprintf('_plots/%s/%s/Run_%s_to_%s_Kiel_Probe_vs_Mass_Flow_Rate_Plot.%s', '_kp_vs_mass_flow_rate', setFileFormat{k}, num2str(minRun), num2str(maxRun), setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ------------------------------------------------------------------------
%# Clear variables
%# ------------------------------------------------------------------------

clearvars x y f h h1 h2 k kj
clearvars setPostDecimals setNeutDecimals
clearvars m n mpaa npaa msaa nsaa maaa naaa meof neof
clearvars minRun maxRun fPath figurename hleg1 plotsavename
clearvars setGeneralFontSize setBorderLineWidth setMarkerSize setSpeed
clearvars setMarker setColor setFileFormat setGeneralFontName setSaveFormat setLineStyle setLineWidth setLineWidthMarker setPolyOrder
clearvars XPlot YPlot XPlotMargin YPlotMargin XPlotSize YPlotSize allPlots
clearvars portSpeed1 portSpeed2 portSpeed3 portSpeed4 portSpeed5 portSpeed6 portSpeed7 portSpeed8 portSpeed9 portSpeed10 portSpeed11 portSpeed12 portSpeed13 portSpeed14
clearvars stbdSpeed1 stbdSpeed2 stbdSpeed3 stbdSpeed4 stbdSpeed5 stbdSpeed6 stbdSpeed7 stbdSpeed8 stbdSpeed9 stbdSpeed10 stbdSpeed11 stbdSpeed12 stbdSpeed13 stbdSpeed14
clearvars pfPort13 pvPort13 pfStbd13 pvStbd13 pfPort14 pvPort14 pfStbd14 pvStbd14 pfPortStbd14 pvPortStbd14
clearvars EQoFit1 EQoFit2 EQoFit3 EQoFit4 EQoFit5 var1 var2 var3 var4 var5
clearvars dev SST resid SSE rSquared fitEqn Rsq1 Rsq2 Rsq3 Rsq4 Rsq5
clearvars June13Comb June13Port June13Stbd
clearvars xPort13 yPort13 xStbd13 yStbd13 xPort14 yPort14 xStbd14 yStbd14 xPortStbdAvg14 yPortStbdAvg14 ypred
clearvars EqnOfFitKP KPValue
