function dis2his(unit1file,unit2file,unit3file,unit4file)
% DIS2HIS(unit1file,unit2file,unit3file,unit4file)
%
% compute distance between 6 sets of reciever pairs
% calculate linear polyfit and residuals
% produce histogram of residuals
%
% INPUT:
%
% unit1file     mat file containing data collected by unit 1
% unit2file     mat file containing data collected by unit 2
% unit3file     mat file containing data collected by unit 3
% unit4file     mat file containing data collected by unit 4
%
% Originally written by tschuh-at-princeton.edu, 12/01/2021

% use mat2mod to convert data to all be same time spans with no time gaps
[d1,d2,d3,d4] = mat2mod(unit1file,unit2file,unit3file,unit4file);

% find rows where nsats <= 4
nthresh = 4;
% find rows where pdop >= 15 or = 0
pthresh = 15;

p1 = d1.pdop; p2 = d2.pdop; p3 = d3.pdop; p4 = d4.pdop;
n1 = d1.nsats(:,1); n2 = d2.nsats(:,1); n3 = d3.nsats(:,1); n4 = d4.nsats(:,1);

% plot distances between all 4 GPS units
% compute all 6 distances between 4 GPS receivers
dist12 = sqrt((d1.xyz(:,1)-d2.xyz(:,1)).^2 + (d1.xyz(:,2)-d2.xyz(:,2)).^2 + (d1.xyz(:,3)-d2.xyz(:,3)).^2);
normdist12 = dist12 - nanmean(dist12) + 1;
dist12 = rmNaNrows(dist12); p = polyfit([1:length(dist12)]',dist12,1);
a12 = 1000*p(1); b12 = p(2); rms12 = rms(dist12); std12 = std(1000*dist12);
x12 = (a12/1000).*[1:length(dist12)]' + b12; e12 = 1000*(x12 - dist12); erms12 = rms(e12);
dist13 = sqrt((d1.xyz(:,1)-d3.xyz(:,1)).^2 + (d1.xyz(:,2)-d3.xyz(:,2)).^2 + (d1.xyz(:,3)-d3.xyz(:,3)).^2);
normdist13 = dist13 - nanmean(dist13) + 2;
dist13 = rmNaNrows(dist13); p = polyfit([1:length(dist13)]',dist13,1);
a13 = 1000*p(1); b13 = p(2); rms13 = rms(dist13); std13 = std(1000*dist13);
x13 = (a13/1000).*[1:length(dist13)]' + b13; e13 = 1000*(x13 - dist13); erms13 = rms(e13);
dist14 = sqrt((d1.xyz(:,1)-d4.xyz(:,1)).^2 + (d1.xyz(:,2)-d4.xyz(:,2)).^2 + (d1.xyz(:,3)-d4.xyz(:,3)).^2);
normdist14 = dist14 - nanmean(dist14) + 3;
dist14 = rmNaNrows(dist14); p = polyfit([1:length(dist14)]',dist14,1);
a14 = 1000*p(1); b14 = p(2); rms14 = rms(dist14); std14 = std(1000*dist14);
x14 = (a14/1000).*[1:length(dist14)]' + b14; e14 = 1000*(x14 - dist14); erms14 = rms(e14);
dist23 = sqrt((d2.xyz(:,1)-d3.xyz(:,1)).^2 + (d2.xyz(:,2)-d3.xyz(:,2)).^2 + (d2.xyz(:,3)-d3.xyz(:,3)).^2);
normdist23 = dist23 - nanmean(dist23) + 4;
dist23 = rmNaNrows(dist23); p = polyfit([1:length(dist23)]',dist23,1);
a23 = 1000*p(1); b23 = p(2); rms23 = rms(dist23); std23 = std(1000*dist23);
x23 = (a23/1000).*[1:length(dist23)]' + b23; e23 = 1000*(x23 - dist23); erms23 = rms(e23);
dist24 = sqrt((d2.xyz(:,1)-d4.xyz(:,1)).^2 + (d2.xyz(:,2)-d4.xyz(:,2)).^2 + (d2.xyz(:,3)-d4.xyz(:,3)).^2);
normdist24 = dist24 - nanmean(dist24) + 5;
dist24 = rmNaNrows(dist24); p = polyfit([1:length(dist24)]',dist24,1);
a24 = 1000*p(1); b24 = p(2); rms24 = rms(dist24); std24 = std(1000*dist24);
x24 = (a24/1000).*[1:length(dist24)]' + b24; e24 = 1000*(x24 - dist24); erms24 = rms(e24);
dist34 = sqrt((d3.xyz(:,1)-d4.xyz(:,1)).^2 + (d3.xyz(:,2)-d4.xyz(:,2)).^2 + (d3.xyz(:,3)-d4.xyz(:,3)).^2);
normdist34 = dist34 - nanmean(dist34) + 6;
dist34 = rmNaNrows(dist34); p = polyfit([1:length(dist34)]',dist34,1);
a34 = 1000*p(1); b34 = p(2); rms34 = rms(dist34); std34 = std(1000*dist34);
x34 = (a34/1000).*[1:length(dist34)]' + b34; e34 = 1000*(x34 - dist34); erms34 = rms(e34);

% find good (g) and bad (b) data
% [g b] = h
d12 = normdist12; d13 = normdist13; d14 = normdist14;
d23 = normdist23; d24 = normdist24; d34 = normdist34;
good12 = d12; bad12 = d12; good13 = d13; bad13 = d13; good14 = d14; bad14 = d14;
good23 = d23; bad23 = d23; good24 = d24; bad24 = d24; good34 = d34; bad34 = d34;
good12(p1>=pthresh | p1==0 | n1<=nthresh | p2>=pthresh | p2==0 | n2<=nthresh) = NaN;
bad12(p1<pthresh & n1>nthresh & p2<pthresh & n2>nthresh) = NaN;
good13(p1>=pthresh | p1==0 | n1<=nthresh | p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
bad13(p1<pthresh & n1>nthresh & p3<pthresh & n3>nthresh) = NaN;
good14(p1>=pthresh | p1==0 | n1<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bad14(p1<pthresh & n1>nthresh & p4<pthresh & n4>nthresh) = NaN;
good23(p2>=pthresh | p2==0 | n2<=nthresh | p3>=pthresh | p3==0 | n3<=nthresh) = NaN;
bad23(p2<pthresh & n2>nthresh & p3<pthresh & n3>nthresh) = NaN;
good24(p2>=pthresh | p2==0 | n2<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bad24(p2<pthresh & n2>nthresh & p4<pthresh & n4>nthresh) = NaN;
good34(p3>=pthresh | p3==0 | n3<=nthresh | p4>=pthresh | p4==0 | n4<=nthresh) = NaN;
bad34(p3<pthresh & n3>nthresh & p4<pthresh & n4>nthresh) = NaN;

% plotting
ah(1) = subplot(3,2,1);
histogram(e12)
title('GPS Pair 1-2')
xlabel('Residuals [mm]')
ylabel('Counts')

ah(2) = subplot(3,2,2);
histogram(e13)
title('GPS Pair 1-3')
xlabel('Residuals [mm]')
ylabel('Counts')

ah(3) = subplot(3,2,3);
histogram(e14)
title('GPS Pair 1-4')
xlabel('Residuals [mm]')
ylabel('Counts')

ah(4) = subplot(3,2,4);
histogram(e23)
title('GPS Pair 2-3')
xlabel('Residuals [mm]')
ylabel('Counts')

ah(5) = subplot(3,2,5);
histogram(e24)
title('GPS Pair 2-4')
xlabel('Residuals [mm]')
ylabel('Counts')

ah(6) = subplot(3,2,6);
histogram(e34)
title('GPS Pair 3-4')
xlabel('Residuals [mm]')
ylabel('Counts')

tt=supertit(ah([1 2]),sprintf('1 Hour of Ship Data Starting from %s',datestr(d1.t(1))));
movev(tt,0.3)