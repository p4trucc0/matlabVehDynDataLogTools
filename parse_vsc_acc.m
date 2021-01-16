function [t, ax, ay, az, rx, ry, rz] = parse_vsc_acc(str_in)
% Patrucco, 26/09/2020
% Parses acceleration data coming from the V-Scatola Arduino DataLogger

LSB_TO_MS2 = (9.806/4096);
LSB_TO_RADS = deg2rad(250/32768); % isnt it 205?

ss = str_in(5:end);
sc = strsplit(ss, ';');
t = get_single_val(sc{1})*.001;
ax = get_single_val(sc{2})*LSB_TO_MS2;
ay = get_single_val(sc{3})*LSB_TO_MS2;
az = get_single_val(sc{4})*LSB_TO_MS2;
rx = get_single_val(sc{5})*LSB_TO_RADS;
ry = get_single_val(sc{6})*LSB_TO_RADS;
rz = get_single_val(sc{7})*LSB_TO_RADS;

    function out = get_single_val(s_in)
        s2 = strsplit(s_in, ' = ');
        out = str2double(s2{2});
    end

end
