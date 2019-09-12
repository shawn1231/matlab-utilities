%{
PAVS Lab May 2018
System Identification practice
Using servo data from previous payload iteration and
new DC motor actuators of new payload design.
%}

clear all;
close all;
clc;
% Use the Servo dataset 1 for model creation and Servo dataset 2 for validation.
% Input files
nstep = csvread('Negative_step.csv',1);
pstep = csvread('Positive_step.csv',1);

% Pull only adc3 data from each response file (6 total)- Noncontinuous
Data    = csvread('ServoAYMB1.csv',1,1);
tA1     = Data(:,1)./1000000;
servoA1 = Data(:,18);

Data    = csvread('ServoAYMB2.csv',1,1);
tA2     = Data(:,1)./1000000;
servoA2 = Data(:,18);

Data    = csvread('ServoYMB1.csv',1,1);
tY1     = Data(:,1)./1000000;
servoY1 = Data(:,18);

Data    = csvread('ServoYMB2.csv',1,1);
tY2     = Data(:,1)./1000000;
servoY2 = Data(:,18);

Data = csvread('NewActuator1.csv',1,1);
tdc1 = Data(:,1)./1000000;
dc1  = Data(:,18);

Data = csvread('NewActuator2.csv',1,1);
tdc2 = Data(:,1)./1000000;
dc2  = Data(:,18);


%% Use Make Continuous function
% Continuous servo & dc motor output
thresh = 1500;
AYMB1 = make_continuous(servoA1, 5000-thresh, 0+thresh, 5000)';
% positive step input -------------------------------------

%thresh = 2000;
AYMB2 = make_continuous(servoA2, 5000-thresh, 0+thresh, 5000)';
% positive step input -------------------------------------

%thresh = 2000;
YMB1 = make_continuous(servoY1, 5000-thresh, 0+thresh, 5000)';
% positive step input -------------------------------------

%thresh = 2000;
YMB2 = make_continuous(servoY2, 5000-thresh, 0+thresh, 5000)';
% positive step input -------------------------------------

thresh = 2250;
DC1 = make_continuous(dc1, 5000-thresh, 0+thresh, 5000)';
% positive step input -------------------------------------

%thresh = 2000;
DC2 = make_continuous(dc2, 5000-thresh, 0+thresh, 5000)';
% positive step input -------------------------------------

%% Make equal vectors (select portions of data)

u1 = pstep(650:1050); % 0.3 input phase
y1 = AYMB1(650:1050);
v1 = AYMB2(650:1050);

y2 = YMB1(650:1050);
v2 = YMB2(650:1050);

y3 = DC1(650:1050);
v3 = DC2(650:1050);

%% Alternate loop Section %%
% hi_threshold = 4500;
% lo_threshold = 0500;
% 
% num_wraps = 0;
% 
% for i = 1:1:length(rotations)
%     if i > 1
%         if ((rotations(i-1) < lo_threshold) && (rotations(i) > hi_threshold))
%             num_wraps = num_wraps - 1;
%         elseif ((rotations(i-1) > hi_threshold) && (rotations(i) < lo_threshold))
%             num_wraps = num_wraps + 1;
%         end
%     end
%     temp(i) = rotations(i) + 5000*num_wraps;
% end
% 
% temp = temp*(360/5000);
% rotations = temp';