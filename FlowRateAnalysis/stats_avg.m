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

flowRate    = results(:,5);
kpStbd      = results(:,6);
kpPort      = results(:,7);
thrustStbd  = results(:,8);
thrustPort  = results(:,9);
torqueStbd  = results(:,10);
torquePort  = results(:,11);
speedStbd   = results(:,12);
speedPort   = results(:,13);
powerStbd   = results(:,14);
powerPort   = results(:,15);

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