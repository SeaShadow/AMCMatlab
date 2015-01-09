%# ------------------------------------------------------------------------
%# function stats_avg( input )
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  January 9, 2015
%#
%# Function   :  Averaged repeated run data
%#
%# Description:  Average run data. Adjust RTm by subtracting turbulence
%#               stimulator resistance.
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
%#
%# CHANGES    :  09/01/2015 - Recoding of resistance coeff. calculations
%#
%# ------------------------------------------------------------------------

function [averagedArray] = stats_avg(repeatrunnos,results)


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

enableCommandWindowOutput = 0;    % Show command windows output

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


% Variables and array dimensions ------------------------------------------
R       = results;
[mr,nr] = size(repeatrunnos);
[m,n]   = size(results);

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

% Shorten variable name ---------------------------------------------------
RA = runArray;

% Stop execution if RA is empty -------------------------------------------
if length(RA) == 0
    return;
end


%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                    % Towing Tank: Length            (m)
ttwidth             = 3.5;                    % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                   % Towing Tank: Water depth       (m)
ttcsa               = ttwidth * ttwaterdepth; % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 17.5;                   % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                  % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;           % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;           % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s) -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;               % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;              % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                   % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                   % Full scale to model scale ratio               (-)

% Form factors and correlaction coefficient
FormFactor = 1.18;                            % Form factor (1+k)

% Correlation coefficients: No Ca (AMC), typical Ca (Bose 2008) and MARIN Ca
CorrCoeff  = 0.00035;                                           % Ca value as used by MARIN for JHSV testing (USE AS DEFAULT)

% Drag coefficient
% See: Oura, T. & Ikeda, Y. 2007, 'Maneuverability Of A Wavepiercing High-Speed
%      Catamaran At Low Speed In Strong Wind', Proceedings of the The
%      2nd International Conference on Marine Research and Transportation
%      28/6/2007, Ischia, Naples, Italy.
DragCoeff = 0.446;

% Roughness of hull surface (ks), typical value
RoughnessOfHullSurface = 150*10^(-6);

% Air density at 20 °C and 101.325 kPa
airDensity = 1.2041;

% FULL SCALE: Demihull, projected area of the ship above the water line
% to the transverse plane, AVS (m^2)
% Established using Incat GA drawing and extracting transverse area then scaling to full scale size.
FSProjectedArea = 341.5/2;

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500           = 4.30;                              % Model length waterline          (m)
MSwsa1500           = 1.501;                             % Model scale wetted surface area (m^2)
MSdraft1500         = 0.133;                             % Model draft                     (m)
MSAx1500            = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500      = 0.592;                             % Mode block coefficient          (-)
FSlwl1500           = MSlwl1500*FStoMSratio;             % Full scale length waterline     (m)
FSwsa1500           = MSwsa1500*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft1500         = MSdraft1500*FStoMSratio;           % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, -0.5 degrees by bow, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500bybow      = 4.33;                              % Model length waterline          (m)
MSwsa1500bybow      = 1.48;                              % Model scale wetted surface area (m^2)
MSdraft1500bybow    = 0.138;                             % Model draft                     (m)
MSAx1500bybow       = 0.025;                             % Model area of max. transverse section (m^2)
BlockCoeff1500bybow = 0.570;                             % Mode block coefficient          (-)
FSlwl1500bybow      = MSlwl1500bybow*FStoMSratio;        % Full scale length waterline     (m)
FSwsa1500bybow      = MSwsa1500bybow*FStoMSratio^2;      % Full scale wetted surface area  (m^2)
FSdraft1500bybow    = MSdraft1500bybow*FStoMSratio;      % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500bystern    = 4.22;                              % Model length waterline          (m)
MSwsa1500bystern    = 1.52;                              % Model scale wetted surface area (m^2)
MSdraft1500bystern  = 0.131;                             % Model draft                     (m)
MSAx1500bystern     = 0.024;                             % Model area of max. transverse section (m^2)
BlockCoeff1500bystern = 0.614;                           % Mode block coefficient          (-)
FSlwl1500bystern    = MSlwl1500bystern*FStoMSratio;      % Full scale length waterline     (m)
FSwsa1500bystern    = MSwsa1500bystern*FStoMSratio^2;    % Full scale wetted surface area  (m^2)
FSdraft1500bystern  = MSdraft1500bystern*FStoMSratio;    % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,500 tonnes, deep transom for prohaska runs, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1500prohaska    = 3.78;                             % Model length waterline          (m)
MSwsa1500prohaska    = 1.49;                             % Model scale wetted surface area (m^2)
MSdraft1500prohaska  = 0.133;                            % Model draft                     (m)
FSlwl1500prohaska    = MSlwl1500prohaska*FStoMSratio;    % Full scale length waterline     (m)
FSwsa1500prohaska    = MSwsa1500prohaska*FStoMSratio^2;  % Full scale wetted surface area  (m^2)
FSdraft1500prohaska  = MSdraft1500prohaska*FStoMSratio;  % Full scale draft                (m)
%# ////////////////////////////////////////////////////////////////////////

%# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%# CONDITION: 1,804 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804          = 4.22;                               % Model length waterline          (m)
MSwsa1804          = 1.68;                               % Model scale wetted surface area (m^2)
MSdraft1804        = 0.153;                              % Model draft                     (m)
MSAx1804           = 0.028;                              % Model area of max. transverse section (m^2)
BlockCoeff1804     = 0.631;                              % Mode block coefficient          (-)
FSlwl1804          = MSlwl1804*FStoMSratio;              % Full scale length waterline     (m)
FSwsa1804          = MSwsa1804*FStoMSratio^2;            % Full scale wetted surface area  (m^2)
FSdraft1804        = MSdraft1804*FStoMSratio;            % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, -0.5 degrees by bow, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bybow     = 4.31;                               % Model length waterline          (m)
MSwsa1804bybow     = 1.66;                               % Model scale wetted surface area (m^2)
MSdraft1804bybow   = 0.157;                              % Model draft                     (m)
MSA1804bybow      = 0.030;                               % Model area of max. transverse section (m^2)
BlockCoeff1804bybow = 0.603;                             % Mode block coefficient          (-)
FSlwl1804bybow     = MSlwl1804bybow*FStoMSratio;         % Full scale length waterline     (m)
FSwsa1804bybow     = MSwsa1804bybow*FStoMSratio^2;       % Full scale wetted surface area  (m^2)
FSdraft1804bybow   = MSdraft1804bybow*FStoMSratio;       % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# CONDITION: 1,804 tonnes, 0.5 degrees by stern, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl1804bystern   = 4.11;                               % Model length waterline          (m)
MSwsa1804bystern   = 1.70;                               % Model scale wetted surface area (m^2)
MSdraft1804bystern = 0.151;                              % Model draft                     (m)
MSA1804bystern     = 0.028;                              % Model area of max. transverse section (m^2)
BlockCoeff1804bystern = 0.657;                           % Mode block coefficient          (-)
FSlwl1804bystern   = MSlwl1804bystern*FStoMSratio;       % Full scale length waterline     (m)
FSwsa1804bystern   = MSwsa1804bystern*FStoMSratio^2;     % Full scale wetted surface area  (m^2)
FSdraft1804bystern = MSdraft1804bystern*FStoMSratio;     % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


% Split results array based on column 11 (Froude Length Number) -----------
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
%[8]  Model Averaged drag                                                      (grams)
%[9]  Model (Rtm) Total resistance                                             (N)
%[10] Model (CTtm) Total resistance Coefficient                                (-)
%[11] Model Froude length number                                               (-)
%[12] Model Heave                                                              (mm)
%[13] Model Trim                                                               (Degrees)
%[14] Equivalent full scale speed                                              (m/s)
%[15] Equivalent full scale speed                                              (knots)
%[16] Model (Rem) Reynolds Number                                              (-)
%[17] Model (CFm) Frictional Resistance Coefficient (ITTC'57)                  (-)
%[18] Model (CFm) Frictional Resistance Coefficient (Grigson)                  (-)
%[19] Model (CRm) Residual Resistance Coefficient                              (-)
%[20] Model (PEm) Model Effective Power                                        (W)
%[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
%[22] Full Scale (Res) Reynolds Number                                         (-)
%[23] Full Scale (CFs) Frictional Resistance Coefficient (ITTC'57)             (-)
%[24] Full Scale (CTs) Total resistance Coefficient                            (-)
%[25] Full Scale (RTs) Total resistance (Rt)                                   (N)
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

% Added: 15/12/2014
%[56] Full Scale (CFs) Frictional Resistance Coefficient (Grigson)             (-)

% Added: 09/01/2015
%[57] Full Scale (CRs) Residual Resistance Coefficient                         (-)

for m=1:ma
    
    %# Array size
    [mcond,ncond] = size(A{m});

    %# Run conditions
    RunCond = mean(A{m}(:,28));
    
    %# Set particulars based on condition ---------------------------------
    if RunCond == 1
        if enableCommandWindowOutput == 1
            disp('Cond. 1 (Turb-studs): Bare-hull');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 2
        if enableCommandWindowOutput == 1
            disp('Cond. 2 (Turb-studs): 1st row');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 3
        if enableCommandWindowOutput == 1
            disp('Cond. 3 (Turb-studs): 1st and 2nd row');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 4
        if enableCommandWindowOutput == 1
            disp('Cond. 4 (Trim-tab): 5 deg., level stat. trim');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 5
        if enableCommandWindowOutput == 1
            disp('Cond. 5 (Trim-tab): 0 deg., level stat. trim');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 6
        if enableCommandWindowOutput == 1
            disp('Cond. 6 (Trim-tab): 10 deg., level stat. trim');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 7
        if enableCommandWindowOutput == 1
            disp('Cond. 7 (Resistance): 1,500t, level');
        end
        MSlwl    = MSlwl1500;
        MSwsa    = MSwsa1500;
        MSdraft  = MSdraft1500;
        FSlwl    = FSlwl1500;
        FSwsa    = FSwsa1500;
        FSdraft  = FSdraft1500;
    elseif RunCond == 8
        if enableCommandWindowOutput == 1
            disp('Cond. 8 (Resistance): 1,500t, -0.5 deg. bow');
        end
        MSlwl    = MSlwl1500bybow;
        MSwsa    = MSwsa1500bybow;
        MSdraft  = MSdraft1500bybow;
        FSlwl    = FSlwl1500bybow;
        FSwsa    = FSwsa1500bybow;
        FSdraft  = FSdraft1500bybow;
    elseif RunCond == 9
        if enableCommandWindowOutput == 1
            disp('Cond. 9 (Resistance): 1,500t, 0.5 deg. stern');
        end
        MSlwl    = MSlwl1500bystern;
        MSwsa    = MSwsa1500bystern;
        MSdraft  = MSdraft1500bystern;
        FSlwl    = FSlwl1500bystern;
        FSwsa    = FSwsa1500bystern;
        FSdraft  = FSdraft1500bystern;
    elseif RunCond == 10
        if enableCommandWindowOutput == 1
            disp('Cond. 10 (Resistance): 1,804t, level');
        end
        MSlwl    = MSlwl1804;
        MSwsa    = MSwsa1804;
        MSdraft  = MSdraft1804;
        FSlwl    = FSlwl1804;
        FSwsa    = FSwsa1804;
        FSdraft  = FSdraft1804;
    elseif RunCond == 11
        if enableCommandWindowOutput == 1
            disp('Cond. 11 (Resistance): 1,804t, -0.5 deg. bow');
        end
        MSlwl    = MSlwl1804bybow;
        MSwsa    = MSwsa1804bybow;
        MSdraft  = MSdraft1804bybow;
        FSlwl    = FSlwl1804bybow;
        FSwsa    = FSwsa1804bybow;
        FSdraft  = FSdraft1804bybow;
    elseif RunCond == 12
        if enableCommandWindowOutput == 1
            disp('Cond. 12 (Resistance): 1,804t, 0.5 deg. stern');
        end
        MSlwl    = MSlwl1804bystern;
        MSwsa    = MSwsa1804bystern;
        MSdraft  = MSdraft1804bystern;
        FSlwl    = FSlwl1804bystern;
        FSwsa    = FSwsa1804bystern;
        FSdraft  = FSdraft1804bystern;
    elseif RunCond == 13
        if enableCommandWindowOutput == 1
            disp('Cond. 13 (Prohaska): 1,500t, deep transom');
        end
        MSlwl    = MSlwl1500prohaska;
        MSwsa    = MSwsa1500prohaska;
        MSdraft  = MSdraft1500prohaska;
        FSlwl    = FSlwl1500prohaska;
        FSwsa    = FSwsa1500prohaska;
        FSdraft  = FSdraft1500prohaska;
    else
        disp('Error: Unspecified Condition!!!!');
    end
    
    %# --------------------------------------------------------------------
    %# Model scale
    %# --------------------------------------------------------------------
    
    % Speed, LVDTs, and drag
    MSSpeed   = mean(A{m}(:,5));                            % (m/s)
    MSFwdLVDT = mean(A{m}(:,6));                            % (mm)
    MSAftLVDT = mean(A{m}(:,7));                            % (mm)
    MSDrag    = mean(A{m}(:,8));                            % (grams)
    
    % Heave and trim
    MSHeave   = (MSFwdLVDT+MSAftLVDT)/2;                    % (mm)
    MSTrim    = atand((MSFwdLVDT-MSAftLVDT)/distbetwposts); % (deg)
    
    % Froude length number
    MSFroude  = MSSpeed/sqrt(gravconst*MSlwl);
    
    % Reynolds number
    MSReynoldsNo = (MSSpeed*MSlwl)/MSKinVis;
    
    % Resistance and resistance coefficient
    MSRT = (MSDrag/1000)*gravconst;
    if any(4:12==RunCond)
        % Turbulence reduction based on EoF as shown in analysis_stats.m (seee Turb Stim Plot)
        TSReduction = 3.1638*MSFroude-0.4031;
        % Only apply TS correction if value > 0 (due to EoF)
        if TSReduction > 0
            MSRT = MSRT-TSReduction;
        else
            MSRT = MSRT;
        end
    else
        MSRT = MSRT;
    end % any(4:12==RunCond)
    MSCT = MSRT/(0.5*freshwaterdensity*MSwsa*MSSpeed^2);
    
    % ITTC'57 and Grigson frictional resistance coefficients
    MSCFITTC57 = 0.075/(log10(MSReynoldsNo)-2)^2;
    if MSReynoldsNo < 10000000
        MSCFGrigson = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
    else
        MSCFGrigson = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
    end
    
    % Residual resistance coefficient
    MSCR = MSCT-(FormFactor*MSCFGrigson);
    
    % Effective and brake power
    MSPe = MSSpeed*MSRT;                                    % (W)
    MSPb = MSPe/0.5;                                        % (W)
    
    %# --------------------------------------------------------------------
    %# Full scale
    %# --------------------------------------------------------------------
    
    % Speed
    FSSpeed      = MSSpeed*sqrt(FStoMSratio);
    
    % Reynolds number
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;
    
    % ITTC'57 and Grigson frictional resistance coefficients
    FSCFITTC57 = 0.075/(log10(FSReynoldsNo)-2)^2;
    if FSReynoldsNo < 10000000
        FSCFGrigson = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2);
    else
        FSCFGrigson = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3);
    end
    
    % Roughness allowance, correlation allowance and air resistance coefficient
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSwsa));        
    
    % Residual resistance coefficient
    FSCR = MSCR;
    
    % Resistance and resistance coefficient
    FSCT = FormFactor*FSCFGrigson+FSRoughnessAllowance+FSCorrelelationCoeff+FSCR+FSAirResistanceCoeff;
    FSRT = 0.5*saltwaterdensity*(FSSpeed^2)*FSwsa*FSCT;
    
    % Effective and brake power
    FSPe = FSSpeed*FSRT;                                    % (W)
    FSPb = FSPe/0.5;                                        % (W)    
    
    %# --------------------------------------------------------------------
    %# Add values to averaged Array
    %# --------------------------------------------------------------------
    
    %# Not really needed here ---------------------------------------------
    
    %[1]  Run No.                                                                  (-)
    averagedArray(m,1)  = 0;
    
    %[2]  FS                                                                       (Hz)
    averagedArray(m,2)  = 0;
    
    %[3]  No. of samples                                                           (-)
    averagedArray(m,3)  = 0;
    
    %[4]  Record time                                                              (s)
    averagedArray(m,4)  = 0;
    
    %# Averaged repated runs of sensors -----------------------------------
    
    %[5]  Model Averaged speed                                                     (m/s)
    averagedArray(m,5)  = MSSpeed;
    
    %[6]  Model Averaged fwd LVDT                                                  (m)
    averagedArray(m,6)  = MSFwdLVDT;
    
    %[7]  Model Averaged aft LVDT                                                  (m)
    averagedArray(m,7)  = MSAftLVDT;
    
    %[8]  Model Averaged drag                                                      (grams)
    averagedArray(m,8)  = MSDrag;
    
    %# Model scale resistance and resistance coefficient ------------------
    
    %[9]  Model (Rtm) Total resistance                                             (N)    
    averagedArray(m,9)  = MSRT;
    
    %[10] Model (CTtm) Total resistance Coefficient                                (-)
    averagedArray(m,10) = MSCT;
    
    %# Froude length number -----------------------------------------------
    
    % Round averaged speed to two (2) decimals only
    MSroundedSpeed = str2num(sprintf('%.2f',MSSpeed));
    
    % Calculate Froude length number
    MSFrRounded    = str2num(sprintf('%.2f',MSroundedSpeed/sqrt(gravconst*MSlwl)));
    
    %[11] Model Froude length number                                               (-)
    averagedArray(m,11) = MSFrRounded;
    
    %# Model heave and running trim ---------------------------------------
    
    %[12] Model Heave                                                              (mm)
    averagedArray(m,12) = MSHeave;
    
    %[13] Model Trim                                                               (Degrees)
    averagedArray(m,13) = MSTrim;
    
    %# Full scale speed in m/s and knots ----------------------------------
    
    %[14] Equivalent full scale speed                                              (m/s)    
    averagedArray(m,14) = FSSpeed;
    
    %[15] Equivalent full scale speed                                              (knots)    
    averagedArray(m,15) = FSSpeed/0.5144;
    
    %# Model scale Reynolds numner ----------------------------------------
    
    %[16] Model (Rem) Reynolds Number                                              (-)
    averagedArray(m,16) = MSReynoldsNo;
    
    %# Model scale ITTC'57 and Grigson frictional resistance coefficient --
    
    %[17] Model (CFm) Frictional Resistance Coefficient (ITTC'57)                  (-)    
    averagedArray(m,17) = MSCFITTC57;
    
    %[18] Model (CFm) Frictional Resistance Coefficient (Grigson)                  (-)    
    averagedArray(m,18) = MSCFGrigson;
    
    %# Model scale residual resistance coefficient ------------------------
    
    %[19] Model (CRm) Residual Resistance Coefficient                              (-)
    averagedArray(m,19) = MSCR;
    
    %# Model scale shaft and brake power ----------------------------------
    
    %[20] Model (PEm) Model Effective Power                                        (W)
    averagedArray(m,20) = MSPe;
    
    %[21] Model (PBm) Model Brake Power (using 50% prop. efficiency estimate)      (W)
    averagedArray(m,21) = MSPb;
    
    %# Full scale Reynolds numner -----------------------------------------
    
    %[22] Full Scale (Res) Reynolds Number                                         (-)
    averagedArray(m,22) = mean(A{m}(:,22));
    
    %# Model scale ITTC'57 frictional resistance coefficient --------------    
    
    %[23] Full Scale (CFs) Frictional Resistance Coefficient (ITTC'57)             (-)
    averagedArray(m,23) = FSCFITTC57;
    
    %# Full scale resistance and resistance coefficient -------------------
    
    %[24] Full Scale (CTs) Total resistance Coefficient                            (-)
    averagedArray(m,24) = FSCT;
    
    %[25] Full Scale (RTs) Total resistance (Rt)                                   (N)
    averagedArray(m,25) = FSRT;
    
    %# Full scale shaft and brake power -----------------------------------
    
    %[26] Full Scale (PEs) Model Effective Power                                   (W)
    averagedArray(m,26) = FSPe;
    
    %[27] Full Scale (PBs) Model Brake Power (using 50% prop. efficiency estimate) (W)
    averagedArray(m,27) = FSPb;
    
    %# Run condition ------------------------------------------------------
    
    %[28] Run condition                                                            (-)
    averagedArray(m,28) = mean(A{m}(:,28));
    
    %# Speed: Min, max and mean values ------------------------------------
    
    %[29] SPEED: Minimum value                                                     (m/s)
    averagedArray(m,29) = mean(A{m}(:,29));
    
    %[30] SPEED: Maximum value                                                     (m/s)
    averagedArray(m,30) = mean(A{m}(:,30));
    
    %[31] SPEED: Average value                                                     (m/s)
    averagedArray(m,31) = mean(A{m}(:,31));
    
    %[32] SPEED: Percentage (max.-avg.) to max. value (exp. 3%)                    (m/s)
    averagedArray(m,32) = mean(A{m}(:,32));
    
    %# LVDT (Fwd): Min, max and mean values -------------------------------
    
    %[33] LVDT (FWD): Minimum value                                                (mm)
    averagedArray(m,33) = mean(A{m}(:,33));
    
    %[34] LVDT (FWD): Maximum value                                                (mm)
    averagedArray(m,34) = mean(A{m}(:,34));
    
    %[35] LVDT (FWD): Average value                                                (mm)
    averagedArray(m,35) = mean(A{m}(:,35));
    
    %[36] LVDT (FWD): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
    averagedArray(m,36) = mean(A{m}(:,36));
    
    %[37] LVDT (AFT): Minimum value                                                (mm)
    averagedArray(m,37) = mean(A{m}(:,37));
    
    %# LVDT (Aft): Min, max and mean values -------------------------------
    
    %[38] LVDT (AFT): Maximum value                                                (mm)
    averagedArray(m,38) = mean(A{m}(:,38));
    
    %[39] LVDT (AFT): Average value                                                (mm)
    averagedArray(m,39) = mean(A{m}(:,39));
    
    %[40] LVDT (AFT): Percentage (max.-avg.) to max. value (exp. 3%)               (mm)
    averagedArray(m,40) = mean(A{m}(:,40));
    
    %# Drag: Min, max and mean values -------------------------------------    
    
    %[41] DRAG: Minimum value                                                      (g)
    averagedArray(m,41) = mean(A{m}(:,41));
    
    %[42] DRAG: Maximum value                                                      (g)
    averagedArray(m,42) = mean(A{m}(:,42));
    
    %[43] DRAG: Average value                                                      (g)
    averagedArray(m,43) = mean(A{m}(:,43));
    
    %[44] DRAG: Percentage (max.-avg.) to max. value (exp. 3%)                     (g)
    averagedArray(m,44) = mean(A{m}(:,44));
    
    %# Standard deviations of repeated runs -------------------------------
    
    %[45] SPEED: Standard deviation                                                (m/s)
    averagedArray(m,45) = std(A{m}(:,45),1);
    
    %[46] LVDT (FWD): Standard deviation                                           (mm)
    averagedArray(m,46) = std(A{m}(:,46),1);
    
    %[47] LVDT (AFT): Standard deviation                                           (mm)
    averagedArray(m,47) = std(A{m}(:,47),1);
    
    %[48] DRAG: Standard deviation                                                 (g)    
    averagedArray(m,48) = std(A{m}(:,48),1);
    
    %[49] SPEED: Mean of standard deviation                                        (-)
    averagedArray(m,49) = averagedArray(m,45)/sqrt(mcond);
    
    %[50] LVDT (FWD): Mean of standard deviation                                   (-)
    averagedArray(m,50) = averagedArray(m,46)/sqrt(mcond);
    
    %[51] LVDT (AFT): Mean of standard deviation                                   (-)
    averagedArray(m,51) = averagedArray(m,47)/sqrt(mcond);
    
    %[52] DRAG: Mean of standard deviation                                         (-)
    averagedArray(m,52) = averagedArray(m,48)/sqrt(mcond);
    
    %# Number of repeated runs --------------------------------------------
    
    %[53] Number how many times run has been repeated                              (-)
    averagedArray(m,53) = mcond;
    
    %# Newly added fields -------------------------------------------------
    
    % Added: 11/12/2014, Multiplied CTm data by 1000 for better readibility
    %[54] CTm: Standard deviation
    C = A{m}(:,10);
    Raw_Data = num2cell(C);
    Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false);
    C = cell2mat(Raw_Data);
    averagedArray(m,54) = std(C,1);
    
    % Added: 12/12/2014, Running trim
    %[55] Trim: Standard deviation                                                 (deg)
    averagedArray(m,55) = std(A{m}(:,13),1);
    
    % Added: 15/12/2014
    %[56] Full Scale (CFs) Frictional Resistance Coefficient (Grigson)             (-)
    averagedArray(m,56) = FSCFGrigson;
    
    % Added: 09/01/2015
    %[57] Full Scale (CRs) Residual Resistance Coefficient                         (-)
    averagedArray(m,56) = FSCR;
    
end