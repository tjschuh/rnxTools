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

% new output filename made from first, you'll save the full info
[~,fname,~] = fileparts(files{1});
fname=sprintf('000X-%s.mat',suf(fname,'-'));

% keep rows where nsats > nthresh and pdop < pthres and pdop~=0
nthresh = 4; pthresh = 15;
% outlier removal by percentile
percs=[10 90];

if exist(fname)~=2
  % convert data to all be same time spans with no time gaps
  d = mat2mod(files);
  % compute pairwise Euclidean distances between receivers
  nk=nchoosek(1:length(d),2);

  for k=1:size(nk,1)
    i=nk(k,1); j=nk(k,2);
    % Remember the times etc were prematched
    dest{k} = sqrt([d(i).xyz(:,1)-d(j).xyz(:,1)].^2 + ...
		   [d(i).xyz(:,2)-d(j).xyz(:,2)].^2 + ...
		   [d(i).xyz(:,3)-d(j).xyz(:,3)].^2);
    % find the good data condition
    cond=d(i).pdop<pthresh & d(i).pdop~=0 & d(i).nsats(:,1)>nthresh & ...
	 d(j).pdop<pthresh & d(j).pdop~=0 & d(j).nsats(:,1)>nthresh;
    % Calculate the residuals of the linear fit, applying condition
    thetimes=seconds(d(i).t(cond)-d(i).t(cond(1)));
    p{k}=polyfit(thetimes,dest{k}(cond),1);
    % Calculate residuals
    e{k}=dest{k}(cond)-polyval(p{k},thetimes);
    % remove outliers to get better results
    try
      ee{k}=rmoutliers(e{k},'gesd');
      em{k}='gesd';
    catch
      ee{k} = rmoutliers(e{k},'percentiles',percs);
      em{k}='percentiles';
    end
  end
  % Save whatever you need 
  save(fname,'e','p','ee','em','percs','nthresh','pthresh','nk')
else
  load(fname)
end

keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% plotting
% plot histograms with normal curves over top
% make histograms by using histcounts and bar
% make curves by using fitdist and pdf
f=figure;
f.Position = [250 500 1100 600];

ah1(1) = subplot(3,2,1);
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
