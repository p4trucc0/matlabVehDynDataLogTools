classdef BlackGraph < handle
    % Black axes object for sleeker, more badass data representation
    
    properties
        parent = [];
        position = [0 0 1 1];
        x_data = {};
        y_data = {};
        mx_data = {};
        my_data = {};
        axes = [];
        lines = cell(12, 1);
        markers = cell(12, 1);
        axes_equal = false;
        line_colors = {'r', 'g', 'b', 'c', 'm', 'y', 'w', 'r', 'g', 'b', 'c', 'm', 'w'};
        line_styles = {'-'; 'none'};
        marker_styles = {'none'; 'o'};
        title_str = 'Testing';
        add_str = '';
        add = [];
        title = []; % title graphic objects.
        font_size_title = 12;
        font_size_add = 10;
        n_lines = 0;
        n_markers = 0;
    end
    
    methods
        function obj = BlackGraph(n_parent, n_x_data, n_y_data, varargin)
            obj.parent = n_parent;
            if isnumeric(n_x_data)
                obj.x_data = {n_x_data};
                obj.y_data = {n_y_data};
                obj.n_lines = 1;
            else
                obj.x_data = n_x_data;
                obj.y_data = n_y_data;
                obj.n_lines = length(n_x_data);
            end
            if ~isempty(varargin)
                while length(varargin) >= 2
                    prop_name = varargin{1};
                    prop_value = varargin{2};
                    obj.(prop_name) = prop_value;
                    if length(varargin) > 2
                        varargin = varargin(3:end);
                    else
                        varargin = [];
                    end
                end
            end
            obj.axes = axes('parent', obj.parent);
            obj.axes.Color = 'k';
            hold(obj.axes, 'on');
            grid(obj.axes, 'on');
            obj.axes.GridColor = [.5 .5 .5];
            obj.axes.GridAlpha = 1.0;
            obj.axes.XAxis.Visible = 'off';
            obj.axes.YAxis.Visible = 'off';
            obj.axes.Position = obj.position;
            if obj.axes_equal
                axis(obj.axes, 'equal');
                %obj.axes.PlotBoxAspectRatio = [1 1 1]
            end
            for ii = 1:12
                obj.lines{ii} = line('parent', obj.axes);
            end
            for ii = 1:12
                obj.markers{ii} = line('parent', obj.axes);
            end
            obj.title = text('parent', obj.axes, 'units', 'normalized', ...
                'position', [0.5 0.9], 'Color', [1 1 1], 'String', obj.title_str, ...
                'FontName', 'FixedWidth', 'HorizontalAlignment', 'center');
            obj.add = text('parent', obj.axes, 'units', 'normalized', ...
                'position', [0.5 0.05], 'Color', [1 1 1], 'String', obj.add_str, ...
                'FontName', 'FixedWidth', 'HorizontalAlignment', 'center');
            obj.update_lines();
        end
        
        function set_add_str(obj, n_add_str)
            obj.add_str = n_add_str;
            obj.add.String = obj.add_str;
        end
        
        function add_line(obj, x, y)
            obj.n_lines = obj.n_lines + 1;
            obj.x_data{obj.n_lines} = x;
            obj.y_data{obj.n_lines} = y;
            obj.update_lines();
        end
        
        function add_marker(obj, x, y)
            obj.n_markers = obj.n_markers + 1;
            obj.mx_data{obj.n_markers} = x;
            obj.my_data{obj.n_markers} = y;
            obj.update_lines();
        end
        
        function reset_lines(obj)
            obj.x_data = {};
            obj.y_data = {};
            obj.mx_data = {};
            obj.my_data = {};
            obj.n_lines = 0;
            obj.n_markers = 0;
            obj.update_lines();
        end
        
        function remove_lines(obj, n_rm)
            obj.x_data(n_rm) = [];
            obj.y_data(n_rm) = [];
            obj.n_lines = obj.n_lines - 1;
            obj.update_lines();
        end
        
        function update_lines(obj)
            for ii = 1:length(obj.lines)
                if length(obj.x_data) >= ii
                    obj.lines{ii}.XData = obj.x_data{ii};
                    obj.lines{ii}.YData = obj.y_data{ii};
                else
                    obj.lines{ii}.XData = [];
                    obj.lines{ii}.YData = [];
                end
                obj.lines{ii}.LineStyle = obj.line_styles{1};
                obj.lines{ii}.Marker = obj.marker_styles{1};
                obj.lines{ii}.Color = obj.line_colors{ii};
            end
            for ii = 1:length(obj.markers)
                if length(obj.mx_data) >= ii
                    obj.markers{ii}.XData = obj.mx_data{ii};
                    obj.markers{ii}.YData = obj.my_data{ii};
                else
                    obj.markers{ii}.XData = [];
                    obj.markers{ii}.YData = [];
                end
                obj.markers{ii}.LineStyle = obj.line_styles{2};
                obj.markers{ii}.Marker = obj.marker_styles{2};
                obj.markers{ii}.Color = obj.line_colors{ii};
            end
        end
        
    end
    
    
end