%% Lecture 5 (random signal created by sines)
% =========================================================================
clear; clc;
N = 2000;                   % Number of samples
x = zeros(N,1);             % Memory allocation for vector x
Ts = 10;                    % Sampling period
Fs = 1/Ts;                  % Sampling frequency
t = 0:Ts:(N-1)*Ts;          % Time sequence
F = Fs*(0:N-1)/(N-1);       % Frequency grid
omega = 0.0:0.05:2;         % Sinus function frequencies
A = randn(length(omega),1); % Sinus function amplitudes


% p sinus waves of different amplitudes and frequencies added one by one to
% vector x
for p = 1:length(omega)     
    x = x + A(p)*sin(omega(p)*t/2/pi)';
    
    % Plot the time history and the corresponding FFT of x 
    if p<=5 || p == length(omega)
        figure(1)
        subplot(211),plot(t,x)
        xlabel('Time (s)')
        ylabel('x(t)')
        subplot(212),plot(F,abs(fft(x)))
        xlabel('Frequency (rad/s)')
        ylabel('|F(\omega)|')
        pause(1)
    end
end



%% Lecture 5 -- ifft
close all; clear; clc
m = 1;                          % system mass
omega = 5*pi;                   % natural freq.
zeta = 0.5;                     % damping ratio
omega_d = omega*sqrt(1-zeta^2); % natural freq. with damping
k =(omega^2)*m;                 % stiffness coefficient

dt = 0.005;                     % Sampling period 
t = 0:dt:20;                    % Time instants
F = cos(4.75*pi*t);             % Input force

% System impulse response -- time domain
impulse = exp(-omega*zeta*t).*sin(omega_d*t);
output = dt*(1/m/(omega_d))*conv(impulse,F);

% System impulse response -- frequency domain
output2 = dt*1/m/omega_d*ifft(fft(F).*fft(impulse));

% Figure -- comparison of output and output2
figure(1)
subplot(211),plot(t,F(1:length(t)))
grid
title('Forcing Function')
subplot(212),plot(t,output(1:length(t)));hold on
plot(t,output2(1:length(t)),'--r')
legend({'Response calculated in time Domain','Response calculated in frequency domain'})
grid
title('System Response')
xlabel('Time (s)')



%% Lecture 5 -- Gibbs phenomenon
% =========================================================================
clear; clc; close all;
N = 10000;

figure(1)
clr = colormap(lines(100));
hold on 
title('The building of a square wave: Gibbs'' effect')
xlabel('Time (s)')
ylabel('Signal')

t = linspace(0,4*pi,N);             % Time vector
x = zeros(size(t));                 % Memory allocation
for k = 1:2:250                     % for loop
    x = x + sin(k*t)/k;             % Adding Fourier series terms
    y((k+1)/2,:) = x;               % Storing the signal approximation
    % Iterative plot for the first 5 terms
    if k<20
        plot(t,x','Color',clr((k+1)/2,:))
        pause(1)
    end
end

% Comparison plot for the first 5, 25 and 125 terms
figure(2)
subplot(2,3,1),plot(y(5,:)','-b')
ylabel('Signal')
legend('5 steps')
subplot(2,3,2),plot(y(25,:)','-r')
legend('25 steps')
title('The building of a square wave: Gibbs'' effect')
xlabel('Time (s)')
subplot(2,3,3),plot(y(125,:)','-g')
legend('125 steps')


%% Lecture 5 -- Aliasing
close all
N = 20000;                      % Number of samples
t = 0:1e-3:1e-3*(N-1);          % Fine time grid (for the approximation of the continuous curve) 
x = sin(2*pi*t);                % 1 Hz sine        

% Plot the sinus wave 
figure(1)
plot(t,x)   
axis tight
xlabel('Time (s)')
ylabel('Sinusoidal signal')
title('Sampling problems')
hold on 

Tsample = 1:200:N;                          % Sampling time vector
Ts = t(201);                                % Sampling period
Fs = 1/Ts;                                  % Sampling frequency
disp(['Sampling time: Ts = ',num2str(Ts),' s,  ','Sampling frequency fs = ',num2str(Fs),' (Hz)'])
plot(t(Tsample),x(Tsample),'--or')          % Plot sample points 
xlim([0 5])
pause
plot(t,sin(12*pi*t),'-.g')                  % Plot sine wave of 6 Hz 
legend({'Original sine wave (1 Hz)','sample points','sine wave (6 Hz)'})
pause

% FFT of the sampled signal
N = length(Tsample);                        % Number of sampled points 
NFFT = 2^nextpow2(N);                       % Calculating the min power p with 2^p > N
Y = fft(x(Tsample),NFFT)/N;                 % FFT calculation
f = Fs/2*linspace(0,1,NFFT/2+1);            % Frequency points for the calculated FFT 

% Plot single-sided amplitude spectrum.
figure(2)
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on


%% Lecture 5 -- Aliasing
close all
N = 150000;                     % Number of samples
t = 0:1e-3:1e-3*(N-1);          % Fine time grid (for the approximation of the continuous curve) 
x = sin(2*pi*t);                % 1 Hz sine      

% Plot the sinus wave
figure(1)
plot(t,x)
axis tight
xlabel('Time (s)')
ylabel('Sinusoidal signal')
title('Sampling problems')
hold on 

Tsample = 1:801:N;                          % Sampling time vector
Ts = t(801);                                % Sampling period
Fs = 1/Ts;                                  % Sampling frequency
disp(['Sampling time: Ts = ',num2str(Ts),' s,  ','Sampling frequency fs = ',num2str(Fs),' (Hz)'])

plot(t(Tsample),x(Tsample),'--or')          % Plot sample points 
xlim([0 40])
pause

% FFT of the sampled signal
N = length(Tsample);                        % Number of sampled points 
NFFT = 2^nextpow2(N);                       % Calculating the min power p with 2^p > N
Y = fft(x(Tsample),NFFT)/N;                 % FFT calculation
f = Fs/2*linspace(0,1,NFFT/2+1);            % Frequency points for the calculated FFT 

% Plot single-sided amplitude spectrum.
figure(2)
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on
axis tight