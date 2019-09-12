function [y,f] = create_amplitude_spectrum(x,Ts)
%   CREATE_AMPLITUDE_SPECTRUM gives frequency and amplitude from built-in
%   FFT function, frequency vector is created automatically
%
%   [y,f] = plot_amplitude_spectrum(x,Ts)
%
%   INPUTS:
%   x the input vector of interest, the variable which the frequency
%   information is to be studied
%   Ts is the sample time in seconds corresponding with the x vector
%   OUTPUTS:
%   y the amplitude for the frequency of the x vector given by FFT
%   f the frequency vector (x values) corresponding with the y vector

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     06/24/2018
% Purpose:          To generate single-sided amplitude spectrum from input
%                   vector
% Notes:            Built-in MATLAB FFT is used to generate the frequency
%                   information
% Notes:            The frequency vector is created automatically using the
%                   sample time
% Notes:            The first samples from the frequency vector are thrown
%                   out to get rid of the 0 frequency spike
% Notes:            Input vector is padded to length of nearest power of
%                   two
%--------------------------------------------------------------------------

Fs = 1/Ts;

% find the initial value for L
L = length(x);

% find the next highest power of 2
p = nextpow2(L);

% recalculate the value for L
L = 2^p;

% Time vector
t = (0:L-1)*Ts;

% use FFT with length argument to speed up calculation
y = fft(x,L);
% y = abs(fft(x,L)).^2;

P2 = abs(y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

y = P1;

f = Fs*(0:(L/2))/L;

y = y(2:end);
f = f(2:end);

end