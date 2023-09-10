v_0 = 55 / 3.6;         % [m/s] initial velocity
E_bat_0 = 1;            % [W] initial battery state of charge
s_0 = 0;                % [m] initial position
t_0 = 0;                % [s] initial time
P_mot_el_0 = 1100;      % [W] initial motor power
P_brake_0 = 0;          % [W] initial brake power

h = 1;                  % [s] timestep
time = 500;             % [s] simulation time

steps = time/h;         % [-] number of steps

t = linspace(t_0, time, steps);     % time vector
s = zeros(1,steps);                 % position vector
v = zeros(1,steps);                 % velocity vector
E_bat = ones(1,steps);              % state of charge vector

P_mot_el = zeros(1,steps);
P_brake = zeros(1,steps);

s(1) = s_0;
E_bat(1) = E_bat_0;
P_mot_el(1:100) = P_mot_el_0;
P_brake(1) = P_brake_0;

controls = [P_mot_el_0, P_brake_0];

par = get_car_param();
variables = zeros(0,5);
variables(1) = 1 /180 * pi;       % [rad] road inclination
variables(2) = 0;       % NOT NEEDED irradiation
variables(3) = 0;       % front wind velocity
variables(4) = 0;       % side wind velocity
variables(5) = 273;     % NOT NEEDED ambient temperature

%% get steady state
dv = @(states) dv_rhs(par, states, controls, variables);

[out, fval] = fsolve(dv, [v_0, 0]);

v_0 = out(1);
v(1) = v_0;
states = [v_0, E_bat_0];


%% solve time response

for i=1:steps-1
    % E_bat(i+1) = E_bat(i) + h * dE_bat_rhs(par, states, controls, variables);
    v(i+1) = v(i) + h * dv_rhs(par, states, controls, variables);
    if v(i+1) < 0
        v(i+1) = 0;
    end
    s(i+1) = s(i) + h * v(i);
    states = [v(i+1), E_bat(i+1)];
    controls = [P_mot_el(i+1), P_brake(i+1)];
end

%% plot

figure
hold on
plot(v/max(v))
plot(P_mot_el/max(P_mot_el))

v(1) * 3.6
max(s)