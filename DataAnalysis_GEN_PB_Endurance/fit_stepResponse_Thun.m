%% setup
clc 
clearvars %-except route

%% start
% initialize initial conditions
iniCond.v_0 = 50 / 3.6;         % [m/s] initial velocity
iniCond.E_bat_0 = 1;            % [W] initial battery state of charge
iniCond.s_0 = 0;                % [m] initial position
iniCond.t_0 = 0;                % [s] initial time
iniCond.P_mot_el_0 = 0;         % [W] initial motor power
iniCond.P_brake_0 = 0;          % [W] initial brake power

% initialize solver options
options.h = 1;      % [s] timestep
time = 500;           % [s] simulation time
options.steps = time/options.h;    % [-] number of steps

t = linspace(iniCond.t_0, time, options.steps);     % time vector

% initialize car parameters
par = get_car_param();

% initialize controls vector
P_mot_el = par.P_0 * ones(1,options.steps);
P_brake = zeros(1,options.steps);

P_mot_el(1) = iniCond.P_mot_el_0;
P_brake(1) = iniCond.P_brake_0;

controls_vec = [transpose(P_mot_el), transpose(P_brake)];
controls = controls_vec(1,:);

%% get route
route = gpx2route("clockwise.xml", false);

%% get data from tests

bms_pack_voltage_current = readtable('./ss_offline_data/DataAnalysis_GEN_PB_Endurance/data/bms_pack_voltage_current.csv');
icu_heartbeat = readtable('./ss_offline_data/DataAnalysis_GEN_PB_Endurance/data/icu_heartbeat.csv');

%% plot measurement data
figure
hold on
title('Measurement Data from Thun (03.09.2023)')
yyaxis left
plot(datetime(bms_pack_voltage_current.timestamp, 'ConvertFrom', 'posixtime'), - bms_pack_voltage_current.voltage .* bms_pack_voltage_current.current / 1000000, 'DisplayName', 'Power');
ylim([-1000, 3000]);
ylabel('Electric Power / W')

yyaxis right
plot(datetime(icu_heartbeat.timestamp, 'ConvertFrom', 'posixtime'), icu_heartbeat.speed, 'DisplayName', 'speed');
ylim([-10, 30])
ylabel('car velocity / ms^1')

legend('Location','northeast')

%% get indices for start and end of coasting test

coastingEnd_dt = datetime('2023-09-03 18:19:10');
[i_Start_speed(1, 1), i_End_speed(1, 1), i_Start_power(1, 1), i_End_power(1, 1)] = getIndicesCoasting(coastingEnd_dt, icu_heartbeat, bms_pack_voltage_current);

coastingEnd_dt = datetime('2023-09-03 18:27:10');
[i_Start_speed(1, 2), i_End_speed(1, 2), i_Start_power(1, 2), i_End_power(1, 2)] = getIndicesCoasting(coastingEnd_dt, icu_heartbeat, bms_pack_voltage_current);

coastingEnd_dt = datetime('2023-09-03 18:43:00');
[i_Start_speed(2, 1), i_End_speed(2, 1), i_Start_power(2, 1), i_End_power(2, 1)] = getIndicesCoasting(coastingEnd_dt, icu_heartbeat, bms_pack_voltage_current);

coastingEnd_dt = datetime('2023-09-03 18:58:20');
[i_Start_speed(2, 2), i_End_speed(2, 2), i_Start_power(2, 2), i_End_power(2, 2)] = getIndicesCoasting(coastingEnd_dt, icu_heartbeat, bms_pack_voltage_current);


%% create vector measurement data
measurementVelocity = zeros(length(i_Start_speed(:,1)), options.steps);
for i = 1:length(i_Start_speed(:,1))
    measurementVelocity_interp = zeros(length(i_Start_speed(1,:)), options.steps);
    for j = 1:length(i_Start_speed(1,:))
        timeVec = icu_heartbeat.timestamp(i_Start_speed(i, j):i_End_speed(i, j)) - icu_heartbeat.timestamp(i_Start_speed(i, j));
        VelocityVec = icu_heartbeat.speed(i_Start_speed(i, j):i_End_speed(i, j));
        measurementVelocity_interp(j,:) = interp1(timeVec, VelocityVec, t);
    end
    measurementVelocity(i,:) = mean(measurementVelocity_interp);
end

measurementVelocity(isnan(measurementVelocity)) = 0;

%% find parameters
func = @(paramsToFind) functionToMinimize(paramsToFind, measurementVelocity, iniCond, par, controls_vec, route, options);

paramsInitial = [par.Cd, par.Cr];
paramsFound = fminsearch(func, paramsInitial);

par.Cd = paramsFound(1);
par.Cr = paramsFound(2);

%% solve time response clockwise
[v_1, s_1, E_bat_1] = simulateResponse(iniCond, par, controls_vec, route, options);
disp('Clockwise:')
fprintf('measured Distance: %.1fm \n', 715);
fprintf('simulated Distance: %.1fm \n\n', max(s_1));

%% solve time response counterclockwise
route = resetRoute(route, 725, true);

[v_2, s_2, E_bat_2] = simulateResponse(iniCond, par, controls_vec, route, options);
disp('Counterclockwise:')
fprintf('measured Distance: %.1fm \n', 2035);
fprintf('simulated Distance: %.1fm \n', max(s_2));

%% plot
figure 

set(groot,'defaultLineLineWidth',2.0) % make thicker lines

% subplot 1
subplot(2, 1, 1)
hold on
grid on
xlim([0 200]);
plot(icu_heartbeat.timestamp(i_Start_speed(1, 1):i_End_speed(1, 1)) - icu_heartbeat.timestamp(i_Start_speed(1, 1)), icu_heartbeat.speed(i_Start_speed(1, 1):i_End_speed(1, 1))/max(v_1), 'DisplayName', 'measured velocity, first run');
plot(icu_heartbeat.timestamp(i_Start_speed(1, 2):i_End_speed(1, 2)) - icu_heartbeat.timestamp(i_Start_speed(1, 2)), icu_heartbeat.speed(i_Start_speed(1, 2):i_End_speed(1, 2))/max(v_1), 'DisplayName', 'measured velocity, second run');
plot(t, v_1/max(v_1), 'DisplayName', 'simulated velocity')
%plot(t, measurementVelocity(1, :)/max(v_1), '--g', 'DisplayName', 'interp' )
%plot(P_mot_el/max(P_mot_el))

title('step response: Clockwise')
ylabel('normalized velocity');
xlabel('time / s');

ax = gca;
colors = ['#0072BD'; '#4DBEEE'; '#A2142F'];
colororder(colors)
legend('Location', 'best');

% subplot 2
subplot(2, 1, 2)
hold on
grid on
xlim([0 300]);
plot(icu_heartbeat.timestamp(i_Start_speed(2, 1):i_End_speed(2, 1)) - icu_heartbeat.timestamp(i_Start_speed(2, 1)), icu_heartbeat.speed(i_Start_speed(2, 1):i_End_speed(2, 1))/max(v_1), 'DisplayName', 'measured velocity, first run');
plot(icu_heartbeat.timestamp(i_Start_speed(2, 2):i_End_speed(2, 2)) - icu_heartbeat.timestamp(i_Start_speed(2, 2)), icu_heartbeat.speed(i_Start_speed(2, 2):i_End_speed(2, 2))/max(v_1), 'DisplayName', 'measured velocity, second run');
plot(t, v_2/max(v_2), 'DisplayName', 'simulated velocity')
%plot(t, measurementVelocity(2, :)/max(v_2), '--g', 'DisplayName', 'interp' )
%plot(P_mot_el/max(P_mot_el))

title('step response: Counterclockwise')
ylabel('normalized velocity');
xlabel('time / s');

ax = gca;
colororder(colors)
legend('Location', 'best');

%% validate steady state
variables = [0 * pi/180, 0, 0, 0, 0];
controls = [500, 0];

dv = @(states) dv_rhs(par, states, controls, variables);
[ss_out1, ~ ] = fsolve(dv, [iniCond.v_0, 0]);

controls = [600, 0];
dv = @(states) dv_rhs(par, states, controls, variables);
[ss_out2, ~ ] = fsolve(dv, [iniCond.v_0, 0]);

ss_out = [ss_out1(1), ss_out2(1)];
clear ss_out1 ss_out2

disp(ss_out * 3.6)
