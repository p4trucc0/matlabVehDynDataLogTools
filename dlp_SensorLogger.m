function [nA, nG, acc, gps] = dlp_SensorLogger(line_in)
%% Patrucco, 26/09/2020
% Parses incoming data from Arduino DataLogger ("V-Scatola") and composes
% an output which can be used by the SerialDataLogger class


acc = struct('Time', NaN, 'ax', NaN, 'ay', NaN, 'az', NaN, 'rx', NaN, 'ry', NaN, 'rz', NaN);
gps = struct('Time', NaN, 'speed_kmh', NaN, 'latitude', NaN, 'longitude', NaN, 'heading', NaN, 'TimeGps', NaN);

if contains(line_in, 'ACC')
    try
        [~, ~, ax, ay, az, rx, ry, rz] = parse_SensorLogger_acc(line_in);
        acc.Time = now;
        acc.ax = ax;
        acc.ay = ay;
        acc.az = az;
        acc.rx = rx;
        acc.ry = ry;
        acc.rz = rz;
        nA = true;
    catch
        nA = false;
    end
else
    nA = false;
end

if contains(line_in, 'GPS')
    try
        [~, TimeGps, lat, lon, v_kmh] = parse_SensorLogger_gps(line_in);
        gps.Time = now;
        gps.speed_kmh = v_kmh;
        gps.latitude = lat;
        gps.longitude = lon;
        gps.TimeGps = TimeGps;
        nG = true;
    catch
        nG = false;
    end
else
    nG = false;
end
