%# ------------------------------------------------------------------------
%# function [resistance] = calBHResistanceBasedOnFrTempCorr( input )
%# ------------------------------------------------------------------------
%#
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  October 7, 2014
%#
%# Function   :  Resistance curve based on Froude Numbers (Fr)
%#
%# Description:  Calculate resistance curve based on curve fit from
%#               resistance test data using Froude Numer as input values.
%#               Apply temperature correction based on ITTC 7.5-02-03-01.4
%#               (2008), page 4. RES stands for Resistance Test and SPT
%#               for Self-Propulsion Test, MS for model scale and FS for
%#               full scale.
%#
%# Parameters :  Froude_Numbers  = (array)  Froude length numbers and speeds (-)
%#               Form_Factor     = (double) Form factor (1+k)                (-)
%#               WSA             = (double) Wetted surface area              (m^2)
%#               LWL             = (double) Length waterline                 (m)
%#
%# Return     :  resistance  = (array) Resistance curve
%#
%# Examples of Usage:
%#
%#    >> rawData     = [ 5 6 7 8 9 10 11 12 13 14 ];
%#    >> [ans1]      = calBHResistanceBasedOnFrTempCorr(Froude_Numbers,Form_Factor,WSA,LWL)
%#    ans1           = (array)
%#
%# ------------------------------------------------------------------------

function [resistance] = calBHResistanceBasedOnFrTempCorr(Froude_Numbers,Form_Factor,WSA,LWL)

%# Define variables (ITTC 7.5-02-01-03 (2008)) ----------------------------

%# TODO: Kinematic viscosity could be established by look up table and
%# dynamically read. Input would have to be extended by ResTemp and SPTTemp.

% Resistance test, water temperature 17.5 deg .C

RESKinVisc = 0.0000010675;
RESDensity = 998.6897;

% Self-propulsion test, water temperature 18.5 deg .C

SPTKinVisc = 0.0000010411;
SPTDensity = 998.5048;

%# Array size -------------------------------------------------------------
[m,n] = size(Froude_Numbers);

%# Results array ----------------------------------------------------------

%# Results array columns:
    %[1]  Froude length number             (-)
    %[2]  Resistance (uncorrected)         (N)
    %[3]  Resistance (corrected for temp.) (N) -> See ITTC 7.5-02-03-01.4 (2008)

% Loop through array with Froude length numbers ---------------------------

ResultsArray = [];
for k=1:m
    
    % Calculations
    ModelSpeed    = Froude_Numbers(k,2);
    
    RESReynoldsNr = (ModelSpeed*LWL)/RESKinVisc;
    SPTReynoldsNr = (ModelSpeed*LWL)/SPTKinVisc;
    
    % Write array
    FN                = Froude_Numbers(k,1);
    ResultsArray(k,1) = FN;
    ResistanceByFit   = -7932.12*FN^5+13710.12*FN^4-9049.96*FN^3+2989.46*FN^2-386.61*FN+18.6;
    ResultsArray(k,2) = ResistanceByFit;
    
    % Total resistance coeff., CT=Rtm/(0.5 p S V^2)
    RESCtm = ResistanceByFit/(0.5*RESDensity*WSA*ModelSpeed^2);
    SPTCtm = ResistanceByFit/(0.5*SPTDensity*WSA*ModelSpeed^2);
    
    % Frictional resistance coeff., CF=0.075/(Log10 Rnm-2)^2 or Grigson
    
    % ITTC'57 friction line
    %RESCfm = 0.075/(log10(RESReynoldsNr)-2)^2;
    %SPTCfm = 0.075/(log10(SPTReynoldsNr)-2)^2;
    
    % Grigson friction line
    MSReynoldsNo = RESReynoldsNr;
    if MSReynoldsNo < 10000000
        RESCfm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
    else
        RESCfm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
    end
    MSReynoldsNo = SPTReynoldsNr;
    if MSReynoldsNo < 10000000
        SPTCfm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
    else
        SPTCfm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
    end
    
    % Residual resistance coeff., CR=CT-CF, from resistance test
    Crm = RESCtm-RESCfm;
    
    ResultsArray(k,3) = (Form_Factor*SPTCfm+Crm)/(Form_Factor*RESCfm+Crm)*ResistanceByFit;
    
end

%# Function output --------------------------------------------------------

resistance = ResultsArray;