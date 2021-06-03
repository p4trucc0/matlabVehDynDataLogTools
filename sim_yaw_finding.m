function out_angle = sim_yaw_finding(s_acc_in, angle, c_thr)

if nargin < 3
    c_thr = 0.05;
end

% Patrucco, 2021
% Takes an acceleration struct as input and tries finding corresponding
% angle (to see whether the actual formulae work).

ax_v = s_acc_in.ax;
ay_v = s_acc_in.ay;
rz_v = s_acc_in.rz;

ax_r = zeros(size(ax_v));
ay_r = zeros(size(ax_v));
%rz_r = zeros(size(ax_v));

for ii = 1:length(ax_v)
    v_out = ruota_coord([ax_v(ii); ay_v(ii); 0], 0, 0, angle);
    ax_r(ii) = v_out(1);
    ay_r(ii) = v_out(2);
end


param = struct();
param.rz_corner_threshold = c_thr;
param.min_pts = 5;
out_angle = find_sigma_angle(ax_r, ay_r, rz_v, param);

