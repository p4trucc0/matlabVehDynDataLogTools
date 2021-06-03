function out = ml2unix(tm_in, varargin)
% First argument: timezone, second: conv factor (1.0 for seconds, .001 for
% ms).

if isempty(varargin)
    d = java.util.Date();
    h_timezone = -d.getTimezoneOffset()/60; % UTC zone
    to_sec = 1;
else
    h_timezone = varargin{1};
    if nargin > 2
        to_sec = varargin{2};
    end
end

out = (tm_in - (h_timezone / 24) - datenum(1970, 1, 1)) * (24*3600/to_sec);

end