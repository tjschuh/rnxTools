function varargout=mat2com(unit1file,unit2file,unit3file,unit4file,plt)
% d=MAT2COM(unit1file,unit2file,unit3file,unit4file,plt)
%
% take in all 4 GPS datasets and combine them into one dataset
% via averaging (eventually will be center of mass (com)) and
% then plot the results in similar fashion as prd2mat.m
%
% INPUT:
%
% unit1file     mat file containing data collected by unit 1
% unit2file     mat file containing data collected by unit 2
% unit3file     mat file containing data collected by unit 3
% unit4file     mat file containing data collected by unit 4
% plt           0 for no plot, 1 for plot (default: 1)
%
% OUTPUT:
%
% d             actual data struct
%
% Originally written by tschuh-at-princeton.edu, 11/23/2021
% Last modified by tschuh-at-princeton.edu, 12/08/2021

[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);
[~,fname,~] = fileparts(unit1file);

% combine all data into 1 dataset
% simply by taking the average of the data
% maybe will eventually use a different scheme
% ignoring d4 for now because bad data
d.t = d1.t;
alldx = [d1.xyz(:,1) d2.xyz(:,1) d3.xyz(:,1)];% d4.xyz(:,1)];
d.x = nanmean(alldx,2);
alldy = [d1.xyz(:,2) d2.xyz(:,2) d3.xyz(:,2)];% d4.xyz(:,2)];
d.y = nanmean(alldy,2);
alldz = [d1.xyz(:,3) d2.xyz(:,3) d3.xyz(:,3)];% d4.xyz(:,3)];
d.z = nanmean(alldz,2);
alldlat = [d1.lat d2.lat d3.lat];% d4.lat];
d.lat = nanmean(alldlat,2);
alldlon = [d1.lon d2.lon d3.lon];% d4.lon];
d.lon = nanmean(alldlon,2);
alldutme = [d1.utmeasting d2.utmeasting d3.utmeasting];% d4.utmeasting];
d.utme = nanmean(alldutme,2);
alldutmn = [d1.utmnorthing d2.utmnorthing d3.utmnorthing];% d4.utmnorthing];
d.utmn = nanmean(alldutmn,2);
d.utmz = d1.utmzone;
alldht = [d1.height d2.height d3.height];% d4.height];
d.ht = nanmean(alldht,2);
alldnsats = [d1.nsats(:,1) d2.nsats(:,1) d3.nsats(:,1)];% d4.nsats(:,1)];
d.nsats = nanmean(alldnsats,2);
alldpdop = [d1.pdop d2.pdop d3.pdop];% d4.pdop];
d.pdop = nanmean(alldpdop,2);

% plotting
defval('plt',1)
if plt == 1
    f=figure;
    % position = [left bottom width height]
    f.Position = [500 250 850 550];

    % find rows where nsats <= 4
    nthresh = 4;
    n = d.nsats;

    % also should find rows where pdop is >= 10 or = 0
    % this doesnt always coincide with low nsats
    pthresh = 15;
    p = d.pdop;

    % plotting interval
    int = 5;

    % plot utm coordinates
    % set the zero for the UTM coordinates based on the min and max of data
    x = d.utme-(min(d.utme)-.05*(max(d.utme)-min(d.utme)));
    y = d.utmn-(min(d.utmn)-.05*(max(d.utmn)-min(d.utmn)));
    tc = datetime(d.t,'Format','HH:mm:ss'); 

    % find good (g) and bad (b) data
    % [gx bx] = x
    gx = x; bx = x;
    gy = y; by = y;
    gx(p>=pthresh | p==0 | n<=nthresh) = NaN;
    bx(p<pthresh & n>nthresh) = NaN;
    gy(p>=pthresh | p==0 | n<=nthresh) = NaN;
    by(p<pthresh & n>nthresh) = NaN;

    ah(1)=subplot(2,2,[1 3]);
    c = linspace(1,10,length(x(1:int:end)));
    sz = 10;
    scatter(gx(1:int:end)',gy(1:int:end)',sz,c,'filled')
    colormap(jet)
    colorbar('southoutside','Ticks',[1:3:10],'TickLabels',...
             {datestr(tc(1),'HH:MM:SS'),datestr(tc(floor(end/3)),'HH:MM:SS'),...
              datestr(tc(ceil(2*end/3)),'HH:MM:SS'),datestr(tc(end),'HH:MM:SS')})
    hold on
    % grey out "bad" data where nsats is too low or pdop is too high or 0
    scatter(bx(1:int:end)',by(1:int:end)',sz,[0.7 0.7 0.7],'filled')
    grid on
    longticks
    xlabel('Easting [m]')
    %xticklabels({'0','5','10','15'})
    ylabel('Northing [m]')
    %yticklabels({'0','2','4','6','8','10','12','14','16','18','20'})
    title(sprintf('Ship Location (Every %dth point)',int))

    % plot heights relative to WGS84
    gh = d.ht; bh = d.ht;
    gh(p>=pthresh | p==0 | n<=nthresh) = NaN;
    bh(p<pthresh & n>nthresh) = NaN;

    ah(2)=subplot(2,2,2);
    plot(d.t(1:int:end),gh(1:int:end),'color',[0.4660 0.6740 0.1880])
    hold on
    % grey out "bad" data where nsats is too low or pdop is too high or 0
    plot(d.t(1:int:end),bh(1:int:end),'color',[0.7 0.7 0.7])
    xlim([d.t(1) d.t(end)])
    xticklabels([])
    % remove outliers so plotting looks better
    htout = rmoutliers(d.ht,'mean');
    outpct = (length(d.ht)-length(htout))*100/length(d.ht);
    ylim([min(htout,[],'all')-0.005*abs(min(htout,[],'all')) max(htout,[],'all')+0.005*abs(max(htout,[],'all'))])
    a=annotation('textbox',[0.78 0.57 0 0],'String',[sprintf('%05.2f%% Outliers',outpct)],'FitBoxToText','on');
    a.FontSize = 8;
    grid on
    longticks
    ylabel('Height relative to WGS84 [m]')
    title(sprintf('Ship Height (Every %dth Point)',int))

    % plot nsats and pdop on same plot
    ah(3)=subplot(2,2,4);
    yyaxis left
    plot(d.t,d.nsats(:,1),'b','LineWidth',1)
    yticks([min(d.nsats(:,1))-1:max(d.nsats(:,1))+1])
    ylim([min(d.nsats(:,1))-0.5 max(d.nsats(:,1))+0.5])
    ylabel('Number of Observed Satellites') 
    yyaxis right
    plot(d.t,d.pdop,'r','LineWidth',1)
    ylim([min(d.pdop)-0.25 max(d.pdop)+0.25])
    xlim([d.t(1) d.t(end)])
    ylabel('Position Dilution Of Precision')
    % can only turn grid on for left axis
    grid on
    longticks
    title('Total Number of Satellites and PDOP')

    tt=supertit(ah([1 2]),sprintf('1 Hour of Averaged Ship Data Starting from %s',datestr(d.t(1))));
    movev(tt,0.3)

    a = annotation('textbox',[0.23 0.1 0 0],'String',['camp'],'FitBoxToText','on');
    a.FontSize = 12;

    figdisp(fname,[],'',2,[],'epstopdf')

    close
end

% optional output
varns={d};
varargout=varns(1:nargout);