clear all
close all
clc

x = linspace(0, 2*pi, 1000);
y = sin(x);
z = cos(x);

xx = {x; x};
yy = {y; z};

% Test BlackGraph
f1 = figure();
% b = BlackGraph(f1, xx, yy, 'title', 'prova', 'axes_equal', true);
g = GpsImuVisualizer(f1);