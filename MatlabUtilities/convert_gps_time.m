function [year,month,day,hour,minute,second,zone] = convert_gps_time(single_time_string)
%   CONVERT GPS TIME takes a string formatted time and converts it into
%   component parts of time with the appropriate data type so they can be
%   more easily manipulated
%
%   [year,month,day,hour,minute,second,zone] = convert_gps_time(single_time_string)
%
%   INPUTS:
%   single_time_string is a variable containing a GPS time string formatted
%   according to the following pattern:  YYYY-MM-DDTHH:MM:SSZ
%   OUTPUTS:
%   year contains the year when the GPS record was written
%   month contains the month when the GPS record was written
%   day contains the day when the GPS record was written
%   hour contains the hour when the GPS record was written (24hr format)
%   minute contains the minute when the GPS record was written
%   second contains the second when the GPS record was written
%   zone contains the character code for the time zone used by the GPS time
%   record (this should always be 'Z' for ZULU or UTC+0)

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     04/11/2019
% Purpose:          To convert gibberish time strings into useful data
% Notes:            This function does not convert GPS MTOW or similar time
%                   formats, it is just a simple text parser for fixed
%                   width time strings
%--------------------------------------------------------------------------

    chr      = char(single_time_string);

    year     = str2num(chr(1:4));
    month    = str2num(chr(6:7));
    day      = str2num(chr(9:10));
    hour     = str2num(chr(12:13));
    minute   = str2num(chr(15:16));
    second   = str2num(chr(18:19));
    zone     = chr(20);

end
    



