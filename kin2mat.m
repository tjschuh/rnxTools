function varargout=kin2mat(prdfile)
% [t,d,h]=KIN2MAT(prdfile)
%
% take a PRIDE-PPPAR kin_* solution file
% and create a structured MATLAB .mat file 
%
% INPUT:
%
% kinfile      output file created by PRIDE-PPPAR containing PPP solutions
%
% OUTPUT:
%
% t            time variable
% d            actual data struct
% h            data header line(s)
% .mat file    output file saved as mat file to working directory
%
% EXAMPLE
%
% [t,d]=kin2mat('kinfile'); plot(t,d.height)
%
% Originally written by tschuh-at-princeton.edu, 10/06/2021
% Last modified by tschuh-at-princeton.edu, 10/21/2021

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
    d.(h{5}) = dm(:,8);
    d.heightunit = 'm (rel to WGS84)';
    d.satlabels = hsat;
    d.(h{6}) = sats;
    d.(h{7}) = dm(:,end);
    
    % include utm coodinates
    
    save(outfile,'d')
else
    load(outfile)
end

    % do plotting in here as well
    % only make the plot if it doesnt exist

% optional output
varns={t,d,h};
varargout=varns(1:nargout);