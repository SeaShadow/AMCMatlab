%# ------------------------------------------------------------------------
%# Flow Rate Analysis: Simple statistics
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  November 18, 2014
%#
%# Test date  :  June 5-14, 2013
%# Facility   :  AMC, Model Test Basin (MTB)
%# Runs       :  1-86
%# Speeds     :  500-3,000 RPM
%#
%# Description:  Simple statistics on results.
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  01/07/2013 - Created new script
%#               23/10/2013 - Streamlined code added trigger for BM plots
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
% START: PLOT SWITCHES: 1 = ENABLED 
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableBenchmarkCompPlots = 0; % Show comparisons with benchmark data
enableDetailPlots        = 0; % Enable detail plots of port, stbd and both WJ (6 graphs on one plot)

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************  


%# -------------------------------------------------------------------------
%# Read results DAT file
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

%# ------------------------------------------------------------------------
%# Create directories if not available ------------------------------------
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

%# PDF directory
fPath = sprintf('_plots/%s/%s', '_averaged_summary', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
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

%# averagedArray columns, for referencing purposes: 
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
    %[14] Flow coefficient   (-)
    %[15] Flow rate          (m3/s)
    %[16] Jet velocity       (m/s)
    %[17] Gross thrust       (m3/s)     >> Using Allisons equation
    %[18] Thrust coefficient (-)        >> Baseed on gross thrust
    
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

% Starboard Side
setRPM=500; startRun=64;endRun=66; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(12,:) = ans;
setRPM=750; startRun=67;endRun=67; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(13,:) = ans;
setRPM=1000;startRun=68;endRun=70; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(14,:) = ans;
setRPM=1250;startRun=71;endRun=71; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(15,:) = ans;
setRPM=1500;startRun=72;endRun=74; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(16,:) = ans;
setRPM=1750;startRun=75;endRun=75; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(17,:) = ans;
setRPM=2000;startRun=76;endRun=78; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(18,:) = ans;
setRPM=2250;startRun=79;endRun=79; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(19,:) = ans;
setRPM=2500;startRun=80;endRun=82; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(20,:) = ans;
setRPM=2750;startRun=83;endRun=83; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(21,:) = ans;
setRPM=3000;startRun=84;endRun=86; [ans] = stats_avg(2,setRPM,startRun,endRun,results); averagedArray(22,:) = ans;

% Combined
setRPM=500; startRun=30;endRun=32; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(23,:) = ans;
setRPM=750; startRun=54;endRun=54; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(24,:) = ans;
setRPM=1000;startRun=33;endRun=35; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(25,:) = ans;
setRPM=1250;startRun=55;endRun=55; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(26,:) = ans;
setRPM=1500;startRun=36;endRun=38; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(27,:) = ans;
setRPM=1750;startRun=56;endRun=56; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(28,:) = ans;
setRPM=2000;startRun=39;endRun=41; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(29,:) = ans;
setRPM=2250;startRun=57;endRun=57; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(30,:) = ans;
setRPM=2500;startRun=42;endRun=44; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(31,:) = ans;
setRPM=2750;startRun=58;endRun=58; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(32,:) = ans;
setRPM=3000;startRun=45;endRun=50; [ans] = stats_avg(3,setRPM,startRun,endRun,results); averagedArray(33,:) = ans;


%# ************************************************************************
%# PLOT DPT vs. FLOW RATE *************************************************
%# ************************************************************************

figurename = sprintf('%s', 'Kiel Probe Output vs. Mass Flow Rate for PORT and STARBOARD Data');
f = figure('Name',figurename,'NumberTitle','off');

%# SEPARATE SYSTEMS: RPM vs. flow rate ------------------------------------
%subplot(1,2,1);

xport = averagedArray(1:11,7);
yport = averagedArray(1:11,5);

xstbd = averagedArray(12:22,6);
ystbd = averagedArray(12:22,5);

%# Averaged stbd and port data
xArray = [];  xArray(:,1) = xport;  xArray(:,2) = xstbd;
yArray = [];  yArray(:,1) = yport;  yArray(:,2) = ystbd;

avgX = mean(xArray(:,1:2).');  avgX = avgX.';
avgY = mean(yArray(:,1:2).');  avgY = avgY.';

plot(xstbd,ystbd,'x',xport,yport,'o',avgX,avgY,'-k','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Differential pressure transducer output [V]}');
ylabel('{\bf Flow rate [Kg/s]}');
%title('{\bf Separate runs for STBD and PORT waterjet system}');
xlim([0.9 3.1]);
grid on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
set(gca,'XLim',[1 3.1]);
set(gca,'XTick',[1:0.1:3.1]);
set(gca,'YLim',[0.5 4.5]);
set(gca,'YTick',[0.5:0.1:4.5]);

hleg1 = legend('S:Starboard waterjet','S:Port waterjet','Averaged Port and Stbd');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
legend boxoff;

%# ------------------------------------------------------------------------
%# Save plots as PNGs -----------------------------------------------------
%# ------------------------------------------------------------------------

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

%# Save figure as PDF and PNG
plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Voltage_vs_Flow_Rate');
saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Voltage_vs_Flow_Rate'); % Assign save name
print(gcf, '-djpeg', plotsavename);                                                         % Save plot as PNG
%close; 

%# TOTAL FLOW RATE COMPARISON /////////////////////////////////////////////

figurename = sprintf('%s', 'Kiel Probe Output vs. Total Mass Flow Rate');
f = figure('Name',figurename,'NumberTitle','off');

%subplot(1,2,2);

% xport = averagedArray(1:11,7);
yport = averagedArray(1:11,5);
% 
% xstbd = averagedArray(12:22,6);
ystbd = averagedArray(12:22,5);

%# Averaged stbd and port data
xAvgSepKPArray = [];  xAvgSepKPArray(:,1) = averagedArray(12:22,6);  xAvgSepKPArray(:,2) = averagedArray(1:11,7);
xAvgComKPArray = [];  xAvgComKPArray(:,1) = averagedArray(23:33,6);  xAvgComKPArray(:,2) = averagedArray(23:33,7);

avgXSep = mean(xAvgSepKPArray(:,1:2).');  avgXSep = avgXSep.';
avgXCom = mean(xAvgComKPArray(:,1:2).');  avgXCom = avgXCom.';

addUp = [];
for i=1:length(yport)
    addUp(i, 1) = yport(i) + ystbd(i); 
end
ySep = addUp;
yCom = averagedArray(23:33,5);

plot(avgXSep,ySep,'+r',avgXCom,yCom,'sk','LineWidth',2,'MarkerSize',10);
xlabel('{\bf Averaged differential pressure transducer output [V]}');
ylabel('{\bf Total flow rate [Kg/s]}');
%title('{\bf Total mass flow rate vs. averaged voltage}');
xlim([0.9 3.1]);
grid on;
axis square;

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
set(gca,'XLim',[1 3.1]);
set(gca,'XTick',[1:0.1:3.1]);
set(gca,'YLim',[1 9]);
set(gca,'YTick',[1:0.5:9]);

hleg1 = legend('Waterjets run reparately','Waterjets run together');
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');
legend boxoff;

%# ------------------------------------------------------------------------
%# Save plots as PNGs -----------------------------------------------------
%# ------------------------------------------------------------------------

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

%# Save figure as PDF and PNG
plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Voltage_vs_Total_Flow_Rate');
saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Voltage_vs_Total_Flow_Rate');   % Assign save name
print(gcf, '-djpeg', plotsavename);                                                                 % Save plot as PNG
%close; 


%# -------------------------------------------------------------------------
%# DISPLAY: Differences between STBD and PORT measurements for FRs and DPTs
%# -------------------------------------------------------------------------

diffAvg = [];
for i=1:length(yport)
    diffAvg(i, 1) = abs(1-(ySep(i)/yCom(i)));
    diffAvg(i, 2) = abs(1-(avgXSep(i)/avgXCom(i)));
    diffFr = sprintf('%.1f',diffAvg(i,1) * 100);
    diffVo = sprintf('%.1f',diffAvg(i,2) * 100);
    displayText = sprintf('RPM:: %s:: Differences in total flow rates = %s%% and averaged DPT voltages = %s%%',num2str(averagedArray(i,1)),diffFr,diffVo);
    disp(displayText);
end

%# -------------------------------------------------------------------------
%# Read benchmark data and plot shaft speed vs. flow rate
%# -------------------------------------------------------------------------
if exist('wj_benchmark_data.csv', 'file') == 2
    %# Results array columns: 
        %[1]  Shaft Speed       (RPM)
        %[2]  Prop. eff = 0.855
        %[3]  Prop. eff = 0.8725
        %[4]  Prop. eff = 0.888
        %[5]  Prop. eff = 0.892
        %[6]  Prop. eff = 0.894
        %[7]  Prop. eff = 0.881
        %[8]  Prop. eff = 0.855
        %[9]  Prop. eff = 0.825
        %[10] Prop. eff = 0.65    
    resultsBMData = csvread('wj_benchmark_data.csv');
    
    rpmval = resultsBMData(2:9,1);
    eff1   = resultsBMData(2:9,2);
    eff2   = resultsBMData(2:9,3);
    eff3   = resultsBMData(2:9,4);    
    eff4   = resultsBMData(2:9,5);
    eff5   = resultsBMData(2:9,6);
    eff6   = resultsBMData(2:9,7);
    eff7   = resultsBMData(2:9,8);
    eff8   = resultsBMData(2:9,9);
    eff9   = resultsBMData(2:9,10);
    
    if enableBenchmarkCompPlots == 1
    
        %# Plot benchmark data
        figurename = sprintf('%s', 'Plot: Wartsila waterjet benchmark data vs. flow rate test data');
        f = figure('Name',figurename,'NumberTitle','off');

        xport = averagedArray(1:11,4);
        yport = averagedArray(1:11,5);

        xstbd = averagedArray(12:22,3);
        ystbd = averagedArray(12:22,5);

        %# Averaged stbd and port data
        xArray = [];  xArray(:,1) = xport;  xArray(:,2) = xstbd;
        yArray = [];  yArray(:,1) = yport;  yArray(:,2) = ystbd;

        avgX = mean(xArray(:,1:2).');  avgX = avgX.';
        avgY = mean(yArray(:,1:2).');  avgY = avgY.';    

        plot(rpmval,eff1,'x',rpmval,eff2,'o',rpmval,eff3,'*',rpmval,eff4,'v',rpmval,eff5,'<','LineWidth',1,'MarkerSize',10);
        hold on;
        plot(rpmval,eff6,'s',rpmval,eff7,'d',rpmval,eff8,'^',rpmval,eff9,'>','LineWidth',1,'MarkerSize',10);
        hold on;
        plot(xstbd,ystbd,'ok',xport,yport,'xk','LineWidth',2,'MarkerSize',10);  % ,'MarkerEdgeColor','k','MarkerFaceColor',[.49 1 .63]
        %hold on;
        %plot(avgX,avgY,'-k','LineWidth',2,'MarkerSize',10);    
        xlabel('{\bf Shaft speed [RPM]}');
        ylabel('{\bf Mass flow rate [Kg/s]}');
        %title('{\bf Wartsila waterjet benchmark data vs. measured flow rate test data}');
        title({'{\bf Wartsila waterjet benchmark data vs. mass flow rate}';'{\bf at different propulsive efficiencies ranging from 0.65 to 0.894}'});
        xlim([500 3000]);
        set(gca, 'XTick',[500:500:3000]);   % X-axis increments: start:increment:end
        set(gca, 'YTick',[0:1:12]);         % Y-axis increments: start:increment:end
        grid on;
        axis square;

        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);    

        hleg1 = legend('Benchmark:0.855','Benchmark:0.8725','Benchmark:0.888','Benchmark:0.892','Benchmark:0.894','Benchmark:0.881','Benchmark:0.855','Benchmark:0.825','Benchmark:0.65','Test:Starboard waterjet','Test:Port waterjet'); % ,'Test:Averaged'
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');

        %# ------------------------------------------------------------------------
        %# Save plots as PNGs -----------------------------------------------------
        %# ------------------------------------------------------------------------

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

        %# Save figure as PDF and PNG
        plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Benchmark_data_vs_measured_flow_rates');
        saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Benchmark_data_vs_measured_flow_rates'); % Assign save name
        print(gcf, '-djpeg', plotsavename);                                                                          % Save plot as PNG
        %close;     
    
    end
    
else
    disp('---------------------------------------------------------------------------------------');
    disp('File wj_benchmark_data.csv does not exist!');
    disp('---------------------------------------------------------------------------------------');
    break;
end

%# -------------------------------------------------------------------------
%# Read benchmark data and plot shaft speed vs. flow rate at different propulsive efficiencies
%# -------------------------------------------------------------------------
if exist('wj_benchmark_data_rpm_vs_np.csv', 'file') == 2
    %# Results array columns: 
        %[1]  Shaft Speed           (RPM)
        %[2]  Mass flow rate        (Kg/s)
        %[3]  Propulsive efficiency (-)

    resultsBMData = csvread('wj_benchmark_data_rpm_vs_np.csv');
    
    rpm500  = resultsBMData(1:9,1);    fr500   = resultsBMData(1:9,2);
    rpm1000 = resultsBMData(10:18,1);  fr1000  = resultsBMData(10:18,2);
    rpm1500 = resultsBMData(19:27,1);  fr1500  = resultsBMData(19:27,2);
    rpm2000 = resultsBMData(28:36,1);  fr2000  = resultsBMData(28:36,2);
    rpm2500 = resultsBMData(37:45,1);  fr2500  = resultsBMData(37:45,2);
    rpm3000 = resultsBMData(46:54,1);  fr3000  = resultsBMData(46:54,2);
    rpm3500 = resultsBMData(55:63,1);  fr3500  = resultsBMData(55:63,2);
    rpm4000 = resultsBMData(64:72,1);  fr4000  = resultsBMData(64:72,2);
    
    if enableBenchmarkCompPlots == 1
    
        %# Plot benchmark data
        figurename = sprintf('%s', 'Plot: Wartsila waterjet benchmark data vs. mass flow rate');
        f = figure('Name',figurename,'NumberTitle','off');    

        xport = averagedArray(1:11,4);
        yport = averagedArray(1:11,5);

        xstbd = averagedArray(12:22,3);
        ystbd = averagedArray(12:22,5);

        %# Averaged stbd and port data
        xArray = [];  xArray(:,1) = xport;  xArray(:,2) = xstbd;
        yArray = [];  yArray(:,1) = yport;  yArray(:,2) = ystbd;

        avgX = mean(xArray(:,1:2).');  avgX = avgX.';
        avgY = mean(yArray(:,1:2).');  avgY = avgY.';

        plot(rpm500,fr500,'x',rpm1000,fr1000,'o',rpm1500,fr1500,'*',rpm2000,fr2000,'v',rpm2500,fr2500,'<','LineWidth',1,'MarkerSize',10);
        hold on;
        plot(rpm3000,fr3000,'s','LineWidth',1,'MarkerSize',10);
        hold on;
        plot(xstbd,ystbd,'ok',xport,yport,'xk','LineWidth',2,'MarkerSize',10);  % ,'MarkerEdgeColor','k','MarkerFaceColor',[.49 1 .63]
        %hold on;
        %plot(avgX,avgY,'-k','LineWidth',2,'MarkerSize',10);
        xlabel('{\bf Shaft speed [RPM]}');
        ylabel('{\bf Mass flow rate [Kg/s]}');
        %title('{\bf Wartsila waterjet benchmark data vs. mass flow rate at different propulsive efficiencies}');
        title({'{\bf Wartsila waterjet benchmark data vs. mass flow rate}';'{\bf at different propulsive efficiencies ranging from 0.65 to 0.894}'});
        xlim([500 3000]);
        set(gca, 'XTick',[500:500:3000]);   % X-axis increments: start:increment:end
        set(gca, 'YTick',[0:1:12]);         % Y-axis increments: start:increment:end
        grid on;
        axis square;

        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);    

        hleg1 = legend('Benchmark:500 RPM','Benchmark:1,000 RPM','Benchmark:1,500 RPM','Benchmark:2,000 RPM','Benchmark:2,500 RPM','Benchmark:3,000 RPM','Test:Starboard waterjet','Test:Port waterjet'); % ,'Test:Averaged'
        set(hleg1,'Location','NorthWest');
        set(hleg1,'Interpreter','none');    
        legend boxoff;
        
        %# ------------------------------------------------------------------------
        %# Save plots as PNGs -----------------------------------------------------
        %# ------------------------------------------------------------------------

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

        %# Save figure as PDF and PNG
        plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Benchmark_data_vs_measured_flow_rates_diff_np');
        saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
        plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Benchmark_data_vs_measured_flow_rates_diff_np'); % Assign save name
        print(gcf, '-djpeg', plotsavename);                                                                                  % Save plot as PNG
        %close;    
    
    end
    
else
    disp('---------------------------------------------------------------------------------------');
    disp('File wj_benchmark_data_rpm_vs_np.csv does not exist!');
    disp('---------------------------------------------------------------------------------------');
    break;
end

%# -------------------------------------------------------------------------
%# PLOT FLOW COEFFICIENT VS. VOLUME FLOW RATE STBD AND PORT (separate wj systems)
%# -------------------------------------------------------------------------

enableFCPlot = 2;   % Enable flow coefficient plot. 1 = ON and 2 = OFF

if enableFCPlot == 1
    
    %# Plot benchmark data
    figurename = sprintf('%s', 'Plot: Flow coefficient vs. volume flow rate');
    f = figure('Name',figurename,'NumberTitle','off');

    xport = averagedArray(1:11,14);
    yport = averagedArray(1:11,15);

    xstbd = averagedArray(12:22,14);
    ystbd = averagedArray(12:22,15);

    plot(xstbd,ystbd,'x',xport,yport,'o','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Flow coefficient [-]}');
    ylabel('{\bf Volume flow rate [m^3/s]}');
    title('{\bf Flow coefficient vs. volume flow rate}');
    xlim([0 1]);
    grid on;
    axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);    
    
    hleg1 = legend('S:Starboard waterjet','S:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;
    
    %# ------------------------------------------------------------------------
    %# Save plots as PNGs -----------------------------------------------------
    %# ------------------------------------------------------------------------

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
    
    %# Save figure as PDF and PNG
    plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Flow_coefficient_vs_volume_flow_rate');
    saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Flow_coefficient_vs_volume_flow_rate'); % Assign save name
    print(gcf, '-djpeg', plotsavename);                                                                         % Save plot as PNG
    %close; 

end


if enableDetailPlots == 1

    %# ************************************************************************
    %# PLOT ALL DATA **********************************************************
    %# ************************************************************************

    figurename = sprintf('%s', 'Both Waterjets and Port and Starboard Waterjet Data Only');
    f = figure('Name',figurename,'NumberTitle','off');

    %# SEPARATE SYSTEMS: RPM vs. flow rate ------------------------------------
    subplot(2,3,1);

    xport = averagedArray(1:11,7);
    yport = averagedArray(1:11,9);

    xstbd = averagedArray(12:22,6);
    ystbd = averagedArray(12:22,8);

    xcombport = averagedArray(23:33,7);
    ycombport = averagedArray(23:33,9);

    xcombstbd = averagedArray(23:33,6);
    ycombstbd = averagedArray(23:33,8);

    plot(xstbd,ystbd,'x',xport,yport,'o',xcombstbd,ycombstbd,'+',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Differential pressure transducer output [V]}');
    ylabel('{\bf Thrust [N]}');
    %title('{\bf Separate waterjet systems}');
    xlim([0.9 3.1]);
    grid on;
    % axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);

    hleg1 = legend('S:Starboard waterjet','S:Port waterjet','C:Starboard waterjet','C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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
    legend boxoff;

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
    legend boxoff;

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
    legend boxoff;

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
    legend boxoff;

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
    legend boxoff;

    %# ------------------------------------------------------------------------
    %# Save plots as PNGs -----------------------------------------------------
    %# ------------------------------------------------------------------------

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

    %# Save figure as PDF and PNG
    plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Stbd_and_port_data_10s_off_start_and_end');
    saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Stbd_and_port_data_10s_off_start_and_end'); % Assign save name
    print(gcf, '-djpeg', plotsavename);                                                                             % Save plot as PNG
    %close; 

    %# ************************************************************************
    %# PLOT STARBOARD DATA ONLY ***********************************************
    %# ************************************************************************

    figurename = sprintf('%s', 'STARBOARD Waterjet Data Only');
    f = figure('Name',figurename,'NumberTitle','off');

    %# SEPARATE SYSTEMS: RPM vs. flow rate ------------------------------------
    subplot(2,3,1);

    xport = averagedArray(1:11,7);
    yport = averagedArray(1:11,9);

    xstbd = averagedArray(12:22,6);
    ystbd = averagedArray(12:22,8);

    xcombport = averagedArray(23:33,7);
    ycombport = averagedArray(23:33,9);

    xcombstbd = averagedArray(23:33,6);
    ycombstbd = averagedArray(23:33,8);

    plot(xstbd,ystbd,'x',xcombstbd,ycombstbd,'o','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Differential pressure transducer output [V]}');
    ylabel('{\bf Thrust [N]}');
    %title('{\bf Separate waterjet systems}');
    xlim([0.9 3.1]);
    grid on;
    % axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);

    hleg1 = legend('S:Starboard waterjet','S:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xstbd,ystbd,'x',xcombstbd,ycombstbd,'+','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Differential pressure transducer output [V]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([1 3.1]);
    grid on;
    % axis square;

    hleg1 = legend('S:Starboard waterjet','C:Starboard waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xstbd,ystbd,'x',xcombstbd,ycombstbd,'+','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Torque [Nm]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([0 0.4]);
    grid on;
    % axis square;

    hleg1 = legend('S:Starboard waterjet','C:Starboard waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xstbd,ystbd,'x',xcombstbd,ycombstbd,'+','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Set shaft speed [RPM]}');
    ylabel('{\bf Measured shaft speed [RPM]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([500 3000]);
    ylim([480 2800]);
    grid on;
    % axis square;

    hleg1 = legend('S:Starboard waterjet','C:Starboard waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xstbd,ystbd,'x',xcombstbd,ycombstbd,'+','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Thrust [N]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([0 35]);
    grid on;
    % axis square;

    hleg1 = legend('S:Starboard waterjet','C:Starboard waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xstbd,ystbd,'x',xcombstbd,ycombstbd,'+','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Shaft power [W]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([0 112]);
    grid on;
    % axis square;

    hleg1 = legend('S:Starboard waterjet','C:Starboard waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

    %# ------------------------------------------------------------------------
    %# Save plots as PNGs -----------------------------------------------------
    %# ------------------------------------------------------------------------

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

    %# Save figure as PDF and PNG
    plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Stbd_data_10s_off_start_and_end');
    saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Stbd_data_10s_off_start_and_end'); % Assign save name
    print(gcf, '-djpeg', plotsavename);                                                                    % Save plot as PNG
    %close;

    %# ************************************************************************
    %# PLOT PORT DATA ONLY ****************************************************
    %# ************************************************************************

    figurename = sprintf('%s', 'PORT Waterjet Data Only');
    f = figure('Name',figurename,'NumberTitle','off');

    %# SEPARATE SYSTEMS: RPM vs. flow rate ------------------------------------
    subplot(2,3,1);

    xport = averagedArray(1:11,7);
    yport = averagedArray(1:11,9);

    xstbd = averagedArray(12:22,6);
    ystbd = averagedArray(12:22,8);

    xcombport = averagedArray(23:33,7);
    ycombport = averagedArray(23:33,9);

    xcombstbd = averagedArray(23:33,6);
    ycombstbd = averagedArray(23:33,8);

    plot(xport,yport,'o',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Differential pressure transducer output [V]}');
    ylabel('{\bf Thrust [N]}');
    %title('{\bf Separate waterjet systems}');
    xlim([0.9 3.1]);
    grid on;
    % axis square;

    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);

    hleg1 = legend('S:Port waterjet','C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xport,yport,'o',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Differential pressure transducer output [V]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([1 3.1]);
    grid on;
    % axis square;

    hleg1 = legend('S:Port waterjet','C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xport,yport,'o',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Torque [Nm]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([0 0.4]);
    grid on;
    % axis square;

    hleg1 = legend('S:Port waterjet','C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xport,yport,'o',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Set shaft speed [RPM]}');
    ylabel('{\bf Measured shaft speed [RPM]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([500 3000]);
    ylim([480 2800]);
    grid on;
    % axis square;

    hleg1 = legend('S:Port waterjet','C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xport,yport,'o',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Thrust [N]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([0 35]);
    grid on;
    % axis square;

    hleg1 = legend('S:Port waterjet','C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

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

    plot(xport,yport,'o',xcombport,ycombport,'^','LineWidth',2,'MarkerSize',10);
    xlabel('{\bf Measured shaft speed [RPM]}');
    ylabel('{\bf Shaft power [W]}');
    %title('{\bf Combined and separate waterjet systems}');
    xlim([480 2800]);
    ylim([0 112]);
    grid on;
    % axis square;

    hleg1 = legend('S:Port waterjet''C:Port waterjet');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    legend boxoff;

    %# ------------------------------------------------------------------------
    %# Save plots as PNGs -----------------------------------------------------
    %# ------------------------------------------------------------------------

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

    %# Save figure as PDF and PNG
    plotsavenamePDF = sprintf('_plots/_averaged_summary/PDF/AVERAGED_%s.pdf', 'Port_data_10s_off_start_and_end');
    saveas(gcf, plotsavenamePDF, 'pdf');    % Save figure as PDF
    plotsavename = sprintf('_plots/_averaged_summary/AVERAGED_%s.png', 'Port_data_10s_off_start_and_end'); % Assign save name
    print(gcf, '-djpeg', plotsavename);                                                                    % Save plot as PNG
    %close;
    
end