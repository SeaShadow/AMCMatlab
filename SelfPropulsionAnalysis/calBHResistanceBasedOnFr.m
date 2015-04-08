%# ------------------------------------------------------------------------
%# function [resistance] = calBHResistanceBasedOnFr( input )
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  February 5, 2015
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

%# ************************************************************************
%# START Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%#       >> Default variable name: FullScaleRT_ITTC1978_2011
%# ------------------------------------------------------------------------
if exist('FullScaleRT_ITTC1978_2011.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('FullScaleRT_ITTC1978_2011.mat');
    %# Results array columns:
    %[1]  Froude length number                              (-)
    %[2]  Model speed                                       (m/s)
    %[3]  MS Reynolds number                                (-)
    %[4]  MS Total resistance (catamaran), RTm              (N)
    %[5]  MS Total resistance coeff., CTm                   (-)
    %[6]  GRIGSON:  MS Frictional resistance coeff., CFm    (-)
    %[7]  ITTC1957: MS Frictional resistance coeff., CFm    (-)
    %[8]  GRIGSON:  MS Residual resistance coeff., CRm      (-)
    %[9]  ITTC1957: MS Residual resistance coeff., CRm      (-)
    %[10] FS Ship speed                                     (m/s)
    %[11] FS Ship speed                                     (knots)
    %[12] FS Reynolds number                                (-)
    %[13] Roughness allowance, delta CF                     (-)
    %[14] Correlation coeff., Ca                            (-)
    %[15] FS Air resistance coefficient, CAAs               (-)
    %[16] GRIGSON:  FS Total resistance (catamaran), RTs    (N)
    %[17] ITTC1957: FS Total resistance (catamaran), RTs    (N)
    %[18] GRIGSON:  FS Total resistance coeff., CTs         (-)
    %[19] ITTC1957: FS Total resistance coeff., CTs         (-)
    %[20] GRIGSON:  FS Frictional resistance coeff., CFs    (-)
    %[21] ITTC1957: FS Frictional resistance coeff., CFs    (-)
    %[22] GRIGSON:  FS Residual resistance coeff., CRs      (-)
    %[23] ITTC1957: FS Residual resistance coeff., CRs      (-)
    %[24] GRIGSON:  FS Total resistance (catamaran), RTs    (kN)
    %[25] ITTC1957: FS Total resistance (catamaran), RTs    (kN)
    %[26] MS Total resistance (demihull), RTm               (N)
end
%# ------------------------------------------------------------------------
%# END Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%# ************************************************************************

%# Equation of fit (EoF) --------------------------------------------------
xres = FullScaleRT_ITTC1978_2011(:,1);
yres = FullScaleRT_ITTC1978_2011(:,26);

% Equation of fit for RTm vs. Fr
[fitobject,gof,output] = fit(xres,yres,'poly5');
cvalues = coeffvalues(fitobject);
cnames  = coeffnames(fitobject);
output  = formula(fitobject);

% TEST ONLY
%plot(fitobject,'k-',xres,yres,'*');
%disp(sprintf('Eqn. of fit, y = %s*x^5+%s*x^4+%s*x^3+%s*x^2+%s*x+%s, R^2=%s',sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.3f',cvalues(3)),sprintf('%.3f',cvalues(4)),sprintf('%.3f',cvalues(5)),sprintf('%.3f',cvalues(6)),sprintf('%.2f',gof.rsquare)))

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
    
    % Calculate resistance based on Equation of Fit of BH resistance data
    P1 = cvalues(1);
    P2 = cvalues(2);
    P3 = cvalues(3);
    P4 = cvalues(4);
    P5 = cvalues(5);
    P6 = cvalues(6);
    ResistanceByFit = P1*FN^5+P2*FN^4+P3*FN^3+P4*FN^2+P5*FN+P6;
    
    %ResultsArray(k,2) = -7932.12*FN^5+13710.12*FN^4-9049.96*FN^3+2989.46*FN^2-386.61*FN+18.6;
    ResultsArray(k,2) = ResistanceByFit;
end

%# Function output --------------------------------------------------------

resistance = ResultsArray;
