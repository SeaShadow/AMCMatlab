%# ------------------------------------------------------------------------
%# Resistance Test Analysis - Statistics and averaged run data
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Z�rcher (kzurcher@amc.edu.au)
%# Date       :  September 10, 2013
%#
%# Test date  :  August 27 to September 6, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  01-35   Turbulence Studs Investigation               (TSI)
%# Runs TTI   :  36-62   Trim Tab Optimisation                        (TTI)
%# Runs FF1   :  63-80   Form Factor Estimation using Prohaska Method (FF)
%# Runs RT    :  81-231  Resistance Test                              (RT)
%# Runs FF2   :  231-249 Form Factor Estimation using Prohaska Method (FF)
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
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  10/09/2013 - Created new script
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

% *************************************************************************
%# RESULTS ARRAY COLUMNS
% *************************************************************************
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
%# ERROR ANALYSIS ------------------------------------------------------------------
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
    
%# ------------------------------------------------------------------------
%# Read results DAT file
%# ------------------------------------------------------------------------

if exist('full_resistance_data.dat', 'file') == 2
    %# Read results file
    results = csvread('full_resistance_data.dat');
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('WARNING: Data file for full resistance data (full_resistance_data) does not exist!');
    %break;
end

%# Stop script if required data unavailble --------------------------------
if exist('results','var') == 0
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required resistance data file does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end

% *************************************************************************
% START: PLOTTING AVERAGED DATA
% *************************************************************************

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

%# *********************************************************************
%# Testname
%# *********************************************************************
testName = 'Resistance Test Summary';

%# *********************************************************************
%# Calculate averages for conditions
%# *********************************************************************
[avgcond1]  = stats_avg(1:15,results);
[avgcond2]  = stats_avg(16:25,results);
[avgcond3]  = stats_avg(26:35,results);
[avgcond4]  = stats_avg(36:44,results);
[avgcond5]  = stats_avg(45:53,results);
[avgcond6]  = stats_avg(54:62,results);
[avgcond7]  = stats_avg(63:141,results);
[avgcond8]  = stats_avg(142:156,results);
[avgcond9]  = stats_avg(157:171,results);
[avgcond10] = stats_avg(172:201,results);
[avgcond11] = stats_avg(202:216,results);
[avgcond12] = stats_avg(217:231,results);
[avgcond13] = stats_avg(232:249,results);

%# ------------------------------------------------------------------------   
%# Set plot background (see: http://www.mathworks.com.au/help/matlab/ref/colorspec.html)
%# ------------------------------------------------------------------------   
%whitebg('w');
%whitebg([1 1 1]);
%# ------------------------------------------------------------------------

% *********************************************************************
% TURBULENCE STIMULATOR CONDITIONS
% *********************************************************************     
if length(cond1) ~= 0 || length(cond2) ~= 0 || length(cond3) ~= 0

    startRun = 1;
    endRun   = 35;
    
    figurename = sprintf('%s:: Turbulence Stimulator Investigation, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Plot repeat data ---------------------------------------------------
    subplot(1,2,1)
    
    if length(cond1) ~= 0        
        xcond1 = cond1(:,11); ycond1 = cond1(:,10);

        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond1); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond1 = cell2mat(Raw_Data);
        
        x1 = xcond1; y1 = ycond1;
    else
        x1 = 0; y1 = 0;
    end
    if length(cond2) ~= 0
        xcond2 = cond2(:,11); ycond2 = cond2(:,10);

        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond2); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond2 = cell2mat(Raw_Data);
        
        x2 = xcond2; y2 = ycond2;
    else
        x2 = 0; y2 = 0;
    end
    if length(cond3) ~= 0
        xcond3 = cond3(:,11); ycond3 = cond3(:,10);

        %# Multiply resistance data by 1000 for better readibility        
        Raw_Data = num2cell(ycond3); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond3 = cell2mat(Raw_Data);
        
        x3 = xcond3; y3 = ycond3;
    else
        x3 = 0; y3 = 0;
    end 
    
    h = plot(x1,y1,'*',x2,y2,'+',x3,y3,'x','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Total resistance coefficient C_{tm}*1000 [-]}');
    grid on;
    box on;
    axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    xlim([0.2 0.45]);
    set(gca,'XTick',[0.20 0.25 0.30 0.35 0.40 0.45]);
    setmaxy = max([max(y1),max(y2),max(y3)])*1.02;
    setminy = min([min(y1),min(y2),min(y3)])*0.98;
    %ylim([0 setmaxy]);
    ylim([setminy setmaxy]); 

    %# Legend
    hleg1 = legend('Cond. 1: 1,500t (Barehull)','Cond. 2: 1,500t (1st row)','Cond. 3: 1,500t (1st and 2nd row)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
%# Plot averaged data -----------------------------------------------------
    subplot(1,2,2)
    
    if length(avgcond1) ~= 0        
        xavgcond1 = avgcond1(:,11); yavgcond1 = avgcond1(:,10);

        %# Multiply resistance data by 1000 for better readibility        
        Raw_Data = num2cell(yavgcond1); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond1 = cell2mat(Raw_Data);
        
        x1 = xavgcond1; y1 = yavgcond1;
    else
        x1 = 0; y1 = 0;
    end
    if length(avgcond2) ~= 0
        xavgcond2 = avgcond2(:,11); yavgcond2 = avgcond2(:,10);

        %# Multiply resistance data by 1000 for better readibility        
        Raw_Data = num2cell(yavgcond2); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond2 = cell2mat(Raw_Data);                                         
        
        x2 = xavgcond2; y2 = yavgcond2;
    else
        x2 = 0; y2 = 0;
    end
    if length(avgcond3) ~= 0
        xavgcond3 = avgcond3(:,11); yavgcond3 = avgcond3(:,10);

        %# Multiply resistance data by 1000 for better readibility        
        Raw_Data = num2cell(yavgcond3); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond3 = cell2mat(Raw_Data);
        
        x3 = xavgcond3; y3 = yavgcond3;
    else
        x3 = 0; y3 = 0;
    end
    
    h = plot(x1,y1,'-*',x2,y2,'-+',x3,y3,'-x','MarkerSize',10);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Total resistance coefficient C_{tm}*1000 [-]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([0.2 0.45]);
    set(gca,'XTick',[0.20 0.25 0.30 0.35 0.40 0.45]);
    setmaxy = max([max(y1),max(y2),max(y3)])*1.02;
    setminy = min([min(y1),min(y2),min(y3)])*0.98;
    %ylim([0 setmaxy]);
    ylim([setminy setmaxy]); 
    
    %# Legend
    hleg1 = legend('Cond. 1: 1,500t (Barehull)','Cond. 2: 1,500t (1st row)','Cond. 3: 1,500t (1st and 2nd row)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');    
    legend boxoff;
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Turbulence_Stimulator_Resistance_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Turbulence_Stimulator_Resistance_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;
    
end

% *********************************************************************
% TRIM TAB CONDITIONS
% *********************************************************************     
if length(cond4) ~= 0 || length(cond5) ~= 0 || length(cond6) ~= 0

    startRun = 36;
    endRun   = 62;
    
    figurename = sprintf('%s:: Trim Tab Investigation, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');   
    
    %# Plot repeat data ---------------------------------------------------
    subplot(1,2,1)
    
    if length(cond4) ~= 0        
        xcond4 = cond4(:,11); ycond4 = cond4(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond4); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond4 = cell2mat(Raw_Data);
        
        x4 = xcond4; y4 = ycond4;
    else
        x1 = 0; y1 = 0;
    end
    if length(cond5) ~= 0
        xcond5 = cond5(:,11); ycond5 = cond5(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond5); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond5 = cell2mat(Raw_Data);
        
        x5 = xcond5; y5 = ycond5;
    else
        x2 = 0; y2 = 0;
    end
    if length(cond6) ~= 0
        xcond6 = cond6(:,11); ycond6 = cond6(:,10);

        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond6); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond6 = cell2mat(Raw_Data);
        
        x6 = xcond6; y6 = ycond6;
    else
        x3 = 0; y3 = 0;
    end
    
    h = plot(x4,y4,'*',x5,y5,'+',x6,y6,'x','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Total resistance coefficient C_{tm}*1000 [-]}');
    grid on;
    box on;
    axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations
    xlim([0.42 0.48]);
    set(gca,'XTick',[0.42 0.43 0.44 0.45 0.46 0.47 0.48]);
    setmaxy = max([max(y4),max(y5),max(y6)])*1.02;
    setminy = min([min(y4),min(y5),min(y6)])*0.98;
    %ylim([0 setmaxy]);
    ylim([setminy setmaxy]);

    %# Legend
    hleg1 = legend('Cond. 4: 1,500t (5 degrees)','Cond. 5: 1,500t (0 degrees)','Cond. 6: 1,500t (10 degrees)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
%# Plot averaged data -----------------------------------------------------
    subplot(1,2,2)
    
    if length(avgcond4) ~= 0        
        xavgcond4 = avgcond4(:,11); yavgcond4 = avgcond4(:,10);

        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond4); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond4 = cell2mat(Raw_Data);
        
        x4 = xavgcond4; y4 = yavgcond4;
    else
        x1 = 0; y1 = 0;
    end
    if length(avgcond5) ~= 0
        xavgcond5 = avgcond5(:,11); yavgcond5 = avgcond5(:,10);

        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond5); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond5 = cell2mat(Raw_Data);
        
        x5 = xavgcond5; y5 = yavgcond5;
    else
        x2 = 0; y2 = 0;
    end
    if length(avgcond6) ~= 0
        xavgcond6 = avgcond6(:,11); yavgcond6 = avgcond6(:,10);

        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond6); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond6 = cell2mat(Raw_Data);
        
        x6 = xavgcond6; y6 = yavgcond6;
    else
        x3 = 0; y3 = 0;
    end
    
    h = plot(x4,y4,'-*',x5,y5,'-+',x6,y6,'-x','MarkerSize',10);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Total resistance coefficient C_{tm}*1000 [-]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([0.42 0.48]);
    set(gca,'XTick',[0.42 0.43 0.44 0.45 0.46 0.47 0.48]);
    setmaxy = max([max(y4),max(y5),max(y6)])*1.02;
    setminy = min([min(y4),min(y5),min(y6)])*0.98;
    %ylim([0 setmaxy]);
    ylim([setminy setmaxy]);
    
    %# Legend
    hleg1 = legend('Cond. 4: 1,500t (5 degrees)','Cond. 5: 1,500t (0 degrees)','Cond. 6: 1,500t (10 degrees)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');    
    legend boxoff;
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Trim_Tab_Resistance_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Trim_Tab_Resistance_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;       
  
end

% *********************************************************************
% 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *********************************************************************     
if length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
    
    %startRun = R(1:1);
    %endRun   = R(end, 1);
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('%s:: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');   

    % Fr vs. Rtm (#9) or Ctm (#10) ---------------------------------------------------------
    %subplot(2,2,1:2) % Merged plot over two columns
    subplot(2,2,1)

    if length(cond7) ~= 0
        xcond7 = cond7(:,11); ycond7 = cond7(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond7 = cell2mat(Raw_Data);
                
        x7 = xcond7; y7 = ycond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        xcond8 = cond8(:,11); ycond8 = cond8(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond8 = cell2mat(Raw_Data);
                
        x8 = xcond8; y8 = ycond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        xcond9 = cond9(:,11); ycond9 = cond9(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond9 = cell2mat(Raw_Data);
                
        x9 = xcond9; y9 = ycond9;
    else
        x9 = 0; y9 = 0;
    end    
    if length(cond10) ~= 0
        xcond10 = cond10(:,11); ycond10 = cond10(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond10 = cell2mat(Raw_Data);
                
        x10 = xcond10; y10 = ycond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        xcond11 = cond11(:,11); ycond11 = cond11(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond11 = cell2mat(Raw_Data);
                
        x11 = xcond11; y11 = ycond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        xcond12 = cond12(:,11); ycond12 = cond12(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(ycond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); ycond12 = cell2mat(Raw_Data);
                
        x12 = xcond12; y12 = ycond12;
    else
        x12 = 0; y12 = 0;
    end
    
    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'x',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Total resistance coefficient C_{tm}*1000 [-]}');
    grid on;
    box on;
    axis square;
        
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Axis limitations
    xlim([0.1 0.5]);
    set(gca,'XTick',[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5])

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    % Full scale speed vs. full scale effective power -------------------------
    subplot(2,2,2)

    %x = R(:,15);
    %y = R(:,26);

    if length(cond7) ~= 0
        x7 = cond7(:,15); y7 = cond7(:,26);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        x8 = cond8(:,15); y8 = cond8(:,26);
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        x9 = cond9(:,15); y9 = cond9(:,26);
    else
        x9 = 0; y9 = 0;
    end    
    if length(cond10) ~= 0
        x10 = cond10(:,15); y10 = cond10(:,26);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        x11 = cond11(:,15); y11 = cond11(:,26);
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        x12 = cond12(:,15); y12 = cond12(:,26);
    else
        x12 = 0; y12 = 0;
    end    
    
    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'x',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Full scale speed [knots]}');
    ylabel('{\bf Full scale effective power [W]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([10 30]);
    set(gca,'XTick',[10 12 14 16 18 20 22 24 26 28 30]);
    %setmaxy = max([max(y7),max(y8),max(y9),max(y10),max(y11),max(y12)])*1.1
    %ylim([0 setmaxy]);

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(2,2,3)

    %x = R(:,11);
    %y = R(:,12);

    if length(cond7) ~= 0
        x7 = cond7(:,11); y7 = cond7(:,12);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        x8 = cond8(:,11); y8 = cond8(:,12);
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        x9 = cond9(:,11); y9 = cond9(:,12);
    else
        x9 = 0; y9 = 0;
    end    
    if length(cond10) ~= 0
        x10 = cond10(:,11); y10 = cond10(:,12);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        x11 = cond11(:,11); y11 = cond11(:,12);
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        x12 = cond12(:,11); y12 = cond12(:,12);
    else
        x12 = 0; y12 = 0;
    end    
    
    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'x',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([0.15 0.5]);
    set(gca,'XTick',[0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5])

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    legend boxoff;
    
    % Model speed vs. model trim (degrees) ------------------------------------
    subplot(2,2,4)

    %x = R(:,11);
    %y = R(:,13);
    
    if length(cond7) ~= 0
        x7 = cond7(:,11); y7 = cond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(cond8) ~= 0
        x8 = cond8(:,11); y8 = cond8(:,13);
    else
        x8 = 0; y8 = 0;
    end
    if length(cond9) ~= 0
        x9 = cond9(:,11); y9 = cond9(:,13);
    else
        x9 = 0; y9 = 0;
    end    
    if length(cond10) ~= 0
        x10 = cond10(:,11); y10 = cond10(:,13);
    else
        x10 = 0; y10 = 0;
    end
    if length(cond11) ~= 0
        x11 = cond11(:,11); y11 = cond11(:,13);
    else
        x11 = 0; y11 = 0;
    end
    if length(cond12) ~= 0
        x12 = cond12(:,11); y12 = cond12(:,13);
    else
        x12 = 0; y12 = 0;
    end     

    h = plot(x7,y7,'*',x8,y8,'+',x9,y9,'x',x10,y10,'o',x11,y11,'s',x12,y12,'d','MarkerSize',7);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Running trim [Degrees]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([0.15 0.5]);
    set(gca,'XTick',[0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5])

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Resistance_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Resistance_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;    
    
end

% *********************************************************************
% AVERAGED: 1,500 AND 1,804 TONNES RESISTANCE CONDITIONS
% *********************************************************************
if length(cond7) ~= 0 || length(cond8) ~= 0 || length(cond9) ~= 0 || length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
    
    %startRun = R(1:1);
    %endRun   = R(end, 1);
    startRun = 81;
    endRun   = 231;
    
    figurename = sprintf('Averaged %s:: 1,500 and 1,804 tonnes, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');   

    % Fr vs. Rtm (#9) or Ctm (#10) ---------------------------------------------------------
    %subplot(2,2,1:2) % Merged plot over two columns
    subplot(2,2,1)

    if length(avgcond7) ~= 0
        xavgcond7 = avgcond7(:,11); yavgcond7 = avgcond7(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond7); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond7 = cell2mat(Raw_Data);
                
        x7 = xavgcond7; y7 = yavgcond7;
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        xavgcond8 = avgcond8(:,11); yavgcond8 = avgcond8(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond8); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond8 = cell2mat(Raw_Data);
                
        x8 = xavgcond8; y8 = yavgcond8;
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        xavgcond9 = avgcond9(:,11); yavgcond9 = avgcond9(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond9); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond9 = cell2mat(Raw_Data);
                
        x9 = xavgcond9; y9 = yavgcond9;
    else
        x9 = 0; y9 = 0;
    end    
    if length(avgcond10) ~= 0
        xavgcond10 = avgcond10(:,11); yavgcond10 = avgcond10(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond10); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond10 = cell2mat(Raw_Data);
                
        x10 = xavgcond10; y10 = yavgcond10;
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        xavgcond11 = avgcond11(:,11); yavgcond11 = avgcond11(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond11); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond11 = cell2mat(Raw_Data);
                
        x11 = xavgcond11; y11 = yavgcond11;
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        xavgcond12 = avgcond12(:,11); yavgcond12 = avgcond12(:,10);
        
        %# Multiply resistance data by 1000 for better readibility
        Raw_Data = num2cell(yavgcond12); Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false); yavgcond12 = cell2mat(Raw_Data);
                
        x12 = xavgcond12; y12 = yavgcond12;
    else
        x12 = 0; y12 = 0;
    end
    
    h = plot(x7,y7,'-*',x8,y8,'-+',x9,y9,'-+',x10,y10,'--o',x11,y11,'--s',x12,y12,'--d','MarkerSize',5);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Total resistance coefficient C_{tm}*1000 [-]}');
    grid on;
    box on;
    axis square;
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    %# Line width
    %set(h(1),'linewidth',2);
    %set(h(2),'linewidth',2);
    %set(h(3),'linewidth',2);    
    %set(h(4),'linewidth',1);
    %set(h(5),'linewidth',1);
    %set(h(6),'linewidth',1);
    
    %# Axis limitations
    xlim([0.1 0.5]);
    set(gca,'XTick',[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5])

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    % Full scale speed vs. full scale effective power -------------------------
    subplot(2,2,2)

    %x = R(:,15);
    %y = R(:,26);

    if length(avgcond7) ~= 0
        x7 = avgcond7(:,15); y7 = avgcond7(:,26);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        x8 = avgcond8(:,15); y8 = avgcond8(:,26);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        x9 = avgcond9(:,15); y9 = avgcond9(:,26);
    else
        x9 = 0; y9 = 0;
    end    
    if length(avgcond10) ~= 0
        x10 = avgcond10(:,15); y10 = avgcond10(:,26);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        x11 = avgcond11(:,15); y11 = avgcond11(:,26);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        x12 = avgcond12(:,15); y12 = avgcond12(:,26);
    else
        x12 = 0; y12 = 0;
    end    
    
    h = plot(x7,y7,'-*',x8,y8,'-+',x9,y9,'-+',x10,y10,'--o',x11,y11,'--s',x12,y12,'--d','MarkerSize',5);
    xlabel('{\bf Full scale speed [knots]}');
    ylabel('{\bf Full scale effective power [W]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([10 30]);
    set(gca,'XTick',[10 12 14 16 18 20 22 24 26 28 30]);
    %setmaxy = max([max(y7),max(y8),max(y9),max(y10),max(y11),max(y12)])*1.1
    %ylim([0 setmaxy]);

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    % Model speed vs. model heave (mm) ----------------------------------------
    subplot(2,2,3)

    %x = R(:,11);
    %y = R(:,12);

    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,12);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        x8 = avgcond8(:,11); y8 = avgcond8(:,12);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        x9 = avgcond9(:,11); y9 = avgcond9(:,12);
    else
        x9 = 0; y9 = 0;
    end    
    if length(avgcond10) ~= 0
        x10 = avgcond10(:,11); y10 = avgcond10(:,12);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        x11 = avgcond11(:,11); y11 = avgcond11(:,12);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        x12 = avgcond12(:,11); y12 = avgcond12(:,12);
    else
        x12 = 0; y12 = 0;
    end    
    
    h = plot(x7,y7,'-*',x8,y8,'-+',x9,y9,'-+',x10,y10,'--o',x11,y11,'--s',x12,y12,'--d','MarkerSize',5);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Heave [mm]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([0.15 0.5]);
    set(gca,'XTick',[0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5])

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','SouthWest');
    set(hleg1,'Interpreter','none');    
    legend boxoff;
    
    % Model speed vs. model trim (degrees) ------------------------------------
    subplot(2,2,4)

    %x = R(:,11);
    %y = R(:,13);
    
    if length(avgcond7) ~= 0
        x7 = avgcond7(:,11); y7 = avgcond7(:,13);
    else
        x7 = 0; y7 = 0;
    end
    if length(avgcond8) ~= 0
        x8 = avgcond8(:,11); y8 = avgcond8(:,13);
    else
        x8 = 0; y8 = 0;
    end
    if length(avgcond9) ~= 0
        x9 = avgcond9(:,11); y9 = avgcond9(:,13);
    else
        x9 = 0; y9 = 0;
    end    
    if length(avgcond10) ~= 0
        x10 = avgcond10(:,11); y10 = avgcond10(:,13);
    else
        x10 = 0; y10 = 0;
    end
    if length(avgcond11) ~= 0
        x11 = avgcond11(:,11); y11 = avgcond11(:,13);
    else
        x11 = 0; y11 = 0;
    end
    if length(avgcond12) ~= 0
        x12 = avgcond12(:,11); y12 = avgcond12(:,13);
    else
        x12 = 0; y12 = 0;
    end     

    h = plot(x7,y7,'-*',x8,y8,'-+',x9,y9,'-+',x10,y10,'--o',x11,y11,'--s',x12,y12,'--d','MarkerSize',5);
    xlabel('{\bf Froude length number [-]}');
    ylabel('{\bf Running trim [Degrees]}');
    grid on;
    box on;
    axis square;

    %# Axis limitations
    xlim([0.15 0.5]);
    set(gca,'XTick',[0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5])

    %# Legend
    hleg1 = legend('Cond. 7: 1,500t (0 deg)','Cond. 8: 1,500t (-0.5 deg)','Cond. 9: 1,500t (0.5 deg)','Cond. 10: 1,804t (0 deg)','Cond. 11: 1,804t (-0.5 deg)','Cond. 12: 1,804t (0.5 deg)');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Averaged_Resistance_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Averaged_Resistance_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;    
    
end

% *********************************************************************
% 1,804 TONNES RESISTANCE CONDITIONS
% *********************************************************************     
% if length(cond10) ~= 0 || length(cond11) ~= 0 || length(cond12) ~= 0
%     disp('Conditions 10 to 12 available');
% end

% *********************************************************************
% DEEP TRANSOM PROHASKA CONDITION
% *********************************************************************   
if length(cond13) ~= 0
    
    startRun = 232;
    endRun   = 249;
    
    % Array dimensions
    [m,n]    = size(cond13);
    
    %# --------------------------------------------------------------------
    %# Prohaska array columns ---------------------------------------------
    %# --------------------------------------------------------------------
    %  [1]  X-Axis; Fr^4/Cfm (Using ITTC 1957 for Cfm)
    %  [2]  Y-Axis; Ctm/Cfm  (Using ITTC 1957 for Cfm)
    %  [3]  X-Axis; Fr^4/Cfm (Using Grigson for Cfm)
    %  [4]  Y-Axis; Ctm/Cfm  (Using Grigson for Cfm)
    %# --------------------------------------------------------------------
    
    %# Fr^4/Cfm
    ittcprohaskadata = [];
    for q=1:m
        ittcprohaskadata(q,1) = (cond13(q,11)^4)/cond13(q,17);
        ittcprohaskadata(q,2) = cond13(q,10)/cond13(q,17);
        ittcprohaskadata(q,3) = (cond13(q,11)^4)/cond13(q,18);
        ittcprohaskadata(q,4) = cond13(q,10)/cond13(q,18);
    end
    
    figurename = sprintf('%s:: Prohaska Runs for Form Factor Estimate with Deep Transom, Run %s to %s', testName, num2str(startRun), num2str(endRun));
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Plot repeat data ---------------------------------------------------
    %subplot(1,2,1)
    
    %# ITTC 1957 Friction Line
    x1 = ittcprohaskadata(:,1);
    y1 = ittcprohaskadata(:,2);
    %# Grigson Friction Line
    x2 = ittcprohaskadata(:,3);
    y2 = ittcprohaskadata(:,4);
    
    %# START: Trendline for ITTC 1957 Friction Line -----------------------
    
    polyf1 = polyfit(x1,y1,1);
    polyv1 = polyval(polyf1,x1);
    % Slope of trendline => Y = (slope1 * X ) + slope2
    slopeITTC     = polyf1(1,1);    % Slope
    interceptITTC = polyf1(1,2);    % Intercept
    if interceptITTC > 0
        chooseSign = '+';
        interceptITTC = interceptITTC;
    else
        chooseSign = '-';
        interceptITTC = abs(interceptITTC);
    end
    slopeTextITTC = sprintf('y = %s*x %s %s', sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC));
    
    %# Use CC1(1,2)
    %# NOTE: A correlation coefficient with a magnitude near 1 (as in this case) 
    %#       represents a good fit.  As the fit gets worse, the correlation 
    %#       coefficient approaches zero.
    CC1    = corrcoef(x1,y1);
    
    %# END: Trendline for ITTC 1957 Friction Line -------------------------
    
    %# START: Trendline for Grigson Friction Line -------------------------
    
    polyf2 = polyfit(x2,y2,1);
    polyv2 = polyval(polyf2,x2);
    % Slope of trendline => Y = (slope1 * X ) + slope2
    slopeGrigson     = polyf2(1,1);    % Slope
    interceptGrigson = polyf2(1,2);    % Intercept
    if interceptGrigson > 0
        chooseSign = '+';
        interceptGrigson = interceptGrigson;
    else
        chooseSign = '-';
        interceptGrigson = abs(interceptGrigson);
    end
    slopeTextGrigson = sprintf('y = %s*x %s %s', sprintf('%.3f',slopeGrigson), chooseSign, sprintf('%.3f',interceptGrigson));
    
    %# Use CC2(1,2)
    %# NOTE: A correlation coefficient with a magnitude near 1 (as in this case) 
    %#       represents a good fit.  As the fit gets worse, the correlation 
    %#       coefficient approaches zero.    
    CC2    = corrcoef(x2,y2);
    
    %# END: Trendline for Grigson Friction Line ---------------------------
    
    h = plot(x1,y1,'*b',x2,y2,'xg',x1,polyv1,'-b',x2,polyv2,'-g','MarkerSize',10);
    xlabel('{\bf F_{r}^4/C_{fm} [-]}');
    ylabel('{\bf C_{tm}/C_{fm} [-]}');
    grid on;
    box on;
    axis square;
    
    %# Annotations
    text(0.42,1.08,slopeTextITTC,'FontSize',12,'color','b','FontWeight','normal');
    text(0.42,1.22,slopeTextGrigson,'FontSize',12,'color','g','FontWeight','normal');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line width
    set(h(3),'linewidth',2);
    set(h(4),'linewidth',2);
    
    %# Axis limitations
    xlim([0 0.7]);
    set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7]);
    ylim([1 1.4]);
    set(gca,'YTick',[1 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4]);

    %# Legend
    hleg1 = legend('Cond. 13: ITTC 1957','Cond. 13: Grigson','Cond. 13: ITTC 1957','Cond. 13: Grigson');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
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
    %plotsavenamePDF = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Prohaska_Form_Factor_Resistance_Data_Plots.pdf', '_averaged', num2str(startRun), num2str(endRun));
    %saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/%s/Run%s_to_Run%s_Repeats_Prohaska_Form_Factor_Resistance_Data_Plots.png', '_averaged', num2str(startRun), num2str(endRun));
    saveas(f, plotsavename);                % Save plot as PNG
    %close;    
    
end

% *************************************************************************
% SUMMARY OF MIN, MAC, AVG AND PERCENT VALUES FOR COMPARISONS
% *************************************************************************

% Do something here...