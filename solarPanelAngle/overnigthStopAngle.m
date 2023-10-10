%% setup
clc;
clearvars;
close all;

%% define day and position of interests
UTC = datetime("now");  % date and time of day of interest

Lat = 47.3667;  % [degrees]
Lon = -8.55;    % [degrees]
Alt = 0.4;      % [km]

timeSteps = 0.5;% [hours]

%% calculate time vector and other things
UTC_end = UTC + hours(6);

% calculate start time rounded to next half hour
vec = datevec( UTC );
v5  = vec(:,5)+vec(:,6)/60;
vec(:,5) = floor(v5/30)*30;
vec(:,6) = 0;
UTC_start = datetime(vec);

UTC_vec = UTC_start:hours(timeSteps):UTC_end;
UTC_vec(1) = UTC;

UTC_vec_middle = UTC_vec(1:end-1) + (UTC_vec(2:end) - UTC_vec(1:end-1))/2;
UTC_vec_middle = transpose(UTC_vec_middle);

%% calculate sun azimuth and elevation
[Az, El] = SolarAzEl( UTC_vec_middle, Lat, Lon, Alt);

% average of start and finish time
Az_avg = mean(Az);
El_avg = mean(El);

plotPanelAngle(Az_avg, El_avg);