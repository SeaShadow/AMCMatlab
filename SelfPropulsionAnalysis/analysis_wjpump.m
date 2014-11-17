%# ------------------------------------------------------------------------
%# Pumpcurve for LJ120E waterjet unit supplied by Wärtsilä
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 17, 2014
%#
%# Description:  Pumpcurve analysis for different RPM in full scale.
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  01/10/2014 - File creation
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

% Main and plot titles
enablePlotMainTitle       = 0;    % Show plot title in saved file
enablePlotTitle           = 0;    % Show plot title above plot

% Text on plot
enableTextOnPlot          = 0;    % Show text on plot

% Plot color
enableBlackAndWhitePlot   = 1;    % Show plot in black and white

% Command window output
enableCommandWindowOutput = 1;    % Show command windown ouput

% Scaled to A4 paper
enableA4PaperSizePlot     = 0;    % Show plots scale to A4 size

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
%# START Load LJ120E pumpcurve data (variable name is LJ120EPCData)
%# ------------------------------------------------------------------------
if exist('LJ120EPumpcurveData568RPM.mat', 'file') == 2
    %# Load file into LJ120EPCData variable
    
    %# Waterjet details:
    % Full scale data
    % Shaft speed:      568 RPM
    DefaultPCShaftSpeedRPM = 568;
    DefaultPCShaftSpeedRPS = DefaultPCShaftSpeedRPM/60;
    % Inlet diameter:   1.2m
    
    %# Columns:
    %[1]  Flow coefficient                          (-)
    %[2]  Head coefficient                          (-)
    %[3]  Pump efficiency                           (-)
    %[4]  NPSH (Net positive suction head) 1%/H     (-)
    %[5]  Volume flow rate                          (m^3/s)
    %[6]  Pump head                                 (-)
    
    load('LJ120EPumpcurveData568RPM.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (LJ120EPumpcurveData568RPM.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load LJ120E pumpcurve data (variable name is LJ120EPCData)
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

% Form factors and correlaction coefficient
FormFactor = 1.18;                            % Form factor (1+k)
CorrCoeff  = 0;                               % Correlation coefficient, Ca

% Waterjet constants (FS = full scale and MS = model scale)

% Pump (inlet) diameter, Dp, (m)
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

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
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
fPath = sprintf('_plots/%s', 'LJ120E_Pumpcurve');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', 'LJ120E_Pumpcurve', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', 'LJ120E_Pumpcurve', 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', 'LJ120E_Pumpcurve', 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START Extrapolate to other RPM values
%# ------------------------------------------------------------------------

%# Model scale shaft speeds (TG at FD for TG=pQj(vj-vi)
% MSPortShaftRPM = [2640];
% MSStbdShaftRPM = [2640];
% MSAvgShaftRPM  = [2640];
%
% MSPortShaftRPM = [1000 2000];
% MSStbdShaftRPM = [1000 2000];
% MSAvgShaftRPM  = [1000 2000];

MSPortShaftRPM = [1720.346 1819.177 1932.290 2023.496 2156.079 2254.888 2319.386 2480.594 2655.304];
MSStbdShaftRPM = [1721.284 1820.759 1933.280 2079.042 2156.444 2257.910 2324.894 2479.207 2656.478];
MSAvgShaftRPM  = [1720.815 1819.968 1932.785 2051.269 2156.261 2256.399 2322.140 2479.900 2655.891];

% Active shaft RPM list
activeShaftRPMList = MSAvgShaftRPM;
[mac,nac] = size(activeShaftRPMList);

% Array sizes
[m,n]   = size(LJ120EPCData);
[mp,np] = size(MSPortShaftRPM);
[ms,ns] = size(MSStbdShaftRPM);
[ma,na] = size(MSAvgShaftRPM);

%# Loop through shaft speeds ----------------------------------------------
resultsArrayLJ120EPc = [];
PcArray = [];
for k=1:na
    
    [mra,nra] = size(resultsArrayLJ120EPc);
    
    % Define MS and FS shaft speed variables
    ShaftSpeed   = activeShaftRPMList(k);
    MSShaftSpeed = ShaftSpeed;
    FSShaftSpeed = MSShaftSpeed/sqrt(FStoMSratio);
    
    % Model scale
    MSShaftRPM   = MSShaftSpeed;
    MSShaftRPS   = MSShaftSpeed/60;
    
    % Full scale
    FSShaftRPM   = FSShaftSpeed;
    FSShaftRPS   = FSShaftSpeed/60;
    
    %# ////////////////////////////////////////////////////////////////////
    %# Create results array
    %# ////////////////////////////////////////////////////////////////////
    
    %# Add results to dedicated array for simple export
    %# Columns:
    %[1]  Speed number                              (#)
    %[2]  Model scale (MS) shaft speed              (RPM)
    %[3]  Model scale (MS) shaft speed              (RPS)
    %[4]  Full scale (FS) shaft speed               (RPM)
    %[5]  Full scale (FS) shaft speed               (RPS)
    %[6]  Volume flow rate (QJ)                     (m^3/s)
    %[7]  Pump head (H35)                           (-)
    %[8]  Flow coefficient                          (-)
    %[9]  Head coefficient                          (-)
    %[10] Pump efficiency                           (-)
    %[11] NPSH 1%/H                                 (-)
    %[12] Mass flow rate                            (Kg/s)
    %[13] Jet velocity (vj)                         (m/s)
    % Power:
    %[14] Pump effective power (PPE)                (W)
    %[15] Delivered power (PD)                      (W)
    
    % Add the different pumpcurve values
    for kl=1:m
        PcArray(kl, 1)  = k;
        PcArray(kl, 2)  = MSShaftRPM;
        PcArray(kl, 3)  = MSShaftRPS;
        PcArray(kl, 4)  = FSShaftRPM;
        PcArray(kl, 5)  = FSShaftRPS;
        PcArray(kl, 6)  = LJ120EPCData(kl,4)/((DefaultPCShaftSpeedRPS/FSShaftRPS)*(FS_PumpDia/FS_PumpDia)^3);
        PcArray(kl, 7)  = LJ120EPCData(kl,5)/((DefaultPCShaftSpeedRPS/FSShaftRPS)^2*(FS_PumpDia/FS_PumpDia)^2);
        PcArray(kl, 8)  = PcArray(kl, 6)/(FSShaftRPS*FS_PumpDia^3);
        PcArray(kl, 9)  = (gravconst*PcArray(kl,7))/(FSShaftRPS*FS_PumpDia)^2;
        PcArray(kl, 10) = LJ120EPCData(kl, 3);
        PcArray(kl, 11) = LJ120EPCData(kl, 6);
        PcArray(kl, 12) = PcArray(kl, 6)*saltwaterdensity;
        PcArray(kl, 13) = PcArray(kl, 6)/FS_NozzArea;
        PcArray(kl, 14) = saltwaterdensity*gravconst*PcArray(kl, 6)*PcArray(kl, 7);
        PcArray(kl, 15) = PcArray(kl, 14)/LJ120EPCData(kl,3);
    end
    
    % Combine arrays
    resultsArrayLJ120EPc = [resultsArrayLJ120EPc;PcArray];
end

%# ------------------------------------------------------------------------
%# END Extrapolate to other RPM values
%# ************************************************************************


%# ************************************************************************
%# 0. Shorten resultsArrayLJ120EPc variable name
%# ************************************************************************

M = resultsArrayLJ120EPc;

%# ************************************************************************
%# 1. Plotting pump head (H) vs. volumetric flow rate (QJ)
%# ************************************************************************

%# Plotting gross thrust vs. towing force
figurename = 'LJ120E Watejet: Pump Head vs. Volume Flow Rate';
f  = figure('Name',figurename,'NumberTitle','off');
hold all;
ah = gca;

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
setMarker = {'+';'o';'x';'^';'s';'v';'d';'>';'<';'*'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html

set(gcf,'Color',[1,1,1]);

% X and Y values ----------------------------------------------------------

x = M(1:9,6);
y = M(1:9,7);

% Plotting ----------------------------------------------------------------
% Add curves to plot with loop:
% http://stackoverflow.com/questions/12134406/several-graphs-in-1-loop-each-iteration-adds-a-line-on-every-figure

setMarkerSize      = 10;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-.';

count1 = 1;
count2 = 9;
curve1 = [1 3 5 7 9 11 13 15 17 19];
curve2 = [2 4 6 8 10 12 14 16 18 20];
for k=1:nac+1
    if k == nac+1
        x = LJ120EPCData(:,4);
        y = LJ120EPCData(:,5);
        
        if enableCurveFittingToolboxPlot == 1
            % Fit: poly4
            fitobject = fit(x,y,'poly4');
            
            % See: http://stackoverflow.com/questions/16478077/get-function-handle-of-fit-function-in-matlab-and-assign-fit-parameters
            if enableCommandWindowOutput == 1
                cvalues = coeffvalues(fitobject);
                cnames  = coeffnames(fitobject);
                output  = formula(fitobject);

                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                setDecimals5 = '+%0.3f';
                if cvalues(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if cvalues(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if cvalues(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if cvalues(4) < 0
                    setDecimals4 = '%0.3f';
                end
                if cvalues(5) < 0
                    setDecimals5 = '%0.3f';
                end
                
                p1 = sprintf(setDecimals1,cvalues(1));
                p2 = sprintf(setDecimals2,cvalues(2));
                p3 = sprintf(setDecimals3,cvalues(3));
                p4 = sprintf(setDecimals4,cvalues(4));
                p5 = sprintf(setDecimals5,cvalues(5));
                
                % Display in command window
                setRPMcw = 568;
                disp(sprintf('H vs. QJ: %s RPM ==>> EoF (poly4) = %s*x^4%s*x^3%s*x^2%s*x%s',num2str(setRPMcw),p1,p2,p3,p4,p5));
            end
            
            if enableCurveFittingToolboxCurvePlot == 1
                % Plotting
                h = plot(fitobject,'k-.',x,y,'*');
                
                % Legend
                legendInfo1{curve1(k)} = '568 RPM (Wärtsilä)';
                legendInfo1{curve2(k)} = '568 RPM (Wärtsilä), Fit';                
            else
                % Plotting
                h = plot(x,y,'*');
                % Legend
                legendInfo1{k} = '568 RPM (Wärtsilä)';              
            end

            % Markers and line
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{k}             
            
        else
            % Plotting
            h = plot(ah,x,y,'*');
            
            % Markers and line
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{k}
            
            % Legend
            legendInfo1{k} = '568 RPM (Wärtsilä)';
        end
    else
        x = M(count1:count2,6);
        y = M(count1:count2,7);
        
        if enableCurveFittingToolboxPlot == 1
            % Fit: poly4
            fitobject = fit(x,y,'poly4');
            
            % See: http://stackoverflow.com/questions/16478077/get-function-handle-of-fit-function-in-matlab-and-assign-fit-parameters
            if enableCommandWindowOutput == 1
                cvalues = coeffvalues(fitobject);
                cnames  = coeffnames(fitobject);
                output  = formula(fitobject);
                
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                setDecimals5 = '+%0.3f';
                if cvalues(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if cvalues(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if cvalues(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if cvalues(4) < 0
                    setDecimals4 = '%0.3f';
                end
                if cvalues(5) < 0
                    setDecimals5 = '%0.3f';
                end
                
                p1 = sprintf(setDecimals1,cvalues(1));
                p2 = sprintf(setDecimals2,cvalues(2));
                p3 = sprintf(setDecimals3,cvalues(3));
                p4 = sprintf(setDecimals4,cvalues(4));
                p5 = sprintf(setDecimals5,cvalues(5));
                
                % Display in command window
                setRPMcw = round(M(count1,4));
                disp(sprintf('H vs. QJ: %s RPM ==>> EoF (poly4) = %s*x^4%s*x^3%s*x^2%s*x%s',num2str(setRPMcw),p1,p2,p3,p4,p5));
            end
            
            if enableCurveFittingToolboxCurvePlot == 1
                % Plotting
                h = plot(fitobject,'k-.',x,y,'*');
                
                % Legend
                legendInfo1{curve1(k)} = [num2str(round(M(count1,4))) ' RPM'];
                legendInfo1{curve2(k)} = [num2str(round(M(count1,4))) ' RPM, Fit'];
            else
                % Plotting
                h = plot(x,y,'*');
                
                % Legend
                legendInfo1{k} = [num2str(round(M(count1,4))) ' RPM'];        
            end            

            % Markers and lines
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

        else
            % Plotting
            h = plot(ah,x,y,'*');
            
            % Markers and lines
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            
            % Legend
            legendInfo1{k} = [num2str(round(M(count1,4))) ' RPM'];
        end
        
        count1 = count1+9;
        count2 = count2+9;
    end
end
if enableEqnOfFitPlot == 1
    if enableCommandWindowOutput == 1
        disp('-----------------------------------------------------------------------------------------------------');
    end
    hold on;
    count1 = 1;
    count2 = 9;
    for k=1:nac+1
        if k == nac+1
            x = LJ120EPCData(:,4);
            y = LJ120EPCData(:,5);
            
            % Polynomial fit
            polyf = polyfit(x,y,3);
            polyv = polyval(polyf,x);
            
            ypred = polyv;              % Predictions
            dev   = y - mean(y);        % Deviations - measure of spread
            SST   = sum(dev.^2);        % Total variation to be accounted for
            resid = y - ypred;          % Residuals - measure of mismatch
            SSE   = sum(resid.^2);      % Variation NOT accounted for
            Rsquared = 1 - SSE/SST;     % Percent of error explained
            
            if enableCommandWindowOutput == 1
                % Display in command line (poly4)
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                if polyf(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if polyf(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if polyf(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if polyf(4) < 0
                    setDecimals4 = '%0.3f';
                end
                setRPMcw = 568;
                disp(sprintf('H vs. QJ: %s RPM ==>> EoF (poly4) = %sx^3%sx^2%sx%s | R^2: %s',num2str(setRPMcw),sprintf(setDecimals1,polyf(1)),sprintf(setDecimals2,polyf(2)),sprintf(setDecimals3,polyf(3)),sprintf(setDecimals4,polyf(4)),sprintf('%0.4f',Rsquared)));
            end
            
            % Plotting
            h = plot(x,polyv,'-');
            set(h(1),'Color',setColor{k},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        else
            x = M(count1:count2,6);
            y = M(count1:count2,7);
            
            % Polynomial fit
            polyf = polyfit(x,y,3);
            polyv = polyval(polyf,x);
            
            ypred = polyv;              % Predictions
            dev   = y - mean(y);        % Deviations - measure of spread
            SST   = sum(dev.^2);        % Total variation to be accounted for
            resid = y - ypred;          % Residuals - measure of mismatch
            SSE   = sum(resid.^2);      % Variation NOT accounted for
            Rsquared = 1 - SSE/SST;     % Percent of error explained
            
            if enableCommandWindowOutput == 1
                % Display in command line (poly4)
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                if polyf(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if polyf(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if polyf(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if polyf(4) < 0
                    setDecimals4 = '%0.3f';
                end
                setRPMcw = round(M(count1,4));
                disp(sprintf('H vs. QJ: %s RPM ==>> EoF (poly4) = %sx^3%sx^2%sx%s | R^2: %s',num2str(setRPMcw),sprintf(setDecimals1,polyf(1)),sprintf(setDecimals2,polyf(2)),sprintf(setDecimals3,polyf(3)),sprintf(setDecimals4,polyf(4)),sprintf('%0.4f',Rsquared)));
            end
            
            % Plotting
            h = plot(x,polyv,'-');
            set(h(1),'Color',setColor{k},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            
            count1 = count1+9;
            count2 = count2+9;
        end
    end
end
if enablePlotTitle == 1
    title('{\bf Scaled pump heads and flow rates}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Volumetric flow rate, Q_{J} (m^3/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Pump head, H (m)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Axis limitations -------------------------------------------------------

minX  = 1;
maxX  = 17;
incrX = 2;
minY  = 10;
maxY  = 64;
incrY = 6;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend -----------------------------------------------------------------

%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend(ah,'1','2','3','4','5','6','7','8','9');
hleg1 = legend(legendInfo1);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

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

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(activeShaftRPMList);
maxRun = max(activeShaftRPMList);
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/%s_RPM_to_%s_RPM_LJ120E_Waterjet_Head_and_Flow_Rate_Plot.%s', 'LJ120E_Pumpcurve', setFileFormat{k}, num2str(round(minRun)), num2str(round(maxRun)), setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ************************************************************************
%# 2. Plotting pump efficiency (npump) vs. shaft speed (n)
%# ************************************************************************

%# Plotting gross thrust vs. towing force
figurename = 'LJ120E Watejet: Pump Efficiency vs. Volume Flow Rate';
f  = figure('Name',figurename,'NumberTitle','off');
hold all;
ah = gca;

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
setMarker = {'+';'o';'x';'^';'s';'v';'d';'>';'<';'*'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Set plot figure background to a defined color --------------------------
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html

set(gcf,'Color',[1,1,1]);

% X and Y values ----------------------------------------------------------

x = M(1:9,6);
y = M(1:9,10);

% Plotting ----------------------------------------------------------------
% Add curves to plot with loop:
% http://stackoverflow.com/questions/12134406/several-graphs-in-1-loop-each-iteration-adds-a-line-on-every-figure

setMarkerSize      = 10;
setLineWidthMarker = 1;

count1 = 1;
count2 = 9;
curve1 = [1 3 5 7 9 11 13 15 17 19];
curve2 = [2 4 6 8 10 12 14 16 18 20];
for k=1:nac+1
    if k == nac+1
        x = LJ120EPCData(:,4);
        y = LJ120EPCData(:,3);
        
        if enableCurveFittingToolboxPlot == 1
            % Fit: poly4
            fitobject = fit(x,y,'poly4');
            
            % See: http://stackoverflow.com/questions/16478077/get-function-handle-of-fit-function-in-matlab-and-assign-fit-parameters
            if enableCommandWindowOutput == 1
                cvalues = coeffvalues(fitobject);
                cnames  = coeffnames(fitobject);
                output  = formula(fitobject);
                
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                setDecimals5 = '+%0.3f';
                if cvalues(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if cvalues(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if cvalues(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if cvalues(4) < 0
                    setDecimals4 = '%0.3f';
                end
                if cvalues(5) < 0
                    setDecimals5 = '%0.3f';
                end
                
                p1 = sprintf(setDecimals1,cvalues(1));
                p2 = sprintf(setDecimals2,cvalues(2));
                p3 = sprintf(setDecimals3,cvalues(3));
                p4 = sprintf(setDecimals4,cvalues(4));
                p5 = sprintf(setDecimals5,cvalues(5));
                
                % Display in command window
                setRPMcw = 568;
                disp(sprintf('n. vs. QJ: %s RPM ==>> EoF (poly4) = %s*x^4%s*x^3%s*x^2%s*x%s',num2str(setRPMcw),p1,p2,p3,p4,p5));
            end
            
            if enableCurveFittingToolboxCurvePlot == 1
                % Plotting
                h = plot(fitobject,'k-.',x,y,'*');         

                % Legend
                legendInfo2{curve1(k)} = '568 RPM (Wärtsilä)';
                legendInfo2{curve2(k)} = '568 RPM (Wärtsilä), Fit';            
            else
                % Plotting
                h = plot(x,y,'*');         

                % Legend
                legendInfo2{k} = '568 RPM (Wärtsilä)';
            end

            % Markers and line
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{k}

        else
            % Plotting
            h = plot(ah,x,y,'*');
            
            % Markers and line
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{k}
            
            % Legend
            legendInfo2{k} = '568 RPM (Wärtsilä)';
        end
    else
        if k == 1
            disp('--------------------------------------------------------------------------------------');
        end
        
        x = M(count1:count2,6);
        y = M(count1:count2,10);
        
        if enableCurveFittingToolboxPlot == 1
            % Fit: poly4
            fitobject = fit(x,y,'poly4');
            
            % See: http://stackoverflow.com/questions/16478077/get-function-handle-of-fit-function-in-matlab-and-assign-fit-parameters
            if enableCommandWindowOutput == 1
                cvalues = coeffvalues(fitobject);
                cnames  = coeffnames(fitobject);
                output  = formula(fitobject);
                
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                setDecimals5 = '+%0.3f';
                if cvalues(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if cvalues(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if cvalues(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if cvalues(4) < 0
                    setDecimals4 = '%0.3f';
                end
                if cvalues(5) < 0
                    setDecimals5 = '%0.3f';
                end
                
                p1 = sprintf(setDecimals1,cvalues(1));
                p2 = sprintf(setDecimals2,cvalues(2));
                p3 = sprintf(setDecimals3,cvalues(3));
                p4 = sprintf(setDecimals4,cvalues(4));
                p5 = sprintf(setDecimals5,cvalues(5));
                
                % Display in command window
                setRPMcw = round(M(count1,4));
                disp(sprintf('n. vs. QJ: %s RPM ==>> EoF (poly4) = %s*x^4%s*x^3%s*x^2%s*x%s',num2str(setRPMcw),p1,p2,p3,p4,p5));
            end
            
            if enableCurveFittingToolboxCurvePlot == 1
                % Plotting
                h = plot(fitobject,'k-.',x,y,'*');       

                % Legend
                legendInfo2{curve1(k)} = [num2str(round(M(count1,4))) ' RPM'];
                legendInfo2{curve2(k)} = [num2str(round(M(count1,4))) ' RPM, Fit'];            
            else
                % Plotting
                h = plot(x,y,'*');       

                % Legend
                legendInfo2{k} = [num2str(round(M(count1,4))) ' RPM'];               
            end            

            % Markers and lines
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

        else
            % Plotting
            h = plot(ah,x,y,'*');
            
            % Markers and lines
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
            
            % Legend
            legendInfo2{k} = [num2str(round(M(count1,4))) ' RPM'];
        end
        
        count1 = count1+9;
        count2 = count2+9;
    end
end
if enableEqnOfFitPlot == 1
    if enableCommandWindowOutput == 1
        disp('-----------------------------------------------------------------------------------------------------');
    end
    hold on;
    count1 = 1;
    count2 = 9;
    for k=1:nac+1
        if k == nac+1
            x = LJ120EPCData(:,4);
            y = LJ120EPCData(:,3);
            
            % Polynomial fit
            polyf = polyfit(x,y,3);
            polyv = polyval(polyf,x);
            
            ypred = polyv;              % Predictions
            dev   = y - mean(y);        % Deviations - measure of spread
            SST   = sum(dev.^2);        % Total variation to be accounted for
            resid = y - ypred;          % Residuals - measure of mismatch
            SSE   = sum(resid.^2);      % Variation NOT accounted for
            Rsquared = 1 - SSE/SST;     % Percent of error explained
            
            if enableCommandWindowOutput == 1
                % Display in command line (poly4)
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                if polyf(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if polyf(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if polyf(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if polyf(4) < 0
                    setDecimals4 = '%0.3f';
                end
                setRPMcw = 568;
                disp(sprintf('n. vs. QJ: %s RPM ==>> EoF (poly4) = %sx^3%sx^2%sx%s | R^2: %s',num2str(setRPMcw),sprintf(setDecimals1,polyf(1)),sprintf(setDecimals2,polyf(2)),sprintf(setDecimals3,polyf(3)),sprintf(setDecimals4,polyf(4)),sprintf('%0.4f',Rsquared)));
            end
            
            % Plotting
            h = plot(x,polyv,'-');
            set(h(1),'Color',setColor{k},'LineStyle',setLineStyle,'linewidth',setLineWidth);
        else
            x = M(count1:count2,6);
            y = M(count1:count2,10);
            
            % Polynomial fit
            polyf = polyfit(x,y,3);
            polyv = polyval(polyf,x);
            
            ypred = polyv;              % Predictions
            dev   = y - mean(y);        % Deviations - measure of spread
            SST   = sum(dev.^2);        % Total variation to be accounted for
            resid = y - ypred;          % Residuals - measure of mismatch
            SSE   = sum(resid.^2);      % Variation NOT accounted for
            Rsquared = 1 - SSE/SST;     % Percent of error explained
            
            if enableCommandWindowOutput == 1
                % Display in command line (poly4)
                setDecimals1 = '%0.3f';
                setDecimals2 = '+%0.3f';
                setDecimals3 = '+%0.3f';
                setDecimals4 = '+%0.3f';
                if polyf(1) < 0
                    setDecimals1 = '%0.3f';
                end
                if polyf(2) < 0
                    setDecimals2 = '%0.3f';
                end
                if polyf(3) < 0
                    setDecimals3 = '%0.3f';
                end
                if polyf(4) < 0
                    setDecimals4 = '%0.3f';
                end
                setRPMcw = round(M(count1,4));
                disp(sprintf('n. vs. QJ: %s RPM ==>> EoF (poly4) = %sx^3%sx^2%sx%s | R^2: %s',num2str(setRPMcw),sprintf(setDecimals1,polyf(1)),sprintf(setDecimals2,polyf(2)),sprintf(setDecimals3,polyf(3)),sprintf(setDecimals4,polyf(4)),sprintf('%0.4f',Rsquared)));
            end
            
            % Plotting
            h = plot(x,polyv,'-');
            set(h(1),'Color',setColor{k},'LineStyle',setLineStyle,'linewidth',setLineWidth);
            
            count1 = count1+9;
            count2 = count2+9;
        end
    end
end
if enablePlotTitle == 1
    title('{\bf Scaled pump efficiencies and flow rates}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Volumetric flow rate, Q_{J} (m^3/s)}','FontSize',setGeneralFontSize);
ylabel('{\bf Pump efficiency, \eta_{pump} (-)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Axis limitations -------------------------------------------------------

minX  = 5;
maxX  = 17;
incrX = 2;
minY  = 0.6;
maxY  = 0.95;
incrY = 0.05;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend -----------------------------------------------------------------

%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend(ah,'1','2','3','4','5','6','7','8','9');
hleg1 = legend(legendInfo2);
set(hleg1,'Location','SouthEast');
set(hleg1,'Interpreter','none');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

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

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(activeShaftRPMList);
maxRun = max(activeShaftRPMList);
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/%s_RPM_to_%s_RPM_LJ120E_Waterjet_Pump_Efficiency_Plot.%s', 'LJ120E_Pumpcurve', setFileFormat{k}, num2str(round(minRun)), num2str(round(maxRun)), setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# START: Write results to DAT and TXT
%# ------------------------------------------------------------------------
M = resultsArrayLJ120EPc;
csvwrite('resultsArrayLJ120EPc.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsArrayLJ120EPc.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
%# ------------------------------------------------------------------------
%# END: Write results to DAT and TXT
%# ************************************************************************


%# ************************************************************************
%# Clear variables
%# ************************************************************************
clearvars allPlots k kl m n mp np ms ns ma na mac nac
clearvars ShaftSpeed MSShaftSpeed FSShaftSpeed
clearvars ttlength ttwidth ttwaterdepth ttcsa ttwatertemp gravconst MSKinVis FSKinVis freshwaterdensity saltwaterdensity distbetwposts
clearvars FStoMSratio FormFactor CorrCoeff FS_PumpDia MS_PumpDia FS_EffNozzDia MS_EffNozzDia FS_NozzArea MS_NozzArea FS_ImpDia MS_ImpDia FS_PumpInlArea MS_PumpInlArea FS_PumpMaxArea MS_PumpMaxArea
clearvars MSlwl MSwsa MSdraft MSAx BlockCoeff FSlwl FSwsa FSdraft
