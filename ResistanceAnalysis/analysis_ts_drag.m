%# ------------------------------------------------------------------------
%# Resistance Test Analysis - TS analysis, drag only, for wall accuracy
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Z�rcher (kzurcher@amc.edu.au)
%# Date       :  March 13, 2014
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


%# -------------------------------------------------------------------------
%# Read results DAT file
%# -------------------------------------------------------------------------
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

enableCond07Plot        = 1; % Plot condition 7
enableCond08Plot        = 0; % Plot condition 8
enableCond09Plot        = 0; % Plot condition 9
enableCond10Plot        = 0; % Plot condition 10
enableCond11Plot        = 0; % Plot condition 12
enableCond12Plot        = 0; % Plot condition 12

% Check if any plots enabled, if not stop
if enableCond07Plot == 0 && enableCond08Plot == 0 && enableCond09Plot == 0 && enableCond10Plot == 0 && enableCond11Plot == 0 && enableCond12Plot == 0
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!!! WARNING: No plots enabled! !!!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;    
end

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************  


%# ------------------------------------------------------------------------
%# CONDITION 7: Time Series -----------------------------------------------
%# ------------------------------------------------------------------------

if enableCond07Plot == 1
    
    sortedArray = arrayfun(@(x) cond7(cond7(:,11) == x, :), unique(cond7(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    for j=1:ml
        [ms,ns] = size(sortedArray{j});
        
        minRunNo = min(sortedArray{j}(:,1));
        maxRunNo = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;

        %# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        %# PLOT: DRAG ONLY. WALL INACURACCY INVESTIGATION
        %# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+        
        
        figurename = sprintf('Condition %s:: Run %s to %s, Fr=%s, %s', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo), 'Repeated Runs Time Series Drag Data');
        f = figure('Name',figurename,'NumberTitle','off');
        
        setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
        setColor  = {'r';'g';'b';'c';'m';'y';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1]};
        %setLine   = {'--';'-.';'--';'-.';'--';'-.';'--';'-.';'--';'-.'};
        setLine   = {'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};
        
        minXValues = [];
        maxXValues = [];
        minYValues = [];
        maxYValues = [];
        
        % Run through repeats
        for k=1:ms
            
            % Correct for run numbers below 10
            runNo = sortedArray{j}(k,1);
            if runNo < 10
                runnumber = sprintf('0%s',num2str(runNo));
            else
                runnumber = sprintf('%s',num2str(runNo));
            end
            
            % Set general filename
            filename = sprintf('_time_series_data/R%s.dat',runnumber);
            
            % Read DAT file
            if exist(filename, 'file') == 2
                timeSeriesData = csvread(filename);
                timeSeriesData(all(timeSeriesData==0,2),:)=[];
            else
                break;
            end
            
            x = timeSeriesData(:,1);
            y = timeSeriesData(:,5);
            
            minXValues(ms) = min(x);
            maxXValues(ms) = max(x);
            minYValues(ms) = min(y);
            maxYValues(ms) = max(y);
            
            h = plot(x,y,'Color',setColor{k},'Marker',setMarker{k},'MarkerSize',1,'LineStyle',setLine{k},'linewidth',1);
            legendInfo{k} = sprintf('Run %s',num2str(runnumber));
            hold on;
            
        end
        hold off;
        
        xlabel('{\bf Time [s]}');
        ylabel('{\bf Drag [g]}');
        %title('{\bf Drag}');
        grid on;
        box on;
        axis square;
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        maxX = max(maxXValues);
        set(gca,'XLim',[0 maxX]);
        set(gca,'XTick',[0:2:maxX]);
        minY = round(max(minYValues)*0.8);
        maxY = round(max(maxYValues)*1.2);
        setIncr = round((maxY-minY)/5);
        set(gca,'YLim',[minY maxY]);
        set(gca,'YTick',[minY:setIncr:maxY]);
        
        %# Legend
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');
        legend boxoff;
        
        clearvars legendInfo;
        
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
        %plotsavenamePDF = sprintf('%s/Cond_%s_Run%s_to_Run%s_Fr_%s_Time_Series_Drag_Plots.pdf', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo));
        %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('%s/Cond_%s_Run%s_to_Run%s_Fr_%s_Time_Series_Drag_Plots.png', '_time_series_drag_plots', num2str(RunCond), num2str(minRunNo), num2str(maxRunNo), num2str(FroudeNo));
        saveas(f, plotsavename);                % Save plot as PNG
        close;
        
    end % For loop
    
end % enableCond07Plot


%# ------------------------------------------------------------------------
%# CONDITION 8: Time Series -----------------------------------------------
%# ------------------------------------------------------------------------

if enableCond08Plot == 1

    sortedArray = arrayfun(@(x) cond8(cond8(:,11) == x, :), unique(cond8(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    for j=1:ml
        [ms,ns] = size(sortedArray{j});
        
        minRunNo = min(sortedArray{j}(:,1));
        maxRunNo = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;
        
    end

end


%# ------------------------------------------------------------------------
%# CONDITION 9: Time Series -----------------------------------------------
%# ------------------------------------------------------------------------

if enableCond09Plot == 1

    sortedArray = arrayfun(@(x) cond9(cond9(:,11) == x, :), unique(cond9(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    for j=1:ml
        [ms,ns] = size(sortedArray{j});
        
        minRunNo = min(sortedArray{j}(:,1));
        maxRunNo = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;
        
    end

end


%# ------------------------------------------------------------------------
%# CONDITION 10: Time Series -----------------------------------------------
%# ------------------------------------------------------------------------

if enableCond10Plot == 1

    sortedArray = arrayfun(@(x) cond10(cond10(:,11) == x, :), unique(cond10(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    for j=1:ml
        [ms,ns] = size(sortedArray{j});
        
        minRunNo = min(sortedArray{j}(:,1));
        maxRunNo = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;

    end

end


%# ------------------------------------------------------------------------
%# CONDITION 11: Time Series -----------------------------------------------
%# ------------------------------------------------------------------------

if enableCond11Plot == 1

    sortedArray = arrayfun(@(x) cond11(cond11(:,11) == x, :), unique(cond11(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    for j=1:ml
        [ms,ns] = size(sortedArray{j});
        
        minRunNo = min(sortedArray{j}(:,1));
        maxRunNo = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;
        
    end

end

%# ------------------------------------------------------------------------
%# CONDITION 12: Time Series -----------------------------------------------
%# ------------------------------------------------------------------------

if enableCond12Plot == 1

    sortedArray = arrayfun(@(x) cond12(cond12(:,11) == x, :), unique(cond12(:,11)), 'uniformoutput', false);
    [ml,nl] = size(sortedArray);
    
    for j=1:ml
        [ms,ns] = size(sortedArray{j});
        
        minRunNo = min(sortedArray{j}(:,1));
        maxRunNo = max(sortedArray{j}(:,1));
        FroudeNo    = sortedArray{j}(1,11);
        RunCond     = sortedArray{j}(1,28);
        RunRepeats  = ms;

    end

end