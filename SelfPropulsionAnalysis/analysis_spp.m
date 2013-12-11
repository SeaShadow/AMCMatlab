%# ------------------------------------------------------------------------
%# Self-Propulsion Test Analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  November 12, 2013
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
%#               then use --> analysis_calib_plot.m
%#
%#               => analysis_rt.m    Flow visualistation and resistance
%#                                    ==> Creates resultsArrayRT.dat
%#
%#               then use --> analysis_rt_plot.m
%#
%#               => analysis_bl.m    Bondary layer measurements
%#                                    ==> Creates resultsArrayBL.dat
%#
%#               then use --> analysis_bl_plot.m
%#
%#               => analysis_spp.m    Self-propulsion points
%#                                    ==> Creates resultsArraySPP.dat
%#
%#               then use --> analysis_spp_plot.m
%#
%#               => analysis_spt.m    Self-propulsion test
%#                                    ==> Creates resultsArraySPT.dat
%#
%#               then use --> analysis_spt_plot.m
%#
%#               => analysis_ts.m    Time series data
%#                                    ==> Creates resultsArrayTS.dat
%#
%#               then use --> analysis_ts_plot.m
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  12/11/2013 - Created new script
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

%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
% testName = 'Resistance Test';
% testName = 'Boundary Layer Investigation';
% testName = 'Waterjet Self-Propulsion Points';
testName = 'Waterjet Self-Propulsion Test';

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

%startRun = 70;      % Start at run x
%endRun   = 70;      % Stop at run y

startRun = 70;       % Start at run x
endRun   = 110;      % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% RunNosTest = [1:8];          % Prelimnary testing only
% RunNosPort = [9:29 59:63];   % Port propulsion system only
% RunNosComb = [30:50 55:58];  % Combined propulsion systems
% RunNosStbd = [64:86];        % Starboard propulsion system only
% RunNosStat = [51:53];        % Static flow rates due to head difference of waterlevels of basin and bucket

% NOTE: If statement bellow is for use in LOOPS only!!!!
%
% if any(RunNosTest==k)
%     disp('TEST');
% elseif any(RunNosPort==k)
%     disp('PORT');
% elseif any(RunNosComb==k)
%     disp('COMBINED');    
% elseif any(RunNosStbd==k)
%     disp('STBD');    
% elseif any(RunNosStat==k)
%     disp('STATIC');    
% else
%     disp('OTHER');        
% end

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END DEFINE PROPULSION SYSTEM DEPENDING ON RUN NUMBERS !!!!!!!!!!!!!!!!!!
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

resultsArraySPP = [];
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
    
    %# RUN directory
%     fPath = sprintf('_plots/%s', name(1:3));
%     if isequal(exist(fPath, 'dir'),7)
%         % Do nothing as directory exists
%     else
%         mkdir(fPath);
%     end
    
    % ---------------------------------------------------------------------
    % END: CREATE PLOTS AND RUN DIRECTORY
    % /////////////////////////////////////////////////////////////////////
    
    %# Columns as variables (RAW DATA)
    timeData             = data(:,1);       % Timeline
    Raw_CH_0_Speed       = data(:,2);       % Speed
    Raw_CH_1_LVDTFwd     = data(:,3);       % Forward LVDT
    Raw_CH_2_LVDTAft     = data(:,4);       % Aft LVDT
    Raw_CH_3_Drag        = data(:,5);       % Load cell (drag)
    Raw_CH_4_PortRPM     = data(:,6);       % Port RPM
    Raw_CH_5_StbdRPM     = data(:,7);       % Starboard RPM
    Raw_CH_6_PortThrust  = data(:,8);       % Port thrust
    Raw_CH_7_PortTorque  = data(:,9);       % Port torque
    Raw_CH_8_StbdThrust  = data(:,10);      % Starboard thrust
    Raw_CH_9_StbdTorque  = data(:,11);      % Starboard torque
    Raw_CH_10_PortKP     = data(:,12);     % Port kiel probe
    Raw_CH_11_StbdKP     = data(:,13);      % Starboard kiel probe  
    
    %# Zeros and calibration factors for each channel
    Time_Zero  = ZeroAndCalib(1);
    Time_CF    = ZeroAndCalib(2);
    CH_0_Zero  = ZeroAndCalib(3);
    CH_0_CF    = ZeroAndCalib(4);
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
    CH_11_Zero = ZeroAndCalib(25);
    CH_11_CF   = ZeroAndCalib(26);
        
    %# --------------------------------------------------------------------
    %# Real units ---------------------------------------------------------
    %# --------------------------------------------------------------------
    
    [CH_0_Speed CH_0_Speed_Mean]           = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
    [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]       = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
    [CH_2_LVDTAft CH_2_LVDTAft_Mean]       = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
    [CH_3_Drag CH_3_Drag_Mean]             = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
    
    [RPMStbd RPMPort]                      = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);
    
    [CH_6_PortThrust CH_6_PortThrust_Mean] = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
    [CH_7_PortTorque CH_7_PortTorque_Mean] = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
    [CH_8_StbdThrust CH_8_StbdThrust_Mean] = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
    [CH_9_StbdTorque CH_9_StbdTorque_Mean] = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);    
   
    % /////////////////////////////////////////////////////////////////////
    % DISPLAY RESULTS
    % /////////////////////////////////////////////////////////////////////
    
    %# Add results to dedicated array for simple export
    %# Results array columns: 
        %[1]  Run No.
        %[2]  FS                (Hz)
        %[3]  No. of samples    (-)
        %[4]  Record time       (s)
        %[5]  Speed             (m/s)
        %[6]  Forward LVDT      (mm)
        %[7]  Aft LVDT          (mm)
        %[8]  Drag              (g)
        %[9]  Shaft Speed PORT  (RPM)
        %[10] Shaft Speed STBD  (RPM)
        %[11] Thrust PORT       (N)
        %[12] Torque PORT       (Nm)
        %[13] Thrust STBD       (N)
        %[14] Torque STBD       (Nm)        
        %[15] Kiel probe PORT   (V)
        %[16] Kiel probe STBD   (V)   
        
    % General data
    resultsArraySPP(k, 1)  = k;                                                     % Run No.
    resultsArraySPP(k, 2)  = round(length(timeData) / timeData(end));               % FS (Hz)    
    resultsArraySPP(k, 3)  = length(timeData);                                      % Number of samples
    recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
    resultsArraySPP(k, 4)  = round(recordTime);                                     % Record time in seconds
    
    % Resistance data
    resultsArraySPP(k, 5)  = CH_0_Speed_Mean;                                       % Speed (m/s)
    resultsArraySPP(k, 6)  = CH_1_LVDTFwd_Mean;                                     % Forward LVDT (mm)
    resultsArraySPP(k, 7)  = CH_2_LVDTAft_Mean;                                     % Aft LVDT (mm)
    resultsArraySPP(k, 8)  = CH_3_Drag_Mean;                                        % Drag (g)

    % RPM data
    resultsArraySPP(k, 9)  = RPMPort;                                               % Shaft Speed PORT (RPM)
    resultsArraySPP(k, 10) = RPMStbd;                                               % Shaft Speed STBD (RPM)

    % Thrust and torque data
    resultsArraySPP(k, 11) = abs(CH_6_PortThrust_Mean/1000)*9.806;                  % Thrust PORT (N)
    resultsArraySPP(k, 12) = CH_7_PortTorque_Mean;                                  % Torque PORT (Nm)
    resultsArraySPP(k, 13) = abs(CH_8_StbdThrust_Mean/1000)*9.806;                  % Thrust STBD (N)
    resultsArraySPP(k, 14) = CH_9_StbdTorque_Mean;                                  % Torque STBD (Nm)  
    
    % Kie; probe data
    resultsArraySPP(k, 15)  = mean(Raw_CH_10_PortKP);                                % Kiel probe PORT (V)
    resultsArraySPP(k, 16)  = mean(Raw_CH_11_StbdKP);                               % Kiel probe STBD (V)    
    
    %# Prepare strings for display ----------------------------------------
    
    % Change from 2 to 3 digits
    if k > 99
        name = name(1:4);
    else
        name = name(1:3);
    end

%     massflowrate     = sprintf('%s:: Mass flow rate: %s [Kg/s]', name, sprintf('%.2f',abs(flowrate)));
%     kielprobestbd    = sprintf('%s:: Kiel probe STBD (mean): %s [V]', name, sprintf('%.2f',mean(Raw_CH_1_KPStbd)));
%     kielprobeport    = sprintf('%s:: Kiel probe PORT (mean): %s [V]', name, sprintf('%.2f',mean(Raw_CH_2_KPPort)));
%     thruststbd       = sprintf('%s:: Thrust STBD (mean): %s [N]', name, sprintf('%.2f',abs(((CH_7_ThrustStbd_Mean/1000)*9.806))));
%     thrustport       = sprintf('%s:: Thrust PORT (mean): %s [N]', name, sprintf('%.2f',abs(((CH_8_ThrustPort_Mean/1000)*9.806))));
%     torquestbd       = sprintf('%s:: Torque STBD (mean): %s [Nm]', name, sprintf('%.2f',abs(CH_9_TorqueStbd_Mean)));
%     torqueport       = sprintf('%s:: Torque PORT (mean): %s [Nm]', name, sprintf('%.2f',abs(CH_10_TorquePort_Mean)));

    shaftrpmport     = sprintf('%s:: Shaft speed PORT: %s [RPM]', name, sprintf('%.0f',RPMPort));  
    shaftrpmstbd     = sprintf('%s:: Shaft speed STBD: %s [RPM]', name, sprintf('%.0f',RPMStbd));

     %# Display strings ---------------------------------------------------
     
%     disp(kielprobestbd);
%     disp(kielprobeport);
%     %disp('-------------------------------------------------');  
%     disp(thruststbd);
%     disp(thrustport);
%     %disp('-------------------------------------------------');  
%     disp(torquestbd);
%     disp(torqueport);        

    disp(shaftrpmport);
    disp(shaftrpmstbd);

    disp('/////////////////////////////////////////////////');
    
    %wtot = endRun - startRun;
    %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
%close(w);


% /////////////////////////////////////////////////////////////////////
% START: Write results to CVS
% ---------------------------------------------------------------------
M = resultsArraySPP;
csvwrite('resultsArraySPP.dat', M)                                     % Export matrix M to a file delimited by the comma character      
dlmwrite('resultsArraySPP.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
% ---------------------------------------------------------------------
% END: Write results to CVS
% /////////////////////////////////////////////////////////////////////


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
%profile viewer