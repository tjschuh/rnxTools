function varargout=kin2mat(prdfile,prhfile)
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


defval('prdfile','/i/iu/iu/u/*.prd')

defval('prhfile','/hj.d.d/d.d./hdr')


% Construct the outputfile
matfile=   strip prdfile of its extension 

if not exist(matfile)
    
    % Load the data
    % file comes in: Mjd, SoD, X, Y, Z, Lat, Lon, Ht, Nsat, PDOP
    dm = load(kinfile);
    
    % Load the header
    try
        h= ;
    catch
        % Be explicit - and be careful
        h = {'date','x','y','z','lat','lon','ht','Nsat','PDOP'};
    end
    
    % Make the datetime array from the kinfile column data
    ymd = datestr(dm(:,1)+678942); % convert Mjd to ymd
    hms = datestr(seconds(dm(:,2)),'HH:MM:SS'); % convert sod to hms
    for i = 1:length(dm) % need to use for loop here bc dealing with char arrays
        tstr(i,:) = append(ymd(i,:),' ',hms(i,:)); % combine ymd and hms into one str
    end
    t = datetime(tstr,'InputFormat','dd-MMM-yyyy HH:mm:ss'); % convert tstr to datetime
    
    % Now you make the struct and save for the remainder of the columns
    for index=1:length(h)
        d.(h{index})=dm(:,index+??);
    end
    save(matfile,d,h,t)
    
else
    load(matfile)


end


end

