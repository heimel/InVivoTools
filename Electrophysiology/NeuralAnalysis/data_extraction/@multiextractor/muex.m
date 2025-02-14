function [stime,stype,csp,cest,idx] = muex(me,data,C,dt,thedir)

samps = []; vals = []; csp = []; cest = []; idx = [];
stime = []; stype = [];

switch me.MEparams.normalize,
   case 0, V=diag(diag(ones(4))); D = diag(diag(ones(4)));
   case 1, [V,D] = eig(C);
   case 2, [V,D] = eig(diag(diag(C)));
end;
T = V*sqrt(inv(D));

m = mean(data);
data = data - repmat(m,size(data,1),1);

samps = []; vals = [];
stime = []; stype = [];
ppos_c = []; s2 = [];

e = sum((data*T)'.^2);

if me.MEparams.useabs,

   ppos = peakPos2(e',me.MEparams.thresh,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
                %floor(me.MEparams.overlap_sep/dt));
   % compute sign
   ns = sqrt(mean(diag(thecov))); sc = ones(length(ppos),1);
   for k=1:length(ppos), sc(k)=sd_calcSign(data,ppos(k),max(1,floor(me.MEparams.peak_sep/dt)),ns); end;
   if me.MEparams.remove_unresolved,
      ppos_c = peakPos2(e',thresh3,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
      ppos_c = setdiff(ppos_c,ppos);
      sc2 = zeros(length(ppos),1); % calculate sign
      for k=1:length(ppos_c),sc2(k)=sd_calcSign(data,ppos_c(k),max(1,floor(me.MEparams.peak_sep/dt)),ns);end;
   end;
else,
   e_pos = sum((data.*(data>0)*T)'.^2);
   e_neg = sum((data.*(data<0)*T)'.^2);
   if me.MEparams.datadir==1,,
     thpos = me.MEparams.thresh2; thneg = me.MEparams.thresh;
   elseif me.MEparams.datadir==2,
     thpos = me.MEparams.thresh; thneg = me.MEparams.thresh2;
   else, thpos = me.MEparams.thresh; thneg = me.MEparams.thresh;
   end;
   if 1,
     if me.MEparams.datadir~=0,
       if me.MEparams.datadir==1,ppos2=peakPos2(e_neg',thneg, max(1,floor(me.MEparams.peak_sep/dt)),0); pposm=[]; pposM=ppos2;
       elseif me.MEparams.datadir==2, ppos1=peakPos2(e_pos',thpos,max(1,floor(me.MEparams.peak_sep/dt)),0);pposm=[]; pposM=ppos1;
       end;
       [ppos,s2,iip,iin]=mergePos(me,pposm,pposM,dt);
       sc=zeros(size(ppos));sc(iip)=-(2*me.MEparams.datadir-3);sc(iin)=2*me.MEparams.datadir-3;
     else,
       ppos1= peakPos2(e_pos',thpos,max(1,floor(me.MEparams.peak_sep/dt)),0);
       ppos2= peakPos2(e_neg',thneg,max(1,floor(me.MEparams.peak_sep/dt)),0);
       [ppos,ii] = unique([ppos1;ppos2]); % all points are major, need to compute sign
       sc = zeros(size(ppos)); sc(find(ii<=length(ppos1)))=1; sc(find(ii>length(ppos1)))=-1;
     end;
   end;
   if me.MEparams.remove_unresolved,
      ppos_cp = peakPos2(e_pos',me.MEparams.thresh3,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
      ppos_cn = peakPos2(e_neg',me.MEparams.thresh3,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
      [ppos_c,ii] = unique([ppos_cp;ppos_cn]);
      % need to calculate sign
      sc2 = zeros(size(ppos_c));  sc2(find(ii<=length(ppos_cp)))=1; sc2(find(ii>length(ppos_cp)))=-1;
      [ppos_c,ii] = setdiff(ppos_c,ppos);
      if size(ppos_c,2)>size(ppos_c,1),ppos_c = ppos_c'; end;
      sc2 = sc2(ii);
   end;
end;

if length(ppos)<2, disp('no spikes'); return; end;

%pnwin1 = ceil(300e-6/dt); pnwin2 = ceil(2500e-6/dt);
%npwin = ceil(600e-6/dt);  npwin2 = ceil(1500e-6/dt);
%maxlength=length(e);
%wwin = max([pnwin1 pnwin2 npwin npwin2]);
%ppos = ppos(find((ppos-wwin>1)&(ppos+wwin<maxlength)));


if me.MEparams.remove_unresolved,
   if me.MEparams.datadir~=0, % if data has direction
      majInd = find(s2==1); % find major direction
      minInd = find(s2~=1);
   else, majInd = 1:length(ppos); minInd = [];
   end;
   ppos_o = ppos;
   [ppos,iii] = unique([ppos;ppos_c]);
   PosInd = find(iii<=length(ppos_o));
   PosCInd= find(iii>length(ppos_o));
   majPosInd = PosInd(majInd);
   minPosInd = sort([(find(iii>length(ppos_o)));(PosInd(minInd))]);
   SC = [sc;sc2]; SC = SC(iii);
else,
   PosInd = 1:length(ppos);
   SC = sc;
   if me.MEparams.datadir~0, % if data has direction
      majInd = find(s2==1); minInd = find(s2~=1);
   else, majInd = 1:length(ppos); minInd = []; % all points are major (abs or ~abs w/o dir)
   end;
   majPosInd = PosInd(majInd); minPosInd = PosInd(minInd);
end;

if me.MEparams.datadir~=0, majVal=2*me.MEparams.datadir-3; minVal = 3-2*me.MEparams.datadir;
else, majVal = 1; minVal = -1; end;

majMin = zeros(size(ppos));
majMin(majPosInd) = majVal;
majMin(minPosInd) = minVal;

segst = find(diff(ppos)>floor(me.MEparams.overlap_sep/dt));
segst = [1;(segst+1);length(ppos)+1];
nseg  = length(segst)-1;
mjmn=[];
pos_db = [];
th2 = me.MEparams.thresh2;
for k=1:nseg,
  [st,typ]=sd_procSpSeg(e,SC,ppos,segst,k,dt);
  [mnm,mnmi]=intersect(ppos(segst(k):segst(k+1)-1),st);
  pos_db = [ pos_db; ppos(segst(k)+mnmi-1)];
  mjmn=[mjmn;majMin(segst(k)+mnmi-1)];
  stime = [ stime; st ];
  stype = [ stype; typ];
end;

stime2=[];  stype2=[];
stime2=stime;stype2=stype;
mjmn2 = find(mjmn==majVal);
stime = stime(mjmn2);
stype = stype(mjmn2);

[cest,idx]=sd_removeOverlaps2(stime,stype);
[cest,idx]=sd_removeEdges(me,cest,idx,dt);
[csp,idx] =sd_resampleAlign2(me,data,cest,idx,dt);

