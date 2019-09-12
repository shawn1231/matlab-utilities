function wrapped = unwrap_rotations_old(unwrapped, wrap_threshold)
%   UNWRAP_ROTATIONS For discontinuous angles (Euler yaw from quaternions),
%   remove the discontinuity by accumulating the number of wraps and
%   returns the continuous angle estimate
%
%   unwrapped = unwrap_rotations(wrapped, wrap_threshold)
%
%   INPUTS:
%   unwrapped is a discontinuous angle measurements (discontinuity must be
%   zero centered (designed to work with +180 - -180 degrees)
%   wrap_threshold is the magnitude of the extreme value which is to be
%   "caught" and used to increment/decrement the wrap counter
%   OUTPUTS:
%   wrapped is a copy of unwrapped except in locations where there was a
%   discontuity present in unwrapped, at these locations, wrapped will be
%   offset by the appropriate number of degrees in order to make wrapped
%   continuous

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     3/11/2018
% Purpose:          To create continuous yaw measurements from
%                   discontinuous measured yaw measurements
% Notes:            This will only work on data with a valid range of
%                   approximately +180 - -180 degrees
% Notes:            It could be easily modified to work on other ranges
%                   and/or non-zero-centered data
%--------------------------------------------------------------------------


n = 0; % wrap counter
for i = 2:1:length(unwrapped)
if(unwrapped(i) > wrap_threshold && unwrapped(i-1) < -wrap_threshold)
    n = n-1;
elseif(unwrapped(i) < -wrap_threshold && unwrapped(i-1) > wrap_threshold)
    n = n+1;
end
wrapped(i) = unwrapped(i) + 360 * n;
end