% This function returns the car parameters in the par struct
% Created by: Tony Ngo, July 2023
% Modified by: Giacomo Mastroddi, August 2023
% Last updated: Flurin Solèr, 21.09.2023
%
% Update of parameters is shown in
% https://docs.google.com/spreadsheets/d/1VM5SzLikoJzH0g0JZaDFPCyxnKqB7-gmFB9RuCryzVE/edit

function par = get_car_param()
    % initialize parameters struct 
    par = struct;

    %% Initial conditions
    par.t_0 = get_machine_time_s();   % [s] machine time (REMEMBER TO ADD TIME IF YOU ARE IN THE NIGHT)
    par.s_0 = get_init_cumDistance();                         % initial position of the simulation 
    par.s_0 = 1000000;                         % initial position of the simulation 
    par.v_0 = get_init_v()/3.6;
    par.SoC_0 = get_init_soc();
      
    %% Longitudinal Vehicle Dynamics
    par.rho_a = 1.17;           % [kg/m^3] Air density 
    par.Af = 0.85;              % [m^2] Frontal area 
    par.Cd = 0.2171;              % [-] Aerodynamic drag coefficient (0.09)
    par.Cr = 0.00157;             % [-] Roll friction coefficient (0.003)
    par.g = 9.81;               % [m/s^2] Gravitational acceleration
    par.r_w = 0.2785;           % [m] Wheel radius
    
    par.m_car = 182;           % [kg] Car mass
    par.m_driver = 82;          % [kg] Driver mass
    par.m_rot = load("tot_eq_rot_mass.mat").EqMassTot;   % [kg] Equivalent mass of rotating parts
    par.m_tot = par.m_car + par.m_driver + par.m_rot;    % [kg] Total mass
    
    %% Electric Motor
    par.gamma_gb = 1;           % [-] Transmission gear box
    par.e_mot = 0.98;           % [-] Motor efficiency
    par.P_0 = 110;              % [W] Idle losses
    par.T_mot_max = 45;         % [Nm] Maximal Torque
    par.T_mot_min = -45;        % [Nm] Minimal Torque
    
    %% Photvoltaic Module
    par.A_PV = 4;               % [m^2] Solar panel area
    par.eta_PV = 0.244;         % [-] Solar panel efficiency
    par.eta_wire = 0.98;        % [-] Wiring efficiency
    par.eta_MPPT = 0.99;        % [-] MPPT efficiency
    par.eta_mismatch = 0.98;    % [-] Mismatch efficiency
    par.lambda_PV = 0.0029;     % [1/K] Power loss coefficient
    par.theta_STC = 25+273.15;  % [K] Standard Condition Temperature
    par.G_0 = 1000;             % [W/m^2] Reference Global Irradiance
    par.nu = -3.47;             % [-] Model coefficient
    par.kappa = -0.0594;        % [s/m] Model coefficient

    par.theta_NOCT = 50;            % [°C] Nominal Operation Cell Temp
    par.S = 80;                     % [mW/cm^2]
    
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
    par.eta_coul = 1;           % [-] Coulumbic efficiency
    
    %% Route (regulations)
    par.v_max = 120/3.6;        % [m/s] abs max velocity
    par.v_min = 50 / 3.6;       % [m/s] Min velocity

    %% DP
    par.s_step_DP = 10000;          % [m] do not change

    %% MPC 
    %% Discretization variables
    par.s_step = 100;                % [m]
    par.N = 500;                               % [-] Horizon length
    par.N_t = 60*15*2.5;                       % [s] Horizon length in seconds
    par.N_t = (par.N*par.s_step)/(50/3.6);     % [s] Horizon length in seconds
 
    % par.s_0 = get_initial_position();        % initial position of the simulation   
    par.s_tot =  par.s_0 + par.N*par.s_step;   % [m] simulated distance from initial position to final position
    par.s_final = 3000000;                     % [m] total distance (for parameters)

    %par.t_0 = 60*60*16+50*60;

    %% Model flag
    par.battery_model_flag = 0;     % 0 for simple, else for extended model
    
    %% Slack variable
    par.S1_weight = 1e-2;       % weight slack variable for battery target
    par.S2_weight = 1e4;        % weight slack variable for max velocity soft constraint
    par.slack_max = inf;
    
    %% Initialize constraints boundaries
    par.P_el_max = 2000;        % [W] Maximal electric power
    par.P_el_min = -2000;       % [W] Minimal electric power

    par.P_brake_max = 0;        % [W] Max brake power (always 0)
    par.P_brake_min = -5000;    % [W] Min brake power (no regen)

    par.SoC_max = 1.0001;       % [-] Max SoC
    par.SoC_min = 0.1;          % [-] Min safe SoC

    par.v_driver_max = 90/3.6;  % [m/s] max velocity by driver

    par.v_end_lb_percentage = 1;  % [-] set the final velocity constraint; these two values should be between [0.1;1]
    par.v_end_ub_percentage = 1;    % [-] v_max*par.v_end_lb_percentage < v(end) < v_max*par.v_end_ub_percentage    
    %% save format
    par.format = 'yyyymmdd_HHMMSS';
    par.filename = [datestr(datetime,par.format)+"_"+num2str(par.s_0)+"_"+num2str(par.s_tot)];

end