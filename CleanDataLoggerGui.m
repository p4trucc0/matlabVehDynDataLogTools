function CleanDataLoggerGui()
%% Patrucco, 2020
% Simple GUI to add to a webcam some gauges and buttons to handle
% calibration phases. Everything that should be configured is handled
% through constants into the code rather than through buttons and active
% interfaces, to keep speed up.

COM_PORT = 'COM6';
HORIZONTAL_PANEL_SEP = 1/3;
VERTICAL_PANEL_SEP = 2/3;
VERTICAL_SEPARATION = false;
BUTTON_FONTSIZE = 16;
CAMERA_ID = 2;
CAMERA_DT = .1; % 10 FPS
CAMERA_ROTATION = 0;
CAMERA_RESOLUTION = '320x240';
ZERO_CALIBRATION_POINTS = 100; % 5 sec @ 20Hz
ANG_CALIBRATION_POINTS = 200; % 10 sec @ 20Hz   

MainFigure = figure();
if VERTICAL_SEPARATION
    UpperPanel = uipanel('Parent', MainFigure, 'Units','norm', 'Position', [0 HORIZONTAL_PANEL_SEP 1 (1-HORIZONTAL_PANEL_SEP)], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerPanel = uipanel('Parent', MainFigure, 'Units','norm', 'Position', [0 0 1 HORIZONTAL_PANEL_SEP], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerLeftPanel = uipanel('Parent', LowerPanel, 'Units','norm', 'Position', [0 0 1/3 1], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerCenterPanel = uipanel('Parent', LowerPanel, 'Units','norm', 'Position', [1/3 0 1/3 1], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerRightPanel = uipanel('Parent', LowerPanel, 'Units','norm', 'Position', [2/3 0 1/3 1], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
else
    UpperPanel = uipanel('Parent', MainFigure, 'Units','norm', 'Position', [0 0 VERTICAL_PANEL_SEP 1], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerPanel = uipanel('Parent', MainFigure, 'Units','norm', 'Position', [VERTICAL_PANEL_SEP 0 (1-VERTICAL_PANEL_SEP) 1], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerLeftPanel = uipanel('Parent', LowerPanel, 'Units','norm', 'Position', [0 (2/3) 1 1/3], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerCenterPanel = uipanel('Parent', LowerPanel, 'Units','norm', 'Position', [0 (1/3) 1 1/3], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
    LowerRightPanel = uipanel('Parent', LowerPanel, 'Units','norm', 'Position', [0 0 1 1/3], ...
        'BackgroundColor', [0 0 0], 'BorderType', 'none');
end

Tacho = TachoObj(LowerLeftPanel, 0, 250, 130, 'km/h', 6);
Gg = GGObj(LowerCenterPanel, [0 0 1 1], 100);

% Buttons
CalibrateZeroBtn = uicontrol('Parent', LowerRightPanel, 'Style','pushbutton', ...
    'FontSize',BUTTON_FONTSIZE, 'String','Zero Calibration','Units','norm','Position',[0 (2/3) 1 (1/3)], 'BackgroundColor',[.8 .8 .8], ...
    'Callback', @CalibrateZeroFcn);
CalibrateAngBtn = uicontrol('Parent', LowerRightPanel, 'Style','pushbutton', ...
    'FontSize',BUTTON_FONTSIZE, 'String','Acc/Brake Calibration','Units','norm','Position',[0 (1/3) 1 (1/3)], 'BackgroundColor',[.8 .8 .8], ...
    'Callback', @CalibrateAngFcn);
RecordBtn = uicontrol('Parent', LowerRightPanel, 'Style','pushbutton', ...
    'FontSize',BUTTON_FONTSIZE, 'String','Record','Units','norm','Position',[0 (0/3) 1 (1/3)], 'BackgroundColor',[.8 .8 .8], ...
    'Callback', @RecordFcn);


DL = CalibratingDataLogger(COM_PORT); 
DL.initialize();
addlistener(DL, 'zeroCalibrationSuccess', @zeroCalibrationSuccessFcn);
addlistener(DL, 'angCalibrationSuccess', @angCalibrationSuccessFcn);
addlistener(DL, 'angCalibrationFail', @angCalibrationFailFcn);
addlistener(DL, 'newAccDataAvailable', @newAccDataAvailableFcn);
addlistener(DL, 'newSpeedAvailable', @newSpeedAvailableFcn);

cam = webcam(CAMERA_ID);
cam.Resolution = CAMERA_RESOLUTION;
tw = TimedWebcam(cam, CAMERA_DT);
tw.rotation = CAMERA_ROTATION;
addlistener(tw, 'newSnapshotAvailable', @newFrame);
Ax = axes('Parent',UpperPanel, 'Position',[0 0 1 1]);

set(MainFigure, 'DeleteFcn', @WindowDeleteFcn);

    function RecordFcn(obj, event)
        if ~DL.mat_log
            DL.startFastOnTrigger();
            set(RecordBtn, 'BackGroundColor', [1 .8 .8]);
        else
            DL.stopFastOnTrigger();
            set(RecordBtn, 'BackGroundColor', [.8 .8 .8]);
        end
    end

    function CalibrateZeroFcn(obj, event)
        DL.triggerZeroCalibration(ZERO_CALIBRATION_POINTS);
    end

    function CalibrateAngFcn(obj, event)
        DL.triggerAngCalibration(ANG_CALIBRATION_POINTS);
    end

    function zeroCalibrationSuccessFcn(obj, event)
        set(CalibrateZeroBtn, 'BackGroundColor', [.8 1 .8]);
    end

    function angCalibrationSuccessFcn(obj, event)
        set(CalibrateAngBtn, 'BackGroundColor', [.8 1 .8]);
    end

    function angCalibrationFailFcn(obj, event)
        set(CalibrateAngBtn, 'BackGroundColor', [1 .8 .8]);
    end

    function newAccDataAvailableFcn(obj, event)
        Gg.updateRedraw(event.Data.ax/9.81, event.Data.ay/9.81);
    end

    function newSpeedAvailableFcn(obj, event)
        if ~isnan(event.Data)
            Tacho.updateVal(event.Data);
        else
            Tacho.updateVal(0.0);
        end
    end

    function newFrame(obj, event)
        img_width = size(event.Data, 2);
        img_height = size(event.Data, 1);
        UpperPanel.Units = 'pixels';
        axp_width = UpperPanel.Position(3);
        axp_height = UpperPanel.Position(4);
        AR_img = img_width / img_height;
        AR_axp = axp_width / axp_height;
        AR_rat = [axp_width/img_width axp_height/img_height];
        if AR_rat(1) < AR_rat(2)
            w = axp_width;
            h = axp_width / AR_img;
        else
            h = axp_height;
            w = axp_height * AR_img;
        end
        posv = [(axp_width - w)/2 (axp_height - h)/2 w h];
        Ax.Units = 'pixels';
        set(Ax, 'Position', posv);
        image(Ax, event.Data);
        UpperPanel.Units = 'normalized';
        Ax.Units = 'normalized';
    end

    function WindowDeleteFcn(obj, event)
        stop(tw.timer);
        DL.stop();
    end

end











