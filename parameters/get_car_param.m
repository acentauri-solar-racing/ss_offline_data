% This function returns the car parameters in the par struct
% Created by: Tony Ngo, July 2023
% Modified by: Giacomo Mastroddi, August 2023
%
% Update of parameters is shown in
% https://docs.google.com/spreadsheets/d/1VM5SzLikoJzH0g0JZaDFPCyxnKqB7-gmFB9RuCryzVE/edit

function par = get_car_param()
%% Longitudinal Vehicle Dynamics
par.rho_a = 1.17;           % [kg/m^3] Air density 
par.Af = 0.85;              % [m^2] Frontal area 
par.Cd = 0.09;              % [-] Aerodynamic drag coefficient
par.Cr = 0.003;             % [-] Roll friction coefficient
par.g = 9.81;               % [m/s^2] Gravitational acceleration
par.r_w = 0.2785;           % [m] Wheel radius
par.m_car = 188;            % [kg] Car mass
par.m_driver = 80;          % [kg] Driver mass
par.m_rot = load("tot_eq_rot_mass.mat").EqMassTot;   % [kg] Equivalent mass of rotating parts

par.m_tot = par.m_car + par.m_driver + par.m_rot;    % [kg] Total mass

%% Electric Motor
par.gamma_gb = 1;           % [-] Transmission gear box
par.e_mot = 0.97;           % [-] Motor efficiency
par.P_0 = 30;               % [W] Idle losses
par.P_el_max = 5000;        % [W] Maximal electric power
par.P_el_min = -5000;       % [W] Minimal electric power
par.T_mot_max = 45;         % [Nm] Maximal Torque
par.T_mot_min = -45;        % [Nm] Minimal Torque

%% Photvoltaic Module
par.A_PV = 4;               % [-] Solar panel area
par.eta_PV = 0.244;         % [-] Solar panel efficiency
par.lambda_PV = 0.0029;     % [1/K] Power loss coefficient
par.eta_wire = 0.98;        % [-] Wiring efficiency
par.eta_MPPT = 0.99;        % [-] MPPT efficiency
par.eta_mismatch = 0.98;    % [-] Mismatch efficiency
par.theta_STC = 298.15;     % [K] Standard Condition Temperature
par.G_0 = 1000;             % [W/m^2] Reference Global Irradiance
par.nu = -3.47;             % [-] Model coefficient
par.kappa = -0.0594;        % [s/m] Model coefficient

par.eta_PV_tot = par.eta_PV * par.eta_wire * par.eta_MPPT * par.eta_mismatch; %[-] Total efficiency

%% Battery Pack
par.U_bat_oc = 126;         % [V] Open circuit voltage
par.R_bat = 0.075;          % [Ohm] Internal Resistance
par.E_bat_max = 5200*3600;  % [W*s = J] Maximal energy capacity
par.U_bat_max = 147;        % [V] Max voltage
par.U_bat_min = 87.5;       % [V] Min voltage
par.I_bat_max = 120;        % [A] Max current (traction)
par.I_bat_min = -39.6;      % [A] Min current (regenerative)
par.P_bat_max = 15120;      % [W] Max power
par.P_bat_min = -4989.6;    % [W] Min power
par.SoC_max = 1;            % [-] Max SoC
par.SoC_min = 0.1;          % [-] Min safe SoC
par.eta_coul = 1;           % [-] Coulumbic efficiency

%% Route (regulations)
par.v_min = 60 / 3.6;       % [m/s] Min velocity

end