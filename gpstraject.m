function gpstraject
% GPSTRAJECT
%
% Make a beautiful diagram of the seafloor geodetic campaign
%
% INPUT:
%
% OUTPUT:
%
% 
% Last modified by fjsimons-at-princeton.edu, 01/21/2022

% Top topo map in [0 360] and [-90 90]
xels=[278 296];
yels=[28 35];
C11=[xels(1) yels(2)];
CMN=[xels(2) yels(1)];

% Receiver symbols and colors
sym={'.','o','.'}; 
me={'r','g','b'};
mf={'r','g','b'};

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

% Get one set of data; execute on ariel
diro='/data1/seafloorgeodesy/SwiftNavData/BIOSCruise/Unit2';
fname=sprintf('%s_%s.mat',mfilename,suf(diro,'/'));

try 
  % Get it
  load(fname)
  % Make sure that's saved as well (wasn't at first)
  % dirs={'leg1','camp','leg2',};
catch
  % This for Ariel
  addpath('/home/fjsimons/PROGRAMS/MFILES/slepian_alpha')
  % Make it
  for index=1:length(dirs)
    mats=ls2cell(fullfile(diro,dirs{index},'*.mat'));
    % Every round minute is our target, alternative would be every minute apart
    bign=60*length(mats);
    % Initialize 
    t.(dirs{index})=NaT(bign,1);
    hwgs.(dirs{index})=nan(bign,1);
    lonlat.(dirs{index})=nan(bign,2);
    utmeno.(dirs{index})=nan(bign,2);
    for ondex=1:length(mats)
      % Load the file which renders the structure 'd'
      load(fullfile(diro,dirs{index},mats{ondex}))
      % Running index
      runin=(ondex-1)*60+1:ondex*60;
      % We're only saving by the round minute, how about that
      lojik=second(d.t)==0;
      runon=1:sum(lojik);
      % Proper assignment with makeups for nan
      t.(dirs{index})(runin(runon))=d.t(lojik);
      hwgs.(dirs{index})(runin(runon))=d.height(lojik);
      lonlat.(dirs{index})(runin(runon),:)=[d.lon(lojik) d.lat(lojik)];
      utmeno.(dirs{index})(runin(runon),:)=[d.utmeasting(lojik) d.utmnorthing(lojik)];
    end
    % After that, remove all the nans? or don't bother
  end
  % Save as MAT file, careful, be explicit with extension
  save(fname,'t','hwgs','lonlat','utmeno','dirs')
end

% Get the bathymetry
spc=1/60/4; vers=2019; npc=20;
% Make the save file
defval('savefile',fullfile(getenv('IFILES'),'TOPOGRAPHY','EARTH','GEBCO','HASHES',...
			   sprintf('%s.mat',hash([C11 CMN vers npc spc],'SHA-1'))))
if exist(savefile)~=2
  % I cannot remember why LAT should count backwards according to GEBCO
  [LON,LAT]=meshgrid([C11(1):spc:CMN(1)],[C11(2):-spc:CMN(2)]);
  LON=LON-360;
  z=gebco(LON,LAT,vers,npc);
  save(savefile,'z')
else
  load(savefile)
end

% Make the figure
clf
ah=krijetem(subnum(2,1));

% Overview map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(ah(1))
defval('cax',[-6000 500]);

% Color bar first...
[cb,cm]=cax2dem(cax,'ver');
% See IMAGEF for comments on pixel registration, which these are
imagefnan(C11,CMN,z,cm,cax)

% then colorbar again for adequate rendering
[cb,cm]=cax2dem(cax,'ver');

for index=1:length(dirs)
  hold on
  pl(index)=plot(lonlat.(dirs{index})(:,1),lonlat.(dirs{index})(:,2),...
       'Marker',sym{index},'MarkerFaceColor',mf{index},'MarkerEdgeColor',me{index});
end
pc=plotcont(C11+[-1 1]*5,CMN+[1 -1]*5);
% Maybe adjust to common field of view regardless of resolution even if
% that means cutting pixels off
axis([xels yels])
% xlim([C11(1) CMN(1)]); ylim([CMN(2) C11(2)])
hold off
delete(pc)

% Detail map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(ah(2))


keyboard

% Print to PDF
figdisp([],[],[],2)
