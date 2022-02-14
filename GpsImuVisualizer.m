classdef GpsImuVisualizer < handle
    % Visualize, on a GUI panel, the full history of any GPS + IMU logger 
    
    properties
        parent = []; % figure or panel
        controls = struct(); % buttons and slider objects.
        s_gps = []; % gps history
        s_acc = []; % acc history
        v_gps = []; % visible gps
        v_acc = []; % visible acc
        axes = struct(); % axes
        panels = struct();
        textboxes = struct();
        metrics = struct(); % 
        time_int = [-Inf, Inf]; % selected time-interval
        time_markers = [];
        fontsizes = struct('upper_descr', 9);
    end
    
    methods
        
        function obj = GpsImuVisualizer(n_parent)
            obj.parent = n_parent;
            obj.panels.upper = uipanel('parent', obj.parent, 'position', [0 0.95 1 0.05], 'BorderType', 'none');
            obj.panels.mid = uipanel('parent', obj.parent, 'position', [0 0.1 1 0.85], 'BorderType', 'none');
            obj.panels.midlow = uipanel('parent', obj.parent, 'position', [0 0.05 1 0.05], 'BorderType', 'none');
            obj.panels.lower = uipanel('parent', obj.parent, 'position', [0 0 1 0.05], 'BorderType', 'none');
            obj.axes.trajectory = BlackGraph(obj.panels.mid, [], [], 'position', [0 0.5 0.5 0.5], 'axes_equal', true, 'title_str', 'Traiettoria');
            obj.axes.speed = BlackGraph(obj.panels.mid, [], [], 'position', [0.5 0.5 0.5 0.5], 'axes_equal', false, 'title_str', 'Velocità');
            obj.axes.altitude = BlackGraph(obj.panels.mid, [], [], 'position', [0 0.25 0.5 0.25], 'axes_equal', false, 'title_str', 'Altitudine');
            obj.axes.accX = BlackGraph(obj.panels.mid, [], [], 'position', [0.5 0.25 0.5 0.25], 'axes_equal', false, 'title_str', 'Acc. Long.');
            obj.axes.accY = BlackGraph(obj.panels.mid, [], [], 'position', [0.5 0 0.5 0.25], 'axes_equal', false, 'title_str', 'Acc. Lat.');
            obj.axes.rotZ = BlackGraph(obj.panels.mid, [], [], 'position', [0 0 0.5 0.25], 'axes_equal', false, 'title_str', 'Rot. Z.');
            obj.textboxes.main = uicontrol('parent', obj.panels.upper,'Style','edit', 'units', 'norm', 'pos', [0 0 .5 1], ...
                'String', 'GpsImuVisualizer V0.1 - No file loaded', 'FontSize', obj.fontsizes.upper_descr, 'enable', 'inactive');
            obj.textboxes.time_limits = uicontrol('parent', obj.panels.upper,'Style','edit', 'units', 'norm', 'pos', [.5 0 .25 1], ...
                'String', 'T=xxxx.x-yyyy.y s (XXXXs)', 'FontSize', obj.fontsizes.upper_descr, 'enable', 'inactive');
            obj.textboxes.dist_limits = uicontrol('parent', obj.panels.upper,'Style','edit', 'units', 'norm', 'pos', [.75 0 .25 1], ...
                'String', 's=xxxxx.x-yyyyy.y s (XXkm)', 'FontSize', obj.fontsizes.upper_descr, 'enable', 'inactive');
            obj.controls.btn_load = uicontrol('parent', obj.panels.midlow, 'style','pushbutton', ...
                'units','norm', 'position', [0 0 0.2 1], 'String', 'Carica', ...
                'FontName', 'Arial', 'FontSize', obj.fontsizes.upper_descr, 'Callback', @obj.load_from_file, ...
                'BackgroundColor', [.9 .9 .9], 'Tag', 'X2C');
            obj.controls.btn_tfilt = uicontrol('parent', obj.panels.midlow, 'style','pushbutton', ...
                'units','norm', 'position', [0.2 0 0.2 1], 'String', 'FiltTempo', ...
                'FontName', 'Arial', 'FontSize', obj.fontsizes.upper_descr, 'Callback', @obj.graphic_time_filter, ...
                'BackgroundColor', [.9 .9 .9], 'Tag', 'X2C');
            obj.controls.btn_tfilt = uicontrol('parent', obj.panels.midlow, 'style','pushbutton', ...
                'units','norm', 'position', [0.4 0 0.2 1], 'String', 'ResetFilt', ...
                'FontName', 'Arial', 'FontSize', obj.fontsizes.upper_descr, 'Callback', @obj.reset_time_filter, ...
                'BackgroundColor', [.9 .9 .9], 'Tag', 'X2C');
            obj.controls.btn_addmk = uicontrol('parent', obj.panels.midlow, 'style','pushbutton', ...
                'units','norm', 'position', [0.6 0 0.2 1], 'String', 'Marcatore+', ...
                'FontName', 'Arial', 'FontSize', obj.fontsizes.upper_descr, 'Callback', @obj.add_marker, ...
                'BackgroundColor', [.9 .9 .9], 'Tag', 'X2C');
            obj.controls.btn_addmk = uicontrol('parent', obj.panels.midlow, 'style','pushbutton', ...
                'units','norm', 'position', [0.8 0 0.2 1], 'String', 'MarcatoreR', ...
                'FontName', 'Arial', 'FontSize', obj.fontsizes.upper_descr, 'Callback', @obj.rm_marker, ...
                'BackgroundColor', [.9 .9 .9], 'Tag', 'X2C');
        end
        
        function load_from_file(obj, ev1, ev2, ev3)
            [fname, fpath] = uigetfile('*.txt', 'Load File...');
            [s_acc1, s_gps1, ~] = load_gpsacc_log([fpath, fname]);
            obj.load_histories(s_acc1, s_gps1);
        end
        
        function load_histories(obj, n_acc, n_gps)
            obj.s_acc = n_acc;
            obj.s_gps = n_gps;
            obj.v_acc = n_acc;
            obj.v_gps = n_gps;
            obj.time_int = [-Inf, Inf];
            obj.calc_metrics();
            obj.update_graphs();
        end
        
        function calc_metrics(obj)
            if (~isempty(obj.v_gps) && ~isempty(obj.s_gps))
                obj.metrics.total.time = obj.s_gps.time(end) - obj.s_gps.time(1);
                obj.metrics.total.dist = obj.s_gps.distance_m(end) - obj.s_gps.distance_m(1);
                obj.metrics.partial.time = obj.v_gps.time(end) - obj.v_gps.time(1);
                obj.metrics.partial.dist = obj.v_gps.distance_m(end) - obj.v_gps.distance_m(1);
                obj.metrics.partial.t0 = obj.v_gps.time(1);
                obj.metrics.partial.t1 = obj.v_gps.time(end);
                obj.metrics.partial.d0 = obj.v_gps.distance_m(1);
                obj.metrics.partial.d1 = obj.v_gps.distance_m(end);
                obj.metrics.partial.v_max = 3.6*max(obj.v_gps.speed);
                obj.metrics.partial.v_min = 3.6*min(obj.v_gps.speed);
                obj.metrics.partial.v_mean = 3.6*mean(obj.v_gps.speed, 'omitnan');
                obj.metrics.partial.alt_max = max(obj.v_gps.altitude);
                obj.metrics.partial.alt_min = min(obj.v_gps.altitude);
                obj.metrics.partial.alt_mean = mean(obj.v_gps.altitude, 'omitnan');
                obj.metrics.partial.ax_brk_max = min(obj.v_acc.ax);
                obj.metrics.partial.ax_acc_max = max(obj.v_acc.ax);
                obj.metrics.partial.ay_acc_max = max(abs(obj.v_acc.ay));
                obj.metrics.partial.lat_max = max(obj.v_gps.latitude);
                obj.metrics.partial.lat_min = min(obj.v_gps.latitude);
                obj.metrics.partial.lon_max = max(obj.v_gps.longitude);
                obj.metrics.partial.lon_min = min(obj.v_gps.longitude);
            else
                obj.metrics.total.time = NaN;
                obj.metrics.total.dist = NaN;
                obj.metrics.partial.time = NaN;
                obj.metrics.partial.dist = NaN;
                obj.metrics.partial.t0 = NaN;
                obj.metrics.partial.t1 = NaN;
                obj.metrics.partial.d0 = NaN;
                obj.metrics.partial.d1 = NaN;
                obj.metrics.partial.v_max = NaN;
                obj.metrics.partial.v_min = NaN;
                obj.metrics.partial.v_mean = NaN;
                obj.metrics.partial.alt_max = NaN;
                obj.metrics.partial.alt_min = NaN;
                obj.metrics.partial.alt_mean = NaN;
                obj.metrics.partial.ax_brk_max = NaN;
                obj.metrics.partial.ax_acc_max = NaN;
                obj.metrics.partial.ay_acc_max = NaN;
                obj.metrics.partial.lat_max = NaN;
                obj.metrics.partial.lat_min = NaN;
                obj.metrics.partial.lon_max = NaN;
                obj.metrics.partial.lon_min = NaN;
            end
        end
        
        function update_graphs(obj)
            fn_ax = fieldnames(obj.axes);
            for i_f = 1:length(fn_ax)
                obj.axes.(fn_ax{i_f}).reset_lines();
            end
            obj.axes.trajectory.add_line(obj.v_gps.x, obj.v_gps.y);
            obj.axes.trajectory.add_line(obj.v_gps.x(1:2), obj.v_gps.y(1:2));
            gps_str = ['Lat: ', num2str(obj.metrics.partial.lat_min), ...
                '-', num2str(obj.metrics.partial.lat_max), '; Long: ', ...
                num2str(obj.metrics.partial.lon_min), ...
                '-', num2str(obj.metrics.partial.lon_max)];
            obj.axes.trajectory.set_add_str(gps_str);
            obj.axes.speed.add_line(obj.v_gps.time, 3.6*obj.v_gps.speed);
            str_add_str = ['Min = ', num2str(round(obj.metrics.partial.v_min, 1)), ...
                '; Max = ', num2str(round(obj.metrics.partial.v_max, 1))];
            obj.axes.speed.set_add_str(str_add_str);
            obj.axes.altitude.add_line(obj.v_gps.time, obj.v_gps.altitude);
            alt_add_str = ['Min = ', num2str(round(obj.metrics.partial.alt_min, 1)), ...
                '; Max = ', num2str(round(obj.metrics.partial.alt_max, 1))];
            obj.axes.altitude.set_add_str(alt_add_str);
            obj.axes.accX.add_line(obj.v_acc.time, obj.v_acc.ax);
            acx_add_str = ['Accel. Max = ', num2str(round(obj.metrics.partial.ax_acc_max, 1)), ...
                '; Frenata Max = ', num2str(round(obj.metrics.partial.ax_brk_max, 1))];
            obj.axes.accX.set_add_str(acx_add_str);
            obj.axes.accY.add_line(obj.v_acc.time, obj.v_acc.ay);
            acy_add_str = ['Accel. Lat. Max = ', num2str(round(obj.metrics.partial.ay_acc_max, 1))];
            obj.axes.accY.set_add_str(acy_add_str);
            obj.axes.rotZ.add_line(obj.v_acc.time, obj.v_acc.rz);
            s_gen_tempo = ['T [s]=', num2str(round(obj.metrics.partial.t0,1)), ...
                '-', num2str(round(obj.metrics.partial.t1,1)), 's (', ...
                num2str(round(obj.metrics.total.time)), ')'];
            s_gen_dist = ['s [m]=', num2str(round(obj.metrics.partial.d0,1)), ...
                '-', num2str(round(obj.metrics.partial.d1,1)), 'm (', ...
                num2str(round(obj.metrics.total.dist/1000)), 'km)'];
             obj.textboxes.time_limits.String = s_gen_tempo;
             obj.textboxes.dist_limits.String = s_gen_dist;
            for i_m = 1:length(obj.time_markers)
                 obj.axes.trajectory.add_marker(interp1(obj.s_gps.time, obj.s_gps.x, obj.time_markers(i_m)), ...
                     interp1(obj.s_gps.time, obj.s_gps.y, obj.time_markers(i_m)));
                 obj.axes.speed.add_marker(obj.time_markers(i_m), 3.6*interp1(obj.s_gps.time, obj.s_gps.speed, obj.time_markers(i_m)));
                 obj.axes.altitude.add_marker(obj.time_markers(i_m), interp1(obj.s_gps.time, obj.s_gps.altitude, obj.time_markers(i_m)));
                 obj.axes.accX.add_marker(obj.time_markers(i_m), interp1(obj.s_acc.time, obj.s_acc.ax, obj.time_markers(i_m)));
                 obj.axes.accY.add_marker(obj.time_markers(i_m), interp1(obj.s_acc.time, obj.s_acc.ay, obj.time_markers(i_m)));
                 obj.axes.rotZ.add_marker(obj.time_markers(i_m), interp1(obj.s_acc.time, obj.s_acc.rz, obj.time_markers(i_m)));
            end
        end
        
        function graphic_time_filter(obj, ev1, ev2, ev3)
            xxv = ginput(2);
            obj.time_int = [xxv(1, 1), xxv(2, 1)];
            i_gps = find(obj.s_gps.time >= obj.time_int(1) & obj.s_gps.time <= obj.time_int(2));
            i_acc = find(obj.s_acc.time >= obj.time_int(1) & obj.s_acc.time <= obj.time_int(2));
            obj.v_gps = cut_scalar_struct_arb(obj.s_gps, i_gps);
            obj.v_acc = cut_scalar_struct_arb(obj.s_acc, i_acc);
            obj.calc_metrics();
            obj.update_graphs();
        end
        
        function reset_time_filter(obj, ev1, ev2, ev3)
            obj.time_int = [-Inf, Inf];
            i_gps = find(obj.s_gps.time >= obj.time_int(1) & obj.s_gps.time <= obj.time_int(2));
            i_acc = find(obj.s_acc.time >= obj.time_int(1) & obj.s_acc.time <= obj.time_int(2));
            obj.v_gps = cut_scalar_struct_arb(obj.s_gps, i_gps);
            obj.v_acc = cut_scalar_struct_arb(obj.s_acc, i_acc);
            obj.calc_metrics();
            obj.update_graphs();
        end
        
        function add_marker(obj, ev1, ev2, ev3)
            x = ginput(1);
            obj.time_markers = [obj.time_markers, x(1)];
            obj.update_graphs()
        end
        
        function rm_marker(obj, ev1, ev2, ev3)
            if ~isempty(obj.time_markers)
                obj.time_markers(end) = [];
            end
            obj.update_graphs()
        end
        
    end
    
    events
    end
    
end