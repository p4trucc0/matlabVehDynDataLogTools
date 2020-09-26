function [t, time_utc_str, isactive, lat, lon, v_kts, course, date_str, mvar, Time] = parse_vsc_gps(str_in)
% Patrucco, 26/09/2020
% Parses GPS data coming from the V-Scatola Arduino DataLogger.
% It just corresponds to a time measure in [ms] plus a raw GPRMC string,
% which is not necessarily completely transmitted

ss = str_in(5:end);
sc = strsplit(ss, ';');
try
    ssc = strsplit(sc{1}, ' = ');
    t = str2double(ssc{2})*.001;
catch
    t = NaN;
end

rmc_in = sc{2};

rmc_ss = strsplit(rmc_in, ',', 'CollapseDelimiters', false);
if length(rmc_ss) >= 2
    try
        time_utc_str = rmc_ss{2};
        time_h = str2double(rmc_ss{2}(1:2));
        time_m = str2double(rmc_ss{2}(3:4));
        time_s = str2double(rmc_ss{2}(5:end));
    catch
        time_utc_str = '';
        time_h = NaN;
        time_m = NaN;
        time_s = NaN;
    end
else
    time_utc_str = '';
    time_h = NaN;
    time_m = NaN;
    time_s = NaN;
end
if length(rmc_ss) >= 3
    isactive = isequal(rmc_ss{3}, 'A');
else
    isactive = NaN;
end
if length(rmc_ss) >= 5
    latstr = rmc_ss{4};
    if rmc_ss{5} == 'N'
        latdir = +1;
    else
        latdir = -1;
    end
    try
        lat_deg = str2double(latstr(1:2));
        lat_min = str2double(latstr(3:end));
        lat = (lat_deg + lat_min / 60) * latdir;
    catch
        lat = NaN;
    end
else
    lat = NaN;
end
if length(rmc_ss) >= 7
    lonstr = rmc_ss{6};
    if rmc_ss{7} == 'E'
        londir = +1;
    else
        londir = -1;
    end
    try
        lon_deg = str2double(lonstr(1:3));
        lon_min = str2double(lonstr(4:end));
        lon = (lon_deg + lon_min / 60) * londir;
    catch
        lon = NaN;
    end
else
    lon = NaN;
end
if length(rmc_ss) >= 8
    v_kts = str2double(rmc_ss{8});
else
    v_kts = NaN;
end
if length(rmc_ss) >= 9
    course = str2double(rmc_ss{9});
else
    course = NaN;
end
if length(rmc_ss) >= 10
    try
        date_str = rmc_ss{10};
        date_d = str2double(date_str(1:2));
        date_m = str2double(date_str(3:4));
        date_y = 2000 + str2double(date_str(5:6));
    catch
        date_str = '';
        date_d = NaN;
        date_m = NaN;
        date_y = NaN;
    end
else
    date_str = '';
    date_d = NaN;
    date_m = NaN;
    date_y = NaN;
end
if length(rmc_ss) >= 11
    mvar = str2double(rmc_ss{11});
else
    mvar = NaN;
end
Time = datenum(date_y, date_m, date_d, time_h, time_m, time_s);
end