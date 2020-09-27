classdef TimedWebcam < handle
    % Patrucco, 2020
    % A webcam with a non-prioritized timer to generate snapshots
    
    properties
        camera = [];
        delta_t_s = [];
        timer = [];
        rotation = 0;
        Img = [];
    end
    
    methods
        
        function obj = TimedWebcam(n_camera, n_delta_t_s)
            obj.camera = n_camera;
            obj.delta_t_s = n_delta_t_s;
            obj.timer = timer('BusyMode', 'drop', 'ExecutionMode', 'fixedRate', 'Period', obj.delta_t_s, 'TimerFcn',@obj.timerFcnCB);
            start(obj.timer);
        end
        
        function timerFcnCB(obj, ob2, ev2)
            im = snapshot(obj.camera);
            if obj.rotation == 0
                obj.Img = im;
            else
                obj.Img = rotate_image(im, obj.rotation);
            end
            notify(obj, 'newSnapshotAvailable', EventWithData(obj.Img));
        end
        
        function delete(obj)
            stop(obj.timer);
        end
        
    end
    
    events
        newSnapshotAvailable;
    end
    
end