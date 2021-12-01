function inversion(unit1file,unit2file,unit3file,unit4file)
%
%
%
%
% Originally written by tschuh-at-princeton.edu, 11/30/2021

% use mat2mod to convert data to all be same time spans with no time gaps
[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);

% GPS locations [m] at t=0
% ignoring d4 for now b/c it's bad!
P1 = d1.xyz(1,:)';
P2 = d2.xyz(1,:)';
P3 = d3.xyz(1,:)';

% true beacon location
dogx = 1.979e6;
dogy = -5.074e6;
dogz = 3.30385e6; %~5 km below surface

% compute slant ranges [m] for d1,d2,d3 at t=0
sr1 = sqrt((d1.xyz(1,1) - dogx).^2 + (d1.xyz(1,2) - dogy).^2 + (d1.xyz(1,3) - dogz).^2);
sr2 = sqrt((d2.xyz(1,1) - dogx).^2 + (d2.xyz(1,2) - dogy).^2 + (d2.xyz(1,3) - dogz).^2);
sr3 = sqrt((d3.xyz(1,1) - dogx).^2 + (d3.xyz(1,2) - dogy).^2 + (d3.xyz(1,3) - dogz).^2);

P = [P1 P2 P3];
S = [sr1 sr2 sr3];

% use Trilateration code from "An Algebraic Solution to the Multilateration Problem"
[N1 N2] = Trilateration(P,S, diag(ones(1,3)));
N1mat = [N1(2,1) N1(3,1) N1(4,1)];
N2mat = [N2(2,1) N2(3,1) N2(4,1)];

keyboard
