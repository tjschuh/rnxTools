function pppvrtk(pppfile1,pppfile2,pppfile3,pppfile4,rtkfile1,rtkfile2,rtkfile3,rtkfile4)
% PPPVRTK(pppfile1,pppfile2,pppfile3,pppfile4,rtkfile1,rtkfile2,rtkfile3,rtkfile4)
%
% compare PPP and RTK by taking post-processed datasets from both methods
% across the same time spans of the the residuals of the distances between
% the 4 GPS receivers on-board R/V Atlantic Explorer and (1) plotting the
% standard deviation of each dataset as a function of the number of points
% in the datasets and (2) plotting the histograms back-to-back of the residuals
%
% INPUT:
%
% pppfile1     ppp mat file containing data collected by unit 1
% pppfile2     ppp mat file containing data collected by unit 2
% pppfile3     ppp mat file containing data collected by unit 3
% pppfile4     ppp mat file containing data collected by unit 4
% rtkfile1     rtk mat file containing data collected by unit 1
% rtkfile2     rtk mat file containing data collected by unit 2
% rtkfile3     rtk mat file containing data collected by unit 3
% rtkfile4     rtk mat file containing data collected by unit 4
%
% OUTPUT:
%
% subplot of standard deviation vs number of points in both datasets
% subplot of histograms back-to-back of both datasets
%
% Originally written by tschuh-at-princeton.edu, 01/17/2022
% Last modified by tschuh-at-princeton.edu, 01/18/2022

% (i=1) go through all 4 ppp datasets and compute pvar datasets
% which are the residuals from the GPS receiver distances, then
% (i=2) go through all 4 rtk datasets and compute rvar datasets
for i = 1:2
    if i == 1 % ppp
        % use mat2mod to convert ppp data to all be same time spans with no time gaps
        [d1,d2,d3,d4] = mat2mod(pppfile1,pppfile2,pppfile3,pppfile4);
        [~,pfname,~] = fileparts(pppfile1);
        ptime = d1.t;
    else % rtk
        % use mat2mod to convert rtk data to all be same time spans with no time gaps
        [d1,d2,d3,d4] = mat2mod(rtkfile1,rtkfile2,rtkfile3,rtkfile4);
        [~,rfname,~] = fileparts(rtkfile1);
        rtime = d1.t;
    end
        
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

    % use d to find residuals e
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

    if i == 1 % ppp
        % iteratively remove outliers to improve the "normality" of the data
        % make copies of e --> ee so we can still work with e
        pe12 = e12;
        pd12 = fitdist(e12,'Normal');
        pvar12(1,1) = length(e12); pvar12(1,2) = pd12.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e12) > length(d1.t)/3
            e12 = rmoutliers(e12,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd12 = fitdist(e12,'Normal');
            pvar12(counter,1) = length(e12); pvar12(counter,2) = pd12.sigma;
            counter = counter + 1;
        end

        pe13 = e13;
        pd13 = fitdist(e13,'Normal');
        pvar13(1,1) = length(e13); pvar13(1,2) = pd13.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e13) > length(d1.t)/3
            e13 = rmoutliers(e13,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd13 = fitdist(e13,'Normal');
            pvar13(counter,1) = length(e13); pvar13(counter,2) = pd13.sigma;
            counter = counter + 1;
        end

        pe14 = e14;
        pd14 = fitdist(e14,'Normal');
        pvar14(1,1) = length(e14); pvar14(1,2) = pd14.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e14) > length(d1.t)/3
            e14 = rmoutliers(e14,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd14 = fitdist(e14,'Normal');
            pvar14(counter,1) = length(e14); pvar14(counter,2) = pd14.sigma;
            counter = counter + 1;
        end

        pe23 = e23;
        pd23 = fitdist(e23,'Normal');
        pvar23(1,1) = length(e23); pvar23(1,2) = pd23.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e23) > length(d1.t)/3
            e23 = rmoutliers(e23,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd23 = fitdist(e23,'Normal');
            pvar23(counter,1) = length(e23); pvar23(counter,2) = pd23.sigma;
            counter = counter + 1;
        end

        pe24 = e24;
        pd24 = fitdist(e24,'Normal');
        pvar24(1,1) = length(e24); pvar24(1,2) = pd24.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e24) > length(d1.t)/3
            e24 = rmoutliers(e24,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd24 = fitdist(e24,'Normal');
            pvar24(counter,1) = length(e24); pvar24(counter,2) = pd24.sigma;
            counter = counter + 1;
        end

        pe34 = e34;
        pd34 = fitdist(e34,'Normal');
        pvar34(1,1) = length(e34); pvar34(1,2) = pd34.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e34) > length(d1.t)/3
            e34 = rmoutliers(e34,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd34 = fitdist(e34,'Normal');
            pvar34(counter,1) = length(e34); pvar34(counter,2) = pd34.sigma;
            counter = counter + 1;
        end
    else % rtk
        % iteratively remove outliers to improve the "normality" of the data
        re12 = e12;
        pd12 = fitdist(e12,'Normal');
        rvar12(1,1) = length(e12); rvar12(1,2) = pd12.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e12) > length(d1.t)/3
            e12 = rmoutliers(e12,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd12 = fitdist(e12,'Normal');
            rvar12(counter,1) = length(e12); rvar12(counter,2) = pd12.sigma;
            counter = counter + 1;
        end

        re13 = e13;
        pd13 = fitdist(e13,'Normal');
        rvar13(1,1) = length(e13); rvar13(1,2) = pd13.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e13) > length(d1.t)/3
            e13 = rmoutliers(e13,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd13 = fitdist(e13,'Normal');
            rvar13(counter,1) = length(e13); rvar13(counter,2) = pd13.sigma;
            counter = counter + 1;
        end

        re14 = e14;
        pd14 = fitdist(e14,'Normal');
        rvar14(1,1) = length(e14); rvar14(1,2) = pd14.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e14) > length(d1.t)/3
            e14 = rmoutliers(e14,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd14 = fitdist(e14,'Normal');
            rvar14(counter,1) = length(e14); rvar14(counter,2) = pd14.sigma;
            counter = counter + 1;
        end

        re23 = e23;
        pd23 = fitdist(e23,'Normal');
        rvar23(1,1) = length(e23); rvar23(1,2) = pd23.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e23) > length(d1.t)/3
            e23 = rmoutliers(e23,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd23 = fitdist(e23,'Normal');
            rvar23(counter,1) = length(e23); rvar23(counter,2) = pd23.sigma;
            counter = counter + 1;
        end

        re24 = e24;
        pd24 = fitdist(e24,'Normal');
        rvar24(1,1) = length(e24); rvar24(1,2) = pd24.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e24) > length(d1.t)/3
            e24 = rmoutliers(e24,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd24 = fitdist(e24,'Normal');
            rvar24(counter,1) = length(e24); rvar24(counter,2) = pd24.sigma;
            counter = counter + 1;
        end

        re34 = e34;
        pd34 = fitdist(e34,'Normal');
        rvar34(1,1) = length(e34); rvar34(1,2) = pd34.sigma;
        thresh = 2.5;
        counter = 2;
        while length(e34) > length(d1.t)/3
            e34 = rmoutliers(e34,'percentiles',[thresh 100-thresh]);
            thresh = thresh + 2.5;
            pd34 = fitdist(e34,'Normal');
            rvar34(counter,1) = length(e34); rvar34(counter,2) = pd34.sigma;
            counter = counter + 1;
        end
    end
end

maxstd = max([pvar12(1,2) pvar13(1,2) pvar14(1,2) pvar23(1,2) pvar24(1,2) pvar34(1,2) ...
              rvar12(1,2) rvar13(1,2) rvar14(1,2) rvar23(1,2) rvar24(1,2) rvar34(1,2)]);

% plotting
% plot the std curves first
f=figure;
f.Position = [250 500 1100 800];

ah1(1) = subplot(3,2,1);
plot(pvar12(:,1),pvar12(:,2),'Color',[0.4 0.6667 0.8431],'LineWidth',2)
hold on
plot(rvar12(:,1),rvar12(:,2),'Color',[0.466 0.674 0.188],'LineWidth',2)
cosmo1(gca,'GPS Pair 1-2','# of Data Points','Std [mm]',e12,d1.t,maxstd)

ah1(2) = subplot(3,2,2);
plot(pvar13(:,1),pvar13(:,2),'Color',[0.4 0.6667 0.8431],'LineWidth',2)
hold on
plot(rvar13(:,1),rvar13(:,2),'Color',[0.466 0.674 0.188],'LineWidth',2)
cosmo1(gca,'GPS Pair 1-3','# of Data Points','Std [mm]',e13,d1.t,maxstd)

ah1(3) = subplot(3,2,3);
plot(pvar14(:,1),pvar14(:,2),'Color',[0.4 0.6667 0.8431],'LineWidth',2)
hold on
plot(rvar14(:,1),rvar14(:,2),'Color',[0.466 0.674 0.188],'LineWidth',2)
cosmo1(gca,'GPS Pair 1-4','# of Data Points','Std [mm]',e14,d1.t,maxstd)

ah1(4) = subplot(3,2,4);
plot(pvar23(:,1),pvar23(:,2),'Color',[0.4 0.6667 0.8431],'LineWidth',2)
hold on
plot(rvar23(:,1),rvar23(:,2),'Color',[0.466 0.674 0.188],'LineWidth',2)
cosmo1(gca,'GPS Pair 2-3','# of Data Points','Std [mm]',e23,d1.t,maxstd)

ah1(5) = subplot(3,2,5);
plot(pvar24(:,1),pvar24(:,2),'Color',[0.4 0.6667 0.8431],'LineWidth',2)
hold on
plot(rvar24(:,1),rvar24(:,2),'Color',[0.466 0.674 0.188],'LineWidth',2)
cosmo1(gca,'GPS Pair 2-4','# of Data Points','Std [mm]',e24,d1.t,maxstd)

ah1(6) = subplot(3,2,6);
plot(pvar34(:,1),pvar34(:,2),'Color',[0.4 0.6667 0.8431],'LineWidth',2)
hold on
plot(rvar34(:,1),rvar34(:,2),'Color',[0.466 0.674 0.188],'LineWidth',2)
cosmo1(gca,'GPS Pair 3-4','# of Data Points','Std [mm]',e34,d1.t,maxstd)

% finishing touches
tt=supertit(ah1([1 2]),sprintf('Std vs # of Data Points (Ship Data from %s to %s)',datestr(rtime(1)),datestr(rtime(end))));
movev(tt,0.3)
a = annotation('textbox',[0.465 0.085 0 0],'String',['leg2'],'FitBoxToText','on');
a.FontSize = 12;


figdisp(sprintf('std-%s-%s',pfname,rfname),[],'',2,[],'epstopdf')

close

% plotting histograms
g=figure;
g.Position = [250 500 1100 800];

% number of bins
nbins = 30;

ah2(1) = subplot(3,2,1);
% remove outliers to get better results
%try
%    pee12 = rmoutliers(pe12,'gesd');
%    ree12 = rmoutliers(re12,'gesd');
%catch
    pee12 = rmoutliers(pe12,'percentiles',[5 95]);
    ree12 = rmoutliers(re12,'percentiles',[5 95]);
    %end
phObj12 = histfit(pee12,nbins);
hold on
rhObj12 = histfit(ree12,nbins);
cosmo2(gca,sprintf('PPP = %i/%i, GPS Pair 1-2, RTK = %i/%i',length(pee12),length(ptime),length(ree12),length(rtime)),'Residuals [mm]','Counts',pee12,phObj12,ree12,rhObj12)

ah2(2) = subplot(3,2,2);
% remove outliers to get better results
%try
%    pee13 = rmoutliers(pe13,'gesd');
%    ree13 = rmoutliers(re13,'gesd');
%catch
    pee13 = rmoutliers(pe13,'percentiles',[5 95]);
    ree13 = rmoutliers(re13,'percentiles',[5 95]);
    %end
phObj13 = histfit(pee13,nbins);
hold on
rhObj13 = histfit(ree13,nbins);
cosmo2(gca,sprintf('PPP = %i/%i, GPS Pair 1-3, RTK = %i/%i',length(pee13),length(ptime),length(ree13),length(rtime)),'Residuals [mm]','Counts',pee13,phObj13,ree13,rhObj13)

ah2(3) = subplot(3,2,3);
% remove outliers to get better results
%try
%    pee14 = rmoutliers(pe14,'gesd');
%    ree14 = rmoutliers(re14,'gesd');
%catch
    pee14 = rmoutliers(pe14,'percentiles',[5 95]);
    ree14 = rmoutliers(re14,'percentiles',[5 95]);
    %end
phObj14 = histfit(pee14,nbins);
hold on
rhObj14 = histfit(ree14,nbins);
cosmo2(gca,sprintf('PPP = %i/%i, GPS Pair 1-4, RTK = %i/%i',length(pee14),length(ptime),length(ree14),length(rtime)),'Residuals [mm]','Counts',pee14,phObj14,ree14,rhObj14)

ah2(4) = subplot(3,2,4);
% remove outliers to get better results
%try
%    pee23 = rmoutliers(pe23,'gesd');
%    ree23 = rmoutliers(re23,'gesd');
%catch
    pee23 = rmoutliers(pe23,'percentiles',[5 95]);
    ree23 = rmoutliers(re23,'percentiles',[5 95]);
    %end
phObj23 = histfit(pee23,nbins);
hold on
rhObj23 = histfit(ree23,nbins);
cosmo2(gca,sprintf('PPP = %i/%i, GPS Pair 2-3, RTK = %i/%i',length(pee23),length(ptime),length(ree23),length(rtime)),'Residuals [mm]','Counts',pee23,phObj23,ree23,rhObj23)

ah2(5) = subplot(3,2,5);
% remove outliers to get better results
%try
%    pee24 = rmoutliers(pe24,'gesd');
%    ree24 = rmoutliers(re24,'gesd');
%catch
    pee24 = rmoutliers(pe24,'percentiles',[5 95]);
    ree24 = rmoutliers(re24,'percentiles',[5 95]);
    %end
phObj24 = histfit(pee24,nbins);
hold on
rhObj24 = histfit(ree24,nbins);
cosmo2(gca,sprintf('PPP = %i/%i, GPS Pair 2-4, RTK = %i/%i',length(pee24),length(ptime),length(ree24),length(rtime)),'Residuals [mm]','Counts',pee24,phObj24,ree24,rhObj24)

ah2(6) = subplot(3,2,6);
% remove outliers to get better results
%try
%    pee34 = rmoutliers(pe34,'gesd');
%    ree34 = rmoutliers(re34,'gesd');
%catch
    pee34 = rmoutliers(pe34,'percentiles',[5 95]);
    ree34 = rmoutliers(re34,'percentiles',[5 95]);
    %end
phObj34 = histfit(pee34,nbins);
hold on
rhObj34 = histfit(ree34,nbins);
cosmo2(gca,sprintf('PPP = %i/%i, GPS Pair 3-4, RTK = %i/%i',length(pee34),length(ptime),length(ree34),length(rtime)),'Residuals [mm]','Counts',pee34,phObj34,ree34,rhObj34)

% finishing touches
tt=supertit(ah2([1 2]),sprintf('Demeaned Residuals of Ship Data from %s to %s',datestr(rtime(1)),datestr(rtime(end))));
movev(tt,0.3)
b = annotation('textbox',[0.465 0.085 0 0],'String',['leg2'],'FitBoxToText','on');
b.FontSize = 12;

figdisp(sprintf('histo-%s-%s',pfname,rfname),[],'',2,[],'epstopdf')

close

% cosmetics for std plots
function cosmo1(ax,titl,xlab,ylab,minlen,maxlen,maxstd)
set(ax,'XDir','reverse')
title(titl)
xlabel(xlab)
ylabel(ylab)
xlim([length(minlen) length(maxlen)])
ylim([0 maxstd+0.05*maxstd])
legend('PPP','RTK')
grid on
longticks

% cosmetics for histogram plots
function cosmo2(ax,titl,xlab,ylab,pdata,phobj,rdata,rhobj)
% plot rtk histogram below x-axis
rhobj(1).YData = -1*rhobj(1).YData;
rhobj(2).YData = -1*rhobj(2).YData;
ax.XGrid = 'on';
ax.YGrid = 'off';
ax.GridColor = [0 0 0];
ax.TickLength = [0 0];
title(titl)
xlabel(xlab)
if std(pdata)>=std(rdata)
    xlim([round(-3*std(pdata),2) round(3*std(pdata),2)])
    xticks([round(-3*std(pdata),2) round(-2*std(pdata),2) round(-std(pdata),2) 0 round(std(pdata),2) round(2*std(pdata),2) round(3*std(pdata),2)])
    xticklabels({round(-3*std(pdata),0),round(-2*std(pdata),0),round(-std(pdata),0),0,round(std(pdata),0),round(2*std(pdata),0),round(3*std(pdata),0)})
    text(1.55*std(pdata),4*max(phobj(1).YData)/5,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f',std(pdata),median(pdata),mean(pdata)),'FontSize',9)
    text(1.55*std(pdata),4*min(rhobj(1).YData)/5,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f',std(rdata),median(rdata),mean(rdata)),'FontSize',9)
    ppct = (length(pdata(pdata<=round(3*std(pdata)) & pdata>=round(-3*std(pdata))))/length(pdata))*100;
    text(-2.9*std(pdata),85*max(phobj(1).YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',ppct,min(pdata),max(pdata)),'FontSize',9)
    rpct = (length(rdata(rdata<=round(3*std(rdata)) & rdata>=round(-3*std(rdata))))/length(rdata))*100;
    text(-2.9*std(pdata),85*min(rhobj(1).YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',rpct,min(rdata),max(rdata)),'FontSize',9)
elseif std(pdata)<std(rdata)
    xlim([round(-3*std(rdata),2) round(3*std(rdata),2)])
    xticks([round(-3*std(rdata),2) round(-2*std(rdata),2) round(-std(rdata),2) 0 round(std(rdata),2) round(2*std(rdata),2) round(3*std(rdata),2)])
    xticklabels({round(-3*std(rdata),0),round(-2*std(rdata),0),round(-std(rdata),0),0,round(std(rdata),0),round(2*std(rdata),0),round(3*std(rdata),0)})
    text(1.55*std(rdata),4*max(phobj(1).YData)/5,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f',std(pdata),median(pdata),mean(pdata)),'FontSize',9)
    text(1.55*std(rdata),4*min(rhobj(1).YData)/5,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f',std(rdata),median(rdata),mean(rdata)),'FontSize',9)
    ppct = (length(pdata(pdata<=round(3*std(pdata)) & pdata>=round(-3*std(pdata))))/length(pdata))*100;
    text(-2.9*std(rdata),85*max(phobj(1).YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',ppct,min(pdata),max(pdata)),'FontSize',9)
    rpct = (length(rdata(rdata<=round(3*std(rdata)) & rdata>=round(-3*std(rdata))))/length(rdata))*100;
    text(-2.9*std(rdata),85*min(rhobj(1).YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',rpct,min(rdata),max(rdata)),'FontSize',9)
end
ylabel(ylab)
if abs(max(phobj(1).YData)) >= abs(min(rhobj(1).YData))
    ylim([-max(phobj(1).YData)-0.1*max(phobj(1).YData) max(phobj(1).YData)+0.1*max(phobj(1).YData)])
elseif abs(max(phobj(1).YData)) < abs(min(rhobj(1).YData))
    ylim([min(rhobj(1).YData)+0.1*min(rhobj(1).YData) -min(rhobj(1).YData)-0.1*min(rhobj(1).YData)])
end
longticks([],2)
phobj(1).FaceColor = [0.4 0.6667 0.8431]; %light blue bars
rhobj(1).FaceColor = [0.466 0.674 0.188]; %lime green bars

% text(1.55*std(pdata),4*max(phobj(1).YData)/5,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f',std(pdata),median(pdata),mean(pdata)),'FontSize',9)
% text(1.55*std(rdata),4*min(rhobj(1).YData)/5,sprintf('std = %.0f\nmed = %.0f\nmean = %.0f',std(rdata),median(rdata),mean(rdata)),'FontSize',9)
% ppct = (length(pdata(pdata<=round(3*std(pdata)) & pdata>=round(-3*std(pdata))))/length(pdata))*100;
% text(-2.9*std(pdata),85*max(phobj(1).YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',ppct,min(pdata),max(pdata)),'FontSize',9)
% rpct = (length(rdata(rdata<=round(3*std(rdata)) & rdata>=round(-3*std(rdata))))/length(rdata))*100;
% text(-2.9*std(rdata),85*min(rhobj(1).YData)/100,sprintf('%05.2f%%\nmin = %.0f\nmax = %.0f',rpct,min(rdata),max(rdata)),'FontSize',9)

% plot vertical lines at respective medians
line([median(pdata) median(pdata)],[0 max(phobj(2).YData)],'Color','k','LineStyle','--','LineWidth',1.5);
line([median(rdata) median(rdata)],[0 min(rhobj(2).YData)],'Color','k','LineStyle','--','LineWidth',1.5);
% plot horizontal line at 0
yline(0,'k','LineWidth',1.5);