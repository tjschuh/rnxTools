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

if exist(fname)~=3
  % convert data to all be same time spans with no time gaps
  [d,tmax] = mat2mod(files);
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
    keyboard
    % remove outliers to get better results
    try
      ee{k}=rmoutliers(e{k},'gesd');
      em{k}='gesd';
    catch
      ee{k} = rmoutliers(e{k},'percentiles',percs);
      em{k}='percentiles';
    end
  end
  % Save whatever you need, all still in standard units
  save(fname,'e','p','ee','em','percs','nthresh','pthresh','nk','tmax')
else
  load(fname)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plotting in case you have exactly 4 files, hence 6 distances
% plot histograms with normal curves over top
% make histograms by using histcounts and bar
% make curves by using fitdist and pdf
f=figure(1); clf
[ah,ha]=krijetem(subnum(3,2));

% Convert to mm
ucon=1000;

for k=1:length(ah)
  % Unit conversion
  ee{k}=ee{k}*ucon;
  e{k}=e{k}*ucon;
  axes(ah(k))
  % nbins is computed for each dataset using Freedman-Diaconis' Rule
  % this is a personal choice over other methods including Sturges' Rule
  % experimented with other methods and this was my preference
  nbins=round((max(ee{k})-min(ee{k}))/(2*iqr(ee{k})*(length(ee{k}))^(-1/3)));
  % calculate goodness of fit (gof) compared to a normal distribution
  [~,~,stats]=chi2gof(ee{k},'NBins',nbins);
  % divide chi squared by degrees of freedom to reduce to 1 DoF
  % with 1 Dof, chi squared <= 4 signifies ~90% chance data are normal
  % will make red curve dotted if gof > 4
  gof=stats.chi2stat/stats.df;
  [yvals,edges]=histcounts(ee{k},nbins);
  barc{k}=0.5*(edges(1:end-1)+edges(2:end));
  b{k}=bar(barc{k},yvals,'BarWidth',1);
  % Cosmetics
  lain{k}=cosmo1(ah(k),ah(k),...
		 sprintf('GPS Pair %i-%i, # of Points = %i/%i',nk(k,1),nk(k,2),...
			 length(ee{k}),length(e{k})),...
		 'Residuals [mm]','Counts',e{k},gof,b{k});
end

% finishing touches - you should keep minmax times from before
tt=supertit(ah([1 2]),sprintf('Demeaned Residuals of Ship Data from %s to %s',...
			       datestr(tmax(1)),datestr(tmax(2))));
movev(tt,0.3)

keyboard

%figdisp(sprintf('histo-%s',fname),[],'',2,[],'epstopdf')

%close

% plot qq plots for each dataset to measure how "normal" data is
g=figure;
g.Position = [250 500 1100 600];

ah2(1) = subplot(3,2,1);
qq{k} = qqplot(ee12);
cosmo2('GPS Pair 1-2',qq12)

% finishing touches
tt=supertit(ah1([1 2]),sprintf('QQ Plots of Residuals vs Standard Normals (%s to %s)',datestr(d1.t(1)),datestr(d1.t(end))));
movev(tt,0.3)

%figdisp(sprintf('qqplot-%s',fname),[],'',2,[],'epstopdf')

%close

% cosmetics for histogram and pdf plots
function lain = cosmo1(ax,ah,titl,xlab,ylab,data,gof,b)
ax.XGrid = 'on';
ax.YGrid = 'off';
ax.GridColor = [0 0 0];
ax.TickLength = [0 0];
title(titl)
xlabel(xlab)
% later versions could use XTICKS and XLABELS 
         xlim(round([-3 3]*std(data),2))
     ax.XTick=round([-3:3]*std(data),2);
ax.XTickLabel=round([-3:3]*std(data),0);
ylabel(ylab)
ylim([0 max(b.YData)+0.1*max(b.YData)])
longticks(ax,2)

% Quote data stats
text(1.55*std(data),7.25*ah.YLim(2)/10,...
     sprintf('std = %.0f\nmed = %.0f\nmean = %.0f\ngof = %.0f',...
	     std(data),median(data),mean(data),gof),'FontSize',9)
pct = (length(data(data<=round(3*std(data)) & data>=round(-3*std(data))))/length(data))*100;
text(-2.9*std(data),8*ah.YLim(2)/10,...
     sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',...
	     pct,min(data),max(data)),'FontSize',9)

% Overlayes
% light blue bars
b.FaceColor = [0.4 0.6667 0.8431]; 
% plot vertical line at median
hold on
% later versions could use XLINE
plot([1 1]*median(data),ylim,'k--','LineWidth',2);

% plot pdf on top of histogram
pd = fitdist(data,'Normal');
xvals = [-3*std(data):3*std(data)];
yvals = pdf(pd,xvals);
area = sum(b.YData)*diff(b.XData(1:2));
lain = plot(xvals,yvals*area,'r','LineWidth',2);
% if gof > 4 make red curve dotted b/c data is not normal
if gof > 4
  lain.LineStyle = '--';
end
hold off

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
