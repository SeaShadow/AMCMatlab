%# ------------------------------------------------------------------------
%# PST and DPT Calibration
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  February 13, 2015
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
%# CHANGES    :  10/12/2013 - Created new script
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
enableProfiler            = 0;    % Use profiler to show execution times

% Main and plot titles
enablePlotMainTitle       = 1;    % Show plot title in saved file
enablePlotTitle           = 1;    % Show plot title above plot
enableTextOnPlot          = 0;    % Show text on plot
enableBlackAndWhitePlot   = 0;    % Show plot in black and white
enableEqnOfFitPlot        = 0;    % Show equations of fit
enableCommandWindowOutput = 1;    % Show command windown ouput

% Scaled to A4 paper
enableA4PaperSizePlot     = 1;    % Show plots scale to A4 size

% Time series plot
enableTimeSeriesPlot      = 1;    % Enable or disable time series plot

%# ------------------------------------------------------------------------
%# END: PLOT SWITCHES
%# ************************************************************************


%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'PST and DPT Calibration';


% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile on
end


%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory


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
setDirName = '_plots/PST_Calibration';

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


%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz


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

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 39;  % Number of headerlines to data
headerlinesZeroAndCalib = 33;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration ----------------------------
%# ------------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 0;

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

startRun = 4;      % Start at run x
endRun   = 15;     % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArrayCalib = [];
%w = waitbar(0,'Processed run files');
for k=startRun:endRun
%for k=startRun:5
    
    %# Allow for 1 to become 01 for run numbers
    if k < 10
        filename = sprintf('%s0%s.run\\R0%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
    else
        filename = sprintf('%s%s.run\\R%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
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
    
    %# Columns as variables (RAW DATA)
    timeData               = data(:,1);       % Timeline
    Raw_CH_0_Speed         = data(:,2);       % Speed
    Raw_CH_19_Inb_PST      = data(:,3);       % Inboard PST
    Raw_CH_20_Outb_PST     = data(:,4);       % Outboard PST
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
    CH_19_Zero = ZeroAndCalib(5);
    CH_19_CF   = ZeroAndCalib(6);
    CH_20_Zero = ZeroAndCalib(7);
    CH_20_CF   = ZeroAndCalib(8);
    
    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    % Speed
    [CH_0_Speed CH_0_Speed_Mean]         = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);

    % Pitot static tubes (PST) and differential pressure transducer (DPT)
    [CH_19_Inb_PST CH_19_Inb_PST_Mean]   = analysis_realunits(Raw_CH_19_Inb_PST,CH_19_Zero,CH_19_CF);
    [CH_20_Outb_PST CH_20_Outb_PST_Mean] = analysis_realunits(Raw_CH_20_Outb_PST,CH_20_Zero,CH_20_CF);
    
    % /////////////////////////////////////////////////////////////////////
    % DISPLAY RESULTS
    % /////////////////////////////////////////////////////////////////////
    
    %# Add results to dedicated array for simple export
    %# Results array columns:
    %[1]  Run No.
    %[2]  FS                              (Hz)
    %[3]  No. of samples                  (-)
    %[4]  Record time                     (s)
    
    %[5]  Model speed                     (m/s)
    %[6]  Froude length number            (-)
    
    %[7]  CH_19: PST: TS mean             (V)
    %[8]  CH_19: PST: Calibration factor  (-)
    %[9]  CH_19: PST: Zero value          (V)
    
    %[10] CH_19: PST: CF*(x-zero) mean    (V)
    %[11] CH_19: PST: Minimum             (V)
    %[12] CH_19: PST: Maximum             (V)
    %[13] CH_19: PST: Diff. min to avg    (percent)
    %[14] CH_19: PST: Standard deviation  (V)
    
    % General data
    resultsArrayCalib(k, 1)  = k;                                                       % Run No.
    resultsArrayCalib(k, 2)  = round(length(timeData) / timeData(end));                 % FS (Hz)
    resultsArrayCalib(k, 3)  = length(timeData);                                        % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArrayCalib(k, 4)  = round(recordTime);                                       % Record time in seconds
    
    % Speed data
    resultsArrayCalib(k, 5)  = CH_0_Speed_Mean;                                         % Speed (m/s)
    roundedspeed   = str2num(sprintf('%.2f',resultsArrayCalib(k, 5)));                  % Round averaged speed to two (2) decimals only
    modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl1500))); % Calculate Froude length number
    resultsArrayCalib(k, 6)  = modelfrrounded;                                          % Froude length number (adjusted for Lwl change at different conditions) (-)
    
    % Variables
    MeanData                 = CH_19_Inb_PST_Mean;
    CHData                   = CH_19_Inb_PST;
    
    % CH_19: PST data
    resultsArrayCalib(k, 7)  = mean(Raw_CH_19_Inb_PST);
    resultsArrayCalib(k, 8)  = CH_19_CF;
    resultsArrayCalib(k, 9)  = CH_19_Zero;
    
    % CH_19: Stats
    resultsArrayCalib(k, 10) = MeanData;
    resultsArrayCalib(k, 11) = min(CHData);
    resultsArrayCalib(k, 12) = max(CHData);
    resultsArrayCalib(k, 13) = abs(1-(min(CHData)/MeanData));
    resultsArrayCalib(k, 14) = std(CHData);
    
    
    % Change from 2 to 3 digits -------------------------------------------
    if k > 99
        runno = name(2:4);
    else
        runno = name(1:3);
    end
    
    %# ********************************************************************
    %# Time series plot
    %# ********************************************************************
    if enableTimeSeriesPlot == 1
        
        figurename = sprintf('Run %s:: Time Series and Real Units Plot', num2str(runno));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings --------------------------------------------
        
        if enableA4PaperSizePlot == 1
            set(gcf, 'PaperSize', [19 19]);
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperPosition', [0 0 19 19]);
            
            set(gcf, 'PaperUnits', 'centimeters');
            set(gcf, 'PaperSize', [19 19]);
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperPosition', [0 0 19 19]);
        end
        
        % Fonts and colours -----------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        setLegendFontSize  = 14;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. ----------------------------
        set(gca,'TickDir','in',...
            'FontSize',10,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors ----------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'<';'^';'x';'>'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        setLineStyle  = {'-';'--';'-.';':';'-';'--';'-.';':';'-';'--'};
        
        %# Line, colors and markers
        setMarkerSize      = 10;
        setLineWidthMarker = 1;
        setLineWidth       = 2;
        setLineWidthThin   = 1;
        setLineStyle       = '-';
        setLineStyle1      = '--';
        setLineStyle2      = '-.';
        setLineStyle3      = ':';
        
        % SUBPLOT /////////////////////////////////////////////////////////
        subplot(1,2,1);
        
        % X and Y values --------------------------------------------------
        
        MinVal  = min(Raw_CH_19_Inb_PST);
        MeanVal = mean(Raw_CH_19_Inb_PST);
        MaxVal  = max(Raw_CH_19_Inb_PST);
        
        % Axis data
        x = timeData;
        y = Raw_CH_19_Inb_PST;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        % Mean
        x2 = [min(x) max(x)];
        y2 = [MeanVal MeanVal];
        
        % Min
        x3 = [min(x) max(x)];
        y3 = [MinVal MinVal];
        
        % Max
        x4 = [min(x) max(x)];
        y4 = [MaxVal MaxVal];              
        
        % Plotting --------------------------------------------------------
        h = plot(x,y,'-',x,polyv,'-',x2,y2,'-',x3,y3,'-',x4,y4,'-');
        if enablePlotTitle == 1
            title('{\bf Raw Output (inclusive zero)}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time (s)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Output (V)}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Line width
        set(h(1),'Color',setColor{1},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
        set(h(2),'Color',setColor{6},'Marker','none','LineStyle',setLineStyle1,'linewidth',setLineWidth);
        set(h(3),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h(4),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
        set(h(5),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);        
        
        % Axis limitations
        minX  = min(x);
        maxX  = max(x);
        incrX = 5;
        minY  = MinVal*0.96;
        maxY  = MaxVal*1.04;
        incrY = (maxY-minY)/5;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
        
        %# Legend
        hleg1 = legend('Output (time series)','Trendline','Mean value');
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        % SUBPLOT /////////////////////////////////////////////////////////
        subplot(1,2,2);
        
        % X and Y values --------------------------------------------------
        
        MinVal  = min(CH_19_Inb_PST);
        MeanVal = mean(CH_19_Inb_PST);
        MaxVal  = max(CH_19_Inb_PST);
        
        % Axis data
        x = timeData;
        y = CH_19_Inb_PST;
        
        %# Trendline
        polyf = polyfit(x,y,1);
        polyv = polyval(polyf,x);
        
        % Mean
        x2 = [min(x) max(x)];
        y2 = [MeanVal MeanVal];        
        
        % Min
        x3 = [min(x) max(x)];
        y3 = [MinVal MinVal];    
        
        % Max
        x4 = [min(x) max(x)];
        y4 = [MaxVal MaxVal];            
        
        % Plotting --------------------------------------------------------
        h = plot(x,y,'-',x,polyv,'-',x2,y2,'-',x3,y3,'-',x4,y4,'-');
        if enablePlotTitle == 1
            title('{\bf Raw Output (without zero)}','FontSize',setGeneralFontSize);
        end
        xlabel('{\bf Time (s)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Output (V)}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line width
        set(h(1),'Color',setColor{2},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidthThin);
        set(h(2),'Color',setColor{6},'Marker','none','LineStyle',setLineStyle1,'linewidth',setLineWidth);
        set(h(3),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h(4),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
        set(h(5),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);     
        
        % Axis limitations
        minX  = min(x);
        maxX  = max(x);
        incrX = 5;
        minY  = MinVal*0.85;
        maxY  = MaxVal*1.15;
        incrY = (maxY-minY)/5;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));
        
        %# Legend
        hleg1 = legend('Output (real units)','Trendline','Mean value');
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ------------------------------------------
        
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
        
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for k=1:3
            plotsavename = sprintf('_plots/%s/%s/Run_%s_CH_19-20_PST_Calibration_Plot.%s', 'PST_Calibration', setFileFormat{k}, num2str(runno), setFileFormat{k});
            print(gcf, setSaveFormat{k}, plotsavename);
        end
        close;
        
    end % enableTimeSeriesPlot == 1
    
    %# ********************************************************************
    %# Command Window Output
    %# ********************************************************************
    if enableCommandWindowOutput == 1
        froudeno      = sprintf('%s:: Froude length number: %s [-]', runno, sprintf('%.2f',modelfrrounded));
        
        % Time series data
        inbpst        = sprintf('%s::Inboard PST (time series mean): %s [V]', runno, sprintf('%.2f',mean(Raw_CH_19_Inb_PST)));
        %outbpst       = sprintf('%s::Outboard PST (time series mean): %s [V]', runno, sprintf('%.2f',mean(Raw_CH_20_Outb_PST)));
        
        % Calibration factors and zero values
        inbpstCFZero  = sprintf('%s::Inboard PST: CF = %s, Zero = %s', runno, num2str(CH_19_CF), num2str(CH_19_Zero));
        %outbpstCFZero = sprintf('%s::Outboard PST: CF = %s, Zero = %s', runno, num2str(CH_20_CF), num2str(CH_20_Zero));
        
        % Averaged values with CF*(x-zero) applied
        inbpstAvgMean  = sprintf('%s::Inboard PST (CF*(x-zero) mean): %s [V]', runno, sprintf('%.2f',CH_19_Inb_PST_Mean));
        %outbpstAvgMean = sprintf('%s::Outboard PST (CF*(x-zero) mean): %s [V]', runno, sprintf('%.2f',CH_20_Outb_PST_Mean));
        
        %# Display strings ---------------------------------------------------
        
        disp(froudeno);
        
        disp('-------------------------------------------------');
        
        % CH_19
        disp(inbpst);
        disp(inbpstCFZero);
        disp(inbpstAvgMean);
        
        %disp('-------------------------------------------------');
        
        % CH_20
        %disp(outbpst);
        %disp(outbpstCFZero);
        %disp(outbpstAvgMean);
    end % enableCommandWindowOutput == 1
    
end % k=startRun:endRun


%# ************************************************************************
%# 1. Speed vs. Voltage
%# ************************************************************************

M = resultsArrayCalib;
M = M(any(M,2),:);   % Remove zero rows

%# Plotting speed ---------------------------------------------------------
figurename = 'Plot 1: Speed vs. Voltage';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

%if enableA4PaperSizePlot == 1
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);
%end

% Fonts and colours -------------------------------------------------------
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

x1 = M(:,10);
y1 = M(:,5);

% Curve fitting
[fitobject,gof,output] = fit(x1,y1,'poly4');
cvalues                = coeffvalues(fitobject);

if enableCommandWindowOutput == 1
    cval = cvalues;
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
    EoFEqn = sprintf('EoF: y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
    disp(EoFEqn);
end

%# Plotting ---------------------------------------------------------------
h1 = plot(fitobject,'-',x1,y1,'*');
legendInfo{1}  = 'Speed vs. Voltage';
legendInfo{2}  = 'Speed vs. Voltage curve fitting';
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
xlabel('{\bf Mean (excl. zero) DPT output (V)}','FontSize',setGeneralFontSize);
ylabel('{\bf Carriage speed (m/s)}','FontSize',setGeneralFontSize);
%if enablePlotTitle == 1
%    title('{\bf Calibration)}','FontSize',setGeneralFontSize);
%end
grid on;
box on;
axis square;

%# Line, colors and markers
%set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker); %,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin
%set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
text(0.7,0.9,EoFEqn,'FontSize',setGeneralFontSize,'color','k','FontWeight','normal');

%# Axis limitations
minX  = 0;
maxX  = 3;
incrX = 0.2;
minY  = 0;
maxY  = 3;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo);
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
%if enableA4PaperSizePlot == 1
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');
%end

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
    plotsavename = sprintf('_plots/%s/%s/Plot_1_Speed_vs_Voltage_Plot.%s', 'PST_Calibration', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
M = resultsArrayCalib;
csvwrite('resultsArrayCalib.dat', M)                                     % Export matrix M to a file delimited by the comma character
dlmwrite('resultsArrayCalib.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile viewer
end
