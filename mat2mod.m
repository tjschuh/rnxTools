function [d1,d2,d3,d4]=mat2mod(unit1file,unit2file,unit3file,unit4file)
% [d1,d2,d3,d4]=MAT2MOD(unit1file,unit2file,unit3file,unit4file)
%
% takes in data from 4 different units
% makes them all start and end at the same time
% and inserts NaNs for times where no data was processed
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
% d1           modified version of unit1file data struct
% d2           modified version of unit2file data struct
% d3           modified version of unit3file data struct
% d4           modified version of unit4file data struct
%
% Originally written by tschuh-at-princeton.edu, 11/12/2021

% load in all 4 mat files corresponding to different units
files = {unit1file,unit2file,unit3file,unit4file};
for i=1:length(files)
    load(files{i});
    % use timetable to fill in time skips/data gaps
    tt = timetable(d.t,d.xyz,d.lat,d.lon,d.utmeasting,d.utmnorthing,d.utmzone,d.height,d.nsats,d.pdop);
    rett = retime(tt,'secondly','fillwithmissing');
    % redefine struct fields with NaN rows included
    d.t = rett.Time;
    d.xyz = rett.Var1;
    d.lat = rett.Var2;
    d.lon = rett.Var3;
    d.utmeasting = rett.Var4;
    d.utmnorthing = rett.Var5;
    d.utmzone = rett.Var6;
    d.height = rett.Var7;
    d.nsats = rett.Var8;
    d.pdop = rett.Var9;
    dmat(i) = d;
end

% find which d is the smallest and use that one
% to intersect with all the others so that
% all 4 datasets start and end at the same time
for i=1:length(files)
    lmat(i) = length(dmat(i).t);
end
col=find(lmat==min(lmat),1);
smalld = dmat(col);
% intersect all the other d's with smalld
for i=1:length(files)
    if i ~= col
        [dmat(i).t,ia,~] = intersect(dmat(i).t,smalld.t);
        dmat(i).xyz = dmat(i).xyz(ia,:);
        dmat(i).lat = dmat(i).lat(ia,:);
        dmat(i).lon = dmat(i).lon(ia,:);
        dmat(i).utmeasting = dmat(i).utmeasting(ia,:);
        dmat(i).utmnorthing = dmat(i).utmnorthing(ia,:);
        dmat(i).utmzone = dmat(i).utmzone(ia,:);
        dmat(i).height = dmat(i).height(ia,:);
        dmat(i).nsats = dmat(i).nsats(ia,:);
        dmat(i).pdop = dmat(i).pdop(ia,:);
    end
end
% finally define d1, d2, d3, d4 from dmat
d1 = dmat(1);
d2 = dmat(2);
d3 = dmat(3);
d4 = dmat(4);
