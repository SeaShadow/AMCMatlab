%# ------------------------------------------------------------------------
%# function stats_minmax( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         September 17, 2013
%# 
%# Function   :  Average data
%# 
%# Description:  Average run data
%# 
%# Parameters :  condition = results MxN array
%#
%# Return     :  averagedArray = Nx1 array
%# 
%# Examples of Usage: 
%# 
%#    >> condition       = [1 2 3;2 3 4;5 6 7]; 
%#    >> [averagedArray] = stats_minmax(condition)
%#    ans1 = 
%#           [ 12 52 71; 78 80 85; 93 95 95;
%#
%# ------------------------------------------------------------------------

function [minmaxArray] = stats_minmax(condition)

% Variables and array dimensions
CO    = condition;
COND  = arrayfun(@(x) CO(CO(:,11) == x, :), unique(CO(:,11)), 'uniformoutput', false);
[m,n] = size(COND);

% Empty arrays
minmaxArray = [];

%# Array columns: 
    %[1]  Run condition                                      (-)
    %[2]  Froude Length Number (Fr)                          (-)
    %[3]  HEAVE: Minimum value                               (mm)
    %[4]  HEAVE: Maximum value                               (mm)
    %[5]  HEAVE: Mean value of minimum and maximum values    (mm)
    %[6]  Model (Crm) Residual Resistance Coefficient * 1000 (-)
    %[7]  Froude length number                               (-)
    % Added columns: 27/9/2013 --------------------------------------------
    %[8]  TRIM: Minimum value                                (deg)
    %[9]  TRIM: Maximum value                                (deg)
    %[10] TRIM: Mean value of minimum and maximum values     (deg)    
    
for m=1:m
    %COND{m}(:,11)  COLUMN
    %COND{m}(1,11)  SINGLE VALUE
    minmaxArray(m,1)  = COND{m}(1,28);
    minmaxArray(m,2)  = COND{m}(1,11);
    minmaxArray(m,3)  = min(COND{m}(:,12));
    minmaxArray(m,4)  = max(COND{m}(:,12));
    intArray = [minmaxArray(m,3) minmaxArray(m,4)];
    minmaxArray(m,5)  = mean(intArray);
    minmaxArray(m,6)  = mean(COND{m}(:,19))*1000;
    minmaxArray(m,7)  = mean(COND{m}(:,11));
    % Added columns: 27/9/2013 --------------------------------------------
    minmaxArray(m,8)  = min(COND{m}(:,13));
    minmaxArray(m,9)  = max(COND{m}(:,13));    
    intArray = [minmaxArray(m,8) minmaxArray(m,9)];
    minmaxArray(m,10) = mean(intArray);
end