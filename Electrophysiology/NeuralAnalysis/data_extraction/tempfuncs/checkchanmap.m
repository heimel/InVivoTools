function checkchanmap(use16)

%  CHECKCHANMAP (USE16)
%
%  Run this in a data directory, and it will check to see if the channel
%  mapping is correct.  It will look at the correlation channel 1 of each
%  tetrode with all of the other channels, numbered starting 1 to 4 with the
%  first tetrode in the acqParams_out file and increasing with each additional
%  tetrode.
% 
%  If use16 is true, it does all sixteen channels.  Otherwise it does 8.

n = 8;
g(:,1)  = loadIgor('r001_tet1_c01');
g(:,2)  = loadIgor('r001_tet1_c02');
g(:,3)  = loadIgor('r001_tet1_c03');
g(:,4)  = loadIgor('r001_tet1_c04');
g(:,5)  = loadIgor('r001_tet2_c01');
g(:,6)  = loadIgor('r001_tet2_c02');
g(:,7)  = loadIgor('r001_tet2_c03');
g(:,8)  = loadIgor('r001_tet2_c04');
if use16,
 n = 16;
 g(:,9)  = loadIgor('r001_tet3_c01');
 g(:,10) = loadIgor('r001_tet3_c02');
 g(:,11) = loadIgor('r001_tet3_c03');
 g(:,12) = loadIgor('r001_tet3_c04');
 g(:,13) = loadIgor('r001_tet4_c01');
 g(:,14) = loadIgor('r001_tet4_c02');
 g(:,15) = loadIgor('r001_tet4_c03');
 g(:,16) = loadIgor('r001_tet4_c04');
end;


for i=1:n,
	j1(i) = xcorr(g(:,1),g(:,i),0);
	j2(i) = xcorr(g(:,5),g(:,i),0);
	if use16, j3(i) = xcorr(g(:,9),g(:,i),0);
	          j4(i) = xcorr(g(:,13),g(:,i),0); end;
end;

figure
subplot(4,1,1); bar(j1); subplot(4,1,2); bar(j2);
if use16, subplot(4,1,3); bar(j3); subplot(4,1,4); bar(j4); end;

