%# ------------------------------------------------------------------------
%# Pumpcurve for LJ120E waterjet unit supplied by Wartsila
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  September 23, 2014
%#
%# Description:  Pumpcurve analysis for different RPM in full scale.
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  23/09/2014 - File creation
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

enablePlotMainTitle     = 0;    % Show plot title in saved file
enablePlotTitle         = 0;    % Show plot title above plot
enableTextOnPlot        = 0;    % Show text on plot
enableBlackAndWhitePlot = 1;    % Show plot in black and white
enableEqnOfFitPlot      = 0;    % Show equations of fit

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


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
MSKinVis            = (((0.585*10^(-3))*(ttwatertemp-12)-0.03361)*(ttwatertemp-12)+1.235)*10^(-6); % Model scale kinetic viscosity at X (see ttwatertemp) degrees following ITTC (m2/s)
%MSKinVis            = 0.00000104125125;       % Model scale kinetic viscosity at 18.5C (m^2/s)
FSKinVis            = 0.0000011581;           % Full scale kinetic viscosity           (m^2/s)
freshwaterdensity   = 1000;                   % Model scale water density        (Kg/m^3)
saltwaterdensity    = 1025;                   % Salt water scale water density   (Kg/m^3)
distbetwposts       = 1150;                   % Distance between carriage posts  (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio  (-)

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

MSPortShaftRPM = [1745.733 1853.208 1983.190 2088.459 2201.762 2285.104 2370.432 2497.063 2658.391];
MSStbdShaftRPM = [1745.733 1853.208 1983.190 2088.459 2201.762 2285.104 2370.432 2497.063 2658.391];
MSAvgShaftRPM  = [1745.733 1853.208 1983.190 2088.459 2201.762 2285.104 2370.432 2497.063 2658.391];

% Active shaft RPM list
activeShaftRPMList = MSPortShaftRPM;
[mac,nac] = size(activeShaftRPMList);

% Array sizes
[m,n]   = size(LJ120EPCData);
[mp,np] = size(MSPortShaftRPM);
[ms,ns] = size(MSStbdShaftRPM);
[ma,na] = size(MSAvgShaftRPM);

%# Loop through shaft speeds
resultsArrayLJ120EPc = [];
PcArray = [];
for k=1:np
    
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
    %# CREATE RESULTS ARRAY
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
        %[11] Mass flow rate                            (Kg/s)
        %[12] Jet velocity (vj)                         (m/s)
    % Power:
        %[13] Pump effective power (PPE)                (W)
        %[14] Delivered power (PD)                      (W)

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
        PcArray(kl, 10) = 0;
        PcArray(kl, 11) = PcArray(kl, 6)*saltwaterdensity;
        PcArray(kl, 12) = PcArray(kl, 6)/FS_NozzArea;
        PcArray(kl, 13) = saltwaterdensity*gravconst*PcArray(kl, 6)*PcArray(kl, 7);
        PcArray(kl, 14) = PcArray(kl, 13)/LJ120EPCData(kl,3);
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
        
% set(gcf, 'PaperSize', [19 19]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition', [0 0 19 19]);
%
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperSize', [19 19]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition', [0 0 19 19]);

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;

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
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
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

setMarkerSize      = 8;
setLineWidthMarker = 1;

count1 = 1;
count2 = 9;
for k=1:nac+1
    if k == nac+1
        x = LJ120EPCData(:,4);
        y = LJ120EPCData(:,5);
        
        h = plot(ah,x,y,'*','Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{k}
        legendInfo{k} = '568 RPM (Wartsila)';
    else
        x = M(count1:count2,6);
        y = M(count1:count2,7);

        h = plot(ah,x,y,'*','Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        legendInfo{k} = [num2str(round(M(count1,4))) ' RPM'];

        count1 = count1+9;
        count2 = count2+9;
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

% Find X and Y min and max values for axis limitation

% From Wartsila provided data
minXW = round(min(LJ120EPCData(:,4)))-1;
maxXW = round(max(LJ120EPCData(:,4)))+1;
minYW = round(min(LJ120EPCData(:,5)))-1;
maxYW = round(max(LJ120EPCData(:,5)))+1;

% From selected RPM values
minX  = round(min(M(:,6)))-1;
maxX  = round(max(M(:,6)))+1;
minY  = round(min(M(:,7)))-1;
maxY  = round(max(M(:,7)))+1;

% Check min and max values from selected RPM values and Wartsila data
if minX < minXW
    minX = minX;
else
    minX = minXW;
end

if maxX < maxXW
    maxX = maxXW;
else
    maxX = maxX;
end

if minY < minYW
    minY = minY;
else
    minY = minYW;
end

if maxY < maxYW
    maxY = maxYW;
else
    maxY = maxY;
end

% Find best divider for axis
divider = [2 3 5];
[mdiv,ndiv] = size(divider);
setXIncr = 1;
setYIncr = 1;
for i=1:ndiv
    if mod(maxX-minX,divider(i)) == 0;
        setXIncr = divider(i);
    end
    if mod(maxY-minY,divider(i)) == 0;
        setYIncr = divider(i);
    end
end

% Manual increment overwrite
%setXIncr = 3;
setYIncr = 6;

% Set limitations
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:setXIncr:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:setYIncr:maxY);

%# Legend -----------------------------------------------------------------

%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend(ah,'1','2','3','4','5','6','7','8','9');
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
legend boxoff;

%# Font sizes and border --------------------------------------------------

%set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

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
        
% set(gcf, 'PaperSize', [19 19]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition', [0 0 19 19]);
%
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperSize', [19 19]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition', [0 0 19 19]);

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;

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
setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
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

setMarkerSize      = 8;
setLineWidthMarker = 1;

count1 = 1;
count2 = 9;
for k=1:nac+1
    if k == nac+1
        x = LJ120EPCData(:,4);
        y = LJ120EPCData(:,3);
        
        h = plot(ah,x,y,'*','Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); % ,'MarkerFaceColor',setColor{k}
        legendInfo{k} = '568 RPM (Wartsila)';
    else
        x = M(count1:count2,6);
        y = M(count1:count2,10);

        h = plot(ah,x,y,'*','Color',setColor{k},'Marker',setMarker{k},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        legendInfo{k} = [num2str(round(M(count1,4))) ' RPM'];

        count1 = count1+9;
        count2 = count2+9;
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

% Find X and Y min and max values for axis limitation

% From Wartsila provided data
minXW = round(min(LJ120EPCData(:,4)))-1;
maxXW = round(max(LJ120EPCData(:,4)))+1;
minYW = round(min(LJ120EPCData(:,3)))-0.1;
maxYW = round(max(LJ120EPCData(:,3)))+0.1;

% From selected RPM values
minX  = round(min(M(:,6)))-1;
maxX  = round(max(M(:,6)))+1;
minY  = round(min(M(:,10)))-0.1;
maxY  = round(max(M(:,10)))+0.1;

% Check min and max values from selected RPM values and Wartsila data
if minX < minXW
    minX = minX;
else
    minX = minXW;
end

if maxX < maxXW
    maxX = maxXW;
else
    maxX = maxX;
end

if minY < minYW
    minY = minY;
else
    minY = minYW;
end

if maxY < maxYW
    maxY = maxYW;
else
    maxY = maxY;
end

% Find best divider for axis
divider = [2 3 5];
[mdiv,ndiv] = size(divider);
setXIncr = 1;
setYIncr = 1;
for i=1:ndiv
    if mod(maxX-minX,divider(i)) == 0;
        setXIncr = divider(i);
    end
    if mod(maxY-minY,divider(i)) == 0;
        setYIncr = divider(i);
    end    
end

% Manual increment overwrite
setXIncr = 2;
setYIncr = 0.1;

% Manual min, max overwrite
%minX  = 0;
%maxX  = 10;
minY  = 0;
maxY  = 1;

% Set limitations
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:setXIncr:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:setYIncr:maxY);

%# Legend -----------------------------------------------------------------

%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend(ah,'1','2','3','4','5','6','7','8','9');
hleg1 = legend(legendInfo);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
legend boxoff;

%# Font sizes and border --------------------------------------------------

%set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

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
