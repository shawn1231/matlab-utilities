function [lat,lng] = oppositehaversine(start_coordinates,distance,heading,units)
%   OPPOSITEHAVERSINE Uses haversine relationships to calculate ending
%   coordinates from starting coordinates, distance traveled and heading
%
%   [lat,lng] = oppositehaversine(start_coordinates,distance,heading,units)
%
%   INPUTS:
%   start_coordinates contains latitude and longitude location
%   representing the starting point at which the measured distance and
%   heading are calculated
%   distance represents the distance in 'units' travelled from the start
%   point
%   heading is the compass heading in radians measured clockwise from
%   North along which the distance is measured
%   OUTPUTS:
%   lat is the latitude of the endpoint
%   lng is the longitude of the endpoint

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     12/10/2017
% Purpose:          To extract end coordinates from specified distance and
%                   starting coordinates
% Notes:            Uses the same haversine relationships which are used in
%                   haversine function to invert the calculation
%--------------------------------------------------------------------------
    
    % if no units are specified then use km
    if(nargin < 4) % determine if units were passed based on number or args
        units = 'km';
    end
    
    % using mean radius here
    mean_radius_earth = 6371; % km
    
    % convert heading to radians
    %heading = deg2rad(heading);
    lat1 = deg2rad(start_coordinates(1));
    lng1 = deg2rad(start_coordinates(2));
    
    % convert distance to km always
    distance = distance*unitsratio('km',units);
    
    % define helpful variables, angular distance is defined as the distance
    % travelled divided by the radius of the earth in the same unit system
    delta = distance/mean_radius_earth;
    
    % compute the latitude
    lat = asin(sin(lat1)*cos(delta)+cos(lat1)*sin(delta)*cos(heading));
    % compute the longitude
    lng = lng1 + atan2(sin(heading)*sin(delta)*cos(lat1),...
        cos(delta)-sin(lat1)*sin(lat));
    
    % convert latitude and longitude to decimal degrees
    lat = rad2deg(lat);
    lng = rad2deg(lng);
     
    % convert longitude to the correct range (-180,180)
    lng = mod((lng+540),360)-180;
end