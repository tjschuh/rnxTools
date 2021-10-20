function varargout=kin2mat(prdfile)%,prhfile)
% [t,d,h]=KIN2MAT(prdfile,prhfile)
%
% take a PRIDE-PPPAR kin_* solution file
% and create a structured MATLAB .mat file 
%
% INPUT:
%
% kinfile             output file created by PRIDE-PPPAR containing PPP solutions
%
% OUTPUT:
%
% t
% d
% h  
%
%
% EXAMPLE
%
% [t,d]=kin2mat('kinfile'); plot(t,d.x,t.dy)
% 
% and a mat file is produced
%
% Originally written by tschuh-at-princeton.edu, 10/06/2021
% Last modified by tschuh-at-princeton.edu, 10/20/2021

%defval('prdfile','/i/iu/iu/u/*.prd')

%defval('prhfile','/hj.d.d/d.d./hdr')


% Construct the outputfile
% prdfile doesnt have any header
%matfile=strip prdfile of its extension 

% if *.mat doesnt exist, make it and save it
% otherwise load it
%if exist(prdfile,'file') == 0
    
    % Load the data
    % file comes in: Mjd, SoD, X, Y, Z, Lat, Lon, Ht, Nsat, PDOP
    dm = load(prdfile);
    [filepath,name,ext] = fileparts(prdfile);
    
    % Load the header
    %try
    %h= ;
    %catch
    % Be explicit - and be careful
    h = {'t','xyz','lat','lon','height','nsat','pdop'};
    %end
    
    % Make the datetime array from the kinfile column data
    ymd = datestr(dm(:,1)+678942); % convert Mjd to ymd
    hms = datestr(seconds(dm(:,2)),'HH:MM:SS'); % convert sod to hms
    for i = 1:length(dm) % need to use for loop here bc dealing with char arrays
        tstr(i,:) = append(ymd(i,:),' ',hms(i,:)); % combine ymd and hms into one str
    end
    t = datetime(tstr,'InputFormat','dd-MMM-yyyy HH:mm:ss'); % convert tstr to datetime
    
    % Now you make the struct and save for the remainder of the columns
    % maybe want to rethink how this is done i.e. not in a for loop
    for index=1:length(h)
        if index == 1
            d.(h{index}) = t;
        elseif index == 2
            d.(h{index}) = dm(:,index+1:index+3);
        elseif index == length(h)
            d.(h{index}) = dm(:,end);
        else
            d.(h{index}) = dm(:,index+3);
        end
    end
    
    %save(matfile,d,h,t)
    d.ellipsoid = 'WGS84';
    d.xyzunit = 'm';
    d.lonlatunit = 'deg';
    % check how mnay satellites of each type, if all zero after GLONASS then save sats
    d.sats = {'Total','GPS','GLONASS'};
    save(name,'d')

    %else
    %load(prdfile)
    %end

    %do plotting in here as well
    %only make the plot if it doesnt exist
