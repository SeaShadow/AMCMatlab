%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Curve fitting and error estimate
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  July9, 2013
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  Fitting Experimental Data to Straight Lines.
%#
%# -------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  09/07/2013 - File creation
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
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 29;  % Number of headerlines to data
headerlinesZeroAndCalib = 23;  % Number of headerlines to zero and calibration factors

%# ------------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration ----------------------------
%# ------------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 8000;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 8000;   

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

startRun = 29;      % Start at run x
endRun   = 29;      % Stop at run y

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

%# Collect data for cfArray
    %[1]  Run number
    %[2]  Slope
    %[3]  Intercept
    %[4]  S (root square)
    %[5]  Error slope
    %[6]  Error intercept
    %[7]  Relative slope error
    %[8]  Relative intercept error 
    %[9]  Channel number
    
cfArray = [];

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
    
    %# Columns as variables (RAW DATA)
    timeData             = data(:,1);       % Timeline
    Raw_CH_0_WaveProbe   = data(:,2);       % Wave probe data
    Raw_CH_1_KPStbd      = data(:,3);       % Kiel probe stbd data
    Raw_CH_2_KPPort      = data(:,4);       % Kiel probe port data
    Raw_CH_3_StaticStbd  = data(:,5);       % Static stbd data
    Raw_CH_4_StaticPort  = data(:,6);       % Static port data
    Raw_CH_5_RPMStbd     = data(:,7);       % RPM stbd data
    Raw_CH_6_RPMPort     = data(:,8);       % RPM port data
    Raw_CH_7_ThrustStbd  = data(:,9);       % Thrust stbd data
    Raw_CH_8_ThrustPort  = data(:,10);      % Thrust port data
    Raw_CH_9_TorqueStbd  = data(:,11);      % Torque stbd data
    Raw_CH_10_TorquePort = data(:,12);      % Torque port data
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    %CH_0_CF    = ZeroAndCalib(4);
    CH_0_CF    = 46.001;                % Custom calibration factor
    CH_1_Zero  = ZeroAndCalib(5);
    CH_1_CF    = ZeroAndCalib(6);
    CH_2_Zero  = ZeroAndCalib(7);
    CH_2_CF    = ZeroAndCalib(8);
    CH_3_Zero  = ZeroAndCalib(9);
    CH_3_CF    = ZeroAndCalib(10);
    CH_4_Zero  = ZeroAndCalib(11);
    CH_4_CF    = ZeroAndCalib(12);
    CH_5_Zero  = ZeroAndCalib(13);
    CH_5_CF    = ZeroAndCalib(14);
    CH_6_Zero  = ZeroAndCalib(15);
    CH_6_CF    = ZeroAndCalib(16);
    CH_7_Zero  = ZeroAndCalib(17);
    CH_7_CF    = ZeroAndCalib(18);
    CH_8_Zero  = ZeroAndCalib(19);
    CH_8_CF    = ZeroAndCalib(20);
    CH_9_Zero  = ZeroAndCalib(21);
    CH_9_CF    = ZeroAndCalib(22);
    CH_10_Zero = ZeroAndCalib(23);
    CH_10_CF   = ZeroAndCalib(24);
    
    %# --------------------------------------------------------------------
    %# Get real units by applying calibration factors and zeros
    %# --------------------------------------------------------------------

    timeDataShort = timeData(startSamplePos:end-cutSamplesFromEnd);
    
    %# Wave probe
    [CH_0_WaveProbe CH_0_WaveProbe_Mean]     = analysis_realunits(Raw_CH_0_WaveProbe,CH_0_Zero,CH_0_CF);
    
    %# DPT with kiel probe
    CH_1_KPStbd                              = Raw_CH_1_KPStbd;   % 5 PSI DPT
    CH_2_KPPort                              = Raw_CH_2_KPPort;   % 5 PSI DPT
    
    %# Dynamometer: Thrust
    [CH_7_ThrustStbd CH_7_ThrustStbd_Mean]   = analysis_realunits(Raw_CH_7_ThrustStbd,CH_7_Zero,CH_7_CF);
    [CH_8_ThrustPort CH_8_ThrustPort_Mean]   = analysis_realunits(Raw_CH_8_ThrustPort,CH_8_Zero,CH_8_CF);    
    
    %# Dynamometer: Torque
    [CH_9_TorqueStbd CH_9_TorqueStbd_Mean]   = analysis_realunits(Raw_CH_9_TorqueStbd,CH_9_Zero,CH_9_CF);
    [CH_10_TorquePort CH_10_TorquePort_Mean] = analysis_realunits(Raw_CH_10_TorquePort,CH_10_Zero,CH_10_CF);
    
    [RPMStbd RPMPort]                        = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort);
    
    %# Cut first X and last X seconds from data
    WaveProbe                                = CH_0_WaveProbe(startSamplePos:end-cutSamplesFromEnd);
    KPStbd                                   = CH_1_KPStbd(startSamplePos:end-cutSamplesFromEnd);
    KPPort                                   = CH_2_KPPort(startSamplePos:end-cutSamplesFromEnd);
    ThrustStbd                               = CH_7_ThrustStbd(startSamplePos:end-cutSamplesFromEnd);
    ThrustPort                               = abs(CH_8_ThrustPort(startSamplePos:end-cutSamplesFromEnd));
    TorqueStbd                               = CH_9_TorqueStbd(startSamplePos:end-cutSamplesFromEnd);
    TorquePort                               = abs(CH_10_TorquePort(startSamplePos:end-cutSamplesFromEnd));
        
    %# --------------------------------------------------------------------
    %# CHANNEL LIST
    %# --------------------------------------------------------------------
        %[0]    Wave probe
        %[1]    STBD: DPT (Kiel probe)
        %[2]    PORT: DPT (Kiel probe)
        %-3-    STBD: DPT (Static)
        %-4-    PORT: DPT (Static)
        %-5-    STBD: ISP (RPM)
        %-6-    PORT: ISP (RPM)
        %[7]    STBD: Dyno. thrust
        %[8]    PORT: Dyno. thrust
        %[9]    STBD: Dyno. torque
        %[10]   PORT: Dyno. torque
    
    % /////////////////////////////////////////////////////////////////////
    % START: WAVE PROBE ANALYSIS
    % ---------------------------------------------------------------------
    
    %# X and Y values
    x = timeDataShort;
    y = WaveProbe;
    
    %# Cross-check data for calcuations (see wave probe calibation Excel spread sheet)
    %x = [1.01;1.27;1.85;2.38;2.83;3.13;3.96;4.91];
    %y = [0;0.19;0.58;0.96;1.26;1.47;2.07;2.75];
    
    [results] = curvefit(29,timeDataShort,WaveProbe,1);
    %# Summarise data for cfArray
    i=1;cfArray(i,1) = results(1);cfArray(i,2) = results(2);cfArray(i,3) = results(3);cfArray(i,4) = results(4);cfArray(i,5) = results(5);cfArray(i,6) = results(6);cfArray(i,7) = results(7);cfArray(i,8) = results(8);cfArray(i,9) = results(9);

    [results] = curvefit(29,timeDataShort,KPPort,2);
    %# Summarise data for cfArray
    i=2;cfArray(i,1) = results(1);cfArray(i,2) = results(2);cfArray(i,3) = results(3);cfArray(i,4) = results(4);cfArray(i,5) = results(5);cfArray(i,6) = results(6);cfArray(i,7) = results(7);cfArray(i,8) = results(8);cfArray(i,9) = results(9);
        
    %# TO DO: Added index so that cfArray keep being populated without ----
    %#        specifically mentioning the index!!!!!! ---------------------
    %# TO DO: Automatic disitnction between STBD and PORT in loop!!!!!! ---   
    
    % Sample number
%     samples = length(x);
%     
%     %# Trendline
%     p  = polyfit(x,y,1);
%     p2 = polyval(p,x);
%         
%     % Slope of trendline => Y = (a * X ) + b
%     slope{i} = polyfit(x,y,1);
%     slopeVal = slope{1,2}(1);   % Slope     = a
%     intcpVal = slope{1,2}(2);   % Intercept = b    
%     
%     %# combData array columns:
%         %[1]  xi
%         %[2]  yi        
%         %[3]  xi*yi
%         %[4]  xi^2
%         %[5]  yi^2
%         %[6]  (yi-axi-b)^2
%         
%     combData      = [];
%     
%     %# xi
%     combData(:,1) = x;
%     
%     %# yi
%     combData(:,2) = y;    
% 
%     %# Use common variable
%     A = num2cell(x);
%     B = num2cell(y);    
%     
%     %# xi * yi
%     C = cellfun(@(a,b) b*a, A, B, 'UniformOutput', 0);
%     combData(:,3) = cell2mat(C);
%   
%     %# (xi)^2
%     C = cellfun(@(a) a^2, A, 'UniformOutput', 0);
%     combData(:,4) = cell2mat(C);    
%     
%     %# (yi)^2
%     C = cellfun(@(b) b^2, B, 'UniformOutput', 0);
%     combData(:,5) = cell2mat(C);    
%     
%     %# Sums
%     sumxi       = sum(combData(:,1));
%     sumyi       = sum(combData(:,2));
%     sumxiyi     = sum(combData(:,3));
%     sumxi2      = sum(combData(:,4));
%     sumyi2      = sum(combData(:,5));
%     
%     %# Calculations
%     slope     = ((samples*sumxiyi)-(sumxi)*(sumyi))/((samples*sumxi2)-(sumxi)^2);
%     intercept = ((sumxi2)*(sumyi)-(sumxi)*(sumxiyi))/((samples*sumxi2)-(sumxi)^2);
%     
%     %# (yi - a*xi-b)^2
%     C = cellfun(@(a,b) (b-slope*a-intercept)^2, A, B, 'UniformOutput', 0);
%     combData(:,6) = cell2mat(C);    
%     
%     sumyiaxib2  = sum(combData(:,6));    
%     
%     %# S = square root of the quantity found by dividing the sum of the squares of the deviations from the best fit line
%     S = sqrt(sumyiaxib2/(samples-2));
%     
%     errorSlope     = S*sqrt(samples/((samples*sumxi2)-(sumxi)^2));
%     errorIntercept = S*sqrt(sumxi2/((samples*sumxi2)-(sumxi)^2));
%     
%     relSloperError    = errorSlope/slope;
%     relInterceptError = errorIntercept/intercept;
%     
%     %disp(sprintf('PLOYFIT :: Slope = %s | Intercept = %s (by polyfit function)',num2str(slopeVal),num2str(intcpVal)));
%     disp(sprintf('CURVEFIT:: Slope = %s | Intercept = %s (by curve fitting, regression)',num2str(slope),num2str(intercept)));
%     disp(sprintf('CURVEFIT:: S                        = %s',num2str(S)));
%     disp(sprintf('CURVEFIT:: Error slope              = %s',num2str(errorSlope)));
%     disp(sprintf('CURVEFIT:: Error intercept          = %s',num2str(errorIntercept)));
%     disp(sprintf('CURVEFIT:: Relative slope error     = %s%%',sprintf('%.2f',abs(relSloperError*100))));
%     disp(sprintf('CURVEFIT:: Relative intercept error = %s%%',sprintf('%.2f',abs(relInterceptError*100))));
%     
%     %# Summarise data for cfArray        
%     cfArray(k,1) = k;
%     cfArray(k,2) = slope;
%     cfArray(k,3) = intercept;
%     cfArray(k,4) = S;
%     cfArray(k,5) = errorSlope;
%     cfArray(k,6) = errorIntercept;
%     cfArray(k,7) = relSloperError;
%     cfArray(k,8) = relInterceptError;
%     cfArray(k,9) = 0;
    
    %# --------------------------------------------------------------------
    %# Plotting
    %# --------------------------------------------------------------------
%     figurename = sprintf('Wave probe: Run %s', name(2:3));
%     f = figure('Name',figurename,'NumberTitle','off');
%     
%     h = plot(x,y,'-b',x,p2,'--r');
%     xlabel('{\bf Time [s]}');
%     ylabel('{\bf Mass (Water) [Kg]}');
%     grid on;
%     box on;
%     axis square;
% 
%     %# Line width
%     set(h(1),'linewidth',1);
%     set(h(2),'linewidth',2);
% 
%     %# Axis limitations
%     xlim([x(1) x(end)]);
%     ylim([y(1) y(end)]);
%     
%     %# Legend
%     %hleg1 = legend('Wave probe output','Trendline');
%     %set(hleg1,'Location','SouthEast');
%     %set(hleg1,'Interpreter','none');
%     
%     %# Figure size on screen (50% scaled, but same aspect ratio)
%     set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
% 
%     %# Figure size printed on paper
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');    
    
    % ---------------------------------------------------------------------
    % END: WAVE PROBE ANALYSIS
    % /////////////////////////////////////////////////////////////////////
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);

%# Remove zero rows
%results(all(results==0,2),:)=[];


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
M = cfArray;
csvwrite('cfArray.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('cfArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer