function [mult,g,wvs] = get_calib_shift(pathn, fname, sampdt)

howlong = 27;

pathn = fixpath(pathn);

eval(['load ' pathn 'stims']);

fname1=[pathn 'r001_' fname];
fname2=[pathn 'r002_' fname];
fname3=[pathn 'r003_' fname];
%fname4=[pathn 'r004_' fname];
%fname5=[pathn 'r005_' fname];

g=-[loadIgor(fname1);loadIgor(fname2);loadIgor(fname3);];%loadIgor(fname4)];...
%    loadIgor(fname5);];
t = 0:sampdt:howlong;
mfr = MTI2{1}.frameTimes-start;
mfr = mfr(find(mfr<howlong));
mfrs = (round(mfr/sampdt)+1)';
strt=fix(0.000/sampdt);
stop=fix(0.007/sampdt);
indmat = repmat(mfrs,1,length(strt:stop))+repmat((strt:stop),length(mfrs),1);
wvs = g(indmat);
[m,i]=min(wvs');
[p,s]=polyfit(mfr,i*sampdt,1);
figure(2);hold off;
plot(mfr,i*sampdt,'.');hold on; plot(mfr,p(1)*mfr+p(2),'kx');
mult=1/(1-p(1));
