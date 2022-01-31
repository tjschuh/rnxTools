function varargout=mat2mod(files)
% dmat=MAT2MOD(files)
%
% Given Precise Point Position time series of (four) different units, makes
% them all start and end at the same time and inserts NaNs for times where
% no data were processed
%
% INPUT:
% 
% files        cell with MAT-filename strings containing data structures
%
% OUTPUT:
%
% dmat         higher-dimensional structure with modified input structures
%
% EXAMPLE:
%
% dmat=mat2mod(files);
% 
% Originally written by tschuh-at-princeton.edu, 11/12/2021
% Last modified by tschuh-at-princeton.edu, 11/15/2021
% Last modified by fjsimons-at-alum.mit.edu, 01/31/2022

% Non-array variables to exclude from the tabling procedure
drem={'xyzunit','lonlatunit','utmunit','heightunit','satlabels'};

for i=1:length(files)
    load(files{i});
    % Only get the wanted variables, turn them into a timetable
    % Use (RE)TIME(TABLE) to fill in time skips/data gaps with NaNs
    tt=retime(table2timetable(struct2table(rmfield(d,drem))),'secondly','fillwithmissing');
    % Reassign to the old STRUCT
    d.t=tt.t;
    % These are the variables we kept
    fnd=fieldnames(rmfield(d,drem));
    % And they appear shifted by one in the time table
    fnt=fieldnames(tt);
    % So now you put them back in the right place as a struct
    for j=2:length(fnd)
      d.(fnd{j})=tt.(fnt{j-1});
    end    
    % Assemble for later use
    dmat(i) = d;
end

% About to change this

% find which d is the smallest and use that one
% to intersect with all the others so that
% all datasets start and end at the same time
% we do this twice to make the start and end times match
for j=1:2
  for i=1:length(files)
    lmat(i) = length(dmat(i).t);
  end
  col=find(lmat==min(lmat),1);
  % intersect all the other d's with the time in dmat(col)
  for i=1:length(files)
    if i ~= col
      % Do this for all field names
      [~,ia,~] = intersect(dmat(i).t,dmat(col).t);
      for k=1:length(fnd)
	dmat(i).(fnd{k}) = dmat(i).(fnd{k})(ia,:);
      end
    end
  end
end

% Variable output
varns={dmat};
varargout=varns(1:nargout);
