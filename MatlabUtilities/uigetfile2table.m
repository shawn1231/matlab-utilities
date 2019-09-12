function [table, filename] = uigetfile2table();
%   UIGETFILE2TABLE creates a table from data in a .csv file
%
%   table = uigetfile2table()
%
%   INPUTS:
%   noneplot(ansload
%   OUTPUTS:
%   table - contains all of the data which was in the chosen .csv file,
%   filenames are stored in the first row of the .csv, options to the
%   readtable function are set explicitely to avoid variable naming errors

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     6/19/2018
% Purpose:          To create a table of data in the MATLAB workspace based
%                   on a .csv file which is chosen via the GUI
% Notes:            This function is written and tested on SnowflakeX Phase
%                   III data files, other files may or may not work
%                   properly
% Notes:            If there are issues with variable names you should
%                   check the paramaters associates with opts
%--------------------------------------------------------------------------

message = 'Please choose a file';

% for start directory
user = {'smhhgf','jomtz7'};
start_dir = {}; % need to create empty cell or assignment will not work

for ii = 1:1:length(user)
    current_user = user{ii};
    start_dir{ii} = strcat('C:\Users\',current_user,'\Box Sync\Snowflake X Phase III\1-Phase III\1-FlightTests');
end
% add your own additional entries for personal computers as needed 
% extra for Shawn's personal computer
start_dir{length(start_dir)+1} = 'C:\Users\shawn\Box Sync\Snowflake X Phase III\1-Phase III\1-FlightTests';

% extra for Jesse's laptop 
start_dir{length(start_dir)+1} = 'C:\Users\jomal\Box Sync\Snowflake X Phase III\1-Phase III\1-FlightTests';

for ii = 1:1:length(start_dir)
    if(exist(start_dir{ii}) == 7) 
        break;
    elseif ii == length(start_dir)
        start_dir{length(start_dir)+1} = '';
        ii = ii + 1;
        break;
    end
end

startup_directory = strcat(start_dir{ii},'\*.csv');

[filename, pathname] = uigetfile(startup_directory,message);

full_path_filename = strcat(pathname,filename);

opts = detectImportOptions(full_path_filename,'Delimiter',',');

opts.VariableNamesLine = 1;
opts.DataLine = 2;

table = readtable(full_path_filename,opts,'ReadVariableNames',true);

end




        