%% setup
clc;
clearvars;
close all;

%% define day and position of interests
UTC = datetime("now");  % date and time of day of interest

Lat = 47.3667;  % [degrees]
Lon = -8.55;    % [degrees]
Alt = 0.4;      % [km]

CarAngle = 130;   % [degrees] given from parking position

%% cacluclate time vector
UTC_vec = UTC:minutes(1):UTC+hours(0.5)-minutes(1);
UTC_vec = transpose(UTC_vec);

%% calculate sun azimuth and elevation
[Az, El] = SolarAzEl( UTC_vec, Lat, Lon, Alt);

Az_avg = mean(Az);
El_avg = mean(El);

%% convert to vector
% x-axis: North
% y_axis: West
% z-axis: up
[sun_x, sun_y, sun_z] = sph2cart(Az*pi/180, El*pi/180, 1);
SunDir = [sun_x, sun_y, sun_z];

% car angle to azimuth angle
PanelAz = CarAngle + 90;

%% maximize solar Irradiance 
func = @(PanelEl) objective(SunDir, PanelAz, PanelEl);

paramsInitial = El_avg; % [degrees]
paramsFound = fminsearch(func, paramsInitial);

min = objective(SunDir, PanelAz, paramsFound);


%% plot panal angle
plotPanelAngle(PanelAz, paramsFound);

%% optimize panel angle
function min = objective(SunDir, CarAngle, PanelEl)
    len = length(SunDir(:,1));
    % convert to vector
    CarAngle_vec = CarAngle * ones(len,1);
    PanelEl_vec = PanelEl * ones(len,1);
    r_vec = ones(len,1);

    % convert to cartesian vector
    [ PanelDir_x, PanelDir_y, PanelDir_z ] = sph2cart(CarAngle_vec*pi/180, PanelEl_vec*pi/180, r_vec);
    PanelDir = [ PanelDir_x, PanelDir_y, PanelDir_z ];
    
    % calculate dot product
    min = ones(len,1);
    for i=1:len
        min(i) = dot(SunDir(i,:), PanelDir(i,:));
    end

    % sum of square
    min = sum(min.*min);
    % to make into minimization problem
    min = - min; 
end

