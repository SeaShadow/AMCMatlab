%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Plotting
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 8, 2014
%#
%# Test date  :  September 1-4, 2014
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-67
%# Speeds     :  800-3,400 RPM
%#
%# Description:  Repeated flow rate measurement test for validation and
%#               uncertainty analysis reasons.
%#
%# -------------------------------------------------------------------------
%#
%# CHANGES    :  08/09/2014 - File creation
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

%# -------------------------------------------------------------------------
%# Read DAT file
%# -------------------------------------------------------------------------
if exist('resultsArray.dat', 'file') == 2
    %# Results array columns: 
        %[1]  Run No.
        %[2]  FS                (Hz)
        %[3]  No. of samples    (-)
        %[4]  Record time       (s)
        %[5]  Flow rate         (Kg/s)
        %[6]  Kiel probe STBD   (V)
        %[7]  Kiel probe PORT   (V)
        %[8]  Thrust STBD       (N)
        %[9]  Thrust PORT       (N)
        %[10] Torque STBD       (Nm)
        %[11] Torque PORT       (Nm)
        %[12] Shaft Speed STBD  (RPM)
        %[13] Shaft Speed PORT  (RPM)
        %[14] Power STBD        (W)
        %[15] Power PORT        (W)
    results = csvread('resultsArray.dat');
    
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('---------------------------------------------------------------------------------------');
    disp('File resultsArray.dat does not exist!');
    disp('---------------------------------------------------------------------------------------');
    break;
end

%# -------------------------------------------------------------------------
%# Set column variables
%# -------------------------------------------------------------------------
runNo       = results(:,1);
sampleFreq  = results(:,2);
samplesNo   = results(:,3);
recordTime  = results(:,4);
flowRate    = results(:,5);
kpStbd      = results(:,6);
kpPort      = results(:,7);
thrustStbd  = results(:,8);
thrustPort  = results(:,9);
torqueStbd  = results(:,10);
torquePort  = results(:,11);
speedStbd   = results(:,12);
speedPort   = results(:,13);
powerStbd   = results(:,14);
powerPort   = results(:,15);

%# -------------------------------------------------------------------------
%# Plotting
%# -------------------------------------------------------------------------
figurename = sprintf('Plotting: %s', 'Kiel probe voltage vs. mass flow rate');
f = figure('Name',figurename,'NumberTitle','off');

h = plot(kpPort,flowRate,'x');
grid on;
box on;
xlabel('{\bf Kiel probe [V]}');
ylabel('{\bf Mass flow rate [Kg/s]}');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);
