%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Plotting
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  June 17, 2013
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  Plotting results of flow rate measurement analysis.
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
h = plot(kpPort,flowRate,'x');grid on;box on;xlabel('Kiel probe [V]');ylabel('Mass flow rate [Kg/s]');