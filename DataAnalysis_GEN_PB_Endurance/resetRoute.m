function route = resetRoute(route, newStart, changeDirection)

    newStart = mod(newStart, max(route.cmlDistance));
    
    if newStart ~= 0
        if newStart < 0
            newStart = max(route.cmlDistance) + newStart;
        end
    
        shift = find(route.cmlDistance > newStart);
        shift = - shift(1);

        route.Distance = circshift(route.Distance, shift);
        route.Elevation = circshift(route.Elevation, shift);
        route.Longitude = circshift(route.Longitude, shift);
        route.Latitude = circshift(route.Latitude, shift);
    end

    if changeDirection
        route.Distance = flip(route.Distance);
        route.Elevation = flip(route.Elevation);
        route.Longitude = flip(route.Longitude);
        route.Latitude = flip(route.Latitude);
    end

    for i = 2:length(route.cmlDistance)
        route.cmlDistance(i) = sum(route.Distance(1:i-1));
        route.alpha(i-1) = atan(( route.Elevation(i) - route.Elevation(i-1) ) / route.Distance(i-1) );
    end
end