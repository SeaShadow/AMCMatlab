%# ------------------------------------------------------------------------
%# function stats_avg( input )
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  December 12, 2014
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

% Variables and array dimensions
R       = results;
[mr,nr] = size(repeatrunnos);   % Array dimensions
[m,n]   = size(results);        % Array dimensions

% Empty arrays
runArray      = [];
averagedArray = [];

% Filer resultsArray for specific run numbers as specified in repeatrunnos
for j=1:m
    for l=1:nr
        if repeatrunnos(1,l) == results(j,1)
            runArray(l,:) = results(j,:);
        end
    end
end

% Shorten variable name
RA = runArray;

% Stop execution if RA is empty
if length(RA) == 0
    return;
end

% Split results array based on column 11 (Froude Length Number)
A = arrayfun(@(x) RA(RA(:,11) == x, :), unique(RA(:,11)), 'uniformoutput', false);

% Array dimensions of split down array
[ma,na] = size(A);

%# Array columns:
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
%[28] Run condition                                                            (-)
%[29] SPEED: Minimum value                                                     (m/s)
%[30] SPEED: Maximum value                                                     (m/s)
%[31] SPEED: Average value                                                     (m/s)
%[32] SPEED: Percentage (max.-avg.) to max. value (exp. 3%)                    (m/s)
%[33] LVDT (FWD): Minimum value                                                (mm)
%[34] LVDT (FWD): Maximum value                                                (mm)
%[35] LVDT (FWD): Average value                                                (mm)
%[36] LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
%[37] LVDT (AFT): Minimum value                                                (mm)
%[38] LVDT (AFT): Maximum value                                                (mm)
%[39] LVDT (AFT): Average value                                                (mm)
%[40] LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
%[41] DRAG: Minimum value                                                      (g)
%[42] DRAG: Maximum value                                                      (g)
%[43] DRAG: Average value                                                      (g)
%[44] DRAG: Percentage (max.-avg.) to max. value (exp. 3%)                     (g)
%[45] SPEED: Standard deviation                                                (m/s)
%[46] LVDT (FWD): Standard deviation                                           (mm)
%[47] LVDT (AFT): Standard deviation                                           (mm)
%[48] DRAG: Standard deviation                                                 (g)
%[49] SPEED: Mean of standard deviation                                        (-)
%[50] LVDT (FWD): Mean of standard deviation                                   (-)
%[51] LVDT (AFT): Mean of standard deviation                                   (-)
%[52] DRAG: Mean of standard deviation                                         (-)
%[53] Number how many times run has been repeated                              (-)

% Added: 11/12/2014, Multiplied CTm data by 1000 for better readibility
%[54] CTm: Standard deviation                                                  (-)

% Added: 12/12/2014, Running trim
%[55] Trim: Standard deviation                                                 (deg)

for m=1:ma
    
    [mcond,ncond] = size(A{m});
    
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
    averagedArray(m,29) = mean(A{m}(:,29));
    averagedArray(m,30) = mean(A{m}(:,30));
    averagedArray(m,31) = mean(A{m}(:,31));
    averagedArray(m,32) = mean(A{m}(:,32));
    averagedArray(m,33) = mean(A{m}(:,33));
    averagedArray(m,34) = mean(A{m}(:,34));
    averagedArray(m,35) = mean(A{m}(:,35));
    averagedArray(m,36) = mean(A{m}(:,36));
    averagedArray(m,37) = mean(A{m}(:,37));
    averagedArray(m,38) = mean(A{m}(:,38));
    averagedArray(m,39) = mean(A{m}(:,39));
    averagedArray(m,40) = mean(A{m}(:,40));
    averagedArray(m,41) = mean(A{m}(:,41));
    averagedArray(m,42) = mean(A{m}(:,42));
    averagedArray(m,43) = mean(A{m}(:,43));
    averagedArray(m,44) = mean(A{m}(:,44));
    averagedArray(m,45) = std(A{m}(:,45),1);
    averagedArray(m,46) = std(A{m}(:,46),1);
    averagedArray(m,47) = std(A{m}(:,47),1);
    averagedArray(m,48) = std(A{m}(:,48),1);
    averagedArray(m,49) = averagedArray(m,45)/sqrt(mcond);
    averagedArray(m,50) = averagedArray(m,46)/sqrt(mcond);
    averagedArray(m,51) = averagedArray(m,47)/sqrt(mcond);
    averagedArray(m,52) = averagedArray(m,48)/sqrt(mcond);
    averagedArray(m,53) = mcond;
    
    % Added: 11/12/2014, Multiplied CTm data by 1000 for better readibility
    C = A{m}(:,10);
    Raw_Data = num2cell(C);
    Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false);
    C = cell2mat(Raw_Data);
    averagedArray(m,54) = std(C,1);
    
    % Added: 12/12/2014, Running trim
    averagedArray(m,55) = std(A{m}(:,13),1);
    
end