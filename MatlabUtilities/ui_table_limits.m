function [limits] = ui_table_limits(y_values, extra_space_fraction)
%   [LIMITS] = UI_TABLE_LIMITS(Y_VALUES,EXTRA_SPACE_FRACTION) will plot the
%   passed values and return min and max values based on a location on the
%   plot input by the user using a cursor and a click event
%
%   [limits] = ui_table_limits(y_values)
%
%   INPUTS:
%   Required:
%   y_values is a vector of values which are to be plotted on the axes on
%   which the user will click to establish a min and max value
%   Optional:
%   high_lim represents the largest possible valid value for the data
%   extra_space_fraction is a fraction representing the percentage of the
%   x-values which will be added/subtracted to the user chosen points in
%   order to algorithmically adjust/find the desired limits
%   OUTPUTS:
%   [limits] is a pair of integers representing the minimum and maximum
%   value determined based on the user input, these limits can be used to
%   trim a larger dataset

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     6/18/2018
% Purpose:          To generate the min and max limits for trimming a
%                   dataset based on user provided limits using a GUI
% Notes:            A function like this one is traditionally used to trim
%                   the dataset associated with a droptest based on the
%                   minimum and maximum altitudes as chosen by a user then
%                   refined using some sort of algorithmic technique
% Notes:            Prior to calling this function make sure that numeric
%                   values which are included in the input vector
%                   (y-values) are valid numerical values, this function
%                   will not check to make sure that the min/max values
%                   make sense but it will handle NaN according to MATLAB
%                   documentation for the min and max functions
%--------------------------------------------------------------------------

if nargin < 2
    extra_space_fraction = .05; % five percent seems like a reasonable default
end

% create a dummy x-value vector, this allows the x-values from the plot to
% be used directly as indices
x_values = 1:1:length(y_values);

figure;
plot(x_values,y_values);
[x ~] = ginput(2); % '~' means that we don't care about the second argument
close; % get rid of the plot after the user has clicked twice

if( x(1) > x(2) ) % x(1) is the later value
    i_end = x(1);
    i_begin = x(2);
else % x(1) is the earlier value
    i_end = x(2);
    i_begin = x(1);
end

% give us some wiggle room on the beginning and end points
extra_space = round((i_end - i_begin)*extra_space_fraction);

i_begin = round(i_begin - extra_space);

% protect against invalid indexes (less than zero)
if i_begin < 1
    i_begin = 1;
end

i_end   = round(i_end + extra_space);

% protect against invalid indices (larger than the vector)
if i_end > length(y_values)
    i_end = length(y_values);
end

% remember the beginning index occurs at the maximum altitude
[M idx_maxalt] = max(y_values(i_begin:i_begin+extra_space));

% remember the end index occurs at the minimum altitude
[M idx_minalt] = min(y_values(i_end-extra_space:i_end));

% this is the tricky part of this function, since min and max functions
% were called on a reduced range, the index corresponding to the found
% values is scoped to that reduced range, thus we need to add on the
% starting value for the reduced range in order to find the proper global
% index

i_begin = i_begin + idx_maxalt;
i_end   = i_end -extra_space + idx_minalt;
        
limits = [i_begin i_end];



