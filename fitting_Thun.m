% Longitudinal Vehicle Dynamics at steady state in a flat terrain
% F_trac = F_aero + F_roll
% P_mot / v = 0.5 * rho_air * c_d * A_f * v^2 + m * g * c_r
%
% In order to calculate the air density with
% https://www.calctool.org/atmospheric-thermodynamics/air-density#what-is-the-density-of-air-considering-humidity
% this website was used
% https://www.ventusky.com/?p=46.81;7.94;7&l=temperature-2m
% Thun, 03.09.2023
% T_amb = 25°
% p_atm = 1025 hPa
% rh = 55 %

clear; close all; clc;

%% Parameters
rho_air = 1.18995; % kg/m^3
g = 9.81; % m/s^2
m = 250 + 80; % kg Rotational mass needs to be included!

%% Testing data
v = [55; 65] / 3.6; % m/s
P_mot = [500; 600]; % W

%% Matrix and vector for Linear Square
b = P_mot ./ v;
A = [0.5 * rho_air * v, m * g * ones([2,1])];

%% Linear Square
lin_results = lsqr(A,b);

fprintf('Aerodynamical friction c_d * A_f: %f\n', lin_results(1));
fprintf('Rolling friction c_r: %f\n', lin_results(2));





