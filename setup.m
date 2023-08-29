% Clear the command window, remove all variables from the workspace, and close all open figures
clc;
clearvars;
close all;

%% Run setup of the IDSC Matlab folder

% Get the path of the current script
pathThisScript = mfilename('fullpath');
pathMainFolder = fileparts(pathThisScript);

% Define the relative path to the 'setup.m' script within the IDSC Matlab folder
relativeSetupPath = '..\ss_idsc_matlab\setup.m';

% Construct the full path to the 'setup.m' script
fullSetupPath = fullfile(pathMainFolder, relativeSetupPath);

% Run the 'setup.m' script to set up the IDSC Matlab folder
run(fullSetupPath);

% Generate the list of all paths under the main folder
allPaths = split(genpath(pathMainFolder), pathsep());

% Add all individual paths to the MATLAB search path to make functions and scripts accessible
addpath(strjoin(allPaths, pathsep()));

%% Run this setup

% Get the path of the current script
pathThisSetupFile = mfilename('fullpath');
pathMainFolder = fileparts(pathThisSetupFile);

% Change the current working directory to the directory of this setup script
cd(pathMainFolder);

% Generate the list of all paths under the main folder
allPaths = split(genpath(pathMainFolder), pathsep());

% Add all individual paths to the MATLAB search path to ensure proper access
addpath(strjoin(allPaths, pathsep()));
