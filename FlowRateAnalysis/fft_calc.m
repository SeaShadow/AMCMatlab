%%FFT 
%Input                                  |%Output
%fs =   Sample frequency of data        |%y  =   OneSided fft
%X  =   Data set                        |%f  =   Frequency range               

function [f y] = fft_calc(X,fs)
    l       = length(X);                % Length and breadth of the data signal
    NFFT    = 2^nextpow2(l);            % Next power of 2 from length of y
    Y       = fft(X,NFFT)/l;            % Compute FFT
    f       = [0 : NFFT/2]'/NFFT*fs;
    y       = 2*abs(Y(1:NFFT/2+1));
    clear -regexp ^r\d{1}$;
    clear time;
end