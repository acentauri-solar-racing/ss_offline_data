function T_cell = theta_cell_NOCT(G, T_amb, v_wind, eta)
% Calculate the cell temperature using the NOCT model
%
% Input: global irradiance as double;
%        ambient temperature as double;
%        wind speed as double;
%        PV efficiency as double;
%
% Output: cell temperature in degrees

G_noct = 800; % [W/m^2]
T_noct = 45; % [°]
tau_alpha = 0.9;
T_amb_noct = 20; % [°]
h_NOCT = 20;
h = 40;

% Need to be experimentally determined
S = 9.5./(5.7 + 3.8*v_wind) * h_NOCT/h * (1 - eta./tau_alpha);

T_cell = T_amb + G./G_noct * (T_noct - T_amb_noct) * S;

end % fct