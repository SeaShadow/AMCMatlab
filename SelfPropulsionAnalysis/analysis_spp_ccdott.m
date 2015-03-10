%# ------------------------------------------------------------------------
%# Self-Propulsion: Test Analysis (SPP) - Using CCoTT method for SPP
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  March 10, 2015
%#
%# Test date  :  November 5 to November 18, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs CT    :  1-15    PST + DPT Calibration Test               (CT)
%# Runs RT    :  16-28   Resistance Test / Transom Streamlines    (RT)
%# Runs BLM   :  29-69   Boundary Layer Measurements              (BLM)
%# Runs SPP   :  70-110  Self-Propulsion Points                   (SPP)
%# Runs SPT   :  111-180 Self-Propulsion Test                     (SPT)
%#
%# Speeds (FR)    :  0.3-0.4 (18-24 knots)
%#
%# Description    :  Waterjet self-propulsion test based on test setups
%#                   using literature and ITTC.
%#
%# ITTC Guidelines:  7.5-02-02-03.1
%#                   7.5-02-02-03.2
%#                   7.5-02-02-03.3
%#
%# ------------------------------------------------------------------------
%#
%# SCRIPTS  :    => analysis.m        First iteration analysis
%#                                    ==> Creates resultsArray.dat
%#
%#               => analysis_calib.m  PST calibration run data
%#                                    ==> Creates resultsArrayCALIB.dat
%#
%#               => analysis_bl.m    Bondary layer measurements
%#                                    ==> Creates resultsArrayBL.dat
%#
%#               => analysis_spp.m    Self-propulsion points
%#                                    ==> Creates resultsArraySPP.dat
%#
%#               => analysis_spp_ccdott.m Self-propulsion points by CCDoTT
%#                                    ==> Creates resultsArraySPP_CCDoTT.dat
%#
%#               => analysis_spt.m    Self-propulsion test
%#                                    ==> Creates resultsArraySPT.dat
%#
%#               => analysis_avg.m    Averages self-propulsion test repeats
%#                                    ==> Creates avgResultsArray.dat
%#
%#               => analysis_ts.m    Time series data
%#                                    ==> Creates resultsArrayTS.dat
%#
%#               => analysis_fscomp.m  Full Scale Results Comparison
%#                                     ==> Uses fullScaleDataArray.dat
%#                                     ==> Uses SeaTrials1500TonnesCorrPower
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  16/09/2014 - Created new script
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


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

% Profiler
enableProfiler            = 0;    % Use profiler to show execution times

% Decide if June 2013 or September 2014 data is used for calculations
enableSept2014FRMValues   = 1;    % Use enable uses flow rate values established September 2014

% Plot titles, colours, etc.
enablePlotMainTitle       = 0;    % Show plot title in saved file
enablePlotTitle           = 0;    % Show plot title above plot
enableBlackAndWhitePlot   = 1;    % Show plot in black and white only
enableTowingForceFDPlot   = 1;    % Show towing force (FD)

% Scaled to A4 paper
enableA4PaperSizePlot     = 0;    % Show plots scale to A4 size

% Adjusted fitting for towing force vs. thrust plot and F at T=0 as well as
enableAdjustedFitting     = 1;    % Show adjusted fitting for speeds 6,8 and 9
enableCommandWindowOutput = 1;    % Show command window output

% Wake scaling with rudder componets
% If TRUE (1) wake scaling uses +(t+0.04)(1-(CFs/CFm)) part of equation
enableWakeScalingRudderComp = 0;  % Use rudder components in wake scaling

% Pump effective power, PPE
enablePPEEstPumpCurveHead   = 0;  % If TRUE use PPE = p g QJ H35 (ITTC) instead of PPE = (E7/nn)-niE1 (Bose 2008)

% Close all plots
enableCloseAllPlots         = 1;  % If TRUE all Matlab plots will be closed

% Check if Curve Fitting Toolbox is installed
% See: http://stackoverflow.com/questions/2060382/how-would-one-check-for-installed-matlab-toolboxes-in-a-script-function
v = ver;
toolboxes = setdiff({v.Name}, 'MATLAB');
ind = find(ismember(toolboxes,'Curve Fitting Toolbox'));
[mtb,ntb] = size(ind);

% IF ntb > 0 Curve Fitting Toolbox is installed
enableCurveFittingToolboxCurvePlot = 0;    % Show fit curves when using Curve Fitting Toolbox
if ntb > 0
    enableCurveFittingToolboxPlot  = 1;
    enableEqnOfFitPlot             = 0;
else
    enableCurveFittingToolboxPlot  = 0;
    enableEqnOfFitPlot             = 1;
end

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


%# ------------------------------------------------------------------------
%# GENERAL SETTINGS AND CONSTANTS
%# ------------------------------------------------------------------------

%# Test name --------------------------------------------------------------
testName = 'Waterjet Self-Propulsion Test';

% -------------------------------------------------------------------------
% Enable profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile on
end

%# -------------------------------------------------------------------------
%# Path where run directories are located
%# -------------------------------------------------------------------------
%runfilespath = 'D:\\Flow Rate MTB Backup\\KZ Flow Rate\\';
runfilespath = '..\\';      % Relative path from Matlab directory

%# -------------------------------------------------------------------------
%# GENERAL SETTINGS
%# -------------------------------------------------------------------------
Fs = 800;       % Sampling frequency = 800Hz

%# ************************************************************************
%# START CONSTANTS AND PARTICULARS
%# ------------------------------------------------------------------------

% On test date
ttlength            = 100;                       % Towing Tank: Length            (m)
ttwidth             = 3.5;                       % Towing Tank: Width             (m)
ttwaterdepth        = 1.45;                      % Towing Tank: Water depth       (m)
ttcsa               = ttwidth*ttwaterdepth;      % Towing Tank: Sectional area    (m^2)
ttwatertemp         = 18.5;                      % Towing Tank: Water temperature (degrees C)

% General constants
gravconst           = 9.806;                     % Gravitational constant           (m/s^2)
MSKinVis            = 0.0000010411;              % Model scale kinetic viscosity at 18.5 deg. C  (m^2/s)  -> See table in ITTC 7.5-02-01-03 (2008)
FSKinVis            = 0.0000010711;              % Full scale kinetic viscosity at 19.2 deg. C   (m^2/s)  -> See table in ITTC 7.5-02-01-03 (2008)
freshwaterdensity   = 998.5048;                  % Model scale water density at 18.5 deg. C      (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
saltwaterdensity    = 1025.0187;                 % Salt water scale water density at 19.2 deg. C (Kg/m^3) -> See table in ITTC 7.5-02-01-03 (2008)
distbetwposts       = 1150;                      % Distance between carriage posts               (mm)
FStoMSratio         = 21.6;                      % Full scale to model scale ratio               (-)

%# ************************************************************************
%# CONDITION: 1,500 tonnes, level static trim, trim tab at 5 degrees
%# ------------------------------------------------------------------------
MSlwl           = 4.30;                          % Model length waterline          (m)
MSwsa           = 1.501;                         % Model scale wetted surface area (m^2)
MSdraft         = 0.133;                         % Model draft                     (m)
MSAx            = 0.024;                         % Model area of max. transverse section (m^2)
BlockCoeff      = 0.592;                         % Mode block coefficient          (-)
AreaRatio       = MSAx/(ttwaterdepth*ttwidth);   % Area ratio                      (-)
FSlwl           = MSlwl*FStoMSratio;             % Full scale length waterline     (m)
FSwsa           = MSwsa*FStoMSratio^2;           % Full scale wetted surface area  (m^2)
FSdraft         = MSdraft*FStoMSratio;           % Full scale draft                (m)
%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************

% Form factor (by slow speed Prohaska runs)
FormFactor = 1.18;                            % Form factor (1+k)

% Correlation coefficients: No Ca (AMC), typical Ca (Bose 2008) and MARIN Ca
CorrCoeff  = 0.00035;                                           % Ca value as used by MARIN for JHSV testing (USE AS DEFAULT)
%CorrCoeff  = 0;                                                % Correlation coefficient, Ca as used by AMC
%CorrCoeff  = (105*((150*10^(-6))/FSlwl)^(1/3)-0.64)*10^(-3);   % Ca calculcation for typical value as shown in Bose (2008), equation 2-4, page 6

% Waterjet constants (FS = full scale and MS = model scale) ---------------

% Width factor (typical value, source??)
WidthFactor    = 1.3;

% Pump diameter, Dp, (m)
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

%# ************************************************************************
%# Start Boundary layer related constants
%# ------------------------------------------------------------------------

% Boundary layer: Power law factors (-)
% NOTE: See Matlab file "analysis_bl.m" for values
BLPLFactorArray  = [6.6467 6.6467 6.6467 6.6467 6.6467 6.6467 6.6467 6.6467 6.6467];

% Boundary layer: Thickness (m)
% NOTE: See Excel file "Run Sheet - Self-Propulsion Test.xlsx" WS "3 BL and wake fraction" for values
BLThicknessArray = [0.0452 0.0453 0.0451 0.0445 0.0436 0.0424 0.0408 0.0389 0.0367];

%# ------------------------------------------------------------------------
%# End Boundary layer related constants
%# ************************************************************************

% Installation efficiency (typical value)
InstEff = 1;

% ITTC 1978 Related Values ------------------------------------------------

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

%# ------------------------------------------------------------------------
%# END CONSTANTS AND PARTICULARS
%# ************************************************************************


%# -------------------------------------------------------------------------
%# Number of headerlines in DAT file
%# -------------------------------------------------------------------------
headerlines             = 39;  % Number of headerlines to data
headerlinesZeroAndCalib = 33;  % Number of headerlines to zero and calibration factors


%# ------------------------------------------------------------------------
%# Omit first 10 seconds of data due to acceleration
%# ------------------------------------------------------------------------

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from start)
startSamplePos    = 1;

% 10 seconds x sample frequency = 10 x 800 = 8000 samples (from end)
cutSamplesFromEnd = 0;


%# ************************************************************************
%# START FILE LOOP FOR RUNS startRun to endRun
%# ------------------------------------------------------------------------

%startRun = 70;      % Start run
%endRun   = 70;      % Stop run

startRun = 70;       % Start run
endRun   = 109;      % Stop run

%# ------------------------------------------------------------------------
%# END FILE LOOP FOR RUNS startRun to endRun
%# ************************************************************************


%# ************************************************************************
%# START DEFINE PLOT SIZE
%# ------------------------------------------------------------------------
%# Centimeters units
XPlot = 42.0;                           %# A3 paper size
YPlot = 29.7;                           %# A3 paper size
XPlotMargin = 1;                        %# left/right margins from page borders
YPlotMargin = 1;                        %# bottom/top margins from page borders
XPlotSize = XPlot - 2*XPlotMargin;      %# figure size on paper (widht & hieght)
YPlotSize = YPlot - 2*YPlotMargin;      %# figure size on paper (widht & hieght)
%# ------------------------------------------------------------------------
%# END DEFINE PLOT SIZE
%# ************************************************************************


%# ************************************************************************
%# START Load shaft speed list (variable name is shaftSpeedList by default)
%# ------------------------------------------------------------------------
if exist('shaftSpeedListRuns90to109.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('shaftSpeedListRuns90to109.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (shaftSpeedListRuns90to109.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load shaft speed list (variable name is shaftSpeedList by default)
%# ************************************************************************


%# ************************************************************************
%# START Full scale results
%# ------------------------------------------------------------------------
if exist('fullScaleDataArray_CCDoTT.dat', 'file') == 2
    %# Results array columns:
    % See 4. Extrapolation to full scale for column descriptions
    fullscaleresults = csvread('fullScaleDataArray_CCDoTT.dat');
    [mfsr,nfsr] = size(fullscaleresults);
    %# Remove zero rows
    fullscaleresults(all(fullscaleresults==0,2),:)=[];
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: File fullScaleDataArray_CCDoTT.dat does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    %break;
end
%# ------------------------------------------------------------------------
%# END Full scale results
%# ************************************************************************


%# ************************************************************************
%# START Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ------------------------------------------------------------------------
if exist('SeaTrials1500TonnesCorrPower.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('SeaTrials1500TonnesCorrPower.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (SeaTrials1500TonnesCorrPower.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ************************************************************************


%# ************************************************************************
%# START Shallow Water Sea Trials Data (variable name is SeaTrials1500TonnesCorrPowerShallowWater by default)
%# ------------------------------------------------------------------------
if exist('SeaTrials1500TonnesCorrPowerShallowWater.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('SeaTrials1500TonnesCorrPowerShallowWater.mat');
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for shaft speed data (SeaTrials1500TonnesCorrPowerShallowWater.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Shallow Water Sea Trials Data (variable name is SeaTrialsCorrectedPower by default)
%# ************************************************************************


%# ************************************************************************
%# START Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%#       >> Default variable name: FullScaleRT_ITTC1978_2011_Schuster_TempCorr
%# ------------------------------------------------------------------------
if exist('FullScaleRT_ITTC1978_2011_Schuster_TempCorr.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('FullScaleRT_ITTC1978_2011_Schuster_TempCorr.mat');
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
    ResResults = FullScaleRT_ITTC1978_2011_Schuster_TempCorr;
    clearvars FullScaleRT_ITTC1978_2011_Schuster_TempCorr
else
    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    %disp('WARNING: Required data file for resistance data (FullScaleRT_ITTC1978_2011_Schuster_TempCorr.mat) does not exist!');
    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
end
%# ------------------------------------------------------------------------
%# END Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%# ************************************************************************


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
    ResResultsUC = FullScaleRT_ITTC1978_2011;
    clearvars FullScaleRT_ITTC1978_2011
else
    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    %disp('WARNING: Required data file for resistance data (FullScaleRT_ITTC1978_2011_Schuster_TempCorr.mat) does not exist!');
    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
end
%# ------------------------------------------------------------------------
%# END Full Scale Resistance Results (Based on ITTC (2011) 7.5-02-03-01.4
%# ************************************************************************


%# ************************************************************************
%# START Kiel probe vs. mass flow rate (from analysis_stats.m)
%# ------------------------------------------------------------------------
SetMFRvsKPDataFilePath = '..\..\..\2014 August - Flow rate measuements REDUX\_Run files\_Matlab analysis\SummaryMFRSept2014Array.dat';
if exist(SetMFRvsKPDataFilePath, 'file') == 2
    % Load file into shaftSpeedList variable
    load(SetMFRvsKPDataFilePath);
    
    % Create polynomial 4 fit
    [fitobjectP,gofP,outputP]  = fit(SummaryMFRSept2014Array(:,2),SummaryMFRSept2014Array(:,3),'poly4');
    cvaluesMFRvsKPSept2014Port = coeffvalues(fitobjectP);
    
    % Check Equation of Fit
    %     if enableCommandWindowOutput == 1
    %         cval = cvaluesMFRvsKPSept2014Port;
    %         setDecimals1 = '%0.4f';
    %         setDecimals2 = '+%0.4f';
    %         setDecimals3 = '+%0.4f';
    %         setDecimals4 = '+%0.4f';
    %         setDecimals5 = '+%0.4f';
    %         if cval(1) < 0
    %             setDecimals1 = '%0.4f';
    %         end
    %         if cval(2) < 0
    %             setDecimals2 = '%0.4f';
    %         end
    %         if cval(3) < 0
    %             setDecimals3 = '%0.4f';
    %         end
    %         if cval(4) < 0
    %             setDecimals4 = '%0.4f';
    %         end
    %         if cval(5) < 0
    %             setDecimals5 = '%0.4f';
    %         end
    %         p1   = sprintf(setDecimals1,cval(1));
    %         p2   = sprintf(setDecimals2,cval(2));
    %         p3   = sprintf(setDecimals3,cval(3));
    %         p4   = sprintf(setDecimals4,cval(4));
    %         p5   = sprintf(setDecimals5,cval(5));
    %         gofrs = sprintf('%0.2f',gofP.rsquare);
    %         EoFEqn = sprintf('>> PORT Equation of Fit (EoF): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
    %         disp(EoFEqn);
    %     end
    
    % Create polynomial 4 fit
    [fitobjectS,gofS,outputS]  = fit(SummaryMFRSept2014Array(:,4),SummaryMFRSept2014Array(:,5),'poly4');
    cvaluesMFRvsKPSept2014Stbd = coeffvalues(fitobjectS);
    
    % Check Equation of Fit
    %     if enableCommandWindowOutput == 1
    %         cval = cvaluesMFRvsKPSept2014Stbd;
    %         setDecimals1 = '%0.4f';
    %         setDecimals2 = '+%0.4f';
    %         setDecimals3 = '+%0.4f';
    %         setDecimals4 = '+%0.4f';
    %         setDecimals5 = '+%0.4f';
    %         if cval(1) < 0
    %             setDecimals1 = '%0.4f';
    %         end
    %         if cval(2) < 0
    %             setDecimals2 = '%0.4f';
    %         end
    %         if cval(3) < 0
    %             setDecimals3 = '%0.4f';
    %         end
    %         if cval(4) < 0
    %             setDecimals4 = '%0.4f';
    %         end
    %         if cval(5) < 0
    %             setDecimals5 = '%0.4f';
    %         end
    %         p1   = sprintf(setDecimals1,cval(1));
    %         p2   = sprintf(setDecimals2,cval(2));
    %         p3   = sprintf(setDecimals3,cval(3));
    %         p4   = sprintf(setDecimals4,cval(4));
    %         p5   = sprintf(setDecimals5,cval(5));
    %         gofrs = sprintf('%0.2f',gofP.rsquare);
    %         EoFEqn = sprintf('>> STBD Equation of Fit (EoF): y=%sx^4%sx^3%sx^2%sx%s | R^2: %s',p1,p2,p3,p4,p5,gofrs);
    %         disp(EoFEqn);
    %     end
    
else
    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    %disp('WARNING: Required data file for thrust data (SummaryMFRSept2014Array.dat) does not exist!');
    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
end
%# ------------------------------------------------------------------------
%# END Kiel probe vs. mass flow rate
%# ************************************************************************


%# ************************************************************************
%# START Averaged resistance data (created by analysis_custom.m)
%# ------------------------------------------------------------------------
SetAvgResistanceFilePath = '..\..\..\2013 August - Resistance test\_Run files\_Matlab analysis\resultsAveragedArray.dat';
if exist(SetAvgResistanceFilePath, 'file') == 2
    %# Results array columns:
    % See 4. Extrapolation to full scale for column descriptions
    resultsAveragedArray = csvread(SetAvgResistanceFilePath);
    [mfsr,nfsr] = size(resultsAveragedArray);
    %# Remove zero rows
    resultsAveragedArray(all(resultsAveragedArray==0,2),:)=[];
    
    R = resultsAveragedArray;   % Results array
    R(all(R==0,2),:) = [];      % Remove Zero rows from array
    [m,n] = size(R);            % Array dimensions
    
    % Split results array based on column 28 (test condition)
    ARes = arrayfun(@(x) R(R(:,28) == x, :), unique(R(:,28)), 'uniformoutput', false);
    [ma,na] = size(ARes);       % Array dimensions
    
    for j=1:ma
        if ARes{j}(1,28) == 1
            avgcond1 = ARes{j};
        end
        if ARes{j}(1,28) == 2
            avgcond2 = ARes{j};
        end
        if ARes{j}(1,28) == 3
            avgcond3 = ARes{j};
        end
        if ARes{j}(1,28) == 4
            avgcond4 = ARes{j};
        end
        if ARes{j}(1,28) == 5
            avgcond5 = ARes{j};
        end
        if ARes{j}(1,28) == 6
            avgcond6 = ARes{j};
        end
        if ARes{j}(1,28) == 7
            avgcond7 = ARes{j};
        end
        if ARes{j}(1,28) == 8
            avgcond8 = ARes{j};
        end
        if ARes{j}(1,28) == 9
            avgcond9 = ARes{j};
        end
        if ARes{j}(1,28) == 10
            avgcond10 = ARes{j};
        end
        if ARes{j}(1,28) == 11
            avgcond11 = ARes{j};
        end
        if ARes{j}(1,28) == 12
            avgcond12 = ARes{j};
        end
        if ARes{j}(1,28) == 13
            avgcond13 = ARes{j};
        end
    end % j=1:ma
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: File resultsAveragedArray.dat does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    %break;
end
%# ------------------------------------------------------------------------
%# END START Averaged resistance data (created by analysis_custom.m)
%# ************************************************************************


%# ////////////////////////////////////////////////////////////////////////
%# START REPEAT RUN NUMBERS
%# ------------------------------------------------------------------------
RunsForSpeed1 = [101 102 103 107];          % Fr = 0.24
RunsForSpeed2 = [98 99 100 108];            % Fr = 0.26
RunsForSpeed3 = [95 96 97 109];             % Fr = 0.28
RunsForSpeed4 = [70 104 71 72 73 74];       % Fr = 0.30
RunsForSpeed5 = [75 76 78 77];              % Fr = 0.32
RunsForSpeed6 = [79 80 81];                 % Fr = 0.34
RunsForSpeed7 = [82 83 84];                 % Fr = 0.36
RunsForSpeed8 = [85 86 87 88 89 105 106];   % Fr = 0.38
RunsForSpeed9 = [90 91 92 93 94];           % Fr = 0.40
%# ------------------------------------------------------------------------
%# END REPEAT RUN NUMBERS
%# ////////////////////////////////////////////////////////////////////////


%# ////////////////////////////////////////////////////////////////////////
%# START: CREATE PLOTS AND RUN DIRECTORY
%# ------------------------------------------------------------------------

%# _PLOTS directory
fPath = '_plots/';
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# SPP directory ----------------------------------------------------------
setDirName = '_plots/SPP';

fPath = setDirName;
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('%s/%s', setDirName, 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('%s/%s', setDirName, 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('%s/%s', setDirName, 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# SPP_CCDoTT directory ---------------------------------------------------
setDirName = '_plots/SPP_CCDoTT';

fPath = setDirName;
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('%s/%s', setDirName, 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('%s/%s', setDirName, 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('%s/%s', setDirName, 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# LJ120E_Pumpcurve directory ---------------------------------------------

%# _plots/SPP directory
fPath = sprintf('_plots/%s', 'LJ120E_Pumpcurve');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PDF directory
fPath = sprintf('_plots/%s/%s', 'LJ120E_Pumpcurve', 'PDF');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# PNG directory
fPath = sprintf('_plots/%s/%s', 'LJ120E_Pumpcurve', 'PNG');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# EPS directory
fPath = sprintf('_plots/%s/%s', 'LJ120E_Pumpcurve', 'EPS');
if isequal(exist(fPath, 'dir'),7)
    % Do nothing as directory exists
else
    mkdir(fPath);
end

%# ------------------------------------------------------------------------
%# END: CREATE PLOTS AND RUN DIRECTORY
%# ////////////////////////////////////////////////////////////////////////


%# ////////////////////////////////////////////////////////////////////////
%# LOOP THROUGH ALL RUN FILES (depending on startRun and endRun settings)
%# ////////////////////////////////////////////////////////////////////////

% If resultsArraySPP_CCDoTT.dat does NOT EXIST loop through DAQ files
if exist('resultsArraySPP_CCDoTT.dat', 'file') == 0
    
    resultsArraySPP = [];
    %w = waitbar(0,'Processed run files');
    for k=startRun:endRun
        
        %# Allow for 1 to become 01 for run numbers
        if k < 10
            filename = sprintf('%s0%s.run\\R0%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
        else
            filename = sprintf('%s%s.run\\R%s-02_moving.dat', runfilespath, num2str(k), num2str(k));
        end
        [pathstr, name, ext] = fileparts(filename);     % Get file details like path, filename and extension
        
        %# Import the file: importdata(FILENAME, DELIMETER, NUMBER OF HEADERLINES)
        zAndCFData = importdata(filename, ' ', headerlines);
        zAndCF     = zAndCFData.data;
        
        %# Calibration factors and zeros
        ZeroAndCalibData = importdata(filename, ' ', headerlinesZeroAndCalib);
        ZeroAndCalib     = ZeroAndCalibData.data;
        
        %# Time series
        AllRawChannelData = importdata(filename, ' ', headerlines);
        
        %# Create new variables in the base workspace from those fields.
        vars = fieldnames(AllRawChannelData);
        for i = 1:length(vars)
            assignin('base', vars{i}, AllRawChannelData.(vars{i}));
        end
        
        %# Columns as variables (RAW DATA)
        timeData             = data(:,1);       % Timeline
        Raw_CH_0_Speed       = data(:,2);       % Speed
        Raw_CH_1_LVDTFwd     = data(:,3);       % Forward LVDT
        Raw_CH_2_LVDTAft     = data(:,4);       % Aft LVDT
        Raw_CH_3_Drag        = data(:,5);       % Load cell (drag)
        Raw_CH_4_PortRPM     = data(:,6);       % Port RPM
        Raw_CH_5_StbdRPM     = data(:,7);       % Starboard RPM
        Raw_CH_6_PortThrust  = data(:,8);       % Port thrust
        Raw_CH_7_PortTorque  = data(:,9);       % Port torque
        Raw_CH_8_StbdThrust  = data(:,10);      % Starboard thrust
        Raw_CH_9_StbdTorque  = data(:,11);      % Starboard torque
        Raw_CH_10_PortKP     = data(:,12);      % Port kiel probe
        Raw_CH_11_StbdKP     = data(:,13);      % Starboard kiel probe
        
        %# Zeros and calibration factors for each channel
        Time_Zero  = ZeroAndCalib(1);
        Time_CF    = ZeroAndCalib(2);
        CH_0_Zero  = ZeroAndCalib(3);
        CH_0_CF    = ZeroAndCalib(4);
        CH_1_Zero  = ZeroAndCalib(5);
        CH_1_CF    = ZeroAndCalib(6);
        CH_2_Zero  = ZeroAndCalib(7);
        CH_2_CF    = ZeroAndCalib(8);
        CH_3_Zero  = ZeroAndCalib(9);
        CH_3_CF    = ZeroAndCalib(10);
        CH_4_Zero  = ZeroAndCalib(11);
        CH_4_CF    = ZeroAndCalib(12);
        CH_5_Zero  = ZeroAndCalib(13);
        CH_5_CF    = ZeroAndCalib(14);
        CH_6_Zero  = ZeroAndCalib(15);
        CH_6_CF    = ZeroAndCalib(16);
        CH_7_Zero  = ZeroAndCalib(17);
        CH_7_CF    = ZeroAndCalib(18);
        CH_8_Zero  = ZeroAndCalib(19);
        CH_8_CF    = ZeroAndCalib(20);
        CH_9_Zero  = ZeroAndCalib(21);
        CH_9_CF    = ZeroAndCalib(22);
        CH_10_Zero = ZeroAndCalib(23);
        CH_10_CF   = ZeroAndCalib(24);
        CH_11_Zero = ZeroAndCalib(25);
        CH_11_CF   = ZeroAndCalib(26);
        
        %# --------------------------------------------------------------------
        %# Voltage to real units conversion
        %# --------------------------------------------------------------------
        
        [CH_0_Speed CH_0_Speed_Mean]           = analysis_realunits(Raw_CH_0_Speed,CH_0_Zero,CH_0_CF);
        [CH_1_LVDTFwd CH_1_LVDTFwd_Mean]       = analysis_realunits(Raw_CH_1_LVDTFwd,CH_1_Zero,CH_1_CF);
        [CH_2_LVDTAft CH_2_LVDTAft_Mean]       = analysis_realunits(Raw_CH_2_LVDTAft,CH_2_Zero,CH_2_CF);
        [CH_3_Drag CH_3_Drag_Mean]             = analysis_realunits(Raw_CH_3_Drag,CH_3_Zero,CH_3_CF);
        
        [CH_6_PortThrust CH_6_PortThrust_Mean] = analysis_realunits(Raw_CH_6_PortThrust,CH_6_Zero,CH_6_CF);
        [CH_7_PortTorque CH_7_PortTorque_Mean] = analysis_realunits(Raw_CH_7_PortTorque,CH_7_Zero,CH_7_CF);
        [CH_8_StbdThrust CH_8_StbdThrust_Mean] = analysis_realunits(Raw_CH_8_StbdThrust,CH_8_Zero,CH_8_CF);
        [CH_9_StbdTorque CH_9_StbdTorque_Mean] = analysis_realunits(Raw_CH_9_StbdTorque,CH_9_Zero,CH_9_CF);
        
        [RPMStbd RPMPort]                      = analysis_rpm(k,name,Fs,timeData,Raw_CH_5_StbdRPM,Raw_CH_4_PortRPM);
        
        % /////////////////////////////////////////////////////////////////////
        % DISPLAY RESULTS
        % /////////////////////////////////////////////////////////////////////
        
        %# Add results to dedicated array for simple export
        %# Results array columns:
        
        %[1]  Run No.
        %[2]  FS                          (Hz)
        %[3]  No. of samples              (-)
        %[4]  Record time                 (s)
        
        %[5]  Froude length number        (-)
        %[6]  Speed (vm)                  (m/s)
        %[7]  Forward LVDT                (mm)
        %[8]  Aft LVDT                    (mm)
        %[9]  Drag                        (g)
        %[10] Drag                        (N)
        
        %[11] PORT: Shaft Speed           (RPM)
        %[12] STBD: Shaft Speed           (RPM)
        %[13] PORT: Thrust                (N)
        %[14] STBD: Thrust                (N)
        %[15] PORT: Torque                (Nm)
        %[16] STBD: Torque                (Nm)
        %[17] PORT: Kiel probe            (V)
        %[18] STBD: Kiel probe            (V)
        
        % New columns added 15/7/2014
        %[19] Shaft/motor speed           (RPM)
        %[20] Ship speed (vs)             (m/s)
        %[21] Ship speed (vs)             (knots)
        
        %[22] Model scale Reynolds number (Rem) (-)
        %[23] Full scale Reynolds number (Res)  (-)
        
        %[24] Model scale frictional resistance coefficient (Grigson), CFm (-)
        %[25] Full scale Frictional resistance coefficient (Grigson), CFs  (-)
        %[26] Correleation coefficient, Ca                                 (-)
        %[27] Form factor (1+k)                                            (-)
        %[28] Towing force, (FD)                                           (N)
        %[29] Towing force coefficient, (CFD)                              (-)
        
        % Mass flow rate and jet velocity
        %[30] PORT: Mass flow rate (pQJ)      (Kg/s)
        %[31] STBD: Mass flow rate (pQJ)      (Kg/s)
        %[32] PORT: Volumetric flow rate (QJ) (m^3/s)
        %[33] STBD: Volumetric flow rate (QJ) (m^3/s)
        
        %[34] PORT: Jet velocity (vj)     (m/s)
        %[35] STBD: Jet velocity (vj)     (m/s)
        
        % Wake fraction
        %[36] PORT: Wake fraction (1-w)   (-)
        %[37] STBD: Wake fraction (1-w)   (-)
        
        %[38] PORT: Inlet velocity, vi    (m/s)
        %[39] STBD: Inlet velocity, vi    (m/s)
        
        % Gross thrust = TG = p Q (vj - vi)
        %[40] PORT: Gross thrust, TG      (N)
        %[41] STBD: Gross thrust, TG      (N)
        %[42] Total gross thrust, TG      (N)
        
        % Gross thrust = TG = p Q vj
        %[43] PORT: Gross thrust, TG      (N)
        %[44] STBD: Gross thrust, TG      (N)
        %[45] Total gross thrust, TG      (N)
        
        % New values added on 24/9/2014
        %[46] Power law factor                             (-)
        %[47] Boundary layer thickness                     (m)
        %[48] Volume flow rate inside boundary layer (Qbl) (m^3/s)
        %[49] PORT: Wake fraction (w)                      (-)
        %[50] STBD: Wake fraction (w)                      (-)
        
        % General data
        resultsArraySPP(k, 1)  = k;                                                     % Run No.
        resultsArraySPP(k, 2)  = round(length(timeData) / timeData(end));               % FS (Hz)
        resultsArraySPP(k, 3)  = length(timeData);                                      % Number of samples
        recordTime = length(timeData) / (round(length(timeData) / timeData(end)));
        resultsArraySPP(k, 4)  = round(recordTime);                                     % Record time in seconds
        
        roundedspeed   = str2num(sprintf('%.2f',CH_0_Speed_Mean));                      % Round averaged speed to two (2) decimals only
        modelfrrounded = str2num(sprintf('%.2f',roundedspeed / sqrt(gravconst*MSlwl))); % Calculate Froude length number
        resultsArraySPP(k, 5) = modelfrrounded;                                         % Froude length number (adjusted for Lwl change at different conditions) (-)
        
        % Resistance data
        resultsArraySPP(k, 6)  = CH_0_Speed_Mean;                                       % Speed (m/s)
        resultsArraySPP(k, 7)  = CH_1_LVDTFwd_Mean;                                     % Forward LVDT (mm)
        resultsArraySPP(k, 8)  = CH_2_LVDTAft_Mean;                                     % Aft LVDT (mm)
        resultsArraySPP(k, 9)  = CH_3_Drag_Mean;                                        % Drag (g)
        resultsArraySPP(k, 10) = (CH_3_Drag_Mean/1000)*gravconst;                       % Drag (N)
        
        % RPM data
        resultsArraySPP(k, 11) = RPMPort;                                               % Shaft Speed PORT (RPM)
        resultsArraySPP(k, 12) = RPMStbd;                                               % Shaft Speed STBD (RPM)
        
        % Thrust and torque data
        resultsArraySPP(k, 13) = abs(CH_6_PortThrust_Mean/1000)*9.806;                  % Thrust PORT (N)
        resultsArraySPP(k, 14) = abs(CH_8_StbdThrust_Mean/1000)*9.806;                  % Thrust STBD (N)
        resultsArraySPP(k, 15) = CH_7_PortTorque_Mean;                                  % Torque PORT (Nm)
        resultsArraySPP(k, 16) = CH_9_StbdTorque_Mean;                                  % Torque STBD (Nm)
        
        % Kie; probe data
        resultsArraySPP(k, 17)  = mean(Raw_CH_10_PortKP);                               % Kiel probe PORT (V)
        resultsArraySPP(k, 18)  = mean(Raw_CH_11_StbdKP);                               % Kiel probe STBD (V)
        
        % New columns added 15/7/2014
        sslIndex = find(shaftSpeedList == k);
        if isempty(sslIndex) == 1
            shaftSpeedRPM = 0;
        else
            %shaftSpeedRPM = shaftSpeedList(sslIndex,2);
            % Actual (averaged PORT and STBD) shaft speed (i.e. measured shaft speed)
            shaftSpeedRPM = (RPMStbd+RPMPort)/2;
        end
        resultsArraySPP(k, 19)  = shaftSpeedRPM;                                        % Shaft/motor speed (RPM)
        
        % Full scale speed
        MSspeed = CH_0_Speed_Mean;
        FSspeed = CH_0_Speed_Mean*sqrt(FStoMSratio);
        
        resultsArraySPP(k, 20)  = FSspeed;                                              % Ship speed (m/s)
        resultsArraySPP(k, 21)  = FSspeed/0.514444;                                     % Ship speed (knots)
        
        %# ****************************************************************
        %# Start Schuster correction factors (only Re and CF)
        %# ----------------------------------------------------------------
        
        MSReynoldsNo = (MSspeed*MSlwl)/MSKinVis;
        
        if MSReynoldsNo < 10000000
            MSCFm = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2); % Model Frictional Resistance Coefficient (Grigson) (-)
        else
            MSCFm = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3); % Model Frictional Resistance Coefficient (Grigson) (-)
        end
        
        %R Fr vs. single demihull corrected resistance
        xres = ResResults(:,1);
        yres = ResResults(:,26);
        
        % Equation of fit for RTm vs. Fr
        [fitobject,gof,output] = fit(xres,yres,'poly5');
        cvalues = coeffvalues(fitobject);
        
        P1 = cvalues(1);
        P2 = cvalues(2);
        P3 = cvalues(3);
        P4 = cvalues(4);
        P5 = cvalues(5);
        P6 = cvalues(6);
        
        % Froude length number, RTm, and CTm
        FN               = roundedspeed / sqrt(gravconst*MSlwl);
        MSRTm            = P1*FN^5+P2*FN^4+P3*FN^3+P4*FN^2+P5*FN+P6;
        MSCTm            = MSRTm/(0.5*freshwaterdensity*MSwsa*MSspeed^2);
        
        % Schuster corrections
        MSRv             = MSCFm*(0.5*freshwaterdensity*MSwsa*MSspeed^2);
        DepthFroudeNo    = MSspeed/sqrt(gravconst*ttwaterdepth);
        MSCorrSpeedRatio = (AreaRatio/(1-AreaRatio-DepthFroudeNo^2))+(1-(MSRv/MSRTm))*(2/3)*DepthFroudeNo^10;
        
        % Schuster corrected model speed and Reynolds number
        MSSpeedCorr      = MSspeed*(1+MSCorrSpeedRatio);
        MSReynoldsNo     = (MSSpeedCorr*MSlwl)/MSKinVis;
        
        %# ----------------------------------------------------------------
        %# End Schuster correction factors (only Re and CF)
        %# ****************************************************************
        
        % Model and full scale Reynolds number
        %MSReynoldsNo = (MSspeed*MSlwl)/MSKinVis;
        MSReynoldsNo = MSReynoldsNo;
        FSReynoldsNo = (FSspeed*FSlwl)/FSKinVis;
        
        resultsArraySPP(k, 22) = MSReynoldsNo;  % Model scale Reynolds number (-)
        resultsArraySPP(k, 23) = FSReynoldsNo;  % Full scale Reynolds number (-)
        
        % Model scale frictional resistance coefficient (Grigson), CFm (-)
        if MSReynoldsNo < 10000000
            resultsArraySPP(k, 24) = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
        else
            resultsArraySPP(k, 24) = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
        end
        
        % Full scale frictional resistance coefficient (Grigson), CFs (-)
        if FSReynoldsNo < 10000000
            resultsArraySPP(k, 25) = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2);
        else
            resultsArraySPP(k, 25) = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3);
        end
        
        resultsArraySPP(k, 26)  = CorrCoeff;                                            % Correlation coefficient, Ca (-)
        resultsArraySPP(k, 27)  = FormFactor;                                           % Form factor (-)
        
        % Towing force (FD) and towing force coefficient
        setCFm = resultsArraySPP(k, 24);
        setCFs = resultsArraySPP(k, 25);
        resultsArraySPP(k, 28)  = 0.5*freshwaterdensity*(MSspeed^2)*MSwsa*(FormFactor*(setCFm-setCFs)-CorrCoeff);  % Towing force, FD (N)
        resultsArraySPP(k, 29)  = FormFactor*(setCFm-setCFs)-CorrCoeff;                                            % Towing force coefficient, CFD (-)
        
        % Kiel probes
        PortKP = resultsArraySPP(k, 17);                                                % PORT: Kiel probe (V)
        StbdKP = resultsArraySPP(k, 18);                                                % STBD: Kiel probe (V)
        
        %# START Handle mass flow rate ------------------------------------
        if enableSept2014FRMValues == 1
            % If results from flow rate measurement test have been saved in
            % SummaryMFRSept2014Array.dat use automatic fitting otherwise
            % use older established result set
            if exist(SetMFRvsKPDataFilePath, 'file') == 2
                EoFPort = cvaluesMFRvsKPSept2014Port;
                EoFStbd = cvaluesMFRvsKPSept2014Stbd;
                PortMfr = EoFPort(1)*PortKP^4+EoFPort(2)*PortKP^3+EoFPort(3)*PortKP^2+EoFPort(4)*PortKP+EoFPort(5);
                StbdMfr = EoFStbd(1)*StbdKP^4+EoFStbd(2)*StbdKP^3+EoFStbd(3)*StbdKP^2+EoFStbd(4)*StbdKP+EoFStbd(5);
            else
                % PORT and STBD (September 2014 FRM test): Mass flow rate (Kg/s)
                PortMfr = -0.0421*PortKP^4+0.5718*PortKP^3-2.9517*PortKP^2+7.8517*PortKP-5.1976;
                StbdMfr = -0.0942*StbdKP^4+1.1216*StbdKP^3-4.9878*StbdKP^2+11.0548*StbdKP-6.8484;
            end
        else
            % PORT (June 2013 FRM test): Mass flow rate (Kg/s)
            if PortKP > 1.86
                PortMfr = 0.1133*PortKP^3-1.0326*PortKP^2+4.3652*PortKP-2.6737;
            else
                PortMfr = 0.4186*PortKP^5-4.5094*PortKP^4+19.255*PortKP^3-41.064*PortKP^2+45.647*PortKP-19.488;
            end
            % STBD (June 2013 FRM test): Mass flow rate (Kg/s)
            if StbdKP > 1.86
                StbdMfr = 0.1133*StbdKP^3-1.0326*StbdKP^2+4.3652*StbdKP-2.6737;
            else
                StbdMfr = 0.4186*StbdKP^5-4.5094*StbdKP^4+19.255*StbdKP^3-41.064*StbdKP^2+45.647*StbdKP-19.488;
            end
        end
        %# END Handle mass flow rate --------------------------------------
        
        % Mass flow rate and jet velocity
        resultsArraySPP(k, 30)  = PortMfr;                                   % PORT: Mass flow rate (Kg/s)
        resultsArraySPP(k, 31)  = StbdMfr;                                   % STBD: Mass flow rate (Kg/s)
        
        % Volume flow rate
        PortVfr = PortMfr/freshwaterdensity;
        StbdVfr = StbdMfr/freshwaterdensity;
        resultsArraySPP(k, 32)  = PortVfr;                                   % PORT: Volume flow rate (m^3/s)
        resultsArraySPP(k, 33)  = StbdVfr;                                   % STBD: Volume flow rate (m^3/s)
        
        % Jet velocity
        resultsArraySPP(k, 34)  = PortVfr/MS_NozzArea;                       % PORT: Jet velocity (m/s)
        resultsArraySPP(k, 35)  = StbdVfr/MS_NozzArea;                       % STBD: Jet velocity (m/s)
        
        % Wake fraction and gross thrust
        if any(k==RunsForSpeed1)
            setSpeed = 1;
        elseif any(k==RunsForSpeed2)
            setSpeed = 2;
        elseif any(k==RunsForSpeed3)
            setSpeed = 3;
        elseif any(k==RunsForSpeed4)
            setSpeed = 4;
        elseif any(k==RunsForSpeed5)
            setSpeed = 5;
        elseif any(k==RunsForSpeed6)
            setSpeed = 6;
        elseif any(k==RunsForSpeed7)
            setSpeed = 7;
        elseif any(k==RunsForSpeed8)
            setSpeed = 8;
        elseif any(k==RunsForSpeed9)
            setSpeed = 9;
        else
            disp('Oops.. something is wrong here, run is not in speed list!');
        end
        
        if any(k==RunsForSpeed1) || any(k==RunsForSpeed2) || any(k==RunsForSpeed3) || any(k==RunsForSpeed4) || any(k==RunsForSpeed5) || any(k==RunsForSpeed6) || any(k==RunsForSpeed7) || any(k==RunsForSpeed8) || any(k==RunsForSpeed9)
            BLPLFactor  = BLPLFactorArray(setSpeed);
            BLThickness = BLThicknessArray(setSpeed);
            QBL         = CH_0_Speed_Mean*WidthFactor*MS_PumpDia*BLThickness*(BLPLFactor/(BLPLFactor+1));
            setPortWF   = 1-((BLPLFactor+1)/(BLPLFactor+2))*(PortVfr/QBL)^(1/(BLPLFactor+1));
            setStbdWF   = 1-((BLPLFactor+1)/(BLPLFactor+2))*(StbdVfr/QBL)^(1/(BLPLFactor+1));
        else
            BLPLFactor  = 0;
            BLThickness = 0;
            QBL         = 0;
            setPortWF   = 1;
            setStbdWF   = 1;
        end
        
        % Wake fraction (1-w)
        resultsArraySPP(k, 36)  = 1-setPortWF;       % PORT: Wake fraction (1-w) (-)
        resultsArraySPP(k, 37)  = 1-setStbdWF;       % STBD: Wake fraction (1-w) (-)
        
        % Inlet velocity
        resultsArraySPP(k, 38)  = MSspeed*resultsArraySPP(k, 36); % PORT: Inlet velocity, vi (m/s)
        resultsArraySPP(k, 39)  = MSspeed*resultsArraySPP(k, 37); % STBD: Inlet velocity, vi (m/s)
        
        % Variables for gross thrust (TG)
        PortJetVel = resultsArraySPP(k, 34);         % Port jet velocity (m/s)
        StbdJetVel = resultsArraySPP(k, 35);         % Stbd jet velocity (m/s)
        PortInlVel = resultsArraySPP(k, 38);         % Port inlet velocity (m/s)
        StbdInlVel = resultsArraySPP(k, 39);         % Stbd inlet velocity (m/s)
        
        % Gross thrust = TG = p Q (vj - vi)
        TG1Port = PortMfr*(PortJetVel-PortInlVel);
        TG1Stbd = StbdMfr*(StbdJetVel-StbdInlVel);
        resultsArraySPP(k, 40)  = TG1Port;           % PORT: Gross thrust, TG (N)
        resultsArraySPP(k, 41)  = TG1Stbd;           % STBD: Gross thrust, TG (N)
        resultsArraySPP(k, 42)  = TG1Port+TG1Stbd;   % TOTAL gross thrust, TG (N)
        
        % Gross thrust = TG = p Q vj
        TG2Port  = PortMfr*PortJetVel;
        TG2Stbd  = StbdMfr*StbdJetVel;
        resultsArraySPP(k, 43)  = TG2Port;           % PORT: Gross thrust, TG (N)
        resultsArraySPP(k, 44)  = TG2Stbd;           % STBD: Gross thrust, TG (N)
        resultsArraySPP(k, 45)  = TG2Port+TG2Stbd;   % TOTAL gross thrust, TG (N)
        
        % New values added on 24/9/2014
        resultsArraySPP(k, 46) = BLPLFactor;
        resultsArraySPP(k, 47) = BLThickness;
        resultsArraySPP(k, 48) = QBL;
        
        % Wake fraction w
        resultsArraySPP(k, 49) = setPortWF;
        resultsArraySPP(k, 50) = setStbdWF;
        
        %# Prepare strings for display ----------------------------------------
        
        % Change from 2 to 3 digits
        if k > 99
            name = name(1:4);
        else
            name = name(1:3);
        end
        
        % Prepare strings  ----------------------------------------------------
        
        setRPM       = sprintf('%s:: Set motor/shaft speed: %s [RPM]', name, sprintf('%.0f',shaftSpeedRPM));
        shaftrpmport = sprintf('%s:: Measured motor/shaft speed PORT: %s [RPM]', name, sprintf('%.0f',RPMPort));
        shaftrpmstbd = sprintf('%s:: Measured motor/speed STBD: %s [RPM]', name, sprintf('%.0f',RPMStbd));
        
        %# Display strings ---------------------------------------------------
        
        disp(setRPM);
        disp(shaftrpmport);
        disp(shaftrpmstbd);
        
        disp('/////////////////////////////////////////////////');
        
        %wtot = endRun - startRun;
        %w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
    end
    
    %# Close progress bar
    %close(w);
    
    % /////////////////////////////////////////////////////////////////////
    % START Write results to DAT or TXT file
    % ---------------------------------------------------------------------
    resultsArraySPP = resultsArraySPP(any(resultsArraySPP,2),:);                    % Remove zero rows
    M = resultsArraySPP;
    %M = M(any(M,2),:);                                                             % remove zero rows only in resultsArraySPP text file
    csvwrite('resultsArraySPP_CCDoTT.dat', M)                                       % Export matrix M to a file delimited by the comma character
    %dlmwrite('resultsArraySPP_CCDoTT.txt', M, 'delimiter', '\t', 'precision', 4)   % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
    % ---------------------------------------------------------------------
    % END Write results to DAT or TXT file
    % /////////////////////////////////////////////////////////////////////
    
else
    
    %# As we know that resultsArraySPP_CCDoTT.dat exits, read it
    resultsArraySPP = csvread('resultsArraySPP_CCDoTT.dat');
    
    %# Remove zero rows
    resultsArraySPP(all(resultsArraySPP==0,2),:)=[];
    
end


%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 1. Plot gross thrust (TG) vs. towing force (F)
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

% Remove zero rows
resultsArraySPP = resultsArraySPP(any(resultsArraySPP,2),:);

% Split results array based on column 9 (Length Froude Number)
R = resultsArraySPP;
A = arrayfun(@(x) R(R(:,5) == x, :), unique(R(:,5)), 'uniformoutput', false);
[ma,na] = size(A);      % Array dimensions

% Froude numbers for nine (9) speeds
Froude_Numbers = [];
% Froude_Numbers columns:
%[1] Froude length number, Fr                   (-)
%[2] Repeated runs averaged measured speed, Vm  (m/s)
for k=1:ma
    Froude_Numbers(k,1) = A{k}(1,5);
    Froude_Numbers(k,2) = mean(A{k}(:,6));
end

%# ************************************************************************
%# Model Scale: Uncorrected and corrected bnare hull resistance
%# ************************************************************************

%# UNCORRECTED: calBHResistanceBasedOnFr results array columns:
%[1]  Froude length number             (-)
%[2]  Resistance (uncorrected)         (N)
%[resistance] = calBHResistanceBasedOnFr(Froude_Numbers);

%# CORRECTED: calBHResistanceBasedOnFrTempCorr results array columns:
%[1]  Froude length number             (-)
%[2]  Resistance (uncorrected)         (N)
%[3]  Resistance (corrected for temp.) (N) -> See ITTC 7.5-02-03-01.4 (2008)
[resistance] = calBHResistanceBasedOnFrTempCorr(Froude_Numbers,FormFactor,MSwsa,MSlwl);

%# ************************************************************************
%# Self-Propulsion Points Based on:
%#   CCDoTT (2007). "Waterjet Data"
%# ************************************************************************
TG_at_FDArray       = [];   % Gross thrust = TG = p Q (vj - vi)
F_at_TGZero         = [];   % Gross thrust = TG = p Q (vj - vi)
FR_at_SPP           = [];   % Flow rates at self-propulsion point (SPP)
thrustDedFracArray  = [];   % Thrust deduction array where TG = p Q (vj - vi)
shaftSpeedConvArray = [];   % Shaft speed array where TG = p Q (vj - vi)
resSPP              = [];   % Summary results of self-propulsion points
for k=1:ma
    [mb,nb] = size(A{k});
    
    % Corrected resistance (RC) at current Froude length number -----------
    correctedResistance = resistance(k,3);
    
    %# TG at FD -----------------------------------------------------------
    y1       = A{k}(:,45);   % Gross thrust = TG = p Q vj        (N)
    y2       = A{k}(:,42);   % Gross thrust = TG = p Q (vj - vi) (N)
    
    yPortTQ  = A{k}(:,15);   % PORT: Torque                      (N)
    yStbdTQ  = A{k}(:,16);   % STBD: Torque                      (N)
    
    yPortKP  = A{k}(:,17);   % PORT: Kiel Probe                  (V)
    yStbdKP  = A{k}(:,18);   % STBD: Kiel Probe                  (V)
    
    yPortSS  = A{k}(:,11);   % PORT: Shaft speed                 (PRM)
    yStbdSS  = A{k}(:,12);   % STBD: Shaft speed                 (PRM)
    
    x        = A{k}(:,10);   % Bare hull resistance              (N)
    towForce = A{k}(1,28);   % Towing force, FD                  (N)
    xq       = 0;            % Intersection of x for TG at zero drag
    
    %# --------------------------------------------------------------------
    %# Gross thrust = TG = p Q (vj - vi)
    %# --------------------------------------------------------------------
    polyf               = polyfit(x,y2,1);
    polyv               = polyval(polyf,x);
    ThrustAtZeroDrag    = spline(x,polyv,0);
    ThrustAtSPP         = ThrustAtZeroDrag-towForce;
    TG_at_FDArray(k, 1) = ThrustAtZeroDrag;        % Gross thrust, TG   (x-axis)
    TG_at_FDArray(k, 2) = 0;                       % Towing force, Drag (y-axis)
    TG_at_FDArray(k, 3) = towForce;                % Towing force, FD
    TG_at_FDArray(k, 4) = ThrustAtSPP;             % Thrust at self. propulsion point = TG at zero drag - FD
    
    % Towing force at zero gross thrust -----------------------------------
    TowingForceAtZeroThrust = spline(polyv,x,0);
    F_at_TGZero(k, 1) = 0;                         % Gross thrust, TG (x-axis)
    F_at_TGZero(k, 2) = TowingForceAtZeroThrust;   % Towing force     (y-axis)
    
    % Thrust deduction fraction (t) ---------------------------------------
    thrustDedFracArray(k, 1) = Froude_Numbers(k,1);
    % t=(TM+FD-RC)/TM
    thrustDedFracArray(k, 2) = (ThrustAtSPP+towForce-correctedResistance)/ThrustAtSPP;
    % RCW=TG(1-t)+FD ==>> t=1-((RC-FD)/T)
    thrustDedFracArray(k, 3) = 1-((correctedResistance-towForce)/ThrustAtSPP);
    % t = ((FD-FatT=0)/TG@SPP)+1
    thrustDedFracArray(k, 4) = ((towForce-TowingForceAtZeroThrust)/ThrustAtSPP)+1;
    % t = 1-((FatT=0-FD)/TG@SPP)
    thrustDedFracArray(k, 5) = 1-((TowingForceAtZeroThrust-towForce)/ThrustAtSPP);
    
    % Shaft speed at SPP --------------------------------------------------
    %[1] Froude length number             (-)
    %[2] PORT (MS): Shaft speed at SPP    (RPM)
    %[3] PORT (MS): Shaft speed at SPP    (RPM)
    %[4] PORT (FS): Shaft speed at SPP    (RPM)
    %[5] PORT (FS): Shaft speed at SPP    (RPM)
    
    x = A{k}(:,42);     % Gross thrust = TG = p Q (vj - vi)    (N)
    
    % Port
    polyfPORT2             = polyfit(x,yPortSS,1);
    polyvPORT2             = polyval(polyfPORT2,x);
    MSPortShaftSpeed       = spline(x,polyvPORT2,ThrustAtSPP);
    
    % Stbd
    polyfSTBD2             = polyfit(x,yStbdSS,1);
    polyvSTBD2             = polyval(polyfSTBD2,x);
    MSStbdShaftSpeed       = spline(x,polyvSTBD2,ThrustAtSPP);
    
    % Speed array - MS and FS
    shaftSpeedConvArray(k, 1) = Froude_Numbers(k,1);
    shaftSpeedConvArray(k, 2) = MSPortShaftSpeed;
    shaftSpeedConvArray(k, 3) = MSStbdShaftSpeed;
    shaftSpeedConvArray(k, 4) = MSPortShaftSpeed/sqrt(FStoMSratio);
    shaftSpeedConvArray(k, 5) = MSStbdShaftSpeed/sqrt(FStoMSratio);
    
    % Flow Rate at SPP ----------------------------------------------------
    %[1] Froude length number             (-)
    %[2] PORT (MS): Kiel Probe            (V)
    %[3] STBD (MS): Kiel Probe            (V)
    %[4] PORT (MS): Mass flow rate        (RPM)
    %[5] STBD (MS): Mass flow rate        (RPM)
    %[6] PORT (MS): Volumetric flow rate  (RPM)
    %[7] STBD (MS): Volumetric flow rate  (RPM)
    %[8] PORT (MS): Torque                (Nm)
    %[9] STBD (MS): Torque                (Nm)
    
    x = A{k}(:,42);     % Gross thrust = TG = p Q (vj - vi)    (N)
    
    % Port - Kiel Probe
    polyfPortKP = polyfit(x,yPortKP,1);
    polyvPortKP = polyval(polyfPortKP,x);
    PortKPatSPP = spline(x,polyvPortKP,ThrustAtSPP);
    
    % Port - Torque
    polyfPortTQ = polyfit(x,yPortTQ,1);
    polyvPortTQ = polyval(polyfPortTQ,x);
    PortTQatSPP = spline(x,polyvPortTQ,ThrustAtSPP);
    
    % Stbd - Kiel Probe
    polyfStbdKP = polyfit(x,yStbdKP,1);
    polyvStbdKP = polyval(polyfStbdKP,x);
    StbdKPatSPP = spline(x,polyvStbdKP,ThrustAtSPP);
    
    % Stbd - Torque
    polyfStbdTQ = polyfit(x,yStbdTQ,1);
    polyvStbdTQ = polyval(polyfStbdTQ,x);
    StbdTQatSPP = spline(x,polyvStbdTQ,ThrustAtSPP);
    
    MSPortMFR = -0.0421*PortKPatSPP^4+0.5718*PortKPatSPP^3-2.9517*PortKPatSPP^2+7.8517*PortKPatSPP-5.1976;
    MSStbdMFR = -0.0942*StbdKPatSPP^4+1.1216*StbdKPatSPP^3-4.9878*StbdKPatSPP^2+11.0548*StbdKPatSPP-6.8484;
    
    FR_at_SPP(k,1) = Froude_Numbers(k,1);
    FR_at_SPP(k,2) = PortKPatSPP;
    FR_at_SPP(k,3) = StbdKPatSPP;
    FR_at_SPP(k,4) = MSPortMFR;
    FR_at_SPP(k,5) = MSStbdMFR;
    FR_at_SPP(k,6) = MSPortMFR/freshwaterdensity;
    FR_at_SPP(k,7) = MSStbdMFR/freshwaterdensity;
    FR_at_SPP(k,8) = PortTQatSPP;
    FR_at_SPP(k,9) = StbdTQatSPP;
    
    
    %# ********************************************************************
    %# WRITE RESULTSARRAY (resSPP)
    %# ********************************************************************
    
    if k == 4
        PortThrustValues  = A{k}(3:6,40);
        StbdThrustValues  = A{k}(3:6,41);
        TotalThrustValues = A{k}(3:6,42);
    else
        PortThrustValues  = A{k}(:,40);
        StbdThrustValues  = A{k}(:,41);
        TotalThrustValues = A{k}(:,42);
    end
    
    % Determine percentage of thrust
    [mpc,npc] = size(TotalThrustValues);
    tempArray1 = [];
    tempArray2 = [];
    for kpc=1:mpc
        tempArray1(kpc) = PortThrustValues(kpc)/TotalThrustValues(kpc);
        tempArray2(kpc) = StbdThrustValues(kpc)/TotalThrustValues(kpc);
    end
    meanRatioPortWJSys = mean(tempArray1);
    meanRatioStbdWJSys = mean(tempArray2);
    
    SPP_THRUST_PORT = meanRatioPortWJSys*ThrustAtSPP;
    SPP_THRUST_STBD = meanRatioStbdWJSys*ThrustAtSPP;
    
    % resSPP columns:
    
    % FROUDE LENGTH NUMBER AND TOWING FORCE, FD
    %[1]  Froude length number             (-)
    %[2]  Towing Force, FD                 (N)
    
    % PORT WJ SYSTEM (SPP VALUES)
    %[3]  Shaft speed                      (RPM)
    %[4]  Gross thrust                     (N)
    %[5]  Torque                           (Nm)
    %[6]  Kiel probe                       (V)
    
    % STARBOARD WJ SYSTEM (SPP VALUES)
    %[7]  Shaft speed                      (RPM)
    %[8]  Gross thrust                     (N)
    %[9]  Torque                           (Nm)
    %[10] Kiel probe                       (V)
    
    % TOTAL GROSS THRUST
    %[11] Gross thrust at SPP, T@SPP       (N)
    
    % MEAN PORT AND STARBOARD WJ SYSTEM
    %[12] Shaft speed                      (RPM)
    %[13] Gross thrust                     (N)
    %[14] Torque                           (Nm)
    %[15] Kiel probe                       (V)
    
    % AFT AND FWD LVDT, HEAVE AND TRIM
    %[16] Aft LVDT                         (mm)
    %[17] Fwd LVDT                         (mm)
    %[18] Heave                            (mm)
    %[19] Running trim                     (deg)
    
    % FROUDE LENGTH NUMBER AND TOWING FORCE, FD
    resSPP(k,1)  = A{k}(1,5);
    resSPP(k,2)  = towForce;
    
    % PORT WJ SYSTEM
    resSPP(k,3)  = MSPortShaftSpeed;
    resSPP(k,4)  = SPP_THRUST_PORT;
    resSPP(k,5)  = PortTQatSPP;
    resSPP(k,6)  = PortKPatSPP;
    
    % STARBOARD WJ SYSTEM
    resSPP(k,7)  = MSStbdShaftSpeed;
    resSPP(k,8)  = SPP_THRUST_STBD;
    resSPP(k,9)  = StbdTQatSPP;
    resSPP(k,10) = StbdKPatSPP;
    
    % TOTAL GROSS THRUST
    resSPP(k,11) = ThrustAtSPP;
    
    % MEAN PORT AND STARBOARD WJ SYSTEM
    resSPP(k,12) = mean([MSPortShaftSpeed MSStbdShaftSpeed]);
    resSPP(k,13) = mean([SPP_THRUST_PORT SPP_THRUST_STBD]);
    resSPP(k,14) = mean([PortKPatSPP StbdKPatSPP]);
    resSPP(k,15) = mean([PortTQatSPP StbdTQatSPP]);
    
    % AFT AND FWD LVDT, HEAVE AND TRIM
    resSPP(k,16) = 0;
    resSPP(k,17) = 0;
    resSPP(k,18) = 0;
    resSPP(k,19) = 0;
    
end


%# ************************************************************************
%# START Linear Plots (CCFoTT Self-Propulsion Points)
%# ************************************************************************

if exist('resultsArraySPP_CCDoTT_SelfPropPointsData.dat', 'file') == 0
    resSPP_CCDoTT = [];
    %for klp=1:1
    for klp=1:ma % ma
        
        %# ********************************************************************
        %# SELF-PROPULSION POINTS (COMB)
        %# ********************************************************************
        figurename = sprintf('Plot 0 (COMB): Speed = %s, Fr = %s, Linear Plots for Self-Propulsion Points (SPP)',num2str(klp),sprintf('%.2f',A{klp}(1,5)));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings ------------------------------------------------
        
        %         if enableA4PaperSizePlot == 1
        %             set(gcf, 'PaperSize', [19 19]);
        %             set(gcf, 'PaperPositionMode', 'manual');
        %             set(gcf, 'PaperPosition', [0 0 19 19]);
        %
        %             set(gcf, 'PaperUnits', 'centimeters');
        %             set(gcf, 'PaperSize', [19 19]);
        %             set(gcf, 'PaperPositionMode', 'manual');
        %             set(gcf, 'PaperPosition', [0 0 19 19]);
        %         end
        
        % Fonts and colours ---------------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        setLegendFontSize  = 12;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. --------------------------------
        set(gca,'TickDir','in',...
            'FontSize',12,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors --------------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Line, colors and markers
        setMarkerSize       = 12;
        setMarkerSize2      = 12;
        setLineWidthMarker  = 2;
        setLineWidth        = 2;
        setLineWidth2       = 1;
        setLineStyle        = '-';
        setLineStyle2       = '-.';
        
        % Towing Force, FD
        TowForceFD = TG_at_FDArray(klp, 3);
        
        %# Subplot ////////////////////////////////////////////////////////////
        %subplot(1,1,1)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 40;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,42);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,42);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-4);
        maxX = round(max(x2)+4);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('COMB: Speed %s (Gross thrust): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        disp('-------------------------------------------------------------------------');
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_THRUST_CCDoTT_TOTAL = xout;
        
        x3 = SPP_THRUST_CCDoTT_TOTAL;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Gross thrust (N)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        %title('{\bf Gross Thrust}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-3;
        maxX  = max(x2)+3;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# ********************************************************************
        %# Save plot as PNG
        %# ********************************************************************
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        %         if enableA4PaperSizePlot == 1
        %             set(gcf, 'PaperUnits','centimeters');
        %             set(gcf, 'PaperSize',[XPlot YPlot]);
        %             set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        %             set(gcf, 'PaperOrientation','portrait');
        %         end
        
        %# Plot title ---------------------------------------------------------
        %         if enablePlotMainTitle == 1
        %             annotation('textbox', [0 0.9 1 0.1], ...
        %                 'String', strcat('{\bf ', figurename, '}'), ...
        %                 'EdgeColor', 'none', ...
        %                 'HorizontalAlignment', 'center');
        %         end
        
        %# Save plots as PDF, PNG and EPS -------------------------------------
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for k=1:3
            plotsavename = sprintf('_plots/%s/%s/SPP_Plot_0_COMB_Speed_No_%s_Linear_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, num2str(klp), setFileFormat{k});
            print(gcf, setSaveFormat{k}, plotsavename);
        end
        close;
        
        
        %# ********************************************************************
        %# SELF-PROPULSION POINTS (PORT)
        %# ********************************************************************
        figurename = sprintf('Plot 0 (PORT): Speed = %s, Fr = %s, Linear Plots for Self-Propulsion Points (SPP)',num2str(klp),sprintf('%.2f',A{klp}(1,5)));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings ------------------------------------------------
        
        %if enableA4PaperSizePlot == 1
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
        
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
        %end
        
        % Fonts and colours ---------------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        setLegendFontSize  = 12;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. --------------------------------
        set(gca,'TickDir','in',...
            'FontSize',12,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors --------------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Line, colors and markers
        setMarkerSize       = 12;
        setMarkerSize2      = 12;
        setLineWidthMarker  = 2;
        setLineWidth        = 2;
        setLineWidth2       = 1;
        setLineStyle        = '-';
        setLineStyle2       = '-.';
        
        % Towing Force, FD
        TowForceFD = TG_at_FDArray(klp, 3);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,1)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 4000;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,11);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,11);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-300);
        maxX = round(max(x2)+300);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('PORT: Speed %s (Shaft speed): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_RPM_CCDoTT_PORT = xout;
        
        x3 = SPP_RPM_CCDoTT_PORT;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Shaft speed (RPM)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Shaft Speed}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-300;
        maxX  = max(x2)+300;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,2)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 30;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2    = A{klp}(3:6,40);
            y2    = A{klp}(3:6,10);
            WJSys = A{klp}(3:6,40);
        else
            x2    = A{klp}(:,40);
            y2    = A{klp}(:,10);
            WJSys = A{klp}(:,40);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-4);
        maxX = round(max(x2)+4);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('PORT: Speed %s (Gross thrust): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_THRUST_CCDoTT_PORT = xout;
        
        % Determine percentage of thrust
        [mpc,npc] = size(x2);
        tempArray = [];
        for kpc=1:mpc
            tempArray(kpc) = WJSys(kpc)/x2(kpc);
        end
        meanWJSys = mean(tempArray);
        SPP_THRUST_CCDoTT_PORT = meanWJSys*SPP_THRUST_CCDoTT_PORT;
        
        x3 = SPP_THRUST_CCDoTT_PORT;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Gross thrust (N)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Gross Thrust}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = round(min(x2)-3);
        maxX  = round(max(x2)+3);
        incrX = 1;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,3)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = -2;
        maxx1 = 2;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,15);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,15);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-2);
        maxX = round(max(x2)+2);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('PORT: Speed %s (Torque): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_TORQUE_CCDoTT_PORT = xout;
        
        x3 = SPP_TORQUE_CCDoTT_PORT;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Torque (Nm)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Torque}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-0.1;
        maxX  = max(x2)+0.1;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,4)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 6;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,17);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,17);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-2);
        maxX = round(max(x2)+2);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('PORT: Speed %s (Torque): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        disp('-------------------------------------------------------------------------');
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_KP_CCDoTT_PORT = xout;
        
        x3 = SPP_KP_CCDoTT_PORT;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Kiel probe (V)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Kiel probe}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-0.2;
        maxX  = max(x2)+0.2;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# ********************************************************************
        %# Save plot as PNG
        %# ********************************************************************
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        %if enableA4PaperSizePlot == 1
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
        %end
        
        %# Plot title ---------------------------------------------------------
        %         if enablePlotMainTitle == 1
        %             annotation('textbox', [0 0.9 1 0.1], ...
        %                 'String', strcat('{\bf ', figurename, '}'), ...
        %                 'EdgeColor', 'none', ...
        %                 'HorizontalAlignment', 'center');
        %         end
        
        %# Save plots as PDF, PNG and EPS -------------------------------------
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for k=1:3
            plotsavename = sprintf('_plots/%s/%s/SPP_Plot_0_PORT_Speed_No_%s_Linear_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, num2str(klp), setFileFormat{k});
            print(gcf, setSaveFormat{k}, plotsavename);
        end
        close;
        
        
        %# ********************************************************************
        %# SELF-PROPULSION POINTS (STBD)
        %# ********************************************************************
        figurename = sprintf('Plot 0 (STBD): Speed = %s, Fr = %s, Linear Plots for Self-Propulsion Points (SPP)',num2str(klp),sprintf('%.2f',A{klp}(1,5)));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings ------------------------------------------------
        
        %         if enableA4PaperSizePlot == 1
        %             set(gcf, 'PaperSize', [19 19]);
        %             set(gcf, 'PaperPositionMode', 'manual');
        %             set(gcf, 'PaperPosition', [0 0 19 19]);
        %
        %             set(gcf, 'PaperUnits', 'centimeters');
        %             set(gcf, 'PaperSize', [19 19]);
        %             set(gcf, 'PaperPositionMode', 'manual');
        %             set(gcf, 'PaperPosition', [0 0 19 19]);
        %         end
        
        % Fonts and colours ---------------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        setLegendFontSize  = 12;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. --------------------------------
        set(gca,'TickDir','in',...
            'FontSize',12,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors --------------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Line, colors and markers
        setMarkerSize       = 12;
        setMarkerSize2      = 12;
        setLineWidthMarker  = 2;
        setLineWidth        = 2;
        setLineWidth2       = 1;
        setLineStyle        = '-';
        setLineStyle2       = '-.';
        
        % Towing Force, FD
        TowForceFD = TG_at_FDArray(klp, 3);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,1)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 4000;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,12);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,12);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-300);
        maxX = round(max(x2)+300);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('STBD: Speed %s (Shaft speed): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_RPM_CCDoTT_STBD = xout;
        
        x3 = SPP_RPM_CCDoTT_STBD;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Shaft speed (RPM)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Shaft Speed}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-300;
        maxX  = max(x2)+300;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,2)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 30;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2    = A{klp}(3:6,41);
            y2    = A{klp}(3:6,10);
            WJSys = A{klp}(3:6,41);
        else
            x2    = A{klp}(:,41);
            y2    = A{klp}(:,10);
            WJSys = A{klp}(:,41);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-4);
        maxX = round(max(x2)+4);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('STBD: Speed %s (Gross thrust): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_THRUST_CCDoTT_STBD = xout;
        
        % Determine percentage of thrust
        [mpc,npc] = size(x2);
        tempArray = [];
        for kpc=1:mpc
            tempArray(kpc) = WJSys(kpc)/x2(kpc);
        end
        meanWJSys = mean(tempArray);
        SPP_THRUST_CCDoTT_STBD = meanWJSys*SPP_THRUST_CCDoTT_STBD;
        
        x3 = SPP_THRUST_CCDoTT_STBD;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Gross thrust (N)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Gross Thrust}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = round(min(x2)-3);
        maxX  = round(max(x2)+3);
        incrX = 1;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,3)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = -2;
        maxx1 = 2;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,16);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,16);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-2);
        maxX = round(max(x2)+2);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('STBD: Speed %s (Torque): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_TORQUE_CCDoTT_STBD = xout;
        
        x3 = SPP_TORQUE_CCDoTT_STBD;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Torque (Nm)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Torque}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-0.1;
        maxX  = max(x2)+0.1;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# Subplot ////////////////////////////////////////////////////////////
        subplot(2,2,4)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = 0;
        maxx1 = 6;
        
        x1 = [minx1 maxx1];
        y1 = [TowForceFD TowForceFD];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2 = A{klp}(3:6,18);
            y2 = A{klp}(3:6,10);
        else
            x2 = A{klp}(:,18);
            y2 = A{klp}(:,10);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-2);
        maxX = round(max(x2)+2);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('STBD: Speed %s (Torque): Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        disp('-------------------------------------------------------------------------');
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_KP_CCDoTT_STBD = xout;
        
        x3 = SPP_KP_CCDoTT_STBD;
        y3 = TowForceFD;
        
        %# Plotting -----------------------------------------------------------
        %h1 = plot(fitobject,'-k',x2,y2,'*');
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Kiel probe (V)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Kiel probe}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = min(x2)-0.2;
        maxX  = max(x2)+0.2;
        %incrX = 100;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        %set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        %hleg1 = legend('Towing Force (F_{D})','Model Data','Self-Propulsion Point (SPP)');
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# ********************************************************************
        %# Save plot as PNG
        %# ********************************************************************
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        %         if enableA4PaperSizePlot == 1
        %             set(gcf, 'PaperUnits','centimeters');
        %             set(gcf, 'PaperSize',[XPlot YPlot]);
        %             set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        %             set(gcf, 'PaperOrientation','portrait');
        %         end
        
        %# Plot title ---------------------------------------------------------
        %         if enablePlotMainTitle == 1
        %             annotation('textbox', [0 0.9 1 0.1], ...
        %                 'String', strcat('{\bf ', figurename, '}'), ...
        %                 'EdgeColor', 'none', ...
        %                 'HorizontalAlignment', 'center');
        %         end
        
        %# Save plots as PDF, PNG and EPS -------------------------------------
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for k=1:3
            plotsavename = sprintf('_plots/%s/%s/SPP_Plot_0_STBD_Speed_No_%s_Linear_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, num2str(klp), setFileFormat{k});
            print(gcf, setSaveFormat{k}, plotsavename);
        end
        close;
        
        
        %# ********************************************************************
        %# SELF-PROPULSION POINTS (HEAVE AND TRIM)
        %# ********************************************************************
        figurename = sprintf('Plot 0 (Heave and Trim): Speed = %s, Fr = %s, Linear Plots for Self-Propulsion Points (SPP)',num2str(klp),sprintf('%.2f',A{klp}(1,5)));
        f = figure('Name',figurename,'NumberTitle','off');
        
        %# Paper size settings ------------------------------------------------
        
        %if enableA4PaperSizePlot == 1
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
        
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
        %end
        
        % Fonts and colours ---------------------------------------------------
        setGeneralFontName = 'Helvetica';
        setGeneralFontSize = 14;
        setBorderLineWidth = 2;
        setLegendFontSize  = 12;
        
        %# Change default text fonts for plot title
        set(0,'DefaultTextFontname',setGeneralFontName);
        set(0,'DefaultTextFontSize',14);
        
        %# Box thickness, axes font size, etc. --------------------------------
        set(gca,'TickDir','in',...
            'FontSize',12,...
            'LineWidth',2,...
            'FontName',setGeneralFontName,...
            'Clipping','off',...
            'Color',[1 1 1],...
            'LooseInset',get(gca,'TightInset'));
        
        %# Markes and colors --------------------------------------------------
        setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
        % Colored curves
        setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
        if enableBlackAndWhitePlot == 1
            % Black and white curves
            setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
        end
        
        %# Line, colors and markers
        setMarkerSize       = 12;
        setMarkerSize2      = 12;
        setLineWidthMarker  = 2;
        setLineWidth        = 2;
        setLineWidth2       = 1;
        setLineStyle        = '-';
        setLineStyle2       = '-.';
        
        % Towing Force, FD
        TowForceFD = TG_at_FDArray(klp, 3);
        
        %# SUBPLOT ////////////////////////////////////////////////////////////
        subplot(1,2,1)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = -13;
        maxx1 = 5;
        
        x1 = [minx1 maxx1];
        %y1 = [TowForceFD TowForceFD];
        y1 = [0 0];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2    = A{klp}(3:6,7);
            y2    = A{klp}(3:6,10);
            WJSys = A{klp}(3:6,7);
        else
            x2    = A{klp}(:,7);
            y2    = A{klp}(:,10);
            WJSys = A{klp}(:,7);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-4);
        maxX = round(max(x2)+4);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('Fwd LVDT: Speed %s: Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_FWD_LVDT = xout;
        
        % Determine percentage of thrust
        [mpc,npc] = size(x2);
        tempArray = [];
        for kpc=1:mpc
            tempArray(kpc) = WJSys(kpc)/x2(kpc);
        end
        meanWJSys = mean(tempArray);
        SPP_FWD_LVDT = meanWJSys*SPP_FWD_LVDT;
        
        x3 = SPP_FWD_LVDT;
        y3 = yout;
        
        %# Plotting -----------------------------------------------------------
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Fwd LVDT (mm)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Fwd LVDT}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = round(min(x2)-3);
        maxX  = round(max(x2)+3);
        incrX = 1;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# SUBPLOT ////////////////////////////////////////////////////////////
        subplot(1,2,2)
        
        %# X and Y axis -------------------------------------------------------
        
        % Tow Force, FD
        minx1 = -13;
        maxx1 = 5;
        
        x1 = [minx1 maxx1];
        %y1 = [TowForceFD TowForceFD];
        y1 = [0 0];
        
        % Model Data (omit runs at speed 4 due to bad results)
        if klp == 4
            x2    = A{klp}(3:6,8);
            y2    = A{klp}(3:6,10);
            WJSys = A{klp}(3:6,8);
        else
            x2    = A{klp}(:,8);
            y2    = A{klp}(:,10);
            WJSys = A{klp}(:,8);
        end
        
        % Model data - Linear fit
        [fitobject,gof,output] = fit(x2,y2,'poly1');
        cvalues = coeffvalues(fitobject);
        cnames  = coeffnames(fitobject);
        output  = formula(fitobject);
        
        % Linear fit using defined points
        minX = round(min(x2)-4);
        maxX = round(max(x2)+4);
        MMA  = minX:maxX;
        [mi,ni] = size(MMA);
        LFA  = [];
        for ki=1:ni
            LFA(ki,1) = MMA(ki);
            LFA(ki,2) = cvalues(1)*MMA(ki)+cvalues(2);
        end
        x4 = LFA(:,1);
        y4 = LFA(:,2);
        disp(sprintf('Aft LVDT: Speed %s: Eqn. of fit, y = %sx+%s, R^2=%s',num2str(klp),sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.2f',gof.rsquare)));
        
        % Find intersection of linear fit of model data and towing force, FD
        [xout,yout] = intersections(x1,y1,x4,y4,1);
        
        SPP_AFT_LVDT = xout;
        
        % Determine percentage of thrust
        [mpc,npc] = size(x2);
        tempArray = [];
        for kpc=1:mpc
            tempArray(kpc) = WJSys(kpc)/x2(kpc);
        end
        meanWJSys = mean(tempArray);
        SPP_AFT_LVDT = meanWJSys*SPP_AFT_LVDT;
        
        x3 = SPP_AFT_LVDT;
        y3 = yout;
        
        %# Plotting -----------------------------------------------------------
        h1 = plot(x2,y2,'*',x4,y4,'-');
        legendInfo{1} = 'Model Data';
        legendInfo{2} = 'Model Data - Linear fit';
        hold on;
        h2 = plot(x1,y1,'*',x3,y3,'x');
        legendInfo{3} = 'Towing Force (F_{D})';
        legendInfo{4} = 'Self-Propulsion Point (SPP)';
        xlabel('{\bf Aft LVDT (mm)}','FontSize',setGeneralFontSize);
        ylabel('{\bf Towing force (drag) (N)}','FontSize',setGeneralFontSize);
        title('{\bf Aft LVDT}','FontSize',setGeneralFontSize);
        grid on;
        box on;
        axis square;
        
        %# Line, colors and markers
        set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
        set(h1(2),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth2);
        set(h2(1),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle2,'linewidth',setLineWidth);
        set(h2(2),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
        
        %# Set plot figure background to a defined color
        %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
        set(gcf,'Color',[1,1,1]);
        
        %# Axis limitations
        minX  = round(min(x2)-3);
        maxX  = round(max(x2)+3);
        incrX = 1;
        minY  = round(min(y2))-4;
        maxY  = round(max(y2))+4;
        %incrY = 2;
        set(gca,'XLim',[minX maxX]);
        set(gca,'XTick',minX:incrX:maxX);
        set(gca,'YLim',[minY maxY]);
        %set(gca,'YTick',minY:incrY:maxY);
        %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
        %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
        
        %# Legend
        hleg1 = legend(legendInfo);
        set(hleg1,'Location','SouthWest');
        set(hleg1,'Interpreter','tex');
        set(hleg1,'LineWidth',1);
        set(hleg1,'FontSize',setLegendFontSize);
        %legend boxoff;
        
        %# Font sizes and border ----------------------------------------------
        
        set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
        
        %# ********************************************************************
        %# Save plot as PNG
        %# ********************************************************************
        
        %# Figure size on screen (50% scaled, but same aspect ratio)
        set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
        
        %# Figure size printed on paper
        %if enableA4PaperSizePlot == 1
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
        %end
        
        %# Plot title ---------------------------------------------------------
        %if enablePlotMainTitle == 1
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
        %end
        
        %# Save plots as PDF, PNG and EPS -------------------------------------
        % Enable renderer for vector graphics output
        set(gcf, 'renderer', 'painters');
        setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
        setFileFormat = {'PDF' 'PNG' 'EPS'};
        for k=1:3
            plotsavename = sprintf('_plots/%s/%s/SPP_Plot_0_Heave_Trim_Speed_No_%s_Linear_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, num2str(klp), setFileFormat{k});
            print(gcf, setSaveFormat{k}, plotsavename);
        end
        %close;
        
        
        %# ********************************************************************
        %# WRITE RESULTSARRAY (resSPP_CCDoTT)
        %# ********************************************************************
        
        % resSPP_CCDoTT columns:
        
        % FROUDE LENGTH NUMBER AND TOWING FORCE, FD
        %[1]  Froude length number             (-)
        %[2]  Towing Force, FD                 (N)
        
        % PORT WJ SYSTEM (AT SPP)
        %[3]  Shaft speed                      (RPM)
        %[4]  Gross thrust                     (N)
        %[5]  Torque                           (Nm)
        %[6]  Kiel probe                       (V)
        
        % STARBOARD WJ SYSTEM (AT SPP)
        %[7]  Shaft speed                      (RPM)
        %[8]  Gross thrust                     (N)
        %[9]  Torque                           (Nm)
        %[10] Kiel probe                       (V)
        
        % TOTAL GROSS THRUST
        %[11] Gross thrust at SPP, T@SPP       (N)
        
        % MEAN PORT AND STARBOARD WJ SYSTEM
        %[12] Shaft speed                      (RPM)
        %[13] Gross thrust                     (N)
        %[14] Torque                           (Nm)
        %[15] Kiel probe                       (V)
        
        % AFT AND FWD LVDT, HEAVE AND TRIM
        %[16] Aft LVDT                         (mm)
        %[17] Fwd LVDT                         (mm)
        %[18] Heave                            (mm)
        %[19] Running trim                     (deg)
        
        % THRUST AT ZERO FORCE AND FORCE AT ZERO THRUST
        %[20] Thrust at zero force, TF=0       (N)
        %[21] Force at zero thrust, FT=0       (N)
        %[22] Corrected BH resistance, RC      (N)
        
        % CFm, CFs and CA
        %[23] Model scale: CFm                 (-)
        %[24] Full scale: CFs                  (-)
        %[25] Correlation coefficient, CA      (-)
        %[26] Cross-check towing force, FD     (N)
        
        % FROUDE LENGTH NUMBER AND TOWING FORCE, FD
        resSPP_CCDoTT(klp,1)  = A{klp}(1,5);
        resSPP_CCDoTT(klp,2)  = TowForceFD;
        
        % PORT WJ SYSTEM
        resSPP_CCDoTT(klp,3)  = SPP_RPM_CCDoTT_PORT;
        resSPP_CCDoTT(klp,4)  = SPP_THRUST_CCDoTT_PORT;
        resSPP_CCDoTT(klp,5)  = SPP_TORQUE_CCDoTT_PORT;
        resSPP_CCDoTT(klp,6)  = SPP_KP_CCDoTT_PORT;
        
        % STARBOARD WJ SYSTEM
        resSPP_CCDoTT(klp,7)  = SPP_RPM_CCDoTT_STBD;
        resSPP_CCDoTT(klp,8)  = SPP_THRUST_CCDoTT_STBD;
        resSPP_CCDoTT(klp,9)  = SPP_TORQUE_CCDoTT_STBD;
        resSPP_CCDoTT(klp,10) = SPP_KP_CCDoTT_STBD;
        
        % TOTAL GROSS THRUST
        resSPP_CCDoTT(klp,11) = SPP_THRUST_CCDoTT_TOTAL;
        
        % MEAN PORT AND STARBOARD WJ SYSTEM
        resSPP_CCDoTT(klp,12) = mean([SPP_RPM_CCDoTT_PORT SPP_RPM_CCDoTT_STBD]);
        resSPP_CCDoTT(klp,13) = mean([SPP_THRUST_CCDoTT_PORT SPP_THRUST_CCDoTT_STBD]);
        resSPP_CCDoTT(klp,14) = mean([SPP_TORQUE_CCDoTT_PORT SPP_TORQUE_CCDoTT_STBD]);
        resSPP_CCDoTT(klp,15) = mean([SPP_KP_CCDoTT_PORT SPP_KP_CCDoTT_STBD]);
        
        % AFT AND FWD LVDT, HEAVE AND TRIM
        resSPP_CCDoTT(klp,16) = SPP_FWD_LVDT;
        resSPP_CCDoTT(klp,17) = SPP_AFT_LVDT;
        resSPP_CCDoTT(klp,18) = (SPP_FWD_LVDT+SPP_AFT_LVDT)/2;
        resSPP_CCDoTT(klp,19) = atand((SPP_FWD_LVDT-SPP_AFT_LVDT)/distbetwposts);
        
        % THRUST AT ZERO FORCE AND FORCE AT ZERO THRUST
        resSPP_CCDoTT(klp,20) = 0;
        resSPP_CCDoTT(klp,21) = 0;
        resSPP_CCDoTT(klp,22) = 0;
        
        % CFm, CFs and CA
        resSPP_CCDoTT(klp,23) = 0;
        resSPP_CCDoTT(klp,24) = 0;
        resSPP_CCDoTT(klp,25) = 0;
        resSPP_CCDoTT(klp,26) = 0;
        
        % F_SPP = TF=0-FD
        resSPP_CCDoTT(klp,27) = 0;
        resSPP_CCDoTT(klp,28) = 0;
        
    end % klp=1:ma
    
else
    
    %# As we know that resultsArraySPP.dat exits, read it
    resSPP_CCDoTT = csvread('resultsArraySPP_CCDoTT_SelfPropPointsData.dat');
    
    %# Remove zero rows
    resSPP_CCDoTT(all(resSPP_CCDoTT==0,2),:)=[];
    
end % exist('resultsArraySPP_CCDoTT_SelfPropPointsData.dat', 'file') == 0

%# ************************************************************************
%# START Write results to DAT or TXT file
%# ------------------------------------------------------------------------
M = resSPP_CCDoTT;
%M = M(any(M,2),:);                                                     % remove zero rows only in resultsArraySPP text file
csvwrite('resultsArraySPP_CCDoTT_SelfPropPointsData.dat', M)            % Export matrix M to a file delimited by the comma character
%dlmwrite('resultsArraySPP_CCDoTT_SelfPropPointsData.txt', M, 'delimiter', '\t', 'precision', 4)    % Export matrix M to a file delimited by the tab character and using a precision of four significant digits
%# ------------------------------------------------------------------------
%# END Write results to DAT or TXT file
%# ************************************************************************

%# ************************************************************************
%# END  Linear Plots (CCFoTT Self-Propulsion Points)
%# ************************************************************************


%# ************************************************************************
%# START OVERWRITES
%# ------------------------------------------------------------------------
%# Self-Propulsion Points Based on:
%#   CCDoTT (2007). "Waterjet Data"
%# ************************************************************************
TG_at_FDArray       = [];   % Gross thrust = TG = p Q (vj - vi)
F_at_TGZero         = [];   % Gross thrust = TG = p Q (vj - vi)
FR_at_SPP           = [];   % Flow rates at self-propulsion point (SPP)
thrustDedFracArray  = [];   % Thrust deduction array where TG = p Q (vj - vi)
shaftSpeedConvArray = [];   % Shaft speed array where TG = p Q (vj - vi)
resSPP              = [];   % Summary results of self-propulsion points
for k=1:ma
    
    [mb,nb] = size(A{k});
    
    % Corrected resistance (RC) at current Froude length number -----------
    correctedResistance = resistance(k,3);
    
    %# TG at FD -----------------------------------------------------------
    y1       = A{k}(:,45);   % Gross thrust = TG = p Q vj        (N)
    y2       = A{k}(:,42);   % Gross thrust = TG = p Q (vj - vi) (N)
    
    yPortTQ  = A{k}(:,15);   % PORT: Torque                      (N)
    yStbdTQ  = A{k}(:,16);   % STBD: Torque                      (N)
    
    yPortKP  = A{k}(:,17);   % PORT: Kiel Probe                  (V)
    yStbdKP  = A{k}(:,18);   % STBD: Kiel Probe                  (V)
    
    yPortSS  = A{k}(:,11);   % PORT: Shaft speed                 (PRM)
    yStbdSS  = A{k}(:,12);   % STBD: Shaft speed                 (PRM)
    
    x        = A{k}(:,10);   % Bare hull resistance              (N)
    towForce = A{k}(1,28);   % Towing force, FD                  (N)
    xq       = 0;            % Intersection of x for TG at zero drag
    
    %# --------------------------------------------------------------------
    %# Gross thrust = TG = p Q (vj - vi)
    %# --------------------------------------------------------------------
    polyf               = polyfit(x,y2,1);
    polyv               = polyval(polyf,x);
    ThrustAtZeroDrag    = spline(x,polyv,0);
    ThrustAtSPP         = resSPP_CCDoTT(k,11);
    TG_at_FDArray(k, 1) = ThrustAtZeroDrag;        % Gross thrust, TG   (x-axis)
    TG_at_FDArray(k, 2) = 0;                       % Towing force, Drag (y-axis)
    TG_at_FDArray(k, 3) = resSPP_CCDoTT(k,2);      % Towing force, FD
    TG_at_FDArray(k, 4) = ThrustAtSPP;             % Thrust at self. propulsion point = TG at zero drag - FD
    
    % Towing force at zero gross thrust -----------------------------------
    TowingForceAtZeroThrust = spline(polyv,x,0);
    F_at_TGZero(k, 1) = 0;                         % Gross thrust, TG (x-axis)
    F_at_TGZero(k, 2) = TowingForceAtZeroThrust;   % Towing force     (y-axis)
    
    % Thrust deduction fraction (t) ---------------------------------------
    thrustDedFracArray(k, 1) = Froude_Numbers(k,1);
    % t=(TM+FD-RC)/TM
    thrustDedFracArray(k, 2) = (ThrustAtSPP+towForce-correctedResistance)/ThrustAtSPP;
    % RCW=TG(1-t)+FD ==>> t=1-((RC-FD)/T)
    thrustDedFracArray(k, 3) = 1-((correctedResistance-towForce)/ThrustAtSPP);
    % t = ((FD-FatT=0)/TG@SPP)+1
    thrustDedFracArray(k, 4) = ((towForce-TowingForceAtZeroThrust)/ThrustAtSPP)+1;
    % t = 1-((FatT=0-FD)/TG@SPP)
    thrustDedFracArray(k, 5) = 1-((TowingForceAtZeroThrust-towForce)/ThrustAtSPP);
    
    % Shaft speed at SPP --------------------------------------------------
    
    % shaftSpeedConvArray columns:
    %[1] Froude length number             (-)
    %[2] PORT (MS): Shaft speed at SPP    (RPM)
    %[3] PORT (MS): Shaft speed at SPP    (RPM)
    %[4] PORT (FS): Shaft speed at SPP    (RPM)
    %[5] PORT (FS): Shaft speed at SPP    (RPM)
    
    x = A{k}(:,42);     % Gross thrust = TG = p Q (vj - vi)    (N)
    
    % Port
    MSPortShaftSpeed       = resSPP_CCDoTT(k,3);
    
    % Stbd
    MSStbdShaftSpeed       = resSPP_CCDoTT(k,7);
    
    % Speed array - MS and FS
    shaftSpeedConvArray(k, 1) = Froude_Numbers(k,1);
    shaftSpeedConvArray(k, 2) = MSPortShaftSpeed;
    shaftSpeedConvArray(k, 3) = MSStbdShaftSpeed;
    shaftSpeedConvArray(k, 4) = MSPortShaftSpeed/sqrt(FStoMSratio);
    shaftSpeedConvArray(k, 5) = MSStbdShaftSpeed/sqrt(FStoMSratio);
    
    % Flow Rate at SPP ----------------------------------------------------
    
    % FR_at_SPP columns:
    %[1] Froude length number             (-)
    %[2] PORT (MS): Kiel Probe            (V)
    %[3] STBD (MS): Kiel Probe            (V)
    %[4] PORT (MS): Mass flow rate        (RPM)
    %[5] STBD (MS): Mass flow rate        (RPM)
    %[6] PORT (MS): Volumetric flow rate  (RPM)
    %[7] STBD (MS): Volumetric flow rate  (RPM)
    %[8] PORT (MS): Torque                (Nm)
    %[9] STBD (MS): Torque                (Nm)
    
    x = A{k}(:,42);     % Gross thrust = TG = p Q (vj - vi)    (N)
    
    % Port - Kiel Probe
    PortKPatSPP = resSPP_CCDoTT(k,6);
    
    % Port - Torque
    PortTQatSPP = resSPP_CCDoTT(k,5);
    
    % Stbd - Kiel Probe
    StbdKPatSPP = resSPP_CCDoTT(k,10);
    
    % Stbd - Torque
    StbdTQatSPP = resSPP_CCDoTT(k,9);
    
    MSPortMFR = -0.0421*PortKPatSPP^4+0.5718*PortKPatSPP^3-2.9517*PortKPatSPP^2+7.8517*PortKPatSPP-5.1976;
    MSStbdMFR = -0.0942*StbdKPatSPP^4+1.1216*StbdKPatSPP^3-4.9878*StbdKPatSPP^2+11.0548*StbdKPatSPP-6.8484;
    
    FR_at_SPP(k,1) = Froude_Numbers(k,1);
    FR_at_SPP(k,2) = PortKPatSPP;
    FR_at_SPP(k,3) = StbdKPatSPP;
    FR_at_SPP(k,4) = MSPortMFR;
    FR_at_SPP(k,5) = MSStbdMFR;
    FR_at_SPP(k,6) = MSPortMFR/freshwaterdensity;
    FR_at_SPP(k,7) = MSStbdMFR/freshwaterdensity;
    FR_at_SPP(k,8) = PortTQatSPP;
    FR_at_SPP(k,9) = StbdTQatSPP;
    
    % Add thrust at zero drag, force at zero thrust and resistance to resSPP_CCDoTT
    resSPP_CCDoTT(k,20) = ThrustAtZeroDrag;
    resSPP_CCDoTT(k,21) = TowingForceAtZeroThrust;
    resSPP_CCDoTT(k,22) = resistance(k,3);
    
    % CFm, CFs and CA
    setCFm = A{k}(1,24);
    setCFs = A{k}(1,25);
    setMSSpeed = mean(A{k}(:,6));
    resSPP_CCDoTT(k,23) = setCFm;
    resSPP_CCDoTT(k,24) = setCFs;
    resSPP_CCDoTT(k,25) = CorrCoeff;
    resSPP_CCDoTT(k,26) = 0.5*freshwaterdensity*(setMSSpeed^2)*MSwsa*(FormFactor*(setCFm-setCFs)-CorrCoeff);
    
    % F_SPP = TF=0-FD
    FatSPP = ThrustAtZeroDrag-resSPP_CCDoTT(k,2);
    resSPP_CCDoTT(k,27) = FatSPP;
    resSPP_CCDoTT(k,28) = (1-(FatSPP/resSPP_CCDoTT(k,11)))*100;
    
end % k=1:ma
%# ------------------------------------------------------------------------
%# END OVERWRITES
%# ************************************************************************


%# ************************************************************************
%# START Adjustment of fitting for speeds 6, 8 and 9
%# ------------------------------------------------------------------------
if enableAdjustedFitting == 1
    
    if enableCommandWindowOutput == 1
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        disp('!Adjusted T at F=0 and Slopes Values (Speeds 6, 8 and 9) !');
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    end
    
    %# ********************************************************************
    %# 1. Force at thrust = 0
    %# ********************************************************************
    TG_FD = TG_at_FDArray;
    F_TG  = F_at_TGZero;
    [mftg,nftg] = size(F_TG);
    
    
    %# ********************************************************************
    %# 2. Fitted to measured points
    %# ********************************************************************
    yInt1Prev = F_TG(1,2);
    yInt2Prev = F_TG(2,2);
    yInt3Prev = F_TG(3,2);
    yInt4Prev = F_TG(4,2);
    yInt5Prev = F_TG(5,2);
    yInt6Prev = F_TG(6,2);
    yInt7Prev = F_TG(7,2);
    yInt8Prev = F_TG(8,2);
    yInt9Prev = F_TG(9,2);
    
    % Slopes and Y-intercepts ---------------------------------------------
    slopeInterceptArray = [];
    for kftg=1:mftg
        x = A{kftg}(:,42);
        y = A{kftg}(:,10);
        [fitobject,gof,output]      = fit(x,y,'poly1');
        cvaluesSlopesAndYInt        = coeffvalues(fitobject);
        slopeInterceptArray(kftg,1) = cvaluesSlopesAndYInt(1);
        slopeInterceptArray(kftg,2) = cvaluesSlopesAndYInt(2);
        
        %# Command window
        if enableCommandWindowOutput == 1
            %setDec = '%.2f';
            %disp(sprintf('Speed %s: y = %s*x+%s, R^{2}=%s',num2str(kftg),sprintf(setDec,cvaluesSlopesAndYInt(1)),sprintf(setDec,cvaluesSlopesAndYInt(2)),sprintf(setDec,gof.rsquare)));
        end
    end
    
    
    %# ********************************************************************
    %# 3. Calculate new T at F=0 values and slopes (Speed 6 and 8)
    %# ********************************************************************
    
    % Adjusted Force at Thrust=0 for Speeds 6, 8 and 9
    yInt6Adj = ((yInt7Prev-yInt5Prev)/2)+yInt5Prev;
    yInt8Adj = ((yInt9Prev-yInt7Prev)/2)+yInt7Prev;
    
    % Adjusted Slopes for Speeds 6, 8 and 9
    Slope6Adj = (-1*yInt6Adj)/TG_FD(6,1);
    Slope8Adj = (-1*yInt8Adj)/TG_FD(8,1);
    
    % Adjust/overwrite slopes in slopeInterceptArray using adjusted slopes
    slopeInterceptArray(6,1) = Slope6Adj;
    slopeInterceptArray(8,1) = Slope8Adj;
    slopeInterceptArray(6,2) = yInt6Adj;
    slopeInterceptArray(8,2) = yInt8Adj;
    
    %# ********************************************************************
    %# 4. Plotting Thrust at F=0 vs. Slope of Linear Fit
    %# ********************************************************************
    figurename = 'Plot 1: Thrust at F=0 vs. Slope of Linear Fit';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ------------------------------------------------
    
    if enableA4PaperSizePlot == 1
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
        
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
    end
    
    % Fonts and colours ---------------------------------------------------
    setGeneralFontName = 'Helvetica';
    setGeneralFontSize = 14;
    setBorderLineWidth = 2;
    setLegendFontSize  = 12;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',12,...
        'LineWidth',2,...
        'FontName',setGeneralFontName,...
        'Clipping','off',...
        'Color',[1 1 1],...
        'LooseInset',get(gca,'TightInset'));
    
    %# Markes and colors --------------------------------------------------
    setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Set marker and line sizes
    setMarkerSize      = 12;
    setMarkerSize2     = 9;
    setLineWidthMarker = 2;
    setLineWidth       = 1;
    setLineStyle       = '-';
    
    %# X and Y axis values ------------------------------------------------
    x_1 = TG_FD(1:8,1);
    y_1 = slopeInterceptArray(1:8,1);
    
    % Linear fit ----------------------------------------------------------
    [fitobject,gof,output] = fit(x_1,y_1,'poly1');
    cvaluesTF0vsSlope      = coeffvalues(fitobject);
    
    %# Command window
    if enableCommandWindowOutput == 1
        setDec = '%.3f';
        disp(sprintf('Thrust at F=0 vs. Slope of Linear Fit: y = %s*x+%s, R^{2}=%s',sprintf(setDec,cvaluesTF0vsSlope(1)),sprintf(setDec,cvaluesTF0vsSlope(2)),sprintf(setDec,gof.rsquare)));
    end
    
    %# Plotting -----------------------------------------------------------
    h = plot(fitobject,'k-',x_1,y_1,'*');
    xlabel('{\bf Thrust at F=0, T_{F=0} (N)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Slope of Lineat Fit (-)}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color ----------------------
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Axis limitations ---------------------------------------------------
    
    minX  = round(min(x_1)-1);
    maxX  = round(max(x_1)+1);
    if mod(maxX-minX,2) == 0
        incrX = 2;
    else
        incrX = 1;
    end
    minY  = -2;
    maxY  = 0;
    incrY = 0.4;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend -------------------------------------------------------------
    %hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('Data','Linear Fit');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border ----------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Save plot as PNG ---------------------------------------------------
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    if enableA4PaperSizePlot == 1
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
    end
    
    %# Plot title ---------------------------------------------------------
    if enablePlotMainTitle == 1
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
    end
    
    %# Save plots as PDF, PNG and EPS -------------------------------------
    minRun = min(resultsArraySPP(:,1));
    maxRun = max(resultsArraySPP(:,1));
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for kl=1:3
        plotsavename = sprintf('_plots/%s/%s/SPP_Plot_1_MS_Thrust_at_F_0_vs_Slope_of_Linear_Fit_Plot.%s', 'SPP_CCDoTT', setFileFormat{kl}, setFileFormat{kl});
        print(gcf, setSaveFormat{kl}, plotsavename);
    end
    close;
    
    
    %# ********************************************************************
    %# 5. Adjusted values from measured points (Speed 9)
    %# ********************************************************************
    
    Slope9Adj                = cvaluesTF0vsSlope(1)*TG_FD(9,1)+cvaluesTF0vsSlope(2);
    yInt9Adj                 = (Slope9Adj*TG_FD(9,1))*-1;
    slopeInterceptArray(9,1) = Slope9Adj;
    slopeInterceptArray(9,2) = yInt9Adj;
    
    %# Command window
    if enableCommandWindowOutput == 1
        disp(sprintf('Speed 6 (Adj. F at T=0) = %s, Speed 8 (Adj. F at T=0) = %s, Speed 9 (Adj. F at T=0) = %s',num2str(yInt6Adj),num2str(yInt8Adj),num2str(yInt9Adj)));
        disp(sprintf('Speed 6 (Slope) = %s, Speed 8 (Slope) = %s, Speed 0 (Slope) = %s',num2str(Slope6Adj),num2str(Slope8Adj),num2str(Slope9Adj)));
    end
    
    
    %# ********************************************************************
    %# 6. Exchange T at F=0 original with adjusted values (Speeds 6, 8 & 9)
    %# ********************************************************************
    
    F_at_TGZero(6,2) = yInt6Adj;
    F_at_TGZero(8,2) = yInt8Adj;
    F_at_TGZero(9,2) = yInt9Adj;
    
    % resSPP_CCDoTT overwrites
    resSPP_CCDoTT(6,21) = yInt6Adj;
    resSPP_CCDoTT(8,21) = yInt8Adj;
    resSPP_CCDoTT(9,21) = yInt9Adj;
    
    %# ********************************************************************
    %# 7. Overwrite thrust deduction fraction values
    %# ********************************************************************
    
    % thrustDedFracArray Columns:
    % [1] Froude_Length Number
    % [2] t=(TM+FD-RC)/TM
    % [3] RCW=TG(1-t)+FD ==>> t=1-((RC-FD)/T)
    % [4] t = ((FD-FatT=0)/TG@SPP)+1
    % [5] t = 1-((FatT=0-FD)/TG@SPP)
    % [6] t based on slope
    for ktd=1:mftg
        % t=(TM+FD-RC)/TM
        thrustDedFracArray(k, 2) = (TG_at_FDArray(ktd, 4)+TG_at_FDArray(ktd, 3)-resistance(ktd,3))/TG_at_FDArray(ktd, 4);
        
        % RCW=TG(1-t)+FD ==>> t=1-((RC-FD)/T)
        thrustDedFracArray(k, 3) = 1-((resistance(ktd,3)-TG_at_FDArray(ktd, 3))/TG_at_FDArray(ktd, 4));
        
        % t=((FD-FatT=0)/TG@SPP)+1
        thrustDedFracArray(ktd, 4) = ((TG_at_FDArray(ktd, 3)-F_at_TGZero(ktd, 2))/TG_at_FDArray(ktd, 4))+1;
        
        % t=1-((FatT=0-FD)/TG@SPP)
        thrustDedFracArray(ktd, 5) = 1-((F_at_TGZero(ktd, 2)-TG_at_FDArray(ktd, 3))/TG_at_FDArray(ktd, 4));
        
        %disp(sprintf('(2): Fr = %s, t=(TM+FD-RC)/TM => t=(%s+%s-%s)/%s=%s',num2str(Froude_Numbers(ktd,1)),num2str(TG_at_FDArray(ktd, 4)),num2str(+TG_at_FDArray(ktd, 3)),num2str(resistance(ktd,3)),num2str(TG_at_FDArray(ktd, 4)),num2str(thrustDedFracArray(k, 2))));
        %disp(sprintf('(3): Fr = %s, t=1-((RC-FD)/T) => t=1-((%s-%s)/%s)=%s',num2str(Froude_Numbers(ktd,1)),num2str(resistance(ktd,3)),num2str(TG_at_FDArray(ktd, 3)),num2str(TG_at_FDArray(ktd, 4)),num2str(thrustDedFracArray(k, 3))));
        %disp(sprintf('(4): Fr = %s, t=((FD-FatT=0)/TG@SPP)+1 => t=((%s-%s)/%s)+1=%s',num2str(Froude_Numbers(ktd,1)),num2str(TG_at_FDArray(ktd, 3)),num2str(F_at_TGZero(ktd, 2)),num2str(TG_at_FDArray(ktd, 4)),num2str(thrustDedFracArray(k, 4))));
        %disp(sprintf('(5): Fr = %s, t=1-((FatT=0-FD)/TG@SPP) => t=1-((%s-%s)/%s)=%s',num2str(Froude_Numbers(ktd,1)),num2str(F_at_TGZero(ktd, 2)),num2str(TG_at_FDArray(ktd, 3)),num2str(TG_at_FDArray(ktd, 4)),num2str(thrustDedFracArray(k, 5))));
    end % ktd=1:mftg
    
end % enableAdjustedFitting
%# ------------------------------------------------------------------------
%# END Adjustment of fitting for speeds 6, 8 and 9
%# ************************************************************************


%# ************************************************************************
%# 2. Self-Propulsion Points: Gross Thrust vs. Towing Force
%# ************************************************************************
%# Only plot if all (9) datasets are available
if ma == 9
    
    % TG = p Q vj
    slopesArrayA = [];
    % TG = p Q (vj - vi)
    slopesArrayB = [];
    
    %# Plotting gross thrust vs. towing force -----------------------------
    figurename = 'Plot 2: Self-Propulsion Points: Gross Thrust vs. Towing Force';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ------------------------------------------------
    
    if enableA4PaperSizePlot == 1
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
        
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperSize', [19 19]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 19 19]);
    end
    
    % Fonts and colours ---------------------------------------------------
    setGeneralFontName = 'Helvetica';
    setGeneralFontSize = 14;
    setBorderLineWidth = 2;
    setLegendFontSize  = 12;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. --------------------------------
    set(gca,'TickDir','in',...
        'FontSize',12,...
        'LineWidth',2,...
        'FontName',setGeneralFontName,...
        'Clipping','off',...
        'Color',[1 1 1],...
        'LooseInset',get(gca,'TightInset'));
    
    %# Markes and colors ------------------------------------------------------
    setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Set marker and line sizes
    setMarkerSize      = 12;
    setMarkerSize1     = 8;
    setMarkerSize2     = 6;
    setLineWidthMarker = 1;
    setLineWidth       = 1;
    setLineStyle       = '-';
    
    %# Gross thrust = TG = p Q (vj - vi) ----------------------------------
    
    %# X and Y axes data, create variables for speeds 1 to 9
    %# Note for future self: Next time use structures or arrays!!!!
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Equation of fit (EoF) for towing force vs. thrust plot  !');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    AdjSlopeArray = [];
    for k=1:ma
        
        % X and Y axis
        x = A{k}(:,42);
        y = A{k}(:,10);
        eval(sprintf('x%d = x;', k));
        eval(sprintf('y%d = y;', k));
        
        if enableAdjustedFitting == 1
            % Record slopes
            slopesArrayB(k,1) = Froude_Numbers(k,1);
            slopesArrayB(k,2) = slopeInterceptArray(k,1);
            slopesArrayB(k,3) = slopeInterceptArray(k,1)+1;
            setDec = '%.3f';
            disp(sprintf('Speed %s (TG = p QJ (vj - vi)): Equation of fit = %sx%s',num2str(k),sprintf(setDec,slopeInterceptArray(k,1)),sprintf(setDec,slopeInterceptArray(k,2))));
            
            % Extend linear fit using equation of fit
            xx = [0:1:35];
            [mxx,nxx] = size(xx);
            yy = [];
            for kxx=1:nxx
                yy(kxx) = slopeInterceptArray(k,1)*xx(kxx)+F_at_TGZero(k,2);
                %disp(sprintf('Speed %s: EoF = %s*%s+%s',num2str(k),sprintf(setDec,slopeInterceptArray(k,1)),num2str(kxx),sprintf(setDec,F_at_TGZero(k,2))));
            end
            eval(sprintf('xLF%d = xx;', k));
            eval(sprintf('yLF%d = yy;', k));
        else
            % Linear fit
            P = polyfit(x,y,1);
            V = polyval(P,x);
            eval(sprintf('polyv%d = V;', k));
            % Record slopes
            % Columns:
            %[1]  Froude number                 (-)
            %[2]  Slope (i.e. -(1-t))           (-)
            %[3]  Thrust deduction, t           (-)
            if P(2) < 0
                setDecimals = '%0.3f';
            else
                setDecimals = '+%0.3f';
            end
            slopesArrayB(k,1) = Froude_Numbers(k,1);
            slopesArrayB(k,2) = P(1);
            slopesArrayB(k,3) = P(1)+1;
            disp(sprintf('Speed %s (TG = p QJ (vj - vi)): Equation of fit = %sx%s',num2str(k),sprintf('%0.3f',P(1)),sprintf(setDecimals,P(2))));
            
            % Extend linear fit using equation of fit
            xx = 0:max(x)*1.1;
            yy = P(1)*xx+P(2);
            eval(sprintf('xLF%d = xx;', k));
            eval(sprintf('yLF%d = yy;', k));
        end % enableAdjustedFitting
        
        % Start Add to thrustDedFracArray -------------------------------------
        [fitobject,gof,output]   = fit(xx',yy','poly1');
        cvalues                  = coeffvalues(fitobject);
        AdjSlopeArray(k,1)       = Froude_Numbers(k,1);
        AdjSlopeArray(k,2)       = cvalues(1);
        AdjSlopeArray(k,3)       = cvalues(1)+1;
        thrustDedFracArray(k, 6) = cvalues(1)+1;
        % End Add to thrustDedFracArray ---------------------------------------
        
    end % k=1:ma
    
    %# Plotting
    h1 = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*',x7,y7,'*',x8,y8,'*',x9,y9,'*');
    %# Gross thrus TG at towing force FD
    if enableTowingForceFDPlot == 1
        hold on;
        h3 = plot(TG_at_FDArray(:,1),TG_at_FDArray(:,2),'o');
        hold on;
        %# Towing force at zero thrust
        h5 = plot(F_at_TGZero(:,1),F_at_TGZero(:,2),'s');
    end
    hold on;
    %# Extended linear fit
    h4 = plot(xLF1,yLF1,xLF2,yLF2,xLF3,yLF3,xLF4,yLF4,xLF5,yLF5,xLF6,yLF6,xLF7,yLF7,xLF8,yLF8,xLF9,yLF9);
    if enablePlotTitle == 1
        title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
    end
    xlabel('{\bf Gross thrust, T_{G} (N)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Towing force (N)}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    %axis square;
    
    %# Font sizes and border
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Line, colors and markers
    % setMarker = {'+';'^';'s';'v';'>';'o';'<';'p';'h';'x';'*'};
    setSpeed=1;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setSpeed=2;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{10},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setSpeed=3;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{11},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    setSpeed=4;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{2},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
    setSpeed=5;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{3},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
    setSpeed=6;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{4},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
    setSpeed=7;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{5},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
    setSpeed=8;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{6},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
    setSpeed=9;set(h1(setSpeed),'Color',setColor{setSpeed},'Marker',setMarker{7},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
    
    %# Extended linear curve fit
    if enableTowingForceFDPlot == 1
        setMarkerSize      = 12;
        setLineWidthMarker = 2;
        set(h3(1),'Color',setColor{10},'Marker',setMarker{3},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10}); %,'MarkerFaceColor',setColor{10}
        set(h5(1),'Color',setColor{10},'Marker',setMarker{6},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker,'MarkerFaceColor',setColor{10});
    end
    
    setSpeed=1;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=2;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=3;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=4;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=5;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=6;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=7;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=8;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    setSpeed=9;set(h4(setSpeed),'Color',setColor{setSpeed},'LineStyle',setLineStyle,'linewidth',setLineWidth);
    
    %# Axis limitations
    minX  = 0;
    maxX  = 35;
    incrX = 5;
    minY  = -5;
    maxY  = 30;
    incrY = 5;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    %set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));
    
    %# Legend
    %hleg1 = legend('Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
    hleg1 = legend('F_{r}=0.24','F_{r}=0.26','F_{r}=0.28','F_{r}=0.30','F_{r}=0.32','F_{r}=0.34','F_{r}=0.36','F_{r}=0.38','F_{r}=0.40');
    set(hleg1,'Location','NorthEast');
    set(hleg1,'Interpreter','None');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    if enableTowingForceFDPlot == 1
        [LEGH,OBJH,OUTH,OUTM] = legend;
        legend([OUTH;h3],OUTM{:},'Thrust at F=0');
        [LEGH,OBJH,OUTH,OUTM] = legend;
        legend([OUTH;h5],OUTM{:},'Force at T=0');
    end
    %legend boxoff;
    
    %# ********************************************************************
    %# Save plot as PNG
    %# ********************************************************************
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    if enableA4PaperSizePlot == 1
        set(gcf, 'PaperUnits','centimeters');
        set(gcf, 'PaperSize',[XPlot YPlot]);
        set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
        set(gcf, 'PaperOrientation','portrait');
    end
    
    %# Plot title ---------------------------------------------------------
    if enablePlotMainTitle == 1
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', strcat('{\bf ', figurename, '}'), ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
    end
    
    %# Save plots as PDF, PNG and EPS -------------------------------------
    minRun = min(resultsArraySPP(:,1));
    maxRun = max(resultsArraySPP(:,1));
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/SPP_Plot_2_MS_Thrust_vs_Towing_Force_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    % ---------------------------------------------------------------------
    % Display gross thrust at towing force, FD
    % ---------------------------------------------------------------------
    
    %# Gross thrust = TG = p Q (vj - vi) ----------------------------------
    
    %TG_at_FDArray = TG_at_FDArray';
    [mc,nc] = size(TG_at_FDArray);
    
    TG_and_F_at_T0 = [];
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Self-propulsion points at model scale                   !');
    disp('!Gross thrust (TG = p Q (vj - vi)) at towing force, FD   !');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    for k=1:mc
        disp1 = A{k}(1,5);
        disp2 = TG_at_FDArray(k, 1);
        disp3 = F_at_TGZero(k, 2);
        disp4 = TG_at_FDArray(k, 4);
        TF    = TG_at_FDArray(k, 3);
        
        % Froude length number
        TG_and_F_at_T0(k,1) = disp1;
        
        % TG at zero drag
        TG_and_F_at_T0(k,2) = disp2;
        
        % Towing force at zero thrust
        TG_and_F_at_T0(k,3) = disp3;
        
        % Thrust at self-propulsion point TG=TG@F=0-FD
        TG_and_F_at_T0(k,4) = disp4;
        
        % Towing force, FD
        TG_and_F_at_T0(k,5) = TF;
        
        dispString = sprintf('Fr = %s; TG at zero drag = %sN; Towing force (FD) = %sN; TG at SPP: %sN; F at zero T = %sN',sprintf('%.2f',disp1),sprintf('%.2f',disp2),sprintf('%.2f',TF),sprintf('%.2f',disp4),sprintf('%.2f',disp3));
        disp(dispString);
    end
    
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!Plotting not possible as dataset is not complete (i.e. data for 9 speeds)!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
end

%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 3. Thrust deduction fractions
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

%# ************************************************************************
%# START Load MARIN Data (variable name is Marin112mJHSVData by default)
%# ------------------------------------------------------------------------
if exist('Marin112mJHSVData.mat', 'file') == 2
    % Load file into shaftSpeedList variable
    load('Marin112mJHSVData.mat');
    %# Results array columns:
    %[1]  Full scale ship speed          (knots)
    %[2]  Full scale ship speed          (m/s)
    %[3]  Model scale ship speed         (m/s)
    %[4]  Froude length number           (-)
    %[5]  Thrust deduction fraction, t   (-)
    %[6]  Thrust deduction factor, (1-t) (-)
    
    %# Conditions:
    %# T5 (datasets 1-28)
    %# T5 (datasets 29-54)
else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('WARNING: Required data file for MARIN 112m JHSV data (Marin112mJHSVData.mat) does not exist!');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    break;
end
%# ------------------------------------------------------------------------
%# END Load MARIN Data (variable name is Marin112mJHSVData by default)
%# ************************************************************************


%# ************************************************************************
%# 3. Thrust Deduction Fractions
%# ************************************************************************
%# Plotting gross thrust vs. towing force ---------------------------------
figurename = 'Plot 3: Thrust Deduction Fractions';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 11;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineStyle1      = '--';
setLineStyle2      = '-.';

%# Gross thrust = TG = p Q (vj - vi) --------------------------------------

%# X and Y axis data
mx1 = Marin112mJHSVData(1:28,4);
my1 = Marin112mJHSVData(1:28,5);

mx2 = Marin112mJHSVData(29:54,4);
my2 = Marin112mJHSVData(29:54,5);

% t based on slope
%tx1 = slopesArrayB(:,1);
%ty1 = slopesArrayB(:,3);
tx1 = AdjSlopeArray(:,1);
ty1 = AdjSlopeArray(:,3);

% t=(TM+FD-RC)/TM
tx2 = thrustDedFracArray(:,1);
ty2 = thrustDedFracArray(:,2);

% RCW=TG(1-t)+FD ==>> t=1-((RCW-FD)/T)
tx3 = thrustDedFracArray(:,1);
ty3 = thrustDedFracArray(:,3);

% t = ((FD-FatT=0)/TG@SPP)+1
tx4 = thrustDedFracArray(:,1);
ty4 = thrustDedFracArray(:,4);

% t = 1-((FatT=0-FD)/TG@SPP)
tx5 = thrustDedFracArray(:,1);
ty5 = thrustDedFracArray(:,5);

% Calculate full scale thrust deduction based on t=(T-RT)/T ---------------

% Resistance fitting
[fitobject,gof,output] = fit(ResResults(:,1),ResResults(:,16),'poly5');
cvalues                = coeffvalues(fitobject);

% Froude length numbers
FRArray     = thrustDedFracArray(:,1);
[mres,nres] = size(FRArray);

% tempThrustDedArray columns:
%[1] Froude length number                       (-)
%[2] Total catamaran: Full scale resistance     (N)
%[3] Total catamaran: Total thrust              (N)
% t=(T-RT)/T
%[4] Thrust deduction fraction, t               (-)
%[5] Thrust deduction fraction, (1-t)           (-)
% t=1-(RBH/T)
%[6] Thrust deduction fraction, t               (-)
%[7] Thrust deduction fraction, (1-t)           (-)
for kres=1:mres
    
    % Stbd to port ratio
    if kres == 4
        ratioRow = 3;
    else
        ratioRow = 1;
    end
    
    % Model scale thrust at SPP
    MSThrustAtSPP = TG_at_FDArray(kres,4);
    
    % Model Scale - Split to Port and Stbd values
    PortStbdRatio        = A{kres}(ratioRow,40)/A{kres}(ratioRow,42);
    MSPortGrosThrust     = MSThrustAtSPP*PortStbdRatio;
    PortStbdRatio        = A{kres}(ratioRow,41)/A{kres}(ratioRow,42);
    MSStbdGrosThrust     = MSThrustAtSPP*PortStbdRatio;
    
    % Full Scale - Split to Port and Stbd values
    % NOTE: Neglect run 70 and 71 (as faulty)
    PortStbdRatio        = A{kres}(ratioRow,40)/A{kres}(ratioRow,42);
    FSPortGrosThrust     = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    PortStbdRatio        = A{kres}(ratioRow,41)/A{kres}(ratioRow,42);
    FSStbdGrosThrust     = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    
    TempFittedResistance = cvalues(1)*FRArray(kres,1)^5+cvalues(2)*FRArray(kres,1)^4+cvalues(3)*FRArray(kres,1)^3+cvalues(4)*FRArray(kres,1)^2+cvalues(5)*FRArray(kres,1)+cvalues(6);
    TempTotalCatThrust   = (FSPortGrosThrust+FSStbdGrosThrust)*2;
    TempThrustDedFrac    = (TempTotalCatThrust-TempFittedResistance)/TempTotalCatThrust;
    
    tempThrustDedArray(kres,1) = FRArray(kres,1);
    tempThrustDedArray(kres,2) = TempFittedResistance;
    tempThrustDedArray(kres,3) = TempTotalCatThrust;
    
    % t=(T-RT)/T
    tempThrustDedArray(kres,4) = TempThrustDedFrac;
    tempThrustDedArray(kres,5) = 1-TempThrustDedFrac;
    
    % RBH=(1-t)T => t=1-(RBH/T)
    TempThrustDedFrac = 1-(TempFittedResistance/TempTotalCatThrust);
    tempThrustDedArray(kres,6) = TempThrustDedFrac;
    tempThrustDedArray(kres,7) = 1-TempThrustDedFrac;
    
end % kres=1:mres

% Full scale: t=(T-RT)/T
xt = tempThrustDedArray(:,1);
yt = tempThrustDedArray(:,4);

% Full scale: RBH=(1-t)T => t=1-(RBH/T)
xs = tempThrustDedArray(:,1);
ys = tempThrustDedArray(:,6);

%# Plotting ---------------------------------------------------------------
h = plot(tx1,ty1,'*',tx4,ty4,'*',tx5,ty5,'*',tx2,ty2,'*',tx3,ty3,'*',xt,yt,'*',xs,ys,'*',mx1,my1,'-',mx2,my2,'-');
if enablePlotTitle == 1
    title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust deduction fraction, t (N)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Font sizes and border
set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
% Text on plot
text(0.43,-0.43,'Legend:','FontSize',12,'color','k','FontWeight','bold');
text(0.43,-0.49,'MS = Model scale','FontSize',12,'color','k','FontWeight','normal');
text(0.43,-0.55,'FS = Full scale','FontSize',12,'color','k','FontWeight','normal');

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize); %,'LineWidth',setLineWidthMarker
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize);
set(h(3),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize);
set(h(4),'Color',setColor{4},'Marker',setMarker{2},'MarkerSize',setMarkerSize);
set(h(5),'Color',setColor{5},'Marker',setMarker{6},'MarkerSize',setMarkerSize);
% Full scale: t=(T-RT)/T
set(h(6),'Color',setColor{6},'Marker',setMarker{3},'MarkerSize',setMarkerSize);
% Full scale: RBH=(1-t)T => t=1-(RBH/T)
set(h(7),'Color',setColor{7},'Marker',setMarker{8},'MarkerSize',setMarkerSize);
% MARIN data
set(h(8),'Color',setColor{10},'LineStyle',setLineStyle1,'linewidth',setLineWidth);
set(h(9),'Color',setColor{10},'LineStyle',setLineStyle2,'linewidth',setLineWidth);

%# Axis limitations
minX  = 0.14;
maxX  = 0.54; % 0.7
incrX = 0.05;
minY  = -0.6;
maxY  = 0.6;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('98m (MS) t by slope','98m (MS) F=T_{M}(t-1)+F_{at T=0}','98m (MS) F_{M}=F_{at T=0}-T_{M}(1-t)','98m (MS) t=(T_{M}+F_{D}-R_{C})/T_{M}','98m (MS) using R_{CW}=T_{G}(1-t)+F+{D}','98m (FS) t=(T-R_{T})/T','98m (FS) RBH=(1-t)T => t=1-(RBH/T)','112m MARIN JHSV Cond. T5','112m MARIN JHSV Cond. T4');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','Tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_3_MS_Fr_vs_Thrust_Deduction_Fraction_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 3.1 Thrust Deduction Fractions (without MARIN comparison data)
%# ************************************************************************
%# Plotting gross thrust vs. towing force ---------------------------------
figurename = 'Plot 3.1: Thrust Deduction Fractions (without MARIN comparison data)';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 2;
setLineWidth       = 1;
setLineStyle1      = '--';
setLineStyle2      = '-.';

%# Gross thrust = TG = p Q (vj - vi) --------------------------------------

% t based on slope
%tx1 = slopesArrayB(:,1);
%ty1 = slopesArrayB(:,3);
tx1 = AdjSlopeArray(:,1);
ty1 = AdjSlopeArray(:,3);

% t=(TM+FD-RC)/TM
tx2 = thrustDedFracArray(:,1);
ty2 = thrustDedFracArray(:,2);

% RCW=TG(1-t)+FD ==>> t=1-((RCW-FD)/T)
tx3 = thrustDedFracArray(:,1);
ty3 = thrustDedFracArray(:,3);

% t = ((FD-FatT=0)/TG@SPP)+1
tx4 = thrustDedFracArray(:,1);
ty4 = thrustDedFracArray(:,4);

% t = 1-((FatT=0-FD)/TG@SPP)
tx5 = thrustDedFracArray(:,1);
ty5 = thrustDedFracArray(:,5);

% Calculate full scale thrust deduction based on t=(T-RT)/T ---------------

% Resistance fitting
[fitobject,gof,output] = fit(ResResults(:,1),ResResults(:,16),'poly5');
cvalues                = coeffvalues(fitobject);

% Froude length numbers
FRArray     = thrustDedFracArray(:,1);
[mres,nres] = size(FRArray);

% tempThrustDedArray columns:
%[1] Froude length number                       (-)
%[2] Total catamaran: Full scale resistance     (N)
%[3] Total catamaran: Total thrust              (N)
% t=(T-RT)/T
%[4] Thrust deduction fraction, t               (-)
%[5] Thrust deduction fraction, (1-t)           (-)
% t=1-(RBH/T)
%[6] Thrust deduction fraction, t               (-)
%[7] Thrust deduction fraction, (1-t)           (-)
for kres=1:mres
    
    % Stbd to port ratio
    if kres == 4
        ratioRow = 3;
    else
        ratioRow = 1;
    end
    
    % Model scale thrust at SPP
    MSThrustAtSPP = TG_at_FDArray(kres,4);
    
    % Model Scale - Split to Port and Stbd values
    PortStbdRatio        = A{kres}(ratioRow,40)/A{kres}(ratioRow,42);
    MSPortGrosThrust     = MSThrustAtSPP*PortStbdRatio;
    PortStbdRatio        = A{kres}(ratioRow,41)/A{kres}(ratioRow,42);
    MSStbdGrosThrust     = MSThrustAtSPP*PortStbdRatio;
    
    % Full Scale - Split to Port and Stbd values
    % NOTE: Neglect run 70 and 71 (as faulty)
    PortStbdRatio        = A{kres}(ratioRow,40)/A{kres}(ratioRow,42);
    FSPortGrosThrust     = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    PortStbdRatio        = A{kres}(ratioRow,41)/A{kres}(ratioRow,42);
    FSStbdGrosThrust     = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    
    TempFittedResistance = cvalues(1)*FRArray(kres,1)^5+cvalues(2)*FRArray(kres,1)^4+cvalues(3)*FRArray(kres,1)^3+cvalues(4)*FRArray(kres,1)^2+cvalues(5)*FRArray(kres,1)+cvalues(6);
    TempTotalCatThrust   = (FSPortGrosThrust+FSStbdGrosThrust)*2;
    TempThrustDedFrac    = (TempTotalCatThrust-TempFittedResistance)/TempTotalCatThrust;
    
    tempThrustDedArray(kres,1) = FRArray(kres,1);
    tempThrustDedArray(kres,2) = TempFittedResistance;
    tempThrustDedArray(kres,3) = TempTotalCatThrust;
    
    % t=(T-RT)/T
    tempThrustDedArray(kres,4) = TempThrustDedFrac;
    tempThrustDedArray(kres,5) = 1-TempThrustDedFrac;
    
    % RBH=(1-t)T => t=1-(RBH/T)
    TempThrustDedFrac = 1-(TempFittedResistance/TempTotalCatThrust);
    tempThrustDedArray(kres,6) = TempThrustDedFrac;
    tempThrustDedArray(kres,7) = 1-TempThrustDedFrac;
    
end % kres=1:mres

% Full scale: t=(T-RT)/T
xt = tempThrustDedArray(:,1);
yt = tempThrustDedArray(:,4);

% Full scale: RBH=(1-t)T => t=1-(RBH/T)
xs = tempThrustDedArray(:,1);
ys = tempThrustDedArray(:,6);

%# Plotting ---------------------------------------------------------------
h = plot(tx1,ty1,'*',tx4,ty4,'*',tx5,ty5,'*',tx2,ty2,'*',tx3,ty3,'*',xt,yt,'*',xs,ys,'*');
if enablePlotTitle == 1
    title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust deduction fraction, t (N)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Font sizes and border
set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Annotations
% Text on plot
text(0.43,-0.43,'Legend:','FontSize',12,'color','k','FontWeight','bold');
text(0.43,-0.49,'MS = Model scale','FontSize',12,'color','k','FontWeight','normal');
text(0.43,-0.55,'FS = Full scale','FontSize',12,'color','k','FontWeight','normal');

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize); %,'LineWidth',setLineWidthMarker
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize);
set(h(3),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize);
set(h(4),'Color',setColor{4},'Marker',setMarker{2},'MarkerSize',setMarkerSize);
set(h(5),'Color',setColor{5},'Marker',setMarker{6},'MarkerSize',setMarkerSize);
% Full scale: t=(T-RT)/T
set(h(6),'Color',setColor{6},'Marker',setMarker{3},'MarkerSize',setMarkerSize);
% Full scale: RBH=(1-t)T => t=1-(RBH/T)
set(h(7),'Color',setColor{7},'Marker',setMarker{8},'MarkerSize',setMarkerSize);

%# Axis limitations
minX  = 0.14;
maxX  = 0.54; % 0.7
incrX = 0.05;
minY  = -0.6;
maxY  = 0.6;
incrY = 0.2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('98m (MS) t by slope','98m (MS) F=T_{M}(t-1)+F_{at T=0}','98m (MS) F_{M}=F_{at T=0}-T_{M}(1-t)','98m (MS) t=(T_{M}+F_{D}-R_{C})/T_{M}','98m (MS) R_{CW}=T_{G}(1-t)+F+{D}','98m (FS) t=(T-R_{T})/T','98m (FS) R_{BH}=(1-t)T => t=1-(R_{BH}/T)');
set(hleg1,'Location','NorthEast');
set(hleg1,'Interpreter','Tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_3_1_MS_Fr_vs_Thrust_Deduction_Fraction_without_MARIN_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 4. Resistance vs. TG at Towing Force (FD) and F at zero Thrust (FT=0)
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

%# Plotting gross thrust vs. towing force ---------------------------------
figurename = 'Plot 4: Resistance vs. Gross Thrust at Towing Force F_{D} and Force at Zero Thrust F_{T=0}';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize1     = 12;
setMarkerSize2     = 11;
setLineWidth       = 2;
setLineWidthMarker = 1;
setLineStyle       = '-';

%# Gross thrust = TG = p Q (vj - vi) --------------------------------------

%# X and Y axis data
TA = TG_and_F_at_T0;

% Resistance uncorrected
%xr = resistance(:,1);
%yr = resistance(:,2);

% Resistance corrected for temp. diff. RES and SPT test
xr = resistance(:,1);
yr = resistance(:,3);

% TG at zero drag
x1 = TA(:,1);
y1 = TA(:,2);

% Towing force at zero thrust
x2 = TA(:,1);
y2 = TA(:,3);

% Thrust at self-propulsion point TG=TG@F=0-FD
x3 = TA(:,1);
y3 = TA(:,4);

% Towing force, FD
x4 = TA(:,1);
y4 = TA(:,5);

%# Plotting
h1 = plot(xr,yr,x1,y1,'s',x2,y2,'*',x3,y3,'o',x4,y4,'^');
if enablePlotTitle == 1
    title('{\bf Gross thrust defined as T_{G} = p Q (v_{j} - v_{i})}','FontSize',setGeneralFontSize);
end
xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Towing force, force at T=0 and gross thrust (N)}','FontSize',setGeneralFontSize);
grid on;
box on;
axis square;

%# Font sizes and border
set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Line, colors and markers
set(h1(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h1(2),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize1,'LineWidth',setLineWidthMarker);
set(h1(3),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
set(h1(4),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);
set(h1(5),'Color',setColor{4},'Marker',setMarker{8},'MarkerSize',setMarkerSize2,'LineWidth',setLineWidthMarker);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 40;
incrY = 5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'));

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('Bare Hull Resistance (R_{C})','Thrust at zero drag (T_{F=0})','Towing force at zero thrust (F_{T=0})','Thrust at SPP (T_{SPP})','Towing force (F_{D})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_4_MS_Fr_vs_Towing_Force_and_F_at_Zero_Thrust_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
%# 4. Extrapolation to full scale.
%$ NOTE: Calculations for TG = p Q (vj - vi) method only!
%# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

% Columns:
% [1] Froude length number                              (-)
% [2] TG at zero drag                                   (N)
% [3] Towing force at zero thrust                       (N)
% [4] Thrust at self-propulsion point TG=TG@F=0-FD      (N)
% [5] Towing force, FD                                  (N)

ThrustDedFracArray = thrustDedFracArray;
[mt,nt] = size(ThrustDedFracArray);

ForcesArray = TG_and_F_at_T0;
[m,n] = size(ForcesArray);

% Establish thrust coefficients and full scale shaft speeds
ThrustCoeffArray = [];

% ThrustCoeffArray columns:
% [1]  Froude length number                              (-)
% [2]  MS PORT Gross thrust, TGm                         (N)
% [3]  MS STBD Gross thrust, TGm                         (N)
% [4]  FS PORT Gross thrust, TGs                         (N)
% [5]  FS STBD Gross thrust, TGs                         (N)
% [6]  MS PORT Shaft speed, nm                           (RPM)
% [7]  MS STBD Shaft speed, nm                           (RPM)
% [8]  MS PORT Thrust coefficient, KTm                   (-)
% [9]  MS STBD Thrust coefficient, KTm                   (-)
% [10] FS PORT Shaft speed, ns                           (RPM)
% [11] FS STBD Shaft speed, ns                           (RPM)
% [12] MS PORT Thrust coefficient, KTs                   (-)
% [13] MS STBD Thrust coefficient, KTs                   (-)

for k=1:m
    
    % Stbd to port ratio
    if k == 4
        ratioRow = 3;
    else
        ratioRow = 1;
    end
    
    MSThrustAtSPP = TG_at_FDArray(k,4);
    
    % Model Scale
    PortStbdRatio    = A{k}(ratioRow,40)/A{k}(ratioRow,42);
    MSPortGrosThrust = MSThrustAtSPP*PortStbdRatio;
    PortStbdRatio    = A{k}(ratioRow,41)/A{k}(ratioRow,42);
    MSStbdGrosThrust = MSThrustAtSPP*PortStbdRatio;
    
    % Full Scale - Neglect run 70 and 71 (as faulty)
    PortStbdRatio    = A{k}(ratioRow,40)/A{k}(ratioRow,42);
    FSPortGrosThrust = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    PortStbdRatio    = A{k}(ratioRow,41)/A{k}(ratioRow,42);
    FSStbdGrosThrust = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    
    % Froude length number
    ThrustCoeffArray(k,1)  = ForcesArray(k,1);
    
    % Model scale thrust
    ThrustCoeffArray(k,2)  = MSPortGrosThrust;
    ThrustCoeffArray(k,3)  = MSStbdGrosThrust;
    
    % Full scale thrust
    ThrustCoeffArray(k,4)  = FSPortGrosThrust;
    ThrustCoeffArray(k,5)  = FSStbdGrosThrust;
    
    % Model scale shaft speed
    MSPortSS = shaftSpeedConvArray(k,2);
    MSStbdSS = shaftSpeedConvArray(k,3);
    
    ThrustCoeffArray(k,6)  = MSPortSS;
    ThrustCoeffArray(k,7)  = MSStbdSS;
    
    % Model scale thrust coefficient
    MSPortThrustCoeff = MSPortGrosThrust/(freshwaterdensity*MS_ImpDia^4*(MSPortSS/60)^2);
    MSStbdThrustCoeff = MSStbdGrosThrust/(freshwaterdensity*MS_ImpDia^4*(MSStbdSS/60)^2);
    
    ThrustCoeffArray(k,8)  = MSPortThrustCoeff;
    ThrustCoeffArray(k,9)  = MSStbdThrustCoeff;
    
    % Full scale shaft speed
    FSPortSS = sqrt(FSPortGrosThrust/(saltwaterdensity*FS_ImpDia^4*MSPortThrustCoeff));
    FSStbdSS = sqrt(FSStbdGrosThrust/(saltwaterdensity*FS_ImpDia^4*MSStbdThrustCoeff));
    
    ThrustCoeffArray(k,10) = FSPortSS*60;
    ThrustCoeffArray(k,11) = FSStbdSS*60;
    
    % Full scale thrust coefficient
    FSPortThrustCoeff = FSPortGrosThrust/(saltwaterdensity*FS_ImpDia^4*FSPortSS^2);
    FSStbdThrustCoeff = FSStbdGrosThrust/(saltwaterdensity*FS_ImpDia^4*FSStbdSS^2);
    
    ThrustCoeffArray(k,12) = FSPortThrustCoeff;
    ThrustCoeffArray(k,13) = FSStbdThrustCoeff;
    
end

% Extrapolate WJ Benchmark data for calculated shaft speeds (use MS RPM!!)
[BMDataPort BMEoFPortPH BMEoFPortEff] = fcWJPump(shaftSpeedConvArray(:,2),'Port',ThrustCoeffArray(:,10));
[BMDataStbd BMEoFStbdPH BMEoFStbdEff] = fcWJPump(shaftSpeedConvArray(:,3),'Stbd',ThrustCoeffArray(:,11));

%# Loop through speeds
fullScaleDataArray  = [];
modelScaleDataArray = [];
for k=1:m
    
    %# --------------------------------------------------------------------
    %# MODEL SCALE VARIABLES
    %# --------------------------------------------------------------------
    MSSpeed      = mean(A{k}(:,6));           % Model scale speed (m/s)
    MSReynoldsNo = (MSSpeed*MSlwl)/MSKinVis;  % Full scale reynolds number (-)
    MSRT         = resistance(k,3);
    MSCT         = MSRT/(0.5*freshwaterdensity*MSwsa*MSSpeed^2);
    if MSReynoldsNo < 10000000
        MSCF = 10^(2.98651-10.8843*(log10(log10(MSReynoldsNo)))+5.15283*(log10(log10(MSReynoldsNo)))^2);
    else
        MSCF = 10^(-9.57459+26.6084*(log10(log10(MSReynoldsNo)))-30.8285*(log10(log10(MSReynoldsNo)))^2+10.8914*(log10(log10(MSReynoldsNo)))^3);
    end
    MSCR         = MSCT-(FormFactor*MSCF);
    MSThrustDed  = ThrustDedFracArray(k,4);
    
    % Thrust coefficient KTm=Tm/(pm Dm^4 nm^2)
    MSThrustCoeff = 1;
    
    %# --------------------------------------------------------------------
    %# FULL SCALE VARIABLES
    %# --------------------------------------------------------------------
    FSSpeed      = MSSpeed*sqrt(FStoMSratio); % Full scale speed (m/s)
    FSReynoldsNo = (FSSpeed*FSlwl)/FSKinVis;  % Full scale reynolds number (-)
    FSCR         = MSCR;
    
    % Thrust coefficient KTs=Ts/(ps Ds^4 ns^2)
    FSThrustCoeff = 1;
    
    % 1. Speed and reynolds number ----------------------------------------
    
    % [1]  Froude length number                              (-)
    % [2]  Full scale speed                                  (m/s)
    % [3]  Full scale speed                                  (knots)
    % [4]  Full scale reynolds number                        (-)
    
    % Model Scale
    modelScaleDataArray(k,1)  = ForcesArray(k,1);
    modelScaleDataArray(k,2)  = MSSpeed;
    modelScaleDataArray(k,3)  = FSSpeed/0.51444;
    modelScaleDataArray(k,4)  = MSReynoldsNo;
    
    % Full Scale
    fullScaleDataArray(k,1)  = ForcesArray(k,1);
    fullScaleDataArray(k,2)  = FSSpeed;
    fullScaleDataArray(k,3)  = FSSpeed/0.51444;
    fullScaleDataArray(k,4)  = FSReynoldsNo;
    
    % 2. Shaft speed ------------------------------------------------------
    
    % [5] PORT: Shaft speed                                  (RPM)
    % [6] STBD: Shaft speed                                  (RPM)
    % [7] PORT: Shaft speed                                  (RPS)
    % [8] STBD: Shaft speed                                  (RPS)
    
    % Model Scale
    MSPortSS = shaftSpeedConvArray(k,2);
    MSStbdSS = shaftSpeedConvArray(k,3);
    modelScaleDataArray(k,5) = MSPortSS;
    modelScaleDataArray(k,6) = MSStbdSS;
    modelScaleDataArray(k,7) = MSPortSS/60;
    modelScaleDataArray(k,8) = MSStbdSS/60;
    
    % Full Scale
    FSPortSS = ThrustCoeffArray(k,10);
    FSStbdSS = ThrustCoeffArray(k,11);
    fullScaleDataArray(k,5) = FSPortSS;
    fullScaleDataArray(k,6) = FSStbdSS;
    fullScaleDataArray(k,7) = FSPortSS/60;
    fullScaleDataArray(k,8) = FSStbdSS/60;
    
    % 3. Resistance -------------------------------------------------------
    
    % [9]  Frictional resistance coefficient, CFs            (-)
    % [10] Residual resistannce coefficient, CRs             (-)
    % [11] Total resistannce coefficient, CTs                (-)
    % [12] Total resistance, RT                              (-)
    
    % Model Scale
    modelScaleDataArray(k,9)  = MSCF;
    modelScaleDataArray(k,10) = MSCR;
    modelScaleDataArray(k,11) = MSCT;
    modelScaleDataArray(k,12) = MSRT;
    
    % Full Scale
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSwsa));
    if FSReynoldsNo < 10000000
        FSCF = 10^(2.98651-10.8843*(log10(log10(FSReynoldsNo)))+5.15283*(log10(log10(FSReynoldsNo)))^2);
    else
        FSCF = 10^(-9.57459+26.6084*(log10(log10(FSReynoldsNo)))-30.8285*(log10(log10(FSReynoldsNo)))^2+10.8914*(log10(log10(FSReynoldsNo)))^3);
    end
    %FSCT = FSCF+FSCR;
    FSCT = FormFactor*FSCF+FSRoughnessAllowance+FSCorrelelationCoeff+FSCR+FSAirResistanceCoeff;
    FSRT = 0.5*saltwaterdensity*FSSpeed^2*FSwsa*FSCT;
    fullScaleDataArray(k,9)  = FSCF;
    fullScaleDataArray(k,10) = FSCR;
    fullScaleDataArray(k,11) = FSCT;
    fullScaleDataArray(k,12) = FSRT;
    
    % 4. Effective power, PE ----------------------------------------------
    
    % [13] Effective power, PE                               (W)
    % [14] Effective power, PE                               (kW)
    % [15] Effective power, PE                               (mW)
    
    % Model Scale
    MSPEW  = MSRT*MSSpeed;
    MSPEkW = MSPEW/1000;
    MSPEmW = MSPEkW/1000;
    modelScaleDataArray(k,13) = MSPEW;
    modelScaleDataArray(k,14) = MSPEkW;
    modelScaleDataArray(k,15) = MSPEmW;
    
    % Full Scale
    FSPEW  = FSRT*FSSpeed;
    FSPEkW = FSPEW/1000;
    FSPEmW = FSPEkW/1000;
    fullScaleDataArray(k,13) = FSPEW;
    fullScaleDataArray(k,14) = FSPEkW;
    fullScaleDataArray(k,15) = FSPEmW;
    
    % 5. Wake fraction (w) and thrust deduction (t) -----------------------
    
    % [16] Wake fraction, ws                                 (-)
    % [17] Wake fraction, 1-ws                               (-)
    % [18] Thrust deduction, t                               (-)
    % [19] Thrust deduction, 1-t                             (-)
    
    % Model Scale
    
    % Calculate inlet wake fraction based on power law
    BLPLFactor     = BLPLFactorArray(k);
    BLThickness    = BLThicknessArray(k);
    QBL            = MSSpeed*WidthFactor*MS_PumpDia*BLThickness*(BLPLFactor/(BLPLFactor+1));
    MSWakeFraction = 1-((BLPLFactor+1)/(BLPLFactor+2))*(FR_at_SPP(k,6)/QBL)^(1/(BLPLFactor+1));
    
    modelScaleDataArray(k,16) = MSWakeFraction;
    modelScaleDataArray(k,17) = 1-MSWakeFraction;
    modelScaleDataArray(k,18) = MSThrustDed;
    modelScaleDataArray(k,19) = 1-MSThrustDed;
    
    % Full Scale
    if enableWakeScalingRudderComp == 1
        FSWakeFraction = (MSWakeFraction*(FSCF/MSCF))+(MSThrustDed+0.04)*(1-(FSCF/MSCF));
    else
        FSWakeFraction = (MSWakeFraction*(FSCF/MSCF));
    end
    % TODO: Check if ts is supposed to be tm!!!!!
    fullScaleDataArray(k,16) = FSWakeFraction;
    fullScaleDataArray(k,17) = 1-FSWakeFraction;
    fullScaleDataArray(k,18) = MSThrustDed;
    fullScaleDataArray(k,19) = 1-MSThrustDed;
    
    % 6. Gross thrust, TG = TGm lambda^3 (ps/pm) --------------------------
    
    % [20] PORT: Gross thrust, TGs                           (N)
    % [21] STBD: Gross thrust, TGs                           (N)
    
    % Stbd to port ratio
    if k == 4
        ratioRow = 3;
    else
        ratioRow = 1;
    end
    
    MSThrustAtSPP = TG_at_FDArray(k,4);
    
    % Model Scale
    PortStbdRatio    = A{k}(ratioRow,40)/A{k}(ratioRow,42);
    MSPortGrosThrust = MSThrustAtSPP*PortStbdRatio;
    PortStbdRatio    = A{k}(ratioRow,41)/A{k}(ratioRow,42);
    MSStbdGrosThrust = MSThrustAtSPP*PortStbdRatio;
    modelScaleDataArray(k,20) = MSPortGrosThrust;
    modelScaleDataArray(k,21) = MSStbdGrosThrust;
    
    % Full Scale - Neglect run 70 and 71 (as faulty)
    PortStbdRatio    = A{k}(ratioRow,40)/A{k}(ratioRow,42);
    FSPortGrosThrust = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    PortStbdRatio    = A{k}(ratioRow,41)/A{k}(ratioRow,42);
    FSStbdGrosThrust = (MSThrustAtSPP*PortStbdRatio)*(FStoMSratio^3)*(saltwaterdensity/freshwaterdensity);
    fullScaleDataArray(k,20) = FSPortGrosThrust;
    fullScaleDataArray(k,21) = FSStbdGrosThrust;
    
    % 7. Mass flow rate (pQJ) and volumetric flow rate (QJ) ---------------
    
    % [22] PORT: Volumetric flow rate, QJ                    (m^3/s)
    % [22] STBD: Volumetric flow rate, QJ                    (m^3/s)
    % [23] PORT: Mass flow rate, pQJ                         (Kg/s)
    % [24] STBD: Mass flow rate, pQJ                         (Kg/s)
    
    % Model Scale
    MSPortVolFR = FR_at_SPP(k,6);
    MSStbdVolFR = FR_at_SPP(k,7);
    MSPortMasFR = FR_at_SPP(k,4);
    MSStbdMasFR = FR_at_SPP(k,5);
    modelScaleDataArray(k,22) = MSPortVolFR;
    modelScaleDataArray(k,23) = MSStbdVolFR;
    modelScaleDataArray(k,24) = MSPortMasFR;
    modelScaleDataArray(k,25) = MSStbdMasFR;
    
    % Full Scale
    
    % Port
    var_A         = saltwaterdensity/FS_NozzArea;
    var_B         = saltwaterdensity*((1-FSWakeFraction)*FSSpeed)*-1;
    var_C         = FSPortGrosThrust*-1;
    FSPortVolFR   = (((-1)*var_B)+sqrt(var_B^2-4*var_A*var_C))/(2*var_A);
    
    % Stbd
    var_C         = FSStbdGrosThrust*-1;
    FSStbdVolFR   = (((-1)*var_B)+sqrt(var_B^2-4*var_A*var_C))/(2*var_A);
    
    % Show variables A,B and C for quadratic equation
    %disp(sprintf('Fr=%s | TP=%s | TS=%s | A=%s | B=%s | CP=%s | CS=%s | VFRP=%s | VFRP=%s',sprintf('%.2f',ForcesArray(k,1)),num2str(FSPortGrosThrust),num2str(FSStbdGrosThrust),num2str(var_A),num2str(var_B),num2str(FSPortGrosThrust*-1),num2str(FSStbdGrosThrust*-1),num2str(MSPortVolFR),num2str(MSStbdVolFR)));
    
    FSPortMasFR = FSPortVolFR*saltwaterdensity;
    FSStbdMasFR = FSStbdVolFR*saltwaterdensity;
    fullScaleDataArray(k,22) = FSPortVolFR;
    fullScaleDataArray(k,23) = FSStbdVolFR;
    fullScaleDataArray(k,24) = FSPortMasFR;
    fullScaleDataArray(k,25) = FSStbdMasFR;
    
    % 8. Jet and inlet velocities -----------------------------------------
    
    % [26] PORT: Jet velocity, vj                            (m/s)
    % [27] STBD: Jet velocity, vj                            (m/s)
    % [28] PORT: Inlet velocity, vi                          (m/s)
    % [29] STBD: Inlet velocity, vi                          (m/s)\
    
    % Model Scale
    MSPortVolFR = FR_at_SPP(k,6);
    MSStbdVolFR = FR_at_SPP(k,7);
    MSPortJetVel = MSPortVolFR/MS_NozzArea;
    MSStbdJetVel = MSStbdVolFR/MS_NozzArea;
    MSPortInlVel = (1-MSWakeFraction)*MSSpeed;
    MSStbdInlVel = (1-MSWakeFraction)*MSSpeed;
    modelScaleDataArray(k,26) = MSPortJetVel;
    modelScaleDataArray(k,27) = MSStbdJetVel;
    modelScaleDataArray(k,28) = MSPortInlVel;
    modelScaleDataArray(k,29) = MSStbdInlVel;
    
    % Full Scale
    FSPortJetVel = FSPortVolFR/FS_NozzArea;
    FSStbdJetVel = FSStbdVolFR/FS_NozzArea;
    FSPortInlVel = (1-FSWakeFraction)*FSSpeed;
    FSStbdInlVel = (1-FSWakeFraction)*FSSpeed;
    fullScaleDataArray(k,26) = FSPortJetVel;
    fullScaleDataArray(k,27) = FSStbdJetVel;
    fullScaleDataArray(k,28) = FSPortInlVel;
    fullScaleDataArray(k,29) = FSStbdInlVel;
    
    % 9. Efficiencies -----------------------------------------------------
    
    % [30] Hull efficiency, nh                               (-)
    % [31] Optimum efficiency, ni                            (-)
    
    % Model Scale
    modelScaleDataArray(k,30) = (1-MSThrustDed)/(1-MSWakeFraction);
    modelScaleDataArray(k,31) = 1-((MSPortJetVel/MSSpeed)-1)^2;
    
    % Full Scale
    fullScaleDataArray(k,30) = (1-MSThrustDed)/(1-FSWakeFraction);
    fullScaleDataArray(k,31) = 1-((FSPortJetVel/FSSpeed)-1)^2;
    
    % 10. Pump related data -----------------------------------------------
    
    % [32] PORT: Flow coefficient                            (-)
    % [33] STBD: Flow coefficient                            (-)
    % [34] PORT: Pump head, H                                (m)
    % [35] STBD: Pump head, H                                (m)
    % [36] PORT: Head coefficient                            (-)
    % [37] STBD: Head coefficient                            (-)
    % [38] PORT: Pump efficieny, npump                       (-)
    % [39] STBD: Pump efficieny, npump                       (-)
    
    % Model Scale
    modelScaleDataArray(k,32) = MSPortVolFR/((MSPortSS/60)*MS_PumpDia^3);
    modelScaleDataArray(k,33) = MSStbdVolFR/((MSStbdSS/60)*MS_PumpDia^3);
    
    % Full Scale
    fullScaleDataArray(k,32) = FSPortVolFR/((FSPortSS/60)*FS_PumpDia^3);
    fullScaleDataArray(k,33) = FSStbdVolFR/((FSStbdSS/60)*FS_PumpDia^3);
    
    % Model Scale
    MSPortPumphead = (24.3499*FR_at_SPP(k,4)^2+212.9700*FR_at_SPP(k,4)-320.9491)/1000;
    MSStbdPumphead = (24.3499*FR_at_SPP(k,5)^2+212.9700*FR_at_SPP(k,5)-320.9491)/1000;
    modelScaleDataArray(k,34) = MSPortPumphead;
    modelScaleDataArray(k,35) = MSStbdPumphead;
    modelScaleDataArray(k,36) = gravconst*MSPortPumphead/((MSPortSS/60)*MS_PumpDia)^2;
    modelScaleDataArray(k,37) = gravconst*MSStbdPumphead/((MSStbdSS/60)*MS_PumpDia)^2;
    
    % Full Scale
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# Pump head based on fit
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %PortPH = [24.69 27.57 31.01 34.98 38.61 42.33 44.76 51.15 58.71];
    %StbdPH = [24.62 27.50 31.00 34.93 38.59 42.26 44.76 51.04 58.55];
    EOFP = BMEoFPortPH;
    EOFS = BMEoFStbdPH;
    VFRP = FSPortVolFR;
    VFRS = FSStbdVolFR;
    PortPH = EOFP(k, 2)*VFRP^4+EOFP(k, 3)*VFRP^3+EOFP(k, 4)*VFRP^2+EOFP(k, 5)*VFRP+EOFP(k, 6);
    StbdPH = EOFS(k, 2)*VFRS^4+EOFS(k, 3)*VFRS^3+EOFS(k, 4)*VFRS^2+EOFS(k, 5)*VFRS+EOFS(k, 6);
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    FSPortPumphead = PortPH;
    FSStbdPumphead = StbdPH;
    fullScaleDataArray(k,34) = FSPortPumphead;
    fullScaleDataArray(k,35) = FSStbdPumphead;
    fullScaleDataArray(k,36) = gravconst*FSPortPumphead/((FSPortSS/60)*FS_PumpDia)^2;
    fullScaleDataArray(k,37) = gravconst*FSStbdPumphead/((FSStbdSS/60)*FS_PumpDia)^2;
    
    % Model Scale
    
    % Port
    MSPortJP  = MSPortVolFR/((MSPortSS/60)*MS_PumpDia^3);
    MSPortKH  = (gravconst*MSPortPumphead)/((MSPortSS/60)^2*MS_PumpDia^2);
    MSPortTQ  = FR_at_SPP(k,8);
    MSKPortQm = MSPortTQ/(freshwaterdensity*(MSPortSS/60)^2*MS_PumpDia^5);
    
    % Stbd
    MSStbdJP  = MSStbdVolFR/((MSStbdSS/60)*MS_PumpDia^3);
    MSStbdKH  = (gravconst*MSStbdPumphead)/((MSStbdSS/60)^2*MS_PumpDia^2);
    MSStbdTQ  = FR_at_SPP(k,9);
    MSKStbdQm = MSStbdTQ/(freshwaterdensity*(MSStbdSS/60)^2*MS_PumpDia^5);
    
    MSPortPumpEff  = (MSPortJP*MSPortKH)/(2*pi*MSKPortQm);
    MSStbdPumpEff  = (MSStbdJP*MSStbdKH)/(2*pi*MSKStbdQm);
    modelScaleDataArray(k,38) = MSPortPumpEff;
    modelScaleDataArray(k,39) = MSStbdPumpEff;
    
    % Full Scale
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %# Efficiency based on fit
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    EOFP = BMEoFPortEff;
    EOFS = BMEoFStbdEff;
    VFRP = FSPortVolFR;
    VFRS = FSStbdVolFR;
    PortPE = EOFP(k, 2)*VFRP^4+EOFP(k, 3)*VFRP^3+EOFP(k, 4)*VFRP^2+EOFP(k, 5)*VFRP+EOFP(k, 6);
    StbdPE = EOFS(k, 2)*VFRS^4+EOFS(k, 3)*VFRS^3+EOFS(k, 4)*VFRS^2+EOFS(k, 5)*VFRS+EOFS(k, 6);
    %# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    FSPortPumpEff  = StbdPE;
    FSStbdPumpEff  = StbdPE;
    fullScaleDataArray(k,38) = FSPortPumpEff;
    fullScaleDataArray(k,39) = FSStbdPumpEff;
    
    % 11. Overall prop. eff., delivered and brake power (ns=0.98) ---------
    
    % [40] PORT: Pump effective power, PPE                   (W)
    % [41] PORT: Pump effective power, PPE                   (W)
    % [42] PORT: Delivered power, PD                         (W)
    % [43] PORT: Delivered power, PD                         (W)
    % [44] PORT: Brake power, PB                             (W)
    % [45] PORT: Brake power, PB                             (W)
    % [46] Overall propulsive efficieny, nD=PE/PD            (-)
    
    % Model Scale
    
    % Energy fluxes at stations 0, 1 and 7
    MSPortEFStat1 = 0.5*freshwaterdensity*MSPortVolFR*(MSSpeed^2)*(1-MSWakeFraction)^2;
    MSStbdEFStat1 = 0.5*freshwaterdensity*MSStbdVolFR*(MSSpeed^2)*(1-MSWakeFraction)^2;
    MSPortEFStat7 = 0.5*freshwaterdensity*MSPortVolFR*MSPortJetVel^2;
    MSStbdEFStat7 = 0.5*freshwaterdensity*MSStbdVolFR*MSStbdJetVel^2;
    MSEFStat0     = 0.5*freshwaterdensity*MSSpeed^2;
    
    % Nozzle and ideal efficiency
    MSPortNozzleEff = 0.98;
    MSStbdNozzleEff = 0.98;
    MSPortIdealEff  = 2/(1+(MSPortJetVel/MSPortInlVel));
    MSStbdIdealEff  = 2/(1+(MSStbdJetVel/MSStbdInlVel));
    
    % Pump effective power, PPE
    if enablePPEEstPumpCurveHead == 1
        % Pump effective power, PPE using PPE = p g QJ H35 (ITTC)
        MSPortPumpEffPower = freshwaterdensity*gravconst*MSPortVolFR*MSPortPumphead;
        MSStbdPumpEffPower = freshwaterdensity*gravconst*MSStbdVolFR*MSStbdPumphead;
    else
        % Pump effective power, PPE using PPE = (E7/nn)-niE1 (Bose 2008)]
        MSPortPumpEffPower = (MSPortEFStat7/MSPortNozzleEff)-MSPortIdealEff*MSPortEFStat1;
        MSStbdPumpEffPower = (MSStbdEFStat7/MSStbdNozzleEff)-MSStbdIdealEff*MSStbdEFStat1;
    end
    modelScaleDataArray(k,40) = MSPortPumpEffPower;
    modelScaleDataArray(k,41) = MSStbdPumpEffPower;
    
    % Delivered power, PD
    MSPortDelPower = MSPortPumpEffPower/MSPortPumpEff;
    MSStbdDelPower = MSStbdPumpEffPower/MSStbdPumpEff;
    modelScaleDataArray(k,42) = MSPortDelPower;
    modelScaleDataArray(k,43) = MSStbdDelPower;
    
    % Brake power (assumed shaft loss 2% and gear box 2%), PB
    MSPortBrakePower = MSPortDelPower/0.98;
    MSStbdBrakePower = MSStbdDelPower/0.98;
    MSPortBrakePower = MSPortBrakePower/0.98;
    MSStbdBrakePower = MSStbdBrakePower/0.98;
    modelScaleDataArray(k,44) = MSPortBrakePower;
    modelScaleDataArray(k,45) = MSStbdBrakePower;
    
    % Overall propulsive efficiency based on nD = PE/PD where PD = PPE/hpump
    modelScaleDataArray(k,46) = MSPEW/(MSPortDelPower+MSStbdDelPower);
    
    % Full Scale
    
    % Energy fluxes at stations 0, 1 and 7
    FSPortEFStat1 = 0.5*saltwaterdensity*FSPortVolFR*(FSSpeed^2)*(1-FSWakeFraction)^2;
    FSStbdEFStat1 = 0.5*saltwaterdensity*FSStbdVolFR*(FSSpeed^2)*(1-FSWakeFraction)^2;
    FSPortEFStat7 = 0.5*saltwaterdensity*FSPortVolFR*FSPortJetVel^2;
    FSStbdEFStat7 = 0.5*saltwaterdensity*FSStbdVolFR*FSStbdJetVel^2;
    FSEFStat0     = 0.5*saltwaterdensity*FSSpeed^2;
    
    % Nozzle and ideal efficiency
    FSPortNozzleEff = 0.98;
    FSStbdNozzleEff = 0.98;
    FSPortIdealEff  = 2/(1+(FSPortJetVel/FSPortInlVel));
    FSStbdIdealEff  = 2/(1+(FSStbdJetVel/FSStbdInlVel));
    
    % Pump effective power, PPE
    if enablePPEEstPumpCurveHead == 1
        % Pump effective power, PPE using PPE = p g QJ H35 (ITTC)
        FSPortPumpEffPower = saltwaterdensity*gravconst*FSPortVolFR*FSPortPumphead;
        FSStbdPumpEffPower = saltwaterdensity*gravconst*FSStbdVolFR*FSStbdPumphead;
    else
        % Pump effective power, PPE using PPE = (E7/nn)-niE1 (Bose 2008)]
        FSPortPumpEffPower = (FSPortEFStat7/FSPortNozzleEff)-FSPortIdealEff*FSPortEFStat1;
        FSStbdPumpEffPower = (FSStbdEFStat7/FSStbdNozzleEff)-FSStbdIdealEff*FSStbdEFStat1;
    end
    fullScaleDataArray(k,40) = FSPortPumpEffPower;
    fullScaleDataArray(k,41) = FSStbdPumpEffPower;
    
    % Delivered power, PD
    FSPortDelPower = FSPortPumpEffPower/FSPortPumpEff;
    FSStbdDelPower = FSStbdPumpEffPower/FSStbdPumpEff;
    fullScaleDataArray(k,42) = FSPortDelPower;
    fullScaleDataArray(k,43) = FSStbdDelPower;
    
    % Brake power (assumed shaft loss 2% and gear box 2%), PB
    FSPortBrakePower = FSPortDelPower/0.98;
    FSStbdBrakePower = FSStbdDelPower/0.98;
    FSPortBrakePower = FSPortBrakePower/0.98;
    FSStbdBrakePower = FSStbdBrakePower/0.98;
    fullScaleDataArray(k,44) = FSPortBrakePower;
    fullScaleDataArray(k,45) = FSStbdBrakePower;
    
    % Overall propulsive efficiency based on nD = PE/PD where PD = PPE/hpump
    fullScaleDataArray(k,46) = FSPEW/(FSPortDelPower+FSStbdDelPower);
    
    % 12. IVR, JVR and NVR ------------------------------------------------
    
    % [47] PORT: Inlet velocity ratio, IVR=Vin/Vm            (-)
    % [48] STBD: Inlet velocity ratio, IVR=Vin/Vm            (-)
    % [49] PORT: Jet velocity ratio, JVR=Vj/Vm               (-)
    % [50] STBD: Jet velocity ratio, JVR=Vj/Vm               (-)
    % [51] PORT: Nozzle velocity ratio, NVR=Vj/Vin           (-)
    % [52] STBD: Nozzle velocity ratio, NVR=Vj/Vin           (-)
    
    % Model Scale
    MSPortIVR = MSPortInlVel/MSSpeed;
    MSStbdIVR = MSStbdInlVel/MSSpeed;
    MSPortJVR = MSPortJetVel/MSSpeed;
    MSStbdJVR = MSStbdJetVel/MSSpeed;
    MSPortNVR = MSPortJetVel/MSSpeed;
    MSStbdNVR = MSStbdJetVel/MSSpeed;
    modelScaleDataArray(k,47) = MSPortIVR;
    modelScaleDataArray(k,48) = MSStbdIVR;
    modelScaleDataArray(k,49) = MSPortJVR;
    modelScaleDataArray(k,50) = MSStbdJVR;
    modelScaleDataArray(k,51) = MSPortNVR;
    modelScaleDataArray(k,52) = MSStbdNVR;
    
    % Full Scale
    FSPortIVR = FSPortInlVel/FSSpeed;
    FSStbdIVR = FSStbdInlVel/FSSpeed;
    FSPortJVR = FSPortJetVel/FSSpeed;
    FSStbdJVR = FSStbdJetVel/FSSpeed;
    FSPortNVR = FSPortJetVel/FSSpeed;
    FSStbdNVR = FSStbdJetVel/FSSpeed;
    fullScaleDataArray(k,47) = FSPortIVR;
    fullScaleDataArray(k,48) = FSStbdIVR;
    fullScaleDataArray(k,49) = FSPortJVR;
    fullScaleDataArray(k,50) = FSStbdJVR;
    fullScaleDataArray(k,51) = FSPortNVR;
    fullScaleDataArray(k,52) = FSStbdNVR;
    
    % 13. Energy flux at Station 1 and 7, PJSE ----------------------------
    
    % [53] PORT: Energy flux at Station 1, E1                (W)
    % [54] STBD: Energy flux at Station 1, E1                (W)
    % [55] PORT: Energy flux at Station 7, E7                (W)
    % [56] STBD: Energy flux at Station 7, E7                (W)
    % [57] Energy flux at Station 0, E0                      (W)
    % [58] PORT: Eff. jet system power, PJSE                 (W)
    % [59] STBD: Eff. jet system power, PJSE                 (W)
    
    % Model Scale
    MSPortPJSE    = MSPortEFStat7-MSPortEFStat1;
    MSStbdPJSE    = MSStbdEFStat7-MSStbdEFStat1;
    modelScaleDataArray(k,53) = MSPortEFStat1;
    modelScaleDataArray(k,54) = MSStbdEFStat1;
    modelScaleDataArray(k,55) = MSPortEFStat7;
    modelScaleDataArray(k,56) = MSStbdEFStat7;
    modelScaleDataArray(k,57) = MSEFStat0;
    modelScaleDataArray(k,58) = MSPortPJSE;
    modelScaleDataArray(k,59) = MSStbdPJSE;
    
    % Full Scale
    FSPortPJSE    = FSPortEFStat7-FSPortEFStat1;
    FSStbdPJSE    = FSStbdEFStat7-FSStbdEFStat1;
    fullScaleDataArray(k,53) = FSPortEFStat1;
    fullScaleDataArray(k,54) = FSStbdEFStat1;
    fullScaleDataArray(k,55) = FSPortEFStat7;
    fullScaleDataArray(k,56) = FSStbdEFStat7;
    fullScaleDataArray(k,57) = FSEFStat0;
    fullScaleDataArray(k,58) = FSPortPJSE;
    fullScaleDataArray(k,59) = FSStbdPJSE;
    
    % 14. Thrust effective power, PTE -------------------------------------
    
    % [60] PORT: Thrust effective power, PTE                 (W)
    % [61] STBD: Thrust effective power, PTE                 (W)
    
    % Model Scale
    MSPortPTE = MSPortGrosThrust*MSSpeed;
    MSStbdPTE = MSStbdGrosThrust*MSSpeed;
    modelScaleDataArray(k,60) = MSPortPTE;
    modelScaleDataArray(k,61) = MSStbdPTE;
    
    % Full Scale
    FSPortPTE = FSPortGrosThrust*FSSpeed;
    FSStbdPTE = FSStbdGrosThrust*FSSpeed;
    fullScaleDataArray(k,60) = FSPortPTE;
    fullScaleDataArray(k,61) = FSStbdPTE;
    
    % 15. Additional efficiencies -----------------------------------------
    
    % [62] PORT: Nozzle efficiency, nn                       (-)
    % [63] STBD: Nozzle efficiency, nn                       (-)
    % [64] PORT: Ideal efficiency, nI                        (-)
    % [65] STBD: Ideal efficiency, nI                        (-)
    % [66] PORT: Jet system efficiency, nJS                  (-)
    % [67] STBD: Jet system efficiency, nJS                  (-)
    
    % Model Scale
    MSPortJetSysEff = MSPortPTE/MSPortPJSE;
    MSStbdJetSysEff = MSStbdPTE/MSStbdPJSE;
    modelScaleDataArray(k,62) = MSPortNozzleEff;
    modelScaleDataArray(k,63) = MSStbdNozzleEff;
    modelScaleDataArray(k,64) = MSPortIdealEff;
    modelScaleDataArray(k,65) = MSStbdIdealEff;
    modelScaleDataArray(k,66) = MSPortJetSysEff;
    modelScaleDataArray(k,67) = MSStbdJetSysEff;
    
    % Full Scale
    FSPortJetSysEff = FSPortPTE/FSPortPJSE;
    FSStbdJetSysEff = FSStbdPTE/FSStbdPJSE;
    fullScaleDataArray(k,62) = FSPortNozzleEff;
    fullScaleDataArray(k,63) = FSStbdNozzleEff;
    fullScaleDataArray(k,64) = FSPortIdealEff;
    fullScaleDataArray(k,65) = FSStbdIdealEff;
    fullScaleDataArray(k,66) = FSPortJetSysEff;
    fullScaleDataArray(k,67) = FSStbdJetSysEff;
    
    % Overall propulsive efficiency based on nD = PE/PD where PD = PJSE/hJS
    
    % Model Scale
    MSPortPDETemp = MSPortPJSE/MSPortJetSysEff;
    MSStbdPDETemp = MSStbdPJSE/MSStbdJetSysEff;
    modelScaleDataArray(k,68) = MSPEW/(MSPortPDETemp+MSStbdPDETemp);
    
    % Full Scale
    FSPortPDETemp = FSPortPJSE/FSPortJetSysEff;
    FSStbdPDETemp = FSStbdPJSE/FSStbdJetSysEff;
    fullScaleDataArray(k,68) = FSPEW/(FSPortPDETemp+FSStbdPDETemp);
    
    % 16. Identifiers for OPE #1, nD --------------------------------------
    % OPE #1: Overall propulsive efficiency using nD=PE/PD
    
    % [69] Adjusted or original curve fitting of T vs. F     (-)
    %      (1) Original
    %      (2) Adjusted
    % [70] Pump effective power using                        (-)
    %      (1) PPE = (E7/nn)-niE1 (Bose 2008)
    %      (2) PPE = p g QJ H35   (ITTC)
    % [71] Correlation coefficient, Ca                       (-)
    
    if enableAdjustedFitting == 1
        modelScaleDataArray(k,69) = 2;
        fullScaleDataArray(k,69)  = 2;
    else
        modelScaleDataArray(k,69) = 1;
        fullScaleDataArray(k,69)  = 1;
    end
    if enablePPEEstPumpCurveHead == 1
        modelScaleDataArray(k,70) = 2;
        fullScaleDataArray(k,70)  = 2;
    else
        modelScaleDataArray(k,70) = 1;
        fullScaleDataArray(k,70)  = 1;
    end
    modelScaleDataArray(k,71) = CorrCoeff;
    fullScaleDataArray(k,71)  = CorrCoeff;
    
    % 17. Prop. Efficiency using nD=(thrust V)/PPE ------------------------
    % Added: 02/12/2014
    
    % nD=(thrust V)/PPE
    modelScaleDataArray(k,72) = ((MSPortGrosThrust+MSStbdGrosThrust)*MSSpeed)/(MSPortPumpEffPower+MSStbdPumpEffPower);
    fullScaleDataArray(k,72)  = ((FSPortGrosThrust+FSStbdGrosThrust)*FSSpeed)/(FSPortPumpEffPower+FSStbdPumpEffPower);
    
    % 18. Prop. Efficiency based on Eqn. 10-28 in Bose (2008) -------------
    % Added: 01/01/2015
    % See Bose (2008), Eqn. 10-28
    
    MSNozzleEff = 0.98;
    MSIntakeEff = 1;
    
    FSNozzleEff = 0.98;
    FSIntakeEff = 1;
    
    modelScaleDataArray(k,73) = (MSPortMasFR*(MSPortJetVel-MSSpeed*(1-MSWakeFraction))*MSSpeed*MSPortPumpEff*InstEff)/(0.5*MSPortMasFR*((MSPortJetVel^2/MSNozzleEff)-MSIntakeEff*MSSpeed^2*(1-MSWakeFraction)^2));
    fullScaleDataArray(k,73)  = (FSPortMasFR*(FSPortJetVel-FSSpeed*(1-FSWakeFraction))*FSSpeed*FSPortPumpEff*InstEff)/(0.5*FSPortMasFR*((FSPortJetVel^2/FSNozzleEff)-FSIntakeEff*FSSpeed^2*(1-FSWakeFraction)^2));
    
    % If installation and nozzle efficiency are assumed as 100% -----------
    % See Bose (2008), Eqn. 10-29
    
    modelScaleDataArray(k,74) = (2*MSPortPumpEff*((MSPortJetVel/MSSpeed)-1))/((MSPortJetVel/MSSpeed)^2-MSIntakeEff);
    fullScaleDataArray(k,74)  = (2*FSPortPumpEff*((FSPortJetVel/FSSpeed)-1))/((FSPortJetVel/FSSpeed)^2-FSIntakeEff);
    
    % 19. Thrust coefficients, KTm and KTs. For SPP KTm=KTs ---------------
    % Added: 06/01/2015
    
    modelScaleDataArray(k,75) = ThrustCoeffArray(k,8);
    fullScaleDataArray(k,75)  = ThrustCoeffArray(k,12);
    
    % 20. Pump head H35 based on delivered power PD (Koushan 1998) --------
    % Added: 02/02/2015
    
    MSNumPumpHead = (MSPortDelPower*InstEff*MSPortPumpEff)/(freshwaterdensity*gravconst*MSPortVolFR);
    FSNumPumpHead = (FSPortDelPower*InstEff*FSPortPumpEff)/(saltwaterdensity*gravconst*FSPortVolFR);
    modelScaleDataArray(k,76) = MSNumPumpHead;
    fullScaleDataArray(k,76)  = FSNumPumpHead;
    
    % 21. Pump effective efficiency PPE (Bose 2008, Eqn. 10-26) -----------
    % Added: 09/02/2015
    
    modelScaleDataArray(k,77) = 0.5*freshwaterdensity*MSPortVolFR*((MSPortJetVel^2/MSPortNozzleEff)-MSPortIdealEff*MSSpeed^2*(1-MSWakeFraction)^2);
    modelScaleDataArray(k,78) = 0.5*freshwaterdensity*MSStbdVolFR*((MSStbdJetVel^2/MSStbdNozzleEff)-MSStbdIdealEff*MSSpeed^2*(1-MSWakeFraction)^2);
    fullScaleDataArray(k,77)  = 0.5*saltwaterdensity*FSPortVolFR*((FSPortJetVel^2/FSPortNozzleEff)-FSPortIdealEff*FSSpeed^2*(1-FSWakeFraction)^2);
    fullScaleDataArray(k,78)  = 0.5*saltwaterdensity*FSStbdVolFR*((FSStbdJetVel^2/FSStbdNozzleEff)-FSStbdIdealEff*FSSpeed^2*(1-FSWakeFraction)^2);
    
    % 22. Volume Flow Rate Coefficient (KQ) -------------------------------
    % Added: 10/02/2015
    
    modelScaleDataArray(k,79) = MSPortVolFR/((MSPortSS/60)*MS_ImpDia)^3;
    modelScaleDataArray(k,80) = MSStbdVolFR/((MSStbdSS/60)*MS_ImpDia)^3;
    fullScaleDataArray(k,79)  = FSPortVolFR/((FSPortSS/60)*FS_ImpDia)^3;
    fullScaleDataArray(k,80)  = FSStbdVolFR/((FSStbdSS/60)*FS_ImpDia)^3;
    
    % 23. Overall propulsive efficiency using Bulten (2006), Eqn. 2.61 ----
    % Added: 19/02/2015
    % See Bulten (2006), Eqn. 2.61. nD=((1-t)/(1-w))nPump((T Vi)/(p g H Q))
    
    modelScaleDataArray(k,81) = ((1-MSThrustDed)/(1-MSWakeFraction))*MSPortPumpEff*((MSPortGrosThrust*MSPortInlVel)/(freshwaterdensity*gravconst*MSNumPumpHead*MSPortVolFR));
    modelScaleDataArray(k,82) = ((1-MSThrustDed)/(1-MSWakeFraction))*MSStbdPumpEff*((MSStbdGrosThrust*MSStbdInlVel)/(freshwaterdensity*gravconst*MSNumPumpHead*MSStbdVolFR));
    fullScaleDataArray(k,81)  = ((1-MSThrustDed)/(1-FSWakeFraction))*FSPortPumpEff*((FSPortGrosThrust*FSPortInlVel)/(saltwaterdensity*gravconst*FSNumPumpHead*FSPortVolFR));
    fullScaleDataArray(k,82)  = ((1-MSThrustDed)/(1-FSWakeFraction))*FSStbdPumpEff*((FSStbdGrosThrust*FSStbdInlVel)/(saltwaterdensity*gravconst*FSNumPumpHead*FSStbdVolFR));
    
    % 24. Effective power and overall propulsive efficiency ---------------
    % Added: 3/3/2015
    % See Ghadimi (2013), Eqn. 3. PE = TF=0 V = p QJ V (Vj-Vi) then nD = PE/PD     
    
    % Use FT=0 at RTm for ITTC1978 extrapolation
    setRTmITTC1978 = resSPP_CCDoTT(k,21);
    
    % Model Scale
    MSEffPower = setRTmITTC1978*MSSpeed;
    MSOPE      = MSEffPower/(MSPortDelPower+MSStbdDelPower);
    modelScaleDataArray(k,83) = MSEffPower;
    modelScaleDataArray(k,84) = MSOPE;
    modelScaleDataArray(k,85) = setRTmITTC1978;

    % Full Scale (single demihull) use ITTC1978 to extrapolate FT=0

    % Model scale: Total resistance coefficient
    MSCTm = setRTmITTC1978/(0.5*freshwaterdensity*MSwsa*MSSpeed^2);
    
    % Model scale: Frictional resistance coefficient
    MSCFm = MSCF;
    
    % Model scale: Residual resistance coefficient
    MSCRm = MSCTm-(FormFactor*MSCFm);
    
    % Roughness allowance
    FSRoughnessAllowance = 0.044*((RoughnessOfHullSurface/FSlwl)^(1/3)-10*FSReynoldsNo^(-1/3))+0.000125;
    % Correlation coefficient
    FSCorrelelationCoeff = (5.68-0.6*log10(FSReynoldsNo))*10^(-3);
    % Air resistance coefficient
    FSAirResistanceCoeff = DragCoeff*((airDensity*FSProjectedArea)/(saltwaterdensity*FSwsa));    
    
    % Full scale: Residual resistance coefficient
    FSCRs = MSCRm;
    
    % Full scale: Frictional resistance coefficient
    FSCFs = FSCF;
    
    % TFull scale: otal resistance coefficient
    FSCTs      = FormFactor*FSCFs+FSRoughnessAllowance+FSCorrelelationCoeff+FSCRs+FSAirResistanceCoeff;
    
    % Full scale: Total resistance
    FSRTs      = 0.5*saltwaterdensity*(FSSpeed^2)*FSwsa*FSCTs;
    
    % Full scale: Effective power
    FSEffPower = FSRTs*FSSpeed;
    
    % Full scale: Overall propulsive efficiency
    FSOPE      = FSEffPower/(FSPortDelPower+FSStbdDelPower);
    
    fullScaleDataArray(k,83) = FSEffPower;
    fullScaleDataArray(k,84) = FSOPE;
    fullScaleDataArray(k,85) = FSRTs;
    
end % k=1:m


%# ////////////////////////////////////////////////////////////////////////
%# Plotting full scale results
%# ////////////////////////////////////////////////////////////////////////

%# ************************************************************************
%# 5. Full scale overall propulsive efficiency, nD
%# ************************************************************************
figurename = 'Plot 5: Full Scale, Propulsive Efficiency';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>';'x'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# ************************************************************************
%# SUBPLOT #1: Overall propulsive efficiency
%# ************************************************************************
%subplot(1,2,1);

%# X and Y axis -----------------------------------------------------------

%# Overall propulsive efficiency where nD = PE/PD where PD = PPE/hpump
x1 = fullScaleDataArray(:,1);
y1 = fullScaleDataArray(:,46);

% Bose (2008), Eqn. 10-28
x2 = fullScaleDataArray(:,1);
y2 = fullScaleDataArray(:,73);

% Bulten (2006), Eqn. 2.61. nD=((1-t)/(1-w))nPump((T Vi)/(p g H Q))
x3 = fullScaleDataArray(:,1);
y3 = fullScaleDataArray(:,81);

% See Ghadimi (2013), Eqn. 3. PE = TF=0 V = p QJ V (Vj-Vi) then nD = PE/PD
x4 = fullScaleDataArray(:,1);
y4 = fullScaleDataArray(:,84);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
Plot5LegendInfo{1} = '\eta_{D}=P_{E}/P_{D} where P_{E}=R_{BH}V, P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})';
Plot5LegendInfo{2} = 'Bose (2008): Eqn. 10-28';
Plot5LegendInfo{3} = 'Bulten (2006): Eqn. 2.61';
Plot5LegendInfo{4} = '\eta_{D}=P_{E}/P_{D} where P_{E}=T_{F=0}V, P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})';
xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
%xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Overall propulsive efficiency, \eta_{D} (-)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Overall propulsive efficiency}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);
set(h(3),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);
set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
% Ship speed (knots)
%minX  = 13;
%maxX  = 25;
%incrX = 1;
% Froude length number
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 1;
incrY = 0.1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

%# Legend
hleg1 = legend(Plot5LegendInfo);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1,'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_5_FS_Overall_Propulsive_Efficiency_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 5.1 Full scale overall propulsive efficiency, nD
%# ************************************************************************
figurename = 'Plot 5.1: Full Scale, Propulsive Efficiency';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

%# Overall propulsive efficiency where nD = PE/PD where PD = PPE/hpump
x1 = fullScaleDataArray(:,1);
y1 = fullScaleDataArray(:,46);

% See Ghadimi (2013), Eqn. 3. PE = TF=0 V = p QJ V (Vj-Vi) then nD = PE/PD
x2 = fullScaleDataArray(:,1);
y2 = fullScaleDataArray(:,84);

% Bare hull resistance RBH
x3 = fullScaleDataArray(:,1);
y3 = fullScaleDataArray(:,12);

Raw_Data = num2cell(y3);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

% Force at zero thrust FT=0 extrapolated to full scale using ITTC1978
x4 = fullScaleDataArray(:,1);
y4 = fullScaleDataArray(:,85);

Raw_Data = num2cell(y4);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y4 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy([x1 x2], [y1 y2], [x3 x4], [y3 y4], 'plot');
Plot51LegendInfo{1} = '\eta_{D}=P_{E}/P_{D} where P_{E}=R_{BH}V, P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})';
Plot51LegendInfo{2} = '\eta_{D}=P_{E}/P_{D} where P_{E}=T_{F=0}V, P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})';
Plot51LegendInfo{3} = 'Bare hull resistance (R_{BH})';
Plot51LegendInfo{4} = 'Force at zero thrust (F_{T=0})';
% Left color black, right color black
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Froude length number, F_{r} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale overall propulsive efficiency','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Overall propulsive efficiency, \eta_{D} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Resistance R_{BH} and force at zero thrust F_{T=0} (kN)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin); 
set(h1(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin); 
% Right Y-axis
set(h2(1),'Color',setColor{3},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth); 
set(h2(2),'Color',setColor{4},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth); 

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0.2;
maxY  = 0.8;
incrY = 0.1;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 60;
maxY  = 300;
incrY = 40;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
%set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
%hleg1 = legend('Overall propulsive efficiency (\eta_{D})','Residual resistance coefficient (C_{Rs})');
hleg1 = legend(Plot51LegendInfo);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_5_1_FS_Overall_Propulsive_Efficiency_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 6. Power plots (two propulsion systems ==>> a single demihull)
%# ************************************************************************

%# Plotting power ---------------------------------------------------------
figurename = 'Plot 6: Full Scale, Power for Single Demi Hull';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'x';'+';'*';'o';'s';'d';'*';'^';'<';'>';'x'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# X and Y axis -----------------------------------------------------------

[m,n] = size(fullScaleDataArray);

%# Effective power, PE
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,15);

%# Delivered power, PD
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,42)+fullScaleDataArray(kx,43))/1000^2;
end
x2 = fullScaleDataArray(:,3);
y2 = TotalPower;

%# Delivered power, PD (Sea Trials Data)
%x3 = XXX;
%y3 = YYY;

%# Pump effective power, PPE
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,40)+fullScaleDataArray(kx,41))/1000^2;
end
x4 = fullScaleDataArray(:,3);
y4 = TotalPower;

%# Effective jet system power, PJSE
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,58)+fullScaleDataArray(kx,59))/1000^2;
end
x5 = fullScaleDataArray(:,3);
y5 = TotalPower;

%# Thrust effective power, PTE
TotalPower = [];
for kx=1:m
    TotalPower(kx) = (fullScaleDataArray(kx,60)+fullScaleDataArray(kx,61))/1000^2;
end
x6 = fullScaleDataArray(:,3);
y6 = TotalPower;

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x4,y4,'*',x5,y5,'*',x6,y6,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Power (MW)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Power estimates}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{5},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 8;
incrY = 1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
%hleg1 = legend('Effective power (P_{E})','Delivered power (P_{D})','Delivered power (P_{D}) from sea trials data)','Pump effective power (P_{PE})','Effective jet system power (P_{JSE})','Thrust effective power (P_{TE})');
hleg1 = legend('Effective power (P_{E})','Delivered power (P_{D})','Pump effective power (P_{PE})','Effective jet system power (P_{JSE})','Thrust effective power (P_{TE})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
minRun = min(resultsArraySPP(:,1));
maxRun = max(resultsArraySPP(:,1));
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_6_FS_Power_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 7. Full Scale, Jet and Inlet Velocity
%# ************************************************************************
figurename = 'Plot 7: Full Scale, Jet and Inlet Velocity';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# X and Y axis -----------------------------------------------------------

[m,n] = size(fullScaleDataArray);

%# Effective power, PE
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,2);

%# Delivered power, PD
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,26);

%# Delivered power, PD
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,27);

%# Delivered power, PD
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,28);

%# Delivered power, PD
x5 = fullScaleDataArray(:,3);
y5 = fullScaleDataArray(:,29);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*',x5,y5,'*');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Jet velocity, v_{j}, and inlet velocity, v_{i} (m/s)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Jet velocitiy and inlet velocity}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(5),'Color',setColor{5},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
set(gca,'XLim',[13 25]);
set(gca,'XTick',[13:1:25]);
set(gca,'YLim',[0 24]);
set(gca,'YTick',[0:4:24]);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('Ship speed (v_{s})','Port: Jet velocity (v_{j})','Stbd: Jet velocity (v_{j})','Port: Inlet velocity (v_{i})','Stbd: Inlet velocity (v_{i})');
set(hleg1,'Location','SouthEast');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_7_FS_Speed_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 8. Comparison Delivered Power to Sea Trials Data
%# ************************************************************************
figurename = 'Plot 8: Comparison Delivered Power to Corrected Sea Trials Data';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours ---------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# Delivered Power vs. Ship Speed /////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Deep water: Corrected sea trials power
x = SeaTrialsCorrectedPower(:,1);
y = SeaTrialsCorrectedPower(:,3);

% Shallow water: Corrected sea trials power
x1 = SeaTrialsCorrectedPowerShallowWater(:,1);
y1 = SeaTrialsCorrectedPowerShallowWater(:,3);

% Fitting curve through sea trials delivered power
fitobject = fit(x,y,'poly5');
cvalues = coeffvalues(fitobject);

% Sea Trials Data
fittingSpeeds = [13:1:25];
[mfs,nfs] = size(fittingSpeeds);
delpowerMW = [];
for k=1:nfs
    actSpeed = fittingSpeeds(k);
    delpowerMW(k) = cvalues(1)*actSpeed^5+cvalues(2)*actSpeed^4+cvalues(3)*actSpeed^3+cvalues(4)*actSpeed^2+cvalues(5)*actSpeed+cvalues(6);
end
xst  = fittingSpeeds;
yst  = delpowerMW;

% Measured data (Port+Stbd)*2 for two demi hulls
activeArray = fullScaleDataArray;
[ma,na] = size(activeArray);
delpowerMW = [];
for k=1:ma
    delpowerMW(k) = ((activeArray(k,42)+activeArray(k,43))*2)/1000^2;
end
x  = fullScaleDataArray(:,3);
y  = delpowerMW';

% Polynomial fit through points for m-th order least-squares regression analysis
% See: http://stats.stackexchange.com/questions/56596/finding-uncertainty-in-coefficients-from-polyfit-in-matlab
[p,S,mu]   = polyfit(x,y,4);
[y2,delta] = polyval(p,x,S,mu);

% MANUAL OVERWRITE (TEST): Calculated STD based on Ca=0 to 0.00059 investigation
% TODO: How TF do I automate STD for error bars!!!!!!!!!!!!!!!!!!!!!!!!!!!!
delta = [0.19,0.24,0.30,0.34,0.43,0.52,0.61,0.72,0.86,]';

%# Plotting ---------------------------------------------------------------
h = plot(xst,yst,'-',x,y,'*-');
hold on;
h1 = errorbar(x,y,delta,'k');
xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Total delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
if enablePlotTitle == 1
    title('{\bf Catamaran (i.e. two demi hulls)}','FontSize',setGeneralFontSize);
end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{10},'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(2),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1,'marker','x');
set(h1,'linestyle','none');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 14;
incrY = 2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
%set(gca,'xticklabel',num2str(get(gca,'xtick')','%.0f'))
%set(gca,'yticklabel',num2str(get(gca,'ytick')','%.0f'))

%# Legend
hleg1 = legend('Corrected power from sea trials (P_{D})','Measured delivered power (P_{D})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_8_FS_Comparison_PD_to_Sea_Trials_Data_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 8.1 Comparison of uncorrected Sea Trials Power
%# ************************************************************************
figurename = 'Plot 8.1: Comparison of uncorrected Sea Trials Power';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Deep water: Corrected sea trials power
x1 = SeaTrialsCorrectedPower(:,1);
y1 = SeaTrialsCorrectedPower(:,3);

% Shallow water: Corrected sea trials power
x2 = SeaTrialsCorrectedPowerShallowWater(:,1);
y2 = SeaTrialsCorrectedPowerShallowWater(:,3);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Shaft power (MW)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Sea trials power)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 7;
maxX  = 43;
incrX = 4;
minY  = 0;
maxY  = 30;
incrY = 5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('Deep water (1,500 tonnes)','Shallow water (1,525 tonnes)');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_8_1_FS_Comparison_PD_to_Sea_Trials_Data_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 9. Comparison Delivered Power to Sea Trials Data
%# ************************************************************************
figurename = 'Plot 9: Comparison Propulsive Efficiency Using nD=PE/PD and nD=(thrust V)/PPE';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours ---------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# Delivered Power vs. Ship Speed /////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Overall Propulsive Efficiency using Resistance - nD=PE/PD where PD = PPE/hpump
x1 = fullScaleDataArray(:,1);
y1 = fullScaleDataArray(:,46);

% Overall Propulsive Efficiency using Thrust - nD=(thrust V)/PPE
x3 = fullScaleDataArray(:,1);
y3 = fullScaleDataArray(:,72);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x3,y3,'*');
%xlabel('{\bf Ship speed, V_{s} (knots)}','FontSize',setGeneralFontSize);
xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Overall propulsive efficiency, \eta_{D} (-)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Catamaran (i.e. two demi hulls)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
%set(h(3),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
% set(h1,'marker','x');
% set(h1,'linestyle','none');

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
% Ship speed (knots)
%minX  = 13;
%maxX  = 25;
%incrX = 1;
% Froude length number
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 1;
incrY = 0.1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
%hleg1 = legend(h([1,3,5]),'Fr=0.24','Fr=0.26','Fr=0.28','Fr=0.30','Fr=0.32','Fr=0.34','Fr=0.36','Fr=0.38','Fr=0.40');
hleg1 = legend('\eta_{D}=P_{E}/P_{D}','n_{D}=\Delta M V/P_{PE}'); % '\eta_{D}=P_{E}/P_{D} where P_{D}=P_{JSE}/\eta_{JS}'
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_9_FS_Comparison_Propulsive_Efficiency_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 10. Comparing model (KTm) and full scale (KTs) thrust coefficients
%# ************************************************************************
figurename = 'Plot 10: Thrust identity (C_{T})';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours ---------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% MS Port
x1 = ThrustCoeffArray(:,1);
y1 = ThrustCoeffArray(:,8);

% MS Stbd
x2 = ThrustCoeffArray(:,1);
y2 = ThrustCoeffArray(:,9);

% FS Port
x3 = ThrustCoeffArray(:,1);
y3 = ThrustCoeffArray(:,12);

% FS Stbd
x4 = ThrustCoeffArray(:,1);
y4 = ThrustCoeffArray(:,13);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*',x2,y2,'*',x3,y3,'*',x4,y4,'*');
xlabel('{\bf Froude length number (-)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust coefficient, K_{T} (-)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Thrust coefficient comparison)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(2),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(3),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 0.3;
incrY = 0.05;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend('Port: Model scale','Stbd: Model scale','Port: Full scale','Stbd: Full scale');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_10_MS_And_FS_Thrust_Coefficient_Comparison_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 11. Thrust-drag equilibrium
%# ************************************************************************
figurename = 'Plot 11: Thrust-drag equilibrium';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 12;
setLineWidthMarker = 2;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Total resistance, RT
x1 = ResResults(7:19,11);
y1 = ResResults(7:19,24);

% Extrapolated thrust: total catamaran = (port thrust + stbd thrust) * 2
x2  = fullScaleDataArray(:,3);
y2p = fullScaleDataArray(:,20);
y2s = fullScaleDataArray(:,21);

[m2,n2] = size(x2);
y2t = [];
for k2=1:m2
    y2t(k2) = (y2p(k2)+y2s(k2))*2;
end
y2t = y2t';

%# Divide thrust data by 1000 for kN
Raw_Data = num2cell(y2t);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y2t = cell2mat(Raw_Data);

% Thrust based on sea trials shaft power (see IntPolThrustArray in analysis_thrustcurves.m)

%# ************************************************************************
%# START Interpolated thrust results (thrust curves + sea trials power)
%# ------------------------------------------------------------------------
if exist('IntPolThrustArray.dat', 'file') == 2
    %# Results array columns:
    IntPolThrustArray = csvread('IntPolThrustArray.dat');
    [mfsr,nfsr] = size(IntPolThrustArray);
    %# Remove zero rows
    IntPolThrustArray(all(IntPolThrustArray==0,2),:)=[];
    x3 = IntPolThrustArray(:,1);
    y3 = IntPolThrustArray(:,5);
else
    % Example set of data
    x3 = [14.10 15.35 16.52 17.66 18.83 20.08 21.26 22.40 23.65];
    y3 = [243.94 274.44 305.69 337.89 373.26 413.68 453.09 491.89 535.19];
end
%# ------------------------------------------------------------------------
%# START Interpolated thrust results (thrust curves + sea trials power)
%# ************************************************************************

%# Plotting ---------------------------------------------------------------
h = plot(x2,y2t,'*-',x3,y3,'*-',x1,y1,'-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Resistance and thrust (kN)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Resistance and thrust comparison)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h(3),'Color',setColor{10},'Marker','none','LineStyle',setLineStyle,'linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 150;
maxY  = 600;
incrY = 50;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'));

%# Legend
hleg1 = legend('Extrapolated thrust from model tests (T_{Ext})','Thrust using sea trials and thrust curves (T_{ST})','Bare hull resistance (R_{BH})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_11_FS_Resistance_vs_Extrapolated_Thrust_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 11.1 Thrust-drag equilibrium
%# ************************************************************************
figurename = 'Plot 11.1: Thrust-drag equilibrium';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Total resistance, RT
%x1 = ResResults(7:19,11);
%y1 = ResResults(7:19,24);
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,12);

Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) (y/1000)*2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% Extrapolated thrust: total catamaran = (port thrust + stbd thrust) * 2
x2  = fullScaleDataArray(:,3);
y2p = fullScaleDataArray(:,20);
y2s = fullScaleDataArray(:,21);

[m2,n2] = size(x2);
y2t = [];
for k2=1:m2
    y2t(k2) = (y2p(k2)+y2s(k2))*2;
end
y2t = y2t';

%# Divide thrust data by 1000 for kN
Raw_Data = num2cell(y2t);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y2t = cell2mat(Raw_Data);

% Thrust based on sea trials shaft power (see IntPolThrustArray in analysis_thrustcurves.m)

%# ************************************************************************
%# START Interpolated thrust results (thrust curves + sea trials power)
%# ------------------------------------------------------------------------
if exist('IntPolThrustArray.dat', 'file') == 2
    %# Results array columns:
    IntPolThrustArray = csvread('IntPolThrustArray.dat');
    [mfsr,nfsr] = size(IntPolThrustArray);
    %# Remove zero rows
    IntPolThrustArray(all(IntPolThrustArray==0,2),:)=[];
    x3 = IntPolThrustArray(:,1);
    y3 = IntPolThrustArray(:,5);
else
    % Example set of data
    x3 = [14.10 15.35 16.52 17.66 18.83 20.08 21.26 22.40 23.65];
    y3 = [243.94 274.44 305.69 337.89 373.26 413.68 453.09 491.89 535.19];
end
%# ------------------------------------------------------------------------
%# START Interpolated thrust results (thrust curves + sea trials power)
%# ************************************************************************

% Force at zero thrust FT=0 extrapolated to full scale using ITTC1978
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,85);

Raw_Data = num2cell(y4);
Raw_Data = cellfun(@(y) (y/1000)*2, Raw_Data, 'UniformOutput', false);
y4 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy([x2 x3], [y2t y3], [x1 x4], [y1 y4], 'plot');
Plot111LegendInfo{1} = 'Extrapolated thrust from model tests (T_{Ext})';
Plot111LegendInfo{2} = 'Thrust using sea trials and thrust curves (T_{ST})';
Plot111LegendInfo{3} = 'Bare hull resistance (R_{BH})';
Plot111LegendInfo{4} = 'Force at zero thrust (F_{T=0})';
% Left color black, right color black
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Froude length number, F_{r} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale thrust and restistance','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Thrust (kN)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Resistance R_{BH} and force at zero thrust F_{T=0} (kN)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin); 
set(h1(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin); 
% Right Y-axis
set(h2(1),'Color',setColor{3},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth); 
set(h2(2),'Color',setColor{4},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth); 

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 150;
maxY  = 600;
incrY = 50;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
%set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
%set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 150;
maxY  = 600;
incrY = 50;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
%set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
%set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
%hleg1 = legend('Overall propulsive efficiency (\eta_{D})','Residual resistance coefficient (C_{Rs})');
hleg1 = legend(Plot111LegendInfo);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_11_1_FS_Resistance_vs_Extrapolated_Thrust_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 12. Model scale ship speed, jet and inlet velocity and mass flow rate
%# ************************************************************************
figurename = 'Plot 12: Model scale ship speed, jet and inlet velocity and mass flow rate';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

%if enableA4PaperSizePlot == 1
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);
%end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 16;
setBorderLineWidth = 2;
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

% Ship speed
x1 = modelScaleDataArray(:,3);
y1 = modelScaleDataArray(:,2);

% PORT: Jet velocity
x2 = modelScaleDataArray(:,3);
y2 = modelScaleDataArray(:,26);

% STBD: Jet velocity
x3 = modelScaleDataArray(:,3);
y3 = modelScaleDataArray(:,27);

% PORT: Inlet velocity
x4 = modelScaleDataArray(:,3);
y4 = modelScaleDataArray(:,28);

% STBD: Inlet velocity
x5 = modelScaleDataArray(:,3);
y5 = modelScaleDataArray(:,29);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'-',x2,y2,'*-',x3,y3,'*-',x4,y4,'*-',x5,y5,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Ship speed, jet and inlet velocity (m/s)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidthThin);
set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(3),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h(4),'Color',setColor{4},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(5),'Color',setColor{5},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 6;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('Ship speed, V_{m}','Port: Jet velocity, V_{J}','Stbd: Jet velocity, V_{J}','Port: Inlet velocity, V_{I}','Stbd: Inlet velocity, V_{I}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,2)

%# X and Y axis -----------------------------------------------------------

% PORT: Jet velocity
x1 = modelScaleDataArray(:,3);
y1 = modelScaleDataArray(:,24);

% STBD: Jet velocity
x2 = modelScaleDataArray(:,3);
y2 = modelScaleDataArray(:,25);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Mass  flow rate (Kg/s)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(2),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('Port: Mass flow rate, \rho Q_{J}','Stbd: Mass flow rate, \rho Q_{J}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
%if enableA4PaperSizePlot == 1
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');
%end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_12_Ship_Speed_Jet_Inlet_Velocity_Mass_Flow_Rate_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 12.1 Full scale ship speed vs. jet and inlet velocity - Thesis plot
%# ************************************************************************
figurename = 'Plot 12.1: Full scale ship speed vs. jet and inlet velocity';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Ship speed
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,2);

% PORT: Jet velocity
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,26);

% STBD: Jet velocity
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,27);

% PORT: Inlet velocity
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,28);

% STBD: Inlet velocity
x5 = fullScaleDataArray(:,3);
y5 = fullScaleDataArray(:,29);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'-',x2,y2,'*-',x3,y3,'*-',x4,y4,'*-',x5,y5,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Ship speed, jet and inlet velocity (m/s)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(2),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(3),'Color',setColor{3},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(4),'Color',setColor{4},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 6;
maxY  = 24;
incrY = 2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('Ship speed (V_{s})','Port: Jet velocity (V_{J})','Stbd: Jet velocity (V_{J})','Port: Inlet velocity (V_{I})','Stbd: Inlet velocity (V_{I})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_12_1_Full_Scale_Ship_Speed_Jet_Inlet_Velocity_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 12.1.1 Averaged full scale ship speed vs. jet and inlet velocity - Thesis plot
%# ************************************************************************
figurename = 'Plot 12.1.1: Averaged full scale ship speed vs. jet and inlet velocity';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

[m1211,n1211] = size(fullScaleDataArray(:,3));

% Ship speed
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,2);

% PORT: Jet velocity
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,26);

% STBD: Jet velocity
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,27);

% Averaged jet velocity
AvgTempArray1 = [];
for ky=1:m1211
    AvgTempArray1(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray1(ky,2) = (fullScaleDataArray(ky,26)+fullScaleDataArray(ky,27))/2;
end

x6 = AvgTempArray1(:,1);
y6 = AvgTempArray1(:,2);

% PORT: Inlet velocity
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,28);

% STBD: Inlet velocity
x5 = fullScaleDataArray(:,3);
y5 = fullScaleDataArray(:,29);

% Averaged inlet velocity
AvgTempArray2 = [];
for ky=1:m1211
    AvgTempArray2(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray2(ky,2) = (fullScaleDataArray(ky,28)+fullScaleDataArray(ky,29))/2;
end

x7 = AvgTempArray2(:,1);
y7 = AvgTempArray2(:,2);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'-',x6,y6,'*-',x7,y7,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Ship speed, jet and inlet velocity (m/s)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{1},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth);
set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(3),'Color',setColor{3},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 6;
maxY  = 24;
incrY = 2;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('Ship speed (V_{s})','Jet velocity (V_{J})','Inlet velocity (V_{I})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_12_1_1_Averaged_Full_Scale_Ship_Speed_Jet_Inlet_Velocity_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 12.2 Full scale ship speed vs. mass flow rate
%# ************************************************************************
figurename = 'Plot 12.2: Full scale ship speed vs. mass flow rate';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% PORT: Jet velocity
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,24);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Jet velocity
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,25);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

% PORT: Thrust
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,20);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y3);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

% STBD: Thrust
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,21);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y4);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y4 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy([x1 x2], [y1 y2], [x3 x4], [y3 y4], 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Ship speed (knots)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Mass flow rate (t/s)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Thrust (kN)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.08 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.08 0.97 0.9]); % [Left, bottom, right, top]

% %h = plot(x1,y1,'*-',x2,y2,'*-');
% xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
% ylabel('{\bf Mass  flow rate (Kg/s)}','FontSize',setGeneralFontSize);
% % if enablePlotTitle == 1
% %     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
% % end
% grid on;
% box on;
% axis square;

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
% Right Y-axis
set(h2(1),'Color',setColor{5},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h2(2),'Color',setColor{6},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 5.5;
maxY  = 9.5;
incrY = 0.5;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
% set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 160;
incrY = 20;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
% set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
% set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
hleg1 = legend('Port: Mass flow rate','Stbd: Mass flow rate','Port: Thrust','Stbd: Thrust');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_12_2_Full_Scale_Ship_Speed_Mass_Flow_Rate_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 12.2.1 Averaged full scale ship speed vs. mass flow rate (single propulsion system)
%# ************************************************************************
figurename = 'Plot 12.2.1: Averaged full scale ship speed vs. mass flow rate (single propulsion system)';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

[m1221,n1221] = size(fullScaleDataArray(:,3));

% PORT: Mass flow rate
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,24);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Mass flow rate
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,25);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

% Averaged mass flow rate
AvgTempArray1 = [];
for ky=1:m1221
    AvgTempArray1(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray1(ky,2) = (y1(ky)+y2(ky))/2;
end

x5 = AvgTempArray1(:,1);
y5 = AvgTempArray1(:,2);

% PORT: Thrust
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,20);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y3);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

% STBD: Thrust
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,21);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y4);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y4 = cell2mat(Raw_Data);

% Averaged thrust
AvgTempArray2 = [];
for ky=1:m1221
    AvgTempArray2(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray2(ky,2) = (y3(ky)+y4(ky))/2;
end

x6 = AvgTempArray2(:,1);
y6 = AvgTempArray2(:,2);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy(x5, y5, x6, y6, 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Ship speed (knots)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Mass flow rate (t/s)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Thrust (kN)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.08 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.08 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
% Right Y-axis
set(h2(1),'Color',setColor{5},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 5.5;
maxY  = 9.5;
incrY = 0.5;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
% set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 160;
incrY = 20;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
% set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
% set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
hleg1 = legend('Mass flow rate','Thrust');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_12_2_1_Full_Scale_Ship_Speed_Mass_Flow_Rate_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 12.3 Full scale shaft speed (RPS) vs. mass flow rate
%# ************************************************************************
figurename = 'Plot 12.3: Full scale shaft speed (RPS) vs. mass flow rate';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

%if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
%end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 16;
setBorderLineWidth = 2;
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,2,1)

%# X and Y axis -----------------------------------------------------------

[m123,n123] = size(fullScaleDataArray(:,7));

% PORT: Mass flow rate
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,22);

% STBD: Mass flow rate
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,23);

AvgTempArray = [];
for ky=1:m123
    AvgTempArray(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray(ky,2) = (fullScaleDataArray(ky,22)+fullScaleDataArray(ky,23))/2;
end

x3 = AvgTempArray(:,1);
y3 = AvgTempArray(:,2);

%# Plotting ---------------------------------------------------------------
h = plot(x3,y3,'*-');
legendInfo123{1} = 'Averaged port/stbd';
% Patch min/max area
patch([x1;flipud(x2)],[y1;flipud(y2)],[0.9,0.9,0.9]); %,'EdgeColor','none'
legendInfo123{2} = 'Port/stbd values';
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Volumetric flow rate, Q_{J} (m^{3}/s)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Volumetric flow rate)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 2;
minY  = 5;
maxY  = 10;
incrY = 1;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo123);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,2,2)

%# X and Y axis -----------------------------------------------------------

% PORT: Thrust
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,20);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Thrust
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,21);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

AvgTempArray = [];
for ky=1:m123
    AvgTempArray(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray(ky,2) = (y1(ky)+y2(ky))/2;
end

x3 = AvgTempArray(:,1);
y3 = AvgTempArray(:,2);

%# Plotting ---------------------------------------------------------------
h = plot(x3,y3,'*-');
legendInfo123{1} = 'Averaged port/stbd';
% Patch min/max area
patch([x1;flipud(x2)],[y1;flipud(y2)],[0.9,0.9,0.9]); %,'EdgeColor','none'
legendInfo123{2} = 'Port/stbd values';
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Gross thrust, T_{G} (kN)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Thrust)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 2;
minY  = 30;
maxY  = 110;
incrY = 10;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo123);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,2,3)

%# X and Y axis -----------------------------------------------------------

% PORT: Delivered power
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,42);

%# Divide resistance data by 1000^2 for better readibility
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Delivered power
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,43);

%# Divide resistance data by 1000^2 for better readibility
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

AvgTempArray = [];
for ky=1:m123
    AvgTempArray(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray(ky,2) = (y1(ky)+y2(ky))/2;
end

x3 = AvgTempArray(:,1);
y3 = AvgTempArray(:,2);

%# Plotting ---------------------------------------------------------------
h = plot(x3,y3,'*-');
legendInfo123{1} = 'Averaged port/stbd';
% Patch min/max area
patch([x1;flipud(x2)],[y1;flipud(y2)],[0.9,0.9,0.9]); %,'EdgeColor','none'
legendInfo123{2} = 'Port/stbd values';
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Delivered power, P_{D} (MW)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Delivered power)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 2;
minY  = 0.5;
maxY  = 3.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo123);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(2,2,4)

%# X and Y axis -----------------------------------------------------------

% PORT: Effective pump power
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,40);

%# Divide resistance data by 1000^2 for better readibility
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Effective pump power
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,41);

%# Divide resistance data by 1000^2 for better readibility
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

AvgTempArray = [];
for ky=1:m123
    AvgTempArray(ky,1) = fullScaleDataArray(ky,3);
    AvgTempArray(ky,2) = (y1(ky)+y2(ky))/2;
end

x3 = AvgTempArray(:,1);
y3 = AvgTempArray(:,2);

%# Plotting ---------------------------------------------------------------
h = plot(x3,y3,'*-');
legendInfo123{1} = 'Averaged port/stbd';
% Patch min/max area
patch([x1;flipud(x2)],[y1;flipud(y2)],[0.9,0.9,0.9]); %,'EdgeColor','none'
legendInfo123{2} = 'Port/stbd values';
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Effective pump power, P_{PE} (MW)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Effective pump power)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{3},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 2;
minY  = 0;
maxY  = 2.5;
incrY = 0.5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'));
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend(legendInfo123);
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
%if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
%end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_12_3_Full_Scale_RPS_vs_Mass_Flow_Rate_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


if exist(SetAvgResistanceFilePath, 'file') == 2
    %# ************************************************************************
    %# 13. Heave and running trim comparison plot (Resistace and SP test)
    %# ************************************************************************
    figurename = 'Plot 13: Heave and running trim comparison plot (Resistace and SP test)';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ----------------------------------------------------
    
    %if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    %end
    
    % Fonts and colours -------------------------------------------------------
    setGeneralFontName = 'Helvetica';
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. ------------------------------------
    set(gca,'TickDir','in',...
        'FontSize',12,...
        'LineWidth',2,...
        'FontName',setGeneralFontName,...
        'Clipping','off',...
        'Color',[1 1 1],...
        'LooseInset',get(gca,'TightInset'));
    
    %# Markes and colors ------------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 14;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# Minimum and maximum heave and trim values
    [mavg,navg] = size(avgcond7);
    
    MinMaxHeaveTrimArray = [];
    % MinMaxHeaveTrimArray columns:
    %[1] Ship speed                 (knots)
    %[2] Minimum heave              (mm)
    %[3] Average heave              (mm)
    %[4] Maximum heave              (mm)
    %[5] Standard deviation heave   (mm)
    %[6] Minimum trim               (deg)
    %[7] Average trim               (deg)
    %[8] Maximum trim               (deg)
    %[9] Standard deviation trim    (deg)
    for kavg=1:mavg
        % Ship speed ------------------------------------------------------
        MinMaxHeaveTrimArray(kavg,1) = avgcond7(kavg,15);
        % Heave -----------------------------------------------------------
        MinHeave = (avgcond7(kavg,33)+avgcond7(kavg,37))/2;
        AvgHeave = avgcond7(kavg,12);
        MaxHeave = (avgcond7(kavg,34)+avgcond7(kavg,38))/2;
        StdHeave = std([MinHeave AvgHeave MaxHeave],1);
        MinMaxHeaveTrimArray(kavg,2) = MinHeave;
        MinMaxHeaveTrimArray(kavg,3) = AvgHeave;
        MinMaxHeaveTrimArray(kavg,4) = MaxHeave;
        MinMaxHeaveTrimArray(kavg,5) = StdHeave;
        % Trim ------------------------------------------------------------
        MinTrim = atand((avgcond7(kavg,33)-avgcond7(kavg,37))/distbetwposts);
        AvgTrim = avgcond7(kavg,13);
        MaxTrim = atand((avgcond7(kavg,34)-avgcond7(kavg,38))/distbetwposts);
        StdTrim = std([MinTrim AvgTrim MaxTrim],1);
        MinMaxHeaveTrimArray(kavg,6) = MinTrim;
        MinMaxHeaveTrimArray(kavg,7) = AvgTrim;
        MinMaxHeaveTrimArray(kavg,8) = MaxTrim;
        MinMaxHeaveTrimArray(kavg,9) = StdTrim;
    end
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,1)
    
    %# X and Y axis -----------------------------------------------------------
    
    % Resistance test
    x1 = avgcond7(:,15);
    y1 = avgcond7(:,12);
    
    [fitobject1,gof1,output1]  = fit(x1,y1,'poly5');
    cvalues1 = coeffvalues(fitobject1);
    
    [m1,n1] = size(x1);
    TA1 = [];
    for k1=1:m1
        TA1(k1,1) = x1(k1);
        TA1(k1,2) = cvalues1(1)*x1(k1)^5+cvalues1(2)*x1(k1)^4+cvalues1(3)*x1(k1)^3+cvalues1(4)*x1(k1)^2+cvalues1(5)*x1(k1)+cvalues1(6);
    end
    
    % Self-propulsion test
    x2 = modelScaleDataArray(:,3);
    y2 = resSPP_CCDoTT(:,18);
    
    % Maximum value
    x3 = MinMaxHeaveTrimArray(:,1);
    y3 = MinMaxHeaveTrimArray(:,2);
    
    [fitobject3,gof3,output3]  = fit(x3,y3,'poly5');
    cvalues3 = coeffvalues(fitobject3);
    
    [m3,n3] = size(x3);
    TA3 = [];
    for k3=1:m3
        TA3(k3,1) = x3(k3);
        TA3(k3,2) = cvalues3(1)*x3(k3)^5+cvalues3(2)*x3(k3)^4+cvalues3(3)*x3(k3)^3+cvalues3(4)*x3(k3)^2+cvalues3(5)*x3(k3)+cvalues3(6);
    end    
    
    % Minimum value
    x4 = MinMaxHeaveTrimArray(:,1);
    y4 = MinMaxHeaveTrimArray(:,4);
    
    [fitobject4,gof4,output4]  = fit(x4,y4,'poly5');
    cvalues4 = coeffvalues(fitobject4);
    
    [m4,n4] = size(x4);
    TA4 = [];
    for k4=1:m4
        TA4(k4,1) = x4(k4);
        TA4(k4,2) = cvalues4(1)*x4(k4)^5+cvalues4(2)*x4(k4)^4+cvalues4(3)*x4(k4)^3+cvalues4(4)*x4(k4)^2+cvalues4(5)*x4(k4)+cvalues4(6);
    end
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*-');
    legendInfoPlot13_1{1} = 'Resistance test (mean)';
    % Patch min/max area
    patch([x3;flipud(x4)],[y3;flipud(y4)],[0.9,0.9,0.9]); %,'EdgeColor','none'
    legendInfoPlot13_1{2} = 'Resistance test (minimum and maximum values)';
    % Maximum values
    %hold on;
    %h1 = plot(x3,y3,'-');
    %legendInfoPlot13_1{2} = 'Resistance test (maximum)';
    % Minimum values
    %hold on;
    %h2 = plot(x4,y4,'-');
    %legendInfoPlot13_1{3} = 'Resistance test (minimum)';
    %patch([x3;flipud(x3)],[y4;flipud(y2)],[0.05 0.1 0.3]);
    % Standard deviation
    %hold on;
    %h3 = errorbar(x1,y1,MinMaxHeaveTrimArray(:,5),'k');
    % Self-propulsion test
    hold on;
    h4 = plot(x2,y2,'*-');
    legendInfoPlot13_1{3} = 'Self-propulsion test';  
    xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave (mm)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h4(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Min, avg, max values, and standard deviation
    %set(h1(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    %set(h2(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Error bars
    %set(h3,'marker','x');
    %set(h3,'linestyle','none');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Annotations
    % Text on plot
    %text(13.5,-8.5,'Legend:','FontSize',12,'color','k','FontWeight','bold');
    %text(13.5,-9,'RES = Resistance test','FontSize',12,'color','k','FontWeight','normal');
    %text(13.5,-9.5,'SPT = Self-propulsion test','FontSize',12,'color','k','FontWeight','normal');
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = -10;
    maxY  = 2;
    incrY = 1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfoPlot13_1);
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,2)
    
    %# X and Y axis -----------------------------------------------------------
    
    % Resistance test
    x1 = avgcond7(:,15);
    y1 = avgcond7(:,13);
    
    % Self-propulsion test
    x2 = modelScaleDataArray(:,3);
    y2 = resSPP_CCDoTT(:,19);
    
    % Maximum value
    x3 = MinMaxHeaveTrimArray(:,1);
    y3 = MinMaxHeaveTrimArray(:,6);
    
    % Minimum value
    x4 = MinMaxHeaveTrimArray(:,1);
    y4 = MinMaxHeaveTrimArray(:,8);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*-');
    legendInfoPlot13_2{1} = 'Resistance test';
    % Patch min/max area
    %patch([x3;flipud(x4)],[y3;flipud(y4)],[0.8,0.8,0.8]);
    %legendInfo{2} = 'Resistance test (min. to max. values)';
    % Maximum values
    %hold on;
    %h1 = plot(x3,y3,'-');
    %legendInfo{2} = 'Resistance test (maximum)';
    % Minimum values
    %hold on;
    %h2 = plot(x4,y4,'-');
    %legendInfo{3} = 'Resistance test (minimum)';
    % Standard deviation
    %hold on;
    %h3 = errorbar(x1,y1,MinMaxHeaveTrimArray(:,9),'k');
    % Self-propulsion test
    hold on;
    h4 = plot(x2,y2,'*-');
    legendInfoPlot13_2{2} = 'Self-propulsion test';
    xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Running trim (deg)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h4(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Min, avg, max values, and standard deviation
    %set(h1(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    %set(h2(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Error bars
    %set(h3,'marker','x');
    %set(h3,'linestyle','none');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Annotations
    % Text on plot
    %text(13.5,-0.06,'Legend:','FontSize',12,'color','k','FontWeight','bold');
    %text(13.5,-0.11,'RES = Resistance test','FontSize',12,'color','k','FontWeight','normal');
    %text(13.5,-0.16,'SPT = Self-propulsion test','FontSize',12,'color','k','FontWeight','normal');
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 0.7;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfoPlot13_2);
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# ************************************************************************
    %# Save plot as PNG
    %# ************************************************************************
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    %if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    %end
    
    %# Plot title -------------------------------------------------------------
    %     if enablePlotMainTitle == 1
    %         annotation('textbox', [0 0.9 1 0.1], ...
    %             'String', strcat('{\bf ', figurename, '}'), ...
    %             'EdgeColor', 'none', ...
    %             'HorizontalAlignment', 'center');
    %     end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/SPP_Plot_13_Heave_And_Running_Trim_Comparison_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    
    %# ************************************************************************
    %# 13.1. Curve fitted heave and running trim comparison plot
    %# ************************************************************************
    figurename = 'Plot 13.1: Curve fitted heave and running trim comparison plot (Resistace and SP test)';
    f = figure('Name',figurename,'NumberTitle','off');
    
    %# Paper size settings ----------------------------------------------------
    
    %if enableA4PaperSizePlot == 1
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [19 19]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 19 19]);
    %end
    
    % Fonts and colours -------------------------------------------------------
    setGeneralFontName = 'Helvetica';
    setGeneralFontSize = 16;
    setBorderLineWidth = 2;
    setLegendFontSize  = 14;
    
    %# Change default text fonts for plot title
    set(0,'DefaultTextFontname',setGeneralFontName);
    set(0,'DefaultTextFontSize',14);
    
    %# Box thickness, axes font size, etc. ------------------------------------
    set(gca,'TickDir','in',...
        'FontSize',12,...
        'LineWidth',2,...
        'FontName',setGeneralFontName,...
        'Clipping','off',...
        'Color',[1 1 1],...
        'LooseInset',get(gca,'TightInset'));
    
    %# Markes and colors ------------------------------------------------------
    setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
    % Colored curves
    setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
    if enableBlackAndWhitePlot == 1
        % Black and white curves
        setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
    end
    
    %# Line, colors and markers
    setMarkerSize      = 14;
    setLineWidthMarker = 1;
    setLineWidth       = 2;
    setLineWidthThin   = 1;
    setLineStyle       = '-';
    setLineStyle1      = '--';
    setLineStyle2      = '-.';
    setLineStyle3      = ':';
    
    %# Minimum and maximum heave and trim values
    [mavg,navg] = size(avgcond7);
    
    MinMaxHeaveTrimArray = [];
    % MinMaxHeaveTrimArray columns:
    %[1] Ship speed                 (knots)
    %[2] Minimum heave              (mm)
    %[3] Average heave              (mm)
    %[4] Maximum heave              (mm)
    %[5] Standard deviation heave   (mm)
    %[6] Minimum trim               (deg)
    %[7] Average trim               (deg)
    %[8] Maximum trim               (deg)
    %[9] Standard deviation trim    (deg)
    for kavg=1:mavg
        % Ship speed ------------------------------------------------------
        MinMaxHeaveTrimArray(kavg,1) = avgcond7(kavg,15);
        % Heave -----------------------------------------------------------
        MinHeave = (avgcond7(kavg,33)+avgcond7(kavg,37))/2;
        AvgHeave = avgcond7(kavg,12);
        MaxHeave = (avgcond7(kavg,34)+avgcond7(kavg,38))/2;
        StdHeave = std([MinHeave AvgHeave MaxHeave],1);
        MinMaxHeaveTrimArray(kavg,2) = MinHeave;
        MinMaxHeaveTrimArray(kavg,3) = AvgHeave;
        MinMaxHeaveTrimArray(kavg,4) = MaxHeave;
        MinMaxHeaveTrimArray(kavg,5) = StdHeave;
        % Trim ------------------------------------------------------------
        MinTrim = atand((avgcond7(kavg,33)-avgcond7(kavg,37))/distbetwposts);
        AvgTrim = avgcond7(kavg,13);
        MaxTrim = atand((avgcond7(kavg,34)-avgcond7(kavg,38))/distbetwposts);
        StdTrim = std([MinTrim AvgTrim MaxTrim],1);
        MinMaxHeaveTrimArray(kavg,6) = MinTrim;
        MinMaxHeaveTrimArray(kavg,7) = AvgTrim;
        MinMaxHeaveTrimArray(kavg,8) = MaxTrim;
        MinMaxHeaveTrimArray(kavg,9) = StdTrim;
    end
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,1)
    
    %# X and Y axis -----------------------------------------------------------
    
    % Resistance test
    x1 = avgcond7(:,15);
    y1 = avgcond7(:,12);
    
    [fitobject1,gof1,output1]  = fit(x1,y1,'poly5');
    cvalues1 = coeffvalues(fitobject1);
    
    [m1,n1] = size(x1);
    TA1 = [];
    for k1=1:m1
        TA1(k1,1) = x1(k1);
        TA1(k1,2) = cvalues1(1)*x1(k1)^5+cvalues1(2)*x1(k1)^4+cvalues1(3)*x1(k1)^3+cvalues1(4)*x1(k1)^2+cvalues1(5)*x1(k1)+cvalues1(6);
    end
    
    % Self-propulsion test
    x2 = modelScaleDataArray(:,3);
    y2 = resSPP_CCDoTT(:,18);
    
    % Maximum value
    x3 = MinMaxHeaveTrimArray(:,1);
    y3 = MinMaxHeaveTrimArray(:,2);
    
    [fitobject3,gof3,output3]  = fit(x3,y3,'poly5');
    cvalues3 = coeffvalues(fitobject3);
    
    [m3,n3] = size(x3);
    TA3 = [];
    for k3=1:m3
        TA3(k3,1) = x3(k3);
        TA3(k3,2) = cvalues3(1)*x3(k3)^5+cvalues3(2)*x3(k3)^4+cvalues3(3)*x3(k3)^3+cvalues3(4)*x3(k3)^2+cvalues3(5)*x3(k3)+cvalues3(6);
    end    
    
    % Minimum value
    x4 = MinMaxHeaveTrimArray(:,1);
    y4 = MinMaxHeaveTrimArray(:,4);
    
    [fitobject4,gof4,output4]  = fit(x4,y4,'poly5');
    cvalues4 = coeffvalues(fitobject4);
    
    [m4,n4] = size(x4);
    TA4 = [];
    for k4=1:m4
        TA4(k4,1) = x4(k4);
        TA4(k4,2) = cvalues4(1)*x4(k4)^5+cvalues4(2)*x4(k4)^4+cvalues4(3)*x4(k4)^3+cvalues4(4)*x4(k4)^2+cvalues4(5)*x4(k4)+cvalues4(6);
    end
    
    %# Plotting ---------------------------------------------------------------
    h = plot(TA1(:,1),TA1(:,2),'*-');
    legendInfoPlot13_1{1} = 'Resistance test (mean)';
    % Patch min/max area
    patch([TA3(:,1);flipud(TA4(:,1))],[TA3(:,2);flipud(TA4(:,2))],[0.9,0.9,0.9]); %,'EdgeColor','none'
    legendInfoPlot13_1{2} = 'Resistance test (minimum and maximum values)';
    % Maximum values
    %hold on;
    %h1 = plot(x3,y3,'-');
    %legendInfoPlot13_1{2} = 'Resistance test (maximum)';
    % Minimum values
    %hold on;
    %h2 = plot(x4,y4,'-');
    %legendInfoPlot13_1{3} = 'Resistance test (minimum)';
    %patch([x3;flipud(x3)],[y4;flipud(y2)],[0.05 0.1 0.3]);
    % Standard deviation
    %hold on;
    %h3 = errorbar(x1,y1,MinMaxHeaveTrimArray(:,5),'k');
    % Self-propulsion test
    hold on;
    h4 = plot(x2,y2,'*-');
    legendInfoPlot13_1{3} = 'Self-propulsion test';
%     % Curve fitting
%     hold on;
%     %hf1x = plot(fitobject1,'r-',x3,y3,'k*');
%     hf1 = plot(TA1(:,1),TA1(:,2),'*-');
%     hold on;
%     %hf3x = plot(fitobject3,'g-',x3,y3,'kx');
%     hf3 = plot(TA3(:,1),TA3(:,2),'*-');
%     hold on;
%     %hf4x = plot(fitobject4,'b-',x4,y4,'k+');
%     hf4 = plot(TA4(:,1),TA4(:,2),'*-');
%     % Patch min/max area
%     patch([TA3(:,1);flipud(TA4(:,1))],[TA3(:,2);flipud(TA4(:,2))],[0.8,0.8,0.8]); %,'EdgeColor','none'    
    xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Heave (mm)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h4(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Min, avg, max values, and standard deviation
    %set(h1(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    %set(h2(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Error bars
    %set(h3,'marker','x');
    %set(h3,'linestyle','none');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Annotations
    % Text on plot
    %text(13.5,-8.5,'Legend:','FontSize',12,'color','k','FontWeight','bold');
    %text(13.5,-9,'RES = Resistance test','FontSize',12,'color','k','FontWeight','normal');
    %text(13.5,-9.5,'SPT = Self-propulsion test','FontSize',12,'color','k','FontWeight','normal');
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = -10;
    maxY  = 2;
    incrY = 1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    % set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfoPlot13_1);
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# SUBPLOT ////////////////////////////////////////////////////////////////
    subplot(1,2,2)
    
    %# X and Y axis -----------------------------------------------------------
    
    % Resistance test
    x1 = avgcond7(:,15);
    y1 = avgcond7(:,13);
    
    % Self-propulsion test
    x2 = modelScaleDataArray(:,3);
    y2 = resSPP_CCDoTT(:,19);
    
    % Maximum value
    x3 = MinMaxHeaveTrimArray(:,1);
    y3 = MinMaxHeaveTrimArray(:,6);
    
    % Minimum value
    x4 = MinMaxHeaveTrimArray(:,1);
    y4 = MinMaxHeaveTrimArray(:,8);
    
    %# Plotting ---------------------------------------------------------------
    h = plot(x1,y1,'*-');
    legendInfoPlot13_2{1} = 'Resistance test';
    % Patch min/max area
    %patch([x3;flipud(x4)],[y3;flipud(y4)],[0.8,0.8,0.8]);
    %legendInfo{2} = 'Resistance test (min. to max. values)';
    % Maximum values
    %hold on;
    %h1 = plot(x3,y3,'-');
    %legendInfo{2} = 'Resistance test (maximum)';
    % Minimum values
    %hold on;
    %h2 = plot(x4,y4,'-');
    %legendInfo{3} = 'Resistance test (minimum)';
    % Standard deviation
    %hold on;
    %h3 = errorbar(x1,y1,MinMaxHeaveTrimArray(:,9),'k');
    % Self-propulsion test
    hold on;
    h4 = plot(x2,y2,'*-');
    legendInfoPlot13_2{2} = 'Self-propulsion test';
    xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Running trim (deg)}','FontSize',setGeneralFontSize);
    % if enablePlotTitle == 1
    %     title('{\bf Velocities)}','FontSize',setGeneralFontSize);
    % end
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    set(h4(1),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Min, avg, max values, and standard deviation
    %set(h1(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
    %set(h2(1),'Color',setColor{10},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
    % Error bars
    %set(h3,'marker','x');
    %set(h3,'linestyle','none');
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    %# Annotations
    % Text on plot
    %text(13.5,-0.06,'Legend:','FontSize',12,'color','k','FontWeight','bold');
    %text(13.5,-0.11,'RES = Resistance test','FontSize',12,'color','k','FontWeight','normal');
    %text(13.5,-0.16,'SPT = Self-propulsion test','FontSize',12,'color','k','FontWeight','normal');
    
    %# Axis limitations
    minX  = 13;
    maxX  = 25;
    incrX = 1;
    minY  = 0;
    maxY  = 0.7;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    set(gca,'YLim',[minY maxY]);
    set(gca,'YTick',minY:incrY:maxY);
    % set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend(legendInfoPlot13_2);
    set(hleg1,'Location','NorthWest');
    %set(hleg1,'Interpreter','none');
    set(hleg1, 'Interpreter','tex');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    %legend boxoff;
    
    %# Font sizes and border --------------------------------------------------
    
    set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
    
    %# ************************************************************************
    %# Save plot as PNG
    %# ************************************************************************
    
    %# Figure size on screen (50% scaled, but same aspect ratio)
    set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)
    
    %# Figure size printed on paper
    %if enableA4PaperSizePlot == 1
    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize',[XPlot YPlot]);
    set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
    set(gcf, 'PaperOrientation','portrait');
    %end
    
    %# Plot title -------------------------------------------------------------
    %     if enablePlotMainTitle == 1
    %         annotation('textbox', [0 0.9 1 0.1], ...
    %             'String', strcat('{\bf ', figurename, '}'), ...
    %             'EdgeColor', 'none', ...
    %             'HorizontalAlignment', 'center');
    %     end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/SPP_Plot_13_1_Heave_And_Running_Trim_Comparison_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
        print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
end % exist(SetAvgResistanceFilePath, 'file')


%# ************************************************************************
%# 14. Power comparison (NEW!!! 2 x Y-Axes Template)
%# ************************************************************************

figurename = 'Plot 14: Power comparison';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

%if enableA4PaperSizePlot == 1
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [19 19]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 19 19]);
%end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 16;
setBorderLineWidth = 2;
setLegendFontSize  = 14;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'<';'d';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,1)

%# X and Y axis -----------------------------------------------------------

% PORT: Pump effective power (PPE)
x1 = modelScaleDataArray(:,3);
y1 = modelScaleDataArray(:,40);

% STBD: Pump effective power (PPE)
x2 = modelScaleDataArray(:,3);
y2 = modelScaleDataArray(:,41);

% PORT: Jet system effective power (PJSE)
x3 = modelScaleDataArray(:,3);
y3 = modelScaleDataArray(:,58);

% STBD: Jet system effective power (PJSE)
x4 = modelScaleDataArray(:,3);
y4 = modelScaleDataArray(:,59);

% PORT: Delivered power (PD)
x5 = modelScaleDataArray(:,3);
y5 = modelScaleDataArray(:,42);

% STBD: Delivered power (PD)
x6 = modelScaleDataArray(:,3);
y6 = modelScaleDataArray(:,43);

% PORT: Thrust effective power (PTE)
x7 = modelScaleDataArray(:,3);
y7 = modelScaleDataArray(:,60);

% STBD: Thrust effective power (PTE)
x8 = modelScaleDataArray(:,3);
y8 = modelScaleDataArray(:,61);

% Overall propulsive efficiency
xOPE = modelScaleDataArray(:,3);
yOPE = modelScaleDataArray(:,46);

% Create a plot with 2 y axes using the plotyy function
[ax, h1, h2] = plotyy([x1 x2 x3 x4 x5 x6 x7 x8], [y1 y2 y3 y4 y5 y6 y7 y8], xOPE, yOPE, 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Ship speed (knots)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
title('Model scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Power (W)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Overall propulsive efficiency (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(7),'Color',setColor{7},'Marker',setMarker{7},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(8),'Color',setColor{8},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h2(1),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 140;
incrY = 20;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
% set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
% set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 0.84;
incrY = 0.12;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
% set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.2f'));

%# Legend
%hleg1 = legend('Port: Pump eff. power (P_{PE})','Stbd: Pump eff. power (P_{PE})','Port: Jet system eff. power (P_{JSE})','Stbd: Jet system eff. power (P_{JSE})','Port: Delivered power (P_{D})','Stbd: Delivered power (P_{D})','Port: Thrust eff. power (P_{TE})','Stbd: Thrust eff. power (P_{TE})','\eta_{D}');
hleg1 = legend('P_{PE} (Port)','P_{PE} (Stbd)','P_{JSE} (Port)','P_{JSE} (Stbd)','P_{D} (Port)','P_{D} (Stbd)','P_{TE} (Port)','P_{TE} (Stbd)','\eta_{D}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# SUBPLOT ////////////////////////////////////////////////////////////////
subplot(1,2,2)

%# X and Y axis -----------------------------------------------------------

% PORT: Pump effective power (PPE)
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,40);
Raw_Data = num2cell(y1); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Pump effective power (PPE)
x2 = fullScaleDataArray(:,3);
y2 = fullScaleDataArray(:,41);
Raw_Data = num2cell(y2); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

% PORT: Jet system effective power (PJSE)
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,58);
Raw_Data = num2cell(y3); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

% STBD: Jet system effective power (PJSE)
x4 = fullScaleDataArray(:,3);
y4 = fullScaleDataArray(:,59);
Raw_Data = num2cell(y4); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y4 = cell2mat(Raw_Data);

% PORT: Delivered power (PD)
x5 = fullScaleDataArray(:,3);
y5 = fullScaleDataArray(:,42);
Raw_Data = num2cell(y5); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y5 = cell2mat(Raw_Data);

% STBD: Delivered power (PD)
x6 = fullScaleDataArray(:,3);
y6 = fullScaleDataArray(:,43);
Raw_Data = num2cell(y6); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y6 = cell2mat(Raw_Data);

% PORT: Thrust effective power (PTE)
x7 = fullScaleDataArray(:,3);
y7 = fullScaleDataArray(:,60);
Raw_Data = num2cell(y7); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y7 = cell2mat(Raw_Data);

% STBD: Thrust effective power (PTE)
x8 = fullScaleDataArray(:,3);
y8 = fullScaleDataArray(:,61);
Raw_Data = num2cell(y8); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y8 = cell2mat(Raw_Data);

% Overall propulsive efficiency
xOPE = fullScaleDataArray(:,3);
yOPE = fullScaleDataArray(:,46);

% Create a plot with 2 y axes using the plotyy function
[ax, h1, h2] = plotyy([x1 x2 x3 x4 x5 x6 x7 x8], [y1 y2 y3 y4 y5 y6 y7 y8], xOPE, yOPE, 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Ship speed (knots)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Power (MW)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Overall propulsive efficiency (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Line, colors and markers
set(h1(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{2},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(3),'Color',setColor{3},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(4),'Color',setColor{4},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(5),'Color',setColor{5},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(6),'Color',setColor{6},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(7),'Color',setColor{7},'Marker',setMarker{7},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(8),'Color',setColor{8},'Marker',setMarker{8},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h2(1),'Color',setColor{10},'Marker','none','LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 3.5;
incrY = 0.5;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
% set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 0.84;
incrY = 0.12;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
% set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.2f'));

%# Legend
%hleg1 = legend('Port: Pump eff. power (P_{PE})','Stbd: Pump eff. power (P_{PE})','Port: Jet system eff. power (P_{JSE})','Stbd: Jet system eff. power (P_{JSE})','Port: Delivered power (P_{D})','Stbd: Delivered power (P_{D})','Port: Thrust eff. power (P_{TE})','Stbd: Thrust eff. power (P_{TE})','\eta_{D}');
hleg1 = legend('P_{PE} (Port)','P_{PE} (Stbd)','P_{JSE} (Port)','P_{JSE} (Stbd)','P_{D} (Port)','P_{D} (Stbd)','P_{TE} (Port)','P_{TE} (Stbd)','\eta_{D}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
%if enableA4PaperSizePlot == 1
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize',[XPlot YPlot]);
set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
set(gcf, 'PaperOrientation','portrait');
%end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_14_Power_Comparison_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 14.1 Port Full Scale Power Comparison (NEW!!! 2 x Y-Axes Template)
%# ************************************************************************

figurename = 'Plot 14.1: Port Full Scale Power Comparison';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'<';'d';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% PORT: Pump effective power (PPE)
x1 = fullScaleDataArray(:,3);
y1 = fullScaleDataArray(:,40);
Raw_Data = num2cell(y1); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Pump effective power (PPE)
%x2 = fullScaleDataArray(:,3);
%y2 = fullScaleDataArray(:,41);
%Raw_Data = num2cell(y2); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
%y2 = cell2mat(Raw_Data);

% PORT: Jet system effective power (PJSE)
x3 = fullScaleDataArray(:,3);
y3 = fullScaleDataArray(:,58);
Raw_Data = num2cell(y3); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

% STBD: Jet system effective power (PJSE)
%x4 = fullScaleDataArray(:,3);
%y4 = fullScaleDataArray(:,59);
%Raw_Data = num2cell(y4); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
%y4 = cell2mat(Raw_Data);

% PORT: Delivered power (PD)
x5 = fullScaleDataArray(:,3);
y5 = fullScaleDataArray(:,42);
Raw_Data = num2cell(y5); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y5 = cell2mat(Raw_Data);

% STBD: Delivered power (PD)
%x6 = fullScaleDataArray(:,3);
%y6 = fullScaleDataArray(:,43);
%Raw_Data = num2cell(y6); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
%y6 = cell2mat(Raw_Data);

% PORT: Thrust effective power (PTE)
x7 = fullScaleDataArray(:,3);
y7 = fullScaleDataArray(:,60);
Raw_Data = num2cell(y7); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y7 = cell2mat(Raw_Data);

% STBD: Thrust effective power (PTE)
%x8 = fullScaleDataArray(:,3);
%y8 = fullScaleDataArray(:,61);
%Raw_Data = num2cell(y8); Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
%y8 = cell2mat(Raw_Data);

%# Overall propulsive efficiency where nD = PE/PD where PE=RBH V and where PD = PPE/nPumpnInst
xOPE1 = fullScaleDataArray(:,3);
yOPE1 = fullScaleDataArray(:,46);

%# Overall propulsive efficiency where nD = PE/PD where PE=T V and where PD = PPE/nPumpnInst
xOPE2 = fullScaleDataArray(:,3);
yOPE2 = fullScaleDataArray(:,84);

% Create a plot with 2 y axes using the plotyy function
[ax, h1, h2] = plotyy([x1 x3 x5 x7], [y1 y3 y5 y7], [xOPE1 xOPE2], [yOPE1 yOPE2], 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Ship speed (knots)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Power (MW)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Overall propulsive efficiency (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.08 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.08 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(3),'Color',setColor{3},'Marker',setMarker{6},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h1(4),'Color',setColor{4},'Marker',setMarker{7},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
% Right Y-axis
set(h2(1),'Color',setColor{5},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h2(2),'Color',setColor{6},'Marker',setMarker{3},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 4;
incrY = 0.4;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
% set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 1;
incrY = 0.1;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
% set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
hleg1 = legend('Effective pump power (P_{PE})','Effective jet system power (P_{JSE})','Delivered power (P_{D})','Effective thrust power (P_{TE})','\eta_{D}=P_{E}/P_{D} where P_{E}=R_{BH}V and P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})','\eta_{D}=P_{E}/P_{D} where P_{E}=T_{F=0}V and P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_14_1_Full_Scale_Port_Power_Comparison_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 15. Thrust at SPP using graphical method and TF=0-FD
%# ************************************************************************

figurename = 'Plot 15: Thrust at SPP using graphical method and TF=0-FD';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% Tow force vs. thrust plot
x1 = modelScaleDataArray(:,3);
y1 = resSPP_CCDoTT(:,11);

% T_{SPP}=T_{F=0}-F_{D}
x2 = modelScaleDataArray(:,3);
y2 = resSPP_CCDoTT(:,27);

%# Plotting ---------------------------------------------------------------
h = plot(x1,y1,'*-',x2,y2,'*-');
xlabel('{\bf Ship speed (knots)}','FontSize',setGeneralFontSize);
ylabel('{\bf Thrust at full scale self-propulsion point (N)}','FontSize',setGeneralFontSize);
% if enablePlotTitle == 1
%     title('{\bf Thrust at self-propulsion point)}','FontSize',setGeneralFontSize);
% end
grid on;
box on;
axis square;

%# Line, colors and markers
set(h(1),'Color',setColor{2},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidthThin);
set(h(2),'Color',setColor{2},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 13;
maxX  = 25;
incrX = 1;
minY  = 0;
maxY  = 25;
incrY = 5;
set(gca,'XLim',[minX maxX]);
set(gca,'XTick',minX:incrX:maxX);
set(gca,'YLim',[minY maxY]);
set(gca,'YTick',minY:incrY:maxY);
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));

%# Legend
hleg1 = legend('Graphical method','T_{SPP}=T_{F=0}-F_{D}');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(gca,'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_15_Thrust_at_SPP_vs_Ship_Speed_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 16. Full scale ship speed vs. residual resistance coefficient and delivered power
%# ************************************************************************
figurename = 'Plot 16: Full scale ship speed vs. residual resistance coefficient and delivered power';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% PORT: Jet velocity
x1 = fullScaleDataArray(:,1);
y1 = fullScaleDataArray(:,42);

%# Divide power data by 1000^2 for mega Watt (MW)
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Jet velocity
x2 = fullScaleDataArray(:,1);
y2 = fullScaleDataArray(:,43);

%# Divide power data by 1000^2 for mega Watt (MW)
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

% Residual resistance coefficient, CRs (temperature corrected but not corrected for shallow water!)
x3 = ResResultsUC(:,1);
y3 = ResResultsUC(:,22);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y3);
Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy([x1 x2], [y1 y2], x3, y3, 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Froude length number, F_{r} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Delivered power, P_{D} (MW)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Residual resistance coefficient, C_{Rs}*10^{3} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
set(h1(2),'Color',setColor{2},'Marker',setMarker{5},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
% Right Y-axis
set(h2(1),'Color',setColor{5},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 4;
incrY = 0.5;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0.8;
maxY  = 4;
incrY = 0.4;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
hleg1 = legend('Port: Delivered power (P_{D})','Stbd:  Delivered power (P_{D})','Residual resistance coefficient (C_{Rs})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_16_Full_Scale_Ship_Speed_CRs_and_Delivered_Power_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;

%# ************************************************************************
%# 16.1 Averaged full scale ship speed vs. residual resistance coefficient and delivered power
%# ************************************************************************
figurename = 'Plot 16.1: Averaged full scale ship speed vs. residual resistance coefficient and delivered power';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

% PORT: Delivered power
x1 = fullScaleDataArray(:,1);
y1 = fullScaleDataArray(:,42);

%# Divide power data by 1000^2 for mega Watt (MW)
Raw_Data = num2cell(y1);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y1 = cell2mat(Raw_Data);

% STBD: Delivered power
x2 = fullScaleDataArray(:,1);
y2 = fullScaleDataArray(:,43);

%# Divide power data by 1000^2 for mega Watt (MW)
Raw_Data = num2cell(y2);
Raw_Data = cellfun(@(y) y/1000^2, Raw_Data, 'UniformOutput', false);
y2 = cell2mat(Raw_Data);

% Averaged mass flow rate
AvgTempArray = [];
for ky=1:m1221
    AvgTempArray(ky,1) = fullScaleDataArray(ky,1);
    AvgTempArray(ky,2) = (y1(ky)+y2(ky))/2;
end

x4 = AvgTempArray(:,1);
y4 = AvgTempArray(:,2);

% Residual resistance coefficient, CRs (temperature corrected but not corrected for shallow water!)
x3 = ResResultsUC(:,1);
y3 = ResResultsUC(:,22);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y3);
Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy(x4, y4, x3, y3, 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Froude length number, F_{r} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Delivered power, P_{D} (MW)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Residual resistance coefficient, C_{Rs}*10^{3} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker',setMarker{4},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidthThin);
% Right Y-axis
set(h2(1),'Color',setColor{5},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth);

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0;
maxY  = 3.5;
incrY = 0.5;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0.8;
maxY  = 3.6;
incrY = 0.4;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
hleg1 = legend('Delivered power (P_{D})','Residual resistance coefficient (C_{Rs})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_16_1_Averaged_Full_Scale_Ship_Speed_CRs_and_Delivered_Power_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# 17. Full scale Froude length number vs. OPE and CRs
%# ************************************************************************
figurename = 'Plot 17: Full scale Froude length number vs. OPE and CRs';
f = figure('Name',figurename,'NumberTitle','off');

%# Paper size settings ----------------------------------------------------

% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
%
%     set(gcf, 'PaperUnits', 'centimeters');
%     set(gcf, 'PaperSize', [19 19]);
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperPosition', [0 0 19 19]);
% end

% Fonts and colours -------------------------------------------------------
setGeneralFontName = 'Helvetica';
setGeneralFontSize = 14;
setBorderLineWidth = 2;
setLegendFontSize  = 12;

%# Change default text fonts for plot title
set(0,'DefaultTextFontname',setGeneralFontName);
set(0,'DefaultTextFontSize',14);

%# Box thickness, axes font size, etc. ------------------------------------
set(gca,'TickDir','in',...
    'FontSize',12,...
    'LineWidth',2,...
    'FontName',setGeneralFontName,...
    'Clipping','off',...
    'Color',[1 1 1],...
    'LooseInset',get(gca,'TightInset'));

%# Markes and colors ------------------------------------------------------
setMarker = {'*';'+';'x';'o';'s';'d';'*';'^';'<';'>';'p'};
% Colored curves
setColor  = {'r';'g';'b';'c';'m';[0 0.75 0.75];[0.75 0 0.75];[0 0.8125 1];[0 0.1250 1];'k';'k'};
if enableBlackAndWhitePlot == 1
    % Black and white curves
    setColor  = {'k';'k';'k';'k';'k';'k';'k';'k';'k';'k';'k'};
end

%# Line, colors and markers
setMarkerSize      = 14;
setLineWidthMarker = 1;
setLineWidth       = 2;
setLineWidthThin   = 1;
setLineStyle       = '-';
setLineStyle1      = '--';
setLineStyle2      = '-.';
setLineStyle3      = ':';

%# SUBPLOT ////////////////////////////////////////////////////////////////
%subplot(1,1,1)

%# X and Y axis -----------------------------------------------------------

%# Overall propulsive efficiency where nD = PE/PD where PE=RBH V and where PD = PPE/nPumpnInst
x1 = fullScaleDataArray(:,1);
y1 = fullScaleDataArray(:,46);

% See Ghadimi (2013), Eqn. 3. PE = TF=0 V then nD = PE/PD and where PD = PPE/nPumpnInst
x2 = fullScaleDataArray(:,1);
y2 = fullScaleDataArray(:,84);

% Residual resistance coefficient, CRs (temperature corrected but not corrected for shallow water!)
x3 = ResResultsUC(:,1);
y3 = ResResultsUC(:,22);

%# Divide resistance data by 1000 for better readibility
Raw_Data = num2cell(y3);
Raw_Data = cellfun(@(y) y*1000, Raw_Data, 'UniformOutput', false);
y3 = cell2mat(Raw_Data);

%# Plotting ---------------------------------------------------------------
[ax, h1, h2] = plotyy([x1 x2], [y1 y2], x3, y3, 'plot');
% Left color red, right color blue...
set(ax,{'ycolor'},{'k';'k'});
% Add title and x axis label
xlabel('Froude length number, F_{r} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
% if enablePlotTitle == 1
%title('Full scale','FontSize',setGeneralFontSize,'FontWeight','bold');
% end
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'Ylabel'), 'String', 'Overall propulsive efficiency, \eta_{D} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
set(get(ax(2), 'Ylabel'), 'String', 'Residual resistance coefficient, C_{Rs}*10^{3} (-)','FontSize',setGeneralFontSize,'FontWeight','bold');
grid on;
box on;
axis(ax,'square');

%# Axis positions
set(ax(1),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]
set(ax(2),'Position', [0 0.085 0.97 0.9]); % [Left, bottom, right, top]

%# Line, colors and markers
% Left Y-axis
set(h1(1),'Color',setColor{1},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle1,'linewidth',setLineWidth); %setMarker{4}
set(h1(2),'Color',setColor{1},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle2,'linewidth',setLineWidth); %setMarker{4}
% Right Y-axis
set(h2(1),'Color',setColor{5},'Marker','none','MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker,'LineStyle',setLineStyle,'linewidth',setLineWidth); %setMarker{5}

%# Set plot figure background to a defined color
%# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
set(gcf,'Color',[1,1,1]);

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 0.2;
maxY  = 0.8;
incrY = 0.1;
set(ax(1),'XLim',[minX maxX]);
set(ax(1),'XTick',minX:incrX:maxX);
set(ax(1),'YLim',[minY maxY]);
set(ax(1),'YTick',minY:incrY:maxY);
set(ax(1),'xticklabel',num2str(get(ax(1),'xtick')','%.2f'));
set(ax(1),'yticklabel',num2str(get(ax(1),'ytick')','%.1f'));

%# Axis limitations
minX  = 0.22;
maxX  = 0.42;
incrX = 0.02;
minY  = 2.1;
maxY  = 3.3;
incrY = 0.2;
set(ax(2),'XLim',[minX maxX]);
set(ax(2),'XTick',minX:incrX:maxX);
set(ax(2),'YLim',[minY maxY]);
set(ax(2),'YTick',minY:incrY:maxY);
set(ax(2),'xticklabel',num2str(get(ax(2),'xtick')','%.2f'));
set(ax(2),'yticklabel',num2str(get(ax(2),'ytick')','%.1f'));

%# Legend
hleg1 = legend('\eta_{D}=P_{E}/P_{D} where P_{E}=R_{BH}V, P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})','\eta_{D}=P_{E}/P_{D} where P_{E}=T_{F=0}V, P_{D}=P_{PE}/(\eta_{Pump}\eta_{Inst})','Residual resistance coefficient (C_{Rs})');
set(hleg1,'Location','NorthWest');
%set(hleg1,'Interpreter','none');
set(hleg1, 'Interpreter','tex');
set(hleg1,'LineWidth',1);
set(hleg1,'FontSize',setLegendFontSize);
%legend boxoff;

%# Font sizes and border --------------------------------------------------

set(ax(1),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);
set(ax(2),'FontSize',setGeneralFontSize,'FontWeight','normal','linewidth',setBorderLineWidth);

%# ************************************************************************
%# Save plot as PNG
%# ************************************************************************

%# Figure size on screen (50% scaled, but same aspect ratio)
set(gcf, 'Units','centimeters', 'Position',[5 5 XPlotSize YPlotSize]/2)

%# Figure size printed on paper
% if enableA4PaperSizePlot == 1
%     set(gcf, 'PaperUnits','centimeters');
%     set(gcf, 'PaperSize',[XPlot YPlot]);
%     set(gcf, 'PaperPosition',[XPlotMargin YPlotMargin XPlotSize YPlotSize]);
%     set(gcf, 'PaperOrientation','portrait');
% end

%# Plot title -------------------------------------------------------------
% if enablePlotMainTitle == 1
%     annotation('textbox', [0 0.9 1 0.1], ...
%         'String', strcat('{\bf ', figurename, '}'), ...
%         'EdgeColor', 'none', ...
%         'HorizontalAlignment', 'center');
% end

%# Save plots as PDF, PNG and EPS -----------------------------------------
% Enable renderer for vector graphics output
set(gcf, 'renderer', 'painters');
setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
setFileFormat = {'PDF' 'PNG' 'EPS'};
for k=1:3
    plotsavename = sprintf('_plots/%s/%s/SPP_Plot_17_Full_Scale_Ship_Speed_OPE_and_CRs_Plot.%s', 'SPP_CCDoTT', setFileFormat{k}, setFileFormat{k});
    print(gcf, setSaveFormat{k}, plotsavename);
end
%close;


%# ************************************************************************
%# START Close all plots
%# ------------------------------------------------------------------------

if enableCloseAllPlots == 1
    allPlots = findall(0, 'Type', 'figure', 'FileName', []);
    delete(allPlots);   % Close all plots
end

%# ------------------------------------------------------------------------
%# END Close all plots
%# ************************************************************************


%# ************************************************************************
%# START Write results to DAT or TXT file
%# ------------------------------------------------------------------------

%# Add when creating fullScaleDataArraySets.dat only!!!!
% if exist('fullScaleDataArray_CCDoTT.dat', 'file') == 2 && mfsr == 27
%     exist('fullScaleDataArray_CCDoTT.dat');
%     disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
%     disp('NOTE: fullScaleDataArray_CCDoTT.dat contained three (3) datasets and has been deleted!');
%     disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
% end
%
% % Add new sets when more than one set in file
% if exist('fullScaleDataArray_CCDoTT.dat', 'file') == 2 && mfsr >= 9 && fullscaleresults(1,70) ~= CorrCoeff
%    fullScaleDataArray = [fullscaleresults;fullScaleDataArray];
% end

fullScaleDataArray = fullScaleDataArray(any(fullScaleDataArray,2),:);               % Remove zero rows
M = fullScaleDataArray;
%M = M(any(M,2),:);                                                                 % remove zero rows only in resultsArraySPP text file
csvwrite('fullScaleDataArray_CCDoTT.dat', M)                                        % Export matrix M to a file delimited by the comma character
dlmwrite('fullScaleDataArray_CCDoTT.txt', M, 'delimiter', '\t', 'precision', 4)     % Export matrix M to a file delimited by the tab character and using a precision of four significant digits

%# ------------------------------------------------------------------------
%# END Write results to DAT or TXT file
%# ************************************************************************


% -------------------------------------------------------------------------
% View profile
% -------------------------------------------------------------------------
if enableProfiler == 1
    profile viewer
end
