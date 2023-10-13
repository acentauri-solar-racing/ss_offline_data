function fig1 = plotPanelAngle(Az_vec, El_vec, time)
    %PLOTPANELANGLE creates a uifigure with 3d, top and front view of the car
    %and the solar panel angle
    %   Az = [N x 1] vector of Azimuth angles of the solar position for
    %   different times
    %   El = [N x 1] vector of Elevation Angle of the solar position for
    %   different times
    %   time = [N+1 x 1] vector of start and end times of intervals
    %
    %   If N = 1, there is no possibility to switch between different times
    %
    %   fig1 = PLOTPANELANGLE(...) returns the handle to the uifigure
    
    %% plot for first object in vectors
    Az = Az_vec(1);
    El = El_vec(1);

    current_i = 1;
    
    %% figure setup
    fig1 = uifigure;
    fig1.Position = [100, 100, 1300, 700];
    fig1.Name = "Solar Panel Angle Viewer";

    progress = uiprogressdlg(fig1,'Title','Please Wait',...
        'Message','Opening the application');

    g1 = uigridlayout(fig1);

    progress.Value = 0.2;
    pause(0.5);

    ax1 = uiaxes(g1);
    ax2 = uiaxes(g1);
    ax3 = uiaxes(g1);
    
    progress.Value = 0.3;
    pause(0.5);

    g2 = uigridlayout(g1);
    g2.RowHeight = {90, 40, 20};
    g2.ColumnWidth = {'1x'};

    l2 = uilabel(g2);
    l2.Text = "";

    %s = uislider(g2);

    g3 = uigridlayout(g2);
    g3.RowHeight = {22, '1x'};
    g3.ColumnWidth = {'1x', '1x', '1x'};

    if length(Az_vec) > 1
        b1 = uibutton(g3, 'ButtonPushedFcn', @(src, event) showPrevious(src, event, Az_vec, El_vec, ax1, ax2, ax3, time));
        b1.Text = "< Previous";
        b1.Enable = 'off';
        
        b2 = uibutton(g3, 'ButtonPushedFcn', @(src, event) showNow(src, event, Az_vec, El_vec, ax1, ax2, ax3, time));
        b2.Text = "Now";
    
        b3 = uibutton(g3, 'ButtonPushedFcn',@(src, event) showNext(src, event, Az_vec, El_vec, ax1, ax2, ax3, time));
        b3.Text = "Next >";
    end
        l1 = uilabel(g2);
        l1.Text = strcat( "From <font style='color:green;'>", datestr(time(current_i)), "</font> to <font style='color:green;'>", datestr(time(current_i+1)), "</font>" );
        l1.FontSize = 16;
        l1.WordWrap = "on";
        l1.Interpreter = "html";
        l1.HorizontalAlignment = 'center';

    if length(Az_vec) > 1
        fig1.UserData = struct("current_i", current_i, "B_Previous", b1, "B_Now", b2,"B_Next", b3, "Label", l1);
    end
    
    progress.Value = 0.4;
    progress.Message = "Figure setup complete. Waiting to fully load...";
    disp("-------------------------------------")
    disp("ui Figure setup complete.")
    pause(1);
    progress.Value = 0.5;
    pause(0.5);
    progress.Value = 0.6;
    pause(0.5);
    progress.Value = 0.7;
    pause(1);
    progress.Value = 0.8;
    progress.Message = "Window loaded, drawing plots.";
    disp("Window loaded");
    pause(0.5);
    
    % plot objects that depend on Az and El
    n_arc = 10;
    drawPlots(Az, El, n_arc, ax1, ax2, ax3)

    progress.Value = 0.9;
    pause(1);
    progress.Value = 1;
    pause(0.2);
    close(progress);

    disp("")
    disp("=====================================")
    disp("Welcome to the Solar Panel Angle Viewer!")
    disp("")
    disp("Use the buttons PREVIOUS, NOW and NEXT")
    disp("    to switch to the specific time interval.")
    disp("=====================================")
    disp("")

    pause(3)
end


function showNext(src, event, Az_vec, El_vec, ax1, ax2, ax3, time)
    disp("-------------------------------------")
    disp("ACTION: button showNext pressed")

    fig = ancestor(src,"figure","toplevel");
    current_i = fig.UserData.current_i;

    n_arc = 10;
    if current_i ~= length(Az_vec)
        Az = Az_vec(current_i + 1);
        El = El_vec(current_i + 1);
        drawPlots(Az, El, n_arc, ax1, ax2, ax3)

        fig.UserData.Label.Text = strcat( "From <font style='color:green;'>", datestr(time(current_i + 1)), "</font> to <font style='color:green;'>", datestr(time(current_i + 2)), "</font>" );

        fig.UserData.current_i = current_i + 1;
        disp("Stepped to next time interval.")
        fig.UserData.B_Previous.Enable = 'on';
        if current_i + 1 == length(Az_vec)
            fig.UserData.B_Next.Enable = 'off';
        end
    else
        disp("Reached end of time range, no later interval to display.")
    end
    disp( ['Displaying element: ' num2str(fig.UserData.current_i) ' out of ' num2str(length(Az_vec)) ] ) 
end

function showPrevious(src, event, Az_vec, El_vec, ax1, ax2, ax3, time)
    disp("-------------------------------------")
    disp("ACTION: button showPrevious pressed")

    fig = ancestor(src,"figure","toplevel");
    current_i = fig.UserData.current_i;

    n_arc = 10;
    if current_i ~= 1
        Az = Az_vec(current_i - 1);
        El = El_vec(current_i - 1);
        drawPlots(Az, El, n_arc, ax1, ax2, ax3)

        fig.UserData.Label.Text = strcat( "From <font style='color:green;'>", datestr(time(current_i - 1)), "</font> to <font style='color:green;'>", datestr(time(current_i)), "</font>" );

        fig.UserData.current_i = current_i - 1;
        disp("Stepped to previous time interval.")
        fig.UserData.B_Next.Enable = 'on';
        if current_i - 1 == 1
            fig.UserData.B_Previous.Enable = 'off';
        end
    else
        disp("Reached begining of time range, no earlier interval to display.")
    end
    disp( ['Displaying element: ' num2str(fig.UserData.current_i) ' out of ' num2str(length(Az_vec)) ] ) 
end

function showNow(src, event, Az_vec, El_vec, ax1, ax2, ax3, time)
    disp("-------------------------------------")
    disp("ACTION: button showNow pressed")

    fig = ancestor(src,"figure","toplevel");

    n_arc = 10;

    now = datetime('now');
    i_now = find( posixtime(time(1:end-1)) < posixtime(now), 1, "last");
    i_1now = find( posixtime(time(2:end)) > posixtime(now), 1, "first");

    if ~isempty(i_now) && ~isempty(i_1now)
        Az = Az_vec(i_now);
        El = El_vec(i_now);
        drawPlots(Az, El, n_arc, ax1, ax2, ax3)

        fig.UserData.Label.Text = strcat( "From <font style='color:green;'>", datestr(time(i_now)), "</font> to <font style='color:green;'>", datestr(time(i_now + 1)), "</font>" );

        fig.UserData.current_i = i_now;
        disp("Stepped to current time interval.")
        if i_now == 1
            fig.UserData.B_Previous.Enable = 'off';
        else
            fig.UserData.B_Previous.Enable = 'on';
        end
        if i_now == length(Az_vec)
            fig.UserData.B_Next.Enable = 'off';
        else
            fig.UserData.B_Next.Enable = 'on';
        end
    else
        disp("The current date and time is not inside the available array.")
    end
    disp( ['Displaying element: ' num2str(fig.UserData.current_i) ' out of ' num2str(length(Az_vec)) ] ) 
end

function drawPlots(Az, El, n_arc, ax1, ax2, ax3)
    lineW = 2;
    sizeF = 18;

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

    %% create angle of car and panel
    Car_Front = Az - 90;
    Panel = El - 90;
    
    if Az > 180
        Az = Az - 360;
    end
    if Car_Front > 180
        Car_Front = Car_Front - 360;
    end
    
    %% create plot objects    
    % create azimuthal arrow
    vec_Az = linspace(0, Az, n_arc);
    
    x_az = 0.5 * cos(vec_Az * pi / 180);
    y_az = - 0.5 * sin(vec_Az * pi / 180);
    z_az = zeros(1,n_arc);
    
    % create elevation arrow
    vec_El = linspace(0, El, n_arc);
    
    x_el = 0.5 * cos(vec_El * pi / 180);
    y_el = zeros(1,n_arc);
    z_el = 0.5 * sin(vec_El * pi / 180);
    
    x_elAz = x_el * cos(Az * pi / 180) - y_el * sin(Az * pi / 180);
    y_elAz = - y_el * cos(Az * pi / 180) - x_el * sin(Az * pi / 180);
    z_elAz = z_el;
    
    % create Panel orientation
    vec_Pan = linspace(0, Panel, n_arc);
    
    x_Pan_ = - 0.5 * cos(vec_Pan * pi / 180);
    y_Pan_ = zeros(1,n_arc);
    z_Pan_ = - 0.5 * sin(vec_Pan * pi / 180);
    
    x_Pan = x_Pan_ * cos(Az * pi / 180) - y_Pan_ * sin(Az * pi / 180);
    y_Pan = - y_Pan_ * cos(Az * pi / 180) - x_Pan_ * sin(Az * pi / 180);
    z_Pan = z_Pan_;
    
    % create car front direction
    vec_Car = linspace(0, Car_Front, n_arc);
    
    x_car = 0.4 * cos(vec_Car * pi / 180);
    y_car = - 0.4 * sin(vec_Car * pi / 180);
    z_car = zeros(1,n_arc);
    
    %% import car geometry
    gm = importGeometry("car_cleaned.stl");
    gm = scale(gm, 1/3000);
    gm = rotate(gm, -Car_Front);

    %% 3D plot
    hold(ax1, 'off');

    pdegplot(ax1, gm, "FaceAlpha", 0.8);
    delete(findobj(ax1,'Type','Text')); 
    delete(findobj(ax1,'Type','Quiver'));
    
    hold(ax1, 'on');
    grid(ax1, 'on');
    box(ax1, 'on');
    %axis(ax1, 'on');
    
    title(ax1, '3D View')
    
    % coordinate system
    plot3(ax1, x_xaxis, y_xaxis, z_xaxis, '-k', 'LineWidth', lineW);
    plot3(ax1, x_yaxis, y_yaxis, z_yaxis, '-k', 'LineWidth', lineW);
    plot3(ax1, x_zaxis, y_zaxis, z_zaxis, '-k', 'LineWidth', lineW);
    text(ax1, 1.2,0,0, 'North', 'FontSize', sizeF, 'HorizontalAlignment','center')
    text(ax1, -1.2,0,0, 'South', 'FontSize', sizeF, 'HorizontalAlignment','center')
    text(ax1, 0,-1.2,0, 'East', 'FontSize', sizeF, 'HorizontalAlignment','center')
    text(ax1, 0, 1.2,0, 'West', 'FontSize', sizeF, 'HorizontalAlignment','center')
    
    % azimuth angle
    % plot3(x_az(1:end-1),y_az(1:end-1),z_az(1:end-1), '-r', 'LineWidth', lineW)
    % arrow([x_az(end-1), y_az(end-1), z_az(end-1)], [x_az(end), y_az(end), z_az(end)], 'Color', 'red', 'LineWidth', lineW, 'Parent', ax1);
    % %text(x_az(narc/2) + 0.1, y_az(narc/2) + 0.1, z_az(narc/2), sprintf('Azimuth = %.1f°', Az_avg), 'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', sizeF)
    % plot3([0, 2*x_az(end)], [0, 2*y_az(end)], [0, 2 * z_az(end)], 'r', 'LineWidth', lineW);
    
    % car front angle
    plot3(ax1, x_car(1:end),y_car(1:end),z_car(1:end), '-g', 'LineWidth', lineW)
    %arrow([x_car(end-1), y_car(end-1), z_car(end-1)], [x_car(end), y_car(end), z_car(end)], 'Color', 'green', 'Parent', ax1);
    text(ax1, x_car(n_arc/2) + 0.1, y_car(n_arc/2) + 0.1, z_car(n_arc/2), sprintf('Car Front = %.1f°', abs(Car_Front)), 'Color', 'g', 'HorizontalAlignment', 'right', 'FontSize', sizeF)
    plot3(ax1, [0, 2*x_car(end)], [0, 2*y_car(end)], [0, 2*z_car(end)], 'g','LineWidth', lineW);
    
    % % elevation angle
    % plot3(x_elAz(1:end-1),y_elAz(1:end-1),z_elAz(1:end-1), '-y', 'LineWidth', lineW)
    % arrow([x_elAz(end-1), y_elAz(end-1), z_elAz(end-1)], [x_elAz(end), y_elAz(end), z_elAz(end)], 'Color', 'yellow', 'LineWidth', lineW), 'Parent', ax1;
    % %text(x_elAz(narc/2) + 0.1, y_elAz(narc/2) + 0.1, z_elAz(narc/2), sprintf('Elevation = %.1f°', El_avg), 'Color', 'y', 'HorizontalAlignment', 'center', 'FontSize', sizeF)
    % plot3([0, 3*x_elAz(end)], [0, 3*y_elAz(end)], [0, 3*z_elAz(end)], 'y', 'LineWidth', lineW);
    
    % panel angle
    plot3(ax1, x_Pan(1:end),y_Pan(1:end),z_Pan(1:end), '-b', 'LineWidth', lineW)
    %arrow([x_Pan(end-1), y_Pan(end-1), z_Pan(end-1)], [x_Pan(end), y_Pan(end), z_Pan(end)], 'Color', 'blue', 'Parent', ax1);
    text(ax1, x_Pan(n_arc/2) + 0.1, y_Pan(n_arc/2) + 0.1, z_Pan(n_arc/2) + 0.2, sprintf('Panel Angle = %.1f°', abs(Panel)), 'Color', 'b', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', 'FontSize', sizeF)
    plot3(ax1, [0, 2*x_Pan(end)], [0, 2*y_Pan(end)], [0, 2 * z_Pan(end)], 'b', 'LineWidth', lineW);
    
    ax1.TickDir = 'none';
    zlim(ax1, [0,1])
    xlim(ax1, [-1.4,1.4])
    ylim(ax1, [-1.4,1.4])
    %set(ax1,'xtick',[])
    set(ax1,'xticklabel',[])
    %set(ax1,'ytick',[])
    set(ax1,'yticklabel',[])
    %set(ax1,'ztick',[])
    set(ax1,'zticklabel',[])
    
    set(ax1,'Color','w')
    
    view(ax1, 3);
    
    %% plot from Top
    
    hold(ax2, 'off');

    pdegplot(ax2, gm, "FaceAlpha", 0.8)
    delete(findobj(ax2,'Type','Text')); 
    delete(findobj(ax2,'Type','Quiver'));
    
    hold(ax2, 'on');
    grid(ax2, 'on');
    box(ax2, 'off');
    %axis(ax2, 'on');
    
    title(ax2, 'Top View')
    
    plot3(ax2, x_xaxis, y_xaxis, z_xaxis, '-k', 'LineWidth', lineW);
    plot3(ax2, x_yaxis, y_yaxis, z_yaxis, '-k', 'LineWidth', lineW);
    plot3(ax2, x_zaxis, y_zaxis, z_zaxis, '-k', 'LineWidth', lineW);
    text(ax2,  1.2,0,0, 'North', 'FontSize', sizeF, 'HorizontalAlignment','center')
    text(ax2, 0,-1.2,0, 'East', 'FontSize', sizeF, 'HorizontalAlignment','left')
    text(ax2, -1.2,0,0, 'South', 'FontSize', sizeF, 'HorizontalAlignment','center')
    text(ax2, 0, 1.2,0, 'West', 'FontSize', sizeF, 'HorizontalAlignment','right')
    
    % car front angle
    plot3(ax2, x_car(1:end),y_car(1:end),z_car(1:end), '-g', 'LineWidth', lineW )
    %arrow([x_car(end-1), y_car(end-1), z_car(end-1)], [x_car(end), y_car(end), z_car(end)], 'Color', 'green', 'Parent', ax2, 'NormalDir', [0, 0, 1], 'Width', lineW, 'Length', 10, 'LineWidth', lineW);
    plot3(ax2, [0, 2*x_car(end)], [0, 2*y_car(end)], [0, 2 * z_car(end)], 'g','LineWidth', lineW);
    
    if Car_Front > 0
        text(ax2, x_car(n_arc/2) + 0.1, y_car(n_arc/2) - 0.1, z_car(n_arc/2), sprintf('Car Front = %.1f°', abs(Car_Front)), 'Color', 'g', 'HorizontalAlignment', 'left', 'FontSize', sizeF)
    else
        text(ax2, x_car(n_arc/2) + 0.1, y_car(n_arc/2) + 0.1, z_car(n_arc/2), sprintf('Car Front = %.1f°', abs(Car_Front)), 'Color', 'g', 'HorizontalAlignment', 'right', 'FontSize', sizeF)
    end
    
    xlim(ax2, [-2,2])
    ylim(ax2, [-2,2])
    %set(ax2, 'xtick',[])
    set(ax2,'xticklabel',[])
    %set(ax2,'ytick',[])
    set(ax2,'yticklabel',[])
    %set(ax2,'ztick',[])
    set(ax2,'zticklabel',[])
    
    view(ax2, -90, 90)
    
    %% plot from Front
    hold(ax3, 'off');

    pdegplot(ax3, gm, "FaceAlpha", 0.8)
    delete(findobj(ax3,'Type','Text')); 
    delete(findobj(ax3,'Type','Quiver'));
    
    hold(ax3, 'on');
    grid(ax3, 'on');
    box(ax3, 'on');
    %axis(ax3, 'on');
    
    title(ax3,'Front View')
    
    plot3(ax3,x_xaxis, y_xaxis, z_xaxis, '-k', 'LineWidth', lineW);
    plot3(ax3,x_yaxis, y_yaxis, z_yaxis, '-k', 'LineWidth', lineW);
    plot3(ax3,x_zaxis, y_zaxis, z_zaxis, '-k', 'LineWidth', lineW);
    
    % panel angle
    plot3(ax3,x_Pan(1:end),y_Pan(1:end),z_Pan(1:end), '-b', 'LineWidth', lineW)
    %arrow([x_Pan(end-1), y_Pan(end-1), z_Pan(end-1)], [x_Pan(end), y_Pan(end), z_Pan(end)], 'Color', 'blue', 'Parent', ax3, 'NormalDir', [0, 0, 1]);
    plot3(ax3,[0, 2*x_Pan(end)], [0, 2*y_Pan(end)], [0, 2 * z_Pan(end)], 'b', 'LineWidth', lineW);
    text(ax3,0, 0, -0.05, sprintf('Panel Angle = %.1f°', abs(Panel)), 'Color', 'b', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', sizeF)
    
    % % elevation angle
    % plot3(x_elAz(1:end-1),y_elAz(1:end-1),z_elAz(1:end-1), '-y', 'LineWidth', lineW)
    % %arrow([x_elAz(end-1), y_elAz(end-1), z_elAz(end-1)], [x_elAz(end), y_elAz(end), z_elAz(end)], 'Color', 'yellow', 'LineWidth', lineW, 'Parent', ax3);
    % %text(x_elAz(narc/2) + 0.1, y_elAz(narc/2) + 0.1, z_elAz(narc/2), sprintf('Elevation = %.1f°', El_avg), 'Color', 'y', 'HorizontalAlignment', 'center', 'FontSize', sizeF)
    % plot3([0, 3*x_elAz(end)], [0, 3*y_elAz(end)], [0, 3*z_elAz(end)], 'y', 'LineWidth', lineW);
    
    ax3.TickDir = 'none';
    ylim(ax3, [-1, 1])
    xlim(ax3, [-1, 1])
    %xlim(ax3,[-0.6 * abs(sin(Car_Front)),0.6  * abs(sin(Car_Front))])
    zlim(ax3,[0, 0.6])
    %set(ax3,'xtick',[])
    set(ax3,'xticklabel',[])
    %set(ax3,'ytick',[])
    set(ax3,'yticklabel',[])
    %set(ax3,'ztick',[])
    set(ax3,'zticklabel',[])
    
    view(ax3,180-Az, 0)

    %all_figs = findobj(0, 'type', 'figure');
    %delete(setdiff(all_figs, fig1))

    disp("Plots have been drawn.")
end
