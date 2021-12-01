function [sol1,sol2,real] = inversion(unit1file,unit2file,unit3file,unit4file)
%
% using trilateration method (not my code) calculate beacon
% location on seafloor from slant ranges and ship locations
% can also use RecTrilateration.m to see if it improves result
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
% sol1          calculated average [x y z] beacon location [m] (method 1)
% sol2          calculated average [x y z] beacon location [m] (method 2)
% real          true [x y a] beacon location [m]
%
% Originally written by tschuh-at-princeton.edu, 11/30/2021

% use mat2mod to convert data to all be same time spans with no time gaps
[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);

% true beacon location
% eventually this wont be known
dogx = 1.979e6;
dogy = -5.074e6;
dogz = 3.30385e6; %~5 km below surface
real = [dogx dogy dogz];

% find a location (x,y,z) for every second 
for i=1:length(d1.xyz)
    % GPS locations [m]
    % ignoring d4 for now b/c it's bad!
    P1(:,i) = d1.xyz(i,:)';
    P2(:,i) = d2.xyz(i,:)';
    P3(:,i) = d3.xyz(i,:)';

    % compute slant ranges [m] for d1,d2,d3
    % eventually need to use slant times and velocity
    % profile to find slant ranges (sr = v*st)
    sr1 = sqrt((d1.xyz(i,1) - dogx).^2 + (d1.xyz(i,2) - dogy).^2 + (d1.xyz(i,3) - dogz).^2);
    sr2 = sqrt((d2.xyz(i,1) - dogx).^2 + (d2.xyz(i,2) - dogy).^2 + (d2.xyz(i,3) - dogz).^2);
    sr3 = sqrt((d3.xyz(i,1) - dogx).^2 + (d3.xyz(i,2) - dogy).^2 + (d3.xyz(i,3) - dogz).^2);

    P = [P1(:,i) P2(:,i) P3(:,i)];
    S = [sr1 sr2 sr3];

    % if there are any NaN values, dont do Trilateration, it wont run
    if isnan(sr1)==1 | isnan(sr2)==1 | isnan(sr3)==1
        N1mat(i,:) = [NaN NaN NaN];
        N2mat(i,:) = [NaN NaN NaN];
    else
        % use Trilateration code from "An Algebraic Solution to the Multilateration Problem"
        [N1 N2] = Trilateration(P,S, diag(ones(1,3)));
        N1mat(i,:) = [N1(2,1) N1(3,1) N1(4,1)];
        N2mat(i,:) = [N2(2,1) N2(3,1) N2(4,1)];
    end
end

% for final location take average of all locations (maybe not best way)
% could make histogram here
sol1 = nanmean(N1mat,1);
sol2 = nanmean(N2mat,1);