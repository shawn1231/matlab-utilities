function continuous = make_continuous(discontinuous, upper_thresh, lower_thresh, offset_amt)
%   UNWRAP_ROTATIONS For discontinuous values
%
%   continuous = make_continuous(discontinuous, upper_thresh, lower_thresh, offset_amt)
%
%   INPUTS:
%   discontinuous is a discontinuous vector
%   upper_thresh is the upper magnitude limit to be used when finding
%   discontinuities
%   lower_thres is the lower magnitude limit to be used when finding
%   discontinuities
%   offset_amt is the difference in magnitude of the variable of interest
%   before and after wrapping, in the case of wrapping a yaw angle for
%   example, the offset_amt should be set equal to 360 degrees
%   OUTPUTS:
%   continuous is a copy of unwrapped except in locations where there was a
%   discontuity present in the discontinuous vector

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     3/17/2018
% Purpose:          To create continuous measurements from discontinuous
%                   data from an absolute encoder
% Example usage:    this works on a data file which contains encoder data
%                   on the adc at position 3
% thresh = 2000;
% testing = make_continuous(df.adc3, 5000-thresh, 0+thresh, 5000);
% Notes:            thresholds may need to be tuned for your application
%--------------------------------------------------------------------------

if(nargin < 3)
    lower_thresh = -upper_thresh;
    offset_amt = 360;
end

n = 0; % wrap counter
continuous(1) = discontinuous(1);

for i = 2:1:length(discontinuous)
if(discontinuous(i) > upper_thresh && discontinuous(i-1) < lower_thresh)
    n = n-1;
elseif(discontinuous(i) < lower_thresh && discontinuous(i-1) > upper_thresh)
    n = n+1;
end
continuous(i) = discontinuous(i) + offset_amt * n;
end

continuous = continuous';