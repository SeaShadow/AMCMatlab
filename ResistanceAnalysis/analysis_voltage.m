%# ------------------------------------------------------------------------
%# Function [voltageUnit meanValue] = analysis_voltage( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         March 20, 2014
%# 
%# Function   :  Convert
%# 
%# Description:  Calculate real volate (i.e. subtract zero value)
%# 
%# Parameters :  rawData    = Raw measurement data
%#               Zero       = Zero value
%#
%# Return     :  voltageUnit = (array)   Real units
%#               meanValue   = (double)  Mean of real units
%# 
%# Examples of Usage: 
%# 
%#    >> rawData     = [ 5 6 7 8 9 10 11 12 13 14 ]; 
%#    >> Zero        = 1; 
%#    >> [ans1 ans2] = analysis_voltage(rawData,Zero)
%#    ans1 = 
%#           [ 12 52 71 78 80 85 93 95 95 99 ]
%#    ans2 = 
%#           80
%#
%# ------------------------------------------------------------------------

function [voltageUnit meanValue] = analysis_realunits(Raw_Data,Zero)

%# LOOP: SLOW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%# Apply calibration factor and zeros
%realUnits = [];
%for i = 1:numel(Raw_Data);
%    realUnits(i) = CF * (Raw_Data(i) - Zero);
%end

%# Convert row vector to column vector
%realUnits = realUnits.';

%# CELLFUN: FAST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Raw_Data = num2cell(Raw_Data);                                          % Double to cell conversion
Raw_Data  = cellfun(@(y) y-Zero, Raw_Data, 'UniformOutput', false);     % Apply functions to cell
%S = sprintf('%s*', Raw_Data{:});                                       % Cell to double conversion
%realUnits = sscanf(S, '%f*');                                          % Cell to double conversion
voltageUnit = cell2mat(Raw_Data);                                       % Cell to double conversion

%# Calculate mean
meanValue = mean(voltageUnit);