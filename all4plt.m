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
% Last modified by tschuh-at-princeton.edu, 11/22/2021

% currently statistics (correlation coeff, ployfit, rms, std)
% are computed using all data including grey out parts

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

% find rows where nsats <= 4
nthresh = 4;
% find rows where pdop >= 15 or = 0
pthresh = 15;
% plotting interval
int=15;

% find good (g) and bad (b) data
% [g b] = h
h1 = d1.height; h2 = d2.height; h3 = d3.height; h4 = d4.height;
p1 = d1.pdop; p2 = d2.pdop; p3 = d3.pdop; p4 = d4.pdop;
n1 = d1.nsats(:,1); n2 = d2.nsats(:,1); n3 = d3.nsats(:,1); n4 = d4.nsats(:,1);
g1 = h1; b1 = h1; g2 = h2; b2 = h2; g3 = h3; b3 = h3; g4 = h4; b4 = h4;
g1(p1>=pthresh | p1==0 | n1<=nthresh) = NaN;
b1(p1<pthresh & n1>nthresh) = NaN;
g2(p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
b2(p2<pthresh & n2>nthresh) = NaN;
g3(p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
b3(p3<pthresh & n3>nthresh) = NaN;
g4(p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
b4(p4<pthresh & n4>nthresh) = NaN;

% plot heights of all 4 units all on 1 plot
f=figure;
f.Position = [500 250 800 900];
ah(1)=subplot(5,2,[1 3]);
plot(d1.t(1:int:end),g1(1:int:end),'r')
hold on
plot(d2.t(1:int:end),g2(1:int:end),'g')
plot(d3.t(1:int:end),g3(1:int:end),'b')
plot(d4.t(1:int:end),g4(1:int:end),'k')
xlim([d1.t(1) d1.t(end)])
xticklabels([])
ylabel('Height relative to WGS84 [m]')
sht=title(sprintf('Ship Height (Every %dth Point)',int));
grid on
longticks
% to set best ylim, remove outliers from alldht
% then find the global min
allht = [d1.height d2.height d3.height d4.height];
allhtout = rmoutliers(allht,'mean');
outpct = (length(allht)-length(allhtout))*100/length(allht);
ylim([min(allhtout,[],'all')-0.005*abs(min(allhtout,[],'all')) max(allhtout,[],'all')+0.005*abs(max(allhtout,[],'all'))])
a=annotation('textbox',[0.325 0.655 0 0],'String',[sprintf('%05.2f%% Outliers',outpct)],'FitBoxToText','on');
a.FontSize = 8;
% grey out bad data
plot(d1.t(1:int:end),b1(1:int:end),'color',[0.7 0.7 0.7])
plot(d2.t(1:int:end),b2(1:int:end),'color',[0.7 0.7 0.7])
plot(d3.t(1:int:end),b3(1:int:end),'color',[0.7 0.7 0.7])
plot(d4.t(1:int:end),b4(1:int:end),'color',[0.7 0.7 0.7])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot distances between all 4 GPS units
% compute all 6 distances between 4 GPS receivers
dist12 = sqrt((d1.xyz(:,1)-d2.xyz(:,1)).^2 + (d1.xyz(:,2)-d2.xyz(:,2)).^2 + (d1.xyz(:,3)-d2.xyz(:,3)).^2);
normdist12 = dist12 - nanmean(dist12) + 1;
dist12 = rmNaNrows(dist12); p = polyfit([1:length(dist12)]',dist12,1);
a12 = 1000*p(1); b12 = p(2); rms12 = rms(dist12); std12 = std(dist12);
dist13 = sqrt((d1.xyz(:,1)-d3.xyz(:,1)).^2 + (d1.xyz(:,2)-d3.xyz(:,2)).^2 + (d1.xyz(:,3)-d3.xyz(:,3)).^2);
normdist13 = dist13 - nanmean(dist13) + 2;
dist13 = rmNaNrows(dist13); p = polyfit([1:length(dist13)]',dist13,1);
a13 = 1000*p(1); b13 = p(2); rms13 = rms(dist13); std13 = std(dist13);
dist14 = sqrt((d1.xyz(:,1)-d4.xyz(:,1)).^2 + (d1.xyz(:,2)-d4.xyz(:,2)).^2 + (d1.xyz(:,3)-d4.xyz(:,3)).^2);
normdist14 = dist14 - nanmean(dist14) + 3;
dist14 = rmNaNrows(dist14); p = polyfit([1:length(dist14)]',dist14,1);
a14 = 1000*p(1); b14 = p(2); rms14 = rms(dist14); std14 = std(dist14);
dist23 = sqrt((d2.xyz(:,1)-d3.xyz(:,1)).^2 + (d2.xyz(:,2)-d3.xyz(:,2)).^2 + (d2.xyz(:,3)-d3.xyz(:,3)).^2);
normdist23 = dist23 - nanmean(dist23) + 4;
dist23 = rmNaNrows(dist23); p = polyfit([1:length(dist23)]',dist23,1);
a23 = 1000*p(1); b23 = p(2); rms23 = rms(dist23); std23 = std(dist23);
dist24 = sqrt((d2.xyz(:,1)-d4.xyz(:,1)).^2 + (d2.xyz(:,2)-d4.xyz(:,2)).^2 + (d2.xyz(:,3)-d4.xyz(:,3)).^2);
normdist24 = dist24 - nanmean(dist24) + 5;
dist24 = rmNaNrows(dist24); p = polyfit([1:length(dist24)]',dist24,1);
a24 = 1000*p(1); b24 = p(2); rms24 = rms(dist24); std24 = std(dist24);
dist34 = sqrt((d3.xyz(:,1)-d4.xyz(:,1)).^2 + (d3.xyz(:,2)-d4.xyz(:,2)).^2 + (d3.xyz(:,3)-d4.xyz(:,3)).^2);
normdist34 = dist34 - nanmean(dist34) + 6;
dist34 = rmNaNrows(dist34); p = polyfit([1:length(dist34)]',dist34,1);
a34 = 1000*p(1); b34 = p(2); rms34 = rms(dist34); std34 = std(dist34);

% find good (g) and bad (b) data
% [g b] = h
d12 = normdist12; d13 = normdist13; d14 = normdist14;
d23 = normdist23; d24 = normdist24; d34 = normdist34;
good12 = d12; bad12 = d12; good13 = d13; bad13 = d13; good14 = d14; bad14 = d14;
good23 = d23; bad23 = d23; good24 = d24; bad24 = d24; good34 = d34; bad34 = d34;
good12(p1>=pthresh | p1==0 | n1<=nthresh | p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
bad12(p1<pthresh & n1>nthresh & p2<pthresh & n2>nthresh) = NaN;
good13(p1>=pthresh | p1==0 | n1<=nthresh | p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
bad13(p1<pthresh & n1>nthresh & p3<pthresh & n3>nthresh) = NaN;
good14(p1>=pthresh | p1==0 | n1<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bad14(p1<pthresh & n1>nthresh & p4<pthresh & n4>nthresh) = NaN;
good23(p2>=pthresh | p2==0 | n2<=nthresh | p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
bad23(p2<pthresh & n2>nthresh & p3<pthresh & n3>nthresh) = NaN;
good24(p2>=pthresh | p2==0 | n2<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bad24(p2<pthresh & n2>nthresh & p4<pthresh & n4>nthresh) = NaN;
good34(p3>=pthresh | p3==0 | n3<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bad34(p3<pthresh & n3>nthresh & p4<pthresh & n4>nthresh) = NaN;

ah(2)=subplot(5,2,[2 4]);
plot(d1.t,good12)
hold on
plot(d1.t,good13)
plot(d1.t,good14)
plot(d1.t,good23)
plot(d1.t,good24)
plot(d1.t,good34)
xlim([d1.t(1) d1.t(end)])
xticklabels([])
ylim([0.25 6.75])
yticklabels({'1-2','1-3','1-4','2-3','2-4','3-4'})
ylabel('GPS Pair')
gpst=title(sprintf('Distances between GPS Receivers'));
text(d1.t(850),6.4,sprintf('%.2e, %05.2f, %05.2f, %.2f',a34,b34,rms34,std34))
text(d1.t(850),5.4,sprintf('%.2e, %05.2f, %05.2f, %.2f',a24,b24,rms24,std24))
text(d1.t(850),4.4,sprintf('%.2e, %05.2f, %05.2f, %.2f',a23,b23,rms23,std23))
text(d1.t(850),3.4,sprintf('%.2e, %05.2f, %05.2f, %.2f',a14,b14,rms14,std14))
text(d1.t(850),2.4,sprintf('%.2e, %05.2f, %05.2f, %.2f',a13,b13,rms13,std13))
text(d1.t(850),1.4,sprintf('%.2e, %05.2f, %05.2f, %.2f',a12,b12,rms12,std12))
text(d1.t(520),0.5,sprintf('a [mm/s], b [m], rms [m], std [m]'))
grid on
longticks
% grey out bad data
plot(d1.t,bad12,'color',[0.7 0.7 0.7])
plot(d1.t,bad13,'color',[0.7 0.7 0.7])
plot(d1.t,bad14,'color',[0.7 0.7 0.7])
plot(d1.t,bad23,'color',[0.7 0.7 0.7])
plot(d1.t,bad24,'color',[0.7 0.7 0.7])
plot(d1.t,bad34,'color',[0.7 0.7 0.7])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot accelerations ax, ay, az
% first compute velocity components vx, vy, vz in cm/s
vx1 = 100*diff(d1.xyz(:,1))./seconds(diff(d1.t));
vy1 = 100*diff(d1.xyz(:,2))./seconds(diff(d1.t));
vz1 = 100*diff(d1.xyz(:,3))./seconds(diff(d1.t));
vx2 = 100*diff(d2.xyz(:,1))./seconds(diff(d2.t));
vy2 = 100*diff(d2.xyz(:,2))./seconds(diff(d2.t));
vz2 = 100*diff(d2.xyz(:,3))./seconds(diff(d2.t));
vx3 = 100*diff(d3.xyz(:,1))./seconds(diff(d3.t));
vy3 = 100*diff(d3.xyz(:,2))./seconds(diff(d3.t));
vz3 = 100*diff(d3.xyz(:,3))./seconds(diff(d3.t));
vx4 = 100*diff(d4.xyz(:,1))./seconds(diff(d4.t));
vy4 = 100*diff(d4.xyz(:,2))./seconds(diff(d4.t));
vz4 = 100*diff(d4.xyz(:,3))./seconds(diff(d4.t));

% time and spatial velocity average doesnt seem to work right
% vxavg = (vx1+vx2+vx3+vx4)./4;
% vyavg = (vy1+vy2+vy3+vy4)./4;
% vxyavg = sqrt(vxavg.^2 + vyavg.^2);
% vxytavg = nanmean(vxyavg);

v1 = sqrt(vx1.^2 + vy1.^2 + vz1.^2);
v2 = sqrt(vx2.^2 + vy2.^2 + vz2.^2);
v3 = sqrt(vx3.^2 + vy3.^2 + vz3.^2);
v4 = sqrt(vx4.^2 + vy4.^2 + vz4.^2);

% then compute acceleration components ax, ay, az in cm/s^2
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

% find good (g) and bad (b) data
% [g b] = h
gax1 = ax1; bax1 = ax1; gax2 = ax2; bax2 = ax2; gax3 = ax3; bax3 = ax3; gax4 = ax4; bax4 = ax4;
gax1(p1>=pthresh | p1==0 | n1<=nthresh) = NaN;
bax1(p1<pthresh & n1>nthresh) = NaN;
gax2(p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
bax2(p2<pthresh & n2>nthresh) = NaN;
gax3(p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
bax3(p3<pthresh & n3>nthresh) = NaN;
gax4(p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bax4(p4<pthresh & n4>nthresh) = NaN;
gay1 = ay1; bay1 = ay1; gay2 = ay2; bay2 = ay2; gay3 = ay3; bay3 = ay3; gay4 = ay4; bay4 = ay4;
gay1(p1>=pthresh | p1==0 | n1<=nthresh) = NaN;
bay1(p1<pthresh & n1>nthresh) = NaN;
gay2(p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
bay2(p2<pthresh & n2>nthresh) = NaN;
gay3(p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
bay3(p3<pthresh & n3>nthresh) = NaN;
gay4(p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bay4(p4<pthresh & n4>nthresh) = NaN;
gaz1 = az1; baz1 = az1; gaz2 = az2; baz2 = az2; gaz3 = az3; baz3 = az3; gaz4 = az4; baz4 = az4;
gaz1(p1>=pthresh | p1==0 | n1<=nthresh) = NaN;
baz1(p1<pthresh & n1>nthresh) = NaN;
gaz2(p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
baz2(p2<pthresh & n2>nthresh) = NaN;
gaz3(p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
baz3(p3<pthresh & n3>nthresh) = NaN;
gaz4(p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
baz4(p4<pthresh & n4>nthresh) = NaN;

a1 = sqrt(ax1.^2 + ay1.^2 + az1.^2); 
a2 = sqrt(ax2.^2 + ay2.^2 + az2.^2); 
a3 = sqrt(ax3.^2 + ay3.^2 + az3.^2); 
a4 = sqrt(ax4.^2 + ay4.^2 + az4.^2); 

% compute correlation coefficients
axcorr = corr([ax1 ax2 ax3 ax4],'rows','complete');
aycorr = corr([ay1 ay2 ay3 ay4],'rows','complete');
azcorr = corr([az1 az2 az3 az4],'rows','complete');

% plot ax
ah(3)=subplot(5,2,[5 6]);
plot(d1.t(1:int:end-2),gax1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),gax2(1:int:end),'g')
plot(d3.t(1:int:end-2),gax3(1:int:end),'b')
plot(d4.t(1:int:end-2),gax4(1:int:end),'k')
grid on
longticks([],3)
xlim([d1.t(1) d1.t(end-2)])
ax = abs([ax1 ax2 ax3 ax4]);
axout = rmoutliers(ax,'mean');
outpct = (length(ax)-length(axout))*100/length(ax);
ylim([-max(axout,[],'all')-0.005*abs(max(axout,[],'all')) max(axout,[],'all')+0.005*abs(max(axout,[],'all'))])
a=annotation('textbox',[0.77 0.61 0 0],'String',[sprintf('%05.2f%% Outliers',outpct)],'FitBoxToText','on');
a.FontSize = 8;
b=annotation('textbox',[0.13 0.625 0 0],'String',[sprintf('%.2f, %.2f, %.2f,\n%.2f, %.2f, %.2f',axcorr(1,2),axcorr(1,3),axcorr(1,4),axcorr(2,3),axcorr(2,4),axcorr(3,4))],'FitBoxToText','on');
b.FontSize = 8;
ylabel('a_x [cm/s^2]')
sat=title(sprintf('Ship Acceleration Components (Every %dth Point)',int));
movev(sat,2.5)
xticklabels([])
% grey out bad data
plot(d1.t(1:int:end-2),bax1(1:int:end),'color',[0.7 0.7 0.7])
plot(d2.t(1:int:end-2),bax2(1:int:end),'color',[0.7 0.7 0.7])
plot(d3.t(1:int:end-2),bax3(1:int:end),'color',[0.7 0.7 0.7])
plot(d4.t(1:int:end-2),bax4(1:int:end),'color',[0.7 0.7 0.7])

% plot ay
ah(4)=subplot(5,2,[7 8]);
plot(d1.t(1:int:end-2),gay1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),gay2(1:int:end),'g')
plot(d3.t(1:int:end-2),gay3(1:int:end),'b')
plot(d4.t(1:int:end-2),gay4(1:int:end),'k')
grid on
longticks([],3)
xlim([d1.t(1) d1.t(end-2)])
ay = abs([ay1 ay2 ay3 ay4]);
ayout = rmoutliers(ay,'mean');
outpct = (length(ay)-length(ayout))*100/length(ay);
ylim([-max(ayout,[],'all')-0.005*abs(max(ayout,[],'all')) max(ayout,[],'all')+0.005*abs(max(ayout,[],'all'))])
a=annotation('textbox',[0.77 0.4375 0 0],'String',[sprintf('%05.2f%% Outliers',outpct)],'FitBoxToText','on');
a.FontSize = 8;
b=annotation('textbox',[0.13 0.45 0 0],'String',[sprintf('%.2f, %.2f, %.2f,\n%.2f, %.2f, %.2f',aycorr(1,2),aycorr(1,3),aycorr(1,4),aycorr(2,3),aycorr(2,4),aycorr(3,4))],'FitBoxToText','on');
b.FontSize = 8;
c=annotation('textbox',[0.4 0.45 0 0],'String',[sprintf('GPS 1 - red, GPS 2 - green,\nGPS 3 - blue, GPS 4 - black')],'FitBoxToText','on');
c.FontSize = 8;
ylabel('a_y [cm/s^2]')
xticklabels([])
% grey out bad data
plot(d1.t(1:int:end-2),bay1(1:int:end),'color',[0.7 0.7 0.7])
plot(d2.t(1:int:end-2),bay2(1:int:end),'color',[0.7 0.7 0.7])
plot(d3.t(1:int:end-2),bay3(1:int:end),'color',[0.7 0.7 0.7])
plot(d4.t(1:int:end-2),bay4(1:int:end),'color',[0.7 0.7 0.7])

% plot az
ah(5)=subplot(5,2,[9 10]);
plot(d1.t(1:int:end-2),gaz1(1:int:end),'r')
hold on
plot(d2.t(1:int:end-2),gaz2(1:int:end),'g')
plot(d3.t(1:int:end-2),gaz3(1:int:end),'b')
plot(d4.t(1:int:end-2),gaz4(1:int:end),'k')
grid on
longticks([],3)
xlim([d1.t(1) d1.t(end-2)])
az = abs([az1 az2 az3 az4]);
azout = rmoutliers(az,'mean');
outpct = (length(az)-length(azout))*100/length(az);
ylim([-max(azout,[],'all')-0.005*abs(max(azout,[],'all')) max(azout,[],'all')+0.005*abs(max(azout,[],'all'))])
a=annotation('textbox',[0.77 0.265 0 0],'String',[sprintf('%05.2f%% Outliers',outpct)],'FitBoxToText','on');
a.FontSize = 8;
b=annotation('textbox',[0.13 0.2775 0 0],'String',[sprintf('%.2f, %.2f, %.2f,\n%.2f, %.2f, %.2f',azcorr(1,2),azcorr(1,3),azcorr(1,4),azcorr(2,3),azcorr(2,4),azcorr(3,4))],'FitBoxToText','on');
b.FontSize = 8;
c=annotation('textbox',[0.44 0.2775 0 0],'String',[sprintf('X12, X13, X14,\nX23, X24, X34')],'FitBoxToText','on');
c.FontSize = 8;
ylabel('a_z [cm/s^2]')
% grey out bad data
plot(d1.t(1:int:end-2),baz1(1:int:end),'color',[0.7 0.7 0.7])
plot(d2.t(1:int:end-2),baz2(1:int:end),'color',[0.7 0.7 0.7])
plot(d3.t(1:int:end-2),baz3(1:int:end),'color',[0.7 0.7 0.7])
plot(d4.t(1:int:end-2),baz4(1:int:end),'color',[0.7 0.7 0.7])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% finishing touches
tt=supertit(ah([1 2]),sprintf('1 Hour of Ship Data Starting from %s',datestr(d1.t(1))));
movev(tt,0.3)

a = annotation('textbox',[0.465 0.085 0 0],'String',['leg 1'],'FitBoxToText','on');
a.FontSize = 12;

%figdisp(fname,[],'',2,[],'epstopdf')

%close

%keyboard