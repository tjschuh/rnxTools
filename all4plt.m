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
% Last modified by tschuh-at-princeton.edu, 11/15/2021

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

% combine the fields of all 4 datasets into 1 
alldt = [d1.t d2.t d3.t d4.t];
alldxyz = [d1.xyz d2.xyz d3.xyz d4.xyz];
alldlat = [d1.lat d2.lon d3.lat d4.lat];
alldlon = [d1.lon d2.lon d3.lon d4.lon];
alldutme = [d1.utmeasting d2.utmeasting d3.utmeasting d4.utmeasting];
alldutmn = [d1.utmnorthing d2.utmnorthing d3.utmnorthing d4.utmnorthing];
alldutmz = [d1.utmzone d2.utmzone d3.utmzone d4.utmzone];
alldht = [d1.height d2.height d3.height d4.height];
alldnsats = [d1.nsats d2.nsats d3.nsats d4.nsats];
alldpdop = [d1.pdop d2.pdop d3.pdop d4.pdop];

% find rows where nsats <= 4
nthresh = 4;
nrows1 = find(d1.nsats(:,1)<=nthresh);
nrows2 = find(d2.nsats(:,1)<=nthresh);
nrows3 = find(d3.nsats(:,1)<=nthresh);
nrows4 = find(d4.nsats(:,1)<=nthresh);

% find rows where pdop >= 10 or = 0
pthresh = 15;
prows1 = find(d1.pdop(:,1)>=pthresh | d1.pdop(:,1)==0);
prows2 = find(d2.pdop(:,1)>=pthresh | d2.pdop(:,1)==0);
prows3 = find(d3.pdop(:,1)>=pthresh | d3.pdop(:,1)==0);
prows4 = find(d4.pdop(:,1)>=pthresh | d4.pdop(:,1)==0);

% plot heights of all 4 units all on 1 plot
figure
%ah(1)=subplot(2,2,[1 3]);
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
% to set best ylim, remove outliers from alldht
% then find the global min
alldht = rmoutliers(alldht,'mean');
ylim([min(alldht,[],'all')-0.005*abs(min(alldht,[],'all')) max(alldht,[],'all')+0.005*abs(max(alldht,[],'all'))])
% grey out bad data
% maybe there is a more clever way to do this
nbadt1 = d1.t(nrows1);
nbadht1 = d1.height(nrows1);
pbadt1 = d1.t(prows1);
pbadht1 = d1.height(prows1);
nbadt2 = d2.t(nrows2);
nbadht2 = d2.height(nrows2);
pbadt2 = d2.t(prows2);
pbadht2 = d2.height(prows2);
nbadt3 = d3.t(nrows3);
nbadht3 = d3.height(nrows3);
pbadt3 = d3.t(prows3);
pbadht3 = d3.height(prows3);
nbadt4 = d4.t(nrows4);
nbadht4 = d4.height(nrows4);
pbadt4 = d4.t(prows4);
pbadht4 = d4.height(prows4);
plot(nbadt1,nbadht1,'color',[0.7 0.7 0.7])
plot(pbadt1,pbadht1,'color',[0.7 0.7 0.7])
plot(nbadt2,nbadht2,'color',[0.7 0.7 0.7])
plot(pbadt2,pbadht2,'color',[0.7 0.7 0.7])
plot(nbadt3,nbadht3,'color',[0.7 0.7 0.7])
plot(pbadt3,pbadht3,'color',[0.7 0.7 0.7])
plot(nbadt4,nbadht4,'color',[0.7 0.7 0.7])
plot(pbadt4,pbadht4,'color',[0.7 0.7 0.7])

% plot distances between all 4 GPS units
% grey out bad data?
dist12 = sqrt((d1.xyz(:,1)-d2.xyz(:,1)).^2 + (d1.xyz(:,2)-d2.xyz(:,2)).^2 + (d1.xyz(:,3)-d2.xyz(:,3)).^2);
dist13 = sqrt((d1.xyz(:,1)-d3.xyz(:,1)).^2 + (d1.xyz(:,2)-d3.xyz(:,2)).^2 + (d1.xyz(:,3)-d3.xyz(:,3)).^2);
dist14 = sqrt((d1.xyz(:,1)-d4.xyz(:,1)).^2 + (d1.xyz(:,2)-d4.xyz(:,2)).^2 + (d1.xyz(:,3)-d4.xyz(:,3)).^2);
dist23 = sqrt((d2.xyz(:,1)-d3.xyz(:,1)).^2 + (d2.xyz(:,2)-d3.xyz(:,2)).^2 + (d2.xyz(:,3)-d3.xyz(:,3)).^2);
dist24 = sqrt((d2.xyz(:,1)-d4.xyz(:,1)).^2 + (d2.xyz(:,2)-d4.xyz(:,2)).^2 + (d2.xyz(:,3)-d4.xyz(:,3)).^2);
dist34 = sqrt((d3.xyz(:,1)-d4.xyz(:,1)).^2 + (d3.xyz(:,2)-d4.xyz(:,2)).^2 + (d3.xyz(:,3)-d4.xyz(:,3)).^2);
figure
%ah(2)=subplot(2,2,2);
plot(d1.t,dist12,'LineWidth',1.5)
hold on
plot(d1.t,dist13,'LineWidth',1.5)
plot(d1.t,dist14,'LineWidth',1.5)
plot(d1.t,dist23,'LineWidth',1.5)
plot(d1.t,dist24,'LineWidth',1.5)
plot(d1.t,dist34,'LineWidth',1.5)
legend({'1-2','1-3','1-4','2-3','2-4','3-4'},'Location','east','NumColumns',2)
xlim([d1.t(1) d1.t(end)])
ylabel('Distance [m]')
title('Distances between GPS Receivers')
grid on
longticks

% plot accelerations ax, ay, az
%ah(3)=subplot(2,2,4);
% compute velocity components vx, vy, vz in m/s
vx1 = diff(d1.xyz(:,1))./seconds(diff(d1.t));
vy1 = diff(d1.xyz(:,2))./seconds(diff(d1.t));
vz1 = diff(d1.xyz(:,3))./seconds(diff(d1.t));
vx2 = diff(d2.xyz(:,1))./seconds(diff(d2.t));
vy2 = diff(d2.xyz(:,2))./seconds(diff(d2.t));
vz2 = diff(d2.xyz(:,3))./seconds(diff(d2.t));
vx3 = diff(d3.xyz(:,1))./seconds(diff(d3.t));
vy3 = diff(d3.xyz(:,2))./seconds(diff(d3.t));
vz3 = diff(d3.xyz(:,3))./seconds(diff(d3.t));
vx4 = diff(d4.xyz(:,1))./seconds(diff(d4.t));
vy4 = diff(d4.xyz(:,2))./seconds(diff(d4.t));
vz4 = diff(d4.xyz(:,3))./seconds(diff(d4.t));

v1 = sqrt(vx1.^2 + vy1.^2 + vz1.^2);
v2 = sqrt(vx2.^2 + vy2.^2 + vz2.^2);
v3 = sqrt(vx3.^2 + vy3.^2 + vz3.^2);
v4 = sqrt(vx4.^2 + vy4.^2 + vz4.^2);
% 1 knot = 1852 m/hr
v1knot = 3600*v1/1852;
v2knot = 3600*v2/1852;
v3knot = 3600*v3/1852;
v4knot = 3600*v4/1852;

% compute acceleration components ax, ay, az in m/s^2
ax1 = diff(vx1)./(2*seconds(diff(d1.t(1:end-1))));
ay1 = diff(vy1)./(2*seconds(diff(d1.t(1:end-1))));
az1 = diff(vz1)./(2*seconds(diff(d1.t(1:end-1))));
ax2 = diff(vx2)./(2*seconds(diff(d2.t(1:end-1))));
ay2 = diff(vy2)./(2*seconds(diff(d2.t(1:end-1))));
az2 = diff(vz2)./(2*seconds(diff(d2.t(1:end-1))));
ax3 = diff(vx3)./(2*seconds(diff(d3.t(1:end-1))));
ay3 = diff(vy3)./(2*seconds(diff(d3.t(1:end-1))));
az3 = diff(vz3)./(2*seconds(diff(d3.t(1:end-1))));
ax4 = diff(vx4)./(2*seconds(diff(d4.t(1:end-1))));
ay4 = diff(vy4)./(2*seconds(diff(d4.t(1:end-1))));
az4 = diff(vz4)./(2*seconds(diff(d4.t(1:end-1))));

a1 = sqrt(ax1.^2 + ay1.^2 + az1.^2); 
a2 = sqrt(ax2.^2 + ay2.^2 + az2.^2); 
a3 = sqrt(ax3.^2 + ay3.^2 + az3.^2); 
a4 = sqrt(ax4.^2 + ay4.^2 + az4.^2); 

% how does Frederik want me to plot this exactly?
% fix ylim s.t. its symmetric
figure
int=15;
subplot(3,1,1)
plot(d1.t(1:int:end-2),ax1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),ax2(1:int:end),'g')
plot(d3.t(1:int:end-2),ax3(1:int:end),'b')
plot(d4.t(1:int:end-2),ax4(1:int:end),'m')
legend({'GPS 1','GPS 2','GPS 3','GPS 4'},'Location','northoutside','NumColumns',4)
grid on
longticks
xlim([d1.t(1) d1.t(end-2)])
ax = [ax1 ax2 ax3 ax4];
ylim([min(ax,[],'all')-0.005*abs(min(ax,[],'all')) max(ax,[],'all')+0.005*abs(max(ax,[],'all'))])
ylabel('a_x [m/s^2]')
xticklabels([])

subplot(3,1,2)
plot(d1.t(1:int:end-2),ay1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),ay2(1:int:end),'g')
plot(d3.t(1:int:end-2),ay3(1:int:end),'b')
plot(d4.t(1:int:end-2),ay4(1:int:end),'m')
grid on
longticks
xlim([d1.t(1) d1.t(end-2)])
ay = [ay1 ay2 ay3 ay4];
ylim([min(ay,[],'all')-0.005*abs(min(ay,[],'all')) max(ay,[],'all')+0.005*abs(max(ay,[],'all'))])
ylabel('a_y [m/s^2]')
xticklabels([])

subplot(3,1,3)
plot(d1.t(1:int:end-2),az1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),az2(1:int:end),'g')
plot(d3.t(1:int:end-2),az3(1:int:end),'b')
plot(d4.t(1:int:end-2),az4(1:int:end),'m')
grid on
longticks
xlim([d1.t(1) d1.t(end-2)])
az = [az1 az2 az3 az4];
ylim([min(az,[],'all')-0.005*abs(min(az,[],'all')) max(az,[],'all')+0.005*abs(max(az,[],'all'))])
ylabel('a_z [m/s^2]')
%title('Ship Accelerations')

keyboard
