%# ------------------------------------------------------------------------
%# function [resistance] = calBHResistanceBasedOnFrTempCorr( input )
%# ------------------------------------------------------------------------
%#
%# Author     :  K. Zürcher (Konrad.Zurcher@utas.edu.au)
%# Date       :  March 13, 2015
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


% *************************************************************************
% START: PLOT SWITCHES: 1 = ENABLED
%                       0 = DISABLED
% -------------------------------------------------------------------------

% Plot titles, colours, etc.
enablePlotMainTitle         = 0;    % Show plot title in saved file
enablePlotTitle             = 0;    % Show plot title above plot
enableBlackAndWhitePlot     = 1;    % Show plot in black and white only
enableTowingForceFDPlot     = 1;    % Show towing force (FD)

% Scaled to A4 paper
enableA4PaperSizePlot       = 0;    % Show plots scale to A4 size

% Polynomial fitting plot
enableFittingPlot           = 0;    % Show polynomial fitting plot

% -------------------------------------------------------------------------
% END: PLOT SWITCHES
% *************************************************************************


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
if enableFittingPlot == 1
    
    %# Plotting speed ---------------------------------------------------------
    figurename = 'Plot 1: Polynomial Fitting of Resistance Data';
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
    setMarkerSize      = 12;
    setLineWidthMarker = 2;
    setLineWidth       = 2;
    setLineStyle       = '-';
    
    %# SUBPLOT ////////////////////////////////////////////////////////////
    subplot(1,1,1)
    
    %# Plotting -----------------------------------------------------------
    h = plot(fitobject,'k-',xres,yres,'*');
    xlabel('{\bf Froude length number, F_{r} (-)}','FontSize',setGeneralFontSize);
    ylabel('{\bf Total resistance, R_{T} (N)}','FontSize',setGeneralFontSize);
    grid on;
    box on;
    axis square;
    
    %# Line, colors and markers
    set(h(1),'Color',setColor{1},'Marker',setMarker{1},'MarkerSize',setMarkerSize,'LineWidth',setLineWidthMarker);
    
    %# Set plot figure background to a defined color
    %# See: http://www.mathworks.com.au/help/matlab/ref/colorspec.html
    set(gcf,'Color',[1,1,1]);
    
    % %# Axis limitations
    minX  = 0.1;
    maxX  = 0.5;
    incrX = 0.05;
    minY  = 0;
    maxY  = 1;
    incrY = 0.1;
    set(gca,'XLim',[minX maxX]);
    set(gca,'XTick',minX:incrX:maxX);
    %set(gca,'YLim',[minY maxY]);
    %set(gca,'YTick',minY:incrY:maxY);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%.2f'));
    %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'));
    
    %# Legend
    hleg1 = legend('Resistance data','Fit');
    set(hleg1,'Location','NorthWest');
    set(hleg1,'Interpreter','none');
    set(hleg1,'LineWidth',1);
    set(hleg1,'FontSize',setLegendFontSize);
    legend boxoff;
    
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
    %if enablePlotMainTitle == 1
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', strcat('{\bf ', figurename, '}'), ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    %end
    
    %# Save plots as PDF, PNG and EPS -----------------------------------------
    % Enable renderer for vector graphics output
    set(gcf, 'renderer', 'painters');
    setSaveFormat = {'-dpdf' '-dpng' '-depsc2'};
    setFileFormat = {'PDF' 'PNG' 'EPS'};
    for k=1:3
        plotsavename = sprintf('_plots/%s/%s/MS_Temp_Corrected_Resistance_Polynomial_Fitting_Plot.%s', 'SPP', setFileFormat{k}, setFileFormat{k});
        %print(gcf, setSaveFormat{k}, plotsavename);
    end
    %close;
    
    %# Command line output ------------------------------------------------
    disp(sprintf('Eqn. of fit, y = %s*x^5+%s*x^4+%s*x^3+%s*x^2+%s*x+%s, R^2=%s',sprintf('%.3f',cvalues(1)),sprintf('%.3f',cvalues(2)),sprintf('%.3f',cvalues(3)),sprintf('%.3f',cvalues(4)),sprintf('%.3f',cvalues(5)),sprintf('%.3f',cvalues(6)),sprintf('%.2f',gof.rsquare)))
end

%# Define variables (ITTC 7.5-02-01-03 (2008)) ----------------------------

% Full scale to model scale ratio (-)
FStoMSratio = 21.6;

% Gravitational constant (m/s^2)
gravconst = 9.806;

%# TODO: Kinematic viscosity could be established by look up table and
%# dynamically read. Input would have to be extended by ResTemp and SPTTemp.

% Resistance test, water temperature 17.5 deg .C

RESKinVisc = 0.0000010675;
RESDensity = 998.6897;

% Self-propulsion test, water temperature 18.5 deg .C

SPTKinVisc = 0.0000010411;
SPTDensity = 998.5048;

% Form factor (by slow speed Prohaska runs)
FormFactor = 1.18;      % Form factor (1+k)

%# Array size -------------------------------------------------------------
[m,n] = size(Froude_Numbers);

%# Results array ----------------------------------------------------------
%# Loop through array with Froude length numbers
%# ------------------------------------------------------------------------
ResultsArray = [];
%# ResultsArray columns:
%[1]  Froude length number             (-)
%[2]  Resistance (uncorrected)         (N)
%[3]  Resistance (corrected for temp.) (N) -> See ITTC 7.5-02-03-01.4 (2008)
%[4]  Ship speed based on LWL and Fr   (knots)
for k=1:m
    
    % Calculations
    ModelSpeed    = Froude_Numbers(k,2);
    
    RESReynoldsNr = (ModelSpeed*LWL)/RESKinVisc;
    SPTReynoldsNr = (ModelSpeed*LWL)/SPTKinVisc;
    
    % Write array
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
    
    % Residual resistance coeff., CR=CT-(1+k)CF, from resistance test
    Crm = RESCtm-(FormFactor*RESCfm);
    ResultsArray(k,3) = (Form_Factor*SPTCfm+Crm)/(Form_Factor*RESCfm+Crm)*ResistanceByFit;
    
    % Ship speed (knots)
    ResultsArray(k,4) = (FN*sqrt(gravconst*(LWL*FStoMSratio)))/0.51444;
    
end

%# Function output --------------------------------------------------------

resistance = ResultsArray;
