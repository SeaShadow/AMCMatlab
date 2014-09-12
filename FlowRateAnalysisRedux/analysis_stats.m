%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Simple statistics
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 8, 2014
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


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

enablePlotTitle         = 0;      % Show plot title above plot
enablePlotMainTitle     = 0;      % Show plot title in saved file
enableTextOnPlot        = 0;      % Show equation of fit text on plot
enableAvgPortStbdPlot   = 1;      % Show averaged port and stbd curve
enableBlackAndWhitePlot = 1;      % Show plot in black and white

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ------------------------------------------------------------------------
%# Read results DAT file
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
%# Create directories if not available
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
% testRuns = 1:7;
% portRuns = 8:37;
% stbdRuns = 38:67;

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
stbdAvgArray = [stbdAvgArray;stats_avg(2,1800,results(49:50,:))];
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

% Average portAvgArray and stbdAvgArray arrays

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

% Paper size settings -----------------------------------------------------

set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);

% Fonts and colours -------------------------------------------------------

setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Markes and colors ------------------------------------------------------

setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>'};
% Coloured curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1]};
% B&W curves
if enableBlackAndWhitePlot == 1
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

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

% Polynomial fit ----------------------------------------------------------

setPolyOrder = 4;

% Port (June 2013)
x = xPort13;
y = yPort13;

pfPort13 = polyfit(x,y,setPolyOrder);
pvPort13 = polyval(pfPort13,x);

ypred = pvPort13;           % Predictions
dev = y - mean(y);          % Deviations - measure of spread
SST = sum(dev.^2);          % Total variation to be accounted for
resid = y - ypred;          % Residuals - measure of mismatch
SSE = sum(resid.^2);        % Variation NOT accounted for
Rsq1 = 1 - SSE/SST;         % Percent of error explained

% Stbd (June 2013)
x = xStbd13;
y = yStbd13;

pfStbd13 = polyfit(x,y,setPolyOrder);
pvStbd13 = polyval(pfStbd13,x);

ypred = pvStbd13;           % Predictions
dev = y - mean(y);          % Deviations - measure of spread
SST = sum(dev.^2);          % Total variation to be accounted for
resid = y - ypred;          % Residuals - measure of mismatch
SSE = sum(resid.^2);        % Variation NOT accounted for
Rsq2 = 1 - SSE/SST;         % Percent of error explained

% Port (Sept. 2014)
x = xPort14;
y = yPort14;

pfPort14 = polyfit(x,y,setPolyOrder);
pvPort14 = polyval(pfPort14,x);

ypred = pvPort14;           % Predictions
dev = y - mean(y);          % Deviations - measure of spread
SST = sum(dev.^2);          % Total variation to be accounted for
resid = y - ypred;          % Residuals - measure of mismatch
SSE = sum(resid.^2);        % Variation NOT accounted for
Rsq3 = 1 - SSE/SST;         % Percent of error explained

% Stbd (Sept. 2014)
x = xStbd14;
y = yStbd14;

pfStbd14 = polyfit(x,y,setPolyOrder);
pvStbd14 = polyval(pfStbd14,x);

ypred = pvStbd14;           % Predictions
dev = y - mean(y);          % Deviations - measure of spread
SST = sum(dev.^2);          % Total variation to be accounted for
resid = y - ypred;          % Residuals - measure of mismatch
SSE = sum(resid.^2);        % Variation NOT accounted for
Rsq4 = 1 - SSE/SST;         % Percent of error explained

% Port and Stbd averaged (Sept. 2014)
if enableAvgPortStbdPlot == 1
    x = xPortStbdAvg14;
    y = yPortStbdAvg14;
    
    pfPortStbd14 = polyfit(x,y,setPolyOrder);
    pvPortStbd14 = polyval(pfPortStbd14,x);
    
    ypred = pvPortStbd14;       % Predictions
    dev = y - mean(y);          % Deviations - measure of spread
    SST = sum(dev.^2);          % Total variation to be accounted for
    resid = y - ypred;          % Residuals - measure of mismatch
    SSE = sum(resid.^2);        % Variation NOT accounted for
    Rsq5 = 1 - SSE/SST;         % Percent of error explained
end

% Using Curve Fitting Toolbox
% pvPort13 = fit(yPort13,xPort13,'poly4','Normalize','on');
% pvStbd13 = fit(yStbd13,xStbd13,'poly4','Normalize','on');
% pvPort14 = fit(yPort14,xPort14,'poly4','Normalize','on');
% pvStbd14 = fit(yStbd14,xStbd14,'poly4','Normalize','on');

% Display in command window -----------------------------------------------

% Set number of decimals in command window output
setPostDecimals = '+%0.3f';
setNeutDecimals = '%0.3f';

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
rSquared = sprintf(setNeutDecimals,Rsq1);
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
rSquared = sprintf(setNeutDecimals,Rsq2);
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
rSquared = sprintf(setNeutDecimals,Rsq3);
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
rSquared = sprintf(setNeutDecimals,Rsq4);
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
    rSquared = sprintf(setNeutDecimals,Rsq5);
    EQoFit5  = sprintf('Avg. Port/Stbd (Sept. 2014): %sx^4%sx^3%sx^2%sx%s | R^2: %s',var1,var2,var3,var4,var5,rSquared);
    disp(EQoFit5);
end

% Plotting ----------------------------------------------------------------
if enableAvgPortStbdPlot == 1
    h1 = plot(xPort13,yPort13,setMarker{1},...
        xStbd13,yStbd13,setMarker{2},...
        xPort14,yPort14,setMarker{5},...
        xStbd14,yStbd14,setMarker{8},...
        xPortStbdAvg14,yPortStbdAvg14,setMarker{4});
    hold on;
    h2 = plot(xPort13,pvPort13,'-.',...
        xStbd13,pvStbd13,'-.',...
        xPort14,pvPort14,'-.',...
        xStbd14,pvStbd14,'-.',...
        xPortStbdAvg14,pvPortStbd14,'--');
else
    h1 = plot(xPort13,yPort13,setMarker{1},...
        xStbd13,yStbd13,setMarker{2},...
        xPort14,yPort14,setMarker{5},...
        xStbd14,yStbd14,setMarker{8});
    hold on;
    h2 = plot(xPort13,pvPort13,'-.',...
        xStbd13,pvStbd13,'-.',...
        xPort14,pvPort14,'-.',...
        xStbd14,pvStbd14,'-.');
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
setMarkerSize      = 9;
setLineWidth       = 1;
setLineWidthMarker = 2;
setLineStyle       = '-.';

% Port (June 2013)
set(h1(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(1),'Color',setColor{2},'LineStyle',setLineStyle,'LineWidth',setLineWidth);

% Stbd (June 2013)
set(h1(2),'Color',setColor{5},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(2),'Color',setColor{5},'LineStyle',setLineStyle,'LineWidth',setLineWidth);

% Port (Sept. 2014)
set(h1(3),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(3),'Color',setColor{1},'LineStyle',setLineStyle,'LineWidth',setLineWidth);

% Stbd (Sept. 2014)
set(h1(4),'Color',setColor{3},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h2(4),'Color',setColor{3},'LineStyle',setLineStyle,'LineWidth',setLineWidth);

% Port and Stbd averaged (Sept. 2014)
if enableAvgPortStbdPlot == 1
    set(h1(5),'Color',setColor{6},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    set(h2(5),'Color',setColor{6},'LineStyle','--','LineWidth',setLineWidth);
end

%# Text on plot -----------------------------------------------------------

if enableTextOnPlot == 1
    text(1.8, 1.0, EQoFit1, 'Color', 'k');
    text(1.8, 0.8, EQoFit2, 'Color', 'k');    
    text(1.8, 0.6, EQoFit3, 'Color', 'k');
    text(1.8, 0.4, EQoFit4, 'Color', 'k');
    if enableAvgPortStbdPlot == 1
        text(1.8, 0.2, EQoFit5, 'Color', 'k');
    end
end
    
%# Axis limitations -------------------------------------------------------

xlim([1 4.5]);
%ylim([y(1) y(end)]);
ylim([0 5.5]);

%# Legend -----------------------------------------------------------------

%hleg1 = legend('Port (June 2013)','Fit','Starboard (June 2013)','Fit','Port (Sept. 2014)','Fit','Starboard (Sept. 2014)','Fit');
if enableAvgPortStbdPlot == 1
    hleg1 = legend(h1, 'Port (June 2013)','Starboard (June 2013)','Port (Sept. 2014)','Starboard (Sept. 2014)','Averaged Port/Starboard (Sept. 2014)');
else
    hleg1 = legend(h1, 'Port (June 2013)','Starboard (June 2013)','Port (Sept. 2014)','Starboard (Sept. 2014)');    
end
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
set(hleg1,'FontSize',setGeneralFontSize);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Plot title -------------------------------------------------------------
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

clearvars x y f h h1 h2 k
clearvars setPostDecimals setNeutDecimals
clearvars m n mpaa npaa msaa nsaa maaa naaa
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
