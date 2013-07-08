%# ------------------------------------------------------------------------
%# function stats_avg( input )
%# ------------------------------------------------------------------------
%# 
%# Author:       K. Zürcher (kzurcher@amc.edu.au)
%# Date:         July 1, 2013
%# 
%# Function   :  Average data
%# 
%# Description:  Average run data
%# 
%# Parameters :  propSys       = Prop. system: 1 = Port, 2 = Stbd, 3 = Combined
%#               setRPM        = Set motor RPM
%#               startRun      = Start run at X
%#               endRun        = End run at X
%#               results       = results MxN array
%#
%# Return     :  averagedArray = Nx1 array
%# 
%# Examples of Usage: 
%# 
%#    >> propSys         = 1; 
%#    >> setRPM          = 500;
%#    >> startRun        = 9;
%#    >> endRun          = 11;
%#    >> results         = [1 2 3;2 3 4;5 6 7]; 
%#    >> [averagedArray] = stats_avg(propSys,row,startRun,endRun,results)
%#    ans = [1 2 3 4 5 6 7 8 9 10]
%#
%# ------------------------------------------------------------------------

function [averagedArray] = stats_avg(propSys,setRPM,startRun,endRun,results)

%# Constants
scalingFactor = 21.6;                       % Full scale to model scale ratio
impellerDia    = (1200/scalingFactor)/1000; % Scaled impeller diameter (m)      
                                            % NOTE: 1200 mm = Inlet diameter not impeller diameter
fwDensity      = 1000;                      % Fresh water density      (Kg/m3)

nozzleDiaFs    = 720;                       % Full scale nozzle diameter (mm)
nozzleDiaMs    = nozzleDiaFs/scalingFactor; % Model scale nozzle diameter (mm)
nozzleAreaMs   = ((nozzleDiaMs/2)^2)*pi;    % Model scale nozzle area (mm2)
nozzleAreaMs   = nozzleAreaMs/10^6;         % Model scale nozzle area (m2)

%# Columns to variables
flowRate    = results(:,5);         % Flow rate                 (Kg/s)
kpStbd      = results(:,6);         % Stbd: Kiel probe          (V)
kpPort      = results(:,7);         % Port: Kiel probe          (V)
thrustStbd  = results(:,8);         % Stbd: Thrust              (N)
thrustPort  = results(:,9);         % Port: Thrust              (N)
torqueStbd  = results(:,10);        % Stbd: Torque              (Nm)
torquePort  = results(:,11);        % Port: Torque              (Nm)
speedStbd   = results(:,12);        % Stbd: Shaft speed         (PRM)
speedPort   = results(:,13);        % Port: Shaft speed         (RPM)
powerStbd   = results(:,14);        % Stbd: Shaft power         (W)
powerPort   = results(:,15);        % Port: Shaft power         (W)

%# Averaged array columns: 
    %[1]  Set motor RPM      (RPM)
    %[2]  Prop. system       >> 1 = Port, 2 = Stbd, 3 = Combined
    %[3]  Shaft Speed STBD   (RPM)
    %[4]  Shaft Speed PORT   (RPM)
    %[5]  Flow rate          (Kg/s)
    %[6]  Kiel probe STBD    (V)
    %[7]  Kiel probe PORT    (V)
    %[8]  Thrust STBD        (N)
    %[9]  Thrust PORT        (N)
    %[10] Torque STBD        (Nm)
    %[11] Torque PORT        (Nm)
    %[12] Power STBD         (W)
    %[13] Power PORT         (W)
    %[14] Flow coefficient   (-)
    %[15] Flow rate          (m3/s)
    %[16] Jet velocity       (m/s)
    %[17] Gross thrust       (m3/s)     >> Using Allisons equation
    %[18] Thrust coefficient (-)        >> Baseed on gross thrust
    
averagedArray = [];
averagedArray(:,1)  = setRPM;
averagedArray(:,2)  = propSys;
averagedArray(:,3)  = round(mean(speedStbd(startRun:endRun)));
averagedArray(:,4)  = round(mean(speedPort(startRun:endRun)));
averagedArray(:,5)  = mean(flowRate(startRun:endRun));
averagedArray(:,6)  = mean(kpStbd(startRun:endRun));
averagedArray(:,7)  = mean(kpPort(startRun:endRun));
averagedArray(:,8)  = mean(thrustStbd(startRun:endRun));
averagedArray(:,9)  = mean(thrustPort(startRun:endRun));
averagedArray(:,10) = mean(torqueStbd(startRun:endRun));
averagedArray(:,11) = mean(torquePort(startRun:endRun));
averagedArray(:,12) = mean(powerStbd(startRun:endRun));
averagedArray(:,13) = mean(powerPort(startRun:endRun));
%# Flow coefficient = Q / (n*D^3)
%# Where:   Q (m3/s)
%#          n (1/s)
%#          D (m)
if propSys == 1
    averagedArray(:,14) = (averagedArray(:,5)/fwDensity)/((averagedArray(:,4)/60)*(impellerDia^3));
elseif propSys == 2
    averagedArray(:,14) = (averagedArray(:,5)/fwDensity)/((averagedArray(:,3)/60)*(impellerDia^3));    
else
    averagedArray(:,14) = 0;
end
averagedArray(:,15) = averagedArray(:,5)/fwDensity;
if propSys == 1 || propSys == 2
    averagedArray(:,16) = averagedArray(:,15)/nozzleAreaMs;
else
    averagedArray(:,16) = 0;
end
if propSys == 1 || propSys == 2
    averagedArray(:,17) = averagedArray(:,5)*averagedArray(:,16);
else
    averagedArray(:,17) = 0;
end
if propSys == 1
    averagedArray(:,18) = averagedArray(:,17)/(fwDensity*((averagedArray(:,4)/60)^2)*impellerDia^4);
elseif propSys == 2    
    averagedArray(:,18) = averagedArray(:,17)/(fwDensity*((averagedArray(:,3)/60)^2)*impellerDia^4);
else
    averagedArray(:,18) = 0;
end