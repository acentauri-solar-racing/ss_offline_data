function [v, s, E_bat] = simulateResponse(iniCond, par, controls_vec, route, options)
%SIMULATERESPONSE Summary of this function goes here
%   Detailed explanation goes here

    steps = options.steps;
    h = options.h;
    
    s = zeros(1,steps);                 % position vector
    v = zeros(1,steps);                 % velocity vector
    E_bat = zeros(1,steps);             % state of charge vector
    
    s(1) = iniCond.s_0;
    v(1) = iniCond.v_0;
    E_bat(1) = iniCond.E_bat_0;
    
    states = [v(1), E_bat(1)];
    controls = controls_vec(1,:);

    for i=1:steps-1
        variables = getVariablesThun(route, s(i));
        % E_bat(i+1) = E_bat(i) + h * dE_bat_rhs(par, states, controls, variables);
        v(i+1) = v(i) + h * dv_rhs(par, states, controls, variables);
        if v(i+1) < 0 || isinf(v(i+1))
            v(i+1) = 0;
        end
        s(i+1) = s(i) + h * v(i);
        states = [v(i+1), E_bat(i+1)];
        controls = controls_vec(i+1,:);
    end
    
    v(isnan(v)) = 0;
    s(isnan(s)) = 0;

end

