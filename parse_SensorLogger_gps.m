function [t_phone, Time_phone, latitude, longitude, speed] = parse_SensorLogger_gps(str_in, offset)

if nargin < 2
    d = java.util.Date();
    offset = -d.getTimezoneOffset()/60;
end

s_sps = strsplit(str_in, sprintf('\t'));

t_phone = str2double(s_sps{1})/1000;
Time_phone = unix2ml(t_phone, offset, 0.001);

s_data = strsplit(s_sps{3}, ',');
latitude = str2double(s_data{1});
longitude = str2double(s_data{2});
speed = str2double(s_data{3});

