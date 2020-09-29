function out = unix2ml(ts_in, varargin)
%% Patrucco, 2020
% Converts a unix timestamp into Matlab format.

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

out = datenum(1970, 1, 1) + h_timezone/24 + ts_in*to_sec./(24*3600);




