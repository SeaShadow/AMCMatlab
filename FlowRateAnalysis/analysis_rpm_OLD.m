%# ------------------------------------------------------------------------
%# FUNCTION: Analysis_RPM
%# ------------------------------------------------------------------------
%# CHANGES:   19/06/2013 - Created file
%#            dd/mm/yyyy - ...
%# ------------------------------------------------------------------------

%# INPUT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%# k                = Run number
%# name             = Run file name (e.g. R12-02_moving)
%# timeData         = Time series data
%# Raw_CH_5_RPMStbd = STBD RPM data
%# Raw_CH_6_RPMPort = PORT RPM data
%# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%# OUTPUT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
%# RPMStbd = STRBOARD RPM value
%# RPMPort = PORT RPM value
%# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function [RPMStbd RPMPort] = analysis_rpm(k,name,timeData,Raw_CH_5_RPMStbd,Raw_CH_6_RPMPort)

RPMStbd = 0;
RPMPort = 0;
for krpm=1:2
    
    increments  = 0:5:30;   % 0:x:5 defines x inrements
    xaxislentgh = [0 30];   % [FROM TO]

    %# Define short variables
    x = timeData;
    if krpm == 1
        y        = Raw_CH_5_RPMStbd;
        propside = 1;   % STBD
    else    
        y        = Raw_CH_6_RPMPort;
        propside = 2;   % PORT        
    end

    %# Gauss filter
    %# URL: http://stackoverflow.com/questions/12987905/how-to-make-a-curve-smoothing-in-matlab
    t = x;
    g = gausswin(40); % <-- this value determines the width of the smoothing window
    g = g/sum(g);
    y1 = conv(y, g, 'same');

    %# Plot original data versus smoothed data
    figurename = sprintf('Gauss filter: %s', name);
    f = figure('Name',figurename,'NumberTitle','off');
    plot(t,y);grid on;box on;xlabel('Time [s]');ylabel('Output [Volt]');
    set(gca, 'XTick', increments, 'XLim', xaxislentgh);

    %# Get extremas
    %# URL: http://www.mathworks.com/matlabcentral/fileexchange/12275
    [ymax,imax,ymin,imin] = extrema(y1);

    %# Plotting
    hold on;
    plot(t,y1, 'k.');
    plot(t(imax),ymax,'r*',t(imin),ymin,'g*');grid on;box on;xlabel('Time [s]');ylabel('Output [Volt]');
    set(gca, 'XTick', increments, 'XLim', xaxislentgh);

    %# Save plots as PNG
    fPath = sprintf('_plots/%s', name);
    if isequal(exist(fPath, 'dir'),7)
        % Do nothing as directory exists
    else    
        mkdir(fPath);
    end    
    if krpm == 1
        plotsavename = sprintf('_plots/%s/PEAKS_CH5_rpm_outpur_stbd.png', name);
    else    
        plotsavename = sprintf('_plots/%s/PEAKS_CH6_rpm_outpur_port.png', name);     
    end    
    saveas(f, plotsavename);    % Save plot as image
    close;                      % Close current plot window

    %# MIN (when screw (steel) directly beneath sensor)
    sortTimeMin = sort(t(imin));
    diffTimeMin = diff(sortTimeMin);
    avgTimeMin  = reshape(mean(reshape(diffTimeMin,length(diffTimeMin),[])),[],1);

    RPSMin = 1 / avgTimeMin;
    RPMMin = round(60 / avgTimeMin);

    %# MAX (when screw (steel) is completely outside sensor range)
    sortTimeMax = sort(t(imax));
    diffTimeMax = diff(sortTimeMax);
    avgTimeMax  = reshape(mean(reshape(diffTimeMax,length(diffTimeMax),[])),[],1);

    RPSMax = 1 / avgTimeMax;
    RPMMax = round(60 / avgTimeMax);  

    if krpm == 1
        RPMStbd = RPMMax;
    else    
        RPMPort = RPMMax;     
    end
    
    %# Custom variables
    samplefrq = round(length(timeData) / timeData(end));% Calculated sampling frequency
    
end