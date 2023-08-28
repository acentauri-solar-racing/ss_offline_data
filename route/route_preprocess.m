clearvars;
close all;

%% Import route data
csv_table = readtable("route.csv");

% Assign columns
route = struct();
longitude = csv_table.('longitude');
latitude = csv_table.('latitude');
altitude = csv_table.('altitude');
cum_distance = csv_table.('cumDistance');

pass_columns = csv_table(:, {'maxSpeed', 'surface'});

%% Smooth altitude
window = 1000; % Can be seen as an equivalent distance in meters
altitude_smoothed = smoothdata(altitude, 'gaussian', window, 'SamplePoints', cum_distance);

%% Calculate smooth inclination
inclination = zeros(length(altitude), 1);
inclination_smooth = zeros(length(altitude), 1);

for idx = 1:length(altitude)-1
    inclination(idx) = atan((altitude(idx+1) - altitude(idx)) / (cum_distance(idx+1) - cum_distance(idx))); %rad
    inclination_smooth(idx) = atan((altitude_smoothed(idx+1) - altitude_smoothed(idx)) / (cum_distance(idx+1) - cum_distance(idx))); %rad
end % for

%% Smooth inclination / gradient
inclination_smoothed = smoothdata(inclination, 'gaussian', window, 'SamplePoints', cum_distance);
inclination(isnan(inclination)) = 0; % Remove NaN

%% Calculate driving direction w.r.t north / theta
arclen = zeros(length(cum_distance), 1);
theta = zeros(length(cum_distance), 1);
lin_distance = zeros(length(cum_distance), 1);
wgs84 = wgs84Ellipsoid("m");

for idx = 1:length(cum_distance)-1
    [arclen(idx), theta(idx)] = distance("gc", latitude(idx), longitude(idx), latitude(idx+1), longitude(idx+1));
    lin_distance(idx) = distance(latitude(idx), longitude(idx), latitude(idx+1), longitude(idx+1), wgs84); % Equivalent to: deg2rad(arclen) * earthRadius
end % for

%% Plot

% figure
% plot(cum_distance, inclination, 'r', 'DisplayName', 'incl')
% hold on
% plot(cum_distance, inclination_smoothed, 'b', 'DisplayName', 'smoothed')
% plot(cum_distance, inclination_smooth, 'g', 'DisplayName', 'smooth')
% legend()

%% Save csv file
