function [s, status] = accbrake_yaw_calibration(ax, ay)
% Patrucco, 2020
% ax and ay are equally-sized arrays containing histories of
% zero-calibrated accelerations in the horizontal plane.
% By suggesting the user to perform an acceleration + braking maneuver (in
% this order) one can create points which should be placed along the
% positive and then negative sides of the X axis. 
% Since based on atan2, some attention should be given to the case in which
% the "real" X axis of the car lies close to the Y axis of the
% accelerometer.

G_THRESHOLD = 0.2; % at least an acceleration of 2m/s2
MIN_PTS = 3;

i_ax_pos = find(ax > G_THRESHOLD);
i_ax_neg = find(ax < -G_THRESHOLD);
i_ay_pos = find(ay > G_THRESHOLD);
i_ay_neg = find(ay < -G_THRESHOLD);

if (length(i_ax_pos) + length(i_ax_neg)) < MIN_PTS
    if (length(i_ay_pos) + length(i_ay_neg)) < MIN_PTS
        status = 0;
        s = NaN;
        return;
    end
end

% Find a "first estimate" axis orientation
if (length(i_ax_pos) + length(i_ax_neg)) > (length(i_ay_pos) + length(i_ay_neg))
    if mean(i_ax_pos) > mean(i_ax_neg) % pre-rotate.
        i_acc = i_ax_neg;
        i_brk = i_ax_pos;
        ax = -ax;
        ay = -ay;
        pre_rot = pi;
    else
        i_acc = i_ax_pos;
        i_brk = i_ax_neg;
        pre_rot = 0;
    end
else
    if mean(i_ay_pos) < mean(i_ay_neg)
        i_acc = i_ay_pos;
        i_brk = i_ay_neg;
        ap = ax;
        ax = ay;
        ay = -ap;
        pre_rot = pi/2;
    else
        i_acc = i_ay_neg;
        i_brk = i_ay_pos;
        ap = ax;
        ax = -ay;
        ay = ap;
        pre_rot = -pi/2;
    end
end

% Now I should find an angle (hopefully lower than 90°) reasonably close to
% the now-X

ang_acc = mean(atan2(ay(i_acc), ax(i_acc)));
ang_brk_p = mean(atan2(ay(i_brk), ax(i_brk)));
if ang_brk_p < 0
    ang_brk = ang_brk_p + pi;
else
    ang_brk = ang_brk_p - pi;
end

status = 1;
s = mean([ang_acc, ang_brk]) + pre_rot;



