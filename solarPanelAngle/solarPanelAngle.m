%% setup
clc;
clearvars;
close all;

%% define day and position of interests
UTC = datetime("now");  % date and time of day of interest

Lat = 47.3667;  % [degrees]
Lon = -8.55;     % [degrees]
Alt = 0.4;      % [km]

%% calculate sun azimuth and elevation
time_vec = [UTC; UTC + minutes(30)];

[Az, El] = SolarAzEl( time_vec, [Lat; Lat], [Lon; Lon], [Alt; Alt]);

% average of start and finish time
Az_avg = mean(Az);
El_avg = mean(El);

%% plot angle
plotPanelAngle(Az_avg, El_avg, time_vec);
