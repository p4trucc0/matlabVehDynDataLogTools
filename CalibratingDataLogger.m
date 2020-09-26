classdef CalibratingDataLogger < SerialDataLogger
    
    properties
        zero_cal_buffer = [];
        ang_cal_buffer = [];
        m_tozero = eye(3);
        m_toang = eye(3);
        wdog_acc = [];
        pt_counter = 0;
        acc_data = struct('Time', [], 'ax', [], 'ay', [], 'az', [], 'rx', [], 'ry', [], 'rz', []);
        pt_limit = 0;
        calibrating_zero = false;
        calibrating_ang = false;
        is_zero_cal = false;
        is_ang_cal = false;
    end
    
    methods
        
        function obj = CalibratingDataLogger(n_com)
            obj = obj@SerialDataLogger(n_com);
            obj.wdog_acc = addlistener(obj, 'newImuDataAvailable', @obj.accWatchDog);
        end
        
        function accWatchDog(obj, ob1, ev1)
            M = obj.m_toang*obj.m_tozero;
            av = [ev1.Data.ax; ev1.Data.ay; ev1.Data.az];
            rv = [ev1.Data.rx; ev1.Data.ry; ev1.Data.rz];
            %if (~obj.calibrating_zero) && (~obj.calibrating_ang)
            av1 = M*av;
            rv1 = M*rv;
            obj.acc_data.Time = ev1.Data.Time;
            obj.acc_data.ax = av1(1);
            obj.acc_data.ay = av1(2);
            obj.acc_data.az = av1(3);
            obj.acc_data.rx = rv1(1);
            obj.acc_data.ry = rv1(2);
            obj.acc_data.rz = rv1(3);
            notify(obj, 'newAccDataAvailable', EventWithData(obj.acc_data));
            %else
            if obj.calibrating_zero
                obj.zero_cal_buffer = [obj.zero_cal_buffer, av];
                if obj.pt_counter >= obj.pt_limit
                    obj.findZeroMatrix();
                    obj.calibrating_zero = false;
                    obj.is_zero_cal = true;
                    notify(obj, 'zeroCalibrationSuccess', EventWithData(obj.m_tozero));
                else
                    obj.pt_counter = obj.pt_counter + 1;
                end
            end
            if obj.calibrating_ang
                av0 = obj.m_tozero*av;
                obj.ang_cal_buffer = [obj.ang_cal_buffer, av0(1:2)];
                if obj.pt_counter >= obj.pt_limit
                    s0 = accbrake_yaw_calibration((1/9.81)*obj.ang_cal_buffer(1, :), (1/9.81)*obj.ang_cal_buffer(2, :))
                    if ~isnan(s0)
                    obj.m_toang = jacobian_matrix(0, 0, -s0);
                    notify(obj, 'angCalibrationSuccess', EventWithData(obj.m_toang));
                    obj.is_ang_cal = true;
                    else
                        notify(obj, 'angCalibrationFail', EventWithData(obj.m_toang));
                        obj.is_ang_cal = false;
                    end
                    obj.calibrating_ang = false;
                else
                    obj.pt_counter = obj.pt_counter + 1;
                end
            end
            %end
        end
        
        function findZeroMatrix(obj)
            vcal = mean(obj.zero_cal_buffer, 2);
            vnrm = vcal./norm(vcal);
            [r, b] = find_zero_cal_angles(vnrm);
            obj.m_tozero = jacobian_matrix(r, b, 0);
        end
        
        function triggerZeroCalibration(obj, n_pts)
            obj.pt_limit = n_pts;
            obj.pt_counter = 0;
            obj.zero_cal_buffer = [];
            obj.calibrating_zero = true;
        end
        
        function triggerAngCalibration(obj, n_pts)
            obj.pt_limit = n_pts;
            obj.pt_counter = 0;
            obj.ang_cal_buffer = [];
            obj.calibrating_ang = true;
        end
        
    end
    
    events
        newAccDataAvailable;
        zeroCalibrationSuccess;
        angCalibrationSuccess;
        angCalibrationFail;
    end
    
end