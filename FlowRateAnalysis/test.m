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