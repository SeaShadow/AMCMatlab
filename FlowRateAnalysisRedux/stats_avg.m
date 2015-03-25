%# ------------------------------------------------------------------------
%# function stats_avg( input )
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 8, 2014
%#
%# Function   :  Average data
%#
%# Description:  Average run data
%#
%# Parameters :  propSys       = Prop. system: 1 = Port, 2 = Stbd
%#               setRPM        = Set motor RPM
%#               results       = results MxN array
%#
%# Return     :  averagedArray = Nx1 array
%#
%# Examples of Usage:
%#
%#    >> propSys         = 1;
%#    >> setRPM          = 500;
%#    >> results         = [1 2 3;2 3 4;5 6 7];
%#    >> [averagedArray] = stats_avg(propSys,row,results)
%#    ans = [1 2 3 4 5 6 7 8 9 10]
%#
%# ------------------------------------------------------------------------

function [averagedArray] = stats_avg(propSys,setRPM,results)

%# Results array size -----------------------------------------------------

[m,n] = size(results);

%# Constants --------------------------------------------------------------

scalingFactor = 21.6;                       % Full scale to model scale ratio
impellerDia    = (1200/scalingFactor)/1000; % Scaled impeller diameter (m)
% NOTE: 1200 mm = Inlet diameter not impeller diameter
fwDensity      = 1000;                      % Fresh water density      (Kg/m3)

nozzleDiaFs    = 720;                       % Full scale nozzle diameter (mm)
nozzleDiaMs    = nozzleDiaFs/scalingFactor; % Model scale nozzle diameter (mm)
nozzleAreaMs   = ((nozzleDiaMs/2)^2)*pi;    % Model scale nozzle area (mm2)
nozzleAreaMs   = nozzleAreaMs/10^6;         % Model scale nozzle area (m2)

%# Columns to variables ---------------------------------------------------

flowRate       = results(:,5);         % Flow rate                 (Kg/s)
kpStbd         = results(:,6);         % Stbd: Kiel probe          (V)
kpPort         = results(:,7);         % Port: Kiel probe          (V)
thrustStbd     = results(:,8);         % Stbd: Thrust              (N)
thrustPort     = results(:,9);         % Port: Thrust              (N)
torqueStbd     = results(:,10);        % Stbd: Torque              (Nm)
torquePort     = results(:,11);        % Port: Torque              (Nm)
speedStbd      = results(:,12);        % Stbd: Shaft speed         (PRM)
speedPort      = results(:,13);        % Port: Shaft speed         (RPM)
%powerStbd      = results(:,14);        % Stbd: Shaft power         (W)
%powerPort      = results(:,15);        % Port: Shaft power         (W)
massflowrate1  = results(:,16);        % Mass flow rate (1s only)             (Kg/s)
massflowrate2  = results(:,17);        % Mass flow rate (mean, 1s intervals)  (Kg/s)
massflowrate3  = results(:,18);        % Mass flow rate (overall, Q/t)        (Kg/s)
%differencemfrs = results(:,19);        % Diff. mass flow rate (mean, 1s intervals)/(overall, Q/t) (%)

%# Averaged array columns -------------------------------------------------

%# Columns:
    %[1]  Set shaft speed                       (RPM)
    %[2]  Prop. system                          (1 = Port, 2 = Stbd)
    %[3]  Measured shaft Speed STBD             (RPM)
    %[4]  Measured shaft Speed PORT             (RPM)
    %[5]  Mass Flow rate                        (Kg/s)
    %[6]  Kiel probe STBD                       (V)
    %[7]  Kiel probe PORT                       (V)
    %[8]  Thrust STBD                           (N)
    %[9]  Thrust PORT                           (N)
    %[10] Torque STBD                           (Nm)
    %[11] Torque PORT                           (Nm)
    %[12] Volumetric flow rate                  (m3/s)
    %[13] Flow coefficient                      (-)
    %[14] Jet velocity                          (m/s)
%# Values added: 10/09/2014
    %[15] Mass Flow rate (1s only)              (Kg/s)
    %[16] Mass flow rate (mean, 1s intervals)   (Kg/s)
    %[17] Mass flow rate (overall, Q/t)         (Kg/s)

averagedArray = [];
averagedArray(:,1)  = setRPM;
averagedArray(:,2)  = propSys;
% Exception for runs 8-11 as channels (PORT/STBD) were switched in DAQ
if propSys == 1 && ismember(setRPM,[800 1000]) == 1
    averagedArray(:,3)  = round(mean(speedPort));
    averagedArray(:,4)  = round(mean(speedStbd));
else
    averagedArray(:,3)  = round(mean(speedStbd));
    averagedArray(:,4)  = round(mean(speedPort));
end
% averagedArray(:,3)  = mean(speedStbd);
% averagedArray(:,4)  = mean(speedPort);
averagedArray(:,5)  = mean(flowRate);
averagedArray(:,6)  = mean(kpStbd);
averagedArray(:,7)  = mean(kpPort);
averagedArray(:,8)  = mean(thrustStbd);
averagedArray(:,9)  = mean(thrustPort);
averagedArray(:,10) = mean(torqueStbd);
averagedArray(:,11) = mean(torquePort);

%# Volumetric flow rate (Qj = (? Qj)/?)
averagedArray(:,12) = averagedArray(:,5)/fwDensity;

%# Flow coefficient = Q / (n*D^3)
%# Where:   Q (m3/s)
%#          n (1/s)
%#          D (m)
if propSys == 1
    averagedArray(:,13) = averagedArray(:,12)/((averagedArray(:,4)/60)*(impellerDia^3));
elseif propSys == 2
    averagedArray(:,13) = averagedArray(:,12)/((averagedArray(:,3)/60)*(impellerDia^3));
else
    averagedArray(:,13) = 0;
end

%# Jet velocity (vj = Qj/An)
if propSys == 1 || propSys == 2
    averagedArray(:,14) = averagedArray(:,12)/nozzleAreaMs;
else
    averagedArray(:,14) = 0;
end

%# Mass Flow rate (1s only)
averagedArray(:,15) = mean(massflowrate1);

%# Mass flow rate (mean, 1s intervals)
averagedArray(:,16) = mean(massflowrate2);

%# Mass flow rate (overall, Q/t)
averagedArray(:,17) = mean(massflowrate3);
