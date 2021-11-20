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
[~,fname,~] = fileparts(unit1file);

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

int=15;

% plot heights of all 4 units all on 1 plot
f=figure;
f.Position = [500 250 800 900];
ah(1)=subplot(5,2,[1 3]);
plot(d1.t(1:int:end),d1.height(1:int:end),'r')
hold on
plot(d2.t(1:int:end),d2.height(1:int:end),'g')
plot(d3.t(1:int:end),d3.height(1:int:end),'b')
plot(d4.t(1:int:end),d4.height(1:int:end),'m')
xlim([d1.t(1) d1.t(end)])
xticklabels([])
ylabel('Height relative to WGS84 [m]')
title('Height relative to WGS84')
grid on
longticks
% to set best ylim, remove outliers from alldht
% then find the global min
alldht = rmoutliers(alldht,'mean');
ylim([min(alldht,[],'all')-0.005*abs(min(alldht,[],'all')) max(alldht,[],'all')+0.005*abs(max(alldht,[],'all'))])
% grey out bad data
% maybe there is a more clever way to do this
nbadt1 = d1.t(nrows1); pbadt1 = d1.t(prows1);
nbadht1 = d1.height(nrows1); pbadht1 = d1.height(prows1);
nbadt2 = d2.t(nrows2); pbadt2 = d2.t(prows2);
nbadht2 = d2.height(nrows2); pbadht2 = d2.height(prows2);
nbadt3 = d3.t(nrows3); pbadt3 = d3.t(prows3);
nbadht3 = d3.height(nrows3); pbadht3 = d3.height(prows3);
nbadt4 = d4.t(nrows4); pbadt4 = d4.t(prows4);
nbadht4 = d4.height(nrows4); pbadht4 = d4.height(prows4);
plot(nbadt1(1:int:end),nbadht1(1:int:end),'color',[0.7 0.7 0.7])
plot(pbadt1(1:int:end),pbadht1(1:int:end),'color',[0.7 0.7 0.7])
plot(nbadt2(1:int:end),nbadht2(1:int:end),'color',[0.7 0.7 0.7])
plot(pbadt2(1:int:end),pbadht2(1:int:end),'color',[0.7 0.7 0.7])
plot(nbadt3(1:int:end),nbadht3(1:int:end),'color',[0.7 0.7 0.7])
plot(pbadt3(1:int:end),pbadht3(1:int:end),'color',[0.7 0.7 0.7])
plot(nbadt4(1:int:end),nbadht4(1:int:end),'color',[0.7 0.7 0.7])
plot(pbadt4(1:int:end),pbadht4(1:int:end),'color',[0.7 0.7 0.7])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot distances between all 4 GPS units
% compute all 6 distances between 4 GPS receivers
dist12 = sqrt((d1.xyz(:,1)-d2.xyz(:,1)).^2 + (d1.xyz(:,2)-d2.xyz(:,2)).^2 + (d1.xyz(:,3)-d2.xyz(:,3)).^2);
normdist12 = dist12 - nanmean(dist12) + 1;
dist12 = rmNaNrows(dist12); p = polyfit([1:length(dist12)]',dist12,1);
a12 = p(1); b12 = p(2); rms12 = rms(dist12); std12 = std(dist12);
dist13 = sqrt((d1.xyz(:,1)-d3.xyz(:,1)).^2 + (d1.xyz(:,2)-d3.xyz(:,2)).^2 + (d1.xyz(:,3)-d3.xyz(:,3)).^2);
normdist13 = dist13 - nanmean(dist13) + 2;
dist13 = rmNaNrows(dist13); p = polyfit([1:length(dist13)]',dist13,1);
a13 = p(1); b13 = p(2); rms13 = rms(dist13); std13 = std(dist13);
dist14 = sqrt((d1.xyz(:,1)-d4.xyz(:,1)).^2 + (d1.xyz(:,2)-d4.xyz(:,2)).^2 + (d1.xyz(:,3)-d4.xyz(:,3)).^2);
normdist14 = dist14 - nanmean(dist14) + 3;
dist14 = rmNaNrows(dist14); p = polyfit([1:length(dist14)]',dist14,1);
a14 = p(1); b14 = p(2); rms14 = rms(dist14); std14 = std(dist14);
dist23 = sqrt((d2.xyz(:,1)-d3.xyz(:,1)).^2 + (d2.xyz(:,2)-d3.xyz(:,2)).^2 + (d2.xyz(:,3)-d3.xyz(:,3)).^2);
normdist23 = dist23 - nanmean(dist23) + 4;
dist23 = rmNaNrows(dist23); p = polyfit([1:length(dist23)]',dist23,1);
a23 = p(1); b23 = p(2); rms23 = rms(dist23); std23 = std(dist23);
dist24 = sqrt((d2.xyz(:,1)-d4.xyz(:,1)).^2 + (d2.xyz(:,2)-d4.xyz(:,2)).^2 + (d2.xyz(:,3)-d4.xyz(:,3)).^2);
normdist24 = dist24 - nanmean(dist24) + 5;
dist24 = rmNaNrows(dist24); p = polyfit([1:length(dist24)]',dist24,1);
a24 = p(1); b24 = p(2); rms24 = rms(dist24); std24 = std(dist24);
dist34 = sqrt((d3.xyz(:,1)-d4.xyz(:,1)).^2 + (d3.xyz(:,2)-d4.xyz(:,2)).^2 + (d3.xyz(:,3)-d4.xyz(:,3)).^2);
normdist34 = dist34 - nanmean(dist34) + 6;
dist34 = rmNaNrows(dist34); p = polyfit([1:length(dist34)]',dist34,1);
a34 = p(1); b34 = p(2); rms34 = rms(dist34); std34 = std(dist34);

% bad data
% explain how/why I do this!
% nbaddist121 = dist12(nrows1); pbaddist121 = dist12(prows1);
% nbaddist122 = dist12(nrows2); pbaddist122 = dist12(prows2);
% nbaddist131 = dist13(nrows1); pbaddist131 = dist13(prows1);
% nbaddist133 = dist13(nrows3); pbaddist133 = dist13(prows3);
% nbaddist141 = dist14(nrows1); pbaddist141 = dist14(prows1);
% nbaddist144 = dist14(nrows4); pbaddist144 = dist14(prows4);
% nbaddist232 = dist23(nrows2); pbaddist232 = dist23(prows2);
% nbaddist233 = dist23(nrows3); pbaddist233 = dist23(prows3);
% nbaddist242 = dist24(nrows2); pbaddist242 = dist24(prows2);
% nbaddist244 = dist24(nrows4); pbaddist244 = dist24(prows4);
% nbaddist343 = dist34(nrows3); pbaddist343 = dist34(prows3);
% nbaddist344 = dist34(nrows4); pbaddist344 = dist34(prows4);
% multi = 0.025;
% drows12 = find(dist12(:,1)<=nanmean(dist12)-multi*nanmean(dist12) | dist12(:,1)>=nanmean(dist12)+multi*nanmean(dist12));
% drows13 = find(dist13(:,1)<=nanmean(dist13)-multi*nanmean(dist13) | dist13(:,1)>=nanmean(dist13)+multi*nanmean(dist13));
% drows14 = find(dist14(:,1)<=nanmean(dist14)-multi*nanmean(dist14) | dist14(:,1)>=nanmean(dist14)+multi*nanmean(dist14));
% drows23 = find(dist23(:,1)<=nanmean(dist23)-multi*nanmean(dist23) | dist23(:,1)>=nanmean(dist23)+multi*nanmean(dist23));
% drows24 = find(dist24(:,1)<=nanmean(dist24)-multi*nanmean(dist24) | dist24(:,1)>=nanmean(dist24)+multi*nanmean(dist24));
% drows34 = find(dist34(:,1)<=nanmean(dist34)-multi*nanmean(dist34) | dist34(:,1)>=nanmean(dist34)+multi*nanmean(dist34));
% baddist12 = dist12(drows12); badt12 = d1.t(drows12);
% baddist13 = dist13(drows13); badt13 = d1.t(drows13);
% baddist14 = dist14(drows14); badt14 = d1.t(drows14);
% baddist23 = dist23(drows23); badt23 = d1.t(drows23);
% baddist24 = dist24(drows24); badt24 = d1.t(drows24);
% baddist34 = dist34(drows34); badt34 = d1.t(drows34);

ah(2)=subplot(5,2,[2 4]);
plot(d1.t,normdist12,'LineWidth',2)
hold on
plot(d1.t,normdist13,'LineWidth',2)
plot(d1.t,normdist14,'LineWidth',2)
plot(d1.t,normdist23,'LineWidth',2)
plot(d1.t,normdist24,'LineWidth',2)
plot(d1.t,normdist34,'LineWidth',2)
% plot(nbadt1,nbaddist121,nbadt1,nbaddist131,nbadt1,nbaddist141,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(nbadt2,nbaddist122,nbadt2,nbaddist232,nbadt2,nbaddist242,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(nbadt3,nbaddist133,nbadt3,nbaddist233,nbadt3,nbaddist343,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(nbadt4,nbaddist144,nbadt4,nbaddist244,nbadt4,nbaddist344,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(pbadt1,pbaddist121,pbadt1,pbaddist131,pbadt1,pbaddist141,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(pbadt2,pbaddist122,pbadt2,pbaddist232,pbadt2,pbaddist242,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(pbadt3,pbaddist133,pbadt3,pbaddist233,pbadt3,pbaddist343,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(pbadt4,pbaddist144,pbadt4,pbaddist244,pbadt4,pbaddist344,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(badt12,baddist12,badt13,baddist13,badt14,baddist14,'color',[0.7 0.7 0.7],'LineWidth',2)
% plot(badt23,baddist23,badt24,baddist24,badt34,baddist34,'color',[0.7 0.7 0.7],'LineWidth',2)
xlim([d1.t(1) d1.t(end)])
xticklabels([])
ylim([0.25 6.75])
yticklabels({'1-2','1-3','1-4','2-3','2-4','3-4'})
ylabel('GPS Pair')
title('Distances between GPS Receivers')
% add a leading zero!
text(d1.t(900),6.4,sprintf('%.2e, %.2f, %.2f, %.2f',a34,b34,rms34,std34))
text(d1.t(900),5.4,sprintf('%.2e, %.2f, %.2f, %.2f',a24,b24,rms24,std24))
text(d1.t(900),4.4,sprintf('%.2e, %.2f, %.2f, %.2f',a23,b23,rms23,std23))
text(d1.t(900),3.4,sprintf('%.2e, %.2f, %.2f, %.2f',a14,b14,rms14,std14))
text(d1.t(900),2.4,sprintf('%.2e, %.2f, %.2f, %.2f',a13,b13,rms13,std13))
text(d1.t(900),1.4,sprintf('%.2e, %.2f, %.2f, %.2f',a12,b12,rms12,std12))
text(d1.t(650),0.5,sprintf('a [m/s], b [m], rms [m], std [m]'))
grid on
longticks
keyboard
% plot accelerations ax, ay, az
% first compute velocity components vx, vy, vz in m/s
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

% then compute acceleration components ax, ay, az in m/s^2
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

% bad data
% explain this!
%nbadax1 = ax1(nrows1); pbadax1 = ax1(prows1);
%nbaday1 = ay1(nrows1); pbaday1 = ay1(prows1);
%nbadaz1 = az1(nrows1); pbadaz1 = az1(prows1);
%nbadax2 = ax2(nrows2); pbadax2 = ax2(prows2);
%nbaday2 = ay2(nrows2); pbaday2 = ay2(prows2);
%nbadaz2 = az2(nrows2); pbadaz2 = az2(prows2);
%nbadax3 = ax3(nrows3); pbadax3 = ax3(prows3);
%nbaday3 = ay3(nrows3); pbaday3 = ay3(prows3);
%nbadaz3 = az3(nrows3); pbadaz3 = az3(prows3);
%nbadax4 = ax4(nrows4); pbadax4 = ax4(prows4);
%nbaday4 = ay4(nrows4); pbaday4 = ay4(prows4);
%nbadaz4 = az4(nrows4); pbadaz4 = az4(prows4);

multi=5;
ax1rows = find(ax1(:,1)<=nanmean(abs(ax1))-multi*nanmean(abs(ax1)) | ax1(:,1)>=nanmean(abs(ax1))+multi*nanmean(abs(ax1)));
ay1rows = find(ay1(:,1)<=nanmean(abs(ay1))-multi*nanmean(abs(ay1)) | ay1(:,1)>=nanmean(abs(ay1))+multi*nanmean(abs(ay1)));
az1rows = find(az1(:,1)<=nanmean(abs(az1))-multi*nanmean(abs(az1)) | az1(:,1)>=nanmean(abs(az1))+multi*nanmean(abs(az1)));
ax2rows = find(ax2(:,1)<=nanmean(abs(ax2))-multi*nanmean(abs(ax2)) | ax2(:,1)>=nanmean(abs(ax2))+multi*nanmean(abs(ax2)));
ay2rows = find(ay2(:,1)<=nanmean(abs(ay2))-multi*nanmean(abs(ay2)) | ay2(:,1)>=nanmean(abs(ay2))+multi*nanmean(abs(ay2)));
az2rows = find(az2(:,1)<=nanmean(abs(az2))-multi*nanmean(abs(az2)) | az2(:,1)>=nanmean(abs(az2))+multi*nanmean(abs(az2)));
ax3rows = find(ax3(:,1)<=nanmean(abs(ax3))-multi*nanmean(abs(ax3)) | ax3(:,1)>=nanmean(abs(ax3))+multi*nanmean(abs(ax3)));
ay3rows = find(ay3(:,1)<=nanmean(abs(ay3))-multi*nanmean(abs(ay3)) | ay3(:,1)>=nanmean(abs(ay3))+multi*nanmean(abs(ay3)));
az3rows = find(az3(:,1)<=nanmean(abs(az3))-multi*nanmean(abs(az3)) | az3(:,1)>=nanmean(abs(az3))+multi*nanmean(abs(az3)));
ax4rows = find(ax4(:,1)<=nanmean(abs(ax4))-multi*nanmean(abs(ax4)) | ax4(:,1)>=nanmean(abs(ax4))+multi*nanmean(abs(ax4)));
ay4rows = find(ay4(:,1)<=nanmean(abs(ay4))-multi*nanmean(abs(ay4)) | ay4(:,1)>=nanmean(abs(ay4))+multi*nanmean(abs(ay4)));
az4rows = find(az4(:,1)<=nanmean(abs(az4))-multi*nanmean(abs(az4)) | az4(:,1)>=nanmean(abs(az4))+multi*nanmean(abs(az4)));

badax1 = ax1(ax1rows); badtx1 = d1.t(ax1rows);
baday1 = ay1(ay1rows); badty1 = d1.t(ay1rows);
badaz1 = az1(az1rows); badtz1 = d1.t(az1rows);
badax2 = ax2(ax2rows); badtx2 = d2.t(ax2rows);
baday2 = ay2(ay2rows); badty2 = d2.t(ay2rows);
badaz2 = az2(az2rows); badtz2 = d2.t(az2rows);
badax3 = ax3(ax3rows); badtx3 = d3.t(ax3rows);
baday3 = ay3(ay3rows); badty3 = d3.t(ay3rows);
badaz3 = az3(az3rows); badtz3 = d3.t(az3rows);
badax4 = ax4(ax4rows); badtx4 = d4.t(ax4rows);
baday4 = ay4(ay4rows); badty4 = d4.t(ay4rows);
badaz4 = az4(az4rows); badtz4 = d4.t(az4rows);

% how does Frederik want me to plot this exactly?
% grey out bad data?
ah(3)=subplot(5,2,[5 6]);
plot(d1.t(1:int:end-2),ax1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),ax2(1:int:end),'g')
plot(d3.t(1:int:end-2),ax3(1:int:end),'b')
plot(d4.t(1:int:end-2),ax4(1:int:end),'m')
plot(badtx1(1:int:end),badax1(1:int:end),'color',[0.7 0.7 0.7])
plot(badtx2(1:int:end),badax2(1:int:end),'color',[0.7 0.7 0.7])
plot(badtx3(1:int:end),badax3(1:int:end),'color',[0.7 0.7 0.7])
plot(badtx4(1:int:end),badax4(1:int:end),'color',[0.7 0.7 0.7])
legend({'GPS 1','GPS 2','GPS 3','GPS 4'},'Location','north','NumColumns',4)
grid on
longticks
xlim([d1.t(1) d1.t(end-2)])
ax = abs([ax1 ax2 ax3 ax4]);
ax = rmoutliers(ax,'mean');
ylim([-max(ax,[],'all')-0.005*abs(max(ax,[],'all')) max(ax,[],'all')+0.005*abs(max(ax,[],'all'))])
ylabel('a_x [m/s^2]')
title('Ship Acceleration Components')
xticklabels([])

ah(4)=subplot(5,2,[7 8]);
plot(d1.t(1:int:end-2),ay1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),ay2(1:int:end),'g')
plot(d3.t(1:int:end-2),ay3(1:int:end),'b')
plot(d4.t(1:int:end-2),ay4(1:int:end),'m')
plot(badty1(1:int:end),baday1(1:int:end),'color',[0.7 0.7 0.7])
plot(badty2(1:int:end),baday2(1:int:end),'color',[0.7 0.7 0.7])
plot(badty3(1:int:end),baday3(1:int:end),'color',[0.7 0.7 0.7])
plot(badty4(1:int:end),baday4(1:int:end),'color',[0.7 0.7 0.7])
grid on
longticks
xlim([d1.t(1) d1.t(end-2)])
ay = abs([ay1 ay2 ay3 ay4]);
ay = rmoutliers(ay,'mean');
ylim([-max(ay,[],'all')-0.005*abs(max(ay,[],'all')) max(ay,[],'all')+0.005*abs(max(ay,[],'all'))])
ylabel('a_y [m/s^2]')
xticklabels([])

ah(5)=subplot(5,2,[9 10]);
plot(d1.t(1:int:end-2),az1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),az2(1:int:end),'g')
plot(d3.t(1:int:end-2),az3(1:int:end),'b')
plot(d4.t(1:int:end-2),az4(1:int:end),'m')
plot(badtz1(1:int:end),badaz1(1:int:end),'color',[0.7 0.7 0.7])
plot(badtz2(1:int:end),badaz2(1:int:end),'color',[0.7 0.7 0.7])
plot(badtz3(1:int:end),badaz3(1:int:end),'color',[0.7 0.7 0.7])
plot(badtz4(1:int:end),badaz4(1:int:end),'color',[0.7 0.7 0.7])
grid on
longticks
xlim([d1.t(1) d1.t(end-2)])
az = abs([az1 az2 az3 az4]);
az = rmoutliers(az,'mean');
ylim([-max(az,[],'all')-0.005*abs(max(az,[],'all')) max(az,[],'all')+0.005*abs(max(az,[],'all'))])
ylabel('a_z [m/s^2]')

%keyboard

tt=supertit(ah([1 2]),sprintf('1 Hour of Ship Data Starting from %s',datestr(d1.t(1))));
movev(tt,0.3)

%a = annotation('textbox',[0.45 0.075 0 0],'String',['jaxs'],'FitBoxToText','on');
%a.FontSize = 12;

%figdisp(fname,[],'',2,[],'epstopdf')

%close