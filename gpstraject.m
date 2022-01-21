function gpstraject
% GPSTRAJECT
%
% Make a beautiful diagram of the geodetic campaign
%
% INPUT:
%
% OUTPUT:
%
% 
% Last modified by fjsimons-at-princeton.edu, 01/21/2022


% Receiver symbols and colors
sym='o'; 
me='k';
mf=grey;

% Font size of text boxes
fs=10;
% Offset for these text boxes
to=[0 1 ; 0 1 ; 0 -1 ; 0 -1]/1.5;
% Offset for axis limits
offset = [1.5 0.75];

% Special box strings
ts={'bow','stern','port','starboard'};
% Offset for these boxes
os=[0 3 ; 0 -5 ; -1.5 0 ; 1.25 0];
% Alignment for these boxes
as={'center','center','right','left'};


% Make the figure


% Print to PDF
figdisp([],[],[],2)
