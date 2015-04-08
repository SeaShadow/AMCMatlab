%# Data Processing
%# See: http://sedok.narod.ru/s_files/poland/2360_PDF_C15.pdf

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
%# 0. Read Data
%# ------------------------------------------------------------------------

% Define run filename
runnumber = 141;

filename = sprintf('_time_series_data/R%s.dat',num2str(runnumber));

% Read DAT file
if exist(filename, 'file') == 2
    timeSeriesData = csvread(filename);
    timeSeriesData(all(timeSeriesData==0,2),:)=[];
else
    break;
end

% Column names for timeSeriesData

%[1] Time               (s)
%[2] RU: Speed          (m/s)
%[3] RU: Forward LVDT   (mm)
%[4] RU: Aft LVDT       (mm)
%[5] RU: Drag           (g)

%# Set columns to be used as X and Y values from time series data

x  = timeSeriesData(:,1);   % Time
y  = timeSeriesData(:,5);   % Drag

%# ------------------------------------------------------------------------
%# 1. Example of Noise Reduction Averaging
%# ------------------------------------------------------------------------

% y1 = y;
% y2 = y1; 
% y3 = y2; 
% 
% for i=1:length(x)-5
%     y2(i+4)=(y1(i)+y1(i+1)+y1(i+2)+y1(i+3)+y1(i+4))/5;
% end 
% 
% for i=1:length(x)-10
%     y3(i+9)=(y1(i)+y1(i+1)+y1(i+2)+y1(i+3)+y1(i+4)+y1(i+5)+y1(i+6)+y1(i+7)+y1(i+8)+y1(i+9))/10;
% end 
% 
% % Plots
% setTitle = 'Noise Reduction Averaging';
% fig = figure('Name',setTitle,'NumberTitle','off');
% title(setTitle);
% 
% h = plot(x,y1,'xb',x,y2,'*r',x,y3,'+g');
% xlabel('Time (s)');
% ylabel('Output (g)');
% grid on;
% box on;
% %axis square;
% 
% %# Set plot figure background to a defined color
% %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
% set(gcf,'Color',[1,1,1]);
% 
% %# Axis limitations
% minX = min(x);
% maxX = max(x);
% set(gca,'XLim',[minX maxX]);
% set(gca,'XTick',[minX:5:maxX]);
% 
% % subplot(312)
% % plot(x,y2);
% % xlabel('B'); 
% % 
% % subplot(313)
% % plot(x,y3);
% % xlabel('C');
% 
% %# Legend
% hleg1 = legend('Unchanged','Noise reduction #1','Noise reduction #2');
% set(hleg1,'Location','NorthEast');
% set(hleg1,'Interpreter','none');
% %legend boxoff;
% 
% clearvars legendInfo;

%# ------------------------------------------------------------------------
%# 2. Example of Min-Max Normalization
%# ------------------------------------------------------------------------

x  = x;
y1 = y;

min1 = min(y1);max1=max(y1);
min2 = 0;
max2 = 1;
y2   =((y1-min1)/(max1-min1))*(max2-min2)+min2;

% Plots
setTitle = 'Min-Max Normalization';
fig = figure('Name',setTitle,'NumberTitle','off');
title(setTitle);

polyf1 = polyfit(x,y1,1);
polyv1 = polyval(polyf1,x);

% Slope and intercept of linear fit ---------------------------
slopeITTC     = polyf1(1,1);         % Slope
interceptITTC = polyf1(1,2);         % Intercept
theta         = atan(polyf1(1));     % Angle

if interceptITTC > 0
    chooseSign = '+';
    interceptITTC = interceptITTC;
else
    chooseSign = '-';
    interceptITTC = abs(interceptITTC);
end

slopeTextITTC = sprintf('Run %s:: %s:: y = %s*x %s %s, theta = %s', num2str(runnumber), 'Untreated output', sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
disp(slopeTextITTC);

polyf2 = polyfit(x,y2,1);
polyv2 = polyval(polyf2,x);

% Slope and intercept of linear fit ---------------------------
slopeITTC     = polyf2(1,1);         % Slope
interceptITTC = polyf2(1,2);         % Intercept
theta         = atan(polyf2(1));     % Angle

if interceptITTC > 0
    chooseSign = '+';
    interceptITTC = interceptITTC;
else
    chooseSign = '-';
    interceptITTC = abs(interceptITTC);
end

slopeTextITTC = sprintf('Run %s:: %s:: y = %s*x %s %s, theta = %s', num2str(runnumber), setTitle, sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
disp(slopeTextITTC);
disp('---------------------------------------------------------------------');

h = plot(x,y1,'xb',x,polyv1,x,y2,'*r',x,polyv2);
xlabel('Time (s)');
ylabel('Output (g)');
grid on;
box on;
%axis square;

% Line formatting
set(h(2),'Color','k','Marker','s','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(4),'Color','k','Marker','s','MarkerSize',1,'LineStyle','-.','linewidth',1);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX = min(x);
maxX = max(x);
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',[minX:5:maxX]);

% subplot(211);
% plot(x,y1);
% xlabel('A');
% 
% subplot(212);
% plot(x,y2);
% xlabel('B');

%# Legend
hleg1 = legend('Untreated output','Min-Max Normalization','Linear fit');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
%legend boxoff;

clearvars legendInfo;

%# ------------------------------------------------------------------------
%# 3. Example of Zscore Normalization
%# ------------------------------------------------------------------------

x  = x;
y1 = y;

mean1 = sum(y1)/length(y1);
std1  = sqrt((norm(y1)^2)/length(y1)-mean1);
y2    = (y1-mean1)/std1;

% Plots
setTitle = 'Example of Zscore Normalization';
fig = figure('Name',setTitle,'NumberTitle','off');
title(setTitle);

polyf1 = polyfit(x,y1,1);
polyv1 = polyval(polyf1,x);

% Slope and intercept of linear fit ---------------------------
slopeITTC     = polyf1(1,1);         % Slope
interceptITTC = polyf1(1,2);         % Intercept
theta         = atan(polyf1(1));     % Angle

if interceptITTC > 0
    chooseSign = '+';
    interceptITTC = interceptITTC;
else
    chooseSign = '-';
    interceptITTC = abs(interceptITTC);
end

slopeTextITTC = sprintf('Run %s:: %s:: y = %s*x %s %s, theta = %s', num2str(runnumber), 'Untreated output', sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
disp(slopeTextITTC);

polyf2 = polyfit(x,y2,1);
polyv2 = polyval(polyf2,x);

% Slope and intercept of linear fit ---------------------------
slopeITTC     = polyf2(1,1);         % Slope
interceptITTC = polyf2(1,2);         % Intercept
theta         = atan(polyf2(1));     % Angle

if interceptITTC > 0
    chooseSign = '+';
    interceptITTC = interceptITTC;
else
    chooseSign = '-';
    interceptITTC = abs(interceptITTC);
end

slopeTextITTC = sprintf('Run %s:: %s:: y = %s*x %s %s, theta = %s', num2str(runnumber), setTitle, sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
disp(slopeTextITTC);
disp('---------------------------------------------------------------------');

h = plot(x,y1,'xb',x,polyv1,x,y2,'*r',x,polyv2);
xlabel('Time (s)');
ylabel('Output (g)');
grid on;
box on;
%axis square;

% Line formatting
set(h(2),'Color','k','Marker','s','MarkerSize',1,'LineStyle','--','linewidth',1);
set(h(4),'Color','k','Marker','s','MarkerSize',1,'LineStyle','-.','linewidth',1);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX = min(x);
maxX = max(x);
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',[minX:5:maxX]);

% subplot(211)
% plot(y1)
% xlabel('A')
% 
% subplot(212)
% plot(y2)
% xlabel('B')

%# Legend
hleg1 = legend('Untreated output','Zscore Normalization','Linear fit');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','none');
%legend boxoff;

clearvars legendInfo;

%# ------------------------------------------------------------------------
%# 4. Example of Sigmoidal Normalization 
%# ------------------------------------------------------------------------

% x  = x;
% y1 = y;
% 
% y1(50)  = y1(50)+986;
% y1(150) = y1(150)+1286;
% 
% mean1 = sum(y1)/length(y1) ; 
% std1  = sqrt((norm(y1)^2)/length(y1)-mean1) ; 
% alpha = (y1-mean1)/std1 ; 
% y2    = (1-exp(-alpha))./(1+exp(-alpha)) ; 
% 
% % Plots
% setTitle = 'Sigmoidal Normalization';
% fig = figure('Name',setTitle,'NumberTitle','off');
% title(setTitle);
% 
% polyf = polyfit(x,y2,1);
% polyv = polyval(polyf,x);
% 
% % Slope and intercept of linear fit ---------------------------
% slopeITTC     = polyf(1,1);         % Slope
% interceptITTC = polyf(1,2);         % Intercept
% theta         = atan(polyf(1));     % Angle
% 
% if interceptITTC > 0
%     chooseSign = '+';
%     interceptITTC = interceptITTC;
% else
%     chooseSign = '-';
%     interceptITTC = abs(interceptITTC);
% end
% 
% slopeTextITTC = sprintf('%s:: Run %s:: y = %s*x %s %s, theta = %s', setTitle, num2str(runnumber), sprintf('%.3f',slopeITTC), chooseSign, sprintf('%.3f',interceptITTC), sprintf('%.3f',theta));
% disp(slopeTextITTC);
% 
% h = plot(x,y1,'xb',x,y2,'*r',x,polyv);
% xlabel('Time (s)');
% ylabel('Output (g)');
% grid on;
% box on;
% %axis square;
% 
% % USING FILTER - Colors and markers
% set(h(3),'Color','k','Marker','s','MarkerSize',1,'LineStyle','-.','linewidth',2);
% 
% %# Set plot figure background to a defined color
% %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
% set(gcf,'Color',[1,1,1]);
% 
% %# Axis limitations
% minX = min(x);
% maxX = max(x);
% set(gca,'XLim',[minX maxX]);
% set(gca,'XTick',[minX:5:maxX]);
% 
% % subplot(211)
% % plot(y1)
% % xlabel('A') 
% % 
% % subplot(212)
% % plot(y2)
% % xlabel('B') 
% 
% %# Legend
% hleg1 = legend('Untreated output','Sigmoidal Normalization','Linear fit');
% set(hleg1,'Location','NorthEast');
% set(hleg1,'Interpreter','none');
% %legend boxoff;
% 
% clearvars legendInfo;
