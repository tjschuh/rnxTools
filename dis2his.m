function dis2his(files)
% DIS2HIS(files)
%
% Given Precise Point Position time series of four different units, computes
% their pairwise distances, calculates a least-squares regression line and
% produces histograms of residuals with quantile-quantile plots.
%
% INPUT:
% 
% files        cell with MAT-filename strings containing data structures
%
%
% EXAMPLE:
%
% dis2his({'0001-05340.mat','0002-05340.mat','0003-05340.mat','0004-05340.mat'})
%
% Originally written by tschuh-at-princeton.edu, 12/01/202
% Last modified by tschuh-at-princeton.edu, 01/21/2022
% Last modified by fjsimons-at-princeton.edu, 01/31/2022

% convert data to all be same time spans with no time gaps
d = mat2mod(files);
% new out put filename made from first
[~,fname,~] = fileparts(files{1});

% keep rows where nsats > nthresh and pdop < pthres and pdop~=0
nthresh = 4; pthresh = 15;

keyboard

% compute pairwise Euclidean distances between receivers
nk=nchoosek(1:length(d),2);

for k=1:size(nk,1)
  i=nk(k,1); j=nk(k,2);
  dest{k} = sqrt([d(i).xyz(:,1)-d(j).xyz(:,1)].^2 + ...
		 [d(i).xyz(:,2)-d(j).xyz(:,2)].^2 + ...
		 [d(i).xyz(:,3)-d(j).xyz(:,3)].^2);
  % find good (g) and bad (b) data so we're only working with non-greyed data
  dest{k}=dest{k}(d(i).pdop<pthresh & d(i).pdop~=0 & d(i).nsats(:,1)>nthresh & ...
		  d(j).pdop<pthresh & d(j).pdop~=0 & d(j).nsats(:,1)>nthresh);
end

% use d to find residuals (e)
p = polyfit([1:length(d12)]',d12,1); a12 = 1000*p(1); b12 = p(2);
x12 = (a12/1000).*[1:length(d12)]' + b12; e12 = 1000*(x12 - d12);

% Save the data - 000X-


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% plotting
% plot histograms with normal curves over top
% make histograms by using histcounts and bar
% make curves by using fitdist and pdf
f=figure;
f.Position = [250 500 1100 600];

ah1(1) = subplot(3,2,1);
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
% with 1 Dof, chi squared <= 4 signifies ~90% chance data is normal
% make red curve dotted if gof > 4
gof12 = stats12.chi2stat/stats12.df;
[yvals12,edges12] = histcounts(ee12,nbins12);
barc12 = 0.5*(edges12(1:end-1) + edges12(2:end));
bar12 = bar(barc12,yvals12,'BarWidth',1);
line12 = cosmo1(gca,ah1(1),sprintf('GPS Pair 1-2, # of Points = %i/%i',length(ee12),length(d1.t)),'Residuals [mm]','Counts',ee12,gof12,bar12);

ah1(2) = subplot(3,2,2);
try
    ee13 = rmoutliers(e13,'gesd');
catch
    ee13 = rmoutliers(e13,'percentiles',[10 90]);
end
nbins13 = round((max(ee13) - min(ee13))/(2*iqr(ee13)*(length(ee13))^(-1/3)));
[~,~,stats13] = chi2gof(ee13,'NBins',nbins13);
gof13 = stats13.chi2stat/stats13.df;
[yvals13,edges13] = histcounts(ee13,nbins13);
barc13 = 0.5*(edges13(1:end-1) + edges13(2:end));
bar13 = bar(barc13,yvals13,'BarWidth',1);
line13 = cosmo1(gca,ah1(2),sprintf('GPS Pair 1-3, # of Points = %i/%i',length(ee13),length(d1.t)),'Residuals [mm]','Counts',ee13,gof13,bar13);

ah1(3) = subplot(3,2,3);
try
    ee14 = rmoutliers(e14,'gesd');
catch
    ee14 = rmoutliers(e14,'percentiles',[10 90]);
end
nbins14 = round((max(ee14) - min(ee14))/(2*iqr(ee14)*(length(ee14))^(-1/3)));
[~,~,stats14] = chi2gof(ee14,'NBins',nbins14);
gof14 = stats14.chi2stat/stats14.df;
[yvals14,edges14] = histcounts(ee14,nbins14);
barc14 = 0.5*(edges14(1:end-1) + edges14(2:end));
bar14 = bar(barc14,yvals14,'BarWidth',1);
line14 = cosmo1(gca,ah1(3),sprintf('GPS Pair 1-4, # of Points = %i/%i',length(ee14),length(d1.t)),'Residuals [mm]','Counts',ee14,gof14,bar14);

ah1(4) = subplot(3,2,4);
try
    ee23 = rmoutliers(e23,'gesd');
catch
    ee23 = rmoutliers(e23,'percentiles',[10 90]);
end
nbins23 = round((max(ee23) - min(ee23))/(2*iqr(ee23)*(length(ee23))^(-1/3)));
[~,~,stats23] = chi2gof(ee23,'NBins',nbins23);
gof23 = stats23.chi2stat/stats23.df;
[yvals23,edges23] = histcounts(ee23,nbins23);
barc23 = 0.5*(edges23(1:end-1) + edges23(2:end));
bar23 = bar(barc23,yvals23,'BarWidth',1);
line23 = cosmo1(gca,ah1(4),sprintf('GPS Pair 2-3, # of Points = %i/%i',length(ee23),length(d1.t)),'Residuals [mm]','Counts',ee23,gof23,bar23);

ah1(5) = subplot(3,2,5);
try
    ee24 = rmoutliers(e24,'gesd');
catch
    ee24 = rmoutliers(e24,'percentiles',[10 90]);
end
nbins24 = round((max(ee24) - min(ee24))/(2*iqr(ee24)*(length(ee24))^(-1/3)));
[~,~,stats24] = chi2gof(ee24,'NBins',nbins24);
gof24 = stats24.chi2stat/stats24.df;
[yvals24,edges24] = histcounts(ee24,nbins24);
barc24 = 0.5*(edges24(1:end-1) + edges24(2:end));
bar24 = bar(barc24,yvals24,'BarWidth',1);
line24 = cosmo1(gca,ah1(5),sprintf('GPS Pair 2-4, # of Points = %i/%i',length(ee24),length(d1.t)),'Residuals [mm]','Counts',ee24,gof24,bar24);

ah1(6) = subplot(3,2,6);
try
    ee34 = rmoutliers(e34,'gesd');
catch
    ee34 = rmoutliers(e34,'percentiles',[10 90]);
end
nbins34 = round((max(ee34) - min(ee34))/(2*iqr(ee34)*(length(ee34))^(-1/3)));
[~,~,stats34] = chi2gof(ee34,'NBins',nbins34);
gof34 = stats34.chi2stat/stats34.df;
[yvals34,edges34] = histcounts(ee34,nbins34);
barc34 = 0.5*(edges34(1:end-1) + edges34(2:end));
bar34 = bar(barc34,yvals34,'BarWidth',1);
line34 = cosmo1(gca,ah1(6),sprintf('GPS Pair 3-4, # of Points = %i/%i',length(ee34),length(d1.t)),'Residuals [mm]','Counts',ee34,gof34,bar34);

% finishing touches
tt=supertit(ah1([1 2]),sprintf('Demeaned Residuals of Ship Data from %s to %s',datestr(d1.t(1)),datestr(d1.t(end))));
movev(tt,0.3)

%figdisp(sprintf('histo-%s',fname),[],'',2,[],'epstopdf')

%close

% plot qq plots for each dataset to measure how "normal" data is
g=figure;
g.Position = [250 500 1100 600];

ah2(1) = subplot(3,2,1);
qq12 = qqplot(ee12);
cosmo2('GPS Pair 1-2',qq12)

ah2(2) = subplot(3,2,2);
qq13 = qqplot(ee13);
cosmo2('GPS Pair 1-3',qq13)

ah2(3) = subplot(3,2,3);
qq14 = qqplot(ee14);
cosmo2('GPS Pair 1-4',qq14)

ah2(4) = subplot(3,2,4);
qq23 = qqplot(ee23);
cosmo2('GPS Pair 2-3',qq23)

ah2(5) = subplot(3,2,5);
qq24 = qqplot(ee24);
cosmo2('GPS Pair 2-4',qq24)

ah2(6) = subplot(3,2,6);
qq34 = qqplot(ee34);
cosmo2('GPS Pair 3-4',qq34)

% finishing touches
tt=supertit(ah1([1 2]),sprintf('QQ Plots of Residuals vs Standard Normals (%s to %s)',datestr(d1.t(1)),datestr(d1.t(end))));
movev(tt,0.3)

%figdisp(sprintf('qqplot-%s',fname),[],'',2,[],'epstopdf')

%close

% cosmetics for histogram and pdf plots
function line = cosmo1(ax,ah,titl,xlab,ylab,data,gof,bar)
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
ylim([0 max(bar.YData)+0.1*max(bar.YData)])
longticks([],2)
text(1.55*std(data),7.25*ah.YLim(2)/10,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f\ngof = %.0f',std(data),median(data),mean(data),gof),'FontSize',9)
pct = (length(data(data<=round(3*std(data)) & data>=round(-3*std(data))))/length(data))*100;
text(-2.9*std(data),8*ah.YLim(2)/10,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',pct,min(data),max(data)),'FontSize',9)
bar.FaceColor = [0.4 0.6667 0.8431]; %light blue bars
% plot vertical line at median
hold on
xline(median(data),'k--','LineWidth',2);
% plot pd curve on top of histogram
pd = fitdist(data,'Normal');
xvals = [-3*std(data):3*std(data)];
yvals = pdf(pd,xvals);
area = sum(bar.YData)*diff(bar.XData(1:2));
line = plot(xvals,yvals*area,'r','LineWidth',2);
% if gof > 4 make red curve dotted b/c data is not normal
if gof > 4
    line.LineStyle = '--';
end

% cosmetics for qq plots
function cosmo2(titl,qq)
grid on
longticks([],2)
title(titl)
ylabel('Residual Quantiles')
%xlim([-4 4])
%ylim([-100 100])
qq(1).Marker = '.';
qq(1).MarkerSize = 8;
qq(3).LineWidth = 2;
qq(3).LineStyle = '--';
