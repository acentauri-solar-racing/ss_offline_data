function [lon, lat, alt, dist, maxspeed] = loadWaypointsModified(file)
% Load geographical data, longitude, latitude and altitude from a geojson
% file and compute the distance travelled from the this data. Additionally,
% it extracts max speed information.
%
% Input: geojson file, contains machine readable geographical data,
% e.g. exported from 'brouter.de'
%
% Output: Longitude, latitude in degrees, altitude and distance in meters,
% and max speed in kilometer per hours

    data = jsondecode(fileread(file));

    if iscell(data.features(1).geometry.coordinates)
        lon = cellfun(@(x) x(1), data.features(1).geometry.coordinates);
        lat = cellfun(@(x) x(2), data.features(1).geometry.coordinates);
        alt = cellfun(@thirdElementOrNan, data.features(1).geometry.coordinates);
    else
        coords = data.features(1).geometry.coordinates;
        lon = coords(:,1);
        lat = coords(:,2);
        alt = coords(:,3);
    end

    dist = cumsum([0; haversine(lat / 180*pi, lon / 180*pi)]);
    maxspeed = nan(size(lon));

    % Parse maxspeed data
    messages = data.features(1).properties.messages;
    for i = 2:length(messages)
        cur_lon = str2double(messages{i}{1}) / 1e6;
        cur_lat = str2double(messages{i}{2}) / 1e6;
        tags = messages{i}{10};

        speed_match = regexp(tags, 'maxspeed=(\d+)', 'tokens');
        if ~isempty(speed_match)
            cur_speed = str2double(speed_match{1}{1});
        else
            continue;
        end

        % Find the index of the nearest coordinate to cur_lon and cur_lat
        [~, idx] = min(sqrt((lon - cur_lon).^2 + (lat - cur_lat).^2));
        maxspeed(idx) = cur_speed;
    end

    % Extend missing maxspeed values
    last_known_speed = nan;
    for i = 1:length(lon)
        if isnan(maxspeed(i))
            maxspeed(i) = last_known_speed;
        else
            last_known_speed = maxspeed(i);
        end
    end

    % Handle the case where the initial values are NaN (if any)
    for i = length(lon):-1:1
        if isnan(maxspeed(i))
            maxspeed(i) = last_known_speed;
        else
            last_known_speed = maxspeed(i);
        end
    end
end

function val = thirdElementOrNan(x)
    if length(x) == 3
        val = x(3);
    else
        val = nan;
    end
end

