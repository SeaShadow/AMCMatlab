%# ************************************************************************
%# General testing bits, things & stuff :)
%# ************************************************************************

%# ------------------------------------------------------------------------
%# Graphs I am interested in
%# ------------------------------------------------------------------------

subplot(1,3,1);
h = plot(0,0); %
xlabel('{\bf Thrust [N]}');
ylabel('{\bf Towing force [N]}');
grid on;
box on;
axis square;

%# Line width
% set(h(1),'linewidth',1);
% set(h(2),'linewidth',2);

%# Axis limitations
xlim([1 30]);
ylim([1 30]);
set(gca, 'XTick',[0:5:30]);   % X-axis increments: start:increment:end
set(gca, 'YTick',[0:5:30]);   % Y-axis increments: start:increment:end

subplot(1,3,2);
h = plot(0,0); %
xlabel('{\bf Towing force [N]}');
ylabel('{\bf Thrust deduction [-]}');
grid on;
box on;
axis square;

%# Line width
% set(h(1),'linewidth',1);
% set(h(2),'linewidth',2);

%# Axis limitations
xlim([1 30]);
ylim([1 30]);
set(gca, 'XTick',[0:5:30]);   % X-axis increments: start:increment:end
set(gca, 'YTick',[0:5:30]);   % Y-axis increments: start:increment:end

subplot(1,3,3);
h = plot(0,0); %
xlabel('{\bf Overall proulsive efficiency [-]}');
ylabel('{\bf Froude length number [-]}');
grid on;
box on;
axis square;

%# Line width
% set(h(1),'linewidth',1);
% set(h(2),'linewidth',2);

%# Axis limitations
xlim([1 30]);
ylim([1 30]);
set(gca, 'XTick',[0:5:30]);   % X-axis increments: start:increment:end
set(gca, 'YTick',[0:5:30]);   % Y-axis increments: start:increment:end

break;

%# ------------------------------------------------------------------------
%# Older stuff
%# ------------------------------------------------------------------------

xxx = {1, 2, 3, 4, 5};
yyy = {1; 2; 3; 4; 5};

abbrev1  = cellfun(@(x) x+1, xxx, 'UniformOutput', false);   % Horizontal (x)
abbrev2  = cellfun(@(y) y+1, yyy, 'UniformOutput', false);   % Vertical (y)

Raw_Data = num2cell(Raw_CH_0_WaveProbe);                            % Double to cell conversion
Raw_Data  = cellfun(@(y) y+30, Raw_Data, 'UniformOutput', false);   % Apply functions to cell
S = sprintf('%s*', Raw_Data{:});                                    % Cell to double conversion
Raw_Data = sscanf(S, '%f*');                                        % Cell to double conversion

startRun = 1;      % Start at run x
endRun   = 3;

w = waitbar(0,'Processed run files'); 
for k=startRun:endRun
    k
    wtot = endRun - startRun;
    w = waitbar(k/wtot,w,['iteration: ',num2str(k)]);
end

%# Close progress bar
close(w);