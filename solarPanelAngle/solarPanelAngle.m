%% setup
clc;
clearvars;
close all;

%% define day and position of interests
UTC = datetime("now");  % date and time of day of interest

Lat = 47.3667;  % [degrees]
Lon = -8.55;     % [degrees]
Alt = 0.4;      % [km]

%% calculate sun azimuth and elevation
[Az, El] = SolarAzEl( [UTC; UTC + minutes(30)], [Lat; Lat], [Lon; Lon], [Alt; Alt]);

% average of start and finish time
Az_avg = mean(Az);
El_avg = mean(El);
%El_avg = 60;
%Az_avg = -30;

Car_Front = Az_avg - 90;
Panel = El_avg - 90;

if Az_avg > 180
    Az_avg = Az_avg - 360;
end
if Car_Front > 180
    Car_Front = Car_Front - 360;
end

%% create plot objects

% define x, y, z axis
x_xaxis = [-1, 1];
y_xaxis = [ 0, 0];
z_xaxis = [ 0, 0];

x_yaxis = [ 0, 0];
y_yaxis = [-1, 1];
z_yaxis = [ 0, 0];

x_zaxis = [ 0, 0];
y_zaxis = [ 0, 0];
z_zaxis = [-0.2, 1];

narc = 10;

% create azimuthal arrow
vec_Az = linspace(0, Az_avg, narc);

x_az = 0.5 * cos(vec_Az * pi / 180);
y_az = - 0.5 * sin(vec_Az * pi / 180);
z_az = zeros(1,narc);

% create elevation arrow
vec_El = linspace(0, El_avg, narc);

x_el = 0.5 * cos(vec_El * pi / 180);
y_el = zeros(1,narc);
z_el = 0.5 * sin(vec_El * pi / 180);

x_elAz = x_el * cos(Az_avg * pi / 180) - y_el * sin(Az_avg * pi / 180);
y_elAz = - y_el * cos(Az_avg * pi / 180) - x_el * sin(Az_avg * pi / 180);
z_elAz = z_el;

% create Panel orientation
vec_Pan = linspace(0, Panel, narc);

x_Pan_ = - 0.5 * cos(vec_Pan * pi / 180);
y_Pan_ = zeros(1,narc);
z_Pan_ = - 0.5 * sin(vec_Pan * pi / 180);

x_Pan = x_Pan_ * cos(Az_avg * pi / 180) - y_Pan_ * sin(Az_avg * pi / 180);
y_Pan = - y_Pan_ * cos(Az_avg * pi / 180) - x_Pan_ * sin(Az_avg * pi / 180);
z_Pan = z_Pan_;

% create car front direction
vec_Car = linspace(0, Car_Front, narc);

x_car = 0.4 * cos(vec_Car * pi / 180);
y_car = - 0.4 * sin(vec_Car * pi / 180);
z_car = zeros(1,narc);

%% import car geometry
gm = importGeometry("car_cleaned.stl");
gm = scale(gm, 1/3000);
gm = rotate(gm, -Car_Front);

%% plot objects
lineW = 2;
sizeF = 13;

% start figure
fig1 = figure(1);

pdegplot(gm, "FaceAlpha", 0.8)
delete(findobj(gca,'type','Text')); 
delete(findobj(gca,'type','Quiver'));

hold on;
grid on;
box off;
axis off;

% coordinate system
plot3(x_xaxis, y_xaxis, z_xaxis, '-k', 'LineWidth', lineW);
plot3(x_yaxis, y_yaxis, z_yaxis, '-k', 'LineWidth', lineW);
plot3(x_zaxis, y_zaxis, z_zaxis, '-k', 'LineWidth', lineW);
text( 1.2,0,0, 'North', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')
text(-1.2,0,0, 'South', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')
text(0,-1.2,0, 'East', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')
text(0, 1.2,0, 'West', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')

% azimuth angle
% plot3(x_az(1:end-1),y_az(1:end-1),z_az(1:end-1), '-r', 'LineWidth', lineW)
% arrow([x_az(end-1), y_az(end-1), z_az(end-1)], [x_az(end), y_az(end), z_az(end)], 'Color', 'red', 'LineWidth', lineW);
% %text(x_az(narc/2) + 0.1, y_az(narc/2) + 0.1, z_az(narc/2), sprintf('Azimuth = %.1f°', Az_avg), 'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', sizeF)
% plot3([0, 2*x_az(end)], [0, 2*y_az(end)], [0, 2 * z_az(end)], 'r', 'LineWidth', lineW);

% car front angle
plot3(x_car(1:end-1),y_car(1:end-1),z_car(1:end-1), '-g', 'LineWidth', lineW)
arrow([x_car(end-1), y_car(end-1), z_car(end-1)], [x_car(end), y_car(end), z_car(end)], 'Color', 'green', 'LineWidth', lineW);
text(x_car(narc/2) + 0.1, y_car(narc/2) + 0.1, z_car(narc/2), sprintf('Car Front = %.1f°', abs(Car_Front)), 'Color', 'g', 'HorizontalAlignment', 'right', 'FontSize', sizeF)
plot3([0, 2*x_car(end)], [0, 2*y_car(end)], [0, 2 * z_car(end)], 'g','LineWidth', lineW);

% elevation angle
% plot3(x_elAz(1:end-1),y_elAz(1:end-1),z_elAz(1:end-1), '-y', 'LineWidth', lineW)
% arrow([x_elAz(end-1), y_elAz(end-1), z_elAz(end-1)], [x_elAz(end), y_elAz(end), z_elAz(end)], 'Color', 'yellow', 'LineWidth', lineW);
% %text(x_elAz(narc/2) + 0.1, y_elAz(narc/2) + 0.1, z_elAz(narc/2), sprintf('Elevation = %.1f°', El_avg), 'Color', 'y', 'HorizontalAlignment', 'center', 'FontSize', sizeF)
% plot3([0, 3*x_elAz(end)], [0, 3*y_elAz(end)], [0, 3*z_elAz(end)], 'y');

% panel angle
plot3(x_Pan(1:end-1),y_Pan(1:end-1),z_Pan(1:end-1), '-b', 'LineWidth', lineW)
arrow([x_Pan(end-1), y_Pan(end-1), z_Pan(end-1)], [x_Pan(end), y_Pan(end), z_Pan(end)], 'Color', 'blue', 'LineWidth', lineW);
text(x_Pan(narc/2) + 0.1, y_Pan(narc/2) + 0.1, z_Pan(narc/2) + 0.2, sprintf('Panel Angle = %.1f°', abs(Panel)), 'Color', 'b', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', 'FontSize', sizeF)
plot3([0, 2*x_Pan(end)], [0, 2*y_Pan(end)], [0, 2 * z_Pan(end)], 'b', 'LineWidth', lineW);

zlim([0,1])
xlim([-1.4,1.4])
ylim([-1.4,1.4])
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'ztick',[])
set(gca,'zticklabel',[])

view(3);

ax = gca;

%% plot from top
figure;

pdegplot(gm, "FaceAlpha", 0.8)
delete(findobj(gca,'type','Text')); 
delete(findobj(gca,'type','Quiver'));

hold on;
grid on;
box on;
%axis off;

plot3(x_xaxis, y_xaxis, z_xaxis, '-k', 'LineWidth', lineW);
plot3(x_yaxis, y_yaxis, z_yaxis, '-k', 'LineWidth', lineW);
plot3(x_zaxis, y_zaxis, z_zaxis, '-k', 'LineWidth', lineW);
text( 1.2,0,0, 'North', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')
text(-1.2,0,0, 'South', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')
text(0,-1.2,0, 'East', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')
text(0, 1.2,0, 'West', 'FontSize', 1.2*sizeF, 'HorizontalAlignment','center')

% car front angle
plot3(x_car(1:end-1),y_car(1:end-1),z_car(1:end-1), '-g', 'LineWidth', lineW)
arrow([x_car(end-1), y_car(end-1), z_car(end-1)], [x_car(end), y_car(end), z_car(end)], 'Color', 'green', 'LineWidth', lineW);
plot3([0, 2*x_car(end)], [0, 2*y_car(end)], [0, 2 * z_car(end)], 'g','LineWidth', lineW);

if Car_Front > 0
    text(x_car(narc/2) + 0.1, y_car(narc/2) - 0.1, z_car(narc/2), sprintf('Car Front = %.1f°', abs(Car_Front)), 'Color', 'g', 'HorizontalAlignment', 'left', 'FontSize', sizeF)
else
    text(x_car(narc/2) + 0.1, y_car(narc/2) + 0.1, z_car(narc/2), sprintf('Car Front = %.1f°', abs(Car_Front)), 'Color', 'g', 'HorizontalAlignment', 'right', 'FontSize', sizeF)
end

xlim([-1.4,1.4])
ylim([-1.4,1.4])
%set(gca,'xtick',[])
set(gca,'xticklabel',[])
%set(gca,'ytick',[])
set(gca,'yticklabel',[])
%set(gca,'ztick',[])
set(gca,'zticklabel',[])

view(-90, 90)

%% plot from front
figure(3);

pdegplot(gm, "FaceAlpha", 0.8)
delete(findobj(gca,'type','Text')); 
delete(findobj(gca,'type','Quiver'));

hold on;
grid on;
box on;
%axis on;

plot3(x_xaxis, y_xaxis, z_xaxis, '-k', 'LineWidth', lineW);
plot3(x_yaxis, y_yaxis, z_yaxis, '-k', 'LineWidth', lineW);
plot3(x_zaxis, y_zaxis, z_zaxis, '-k', 'LineWidth', lineW);

% panel angle
plot3(x_Pan(1:end-1),y_Pan(1:end-1),z_Pan(1:end-1), '-b', 'LineWidth', lineW)
arrow([x_Pan(end-1), y_Pan(end-1), z_Pan(end-1)], [x_Pan(end), y_Pan(end), z_Pan(end)], 'Color', 'blue', 'LineWidth', lineW);
plot3([0, 2*x_Pan(end)], [0, 2*y_Pan(end)], [0, 2 * z_Pan(end)], 'b', 'LineWidth', lineW);
text(x_Pan(narc/2), y_Pan(narc/2), z_Pan(narc/2) + 0.5, sprintf('Panel Angle = %.1f°', abs(Panel)), 'Color', 'b', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', 'FontSize', sizeF)

ylim([-0.6,0.6])
zlim([0, 0.6])
%set(gca,'xtick',[])
set(gca,'xticklabel',[])
%set(gca,'ytick',[])
set(gca,'yticklabel',[])
%set(gca,'ztick',[])
set(gca,'zticklabel',[])

view(180-Az_avg, 0)

