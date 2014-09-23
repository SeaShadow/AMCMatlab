%# ------------------------------------------------------------------------
%# Pumpcurve LJ120E jet
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  September 23, 2014
%#
%# Description:  Pumpcurve analysis for different RPM in full scale.
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  23/09/2014 - File creation
%#               dd/mm/yyyy - ...
%#
%# ------------------------------------------------------------------------

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


%# ************************************************************************
%# START Load LJ120E pumpcurve data (variable name is LJ120EPCData)
%# ------------------------------------------------------------------------
if exist('LJ120EPumpcurveData568RPM.mat', 'file') == 2
    %# Load file into LJ120EPCData variable
    
    %# Waterjet details:
        % Full scale data
        % Shaft speed:      568 RPM
        DefaultPCShaftSpeedRPM = 568;
        DefaultPCShaftSpeedRPS = DefaultPCShaftSpeedRPM/60;
        % Inlet diameter:   1.2m
    
    %# Columns:
        %[1]  Flow coefficient                          (-)
        %[2]  Head coefficient                          (-)
        %[3]  Pump efficiency                           (-)
        %[4]  NPSH (Net positive suction head) 1%/H     (-)
        %[5]  Volume flow rate                          (m^3/s)
        %[6]  Pump head                                 (-)
    
    load('LJ120EPumpcurveData568RPM.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (LJ120EPumpcurveData568RPM.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load LJ120E pumpcurve data (variable name is LJ120EPCData)
%# ************************************************************************


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 18.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = (((0.585*10^(-3))*(ttwatertemp-12)-0.03361)*(ttwatertemp-12)+1.235)*10^(-6); % Model scale kinetic viscosity at X (see ttwatertemp) degrees following ITTC (m2/s)
%MSKinVis            = 0.00000104125125;       % Model scale kinetic viscosity at 18.5C (m^2/s)
FSKinVis            = 0.0000011581;           % Full scale kinetic viscosity           (m^2/s)
freshwaterdensity   = 1000;                   % Model scale water density        (Kg/m^3)
saltwaterdensity    = 1025;                   % Salt water scale water density   (Kg/m^3)
distbetwposts       = 1150;                   % Distance between carriage posts  (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio  (-)

% Form factors and correlaction coefficient
FormFactor = 1.18;                            % Form factor (1+k)
CorrCoeff  = 0;                               % Correlation coefficient, Ca

% Waterjet constants (FS = full scale and MS = model scale)

% Pump (inlet) diameter, Dp, (m)
FS_PumpDia     = 1.2;
%MS_PumpDia     = 0.056;
MS_PumpDia     = FS_PumpDia/FStoMSratio;

% Effective nozzle diameter, Dn, (m)
FS_EffNozzDia  = 0.72;
%MS_EffNozzDia  = 0.033;
MS_EffNozzDia  = FS_EffNozzDia/FStoMSratio;

% Nozzle area, An, (m^2)
FS_NozzArea    = 0.4072;
%MS_NozzArea    = 0.00087;
MS_NozzArea    = ((FS_EffNozzDia/2)/FStoMSratio)^2*pi;

% Impeller diameter, Di, (m)
FS_ImpDia      = 1.582;
%MS_ImpDia      = 0.073;
MS_ImpDia      = FS_ImpDia/FStoMSratio;

% Pump inlet area, A4, (m^2)
FS_PumpInlArea = 1.99;
MS_PumpInlArea = 0.004;

% Pump maximum area, A5, (m^2)
FS_PumpMaxArea = 0.67;
MS_PumpMaxArea = 0.001;

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl           = 4.30;                          % Model length waterline          (m)
MSwsa           = 1.501;                         % Model scale wetted surface area (m^2)
MSdraft         = 0.133;                         % Model draft                     (m)
MSAx            = 0.024;                         % Model area of max. transverse section (m^2)
BlockCoeff      = 0.592;                         % Mode block coefficient          (-)
FSlwl           = MSlwl*FStoMSratio;             % Full scale length waterline     (m)
FSwsa           = MSwsa*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft         = MSdraft*FStoMSratio;           % Full scale draft                (m)

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ////////////////////////////////////////////////////////////////////////


%# ************************************************************************
%# START Extrapolate to other RPM values
%# ------------------------------------------------------------------------

%# Model scale shaft speeds (TG at FD for TG=pQj(vj-vi)
MSPortShaftRPM = [2640];
MSStbdShaftRPM = [2640];
MSAvgShaftRPM  = [2640];

% MSPortShaftRPM = [1745.733 1853.208 1983.190 2088.459 2201.762 2285.104 2370.432 2497.063 2658.391];
% MSStbdShaftRPM = [1745.733 1853.208 1983.190 2088.459 2201.762 2285.104 2370.432 2497.063 2658.391];
% MSAvgShaftRPM  = [1745.733 1853.208 1983.190 2088.459 2201.762 2285.104 2370.432 2497.063 2658.391];

% Array sizes
[m,n]   = size(LJ120EPCData);
[mp,np] = size(MSPortShaftRPM);
[ms,ns] = size(MSStbdShaftRPM);
[ma,na] = size(MSAvgShaftRPM);

%# Loop through shaft speeds
resultsArray = [];
pcArray      = [];
for k=1:np
    
    [mra,nra] = size(resultsArray);
    
    % Define MS and FS shaft speed variables
    ShaftSpeed   = MSPortShaftRPM(k);
    MSShaftSpeed = ShaftSpeed;
    FSShaftSpeed = MSShaftSpeed/sqrt(FStoMSratio);
    
    % Model scale
    MSShaftRPM   = MSShaftSpeed;
    MSShaftRPS   = MSShaftSpeed/60;
    
    % Full scale
    FSShaftRPM   = FSShaftSpeed;
    FSShaftRPS   = FSShaftSpeed/60;
    
    %# ////////////////////////////////////////////////////////////////////
    %# CREATE RESULTS ARRAY
    %# ////////////////////////////////////////////////////////////////////
    
    %# Add results to dedicated array for simple export
    %# Columns:
        %[1]  Speed number                              (#)
        %[2]  Model scale (MS) shaft speed              (RPM)
        %[3]  Model scale (MS) shaft speed              (RPS)
        %[4]  Full scale (FS) shaft speed               (RPM)
        %[5]  Full scale (FS) shaft speed               (RPS)
        %[6]  Volume flow rate (QJ)                     (m^3/s)
        %[7]  Pump head (H35)                           (-)
        %[8]  Flow coefficient                          (-)
        %[9]  Head coefficient                          (-)
        %[10] Pump efficiency                           (-)
        %[11] Mass flow rate                            (Kg/s)
        %[12] Jet velocity (vj)                         (m/s)
    % Power:
        %[13] Pump effective power (PPE)                (W)
        %[14] Delivered power (PD)                      (W)

    % Add the different pumpcurve values
    for kl=1:m
        pcArray(kl, 1)  = k;
        pcArray(kl, 2)  = MSShaftRPM;
        pcArray(kl, 3)  = MSShaftRPS;
        pcArray(kl, 4)  = FSShaftRPM;
        pcArray(kl, 5)  = FSShaftRPS;
        pcArray(kl, 6)  = LJ120EPCData(kl,4)/((DefaultPCShaftSpeedRPS/FSShaftRPS)*(FS_PumpDia/FS_PumpDia)^3);
        pcArray(kl, 7)  = LJ120EPCData(kl,5)/((DefaultPCShaftSpeedRPS/FSShaftRPS)^2*(FS_PumpDia/FS_PumpDia)^2);
        pcArray(kl, 8)  = pcArray(kl, 6)/(FSShaftRPS*FS_PumpDia^3);
        pcArray(kl, 9)  = (gravconst*pcArray(kl,7))/(FSShaftRPS*FS_PumpDia)^2;
        pcArray(kl, 10) = LJ120EPCData(kl,3);
        pcArray(kl, 11) = pcArray(kl, 6)*saltwaterdensity;
        pcArray(kl, 12) = pcArray(kl, 6)/FS_NozzArea;
        pcArray(kl, 13) = saltwaterdensity*gravconst*pcArray(kl, 6)*pcArray(kl, 7);
        pcArray(kl, 14) = pcArray(kl, 13)/LJ120EPCData(kl,3);
    end
    
    % Combine arrays
    resultsArray = [resultsArray;pcArray];
end

%# ------------------------------------------------------------------------
%# END Extrapolate to other RPM values
%# ************************************************************************


%# ************************************************************************
%# START: Write results to DAT and TXT
%# ------------------------------------------------------------------------
%M = resultsArray;
%csvwrite('resultsArray.dat', M)                                     % Export matrix M to a file delimited by the comma character
%dlmwrite('resultsArray.txt', M, 'delimiter', '\t', 'precision', 4)  % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
%# ------------------------------------------------------------------------
%# END: Write results to DAT and TXT
%# ************************************************************************


%# ************************************************************************
%# Clear variables
%# ************************************************************************
clearvars allPlots k kl m n mp np ms ns ma na
clearvars ShaftSpeed MSShaftSpeed FSShaftSpeed
clearvars ttlength ttwidth ttwaterdepth ttcsa ttwatertemp gravconst MSKinVis FSKinVis freshwaterdensity saltwaterdensity distbetwposts
clearvars FStoMSratio FormFactor CorrCoeff FS_PumpDia MS_PumpDia FS_EffNozzDia MS_EffNozzDia FS_NozzArea MS_NozzArea FS_ImpDia MS_ImpDia FS_PumpInlArea MS_PumpInlArea FS_PumpMaxArea MS_PumpMaxArea
clearvars MSlwl MSwsa MSdraft MSAx BlockCoeff FSlwl FSwsa FSdraft
