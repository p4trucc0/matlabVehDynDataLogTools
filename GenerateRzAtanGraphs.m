clear all
close all
clc

%% Patrucco, 2021
% Generate Rz, atan2(ay, ax) graphs for historical data.

OutImgFolder = 'C:\Users\Utente\Pictures\20210604\Rz_Atan2_3_sl';
mkdir(OutImgFolder);

% InputLogFolder = 'C:\Users\Utente\Documents\set_elaborazioni\20201231_Vscatola_dump\logs';
% InputLogFolder = 'C:\Users\Utente\Documents\set_elaborazioni\20201220_Vscatola_dump\logs';
InputLogFolder = 'C:\Users\Utente\Documents\set_elaborazioni\phone_acc';
% dirFolder = dir([InputLogFolder, filesep, '*.mat']);
dirFolder = dir([InputLogFolder, filesep, '*.txt']);


for ii = 1:length(dirFolder)
    FileName = dirFolder(ii).name;
    BaseName = [InputLogFolder, filesep, dirFolder(ii).name];
    [s_acc, s_gps, out_param] = load_gpsacc_log(BaseName);
    
    param_sigma = struct();
    param_sigma.rz_corner_threshold = 0.2;
    param_sigma.min_pts = 10;
    
    figure(1);
    plot(s_acc.rz, atan2(s_acc.ayg, s_acc.axg), 'r.');
    s = find_sigma_angle(s_acc.axg, s_acc.ayg, s_acc.rz, param_sigma);
    grid on;
    legend(['\sigma = ', num2str(s)]);
    xlabel('Rz [rad/s]');
    ylabel('atan2(a_{y}/a_{x})');
    title([FileName, ' - Gravity Calibrated']);
    out_fig_name_1 = [OutImgFolder, filesep, FileName(1:end-4), '_g.png'];
    print(out_fig_name_1, ['-d', 'png'], 1);
    close(1);
    
    figure(1);
    plot(s_acc.rz, atan2(s_acc.ay, s_acc.ax), 'r.');
    grid on;
    s = find_sigma_angle(s_acc.ax, s_acc.ay, s_acc.rz, param_sigma);
    legend(['\sigma = ', num2str(s)]);
    xlabel('Rz [rad/s]');
    ylabel('atan2(a_{y}/a_{x})');
    title([FileName, ' - Yaw Calibrated']);
    out_fig_name_1 = [OutImgFolder, filesep, FileName(1:end-4), '_c.png'];
    print(out_fig_name_1, ['-d', 'png'], 1);
    close(1);
    
    figure(1);
    plot(s_acc.ayg, s_acc.axg, 'r.');
    grid on; hold on;
    plot(s_acc.ay, s_acc.ax, 'b.');
    legend({'Gravity Calibrated', 'Yaw Calibrated'});
    xlabel('Rz [rad/s]');
    ylabel('atan2(a_{y}/a_{x})');
    title([FileName, ' - GG Plot']);
    out_fig_name_1 = [OutImgFolder, filesep, FileName(1:end-4), '_gg.png'];
    print(out_fig_name_1, ['-d', 'png'], 1);
    close(1);
    
end

