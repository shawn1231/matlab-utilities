function [f,y] = plot_amplitude_spectrum(x, Ts, units, plot_grid)
%   PLOT_AMPLITUDE_SPECTRUM plots the single-sided-amplitude spectrum using
%   the custom function create_amplitude_spectrum which is based on the
%   built-in MATLAB FFT with enhancements
%
%   [f,y] = plot_amplitude_spectrum(x,Ts,units,grid)
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
% Purpose:          To plot single-sided amplitude spectrum
% Notes:            Passes the return values from the
%                   create_amplitude_spectrum function back to the calling
%                   function
%--------------------------------------------------------------------------

if nargin < 4
    plot_grid = 1;
    if nargin < 3
        units = 'hertz'
    end
end

[y, f] = create_amplitude_spectrum(x,Ts);

if strcmp(units,'hertz')
    x_lab = 'f, Hz';
elseif strcmp(units,'rad/s')
    f = f*2*pi;
    x_lab = 'f, rad/s';
else
    error('Invalid input argument.\nAllowable arguments for''unit'' are:\n%s',...
        '''hertz'' or ''rad/s''');
end

fp = f;
yp = y;

fp(1:5) = [];
yp(1:5) = [];

figure;
plot(fp,yp) 
title('Single-Sided Amplitude Spectrum')

xlabel(x_lab);

if plot_grid == 1
    grid on
    grid minor
end

end








