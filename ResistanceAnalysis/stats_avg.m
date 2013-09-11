%# ------------------------------------------------------------------------
%# function stats_avg( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         September 10, 2013
%# 
%# Function   :  Average data
%# 
%# Description:  Average run data
%# 
%# Parameters :  prepeatrunnos = run numbers of repeats
%#               results       = results MxN array
%#
%# Return     :  averagedArray = Nx1 array
%# 
%# Examples of Usage: 
%# 
%#    >> prepeatrunnos   = [1,2,3]; 
%#    >> results         = [1 2 3;2 3 4;5 6 7]; 
%#    >> [averagedArray] = stats_avg(repeatrunnos,results)
%#    ans = [1 2 3 4 5 6 7 8 9 10]
%#
%# ------------------------------------------------------------------------

function [averagedArray] = stats_avg(repeatrunnos,results)

R       = results;
[mr,nr] = size(repeatrunnos);   % Array dimensions
[m,n]   = size(results);        % Array dimensions

runArray      = [];
averagedArray = [];

for j=1:m
    for l=1:nr
        if repeatrunnos(1,l) == results(j,1)
            runArray(l,:) = results(j,:);
        end
    end
end

RA = runArray;

% Stop execution if RA is empty
if length(RA) == 0
    return;
end

A = arrayfun(@(x) RA(RA(:,11) == x, :), unique(RA(:,11)), 'uniformoutput', false);
[ma,na] = size(A);              % Array dimensions

%# Averaged array columns: 
    %[1]  Run No.                                                                  (-)
    %[2]  FS                                                                       (Hz)
    %[3]  No. of samples                                                           (-)
    %[4]  Record time                                                              (s)
    %[5]  Model Averaged speed                                                     (m/s)
    %[6]  Model Averaged fwd LVDT                                                  (m)
    %[7]  Model Averaged aft LVDT                                                  (m)
    %[8]  Model Averaged drag                                                      (g)
    %[9]  Model (Rtm) Total resistance                                             (N)
    %[10] Model (Ctm) Total resistance Coefficient                                 (-)
    %[11] Model Froude length number                                               (-)
    %[12] Model Heave                                                              (mm)
    %[13] Model Trim                                                               (Degrees)
    %[14] Equivalent full scale speed                                              (m/s)
    %[15] Equivalent full scale speed                                              (knots)
    %[16] Model (Rem) Reynolds Number                                              (-)
    %[17] Model (Cfm) Frictional Resistance Coefficient (ITTC'57)                  (-)
    %[18] Model (Cfm) Frictional Resistance Coefficient (Grigson)                  (-)
    %[19] Model (Crm) Residual Resistance Coefficient                              (-)
    %[20] Model (PEm) Model Effective Power                                        (W)
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    %[23] Full Scale (Cfs) Frictional Resistance Coefficient (ITTC'57)             (-)
    %[24] Full Scale (Cts) Total resistance Coefficient                            (-)
    %[25] Full Scale (Rts) Total resistance (Rt)                                   (N)
    %[26] Full Scale (PEs) Model Effective Power                                   (W)
    %[27] Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    %[28] Run condition  

for m=1:ma
    %[mrn,nrn] = size(A{m});
    
    averagedArray(m,1)  = 0;
    averagedArray(m,2)  = 0;
    averagedArray(m,3)  = 0;
    averagedArray(m,4)  = 0; 
    averagedArray(m,5)  = mean(A{m}(:,5));
    averagedArray(m,6)  = mean(A{m}(:,6));
    averagedArray(m,7)  = mean(A{m}(:,7));
    averagedArray(m,8)  = mean(A{m}(:,8));
    averagedArray(m,9)  = mean(A{m}(:,9));
    averagedArray(m,10) = mean(A{m}(:,10));
    averagedArray(m,11) = mean(A{m}(:,11));
    averagedArray(m,12) = mean(A{m}(:,12));
    averagedArray(m,13) = mean(A{m}(:,13));
    averagedArray(m,14) = mean(A{m}(:,14));
    averagedArray(m,15) = mean(A{m}(:,15));
    averagedArray(m,16) = mean(A{m}(:,16));
    averagedArray(m,17) = mean(A{m}(:,17));
    averagedArray(m,18) = mean(A{m}(:,18));
    averagedArray(m,19) = mean(A{m}(:,19));
    averagedArray(m,20) = mean(A{m}(:,20));
    averagedArray(m,21) = mean(A{m}(:,21));
    averagedArray(m,22) = mean(A{m}(:,22));
    averagedArray(m,23) = mean(A{m}(:,23));
    averagedArray(m,24) = mean(A{m}(:,24));
    averagedArray(m,25) = mean(A{m}(:,25));
    averagedArray(m,26) = mean(A{m}(:,26));
    averagedArray(m,27) = mean(A{m}(:,27));
    averagedArray(m,28) = mean(A{m}(:,28));
    
    %A{m}(:,1)
    
    %averagedArray(:,1) = mean(A{m}(1:mrn));
%     for o=1:mrn
%         averagedArray(:,5)  = mean(flowRate(startRun:endRun));
%         %A{m}(1,1)
%     end
end