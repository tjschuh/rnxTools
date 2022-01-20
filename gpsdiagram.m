function gpsdiagram(dist12,dist13,dist14,dist23,dist24,dist34)
% GPSDIAGRAM(dist12,dist13,dist14,dist23,dist24,dist34)
%
% Make a simple diagram of 4 GPS locations given 6 distances between them
% all
%
% INPUT:
%
% dist12      approximate distance between receivers 1 and 2 [m]
% dist13      approximate distance between receivers 1 and 3 [m]
% dist14      approximate distance between receivers 1 and 4 [m]
% dist23      approximate distance between receivers 2 and 3 [m]
% dist24      approximate distance between receivers 2 and 4 [m]
% dist34      approximate distance between receivers 3 and 4 [m]
%
% OUTPUT:
%
% plot of diagram
%
% Originally written by tschuh-at-princeton.edu, 01/12/2022

% values from R/V Atlantic Explorer
defval('dist12',4.8)
defval('dist13',12.2)
defval('dist14',10.1)
defval('dist23',10.3)
defval('dist24',11.3)
defval('dist34',7.1)

% percentage threshold for calculation approximation in if statement
pct = 0.05;
% offset to add to coordinates for neater plotting
offset = [1 1];

% if pythagorean thm holds for the given distances, then this
% must be the configuration we want so go ahead and plot
if abs((dist24)^2 - ((dist12)^2 + (dist14)^2)) <= pct*(dist24)^2 ...
        && abs((dist13)^2 - ((dist14)^2 + (dist34)^2)) <= pct*(dist13)^2
    % determine relative GPS coordinates
    gps1 = [0 dist14] + offset;
    gps2 = [dist12 dist14] + offset;
    gps3 = [dist34 0] + offset;
    gps4 = [0 0] + offset;
    % combine all coordinates to plot connecting lines
    all4 = [gps1; gps2; gps3; gps4; gps1];

    % plotting
    scatter(gps1(1),gps1(2),'b','filled')
    hold on
    scatter(gps2(1),gps2(2),'b','filled')
    scatter(gps3(1),gps3(2),'b','filled')
    scatter(gps4(1),gps4(2),'b','filled')
    plot(all4(:,1),all4(:,2),'k')
    title('Diagram of 4 GPS Locations')
    xlim([0 gps3(1)+offset(2)])
    xlabel('Distance [meters]')
    ylim([0 gps1(2)+offset(1)])
    ylabel('Distance [meters]')
    a = annotation('textbox',[0.15 0.22 0 0.7],'String',['Unit 1'],'FitBoxToText','on');
    a.FontSize = 8;
    b = annotation('textbox',[0.6 0.22 0 0.7],'String',['Unit 2'],'FitBoxToText','on');
    b.FontSize = 8;
    c = annotation('textbox',[0.8 0.18 0 0],'String',['Unit 3'],'FitBoxToText','on');
    c.FontSize = 8;
    d = annotation('textbox',[0.15 0.18 0 0],'String',['Unit 4'],'FitBoxToText','on');
    d.FontSize = 8;
    e = annotation('textbox',[0.48 0.8 0 0],'String',['bow'],'FitBoxToText','on');
    e.FontSize = 8;
    f = annotation('textbox',[0.48 0.25 0 0],'String',['stern'],'FitBoxToText','on');
    f.FontSize = 8;
    annotation('arrow',[0.47 0.47],[0.55 0.75]);
    annotation('arrow',[0.47 0.47],[0.45 0.25]);
    h = annotation('textbox',[0.3 0.55 0 0],'String',['portside'],'FitBoxToText','on');
    h.FontSize = 8;
    g = annotation('textbox',[0.52 0.55 0 0],'String',['starboard'],'FitBoxToText','on');
    g.FontSize = 8;
    grid on
    longticks
else
    error('Cannot compute configuration currently')
end
