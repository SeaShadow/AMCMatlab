%# ------------------------------------------------------------------------
%# function [resistance] = calBHResistanceBasedOnFr( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  October 7, 2014
%# 
%# Function   :  Resistance curve based on Froude Numbers (Fr)
%# 
%# Description:  Calculate resistance curve based on curve fit from
%#               resistance test data using Froude Numer as input values.
%# 
%# Parameters :  rawData    = Raw measurement data
%#
%# Return     :  resistance  = (array)   Resistance curve
%# 
%# Examples of Usage: 
%# 
%#    >> rawData     = [ 5 6 7 8 9 10 11 12 13 14 ]; 
%#    >> [ans1]      = calBHResistanceBasedOnFr(Froude_Numbers)
%#    ans1           = (array)
%#
%# ------------------------------------------------------------------------

function [resistance] = calBHResistanceBasedOnFr(Froude_Numbers)

%# Array size -------------------------------------------------------------

[m,n] = size(Froude_Numbers);

%# Results array columns:
    %[1]  Froude length number (-)
    %[2]  Resistance           (N)

%# Results array ----------------------------------------------------------

ResultsArray = [];
for k=1:m
    FN                = Froude_Numbers(k,1);
    ResultsArray(k,1) = FN;
    ResultsArray(k,2) = -7932.12*FN^5+13710.12*FN^4-9049.96*FN^3+2989.46*FN^2-386.61*FN+18.6;
end

%# Function output --------------------------------------------------------

resistance = ResultsArray;