function [distance, heading, arclength] = haversine(coordinates1,coordinates2,units)
%   HAVERSINE Uses haversine formula to compute great circle distance
%   between points
%
%   [distance heading arclength] = haversine(coordinates1,coordinates2,units)
%
%   INPUTS:
%   coordinate1 contains latitude and longitude of the start point
%   coordinate2 contains latitude and longitude of the end point
%   units is a character vector representing the units which should be used
%   for the reported distance, see unitsratio for all available units
%   OUTPUTS:
%   distance contains the distance between the points in the given units if
%   no units are given, the output defaults to km
%   heading contains the heading from the start coordinates to the end
%   coordinates in radians
%   arclength contains the arc length of the distance measured in radians

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     12/10/2017
% Purpose:          To calculate great circle distance between coordinates
%                   for the purpose of measuring parachute miss distance
% Notes:            All the caveats of using haversine apply here, maximum
%                   error around 0.5%, using earth's mean radius ignores
%                   the spheroid shape
% Notes:            Distances to be calculated should be on the order of
%                   100's of feet, haversine should be highly accurate
%--------------------------------------------------------------------------
    
    % if no units are specified then use km
    if(nargin < 3) % determine if units were passed based on number or args
        units = 'km';
    end
    
    % using mean radius here
    mean_radius_earth = 6371; % km
    
    % convert latitude and longitude in decimal degrees to radians, use of
    % absolute value may be uneccesary here
    lat1 = deg2rad(coordinates1(1));
    lng1 = deg2rad(coordinates1(2));
    lat2 = deg2rad(coordinates2(1));
    lng2 = deg2rad(coordinates2(2));
    
    % leave the radius of earth out of the formula for now, calculate the
    % arclength (radians) of the distance between the coordinates using the
    % haversine formula
    arclength = asin(sqrt(sin((lat2-lat1)/2).^2 ...
                    + cos(lat1)*cos(lat2)*sin((lng2-lng1)/2).^2));
    
    % solve for the heading between the two coordinates
    heading = atan2(sin(lng2-lng1)*cos(lat2), ...
                cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(lng2-lng1));
    
    % solve for the distance in km
    distance = 2*mean_radius_earth*arclength;
    
    % convert to desired units before ending
    distance = distance*unitsratio(units,'km');

end