%# ------------------------------------------------------------------------
%# Resistance
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  June 30, 2013
%#
%# Test date  :  August 19-25, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  1-xx   Turbulence Stud Investigation   (TSI)
%# Runs TTI   :  1-xx   Trim Tab Investigation          (TTI)
%# Runs RT    :  1-xx   Resistance Test                 (RT)
%#
%# Speeds (FR):  0.2-0.5 (11.7-27.4 knots)
%#
%# Description:  Turbulence stud ionvestigation, trim tab optimisation and
%#               standard resistance test using a single catamaran demihull.
%#
%# -------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  30/07/2013 - Adjusted analysis file for resistance test data
%#               dd/mm/yyyy - ...
%#
%# -------------------------------------------------------------------------

%# -------------------------------------------------------------------------
%# Clear workspace
%# -------------------------------------------------------------------------
clear
clc

%# -------------------------------------------------------------------------
%# Find and close all plots
%# -------------------------------------------------------------------------
allPlots = findall(0, 'Type', 'figure', 'FileName', []);
delete(allPlots);   % Close all plots

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
%profile on

%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# -------------------------------------------------------------------------

%# Test name ---------------------------------------------------------------
% testName = 'Turbulence Stud Investigation';
% testName = 'Trim Tab Optimistation';
testName = 'Resistance Test';

%# DAQ related settings ----------------------------------------------------
Fs = 200;                       % DAQ sampling frequency = 200Hz

%# Constants and particulars -----------------------------------------------
gravconst          = 9.806;             % Gravitational constant            (m/s2)
modellwl           = 4.26;              % Length waterline of model         (m) at level trim
modelwettedsurface = 1.501;             % Model scale wetted surface area   (m2) at level trim
                                        % NOTE: See hydrostatics table (Excel)
modelkinvi         = 0.00000118831;     % Kinetic viscosity at model scale  (m2/s)
modelwaterdensity  = 1000;              % Model scale water density         (Kg/m3)
distbetwposts      = 1700;              % Distance between carriage posts   (mm)
fstomsratio        = 21.6;              % Full scale to model scale ratio

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 22;  % Number of headerlines to data
headerlinesZeroAndCalib = 16;  % Number of headerlines to zero and calibration factors


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START: Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% X seconds x sample frequency = X x FS = XFS samples (from start)
startSamplePos    = 1;

% X seconds x sample frequency = X x FS = XFS samples (from end)
cutSamplesFromEnd = 0;   

%# ------------------------------------------------------------------------
%# END: Omit first 10 seconds of data due to acceleration
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

startRun = 1;      % Start at run x
endRun   = 1;     % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

resultsArray = [];
%w = waitbar(0,'Processed run files'); 
for k=startRun:endRun
    
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

    % /////////////////////////////////////////////////////////////////////
    % START: CREATE PLOTS AND RUN DIRECTORY
    % ---------------------------------------------------------------------

    %# _PLOTS directory
    fPath = '_plots/';
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else    
        mkdir(fPath);
    end    
    
    %# RUN directory (i.e. R01 for run 1)
%     fPath = sprintf('_plots/%s', name(1:3));
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else    
%         mkdir(fPath);
%     end
    
    %# Averaged directory
    fPath = sprintf('_plots/%s', '_averaged');
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else    
        mkdir(fPath);
    end    
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % ///////////////////////////////////////////////////////////////////// 
    
    
    % /////////////////////////////////////////////////////////////////////
    %# START: Columns as variables (RAW DATA)
    %# --------------------------------------------------------------------
    
    timeData            = data(:,1);   % Timeline
    Raw_CH_0_Speed      = data(:,2);   % Speed             RU: m/s
    Raw_CH_1_LVDTFwd    = data(:,3);   % LVDT: Forward     RU: mm
    Raw_CH_2_LVDTAft    = data(:,4);   % LVDT: Aft         RU: mm
    Raw_CH_3_Drag       = data(:,5);   % Drag              RU: Grams (g)
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);   % Time: Zero
    Time_CF    = ZeroAndCalib(2);   % Time: Calibration factor
    CH_0_Zero  = ZeroAndCalib(3);   % Spped: Zero
    CH_0_CF    = ZeroAndCalib(4);   % Speed: Calibration factor
    CH_1_Zero  = ZeroAndCalib(5);   % Fwd LVDT: Zero
    CH_1_CF    = ZeroAndCalib(6);   % Fwd LVDT: Calibration factor
    CH_2_Zero  = ZeroAndCalib(7);   % Aft LVDT: Zero
    CH_2_CF    = ZeroAndCalib(8);   % Aft LVDT: Calibration factor
    CH_3_Zero  = ZeroAndCalib(9);   % Drag: Zero
    CH_3_CF    = ZeroAndCalib(10);  % Drag: Calibration factor
    
    %# --------------------------------------------------------------------
    %# END: Columns as variables (RAW DATA)
    % /////////////////////////////////////////////////////////////////////
    
    
    % /////////////////////////////////////////////////////////////////////
    % START: REAL UNITS COVNERSION
    % ---------------------------------------------------------------------    
    
    [CH_0_Speed CH_0_Speed_Mean]     = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean] = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean] = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]       = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);    
    
    % ---------------------------------------------------------------------
    % END: REAL UNITS COVNERSION
    % /////////////////////////////////////////////////////////////////////     
   
    
    % *********************************************************************
    % START: PLOTTING RAW DATA
    % *********************************************************************     
    
    figurename = sprintf('%s:: Raw Data Plots, Run %s', testName, name(2:3));
    f = figure('Name',figurename,'NumberTitle','off');       

    %# Time vs. speed -----------------------------------------------------
    subplot(2,2,1);
    
    x = timeData(startSamplePos:end-cutSamplesFromEnd);
    y = CH_0_Speed(startSamplePos:end-cutSamplesFromEnd);
    
    %# Trendline
    polyf = polyfit(x,y,1);
    polyv = polyval(polyf,x);
    
    h = plot(x,y,'-b',x,polyv,'-k');grid on;box on;xlabel('{\bf Time [s]}');ylabel('{\bf Speed [m/s]}');%axis square;
    
    %# Line width
    set(h(1),'linewidth',1);
    set(h(2),'linewidth',2);
    
    %# Legend
    hleg1 = legend('Output (real units)','Trendline');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');    
    
    %# Axis limitations
    xlim([round(x(1)) round(x(end))]);
    
    %# Time vs. fdw LVDT --------------------------------------------------
    subplot(2,2,2);
    
    x = timeData(startSamplePos:end-cutSamplesFromEnd);
    y = CH_1_LVDTFwd(startSamplePos:end-cutSamplesFromEnd); 
    
    %# Trendline
    polyf = polyfit(x,y,1);
    polyv = polyval(polyf,x);
    
    h = plot(x,y,'-b',x,polyv,'-k');grid on;box on;xlabel('{\bf Time [s]}');ylabel('{\bf Fdw LVDT [mm]}');%axis square;
    
    %# Line width
    set(h(1),'linewidth',1);
    set(h(2),'linewidth',2);    
    
    %# Legend
    hleg1 = legend('Output (real units)','Trendline');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');    
    
    %# Axis limitations
    xlim([round(x(1)) round(x(end))]);    
    
    %# Time vs. aft LVDT --------------------------------------------------
    subplot(2,2,3);
    
    x = timeData(startSamplePos:end-cutSamplesFromEnd);
    y = CH_2_LVDTAft(startSamplePos:end-cutSamplesFromEnd);   
    
    %# Trendline
    polyf = polyfit(x,y,1);
    polyv = polyval(polyf,x);
    
    h = plot(x,y,'-b',x,polyv,'-k');grid on;box on;xlabel('{\bf Time [s]}');ylabel('{\bf Afr LVDT [mm]}');%axis square;
    
    %# Line width
    set(h(1),'linewidth',1);
    set(h(2),'linewidth',2);     
    
    %# Legend
    hleg1 = legend('Output (real units)','Trendline');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');    
    
    %# Axis limitations
    xlim([round(x(1)) round(x(end))]);    
    
    %# Time vs. drag ------------------------------------------------------
    subplot(2,2,4);

    x = timeData(startSamplePos:end-cutSamplesFromEnd);
    y = CH_3_Drag(startSamplePos:end-cutSamplesFromEnd); 
    
    %# Trendline
    polyf = polyfit(x,y,1);
    polyv = polyval(polyf,x);
    
    h = plot(x,y,'-b',x,polyv,'-k');grid on;box on;xlabel('{\bf Time [s]}');ylabel('{\bf Drag [g]}');%axis square;
    
    %# Line width
    set(h(1),'linewidth',1);
    set(h(2),'linewidth',2);     
    
    %# Legend
    hleg1 = legend('Output (real units)','Trendline');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','none');
    
    %# Axis limitations
    xlim([round(x(1)) round(x(end))]);    
    
    %# Plot title ---------------------------------------------------------
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');  
    
    %# Save plot as PNG ---------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

    %# Figure size printed on paper
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');          

    %# Save plots as PDF and PNG
    %plotsavenamePDF = sprintf('_plots/Run%s_CH0_to_CH3_Raw_Data_Real_Units.pdf', name(1:3));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/Run%s_CH0_to_CH3_Raw_Data_Real_Units.png', name(1:3));
    saveas(f, plotsavename);                % Save plot as PNG
    close;
    
    % *********************************************************************
    % END: PLOTTING RAW DATA
    % *********************************************************************     
    
    
    % /////////////////////////////////////////////////////////////////////
    % COLLECT AND DISPLAY RESULTS
    % /////////////////////////////////////////////////////////////////////    
        
    %# Add results to dedicated array for simple export
    %# Results array columns: 
        %[1]  Run No.                       (-)
        %[2]  FS                            (Hz)
        %[3]  No. of samples                (-)
        %[4]  Record time                   (s)
        %[5]  Averaged speed                (m/s)
        %[6]  Averaged fwd LVDT             (m)
        %[7]  Averaged aft LVDT             (m)
        %[8]  Averaged drag                 (g)
        %[9]  Total resistance (Rt)         (N)
        %[10] Total resistance coeff. (Ct)  (-)
        %[11] Froude length number          (-)
        %[12] Heave                         (mm)
        %[13] Trim                          (Degrees)
        %[14] Equiv. full scale speed       (m/s)
        %[15] Equiv. full scale speed       (knots)
    resultsArray(k, 1)  = k;                                                        % Run No.
    resultsArray(k, 2)  = round(length(timeData) / timeData(end));                  % FS (Hz)    
    resultsArray(k, 3)  = length(timeData);                                         % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArray(k, 4)  = round(recordTime);                                        % Record time in seconds
    resultsArray(k, 5)  = CH_0_Speed_Mean;                                          % Averaged speed (m/s)
    resultsArray(k, 6)  = CH_1_LVDTFwd_Mean;                                        % Averaged forward LVDT (mm)
    resultsArray(k, 7)  = CH_2_LVDTAft_Mean;                                        % Averaged aft LVDT (mm)
    resultsArray(k, 8)  = CH_3_Drag_Mean;                                           % Averaged drag (g)
    resultsArray(k, 9)  = (resultsArray(k, 8) / 1000) * gravconst;                  % Averaged drag (Rt) (N)
    resultsArray(k, 10) = resultsArray(k, 9) / (0.5*modelwaterdensity*modelwettedsurface*resultsArray(k, 5)^2); % Averaged drag (Ct) (-)
    resultsArray(k, 11) = resultsArray(k, 5) / sqrt(gravconst*modellwl);            % Froude length number (-)
    resultsArray(k, 12) = (resultsArray(k, 6)+resultsArray(k, 7))/2;                % Heave (mm)
    resultsArray(k, 13) = atand((resultsArray(k, 6)-resultsArray(k, 7))/distbetwposts); % Trim (Degrees)
    resultsArray(k, 14) = resultsArray(k, 5) * sqrt(fstomsratio);                   % Equiv. full scale speed (m/s)
    resultsArray(k, 15) = resultsArray(k, 14) / 0.5144;                             % Equiv. full scale speed (knots)
    
    %# Prepare strings for display ----------------------------------------
    name = name(1:3);
    avgspeed          = sprintf('%s:: Averaged speed: %s [m/s]', name, sprintf('%.2f',resultsArray(k, 5)));
    avglvdtfdw        = sprintf('%s:: Averaged fwd LVDT: %s [mm]', name, sprintf('%.2f',resultsArray(k, 6)));
    avglvdtaft        = sprintf('%s:: Averaged aft LVDT: %s [mm]', name, sprintf('%.2f',resultsArray(k, 7)));
    avgdrag           = sprintf('%s:: Averaged drag: %s [g]', name, sprintf('%.2f',resultsArray(k, 8)));
    avgdragrt         = sprintf('%s:: Total resistance (Rt): %s [N]', name, sprintf('%.2f',resultsArray(k, 9)));
    avgdragct         = sprintf('%s:: Total resistance coefficient (Ct): %s [-]', name, sprintf('%.6f',resultsArray(k, 10)));
    froudlengthnumber = sprintf('%s:: Froude length number (Fr): %s [-]', name, sprintf('%.2f',resultsArray(k, 11)));
    heave             = sprintf('%s:: Heave: %s [mm]', name, sprintf('%.2f',resultsArray(k, 12)));
    trim              = sprintf('%s:: Trim: %s [Degrees]', name, sprintf('%.2f',resultsArray(k, 13)));
    equivFSspeedms    = sprintf('%s:: Equiv. full scale speed: %s [m/s]', name, sprintf('%.2f',resultsArray(k, 14)));
    equivFSspeedkts   = sprintf('%s:: Equiv. full scale speed: %s [knots]', name, sprintf('%.2f',resultsArray(k, 15)));

    %# Display strings ----------------------------------------------------
    disp(avgspeed);
    disp(avglvdtfdw);
    disp(avglvdtaft);
    disp(avgdrag);
    disp(avgdragrt);
    disp(avgdragct);
    disp(froudlengthnumber);
    disp(heave);
    disp(trim);
    disp(equivFSspeedms);
    disp(equivFSspeedkts);
    disp('/////////////////////////////////////////////////');    

    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);

% *************************************************************************
% START: PLOTTING AVERAGED DATA
% *************************************************************************

R = resultsArray;   % Results array

figurename = sprintf('%s:: Averaged Data Plots, Run %s to %s', testName, num2str(startRun), num2str(endRun));
f = figure('Name',figurename,'NumberTitle','off');   

% Fr vs. Rt or Ct ---------------------------------------------------------
subplot(2,2,1:2)

x = R(:,11);
y = R(:,9);

h = plot(x,y,'*b','MarkerSize',7);xlabel('{\bf Froude length number [-]}');ylabel('{\bf Total resistance [N]}');grid on;box on;%axis square;

%# Axis limitations
%xlim([x(1) x(end)]);

% Model speed vs. Heave (mm) ----------------------------------------------
subplot(2,2,3)

x = R(:,14);
y = R(:,12);

h = plot(x,y,'*b','MarkerSize',7);xlabel('{\bf Model speed [m/s]}');ylabel('{\bf Heave [mm]}');grid on;box on;%axis square;

% Model speed vs. trim (degrees) ------------------------------------------
subplot(2,2,4)

x = R(:,14);
y = R(:,13);

h = plot(x,y,'*b','MarkerSize',7);xlabel('{\bf Model speed [m/s]}');ylabel('{\bf Trim [Degrees]}');grid on;box on;%axis square;

%# Save plot as PNG -------------------------------------------------------

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');   

%# Plot title -------------------------------------------------------------
annotation('textbox', [0 0.9 1 0.1], ...
    'String', strcat('{\bf ', figurename, '}'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');  

%# Save plots as PDF and PNG
%plotsavenamePDF = sprintf('_plots/%s/Averaged_Data_Plot_Run%s_to_Run%s.pdf', '_averaged', num2str(startRun), num2str(endRun));
%saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/%s/Averaged_Data_Plot_Run%s_to_Run%s.png', '_averaged', num2str(startRun), num2str(endRun));
saveas(f, plotsavename);                % Save plot as PNG
%close;

% *************************************************************************
% END:  PLOTTING AVERAGED DATA
% *************************************************************************


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

M = resultsArray;
csvwrite('resultsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('resultsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer