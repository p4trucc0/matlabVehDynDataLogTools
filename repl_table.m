function out = repl_table(s_gps, s_acc, method, param)
% Create a table in a format compatible with that of V A P O R G R A D E to
% visualize an instant replay. Both order of fields and coso is important.

if nargin < 3
    method = 'gps_interp';
    if nargin < 4
        param = struct();
        param.sanitize_gps = true;
        param.wheel_radius = 0.3;
    end
end

FPS = 60;
dt = 1/FPS;

out_fnames = {'t','th_m_0','th_c_0','xc_0','yc_0','zc_0','rho_0','beta_0',...
    'sigma_0','l_fl_0','l_fr_0','l_rl_0','l_rr_0','th_fl_0','th_fr_0',...
    'th_rl_0','th_rr_0','phi_fl','phi_fr','phi_rl','phi_rr','sa_fl',...
    'sa_fr','sa_rl','sa_rr','sr_fl','sr_fr','sr_rl','sr_rr','Fz_fl',...
    'Fz_fr','Fz_rl','Fz_rr','Fx_fl','Fx_fr','Fx_rl','Fx_rr','Fy_fl',...
    'Fy_fr','Fy_rl','Fy_rr','th_m_1','th_c_1','xc_1','yc_1','zc_1',...
    'rho_1','beta_1','sigma_1','l_fl_1','l_fr_1','l_rl_1','l_rr_1','th_fl_1',...
    'th_fr_1','th_rl_1','th_rr_1','th_m_2','th_c_2','xc_2','yc_2','zc_2',...
    'rho_2','beta_2','sigma_2','l_fl_2','l_fr_2','l_rl_2','l_rr_2',...
    'th_fl_2','th_fr_2','th_rl_2','th_rr_2','Ax','Ay','Az','Mf_fl',...
    'Mf_fr','Mf_rl','Mf_rr','Mf_th_fl','Mf_th_fr','Mf_th_rl','Mf_th_rr',...
    'Ma_fl','Ma_fr','Ma_rl','Ma_rr','Md','Mda','Mdp','Mc','Me','gas_pedal',...
    'brk_pedal','clc_pedal','clutch_engaged','gear_lever','steering_wheel',...
    'steered_angle'};

if param.sanitize_gps
    ind_n1 = isnan(s_gps.speed);
    ind_n2 = isnan(s_gps.course);
    ind_ok = find((ind_n1 == 0) & (ind_n2 == 0));
    s_gps = cut_scalar_struct_arb(s_gps, ind_ok);
end

g_t0 = min(s_gps.time);
a_t0 = min(s_acc.time);
g_t1 = max(s_gps.time);
a_t1 = max(s_acc.time);

t0 = max([g_t0 a_t0]);
t1 = min([g_t1 a_t1]);

tv = [t0:dt:t1]';
N = length(tv);


s_gps.course_e_rad = deg2rad(90 -s_gps.course);


out = struct();
for ii = 1:length(out_fnames)
    out.(out_fnames{ii}) = zeros(N, 1);
end

if strcmp(method, 'gps_interp') % raw interpolation method - only GPS.
    out.t = tv;
    out.xc_0 = interp1(s_gps.time, s_gps.x, out.t);
    out.yc_0 = interp1(s_gps.time, s_gps.y, out.t);
    out.sigma_0 = interp1(s_gps.time, s_gps.course_e_rad, out.t);
    out.sigma_1 = [0; diff(out.sigma_0)./dt];
    v_tv = interp1(s_gps.time, (s_gps.speed), out.t);
    out.xc_1 = interp1(s_gps.time, (s_gps.speed), out.t).*cos(out.sigma_0);
    out.yc_1 = interp1(s_gps.time, (s_gps.speed), out.t).*sin(out.sigma_0);
    out.th_fl_1 = interp1(s_gps.time, (s_gps.speed), out.t)./param.wheel_radius;
    out.th_fr_1 = interp1(s_gps.time, (s_gps.speed), out.t)./param.wheel_radius;
    out.th_rl_1 = interp1(s_gps.time, (s_gps.speed), out.t)./param.wheel_radius;
    out.th_rr_1 = interp1(s_gps.time, (s_gps.speed), out.t)./param.wheel_radius;
    out.th_fl_0 = cumtrapz(out.t, out.th_fl_1);
    out.th_fr_0 = cumtrapz(out.t, out.th_fr_1);
    out.th_rl_0 = cumtrapz(out.t, out.th_rl_1);
    out.th_rr_0 = cumtrapz(out.t, out.th_rr_1);
    out.Ax = [0; diff(v_tv)./dt];
    out.Ay = v_tv.*out.sigma_1;
end




