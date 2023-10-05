clearvars;
close all;

%% Open the file browser dialog
[file_name, path_name] = uigetfile('.geojson', 'Choose the geojson file');

% Check if a file was selected
if isequal(file_name, 0) || isequal(path_name, 0)
    disp('No file selected.');
else
    % Display its full path
    full_path = fullfile(path_name, file_name);
    disp(['Selected File: ' full_path]);
end

%% Extract the relevant information
[longitude, latitude, altitude, cum_distance, max_speed] = load_way_points_modified(full_path);

%% Smooth altitude
window = 1000; % Can be seen as an equivalent distance in meters
altitude_smoothed = smoothdata(altitude, 'gaussian', window, 'SamplePoints', cum_distance);

%% Calculate smooth inclination
alt_length = length(altitude);
inclination = zeros(alt_length, 1);
inclination_smooth = zeros(alt_length, 1);

for idx = 1:alt_length-1
    inclination(idx) = atan((altitude(idx+1) - altitude(idx)) / (cum_distance(idx+1) - cum_distance(idx))); %rad
    inclination_smooth(idx) = atan((altitude_smoothed(idx+1) - altitude_smoothed(idx)) / (cum_distance(idx+1) - cum_distance(idx))); %rad
end

inclination(isnan(inclination)) = 0; % Remove NaN

%% Smooth inclination / gradient
inclination_smoothed = smoothdata(inclination, 'gaussian', window, 'SamplePoints', cum_distance);

%% Calculate driving direction w.r.t north / theta
cum_dist_length = length(cum_distance);
arclen = zeros(cum_dist_length, 1);
theta = zeros(cum_dist_length, 1);
lin_distance = zeros(cum_dist_length, 1);

% Create a World Geodetic System of 1984 (WGS84) reference ellipsoid in meters (https://ch.mathworks.com/help/map/ref/distance.html)
wgs84 = wgs84Ellipsoid("m");

for idx = 1:cum_dist_length-1
    [arclen(idx), theta(idx)] = distance("gc", latitude(idx), longitude(idx), latitude(idx+1), longitude(idx+1));
    lin_distance(idx) = distance(latitude(idx), longitude(idx), latitude(idx+1), longitude(idx+1), wgs84); % Equivalent to: deg2rad(arclen) * earthRadius
end

%% Calculate the time travelled between current point and the next at max speed
timeAtMaxSpeed = lin_distance ./ max_speed * 3.6; % Convert into m/s

%% Create the table
route_table = struct();

% Populate the structure
route_table.longitude = longitude;
route_table.latitude = latitude;
route_table.altitude = altitude;
route_table.altitudeSmoothed = altitude_smoothed;
route_table.inclination = inclination;
route_table.inclinationSmooth = inclination_smooth;
route_table.inclinationSmoothed = inclination_smoothed;
route_table.distance = lin_distance;
route_table.cumDistance = cum_distance;
route_table.maxSpeed = max_speed;
route_table.theta = theta;
route_table.timeAtMaxSpeed = timeAtMaxSpeed;

%% Save csv file
[save_file, save_path] = uiputfile('*.csv', 'Save Preprocessed Route As');
if ~isequal(save_file, 0) && ~isequal(save_path, 0)
    writetable(struct2table(route_table), fullfile(save_path, save_file));
end
