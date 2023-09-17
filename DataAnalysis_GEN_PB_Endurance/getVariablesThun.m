function var = getVariablesThun(route, pos)
    
    currAlpha = interp1(route.cmlDistance, route.alpha, pos);
    
    var = zeros(5,0);
    
    var(1) = currAlpha;
    var(2) = 0;
    var(3) = 0;
    var(4) = 0;
    var(5) = 0;
end