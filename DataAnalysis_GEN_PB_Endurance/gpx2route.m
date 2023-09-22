function route = gpx2route(fileName, doPlot)
    
    gpxRoute = readstruct(fileName);
    
    dim = size(gpxRoute.trk.trkseg.trkpt);
    route.Latitude = zeros(dim);
    route.Longitude = zeros(dim);
    route.Elevation = zeros(dim);
    %route.d = zeros(dim);
    
    route.Geometry = 'point';
    route.Metadata.FeatureType = 'waypoint';
    
    for i = 1:dim(2)
        route.Latitude(i) = gpxRoute.trk.trkseg.trkpt(i).latAttribute;
        route.Longitude(i) = gpxRoute.trk.trkseg.trkpt(i).lonAttribute;
        route.Elevation(i) = gpxRoute.trk.trkseg.trkpt(i).ele;
        %route.d(i) = gpxRoute.trk.trkseg.trkpt(i).extensions.swisstopo_waypoint_meters_into_tour;
    end
    
    wgs84 = wgs84Ellipsoid;
    route.Distance = distance(route.Latitude(1:end-1), route.Longitude(1:end-1), route.Latitude(2:end), route.Longitude(2:end), wgs84);
    
    route.cmlDistance = zeros(dim);
    route.alpha = zeros(dim);
    for i = 2:dim(2)
        route.cmlDistance(i) = sum(route.Distance(1:i-1));
        route.alpha(i-1) = atan(( route.Elevation(i) - route.Elevation(i-1) ) / route.Distance(i-1) );
    end
    keep_values = [1, min(1,ceil(route.Distance))];
    
    route.Latitude = route.Latitude(keep_values ~= 0);
    route.Longitude = route.Longitude(keep_values ~= 0);
    route.Elevation = route.Elevation(keep_values ~= 0);
    route.Distance = route.Distance(keep_values(2:end) ~= 0);
    route.cmlDistance = route.cmlDistance(keep_values ~= 0);
    route.alpha = route.alpha(keep_values(2:end) ~= 0);
    
    % because route is a closed circle
    route.alpha = [route.alpha(end), route.alpha];
    
    %% display on map

    if doPlot
        webmap('openstreetmap')
        wmline(geopoint(route), 'Color', 'red')
    end
    %% plot elevation
    if doPlot
        figure
        plot(route.cmlDistance, route.Elevation)
    end

end