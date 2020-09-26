classdef GGObj < handle
    % Patrucco, 26/09/2020
    % Graphic object to draw BMW-inspired GG-plots
    % For now, only one color for dots (I suspect introducing "fading"
    % would increase resource consumption by a factor of 10-100...
    
    properties
        parent = [];
        pos = [0 0 1 1];
        cblen = [];
        data = []; % ax, ay, mod
        data_index = [];
        invert_axes = false;
        ax = [];
        background_color = [0 0 0];
        circles_points = 100;
        circles_color = [1 1 1];
        circles_radii = [.25 .5 .75 1.0 1.25];
        circles_texts = [];
        circles_linestyle = '--';
        circles_lines = [];
        dots_color = [1 0 0];
        dots_size = 10;
        dots = [];
        dyn_color = false; % requires re-drawing or something similar.
        max_circle = true; % show maximum of last N points acc like a circle.
        max_circle_l = [];
        max_circle_t = [];
    end
    
    methods
        function obj = GGObj(n_parent, n_pos, n_cblen)
            obj.cblen = n_cblen;
            obj.data = zeros(obj.cblen, 3);
            obj.data_index = 1;
            obj.parent = n_parent;
            obj.pos = n_pos;
            obj.ax = axes('Parent', obj.parent);
            obj.ax.PlotBoxAspectRatio = [1 1 1];
            obj.ax.XAxis.Visible = 'off';
            obj.ax.YAxis.Visible = 'off';
            obj.ax.Color = obj.background_color;
            obj.circles_lines = cell(length(obj.circles_radii), 1);
            obj.circles_texts = cell(length(obj.circles_radii), 1);
            for i_c = 1:length(obj.circles_lines)
                radius = obj.circles_radii(i_c);
                obj.circles_texts{i_c} = text(0, radius, num2str(round(radius, 2)), 'Color', obj.circles_color);
                obj.circles_lines{i_c} = line('XData', [], 'YData', [], ...
                    'LineStyle', obj.circles_linestyle, 'Color', obj.circles_color);
                tv = linspace(0, 2*pi, obj.circles_points);
                xv = radius*cos(tv);
                yv = radius*sin(tv);
                obj.circles_lines{i_c}.XData = xv;
                obj.circles_lines{i_c}.YData = yv;
            end
            obj.ax.XLim = [-obj.circles_radii(end), obj.circles_radii(end)];
            obj.ax.YLim = [-obj.circles_radii(end), obj.circles_radii(end)];
            if obj.invert_axes
                obj.dots = line('XData', +obj.data(:, 2), 'YData', -obj.data(:, 1), ...
                    'Color', obj.dots_color, 'LineStyle', 'none', 'Marker', '.', ...
                    'MarkerSize', obj.dots_size);
            else
                obj.dots = line('XData', -obj.data(:, 2), 'YData', obj.data(:, 1), ...
                    'Color', obj.dots_color, 'LineStyle', 'none', 'Marker', '.', ...
                    'MarkerSize', obj.dots_size);
            end
            if obj.max_circle
                [max_acc, i_max] = max(obj.data(:, 3));
                tv = linspace(0, 2*pi, obj.circles_points);
                xv = max_acc*cos(tv);
                yv = max_acc*sin(tv);
                obj.max_circle_l = line('XData', xv, 'YData', yv, ...
                    'LineStyle', obj.circles_linestyle, 'Color', obj.dots_color);
                obj.max_circle_t = text(-max_acc/sqrt(2), -max_acc/sqrt(2), ...
                    num2str(round(max_acc, 2)), 'Color', obj.dots_color, ...
                    'FontSize', 14, 'FontWeight', 'bold');
            end
        end
        
        function redrawDots(obj)
            if obj.invert_axes
                obj.dots.XData = +obj.data(:, 2);
                obj.dots.YData = -obj.data(:, 1);
            else
                obj.dots.XData = -obj.data(:, 2);
                obj.dots.YData = +obj.data(:, 1);
            end
            if obj.max_circle
                [max_acc, i_max] = max(obj.data(:, 3));
                tv = linspace(0, 2*pi, obj.circles_points);
                xv = max_acc*cos(tv);
                yv = max_acc*sin(tv);
                obj.max_circle_l.XData = xv;
                obj.max_circle_l.YData = yv;
                obj.max_circle_t.Position = [-max_acc/sqrt(2), -max_acc/sqrt(2), 0];
                obj.max_circle_t.String = num2str(round(max_acc, 2));
            end
        end
        
        % handle circular buffer.
        function addNewData(obj, ax, ay)
            obj.data(obj.data_index, 1) = ax;
            obj.data(obj.data_index, 2) = ay;
            obj.data(obj.data_index, 3) = (ax^2 + ay^2)^.5;
            if obj.data_index == obj.cblen
                obj.data_index = 1;
            else
                obj.data_index = obj.data_index + 1;
            end
        end
        
        function updateRedraw(obj, n_ax, n_ay)
            obj.addNewData(n_ax, n_ay);
            obj.redrawDots();
        end
        
    end
    
    
end