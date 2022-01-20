function dis2his(unit1file,unit2file,unit3file,unit4file)
% DIS2HIS(unit1file,unit2file,unit3file,unit4file)
%
% compute distances between 6 sets of receiver pairs
% calculate linear polyfit and residuals
% produce histogram of residuals
%
% INPUT:
%
% unit1file     mat file containing data collected by unit 1
% unit2file     mat file containing data collected by unit 2
% unit3file     mat file containing data collected by unit 3
% unit4file     mat file containing data collected by unit 4
%
% Originally written by tschuh-at-princeton.edu, 12/01/2021
% Last modified by tschuh-at-princeton.edu, 01/20/2022

% use mat2mod to convert data to all be same time spans with no time gaps
[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);
[~,fname,~] = fileparts(unit1file);

% compute distances between receivers
dist12 = sqrt((d1.xyz(:,1)-d2.xyz(:,1)).^2 + (d1.xyz(:,2)-d2.xyz(:,2)).^2 + (d1.xyz(:,3)-d2.xyz(:,3)).^2);
dist13 = sqrt((d1.xyz(:,1)-d3.xyz(:,1)).^2 + (d1.xyz(:,2)-d3.xyz(:,2)).^2 + (d1.xyz(:,3)-d3.xyz(:,3)).^2);
dist14 = sqrt((d1.xyz(:,1)-d4.xyz(:,1)).^2 + (d1.xyz(:,2)-d4.xyz(:,2)).^2 + (d1.xyz(:,3)-d4.xyz(:,3)).^2);
dist23 = sqrt((d2.xyz(:,1)-d3.xyz(:,1)).^2 + (d2.xyz(:,2)-d3.xyz(:,2)).^2 + (d2.xyz(:,3)-d3.xyz(:,3)).^2);
dist24 = sqrt((d2.xyz(:,1)-d4.xyz(:,1)).^2 + (d2.xyz(:,2)-d4.xyz(:,2)).^2 + (d2.xyz(:,3)-d4.xyz(:,3)).^2);
dist34 = sqrt((d3.xyz(:,1)-d4.xyz(:,1)).^2 + (d3.xyz(:,2)-d4.xyz(:,2)).^2 + (d3.xyz(:,3)-d4.xyz(:,3)).^2);

% find rows where nsats <= 4 and/or where pdop >= 15 or = 0
nthresh = 4; pthresh = 15;

% redefine pdop and nsats so they are easier to work with
p1 = d1.pdop; p2 = d2.pdop; p3 = d3.pdop; p4 = d4.pdop;
n1 = d1.nsats(:,1); n2 = d2.nsats(:,1); n3 = d3.nsats(:,1); n4 = d4.nsats(:,1);

% find good (g) and bad (b) data so we're only working with non-greyed data
% [g b] = dist
good12 = dist12; good13 = dist13; good14 = dist14; good23 = dist23; good24 = dist24; good34 = dist34; 
good12(p1>=pthresh | p1==0 | n1<=nthresh | p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
good13(p1>=pthresh | p1==0 | n1<=nthresh | p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
good14(p1>=pthresh | p1==0 | n1<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
good23(p2>=pthresh | p2==0 | n2<=nthresh | p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
good24(p2>=pthresh | p2==0 | n2<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
good34(p3>=pthresh | p3==0 | n3<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;

% remove any rows containing NaNs
d12 = rmNaNrows(good12);
d13 = rmNaNrows(good13);
d14 = rmNaNrows(good14);
d23 = rmNaNrows(good23);
d24 = rmNaNrows(good24);
d34 = rmNaNrows(good34);

% use d to find residuals (e)
p = polyfit([1:length(d12)]',d12,1); a12 = 1000*p(1); b12 = p(2);
x12 = (a12/1000).*[1:length(d12)]' + b12; e12 = 1000*(x12 - d12);
p = polyfit([1:length(d13)]',d13,1); a13 = 1000*p(1); b13 = p(2);
x13 = (a13/1000).*[1:length(d13)]' + b13; e13 = 1000*(x13 - d13);
p = polyfit([1:length(d14)]',d14,1); a14 = 1000*p(1); b14 = p(2);
x14 = (a14/1000).*[1:length(d14)]' + b14; e14 = 1000*(x14 - d14);
p = polyfit([1:length(d23)]',d23,1); a23 = 1000*p(1); b23 = p(2);
x23 = (a23/1000).*[1:length(d23)]' + b23; e23 = 1000*(x23 - d23);
p = polyfit([1:length(d24)]',d24,1); a24 = 1000*p(1); b24 = p(2);
x24 = (a24/1000).*[1:length(d24)]' + b24; e24 = 1000*(x24 - d24);
p = polyfit([1:length(d34)]',d34,1); a34 = 1000*p(1); b34 = p(2);
x34 = (a34/1000).*[1:length(d34)]' + b34; e34 = 1000*(x34 - d34);

% plotting
f=figure;
f.Position = [250 500 1100 600];

% plot histogram with normal curve over top
ah(1) = subplot(3,2,1);
% remove outliers to get better results
try
    ee12 = rmoutliers(e12,'gesd');
catch
    ee12 = rmoutliers(e12,'percentiles',[10 90]);
end
% nbins is computed for each dataset using Freedman-Diaconis' Rule
% this is a personal choice over other methods including Sturges' Rule
% experimented with other methods and this was my preference
nbins12 = round((max(ee12) - min(ee12))/(2*iqr(ee12)*(length(ee12))^(-1/3)));
% calculate goodness of fit (gof) compared to a normal distribution
[~,~,stats12] = chi2gof(ee12,'NBins',nbins12);
% divide chi squared by degrees of freedom to reduce to 1 DoF
% with 1 Dof, chi squared <= 3 signifies ~93% chance data is normal
% make red curve dotted if gof > 3
gof12 = stats12.chi2stat/stats12.df;
histObj12 = histfit(ee12,nbins12);
cosmo(gca,ah(1),sprintf('GPS Pair 1-2, # of Points = %i/%i',length(ee12),length(d1.t)),'Residuals [mm]','Counts',ee12,gof12,histObj12)

ah(2) = subplot(3,2,2);
try
    ee13 = rmoutliers(e13,'gesd');
catch
    ee13 = rmoutliers(e13,'percentiles',[10 90]);
end
nbins13 = round((max(ee13) - min(ee13))/(2*iqr(ee13)*(length(ee13))^(-1/3)));
[~,~,stats13] = chi2gof(ee13,'NBins',nbins13);
gof13 = stats13.chi2stat/stats13.df;
histObj13 = histfit(ee13,nbins13);
cosmo(gca,ah(2),sprintf('GPS Pair 1-3, # of Points = %i/%i',length(ee13),length(d1.t)),'Residuals [mm]','Counts',ee13,gof13,histObj13)

ah(3) = subplot(3,2,3);
try
    ee14 = rmoutliers(e14,'gesd');
catch
    ee14 = rmoutliers(e14,'percentiles',[10 90]);
end
nbins14 = round((max(ee14) - min(ee14))/(2*iqr(ee14)*(length(ee14))^(-1/3)));
[~,~,stats14] = chi2gof(ee14,'NBins',nbins14);
gof14 = stats14.chi2stat/stats14.df;
histObj14 = histfit(ee14,nbins14);
cosmo(gca,ah(3),sprintf('GPS Pair 1-4, # of Points = %i/%i',length(ee14),length(d1.t)),'Residuals [mm]','Counts',ee14,gof14,histObj14)

ah(4) = subplot(3,2,4);
try
    ee23 = rmoutliers(e23,'gesd');
catch
    ee23 = rmoutliers(e23,'percentiles',[10 90]);
end
nbins23 = round((max(ee23) - min(ee23))/(2*iqr(ee23)*(length(ee23))^(-1/3)));
[~,~,stats23] = chi2gof(ee23,'NBins',nbins23);
gof23 = stats23.chi2stat/stats23.df;
histObj23 = histfit(ee23,nbins23);
cosmo(gca,ah(4),sprintf('GPS Pair 2-3, # of Points = %i/%i',length(ee23),length(d1.t)),'Residuals [mm]','Counts',ee23,gof23,histObj23)

ah(5) = subplot(3,2,5);
try
    ee24 = rmoutliers(e24,'gesd');
catch
    ee24 = rmoutliers(e24,'percentiles',[10 90]);
end
nbins24 = round((max(ee24) - min(ee24))/(2*iqr(ee24)*(length(ee24))^(-1/3)));
[~,~,stats24] = chi2gof(ee24,'NBins',nbins24);
gof24 = stats24.chi2stat/stats24.df;
histObj24 = histfit(ee24,nbins24);
cosmo(gca,ah(5),sprintf('GPS Pair 2-4, # of Points = %i/%i',length(ee24),length(d1.t)),'Residuals [mm]','Counts',ee24,gof24,histObj24)

ah(6) = subplot(3,2,6);
try
    ee34 = rmoutliers(e34,'gesd');
catch
    ee34 = rmoutliers(e34,'percentiles',[10 90]);
end
nbins34 = round((max(ee34) - min(ee34))/(2*iqr(ee34)*(length(ee34))^(-1/3)));
[~,~,stats34] = chi2gof(ee34,'NBins',nbins34);
gof34 = stats34.chi2stat/stats34.df;
histObj34 = histfit(ee34,nbins34);
cosmo(gca,ah(6),sprintf('GPS Pair 3-4, # of Points = %i/%i',length(ee34),length(d1.t)),'Residuals [mm]','Counts',ee34,gof34,histObj34)

% finishing touches
tt=supertit(ah([1 2]),sprintf('Demeaned Residuals of Ship Data from %s to %s',datestr(d1.t(1)),datestr(d1.t(end))));
movev(tt,0.3)

%figdisp(sprintf('histo-%s',fname),[],'',2,[],'epstopdf')

%close

% cosmetics
function cosmo(ax,ah,titl,xlab,ylab,data,gof,hobj)
ax.XGrid = 'on';
ax.YGrid = 'off';
ax.GridColor = [0 0 0];
ax.TickLength = [0 0];
title(titl)
xlabel(xlab)
xlim([round(-3*std(data),2) round(3*std(data),2)])
xticks([round(-3*std(data),2) round(-2*std(data),2) round(-std(data),2) 0 round(std(data),2) round(2*std(data),2) round(3*std(data),2)])
xticklabels({round(-3*std(data),0),round(-2*std(data),0),round(-std(data),0),0,round(std(data),0),round(2*std(data),0),round(3*std(data),0)})
ylabel(ylab)
ylim([0 max(hobj(1).YData)+0.1*max(hobj(1).YData)])
longticks([],2)
hobj(1).FaceColor = [0.4 0.6667 0.8431]; %light blue bars
text(1.55*std(data),7.25*ah.YLim(2)/10,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f\ngof = %.0f',std(data),median(data),mean(data),gof),'FontSize',9)
pct = (length(data(data<=round(3*std(data)) & data>=round(-3*std(data))))/length(data))*100;
text(-2.9*std(data),8*ah.YLim(2)/10,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',pct,min(data),max(data)),'FontSize',9)
% if gof > 3 make red curve dotted b/c data is not normal
if gof > 3
    hobj(2).LineStyle = '--';
end
% plot vertical line at median
hold on
xline(median(data),'k--','LineWidth',2);