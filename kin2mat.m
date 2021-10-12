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
    dm = load(kinfile);
    
    % Load the header
    try
        h= ;
    catch
        % Be xeplicit - and be carefil
        h={'M','x','y'};
    end
    
    % Make the time stamps from the column data
    t=

    % Now you make the struct and save for the remainder of the columns
    for index=1:length(h)
        d.(h{index})=dm(:,index+??);
    end
    save(matfile,d,h,t)
    
else
    load(matfile)


end


end

