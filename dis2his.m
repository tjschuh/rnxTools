function dis2his(unit1file,unit2file,unit3file,unit4file,nbins)
% DIS2HIS(unit1file,unit2file,unit3file,unit4file,nbins)
%
% compute distance between 6 sets of reciever pairs
% calculate linear polyfit and residuals
% produce histogram of residuals
%
% INPUT:
%
% unit1file     mat file containing data collected by unit 1
% unit2file     mat file containing data collected by unit 2
% unit3file     mat file containing data collected by unit 3
% unit4file     mat file containing data collected by unit 4
% nbins         number of bins desired for histograms [default: 30]
%
% Originally written by tschuh-at-princeton.edu, 12/01/2021
% Last modified by tschuh-at-princeton.edu, 01/11/2022

% use mat2mod to convert data to all be same time spans with no time gaps
[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);
[~,fname,~] = fileparts(unit1file);

% plot distances between all 4 GPS units
% compute all 6 distances between 4 GPS receivers
dist12 = sqrt((d1.xyz(:,1)-d2.xyz(:,1)).^2 + (d1.xyz(:,2)-d2.xyz(:,2)).^2 + (d1.xyz(:,3)-d2.xyz(:,3)).^2);
normdist12 = dist12 - nanmean(dist12) + 1;
dist12 = rmNaNrows(dist12); p = polyfit([1:length(dist12)]',dist12,1);
a12 = 1000*p(1); b12 = p(2); rms12 = rms(dist12); std12 = std(1000*dist12);
x12 = (a12/1000).*[1:length(dist12)]' + b12; e12 = 1000*(x12 - dist12); erms12 = rms(e12);
dist13 = sqrt((d1.xyz(:,1)-d3.xyz(:,1)).^2 + (d1.xyz(:,2)-d3.xyz(:,2)).^2 + (d1.xyz(:,3)-d3.xyz(:,3)).^2);
normdist13 = dist13 - nanmean(dist13) + 2;
dist13 = rmNaNrows(dist13); p = polyfit([1:length(dist13)]',dist13,1);
a13 = 1000*p(1); b13 = p(2); rms13 = rms(dist13); std13 = std(1000*dist13);
x13 = (a13/1000).*[1:length(dist13)]' + b13; e13 = 1000*(x13 - dist13); erms13 = rms(e13);
dist14 = sqrt((d1.xyz(:,1)-d4.xyz(:,1)).^2 + (d1.xyz(:,2)-d4.xyz(:,2)).^2 + (d1.xyz(:,3)-d4.xyz(:,3)).^2);
normdist14 = dist14 - nanmean(dist14) + 3;
dist14 = rmNaNrows(dist14); p = polyfit([1:length(dist14)]',dist14,1);
a14 = 1000*p(1); b14 = p(2); rms14 = rms(dist14); std14 = std(1000*dist14);
x14 = (a14/1000).*[1:length(dist14)]' + b14; e14 = 1000*(x14 - dist14); erms14 = rms(e14);
dist23 = sqrt((d2.xyz(:,1)-d3.xyz(:,1)).^2 + (d2.xyz(:,2)-d3.xyz(:,2)).^2 + (d2.xyz(:,3)-d3.xyz(:,3)).^2);
normdist23 = dist23 - nanmean(dist23) + 4;
dist23 = rmNaNrows(dist23); p = polyfit([1:length(dist23)]',dist23,1);
a23 = 1000*p(1); b23 = p(2); rms23 = rms(dist23); std23 = std(1000*dist23);
x23 = (a23/1000).*[1:length(dist23)]' + b23; e23 = 1000*(x23 - dist23); erms23 = rms(e23);
dist24 = sqrt((d2.xyz(:,1)-d4.xyz(:,1)).^2 + (d2.xyz(:,2)-d4.xyz(:,2)).^2 + (d2.xyz(:,3)-d4.xyz(:,3)).^2);
normdist24 = dist24 - nanmean(dist24) + 5;
dist24 = rmNaNrows(dist24); p = polyfit([1:length(dist24)]',dist24,1);
a24 = 1000*p(1); b24 = p(2); rms24 = rms(dist24); std24 = std(1000*dist24);
x24 = (a24/1000).*[1:length(dist24)]' + b24; e24 = 1000*(x24 - dist24); erms24 = rms(e24);
dist34 = sqrt((d3.xyz(:,1)-d4.xyz(:,1)).^2 + (d3.xyz(:,2)-d4.xyz(:,2)).^2 + (d3.xyz(:,3)-d4.xyz(:,3)).^2);
normdist34 = dist34 - nanmean(dist34) + 6;
dist34 = rmNaNrows(dist34); p = polyfit([1:length(dist34)]',dist34,1);
a34 = 1000*p(1); b34 = p(2); rms34 = rms(dist34); std34 = std(1000*dist34);
x34 = (a34/1000).*[1:length(dist34)]' + b34; e34 = 1000*(x34 - dist34); erms34 = rms(e34);

% plotting
f=figure;
f.Position = [250 500 1100 600];

defval('nbins',25)

% rmoutliers
% by default, an outlier is a value > 3 scaled median absolute deviations (MAD)

ah(1) = subplot(3,2,1);
ee12 = rmoutliers(e12);
histObj = histfit(ee12,nbins);
cosmo(gca,'GPS Pair 1-2','Residuals [mm]','Counts',ee12,histObj(1))

ah(2) = subplot(3,2,2);
ee13 = rmoutliers(e13);
histObj = histfit(ee13,nbins);
cosmo(gca,'GPS Pair 1-3','Residuals [mm]','Counts',ee13,histObj(1))

ah(3) = subplot(3,2,3);
ee14 = rmoutliers(e14);
histObj = histfit(ee14,nbins);
cosmo(gca,'GPS Pair 1-4','Residuals [mm]','Counts',ee14,histObj(1))

ah(4) = subplot(3,2,4);
ee23 = rmoutliers(e23);
histObj = histfit(ee23,nbins);
cosmo(gca,'GPS Pair 2-3','Residuals [mm]','Counts',ee23,histObj(1))

ah(5) = subplot(3,2,5);
ee24 = rmoutliers(e24);
histObj = histfit(ee24,nbins);
cosmo(gca,'GPS Pair 2-4','Residuals [mm]','Counts',ee24,histObj(1))

ah(6) = subplot(3,2,6);
ee34 = rmoutliers(e34);
histObj = histfit(ee34,nbins);
cosmo(gca,'GPS Pair 3-4','Residuals [mm]','Counts',ee34,histObj(1))

% finishing touches
tt=supertit(ah([1 2]),sprintf('Demeaned Residuals of Ship Data from %s to %s',datestr(d1.t(1)),datestr(d1.t(end))));
movev(tt,0.3)

figdisp(sprintf('histo-%s',fname),[],'',2,[],'epstopdf')

close

% Cosmetics
function cosmo(ax,titl,xlab,ylab,rawdata,hobj)
ax.XGrid = 'on';
ax.YGrid = 'off';
ax.GridColor = [0 0 0];
ax.TickLength = [0 0];
title(titl)
xlabel(xlab)
xlim([round(-3*std(rawdata),2) round(3*std(rawdata),2)])
xticks([round(-3*std(rawdata),2) round(-2*std(rawdata),2) round(-std(rawdata),2) 0 round(std(rawdata),2) round(2*std(rawdata),2) round(3*std(rawdata),2)])
xticklabels({round(-3*std(rawdata),0),round(-2*std(rawdata),0),round(-std(rawdata),0),0,round(std(rawdata),0),round(2*std(rawdata),0),round(3*std(rawdata),0)})
ylabel(ylab)
ylim([0 max(hobj.YData)+0.1*max(hobj.YData)])
longticks([],2)
hobj.FaceColor = [0.4 0.6667 0.8431]; %light blue bars
%hobj.FaceColor = [0.466 0.674 0.188]; %lime green bars
text(1.55*std(rawdata),4*max(hobj.YData)/5,sprintf('std = %.0f\nmed = %.0f',std(rawdata),median(rawdata)),'FontSize',9)
pct = (length(rawdata(rawdata<=round(3*std(rawdata)) & rawdata>=round(-3*std(rawdata))))/length(rawdata))*100;
text(-2.9*std(rawdata),90*max(hobj.YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',pct,min(rawdata),max(rawdata)),'FontSize',9)
% plot vertical line at median
hold on
xline(median(rawdata),'k-.','LineWidth',2);