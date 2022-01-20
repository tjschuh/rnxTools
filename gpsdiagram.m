function gpsdiagram(dist12,dist13,dist14,dist23,dist24,dist34)
% GPSDIAGRAM(dist12,dist13,dist14,dist23,dist24,dist34)
%
% Make a simple diagram of 4 GPS locations given 6 distances between them
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
% Last modified by tschuh-at-princeton.edu, 01/12/2022
% Last modified by fjsimons-at-princeton.edu, 01/19/2022

% values from R/V Atlantic Explorer
defval('dist12', 4.8)
defval('dist13',12.2)
defval('dist14',10.1)
defval('dist23',10.3)
defval('dist24',11.3)
defval('dist34', 7.1)

% percentage threshold for calculation approximation in if statement
pct = 0.05;
% offset to add to coordinates for neater plotting
offset = [1 1];

% Font size of box tex
fs=10;

% Text box locations
tx=[0.15 0.22 0 0.7;
    0.60 0.22 0 0.7;
    0.80 0.18 0 0  ; 
    0.15 0.18 0 0  ;
    0.48 0.80 0 0  ;
    0.48 0.25 0 0  ;
    0.30 0.55 0 0  ;
    0.52 0.55 0 0 ];
% Text box strings
ts={'Unit 1','Unit 2','Unit 3','Unit 4','bow','stern','port','starboard'};

% if pythagorean thm holds for the given distances, then this
% must be the configuration we want so go ahead and plot
if abs((dist24)^2 - ((dist12)^2 + (dist14)^2)) <= pct*(dist24)^2 ...
        && abs((dist13)^2 - ((dist14)^2 + (dist34)^2)) <= pct*(dist13)^2
    % determine relative GPS coordinates
    gps1 = [0      dist14] + offset;
    gps2 = [dist12 dist14] + offset;
    gps3 = [dist34 0     ] + offset;
    gps4 = [0      0     ] + offset;
    % combine all coordinates to plot connecting lines
    all4 = [gps1; gps2; gps3; gps4; gps1];

    clf
    % main plotting
    scatter(gps1(1),gps1(2),'b','filled')
    hold on
    scatter(gps2(1),gps2(2),'b','filled')
    scatter(gps3(1),gps3(2),'b','filled')
    scatter(gps4(1),gps4(2),'b','filled')
    plot(all4(:,1),all4(:,2),'k')
    tl=title('Diagram of 4 GPS Locations');
    xlim([0 gps3(1)+offset(2)])
    ylim([0 gps1(2)+offset(1)])
    xlabel('distance [m]')
    ylabel('distance [m]')
    
    % extra annotation

    annotation('arrow',[0.47 0.47],[0.55 0.75]);
    annotation('arrow',[0.47 0.47],[0.45 0.25]);

    for index=1:size(tx,1)
      xa{index} = annotation('textbox',tx(index,:),'String',ts{index},...
			     'FontSize',fs,'FitBoxToText','on');
    end
    hold off
    grid on
    longticks(gca,2)
else
    error('Cannot compute configuration currently')
end

% Final cleanup
delete(tl)
box on

% Print to PDF
figdisp([],[],[],2)
