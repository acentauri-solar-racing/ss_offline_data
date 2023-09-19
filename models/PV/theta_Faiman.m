function [T_cell, T_module] = theta_module_Faiman(G, T_amb, v_wind, eta)
% Calculate the cell temperature using the Faiman model
%
% Input: global irradiance as double;
%        ambient temperature as double;
%        wind speed as double;
%        PV efficiency as double;
%
% Output: cell and module temperature in degrees

U0 = 25; % [W/m^2K]
U1 = 6.84; % [Ws/m^3K]
alpha = 0.9; 

T_module = G./(U0 + U1*v_wind) + T_amb;
T_cell = alpha*(1-eta)*G./(U0 + U1*v_wind) + T_amb;

end % fct