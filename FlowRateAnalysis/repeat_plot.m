%# ------------------------------------------------------------------------
%# function fft_plot( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         June 26, 2013
%# 
%# Function   :  Plot data of repeated runs 
%# 
%# Description:  Plot data of repeated runs, carry out single factor ANOVA
%#               Statistics and save figure as PNG.
%# 
%# Parameters :  timeData     = Time series data
%#               resultsArray = 3*x results array
%#               runArray     = Array with run numbers (i.e. 1,2,3)
%#               rpmValue     = RPM of repeats
%#               examineTitle = Name of repeat (i.e. CH_2 PORT Kiel Probe 2720 RPM)
%#               examineUnit  = Unit (i.e. V, Kg, etc.)
%#               savename     = Filename to save figure (i.e. CH_2_PORT_Kiel_Probe_2720_RPM)
%#               name         = Run file name (e.g. R12-02_moving)
%#
%# Return     :  NONE
%# 
%# Examples of Usage: 
%# 
%#    >> timeData     = [ 1 2 3 4 5 6 7 8 9 10 ]; 
%#    >> resultsArray = [ 1 2 3 4 5 6 7 8 9 10; 1 2 3 4 5 6 7 8 9 10; 1 2 3 4 5 6 7 8 9 10]; 
%#    >> runArray     = [ 1 2 3 ];
%#    >> rpmValue     = 500;
%#    >> examineTitle = 'CH_2 PORT Kiel Probe 2720 RPM'; 
%#    >> examineUnit  = 'V'; 
%#    >> savename     = 'CH_2_PORT_Kiel_Probe_2720_RPM'; 
%#    >> name         = 'R12-02_moving'.
%#    >> repeat_plot(timeData,resultsArray,runArray,examineTitle,examineUnit,savename,name)
%#    ans = NONE
%#
%# ------------------------------------------------------------------------

function repeat_plot(timeData,resultsArray,runArray,rpmValue,examineTitle,examineUnit,savename,name)

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# Start and end sample (10s * 800Hz = 8000 samples) !!!!!!!!!!!!!!!!!!!!!!

% startData   = 16000;
% endData     = 32000;

% startData   = 16000;
% endData     = length(timeData)-8000;

startData   = 1;
endData     = length(timeData);

%# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%# Variables
x  = timeData(startData:endData);
y1 = resultsArray(1,startData:endData).';
y2 = resultsArray(2,startData:endData).';
y3 = resultsArray(3,startData:endData).';

%# Averaged data
avgRepeatData = mean(resultsArray(1:3,startData:endData)).';

%# Plot data
figurename = sprintf('%s: Runs %s to %s // %s RPM', examineTitle, num2str(runArray(1)), num2str(runArray(3)), num2str(rpmValue));
f = figure('Name',figurename,'NumberTitle','off');

%# Trendline
p11 = polyfit(x,y1,1);
p12 = polyval(p11,x);
p21 = polyfit(x,y2,1);
p22 = polyval(p21,x);
p31 = polyfit(x,y3,1);
p32 = polyval(p31,x);
p41 = polyfit(x,avgRepeatData,1);
p42 = polyval(p41,x);

%# Plot: Repeat #1 --------------------------------------------------------
subplot(3,3,1);
h1 = plot(x,y1,'-r');
hold on;
h2 = plot(x,p12,'-k');
xlabel('{\bf Time [s]}');
combinedStr = strcat('{\bf', sprintf('Output [%s]', examineUnit),'}');
ylabel(combinedStr);
title('{\bf Real Units Data: Repeat 1}');
xlim([startData/Fs round(endData/Fs)]);
grid on;
set(h1(1),'linewidth',1);   % Repeat #1
set(h2(1),'linewidth',2);   % Trendline #1

%# Plot: Repeat #2 --------------------------------------------------------
subplot(3,3,2);
h1 = plot(x,y2,'-b',x,p22,':k');
hold on;
h2 = plot(x,p22,'-k');
xlabel('{\bf Time [s]}');
combinedStr = strcat('{\bf', sprintf('Output [%s]', examineUnit),'}');
ylabel(combinedStr);
title('{\bf Real Units Data: Repeat 2}');
xlim([startData/Fs round(endData/Fs)]);
grid on;
set(h1(1),'linewidth',1);   % Repeat #2
set(h2(1),'linewidth',2);   % Trendline #2

%# Plot: Repeat #3 --------------------------------------------------------
subplot(3,3,3);
h1 = plot(x,y3,'-g');
hold on;
h2 = plot(x,p32,'-k');
xlabel('{\bf Time [s]}');
combinedStr = strcat('{\bf', sprintf('Output [%s]', examineUnit),'}');
ylabel(combinedStr);
title('{\bf Real Units Data: Repeat 3}');
xlim([startData/Fs round(endData/Fs)]);
grid on;
set(h1(1),'linewidth',1);   % Repeat #3
set(h2(1),'linewidth',2);   % Trendline #3

%# Plot: Averaged ---------------------------------------------------------
subplot(3,1,2);
h1 = plot(x,avgRepeatData,'-k');
hold on;
h2 = plot(x,p42,'-r');
xlabel('{\bf Time [s]}');
combinedStr = strcat('{\bf', sprintf('Output [%s]', examineUnit),'}');
ylabel(combinedStr);
title('{\bf Real Units Data: Averaged}');
xlim([startData/Fs round(endData/Fs)]);
grid on;
set(h1(1),'linewidth',1);   % Averaged
set(h2(1),'linewidth',2);   % Averaged trendline

%# Plot: Overlayed --------------------------------------------------------
subplot(3,1,3);
h1 = plot(x,y1,'-r',x,y2,'-b',x,y3,'-g',x,avgRepeatData,'-k');
%hold on;
%h2 = plot(x,p12,'--k',x,p22,':k',x,p32,'-.k',x,p42,'-r');
xlabel('{\bf Time [s]}');
combinedStr = strcat('{\bf', sprintf('Output [%s]', examineUnit),'}');
ylabel(combinedStr);
title('{\bf Overlayed of Real Units Data}');
xlim([startData/Fs round(endData/Fs)]);
grid on;
set(h1(1),'linewidth',1);   % Repeat #1
set(h1(2),'linewidth',1);   % Repeat #2
set(h1(3),'linewidth',1);   % Repeat #3
% set(h2(1),'linewidth',2);   % Trendline #1
% set(h2(2),'linewidth',2);   % Trendline #2
% set(h2(3),'linewidth',2);   % Trendline #3

%# Legend
repLgnd1 = sprintf('Repeat #1: Run %s', num2str(runArray(1)));
repLgnd2 = sprintf('Repeat #2: Run %s', num2str(runArray(2)));
repLgnd3 = sprintf('Repeat #3: Run %s', num2str(runArray(3)));
repLgnd4 = 'Averaged runs';
hleg1 = legend(repLgnd1,repLgnd2,repLgnd3,repLgnd4);
set(hleg1,'Location','NorthWest');
set(hleg1,'Interpreter','none');

%# Set figure to full screen
%set(f,'Units','Normalized','OuterPosition',[0 0 1 1])  

%# ------------------------------------------------------------------------
%# Mean values -----------------------------------------------------
%# ------------------------------------------------------------------------
runString = sprintf('Runs %s, %s, %s // RPM = %s',num2str(runArray(1)),num2str(runArray(2)),num2str(runArray(3)), num2str(rpmValue));
disp(sprintf('>> %s <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<',examineTitle));
if strcmp(examineTitle(1:4),'CH_0') == 0
    disp(sprintf('Run %s: Mean repeat #1 = %s %s', num2str(runArray(1)), sprintf('%.2f',abs(mean(y1))), examineUnit));
    disp(sprintf('Run %s: Mean repeat #2 = %s %s', num2str(runArray(2)), sprintf('%.2f',abs(mean(y2))), examineUnit));
    disp(sprintf('Run %s: Mean repeat #3 = %s %s', num2str(runArray(3)), sprintf('%.2f',abs(mean(y3))), examineUnit));
    disp(sprintf('%s:: Average mean = %s %s', runString, sprintf('%.2f', abs(mean(avgRepeatData))), examineUnit));
else
    disp('Wave probe, slope used instead of mean.');
end

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

%# RUN directory
fPath = sprintf('_plots/%s', name(1:3));
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end

%# Repeat directory
fPath = sprintf('_plots/%s', '_repeats');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else    
    mkdir(fPath);
end
plotsavename = sprintf('_plots/_repeats/RUNS_%s_TO_%s_%s_%s_RPM.png', num2str(runArray(1)), num2str(runArray(3)), savename, num2str(rpmValue));   % Assign save name
print(gcf, '-djpeg', plotsavename);                                                                                                             % Save plot to _plots
%close;

%# ------------------------------------------------------------------------
%# STATISTICS:          Single factor, tepeated measures ANOVA ------------
%# Required functions:  anova_rm, statdisptable, fcdf, distchck -----------
%# ------------------------------------------------------------------------

%# Convert row vectors to column vectors
resultsArray = resultsArray.';

y1 = resultsArray(:,1);
y2 = resultsArray(:,2);
y3 = resultsArray(:,3);

% y1 = [1;2;3;4;5;6];
% y2 = [1;2;3;4;5;6];
% y3 = [1;2;3;4;5;6];

%# Statistics
if exist('anova_rm','file') == 2 && exist('statdisptable','file') == 2 && exist('fcdf','file') == 2 && exist('distchck','file') == 2
    [p, table] = anova_rm({y1 y2 y3},'off');
    if cell2mat(table(3,6)) < 0.05
        displayTitle = sprintf('%s:: p-value, %s < 0.05: Reject null-hypothesis. Averages of repeats #1, #2 and #3 are different.',runString, sprintf('%.2f',cell2mat(table(3,6))));
    else
        displayTitle = sprintf('%s:: p-value, %s > 0.05: Fail to reject null-hypothesis that the group averages are different.',runString, sprintf('%.2f',cell2mat(table(3,6))));
    end
    disp(displayTitle);
else
    disp('One or all of those function are not available: anova_rm, statdisptable, fcdf, distchck');
end