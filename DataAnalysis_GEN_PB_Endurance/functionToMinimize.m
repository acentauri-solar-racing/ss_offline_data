function out = functionToMinimize(paramsToFind, measurementVelocity, iniCond, par, controls_vec, route, options)
%FUNCTIONTOMINIMIZE Summary of this function goes here
%   Detailed explanation goes here

    % set Cd and Cr to the inputvalues of the function (fminsearch will try
    % to find values for paramToFind that minimize functionToMinimize)
    par.Cd = paramsToFind(1);
    par.Cr = paramsToFind(2);

    % simulate Response for Clockwise
    [v1, ~, ~] = simulateResponse(iniCond, par, controls_vec, route, options);
    route = resetRoute(route, 725, true);

    % simulate Response for Counterclockwise
    [v2, ~, ~] = simulateResponse(iniCond, par, controls_vec, route, options);

    % calculate square error of both
    squareError = (v1 - measurementVelocity(1,:)).^2 + (v2 - measurementVelocity(2,:)).^2;
    out = sum(squareError);
end

