%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Time Series analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  April 2, 2014
%#
%# Test date  :  August 27 to September 6, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  Runs 01-35   Turbulence Studs Investigation               (TSI)
%#               |__Disp. & trim:   1,500t, level static trim
%#               |__Conditions:     1 = No turbulence studs 
%#                                  2 = First row of turbulence studs
%#                                  3 = First and second row of turbulence studs
%#
%# Runs TTI   :  Runs 36-62   Trim Tab Optimisation                        (TTI)
%#               |__Disp. & trim:   1,500t, level static trim
%#               |__Conditions:     4 = Trim tab at 5 degrees
%#                                  5 = Trim tab at 0 degrees
%#                                  6 = Trim tab at 10 degrees
%#
%# Runs FF1   :  Runs 63-80   Form Factor Estimation using Prohaska Method (FF)
%#               |__Disp. & trim:   1,500t, level static trim, trim tab 5 deg.
%#               |__Condition:      7 = Fr 0.1 to 0.2
%#
%# Runs RT    :  Runs 81-231  Resistance Test                              (RT)
%#               |__Disp. & trim:   1,500t, trim tab 5 deg.
%#               |__Conditions:     7 = Level static trim
%#                                  8 = Static trim = -0.5 deg. (by bow)
%#                                  9 = Static trim = 0.5 deg. (by stern)
%#                                 10 = Level static trim
%#                                 11 = Static trim = -0.5 deg. (by bow)
%#                                 12 = Static trim = 0.5 deg. (by stern)
%#
%# Runs FF2   :  Runs 231-249 Form Factor Estimation using Prohaska Method (FF)
%#               |__Disp. & trim:   1,500t, static trim approx. 3 deg., trim tab 5 deg.
%#               |__Condition:     13 = Fr 0.1 to 0.2
%#
%# Speeds (FR)    :  0.1-0.47 (5.9-27.6 knots)
%#
%# Description    :  Turbulence studs investigation, trim tab optimisation and
%#                   standard resistance test using a single catamaran demihull.
%#                   Form factor estimation has been carried out using prohaska 
%#                   method as described by ITTC 7.2-02-02-01.
%#
%# ITTC Guidelines:  7.5-02-02-01
%#                   7.5-02-02-02
%#
%# ------------------------------------------------------------------------
%#
%# SCRIPTS  :    1 => analysis.m          >> Real units, save date to result array
%#
%#               >>> TODO: Copy data from resultsArray.dat to full_resistance_data.dat
%#
%#               2 => analysis_stats.m    >> Resistance and error plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               3 => analysis_heave.m    >> Heave investigation related plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               4 => analysis_lvdts.m    >> Fr vs. fwd, aft and heave plots
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               5 => analysis_custom.m   >> Fr vs. Rtm/(VolDisp*p*g)*(1/Fr^2)
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#                    |__> RESULTS:       "resultsAveragedArray.dat" and "*.txt"
%#
%#               6 => analysis_ts.m       >> Time series data for cond 7-12
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               7 => analysis_ua.m       >> Resistance uncertainty analysis
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               8 => analysis_sene.m     >> Calibration errors
%#                    |
%#                    |__> BASE DATA:     1. Read .cal data files
%#                                        2. "resultsArraySensorError.dat"
%#
%#               9 => analysis_ts_drag.m  >> Time series data for cond 7-12
%#                    |                   >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               10 => analysis_ts_drag_fft.m  >> Time series data for cond 7-12
%#                    |                        >> DRAG ONLY!!!
%#                    |
%#                    |__> BASE DATA:     "full_resistance_data.dat"
%#
%#               >>> TODO: Copy data from frequencyArrayFFT.dat to fft_frequency_data.dat
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  27/09/2013 - Created new script
%#               14/01/2014 - Added conditions list and updated script
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


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START: Omit first X seconds of data due to acceleration
%# ------------------------------------------------------------------------

% X seconds x sample frequency = X x FS = XFS samples (from start)
%startSamplePos    = 1;
startSamplePos    = 1000;   % Cut first 5 seconds

% X seconds x sample frequency = X x FS = XFS samples (from end)
%cutSamplesFromEnd = 0;   
cutSamplesFromEnd = 400;    % Cut last 2 seconds

%# ------------------------------------------------------------------------
%# END: Omit first 10 seconds of data due to acceleration
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

% All runs for cond 7
startRun = 81;    % Start at run x
endRun   = 141;   % Stop at run y

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START: Read results DAT file
%# ------------------------------------------------------------------------

% Read full_resistance_data
if exist('full_resistance_data.dat', 'file') == 2
    %# Results array columns: 
    
    %[1]  Run No.                                                                  (-)
    %[2]  FS                                                                       (Hz)
    %[3]  No. of samples                                                           (-)
    %[4]  Record time                                                              (s)
    %[5]  Model Averaged speed                                                     (m/s)
    %[6]  Model Averaged fwd LVDT                                                  (m)
    %[7]  Model Averaged aft LVDT                                                  (m)
    %[8]  Model Averaged drag                                                      (g)
    %[9]  Model (Rtm) Total resistance                                             (N)
    %[10] Model (Ctm) Total resistance Coefficient                                 (-)
    %[11] Model Froude length number                                               (-)
    %[12] Model Heave                                                              (mm)
    %[13] Model Trim                                                               (Degrees)
    %[14] Equivalent full scale speed                                              (m/s)
    %[15] Equivalent full scale speed                                              (knots)
    %[16] Model (Rem) Reynolds Number                                              (-)
    %[17] Model (Cfm) Frictional Resistance Coefficient (ITTC'57)                  (-)
    %[18] Model (Cfm) Frictional Resistance Coefficient (Grigson)                  (-)
    %[19] Model (Crm) Residual Resistance Coefficient                              (-)
    %[20] Model (PEm) Model Effective Power                                        (W)
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    %[23] Full Scale (Cfs) Frictional Resistance Coefficient (ITTC'57)             (-)
    %[24] Full Scale (Cts) Total resistance Coefficient                            (-)
    %[25] Full Scale (Rts) Total resistance (Rt)                                   (N)
    %[26] Full Scale (PEs) Model Effective Power                                   (W)
    %[27] Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    %[28] Run condition                                                            (-)
    %[29] SPEED: Minimum value                                                     (m/s)
    %[30] SPEED: Maximum value                                                     (m/s)
    %[31] SPEED: Average value                                                     (m/s)
    %[32] SPEED: Percentage (max.-avg.) to max. value (exp. 3%)                    (m/s)
    %[33] LVDT (FWD): Minimum value                                                (mm)
    %[34] LVDT (FWD): Maximum value                                                (mm)
    %[35] LVDT (FWD): Average value                                                (mm)
    %[36] LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
    %[37] LVDT (AFT): Minimum value                                                (mm)
    %[38] LVDT (AFT): Maximum value                                                (mm)
    %[39] LVDT (AFT): Average value                                                (mm)
    %[40] LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
    %[41] DRAG: Minimum value                                                      (g)
    %[42] DRAG: Maximum value                                                      (g)
    %[43] DRAG: Average value                                                      (g)
    %[44] DRAG: Percentage (max.-avg.) to max. value (exp. 3%)                     (g)
    %[45] SPEED: Standard deviation                                                (m/s)
    %[46] LVDT (FWD): Standard deviation                                           (mm)
    %[47] LVDT (AFT): Standard deviation                                           (mm)
    %[48] DRAG: Standard deviation                                                 (g)

    results = csvread('full_resistance_data.dat');
    
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('---------------------------------------------------------------------------------------');
    disp('File full_resistance_data.dat does not exist!');
    disp('---------------------------------------------------------------------------------------');
    break;
end

%# Stop script if required data unavailble --------------------------------
if exist('results','var') == 0
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!!! WARNING: Required resistance data file does not exist! !!!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end

% Read fft_frequency_data
resultsFreqs = [];
if exist('frequencyArrayFFT.dat', 'file') == 2
    %# fft_frequency_data columns: 
    
    %[1]  Run No.                                              (-)
    %[2]  Length Froude Number                                 (-)
    %[3]  Condition                                            (-)
    %[4]  Max. frequency                                       (Hz)

    resultsFreqs = csvread('fft_frequency_data.dat');
    
    %# Remove zero rows
    resultsFreqs(all(resultsFreqs==0,2),:)=[];
else
    disp('---------------------------------------------------------------------------------------');
    disp('File fft_frequency_data.dat does not exist!');
    disp('---------------------------------------------------------------------------------------');
    break;
end

%# ------------------------------------------------------------------------
%# END: Read results DAT file
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


% *************************************************************************
% START: CONDITIONS BASED ON SPEED
% -------------------------------------------------------------------------

cond1=[];cond2=[];cond3=[];cond4=[];cond5=[];cond6=[];cond7=[];cond8=[];cond9=[];cond10=[];cond11=[];cond12=[];cond13=[];

R = results;            % Results array
R(all(R==0,2),:) = [];  % Remove Zero rows from array
[m,n] = size(R);        % Array dimensions

% Split results array based on column 28 (test condition)
A = arrayfun(@(x) R(R(:,28) == x, :), unique(R(:,28)), 'uniformoutput', false);
[ma,na] = size(A);      % Array dimensions

% Create a new array for each condition
for j=1:ma
    if A{j}(1,28) == 1
        cond1 = A{j};
    end
    if A{j}(1,28) == 2
        cond2 = A{j};
    end
    if A{j}(1,28) == 3
        cond3 = A{j};
    end
    if A{j}(1,28) == 4
        cond4 = A{j};
    end
    if A{j}(1,28) == 5
        cond5 = A{j};
    end
    if A{j}(1,28) == 6
        cond6 = A{j};
    end
    if A{j}(1,28) == 7
        cond7 = A{j};
    end
    if A{j}(1,28) == 8
        cond8 = A{j};
    end
    if A{j}(1,28) == 9
        cond9 = A{j};
    end
    if A{j}(1,28) == 10
        cond10 = A{j};
    end
    if A{j}(1,28) == 11
        cond11 = A{j};
    end
    if A{j}(1,28) == 12
        cond12 = A{j};
    end
    if A{j}(1,28) == 13
        cond13 = A{j};
    end    
end

% -------------------------------------------------------------------------
% END: CONDITIONS BASED ON SPEED
% *************************************************************************


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED 
%                       0 = DISABLED
% -------------------------------------------------------------------------

% Frequency plots
% FILE: fft_frequency_data.dat
enableCond07FreqPlot    = 0; % Frequency plot condition 7
enableCond08FreqPlot    = 0; % Frequency plot condition 8
enableCond09FreqPlot    = 0; % Frequency plot condition 9
enableCond10FreqPlot    = 0; % Frequency plot condition 10
enableCond11FreqPlot    = 0; % Frequency plot condition 11
enableCond12FreqPlot    = 0; % Frequency plot condition 12

% FFT and periodogram plots
% FILE: full_resistance_data.dat
enableCond07Plot        = 1; % Plot condition 7
enableCond08Plot        = 0; % Plot condition 8
enableCond09Plot        = 0; % Plot condition 9
enableCond10Plot        = 0; % Plot condition 10
enableCond11Plot        = 0; % Plot condition 12
enableCond12Plot        = 0; % Plot condition 12

% Check if any plots enabled, if not stop
% if enableCond07Plot == 0 && enableCond08Plot == 0 && enableCond09Plot == 0 && enableCond10Plot == 0 && enableCond11Plot == 0 && enableCond12Plot == 0
%     disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
%     disp('!!! WARNING: No plots enabled! !!!');
%     disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
%     break;
% end

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************  


%# ------------------------------------------------------------------------
%# CONDITION 7: FFT Frequencies
%# ------------------------------------------------------------------------

if enableCond07FreqPlot == 1
    
    % Set condition number
    setCondition = 7;
    
    setArray = resultsFreqs;
    sortedArray = arrayfun(@(x) setArray(setArray(:,3) == x, :), unique(setArray(:,3)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);

    for j=1:ml
        
        if sortedArray{j}(1,3) == setCondition
            
            % Variables
            
            minRunNo = min(sortedArray{j}(:,1));
            maxRunNo = max(sortedArray{j}(:,1));
            RunCond  = sortedArray{j}(1,3);
           
            % Plots
                        
            figurename = sprintf('Condition %s:: Run %s to %s, %s', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), 'Maximum frequencies from drag FFT');
            fig = figure('Name',figurename,'NumberTitle','off');

            % Plot frequencies (bar)
            
            subplot(2,1,1);            
            
            x = sortedArray{j}(:,2);
            y = sortedArray{j}(:,4);
            
            bar(y,0.4,'b');
            set(gca,'XTickLabel',x,'XTick',1:numel(x));
            
            % Rotate x label due to space issues
            xticklabel_rotate([],90,[],'Fontsize',10)
            
            xlabel('Froude length number (-)');
            ylabel('Frequency (-)');
            %title('Bar plot');
            grid on;
            box on;
            %axis square;
            
            %# Set plot figure background to a defined color
            %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
            set(gcf,'Color',[1,1,1]);
           
            % Plot frequencies (scatter)
            
            subplot(2,1,2);
            
            plot(x,y,'rs',...
                'LineWidth',2,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','w',...
                'MarkerSize',8);
            xlabel('Froude length number (-)');
            ylabel('Frequency (-)');
            %title('Scatter plot');
            grid on;
            box on;
            %axis square;

            %# Axis limitations
            minX = min(x);
            maxX = max(x);
            set(gca,'XLim',[minX maxX]);
            set(gca,'XTick',[minX:0.01:maxX]);
            
            % Rotate x label due to space issues
            xticklabel_rotate([],90,[],'Fontsize',10)
            
            %# Save plot as PNG -------------------------------------------
            
            %# Figure size on screen (50% scaled, but same aspect ratio)
            set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
            
            %# Figure size printed on paper
            set(gcf, 'PaperUnits','centimeters');
            set(gcf, 'PaperSize',[XPlot YPlot]);
            set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
            set(gcf, 'PaperOrientation','portrait');
            
            %# Plot title -------------------------------------------------
            annotation('textbox', [0 0.9 1 0.1], ...
                'String', strcat('{\bf ', figurename, '}'), ...
                'EdgeColor', 'none', ...
                'HorizontalAlignment', 'center');
            
            %# Save plots as PDF and PNG
            %plotsavenamePDF = sprintf('%s/_Cond_%s_Run%s_to_Run%s_FFT_Frequency_Plot_FFT.pdf', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo));
            %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
            plotsavename = sprintf('%s/_Cond_%s_Run%s_to_Run%s_FFT_Frequency_Plot_FFT.png', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo));
            saveas(fig, plotsavename);                % Save plot as PNG
            %close;
            
        end % If statement
        
    end % For loop

end % enableCond07FreqPlot

test = arrayfun(@(x) cond7(cond7(:,11) == x, :), unique(cond7(:,11)), 'uniformoutput', false);

%# ------------------------------------------------------------------------
%# CONDITION 7: Time Series FFT
%# ------------------------------------------------------------------------

if enableCond07Plot == 1
    
    sortedArray = arrayfun(@(x) cond7(cond7(:,11) == x, :), unique(cond7(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    % Loop through speed groups
    frequencyArray = [];
    polyfitArray   = [];
    FACounter = 1;
    for j=1:ml

        [ms,ns] = size(sortedArray{j});

        minRunNo    = min(sortedArray{j}(:,1));
        maxRunNo    = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;

        %# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        %# PLOT: DRAG ONLY. WALL INACURACCY INVESTIGATION
        %# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+       
        
        figurename = sprintf('Condition %s:: Run %s to %s, Fr=%s, %s', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo), 'Repeated Runs Time Series Drag Data and FFT');
        fig = figure('Name',figurename,'NumberTitle','off');
        
        setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
        setColor  = {'r';'g';'b';'c';'m';'y';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1]};
        %setLine   = {'--';'-.';'--';'-.';'--';'-.';'--';'-.';'--';'-.'};
        setLine   = {'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};
        
        minXValues = [];
        maxXValues = [];
        minYValues = [];
        maxYValues = [];
        
        %# Filters --------------------------------------------------------
        
        % Moving Average Filter
        %a = 1;
        %b = [1/4 1/4 1/4 1/4];
        
        % Discrete Filter
        %a = [1 0.2];
        %b = [2 3];
        
        % Loop through repeats of speed group -----------------------------
        runDataLength = []; % Lengths of runs (i.e no of samples)
        for k=1:ms
            
            % Correct for run numbers below 10
            runNo = sortedArray{j}(k,1);
            if runNo < 10
                runnumber = sprintf('0%s',num2str(runNo));
            else
                runnumber = sprintf('%s',num2str(runNo));
            end
            
            %# Read run time series data create with analysis script ------
            
            % Define run filename
            filename = sprintf('_time_series_data/R%s.dat',runnumber);

            % Read DAT file
            if exist(filename, 'file') == 2
                timeSeriesData = csvread(filename);
                timeSeriesData(all(timeSeriesData==0,2),:)=[];
            else
                break;
            end
            
            % Column names for timeSeriesData
            
            %[1] Time               (s)
            %[2] RU: Speed          (m/s)
            %[3] RU: Forward LVDT   (mm)
            %[4] RU: Aft LVDT       (mm)
            %[5] RU: Drag           (g)
            
            %# Set columns to be used as X and Y values from time series data
            
            x  = timeSeriesData(:,1);
            y  = timeSeriesData(:,5);
            
            %# Store run data lengths -------------------------------------
            
            runDataLength(k, 1) = length(y);            
            
        end % For loop
        
        % Loop through repeats of speed group -----------------------------
        graphLeft     = 1;  % Used to align subplots in figure 3 x n
        graphCenter   = 2;  % Used to align subplots in figure 3 x n
        graphRight    = 3;  % Used to align subplots in figure 3 x n
        runDataArray  = [];
        for k=1:ms
            
            %# Data preparation -------------------------------------------
            
            % Correct for run numbers below 10
            runNo = sortedArray{j}(k,1);
            if runNo < 10
                runnumber = sprintf('0%s',num2str(runNo));
            else
                runnumber = sprintf('%s',num2str(runNo));
            end
            
            %# Read run time series data create with analysis script ------
            
            % Define run filename
            filename = sprintf('_time_series_data/R%s.dat',runnumber);

            % Read DAT file
            if exist(filename, 'file') == 2
                timeSeriesData = csvread(filename);
                timeSeriesData(all(timeSeriesData==0,2),:)=[];
            else
                break;
            end
            
            % Column names for timeSeriesData
            
            %[1] Time               (s)
            %[2] RU: Speed          (m/s)
            %[3] RU: Forward LVDT   (mm)
            %[4] RU: Aft LVDT       (mm)
            %[5] RU: Drag           (g)
            
            %# Set columns to be used as X and Y values from time series data
            
            x  = timeSeriesData(:,1);
            y  = timeSeriesData(:,5);
            
            % USING FILTER
            %fy = filter(b,a,y);
                        
            [tsm,tsn] = size(x);
            
            %# Detrending -------------------------------------------------
            
            % Find the maximum value in each column
            mx    = max(y);
            
            % Calculate the mean of each column
            mu    = mean(y);
            
            % Calculate the standard deviation of each column
            sigma = std(y);            
            
            % Create a matrix of mean values by replicating the mu vector for n rows
            MeanMat = repmat(mu,tsm,1);

            %# Subtract mean (i.e. remove baseline) -----------------------
            % See: http://www.psy.gla.ac.uk/~joachim/TSA/Time_series_analysis_tutorial1.pdf
            
            % Subtract the column mean from each element in that column
            % See: http://cda.psych.uiuc.edu/matlab_class_material/data_analysis.pdf
            dy1      = y - MeanMat;
            
            % Similar approach to subtract mean and fit using DETREND
            % See: http://www.mathworks.com.au/help/matlab/ref/detrend.html
            %dy1      = detrend(y);              % Removes the best straight-line fit from vector y
            %dy1      = detrend(y,'constant');   % Removes the mean value from vector y            
            
            % Testbed
            %dy2      = medfilt1(dy1,1000);
            %dy2      = dy1;

            %# Store y data to runDataArray -------------------------------
            
            % Columns:
            
                % [1] Run x: Raw data
                % [2] Run y: Raw data
                % [3] Run z: Raw data
                % [n] Run n: Raw data

                % [4] Run x: Raw data - mean (detrend)
                % [5] Run y: Raw data - mean (detrend)
                % [6] Run z: Raw data - mean (detrend)
                % [n] Run n: Raw data
            
            runDataArray(:,k)    = y(1:min(runDataLength));
            runDataArray(:,k+ms) = dy1(1:min(runDataLength));
            
            %# Min and max values -----------------------------------------
            
            %# Set min and max values for axis limitations
            
            minXValues(ms) = min(x);
            maxXValues(ms) = max(x);
            minYValues(ms) = min(y);
            maxYValues(ms) = max(y);       

            %# Plot time vs. output ---------------------------------------
            
            subplot(ms,3,graphLeft)
            
            % Linear fit through detrended data ---------------------------
            polyf = polyfit(x,dy1,1);
            polyv = polyval(polyf,x);

            % Slope and intercept of linear fit ---------------------------
            slopeITTC     = polyf(1,1);         % Slope
            interceptITTC = polyf(1,2);         % Intercept
            theta         = atan(polyf(1));     % Angle
            
            if interceptITTC > 0
                chooseSign = '+';
                interceptITTC = interceptITTC;
            else
                chooseSign = '-';
                interceptITTC = abs(interceptITTC);
            end

            disp('-------------------------------------------------------------');
            slopeTextITTC = sprintf('Run %s:: y = %s*x %s %s, theta = %s', num2str(runnumber), sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
            disp(slopeTextITTC);
            
            %# Store polyfitArray data ------------------------------------
            
            % Columns:
            
                % [1] Run number            (-)            
                % [2] Condition             (-)
                % [3] Length Froude number  (-)
                % [4] Slope                 (-)
                % [5] Intercept             (g)
                % [6] Theta                 (deg)
            
            polyfitArray(FACounter, 1) = str2num(runnumber);
            polyfitArray(FACounter, 2) = RunCond;
            polyfitArray(FACounter, 3) = FroudeNo;
            polyfitArray(FACounter, 4) = slopeITTC;
            polyfitArray(FACounter, 5) = interceptITTC;
            polyfitArray(FACounter, 6) = theta;
            
            % NOT USING FILTER
            %h = plot(x,y,'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',1,'LineStyle',setLine{k},'linewidth',1);
            % USING FILTER, ETC. WHERE 2 COLUMNS USED
            h = plot(x,y,x,dy1,x,polyv);
            xlabel('Time (s)');
            ylabel('Magnitude, drag (g)');
            title('Time series (raw data) and with subtracted mean');
            grid on;
            box on;
            %axis square;
    
            % Line - Colors and markers
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',1,'LineStyle','-.','linewidth',1);
            set(h(2),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',1,'LineStyle','-','linewidth',1);
            set(h(3),'Color','k','Marker',setMarker{k},'MarkerSize',1,'LineStyle','-','linewidth',1);
            
            %# Set plot figure background to a defined color
            %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
            set(gcf,'Color',[1,1,1]);
            
            %# Axis limitations
            maxX = max(maxXValues);
            set(gca,'XLim',[0 maxX]);
            set(gca,'XTick',[0:5:maxX]);
            minY = min(dy1);
            maxY = max(y);
            set(gca,'YLim',[minY*1.2 maxY*1.5]);
            
            %# Legend
            % NOT USING FILTER
            %hleg1 = legend(sprintf('Run %s',num2str(runnumber)));
            % USING FILTER
            hleg1 = legend(sprintf('Run %s',num2str(runnumber)),'Subtracted mean','Linear fit');
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','none');
            legend boxoff;
            
            clearvars legendInfo;
            
            %# Plot FFT ---------------------------------------------------
            
            subplot(ms,3,graphCenter)
            
            % Set x and y as time series objects --------------------------
            
            % http://cda.psych.uiuc.edu/matlab_class_material/data_analysis.pdf)
            ts_time = timeseries(x, length(x), 'name', 'TS-Time');
            getdatasamplesize(ts_time);
            
            % NOTE: Use y as either subtracted mean or detrend
            % DEFAULT: y = y
            y = dy1;
            
            ts_drag = timeseries(y, length(y), 'name', 'TS-Drag');
            getdatasamplesize(ts_drag);
            
            % FFT calculations --------------------------------------------
            
            Fs = 200;               % Sampling frequency
            T = 1/Fs;               % Sample time
            L = tsm;                % Length of signal
            t = (0:L-1)*T;          % Time vector

            % Plot single-sided amplitude spectrum.
            
            NFFT = 2^nextpow2(L);   % Next power of 2 from length of y
            Y    = fft(y,NFFT)/L;
            f    = Fs/2*linspace(0,1,NFFT/2+1);
            
            % Identify peaks
            [maxtabstbd, mintabstbd] = peakdet(2*abs(Y(1:NFFT/2+1)), 0.5, f);
            
            % Find two highest values
            %As   = unique(maxtabstbd(:,2));    % Remove duplicates + sort
           
            As   = sort(maxtabstbd(:,2));
            lst2 = As(end-1:end);

            % Find indexes of highest two values
            ind1 = find(maxtabstbd(:,2)==lst2(1));
            ind2 = find(maxtabstbd(:,2)==lst2(2));
            
            % Set indexes to correc order
            setIndArray = [ind1 ind2];
            setIndArray = sort(setIndArray);
            
            ind1 = setIndArray(1);
            ind2 = setIndArray(2);
            
            % Defined X and Y values
            peakDetX = [maxtabstbd(ind1,1) maxtabstbd(ind2,1)];
            peakDetY = [maxtabstbd(ind1,2) maxtabstbd(ind2,2)];
            
            h = plot(f,2*abs(Y(1:NFFT/2+1)),'-',peakDetX,peakDetY,'ok');
            title('Single-Sided Amplitude Spectrum of y(t)')
            xlabel('{\bf Frequency (Hz)}')
            ylabel('{\bf |Y(f)|}')
            grid on;
            box on;
            %axis square;
            
            % Line - Colors and markers
            set(h(1),'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',1,'LineStyle',setLine{k},'linewidth',1);      
            
            %# Legend
            hleg1 = legend(sprintf('Run %s',num2str(runnumber)));
            set(hleg1,'Location','NorthEast');
            set(hleg1,'Interpreter','none');
            legend boxoff;
            
            clearvars legendInfo;
            
            % Periodogram -------------------------------------------------
            
            subplot(ms,3,graphRight)
            
            % Maximum frequency
            % See: http://www.mathworks.com.au/matlabcentral/answers/28239-get-frequencies-out-of-data-with-an-fft
            psdest = psd(spectrum.periodogram,y,'Fs',Fs,'NFFT',length(y));
            [~,I] = max(psdest.Data);
            fprintf('Run %s:: Maximum frequency occurs at %4.3f Hz\n',num2str(runnumber),psdest.Frequencies(I));
            h1 = plot(psdest);
            set(h1,'Color',setColor{k});

            % Write data to array -----------------------------------------
            
            %# frequencyArray columns:
            
            %[1]  Run No.                                              (-)
            %[2]  Length Froude Number                                 (-)
            %[3]  Condition                                            (-)
            %[4]  Max. frequency                                       (Hz)
            
            % The two highest frequencies:
            %[5]  Frequency #1                                         (Hz)
            %[6]  Frequency #2                                         (Hz)
            
            frequencyArray(FACounter, 1) = str2num(runnumber);
            frequencyArray(FACounter, 2) = FroudeNo;
            frequencyArray(FACounter, 3) = RunCond;
            frequencyArray(FACounter, 4) = psdest.Frequencies(I);
            frequencyArray(FACounter, 5) = peakDetX(1);
            frequencyArray(FACounter, 6) = peakDetX(2);
            
            % Counters only -----------------------------------------------
            % NOTE: Needs to be adjusted if more than 3 columns in graph subplot!
            
            % General counter
            FACounter   = FACounter+1;
            
            % Counter for subplots
            graphLeft   = graphLeft+3;
            graphCenter = graphCenter+3;
            graphRight  = graphRight+3;
            
        end

        %# Save plot as PNG -----------------------------------------------
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
        
        %# Plot title -----------------------------------------------------
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');        
        
        %# Save plots as PDF and PNG
        %plotsavenamePDF = sprintf('%s/Cond_%s_Run%s_to_Run%s_Fr_%s_Time_Series_Drag_Plots_FFT.pdf', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('%s/Cond_%s_Run%s_to_Run%s_Fr_%s_Time_Series_Drag_Plots_FFT.png', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo));
        saveas(fig, plotsavename);                % Save plot as PNG
        %close;
        
        % Plot averaged data ----------------------------------------------
        
        figurename = sprintf('Condition %s:: Run %s to %s, Fr=%s, %s', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo), 'Repeated Runs Time Series Drag Data and FFT. Averaged samples of runs.');
        fig = figure('Name',figurename,'NumberTitle','off');
        
        [mrda,nrda] = size(runDataArray);
        
        data = runDataArray;
        
        % Data (i.e. runDataArray) columns:
        
            % [1] Run x: Raw data
            % [2] Run y: Raw data
            % [3] Run z: Raw data
            % [n] Run n: Raw data

            % [4] Run x: Raw data - mean (detrend)
            % [5] Run y: Raw data - mean (detrend)
            % [6] Run z: Raw data - mean (detrend)
            % [n] Run n: Raw data
            
        % Average run samples
        DA  = [];
        DAD = [];
        for k=1:ms
            if k == 1
                DA(:,1)  = data(:,1);
                DAD(:,1) = data(:,1+ms);
            else    
                DA(:,1)  = DA(:,1)+data(:,k);
                DAD(:,1) = DAD(:,1)+data(:,k+ms);                
            end
        end
        avgDA  = DA(:,1)/ms;
        avgDAD = DAD(:,1)/ms;
        
        %# Plot time vs. output -------------------------------------------
        
        subplot(3,1,1)
        
        % Set axis data
        x  = x(1:min(runDataLength));
        y1 = avgDA;
        y2 = avgDAD;
        
        % Linear fit through detrended data
        polyf = polyfit(x,y2,1);
        polyv = polyval(polyf,x);
        
        % Slope and intercept of linear fit ---------------------------
        slopeITTC     = polyf(1,1);         % Slope
        interceptITTC = polyf(1,2);         % Intercept
        theta         = atan(polyf(1));     % Angle
        
        if interceptITTC > 0
            chooseSign = '+';
            interceptITTC = interceptITTC;
        else
            chooseSign = '-';
            interceptITTC = abs(interceptITTC);
        end
        
        disp('-------------------------------------------------------------');
        slopeTextITTC = sprintf('Run %s to %s at Fr = %s (averaged samples):: y = %s*x %s %s, theta = %s',num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo), sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
        disp(slopeTextITTC);
        
        h = plot(x,y1,x,y2,x,polyv);
        hold on;
        maxTSDataArray    = [];     % Highest data point of TS data
        minTSDetDataArray = [];     % Lowest data point of TS (detrend) data
        for o=1:ms
            plot(x,data(:,o),'Color','r','Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
            maxTSDataArray(o) = max(data(:,o));
        end
        for o=1:ms
            plot(x,data(:,o+3),'Color','b','Marker','+','MarkerSize',1,'LineStyle','-.','linewidth',1);
            minTSDetDataArray(o) = min(data(:,o+3));
        end        
        xlabel('Time (s)');
        ylabel('Magnitude, drag (g)');
        title('Time series (raw data) and with subtracted mean');
        grid on;
        box on;
        %axis square;
        
        % USING FILTER - Colors and markers
        set(h(1),'Color','k','Marker',setMarker{ms+1},'MarkerSize',1,'LineStyle','-','linewidth',1.5); %setColor{ms+1}
        set(h(2),'Color','k','Marker',setMarker{ms+1},'MarkerSize',1,'LineStyle','--','linewidth',1.5);
        set(h(3),'Color','k','Marker','*','MarkerSize',1,'LineStyle','-.','linewidth',1.5);

        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        maxX = max(x);
        set(gca,'XLim',[0 maxX]);
        set(gca,'XTick',[0:5:maxX]);
        minY = min(minTSDetDataArray);
        maxY = max(maxTSDataArray);
        set(gca,'YLim',[minY*1.1 maxY*1.5]);
        
        %# Legend
        legend_names=cell(1,ms*2+3);
        legend_names{1} = 'Averaged samples';
        legend_names{2} = 'Averaged samples, subtracted mean';
        legend_names{3} = 'Linear fit';
        counter = 1;
        for p=4:(ms*2+3)
            if counter > ms
                legend_names{p} = sprintf('Run %s (subtracted mean)',num2str(sortedArray{j}(counter-ms,1)));
            else
                legend_names{p} = sprintf('Run %s',num2str(sortedArray{j}(counter,1)));
            end
            counter = counter+1;
        end
        hleg1 = legend(legend_names);
        %hleg1 = legend(sprintf('Run %s',num2str(runnumber)),'Subtracted mean','Linear fit');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        legend boxoff;
        
        clearvars legendInfo;
        
        %# Plot FFT -------------------------------------------------------
        
        subplot(3,1,2)
        
        Fs = 200;               % Sampling frequency
        T = 1/Fs;               % Sample time
        L = length(x);          % Length of signal
        t = (0:L-1)*T;          % Time vector
        
        % Plot single-sided amplitude spectrum.
        
        NFFT = 2^nextpow2(L);   % Next power of 2 from length of y
        Y    = fft(y2,NFFT)/L;
        f    = Fs/2*linspace(0,1,NFFT/2+1);
        
        plot(f,2*abs(Y(1:NFFT/2+1)),'Color','k','Marker',setMarker{ms+1},'MarkerSize',1,'LineStyle','-','linewidth',1); % setColor{ms+1}
        title('Single-Sided Amplitude Spectrum of y(t)')
        xlabel('{\bf Frequency (Hz)}')
        ylabel('{\bf |Y(f)|}')
        grid on;
        box on;
        %axis square;
        
        %# Legend
        hleg1 = legend('Averaged samples (subtracted mean)');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        legend boxoff;
        
        clearvars legendInfo;
        
        % Periodogram -------------------------------------------------
        
        subplot(3,1,3)
        
        % Maximum frequency
        % See: http://www.mathworks.com.au/matlabcentral/answers/28239-get-frequencies-out-of-data-with-an-fft
        psdest = psd(spectrum.periodogram,y2,'Fs',Fs,'NFFT',length(y2));
        [~,I] = max(psdest.Data);
        fprintf('Run %s to %s at Fr = %s (averaged samples):: Maximum frequency occurs at %4.3f Hz\n',num2str(minRunNo),num2str(maxRunNo),num2str(FroudeNo),psdest.Frequencies(I));
        disp('-------------------------------------------------------------');
        disp(' ');
        h1 = plot(psdest);
        %title('Averaged samples: Periodogram Power Spectral Density Estimate')
        set(h1,'Color','k'); % setColor{ms+1}
        
        %# Legend
        hleg1 = legend('Averaged samples (subtracted mean)');
        set(hleg1,'Location','NorthEast');
        set(hleg1,'Interpreter','none');
        legend boxoff;
        
        clearvars legendInfo;        
        
        %# Save plot as PNG -----------------------------------------------
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
        
        %# Plot title -----------------------------------------------------
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
 
        %# Save plots as PDF and PNG
        %plotsavenamePDF = sprintf('%s/Cond_%s_Run%s_to_Run%s_Fr_%s_Time_Series_Drag_Plots_FFT_Averaged.pdf', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('%s/Cond_%s_Run%s_to_Run%s_Fr_%s_Time_Series_Drag_Plots_FFT_Averaged.png', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo));
        saveas(fig, plotsavename);                % Save plot as PNG
        %close;        

        % ////////////////////////////////////////

        % Run 6 loops to consider different amount of repeated runs
%         if j > 5
%             break;
%         end
        %break;

    end % For loop

end % enableCond07Plot


%# ------------------------------------------------------------------------
%# CONDITION 8: Time Series FFT
%# ------------------------------------------------------------------------

if enableCond08Plot == 1

    sortedArray = arrayfun(@(x) cond8(cond8(:,11) == x, :), unique(cond8(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);

end


%# ------------------------------------------------------------------------
%# CONDITION 9: Time Series FFT
%# ------------------------------------------------------------------------

if enableCond09Plot == 1

    sortedArray = arrayfun(@(x) cond9(cond9(:,11) == x, :), unique(cond9(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);

end


%# ------------------------------------------------------------------------
%# CONDITION 10: Time Series FFT
%# ------------------------------------------------------------------------

if enableCond10Plot == 1

    sortedArray = arrayfun(@(x) cond10(cond10(:,11) == x, :), unique(cond10(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);

end


%# ------------------------------------------------------------------------
%# CONDITION 11: Time Series FFT
%# ------------------------------------------------------------------------

if enableCond11Plot == 1

    sortedArray = arrayfun(@(x) cond11(cond11(:,11) == x, :), unique(cond11(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);

end

%# ------------------------------------------------------------------------
%# CONDITION 12: Time Series FFT
%# ------------------------------------------------------------------------

if enableCond12Plot == 1

    sortedArray = arrayfun(@(x) cond12(cond12(:,11) == x, :), unique(cond12(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);

end


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------

if exist('frequencyArray','var') == 1

    M = frequencyArray;
    csvwrite('frequencyArrayFFT.dat', M)                                     % Export matrix M to a file delimited by the comma character
    dlmwrite('frequencyArrayFFT.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

end

% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////
