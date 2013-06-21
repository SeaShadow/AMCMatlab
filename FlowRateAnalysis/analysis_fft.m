%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Fast Fourier Transform (FFT)
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  June 20, 2013
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  FFTs of flow rate measurement data. Save figures as PNG.
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  dd/mm/yyyy - ...
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

%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
FS = 800;       % Sampling frequency = 800Hz

%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 29;  % Number of headerlines to data
headerlinesZeroAndCalib = 23;  % Number of headerlines to zero and calibration factors


%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# START FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

startRun = 9;      % Start at run x
endRun   = 9;     % Stop at run y

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# END FILE LOOP FOR RUNS startRun to endRun !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////
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
    
    %# -------------------------------------------------------------------------
    %# Fast Fourier Transform (FFT)
    %# -------------------------------------------------------------------------
    
    %# Create FFT plots and PNG images
    fft_plot(timeData,Raw_CH_0_WaveProbe,1,length(Raw_CH_0_WaveProbe),'FFT_CH0_wave_probe',name);
    fft_plot(timeData,Raw_CH_1_KPStbd,1,length(Raw_CH_1_KPStbd),'FFT_CH1_kp_stbd',name);
    fft_plot(timeData,Raw_CH_2_KPPort,1,length(Raw_CH_2_KPPort),'FFT_CH2_kp_port',name);
    fft_plot(timeData,Raw_CH_3_StaticStbd,1,length(Raw_CH_3_StaticStbd),'FFT_CH3_static_stbd',name);
    fft_plot(timeData,Raw_CH_4_StaticPort,1,length(Raw_CH_4_StaticPort),'FFT_CH4_static_port',name);
    fft_plot(timeData,Raw_CH_5_RPMStbd,1,length(Raw_CH_5_RPMStbd),'FFT_CH5_rpm_stbd',name);
    fft_plot(timeData,Raw_CH_6_RPMPort,1,length(Raw_CH_6_RPMPort),'FFT_CH6_rpm_port',name);
    fft_plot(timeData,Raw_CH_7_ThrustStbd,1,length(Raw_CH_7_ThrustStbd),'FFT_CH7_thrust_stbd',name);
    fft_plot(timeData,Raw_CH_8_ThrustPort,1,length(Raw_CH_8_ThrustPort),'FFT_CH8_thrust_port',name);
    fft_plot(timeData,Raw_CH_9_TorqueStbd,1,length(Raw_CH_9_TorqueStbd),'FFT_CH9_torque_stbd',name);
    fft_plot(timeData,Raw_CH_10_TorquePort,1,length(Raw_CH_10_TorquePort),'FFT_CH10_torque_port',name);
    
    %# -------------------------------------------------------------------------
    %# Fast Fourier Transform (FFT) OLD
    %# -------------------------------------------------------------------------
    
%     figurename = sprintf('Fast Fourier Transform (FFT): %s', name);
%     figure('Name','FFT','NumberTitle','off');    
%     
%     %# FFT settings
%     Fs          = 800;              % Sampling frequency in Hz
%     
%     x           = Raw_CH_2_KPPort;
%     sampleStart = 1; 
%     %sampleEnd   = length(x);
%     sampleEnd   = 16000;
%     t           = timeData(sampleStart:sampleEnd,1);    % Time series
%     x           = x(sampleStart:sampleEnd,1);           % Input Data   
%     
%     m       = length(x);          % Window length
%     n       = pow2(nextpow2(m));  % Transform length
%     y       = fft(x,n);           % DFT
%     f       = (0:n-1)*(Fs/n);     % Frequency range
%     power   = y.*conj(y)/n;       % Power of the DFT     
% 
%     %# RAW data
%     subplot(3,1,1); 
%     plot(t,x);
%     xlabel('Time (s)');
%     ylabel('Output (V)');
%     title('{\bf Raw Data}');
%     xlim([0 round(length(x)/Fs)]);
%     grid on;
%     
%     %# Fast Fourier Transform (FFT)
%     subplot(3,1,2); 
%     plot(f,abs(power));
%     xlabel('Frequency (Hz)');
%     ylabel('|Y(f)|');
%     title('{\bf Fast Fourier Transform (FFT)}');
%     grid on;
% 
%     %# One-Sided Fast Fourier Transform (FFT)
%     [f y] = fft_calc(x,Fs);  
%     subplot(3,1,3);      
%     plot(f,y);
%     xlabel('Frequency (Hz)');
%     ylabel('|Y(f)|');
%     title('{\bf One-Sided Fast Fourier Transform (FFT)}');     
%     grid on;

end