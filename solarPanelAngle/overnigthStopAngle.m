%% setup
clc;
clearvars;
close all;

%% define day and position of interests
% The values in this section need to be changed
%
% From this, the script calculates the optimal angle of the Solar Panel and
% the car parking direction.
% Lat, Lon and Alt need to be entered for the specific overnight stop
% 
% timeSteps is the time after which the car position needs to be adjusted
% timeDuration is the duration of interest, e.g. 6 hours into the night 
%   after the control overnight stop started

UTC = datetime("2023-10-27 05:40");  % date and time of day of interest

Lon = 135.9278501;  % [degrees]
Lat = -31.1198892;    % [degrees]
Alt = 0.15;      % [km]

timeSteps = 0.5;    % [hours]
timeDuration = 2;   % [hours]

%% calculate time vector and other things
UTC_end = UTC + hours(timeDuration);

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

% average of start and finish time, not needed for plot
Az_avg = mean(Az);
El_avg = mean(El);

plotPanelAngle(Az, El, UTC_vec);