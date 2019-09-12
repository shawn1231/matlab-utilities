%{
Jesse McDermott
Camp Roberts Testing July 2018

Multi step input for system identification
input runs at 100 Hz
%}
% clear
% close all
% clc

N = 0;
Nmax = 3;
max_amp = .35/Nmax;
tmax = 270;
%start = randi(3600e6);
start = 1;
t = start:1e4:start+(tmax*1e6)-1;
%t = [1:1:70]*1e6;
state = 0; %
period = 20; % seconds, on/off duraton
y(1)=0; %

for i = 1:1:tmax*100
    
    tsd(i) = t(i)/1e6;
    
    if i > 1
    b1 = mod(floor(tsd(i)),period/2); % creates two on/off trigger variables
    b2 = mod(floor(tsd(i-1)),period/2);
     if (b1 == 0 && b2~=0)% || (b1 ~=0 && b2 == 0)
        
        if N >= Nmax % this if is more effective here rather than with y(i) below
            N = -4; % Change from -3 to -4 to capture the - max signal
        end
        if state == 0
            state = 1;
           N = N+1;
        elseif state == 1
                state = 0;
        end 
     end
     y(i) = max_amp*N*state;
%         if N >= 3
%            N = 0;    
    end
 end

plot(t,y)
grid on
xlabel('Time (us)')
ylabel('PWM Signal')

