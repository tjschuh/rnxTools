function varargout=kin2mat(prdfile,plt)
% d=KIN2MAT(prdfile,plt)
%
% take a PRIDE-PPPAR kin_* solution file
% and create a structured MATLAB .mat file 
%
% INPUT:
%
% .prd file    kinematic solution output file created by kin2prd
% plt         0 for no plot, 1 for plot (default: 1)
%
% OUTPUT:
%
% d            actual data struct
% .mat file    output file saved as mat file to working directory
%
% EXAMPLE
%
% d=kin2mat('prdfile'); plot(d.t,d.height)
%
% Originally written by tschuh-at-princeton.edu, 10/06/2021
% Last modified by tschuh-at-princeton.edu, 10/26/2021

% prepare the outfile
% extract just the filename from prdfile with no extension    
[~,fname,~] = fileparts(prdfile);
% build the *.mat outfile from fname
outfile = sprintf('%s.mat',fname);

% if outfile doesnt exist, make it and save it
% otherwise load it
if exist(outfile,'file') == 0
    
    % load data
    % file comes in: Mjd, SoD, X, Y, Z, Lat, Lon, Ht, Nsat, PDOP
    dm = load(prdfile);

    % explicitly define header from kinfile
    h = {'t','xyz','lat','lon','height','nsats','pdop'};
    
    % make datetime array from kinfile columns 1 and 2
    % convert Mjd to ymd
    ymd = datestr(dm(:,1)+678942);
    % convert SoD to hms
    hms = datestr(seconds(dm(:,2)),'HH:MM:SS');
    % need to use for loop here bc dealing with char arrays
    for i = 1:length(dm)
        % combine ymd and hms into one str
        tstr(i,:) = append(ymd(i,:),' ',hms(i,:));
    end
    % convert tstr to datetime
    t = datetime(tstr,'InputFormat','dd-MMM-yyyy HH:mm:ss');

    % convert lat,lon to utm easting,northing in meters
    % create cell array with length(dm)
    zones = cell(length(dm),1);
    % lat lon cols are 6 and 7
    for i = 1:length(dm)
        % need to use rem to convert lon from (0,360) to (-180,180) to get utm zone correct
        [x(i,1),y(i,1),zone] = deg2utm(dm(i,6),rem((dm(i,7)+180),360)-180);
        % save utmzone to cell array
        zones{i} = zone;
    end
    
    % get rid of sat cols that are all zeros
    % all possible satellite types
    sattypes = {'Total','GPS','GLONASS','Galileo','BDS-2','BDS-3','QZSS'};
    % cols 9:15 are sat info
    counter = 1;
    for i = 9:15
        % if any rows of col i are nonzero, we keep entire col
        if sum(dm(:,i)) ~= 0
            % copy entire col to sats
            sats(:,counter) = dm(:,i);
            % copy col's header info to hsat
            hsat{counter} = sattypes{i-8};
            counter = counter + 1;
        end
    end
    
    % make data struct explicitly
    d.(h{1}) = t;
    d.(h{2}) = dm(:,3:5);
    d.xyzunit = 'm';
    d.(h{3}) = dm(:,6);
    d.(h{4}) = dm(:,7);
    d.lonlatunit = 'deg';
    d.utmeasting = x;
    d.utmnorthing = y;
    d.utmunit = 'm';
    d.utmzone = zones;
    d.(h{5}) = dm(:,8);
    d.heightunit = 'm (rel to WGS84)';
    d.satlabels = hsat;
    d.(h{6}) = sats;
    d.(h{7}) = dm(:,end);
    
    save(outfile,'d')
else
    load(outfile);
end

% do plotting in here as well
% only make the plot if it doesnt exist
defval('plt',1)
if plt == 1
    f=figure;
    % position = [left bottom width height]
    f.Position = [500 250 850 550];

    % find rows where nsats <= 4
    thresh = 4;
    rows=find(d.nsats(:,1)<=thresh);
    
    % plot utm coordinates
    % set the zero for the UTM coordinates based on the min and max of data
    x = d.utmeasting-(min(d.utmeasting)-.05*(max(d.utmeasting)-min(d.utmeasting)));
    y = d.utmnorthing-(min(d.utmnorthing)-.05*(max(d.utmnorthing)-min(d.utmnorthing)));
    tc = datetime(d.t,'Format','HH:mm:ss'); 
    z=zeros(size(x));
    ah(1)=subplot(2,2,[1 3]);
    c = linspace(1,10,length(x(1:10:end)));
    scatter(x(1:10:end)',y(1:10:end)',[],c,'filled')
    %plot(x(1:10:end)',y(1:10:end)','k','LineWidth',0.5)
    colormap(jet)
    colorbar('southoutside','Ticks',[1:3:10],'TickLabels',...
             {datestr(tc(1),'HH:MM:SS'),datestr(tc(floor(end/3)),'HH:MM:SS'),...
              datestr(tc(ceil(2*end/3)),'HH:MM:SS'),datestr(tc(end),'HH:MM:SS')})
    hold on
    % grey out "bad" data where nsats is low
    badx = x(rows);
    bady = y(rows);
    scatter(badx(1:10:end)',bady(1:10:end)',[],[0.7 0.7 0.7],'filled')
    grid on
    longticks
    xlabel('X [m]')
    ylabel('Y [m]')
    title('Location of Ship in UTM coordinates')

    % plot heights relative to WGS84
    ah(2)=subplot(2,2,2);
    plot(d.t,d.height,'color',[0.4660 0.6740 0.1880])
    hold on
    % grey out "bad" data where nsats is low
    badt = d.t(rows); 
    badht = d.height(rows);
    plot(badt,badht,'color',[0.7 0.7 0.7])
    xlim([d.t(1) d.t(end)])
    xticklabels([])
    % need to make 0.005 multiplier more general!
    ylim([min(d.height)-0.005*abs(min(d.height)) max(d.height)+0.005*abs(max(d.height))])
    grid on
    longticks
    ylabel('Height relative to WGS84 [m]')
    title('Height of Ship relative to WGS84')
    
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

    tt=supertit(ah([1 2]),sprintf('1 Hour of Ship Data Starting from %s',datestr(d.t(1))));
    movev(tt,0.3)
    
    figdisp(fname,[],'',2,[],'epstopdf')
end

% optional output
varns={d};
varargout=varns(1:nargout);