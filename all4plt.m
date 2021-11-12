function all4plt(unit1file,unit2file,unit3file,unit4file)
% ALL4PLT(unit1file,unit2file,unit3file,unit4file)
%
% plot all 4 units on one figure and compare height, distance 
% between receivers, and acceleration (and maybe one day rotation)
%
% INPUT:
%
% unit1file     mat file containing data collected by unit 1
% unit2file     mat file containing data collected by unit 2
% unit3file     mat file containing data collected by unit 3
% unit4file     mat file containing data collected by unit 4
%
% Originally written by tschuh-at-princeton.edu, 11/12/2021

% use mat2mod to convert data to all be same time spans with no time gaps
[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);

% plotting all 4 units together in motion
% not neccessary right now
%figure
%loops = 10;
%M(loops) = struct('cdata',[],'colormap',[]);
%for i = 1:loops
%    scatter3(d1.utmeasting(i,1),d1.utmnorthing(i,1),d1.height(i,1),'k','filled')
%    hold on
%    scatter3(d2.utmeasting(i,1),d2.utmnorthing(i,1),d2.height(i,1),'b','filled')
%    scatter3(d3.utmeasting(i,1),d3.utmnorthing(i,1),d3.height(i,1),'g','filled')
%    scatter3(d4.utmeasting(i,1),d4.utmnorthing(i,1),d4.height(i,1),'r','filled')
%    xlabel('Easting [m]')
%    ylabel('Northing [m]')
%    zlabel('Height rel to WGS84 [m]')
%    M(i) = getframe;
%    clf
%end
%movie(M);

% plot heights of all 4 units in subplot
%figure
%for i=1:nargin
%    subplot(4,1,i)
%    plot(dmat(i).t,dmat(i).height,'color',[0.4660 0.6740 0.1880])
%    xlim([d.t(1) d.t(end)])
%    dmat(i).height = rmoutliers(dmat(i).height,'mean');
%    % need to make 0.005 multiplier more general!
%    ylim([min(dmat(i).height)-0.005*abs(min(dmat(i).height)) max(dmat(i).height)+0.005*abs(max(dmat(i).height))])
%    grid on
%    longticks
%    %ylabel('Height relative to WGS84 [m]')
%    if i < nargin
%        xticklabels([])
%    end
%end

% plot heights of all 4 units all on 1 plot
figure
plot(d1.t,d1.height,'b')
hold on
plot(d2.t,d2.height,'r')
plot(d3.t,d3.height,'g')
plot(d4.t,d4.height,'k')
legend('GPS 1','GPS 2','GPS 3','GPS 4')
xlim([d1.t(1) d1.t(end)])
ylabel('Height relative to WGS84 [m]')
grid on
longticks
% need to figure out how to make ylim work