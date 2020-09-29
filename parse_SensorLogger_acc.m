function [t_phone, Time_phone, ax, ay, az, rx, ry, rz] = parse_SensorLogger_acc(str_in, offset)

if nargin < 2
    d = java.util.Date();
    offset = -d.getTimezoneOffset()/60;
end

s_sps = strsplit(str_in, sprintf('\t'));

t_phone = str2double(s_sps{1})/1000;
Time_phone = unix2ml(t_phone, offset, 0.001);

s_data = strsplit(s_sps{3}, ',');
ax = str2double(s_data{1});
ay = str2double(s_data{2});
az = str2double(s_data{3});
rx = str2double(s_data{4});
ry = str2double(s_data{5});
rz = str2double(s_data{6});

