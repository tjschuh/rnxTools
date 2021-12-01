function com2dep(unit1file,unit2file,unit3file,unit4file)
% COM2DEP(unit1file,unit2file,unit3file,unit4file)
%
%
% INPUT:
%
% unit1file     mat file containing data collected by unit 1
% unit2file     mat file containing data collected by unit 2
% unit3file     mat file containing data collected by unit 3
% unit4file     mat file containing data collected by unit 4
%
% OUTPUT:
%
%
% Originally written by tschuh-at-princeton.edu, 11/24/2021
% Last modified by tschuh-at-princeton.edum 11/30/2021

% set beacon location on seafloor
% these come from file 05040 first xyz positions, but z-5km
% eventually will need to be a changing value until it reaches seafloor
% after that will not be known and will be deduced from timestamps sent back
dogx = 1.979e6;
dogy = -5.074e6;
dogz = 3.30385e6; %~5 km below surface

% combine all datasets into 1 with no plotting
d = mat2com(unit1file,unit2file,unit3file,unit4file,0);
[~,fname,~] = fileparts(unit1file);

% calculate slant range between ship and beacon for each second in meters
sr = sqrt((d.x(:) - dogx).^2 + (d.y(:) - dogy).^2 + (d.z(:) - dogz).^2);

% constant sound speed profile for now [m/s]
v = 1500;

% calculate slant time from slant range and v [s]
st = sr./v;

% plot the distance [km] vs time
% would be nice to eventually add error bars
plot(d.t,sr*1e-3,'LineWidth',2)
%set(gca,'YDir','reverse')
xlim([d.t(1) d.t(end)])
buff = 0.01;
ylim([min(sr*1e-3)-buff*min(sr*1e-3) max(sr*1e-3)+buff*max(sr*1e-3)])
ylabel('Slant Range [km]')
title(sprintf('Raw Slant Range Measurements: %s',datestr(d.t(1))))
grid on
longticks
keyboard
% save figure as pdf
%figdisp(fname,[],'',2,[],'epstopdf')

% close figure
%close