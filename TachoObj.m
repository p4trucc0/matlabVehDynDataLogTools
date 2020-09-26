classdef TachoObj < handle
    % Displays speed, RPM or other variables with an old-fashioned gauge
    % and needle indicator.
    % TODO: add a textual indication of current value.
    
    properties
        val = 0;
        descr = '';
        parent = [];
        a1 = [];
        needle_line = [];
        % Properties - Color
        ax_background_color = [0 0 0];
        ax_ticks_color = [1 1 1];
        ax_needle_color = [1 0 0];
        ax_redline_color = [1 0 0];
        % Properties - Tick positioning
        crc_inner_radius_text = .7;
        crc_inner_radius_major = .8;
        crc_outer_radius_major = 1.0;
        crc_width_major = 2;
        crc_inner_radius_minor = .85;
        crc_outer_radius_minor = 1.0;
        crc_width_minor = 1;
        crc_start_angle = (5/4)*pi;
        crc_end_angle = - (1/4)*pi;
        crc_line_number_major = [];
        crc_line_number_minor = [];
        needle_bottom_length = -.1;
        needle_top_length = .9;
        needle_width = 3.0;
        % Properties - Input Value
        val_min = []; %0.0;
        val_max = [];
        val_red = []; % redline
        % Properties - Text
        text_fontsize = 14;
        text_decimals = 1;
        text_offset = -.05;
        % Val text
        % val_text_fontsize = 28;
    end
    
    methods
        
        function obj = TachoObj(n_parent, n_val_min, n_val_max, n_val_red, n_descr, n_crc_line_number_major)
            obj.parent = n_parent;
            obj.val_min = n_val_min;
            obj.val_max = n_val_max;
            obj.val_red = n_val_red;
            obj.descr = n_descr;
            obj.a1 = axes('Parent', obj.parent);
            obj.a1.PlotBoxAspectRatio = [1 1 1];
            obj.a1.XAxis.Visible = 'off';
            obj.a1.YAxis.Visible = 'off';
            obj.a1.Color = obj.ax_background_color;
            obj.crc_line_number_major = n_crc_line_number_major;
            obj.crc_line_number_minor = 4*(obj.crc_line_number_major-1) + 1;
            % Draw major lines (and text)
            major_lines_angle = linspace(obj.crc_start_angle, obj.crc_end_angle, obj.crc_line_number_major);
            for ii = 1:length(major_lines_angle)
                xxl_1 = obj.crc_inner_radius_major*cos(major_lines_angle(ii));
                yyl_1 = obj.crc_inner_radius_major*sin(major_lines_angle(ii));
                xxl_2 = obj.crc_outer_radius_major*cos(major_lines_angle(ii));
                yyl_2 = obj.crc_outer_radius_major*sin(major_lines_angle(ii));
                xxt = obj.crc_inner_radius_text*cos(major_lines_angle(ii)); % - TEXT_FONTSIZE/4;
                yyt = obj.crc_inner_radius_text*sin(major_lines_angle(ii)); % - TEXT_FONTSIZE/2;
                eq_val = obj.val_min + ((major_lines_angle(ii) - obj.crc_start_angle)/(obj.crc_end_angle - obj.crc_start_angle))*(obj.val_max - obj.val_min);
                if eq_val < obj.val_red
                    line([xxl_1 xxl_2], [yyl_1 yyl_2], 'Parent', obj.a1, 'Color', obj.ax_ticks_color, 'LineWidth', obj.crc_width_major);
                    text(xxt + obj.text_offset, yyt, num2str(round(eq_val, obj.text_decimals)), 'Color', obj.ax_ticks_color, 'FontSize', obj.text_fontsize);
                else
                    line([xxl_1 xxl_2], [yyl_1 yyl_2], 'Parent', obj.a1, 'Color', obj.ax_redline_color, 'LineWidth', obj.crc_width_major);
                    text(xxt + obj.text_offset, yyt, num2str(round(eq_val, obj.text_decimals)), 'Color', obj.ax_redline_color, 'FontSize', obj.text_fontsize);
                end
            end
            % Draw minor lines
            minor_lines_angle = linspace(obj.crc_start_angle, obj.crc_end_angle, obj.crc_line_number_minor);
            for ii = 1:length(minor_lines_angle)
                xxl_1 = obj.crc_inner_radius_minor*cos(minor_lines_angle(ii));
                yyl_1 = obj.crc_inner_radius_minor*sin(minor_lines_angle(ii));
                xxl_2 = obj.crc_outer_radius_minor*cos(minor_lines_angle(ii));
                yyl_2 = obj.crc_outer_radius_minor*sin(minor_lines_angle(ii));
                eq_val = ((minor_lines_angle(ii) - obj.crc_start_angle)/(obj.crc_end_angle - obj.crc_start_angle))*(obj.val_max - obj.val_min);
                if eq_val < obj.val_red
                    line([xxl_1 xxl_2], [yyl_1 yyl_2], 'Parent', obj.a1, 'Color', obj.ax_ticks_color, 'LineWidth', obj.crc_width_minor);
                else
                    line([xxl_1 xxl_2], [yyl_1 yyl_2], 'Parent', obj.a1, 'Color', obj.ax_redline_color, 'LineWidth', obj.crc_width_minor);
                end
            end
            text(obj.text_offset, -.5, obj.descr, 'Color', obj.ax_ticks_color, 'FontSize', obj.text_fontsize);
            obj.needle_line = line('XData', [], 'YData', [], 'Parent', obj.a1, 'Color', obj.ax_needle_color, 'LineWidth', obj.needle_width);
            obj.drawNeedle();
        end
        
        function drawNeedle(obj)
            val_ang = ((obj.val - obj.val_min)/(obj.val_max - obj.val_min)) * (obj.crc_end_angle - obj.crc_start_angle) + obj.crc_start_angle;
            xxa_1 = obj.needle_bottom_length * cos(val_ang);
            yya_1 = obj.needle_bottom_length * sin(val_ang);
            xxa_2 = obj.needle_top_length * cos(val_ang);
            yya_2 = obj.needle_top_length * sin(val_ang);
            obj.needle_line.XData = [xxa_1 xxa_2];
            obj.needle_line.YData = [yya_1 yya_2];
        end
        
        function updateVal(obj, n_val)
            obj.val = n_val;
            obj.drawNeedle();
        end
        
    end
    
end