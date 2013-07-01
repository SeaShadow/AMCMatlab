%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Simple statistics
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  July 1, 2013
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  Simple statistics on results.
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

%# -------------------------------------------------------------------------
%# Read DAT file
%# -------------------------------------------------------------------------
if exist('resultsArray_copy.dat', 'file') == 2
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
    results = csvread('resultsArray_copy.dat');
    
    %# Remove zero rows
    results(all(results==0,2),:)=[];
else
    disp('---------------------------------------------------------------------------------------');
    disp('File resultsArray_copy.dat does not exist!');
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

%# Results array columns: 
    %[1]  Set motor RPM      (RPM)
    %[2]  Prop. system       >> 1 = Port, 2 = Stbd, 3 = Combined
    %[3]  Shaft Speed STBD   (RPM)
    %[4]  Shaft Speed PORT   (RPM)
    %[5]  Flow rate          (Kg/s)
    %[6]  Kiel probe STBD    (V)
    %[7]  Kiel probe PORT    (V)
    %[8]  Thrust STBD        (N)
    %[9]  Thrust PORT        (N)
    %[10] Torque STBD        (Nm)
    %[11] Torque PORT        (Nm)
    %[12] Power STBD         (W)
    %[13] Power PORT         (W)

averagedArray = [];
% Port Side
setRPM=500; startRun=9; endRun=11; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(1,:) = ans;
setRPM=750; startRun=59;endRun=59; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(2,:) = ans;
setRPM=1000;startRun=12;endRun=14; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(3,:) = ans;
setRPM=1250;startRun=60;endRun=60; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(4,:) = ans;
setRPM=1500;startRun=15;endRun=17; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(5,:) = ans;
setRPM=1750;startRun=61;endRun=61; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(6,:) = ans;
setRPM=2000;startRun=18;endRun=20; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(7,:) = ans;
setRPM=2250;startRun=62;endRun=62; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(8,:) = ans;
setRPM=2500;startRun=21;endRun=23; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(9,:) = ans;
setRPM=2750;startRun=63;endRun=63; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(10,:) = ans;
setRPM=3000;startRun=24;endRun=29; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(11,:) = ans;

% Port Side
setRPM=500; startRun=64;endRun=66; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(12,:) = ans;
setRPM=750; startRun=67;endRun=67; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(13,:) = ans;
setRPM=1000;startRun=68;endRun=70; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(14,:) = ans;
setRPM=1250;startRun=71;endRun=71; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(15,:) = ans;
setRPM=1500;startRun=72;endRun=74; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(16,:) = ans;
setRPM=1750;startRun=75;endRun=75; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(17,:) = ans;
setRPM=2000;startRun=76;endRun=78; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(18,:) = ans;
setRPM=2250;startRun=79;endRun=79; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(19,:) = ans;
setRPM=2500;startRun=80;endRun=82; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(20,:) = ans;
setRPM=2750;startRun=83;endRun=83; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(21,:) = ans;
setRPM=3000;startRun=84;endRun=86; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(22,:) = ans;

% Combined
setRPM=500; startRun=30;endRun=32; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(23,:) = ans;
setRPM=750; startRun=54;endRun=54; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(24,:) = ans;
setRPM=1000;startRun=33;endRun=35; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(25,:) = ans;
setRPM=1250;startRun=55;endRun=55; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(26,:) = ans;
setRPM=1500;startRun=36;endRun=38; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(27,:) = ans;
setRPM=1750;startRun=56;endRun=56; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(28,:) = ans;
setRPM=2000;startRun=39;endRun=41; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(29,:) = ans;
setRPM=2250;startRun=57;endRun=57; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(30,:) = ans;
setRPM=2500;startRun=42;endRun=44; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(31,:) = ans;
setRPM=2750;startRun=58;endRun=58; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(32,:) = ans;
setRPM=3000;startRun=45;endRun=50; [ans] = stats_avg(1,setRPM,startRun,endRun,results); averagedArray(33,:) = ans;

%# Plot data
figurename = sprintf('%s', 'Wave probe');
f = figure('Name',figurename,'NumberTitle','off');

%# SEPARATE SYSTEMS: RPM vs. flow rate ------------------------------------
subplot(2,3,1);

xport = averagedArray(1:11,7);
yport = averagedArray(1:11,5);
xstbd = averagedArray(12:22,6);
ystbd = averagedArray(12:22,5);

plot(xstbd,ystbd,'x',xport,yport,'o','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Differential pressure transducer output [V]}');
ylabel('{\bf Flow rate [Kg/s]}');
%title('{\bf Separate waterjet systems}');
xlim([0.9 3.1]);
grid on;
% axis square;

hleg1 = legend('S:Starboard waterjet','S:Port waterjet');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# COMBINED & SEPARATE SYSTEMS: RPM vs. DPT output ------------------------
subplot(2,3,2);

xport     = averagedArray(1:11,4);
yport     = averagedArray(1:11,7);

xstbd     = averagedArray(12:22,3);
ystbd     = averagedArray(12:22,6);

xcombport = averagedArray(23:33,4);
ycombport = averagedArray(23:33,7);

xcombstbd = averagedArray(23:33,3);
ycombstbd = averagedArray(23:33,6);

plot(xstbd,ystbd,'x',xport,yport,'o',xcombstbd,ycombstbd,'+',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Measured shaft speed [RPM]}');
ylabel('{\bf Differential pressure transducer output [V]}');
%title('{\bf Combined and separate waterjet systems}');
xlim([480 2800]);
ylim([1 3.1]);
grid on;
% axis square;

hleg1 = legend('S:Starboard waterjet','S:Port waterjet','C:Starboard waterjet','C:Port waterjet');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# COMBINED & SEPARATE SYSTEMS: RPM vs. Torque ----------------------------
subplot(2,3,3);

xport     = averagedArray(1:11,4);
yport     = averagedArray(1:11,11);

xstbd     = averagedArray(12:22,3);
ystbd     = averagedArray(12:22,10);

xcombport = averagedArray(23:33,4);
ycombport = averagedArray(23:33,11);

xcombstbd = averagedArray(23:33,3);
ycombstbd = averagedArray(23:33,10);

plot(xstbd,ystbd,'x',xport,yport,'o',xcombstbd,ycombstbd,'+',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Measured shaft speed [RPM]}');
ylabel('{\bf Torque [Nm]}');
%title('{\bf Combined and separate waterjet systems}');
xlim([480 2800]);
ylim([0 0.4]);
grid on;
% axis square;

hleg1 = legend('S:Starboard waterjet','S:Port waterjet','C:Starboard waterjet','C:Port waterjet');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# COMBINED & SEPARATE SYSTEMS: Set RPM vs. Measured RPM ------------------
subplot(2,3,4);

xport     = averagedArray(1:11,1);
yport     = averagedArray(1:11,4);

xstbd     = averagedArray(12:22,1);
ystbd     = averagedArray(12:22,3);

xcombport = averagedArray(23:33,1);
ycombport = averagedArray(23:33,4);

xcombstbd = averagedArray(23:33,1);
ycombstbd = averagedArray(23:33,3);

plot(xstbd,ystbd,'x',xport,yport,'o',xcombstbd,ycombstbd,'+',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Set shaft speed [RPM]}');
ylabel('{\bf Measured shaft speed [RPM]}');
%title('{\bf Combined and separate waterjet systems}');
xlim([500 3000]);
ylim([480 2800]);
grid on;
% axis square;

hleg1 = legend('S:Starboard waterjet','S:Port waterjet','C:Starboard waterjet','C:Port waterjet');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# COMBINED & SEPARATE SYSTEMS: RPM vs. Thrust ------------------
subplot(2,3,5);

xport     = averagedArray(1:11,4);
yport     = averagedArray(1:11,9);

xstbd     = averagedArray(12:22,3);
ystbd     = averagedArray(12:22,8);

xcombport = averagedArray(23:33,4);
ycombport = averagedArray(23:33,9);

xcombstbd = averagedArray(23:33,3);
ycombstbd = averagedArray(23:33,8);

plot(xstbd,ystbd,'x',xport,yport,'o',xcombstbd,ycombstbd,'+',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Measured shaft speed [RPM]}');
ylabel('{\bf Thrust [N]}');
%title('{\bf Combined and separate waterjet systems}');
xlim([480 2800]);
ylim([0 35]);
grid on;
% axis square;

hleg1 = legend('S:Starboard waterjet','S:Port waterjet','C:Starboard waterjet','C:Port waterjet');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# COMBINED & SEPARATE SYSTEMS: RPM vs. Power ------------------
subplot(2,3,6);

xport     = averagedArray(1:11,4);
yport     = averagedArray(1:11,13);

xstbd     = averagedArray(12:22,3);
ystbd     = averagedArray(12:22,12);

xcombport = averagedArray(23:33,4);
ycombport = averagedArray(23:33,13);

xcombstbd = averagedArray(23:33,3);
ycombstbd = averagedArray(23:33,12);

plot(xstbd,ystbd,'x',xport,yport,'o',xcombstbd,ycombstbd,'+',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Measured shaft speed [RPM]}');
ylabel('{\bf Shaft power [W]}');
%title('{\bf Combined and separate waterjet systems}');
xlim([480 2800]);
ylim([0 112]);
grid on;
% axis square;

hleg1 = legend('S:Starboard waterjet','S:Port waterjet','C:Starboard waterjet','C:Port waterjet');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');

%# ------------------------------------------------------------------------
%# Save plots as PNGs -----------------------------------------------------
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end

%# Repeat directory
fPath = sprintf('_plots/%s', '_averaged_summary');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end

%# Repeat directory
fPath = sprintf('_plots/%s/%s', '_averaged_summary', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end

plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Stbd_and_port_data_10s_off_start_and_end');
saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Stbd_and_port_data_10s_off_start_and_end'); % Assign save name
print(gcf, '-djpeg', plotsavename);                                                                             % Save plot as PNG
%close; 