classdef SerialDataLogger < handle
    % Patrucco, 2020
    % Generic class to handle different Serial-Port instruments
    
    properties
        name_type = 'SerialDataLogger';
        serial_port = [];
        baud_rate = 115200;
        serial_obj = [];
        serial_open = false;
        log_raw = false;
        log_filename = '';
        log_file = [];
        imu_data = struct('Time', [], 'ax', [], 'ay', [], 'az', [], 'rx', [], 'ry', [], 'rz', []);
        gps_data = struct('Time', [], 'speed_kmh', [], 'latitude', [], 'longitude', [], 'heading', [], 'TimeGps', []);
        parse_fcn = @dlp_vscatola;
    end
    
    methods
        
        function obj = SerialDataLogger(n_serial_port)
            obj.serial_port = n_serial_port;
            obj.serial_obj = serial(obj.serial_port, 'BaudRate', obj.baud_rate);
            set(obj.serial_obj, 'BytesAvailableFcn', @obj.bytesAvailable);
        end
        
        function setSerialPort(obj, n_serial_port)
            if obj.serial_open
                obj.closeSerial();
                if ~obj.serial_open
                    can_change = true;
                end
            else
                can_change = true;
            end
            if can_change
                obj.serial_port = n_serial_port;
                obj.serial_obj = serial(obj.serial_port, 'BaudRate', obj.baud_rate);
                set(obj.serial_obj, 'BytesAvailableFcn', @obj.bytesAvailable);
            end
        end
        
        function status = openSerial(obj)
            try
                fopen(obj.serial_obj);
                if strcmp(obj.serial_obj.status, 'open')
                    obj.serial_open = true;
                    notify(obj, 'serialPortOpened');
                    status = 0;
                else
                    obj.serial_open = false;
                    notify(obj, 'serialPortOpenError');
                    status = 1;
                end
            catch
                obj.serial_open = false;
                notify(obj, 'serialPortOpenError');
                status = 1;
            end
        end
        
        function initialize(obj)
            try
                s = obj.openSerial();
                if s == 0
                    notify(obj, 'initializeSuccess');
                else
                    notify(obj, 'initializeFail');
                end
            catch
                notify(obj, 'initializeFail');
            end
        end
        
        function stop(obj)
            try
                s = obj.closeSerial();
                if s == 0
                    notify(obj, 'stopSuccess');
                else
                    notify(obj, 'stopFail');
                end
            catch
                notify(obj, 'stopFail');
            end
        end
        
        function status = closeSerial(obj)
            try
                fclose(obj.serial_obj);
                if strcmp(obj.serial_obj.status, 'closed')
                    obj.serial_open = false;
                    notify(obj, 'serialPortClosed');
                    status = 0;
                else
                    notify(obj, 'serialPortCloseError');
                    status = 1;
                end
            catch
                notify(obj, 'serialPortCloseError');
                status = 1;
            end
        end
        
        function v = getSpeed(obj)
            v = obj.gps_data.speed_kmh;
        end
        
        function gd = getGpsData(obj)
            gd = obj.gps_data;
        end
        
        function gd = getImuData(obj)
            gd = obj.imu_data;
        end
        
        function bytesAvailable(obj, ext_obj, ext_event)
            newReceived = fgetl(ext_obj);
            if obj.log_raw
                try 
                    obj.log_file = fopen(obj.log_filename, 'a');
                    fprintf(obj.log_file, ['[', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'), '] ', newReceived]);
                    fclose(obj.log_file);
                catch
                    notify(obj, 'logError');
                end
            end
            [nA, nG, n_imu, n_gps] = obj.parse_fcn(newReceived);
            if nA
                obj.imu_data = n_imu;
                notify(obj, 'newImuDataAvailable', EventWithData(n_imu));
            end
            if nG
                obj.gps_data = n_gps;
                notify(obj, 'newGpsDataAvailable', EventWithData(n_gps));
                notify(obj, 'newSpeedAvailable', EventWithData(n_gps.speed_kmh));
            end
        end
        
        % Logging functions
        function updateLogName(obj, varargin)
            if ~isempty(varargin)
                obj.log_filename = varargin{1};
            else
                obj.log_filename = ['DataLog_', datestr(now, 'yyyymmdd_HHMMSS'), '.txt'];
            end
            notify(obj, 'logNameUpdated', EventWithData(obj.log_filename));
        end
        
        function enableLog(obj, enabling)
            if enabling
                obj.log_raw = true;
                notify(obj, 'logEnabled');
            else
                obj.log_raw = false;
                notify(obj, 'logDisabled');
            end
        end
    
    end
    
    events
        serialPortOpened;
        serialPortOpenError;
        serialPortClosed;
        serialPortCloseError;
        logEnabled;
        logDisabled;
        logError;
        logNameUpdated;
        newImuDataAvailable;
        newGpsDataAvailable;
        newSpeedAvailable; 
        initializeSuccess;
        initializeFail;
        stopSuccess;
        stopFail;
    end
    
    
end