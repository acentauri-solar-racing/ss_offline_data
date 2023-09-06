% This file contains the equivalent rotational mass
% Created by: Giacomo Mastroddi, September 2023
clc; clear; close all;

par = get_car_param();

%% 
moiFront_csys = [1877632.37492222; 578770.98787205; 1474931.57386340]*1e-6; %kgm^2
moiRear_csys = [702202.23656886; 31595482.79875335; 30905824.24530662]*1e-6; %kgm^2

distCoGfront = [0.19; 516.93; 279.1]*1e-3; %m
distCoGrear = [2000; 5.33; 278.5]*1e-3; %m

massFront = 5.17; %kg
massRear = 7.7; %kg

moiFront = 0;
moiRear = 0;
for i = 1:3
    %distance to rotating axis i accounted with Steiner's law by taking the
    %norm of the other two axis components
    moiFront = moiFront + 2 * (moiFront_csys(i) - massFront * norm(distCoGfront(1:numel(distCoGfront) ~= i))^2);
    moiRear = moiRear + (moiRear_csys(i) - massRear * norm(distCoGrear(1:numel(distCoGrear) ~= i))^2);
end % for

moiTotal = moiFront + moiRear

rotMass = moiTotal / par.r_w^2;
fprintf(['Equivalent rotational mass: %3.2f kg'], rotMass)

%% Save data
% Get the full path of the currently executing script
scriptFullPath = mfilename('fullpath');

% Extract the directory part of the path
scriptDir = fileparts(scriptFullPath);

% Construct the full path for the data file
dataFileName = 'rotMass.mat';
dataFilePath = fullfile(scriptDir, dataFileName);

% Save the data to the specified path
% save(dataFilePath, 'rotMass');
