%{
 invoke the uigetfile2table function to bring in .csv data into a table
 structure, call the table structure "data", when you call this function
 pick any of the .csv files representing the data from a single drop which
 are contained in the "03-18_CampRoberts\GoodNavData" directory
%}
data = uigetfile2table();

% before using the next function doctor the altitude vector to get rid of
% the invalid altitude values (greater or equal to 10,000ft.)
% for ii = 1:1:length(data.msl_gps)
%     if data.msl_gps(ii) >= 9999
%         data.msl_gps(ii) = 0;
%     end
% end

for ii = 1:1:length(g_mpu_2_)
    if data.g_mpu_2_(ii) >= 9999
        data.g_mpu_2_(ii) = 0;
    end
end

% plot the altitude vector and find the index for the top and bottom of the
% descent using the ui_table_limits function
% [limits] = ui_table_limits(data.msl_gps);
[limits] = ui_table_limits(data.g_mpu_2_);

% this vector is created for comparison in the plot below, you would not
% create this in a real-life data analysis situation
% untrimmed_altitude = data.msl_gps;
yaw_rate_raw = data.g_mpu_2_;
    Fs = 100; % 100 Hz sampling loop
    Fc = 0.72; %
    wn = Fc/(Fs/2);
    [b2,a2] = butter(4,wn); % 4th Order LP butterworth filter
yaw_rate_fil = filter(b2,a2,yaw_rate_raw); 
delta_L = data.winch_right_cmd;
    
% delete everything from the data table which does not fall within the
% range of interest
data = data(limits(1):limits(2),:);

%{
 check and make sure that we trimmed correctly, note that the index for
 the untrimmed and the index for the trimmed altitude will no longer align
 everything has worked properly if the trimmed altitude now starts near
 the maximum value from the untrimmed altitude at index zero
%}
% figure(1); % ----------------------------------------
% plot(untrimmed_altitude,'r--','LineWidth',1.5);
% hold on
% plot(data.msl_gps,'b.-','LineWidth',1.5);
% legend('untrimmed altitude','trimmed altitude');
% xlabel('index')
% ylabel('altitude (AGL), ft')
% ---------------------------------------------------
% figure(1); % ----------------------------------------
% plot(untrimmed_altitude,'r--','LineWidth',1.5);
% hold on
% plot(data.msl_gps,'b.-','LineWidth',1.5);
% legend('untrimmed altitude','trimmed altitude');
% xlabel('index')
% ylabel('altitude (AGL), ft')

% I'm using the old function here but unwrap_rotations will also work
 yaw_unwrapped = unwrap_rotations_old(data.yaw_mpu_madgwick,160);
% yaw_unwrapped = make_continuous(data.yaw_mpu_madgwick,160,-160,360);
data.yaw_mpu_madgwick = yaw_unwrapped';


% these plots are variables which you might be interested in
% figure(2);
% subplot(2,1,1);
% plot(data.yaw_mpu_madgwick);
% title('yaw angle')
figure(2);
subplot(2,1,1);
plot(delta_L); % Prescribed input data
title('Line Deflection')
subplot(2,1,2);
% Heading titles with [], brackets are replaced by underscores
plot(yaw_rate_fil)
ylabel('angle, rad')
title('yaw rate')
xlabel('index');
ylabel('angular rate, rad/s')

%{
 this is the algorithmic way to create a system identification toolbox
 data object, once this is created in this way you can import it into the
 GUI for the SysID Toolbox by doing the normal "import data" steps but on
 the "time domain data" screen you have to select "data object"
%}
%sys_id_data = iddata(data.yaw_mpu_madgwick,data.yaw_desired,.01);



%{
 this is how you call the transfer function estimator algorithmically, in
 this case I am asking for estimation using a fixed number of poles and
 zeros, this could easily be put into a loop which can step through
 different levels of model complexity and you can extract data about the
 quality of fit from the resulting object
%}
% estimated_tf = tfest(sys_id_data,3,2);
% 
% % create a step response plot using the default stuff, this is just for
% % fun, not neccessarily super useful
% figure(3)
% step(estimated_tf);



