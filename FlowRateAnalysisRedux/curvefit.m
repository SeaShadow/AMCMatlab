%# ------------------------------------------------------------------------
%# function curvefit( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         July 9, 2013
%# 
%# Function   :  Curve fitting
%# 
%# Description:  Fitting Experimental Data to Straight Lines
%# 
%# Source:      http://www.che.udel.edu/pdf/FittingData.pdf
%#
%# Parameters :  run     = Run number
%#               x       = X-axis data
%#               y       = X-axis data
%#               channel = Channel number (sensor)
%#
%# Return     :  results = Nx1 array
%# 
%# Examples of Usage: 
%# 
%#    >> run             = 29;
%#    >> x               = [1;2;3;4;5]; 
%#    >> y               = [6;7;8;9;10];
%#    >> channel         = 1 (e.g. 1 = wave probe);
%#    >> [results]       = stats_avg(run,x,y,channel)
%#    ans =              [1 2 3 4 5 6 7 8 9]
%#
%# Rresults columns
%#                      %[1]  Run number
%#                      %[2]  Slope
%#                      %[3]  Intercept
%#                      %[4]  S (root square)
%#                      %[5]  Error slope
%#                      %[6]  Error intercept
%#                      %[7]  Relative slope error
%#                      %[8]  Relative intercept error 
%#                      %[9]  Channel number
%#
%# ------------------------------------------------------------------------

function [results] = curvefit(run,x,y,channel)

%# Cross-check data for calcuations (see wave probe calibation Excel spread sheet)
%x = [1.01;1.27;1.85;2.38;2.83;3.13;3.96;4.91];
%y = [0;0.19;0.58;0.96;1.26;1.47;2.07;2.75];

results = [];

% Sample number
samples = length(x);

%# Trendline
p  = polyfit(x,y,1);
p2 = polyval(p,x);

% Slope of trendline => Y = (a * X ) + b
slope{2} = polyfit(x,y,1);
slopeVal = slope{1,2}(1);   % Slope     = a
intcpVal = slope{1,2}(2);   % Intercept = b    

%# combData array columns:
    %[1]  xi
    %[2]  yi        
    %[3]  xi*yi
    %[4]  xi^2
    %[5]  yi^2
    %[6]  (yi-axi-b)^2

combData = [];

%# xi
combData(:,1) = x;

%# yi
combData(:,2) = y;    

%# Use common variable
A = num2cell(x);
B = num2cell(y);    

%# xi * yi
C = cellfun(@(a,b) b*a, A, B, 'UniformOutput', 0);
combData(:,3) = cell2mat(C);

%# (xi)^2
C = cellfun(@(a) a^2, A, 'UniformOutput', 0);
combData(:,4) = cell2mat(C);    

%# (yi)^2
C = cellfun(@(b) b^2, B, 'UniformOutput', 0);
combData(:,5) = cell2mat(C);    

%# Sums
sumxi       = sum(combData(:,1));
sumyi       = sum(combData(:,2));
sumxiyi     = sum(combData(:,3));
sumxi2      = sum(combData(:,4));
sumyi2      = sum(combData(:,5));

%# Calculations
slope     = ((samples*sumxiyi)-(sumxi)*(sumyi))/((samples*sumxi2)-(sumxi)^2);
intercept = ((sumxi2)*(sumyi)-(sumxi)*(sumxiyi))/((samples*sumxi2)-(sumxi)^2);

%# (yi - a*xi-b)^2
C = cellfun(@(a,b) (b-slope*a-intercept)^2, A, B, 'UniformOutput', 0);
combData(:,6) = cell2mat(C);    

sumyiaxib2  = sum(combData(:,6));    

%# S = square root of the quantity found by dividing the sum of the squares of the deviations from the best fit line
S = sqrt(sumyiaxib2/(samples-2));

errorSlope        = S*sqrt(samples/((samples*sumxi2)-(sumxi)^2));
errorIntercept    = S*sqrt(sumxi2/((samples*sumxi2)-(sumxi)^2));

relSloperError    = errorSlope/slope;
relInterceptError = errorIntercept/intercept;

%# Display
disp(sprintf('PLOYFIT :: Slope = %s | Intercept = %s (by polyfit function)',num2str(slopeVal),num2str(intcpVal)));
disp(sprintf('CURVEFIT:: Slope = %s | Intercept = %s (by curve fitting, regression)',num2str(slope),num2str(intercept)));
disp(sprintf('CURVEFIT:: S                        = %s',num2str(S)));
disp(sprintf('CURVEFIT:: Error slope              = %s',num2str(errorSlope)));
disp(sprintf('CURVEFIT:: Error intercept          = %s',num2str(errorIntercept)));
disp(sprintf('CURVEFIT:: Relative slope error     = %s%%',sprintf('%.2f',abs(relSloperError*100))));
disp(sprintf('CURVEFIT:: Relative intercept error = %s%%',sprintf('%.2f',abs(relInterceptError*100))));

%# Summarise data for cfArray        
results(:,1) = round(run);
results(:,2) = slope;
results(:,3) = intercept;
results(:,4) = S;
results(:,5) = errorSlope;
results(:,6) = errorIntercept;
results(:,7) = relSloperError;
results(:,8) = relInterceptError;
results(:,9) = channel;