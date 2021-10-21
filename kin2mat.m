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

% prepare the outfile
% extract just the filename from prdfile with no extension    
[~,fname,~] = fileparts(prdfile);
% build the *.mat outfile from fname
outfile = sprintf('%s.mat',fname);

% if outfile doesnt exist, make it and save it
% otherwise load it
if exist(outfile,'file') == 0
    
    % Load the data
    % file comes in: Mjd, SoD, X, Y, Z, Lat, Lon, Ht, Nsat, PDOP
    dm = load(prdfile);
    
    % Load the header
    h = {'t','xyz','lat','lon','height','nsat','pdop'};
    
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
    
    d.ellipsoid = 'WGS84';
    d.xyzunit = 'm';
    d.lonlatunit = 'deg';
    % check how mnay satellites of each type, if all zero after GLONASS then save sats
    d.sats = {'Total','GPS','GLONASS'};

    save(outfile,'d')
else
    load(outfile)
end

    %do plotting in here as well
    %only make the plot if it doesnt exist
