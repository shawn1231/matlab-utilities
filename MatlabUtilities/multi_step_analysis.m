%{
   In the log files: Yaw Rate is g_mpu_2_ -- col 36 (or N-1)
                               Winch cmds -- cols 46 & 47 (or N-1)
Winch (or motor) commands represent the change in dynamic line length
leading to changes in yaw and yaw rate. What relationships exist in the 
scale (canopy area, mass and weight,...) and performance data (yaw rate, response,
error, etc)?

%}
%% Load Data and Preprocessing
clear; close all; clc;
load('MotorInputs.mat');
% -----------------------------------------------
[data,filename] = uigetfile2table(); % Uncomment and Use to import data
% load('72318_testing.mat'); % comment out above and use this to keep analyzing same data
i=1;
% ---------- Butter Filter variables ------------
Fs = 100; % 100 Hz sampling loop
Fc = 0.72; %
wn = Fc/(Fs/2);
%------------------------------------------------
time = data.microseconds_since_start;
t = (time - (time(1)))/1000000;
dL_raw = data.winch_left_cmd; % NEUTRAL Line value is 1.5
dL_offset = dL_raw - 1.5; % subtract off the 1.5 offset
yaw_rate = data.g_mpu_2_ ;
% yaw_unwrapped = unwrap_rotations_old(data.yaw_mpu_madgwick,160);
yaw_unwrapped = make_continuous(data.yaw_mpu_madgwick,160,-160,360)';

%{
y = filter(b,a,x) filters the input data x using a rational transfer function 
defined by the numerator and denominator coefficients b and a

% ------- A moving average filter for yaw_rate data ---------
% windowSize = 10; 
% b1 = (1/windowSize)*ones(1,windowSize);
% a1 = 2;
% % y = filter(b,a,x);
% y = filter(b1,a1,yaw_rate);
% dyaw = filter(b1,a1,diff(yaw_unwrapped));
%------------------------------------------------------------
%}
% ------ Filter yaw rate data to reduce noise ----------
[b2,a2] = butter(5,wn); % 4th Order LP butterworth filter
yaw_rate_filt = filtfilt(b2,a2,yaw_rate); % zero-phase filter to eliminate time shift

%------------------------------------------------------------------
%---------------- Motor Transfer Function -------------------------
% Filter step input through Motor TF for Parachute System ID
tsim = [0:1:length(t)-1]';
% Motor_22 from Motor System ID 
% % num = 1.0e5*[0.000937884651246 1.294041219266926 0.025069514394194];
% % den = [1.000000000 5.977771414633959 0.171442474779358];
%       dL_in = lsim(Motor_22, dL_offset,tsim);   %-> Very spiky rise
%
% % Motor_2p1z from Motor System ID 
%       dL_in = lsim(Motor_2p1z, dL_offset,tsim);%-> Very spiky rise
% % Motor_21b from Motor System ID 
        dL_in = lsim(Motor_21b, dL_offset,tsim);
%------------------------------------------------------------------
%%  Step by Step Analysis Finding Signal Groups by Magnitude
%{ 
 Uses G to divide & store each signal magnitude into its own column in the range vector
% Baseline is 4 and subtracting zero centers G
% which is a numerical step locator alternating between 0 and +/-(1-3)
%}
%------------------------------------------------------------------
G = findgroups(dL_raw)-median(findgroups(dL_raw)); 

%% ----------------------------------------------------------------
%--------Shawn's additions-----------------------------------------
%------------------------------------------------------------------
%----------- Adjust amount of clipped data here ---------------------------
% this data will be useful for system id as well, in the case of system id
% (fitting transfer functions) we will want some amount of data before the
% step started (the data at the end is probably not needed for anything but
% 150 samples is just 1.5 seconds so it shouldn't matter much
samples_before = 150; % Values based on sampling rate/frequency (100 Hz)
samples_during = 500; % based on period =10 sec. so on=5s, off=5s
samples_after = 150;
%--------------------------------------------------------------------------

% this turned out to be harder than I thought it would be (surprise right?)
% but this is working now and it creates a nifty cell array containing all
% the results


comparator = [1,2,3,-3,-2,-1]; % order of the comparator vector follows the "natural" order of the multistep
results = cell(1,length(comparator)); % create empty cell array, has to be a cell array because matrices have to be square
max_G = length(G); % avoid repeated calculations
idx = 1;

while idx < max_G % had to use "while" here to control the iterator more precisely than "for" loop allows
    if(max_G-idx < samples_during+samples_after)
        break; % jump out of the idx loop if we are too close to the end
    end
    if(idx > samples_before) % don't start looking for good data until we have enough space
        for y = 1:1:length(comparator) % cycles through comparator to check G
            if(G(idx) == comparator(y)) % this is true only when the input signal is "high"
                results{y} = [results{y}, dL_offset(idx-samples_before:idx+samples_during+samples_after-1), yaw_rate_filt(idx-samples_before:idx+samples_during+samples_after-1)];
%                 results{y} = [results{y}, dL_in(idx-samples_before:idx+samples_during+samples_after-1), yaw_rate_filt(idx-samples_before:idx+samples_during+samples_after-1)];

                idx = idx + samples_before+samples_during+samples_after;
                break; % jump out of the z loop
            end
        end
    end
    idx = idx + 1;
end

% this part of the code creates a plot for each individual "result"
max_m = size(results);
max_m = max_m(2);

for m = 1:1:max_m
    
    dat = results{m};    
    max_n = size(dat);
    max_n = max_n(2);
    
    for n = 1:2:max_n
        % plot whatever you want in here
        figure; % NOTE: if you call just "figure" with no number, it will create a new figure regardless of how many you have already

        in_dat = dat(:,n);
        out_dat = dat(:,n+1);
        out_avg = mean(out_dat(235:end-130)); % MEAN CALCULATION of output magnitude
        line = ones(size(out_dat))*out_avg; % mean value line
        txt = ['Mean Response = ', num2str(out_avg)];
    %--- Plot each input/response result occurance
        plot(in_dat);
        ylim([-.5,.5]);
        text(0,0.4, txt) % label avg response value, 
        yyaxis right     % place text before right axis to tie location to left axis
        plot(out_dat);
        hold on;
        plot(line,'--k'); % plot avg response line
%           text(0,0.4, txt) % label avg response value- location tied to
%           right axis
    %---- Save each figure         
        save_filename = filename;
        save_filename = save_filename(1:end-4); % gets rid of .csv
        save_step = strcat(save_filename,'-response_',num2str(m),'-',num2str(n));

        fig = gcf;
        saveas(fig,char(save_step));

        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 6 6];

        saveas(fig,char(save_step),'png');
    end
end

% some of these are invalid (payload was not spinning backward and/or
% payload was on the ground), they will need to be picked out somehow...
% could be delted manually from the results table or could be found using
% ginput before the file is ever processed

% for the sake of simplicity I would try to delete them manually right now
% % -------- Already done by "plot_yaw_for_directory ------------------ % %
% figure; % Overall Input/Output plot
% plot(dL_offset);
% yyaxis right;
% plot(yaw_rate_filt);
%     save_filename = filename;
%     save_filename = save_filename(1:end-4); % gets rid of .csv
%     save_step = strcat(save_filename,'-YawResponse'); % Save Overall plot
%     fig = gcf;
%     saveas(fig,char(save_step));
% 
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0 0 6 6];
% 
%     saveas(fig,char(save_step),'png');
% % Save results cell for the log file for further analysis
% save(strcat(save_filename,'-results'),'results'); % saves mat file for results in same directory


% End of Shawn's addition------------------------------------------
%------------------------------------------------------------------