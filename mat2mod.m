function varargout=mat2mod(files)
% dmat=MAT2MOD(files)
%
% Given Precise Point Position time series of (four) different units, makes
% them all start and end at the same time and inserts NaNs for times where
% no data were processed
%
% INPUT:
% 
% files        cell with MAT-filename strings containing data
%
% OUTPUT:
%
% dmat         cell with modified versions of data structure
%
% EXAMPLE:
%
% files = {unit1file,unit2file,unit3file,unit4file};
% d=mat2mod(files);
% 
% Originally written by tschuh-at-princeton.edu, 11/12/2021
% Last modified by tschuh-at-princeton.edu, 11/15/2021
% Last modified by fjsimons-at-alum.mit.edu, 01/31/2022

for i=1:length(files)
    load(files{i});
    % Use timetable to fill in time skips/data gaps
    tt = timetable(d.t,d.xyz,d.lat,d.lon,d.utmeasting,d.utmnorthing,d.utmzone,d.height,d.nsats,d.pdop);
    rett = retime(tt,'secondly','fillwithmissing');
    % redefine struct fields with NaN rows included
    % I would do a loop here using fieldnames
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
    % Assemble for later use
    dmat(i) = d;
end

% find which d is the smallest and use that one
% to intersect with all the others so that
% all 4 datasets start and end at the same time
% we do this twice to make the start and end times match
for j=1:2
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
end

% Variable output
varns={dmat};
varargout=varns(1:nargout);
