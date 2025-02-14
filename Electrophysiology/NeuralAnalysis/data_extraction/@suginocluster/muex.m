function [stime,stype,csp,cest,idx] = muex(me,data,C,dt)

samps = []; vals = [];
stime = []; stype = [];

[V,D] = eig(C);
T = V*sqrt(inv(D));

m = mean(data);
data = data - repmat(m,size(data,1),1);
e = sum((data*T)'.^2);

ppos = peakPos2(e',chi2inv(me.MEparams.thresh,4),...
		max(1,floor(me.MEparams.peak_sep/dt)),...
		floor(me.MEparams.overlap_sep/dt)); 
if length(ppos)==0, return; end;

pnwin1 = ceil(300e-6/dt);
pnwin2 = ceil(2500e-6/dt);
npwin = ceil(600e-6/dt);
npwin2 = ceil(1500e-6/dt);
maxlength=length(e);
wwin = max([pnwin1 pnwin2 npwin npwin2]);
ppos = ppos(find((ppos-wwin>1)&(ppos+wwin<maxlength)));

ns = sqrt(mean(diag(C)));
s = ones(length(ppos),1);
for k=1:length(ppos),
      s(k)=sd_calcSign(data,ppos(k),max(1,floor(me.MEparams.peak_sep/dt)),ns);
end;

segst = find(diff(ppos)>ceil(me.MEparams.event_sep/dt));
segst = [1;(segst+1);length(ppos)+1];
nseg  = length(segst)-1;


th2 = chi2inv(me.MEparams.thresh2,4);
for k=1:nseg,
  [st,typ]=sd_procSpSeg(e,s,ppos,segst,k,dt);
  [st,typ]=sd_checkFront(data,e,st,typ,th2,ns,dt,...
      max(1,floor(me.MEparams.peak_sep/dt)),floor(me.MEparams.overlap_sep/dt));
  stime = [ stime; st ];
  stype = [ stype; typ];
end;

[cest,idx]=sd_removeOverlaps2(stime,stype);
[cest,idx]=sd_removeEdges(me,cest,idx,dt);
[csp,idx] =sd_resampleAlign2(me,data,cest,idx,dt);
