   % test code

me  = multiextractor('default');
me2 = me;
me  = struct(me); 
dt  = 3.180762746900000e-05;
ldc = 1;
if ldc,
  h =[loadIgor('r001_tet1_c01')';loadIgor('r001_tet1_c02')'; ...
    loadIgor('r001_tet1_c03')';loadIgor('r001_tet1_c04')';];
  h(1,:) = mefilter(me,h(1,:)); h(2,:) = mefilter(me,h(2,:));
  h(3,:) = mefilter(me,h(3,:)); h(4,:) = mefilter(me,h(4,:));
  h = h';
end;
h2=[loadIgor('r001_tet1_c01')';loadIgor('r001_tet1_c02')'; ...
    loadIgor('r001_tet1_c03')';loadIgor('r001_tet1_c04')';];
h2(1,:) = mefilter(me,h2(1,:)); h2(2,:) = mefilter(me,h2(2,:));
h2(3,:) = mefilter(me,h2(3,:)); h2(4,:) = mefilter(me,h2(4,:));
h2=h2';

t0=clock;
if ldc,
  stddev = std(h); m = mean(h);
  he = h - repmat(m,size(h,1),1);         % subtract mean
  he = he./repmat(stddev,size(h,1),1); % normalize
  he = sum(he'.^2)';                    % energy

  z = findcovdata(he,me.MEparams.threshcov,...
   max(1,floor((me.MEparams.pre_time+me.MEparams.post_time)/dt)));

  thecov = cov(h(z,:));
end;

data = h2;

etime(clock,t0),

samps = []; vals = [];
stime = []; stype = [];
[V,D] = eig(diag(diag(thecov)));
T = V*sqrt(inv(D));

m = mean(data);
data = data - repmat(m,size(data,1),1);
e = sum((data*T)'.^2);
e_pos = sum((data.*(data>0)*T)'.^2);
e_neg = sum((data.*(data<0)*T)'.^2);

ppos_c = []; s2 = [];

if me.MEparams.useabs,

   ppos = peakPos2(e',me.MEparams.thresh,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
		%floor(me.MEparams.overlap_sep/dt));
   % compute sign
   ns = sqrt(mean(diag(thecov))); sc = ones(length(ppos),1);
   for k=1:length(ppos), sc(k)=sd_calcSign(data,ppos(k),max(1,floor(me.MEparams.peak_sep/dt)),ns); end;
   if me.MEparams.remove_unresolved,
      ppos_c = peakPos2(e',me.MEparams.thresh3,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
      ppos_c = setdiff(ppos_c,ppos);
      sc2 = zeros(length(ppos),1); % calculate sign
      for k=1:length(ppos_c),sc2(k)=sd_calcSign(data,ppos_c(k),max(1,floor(me.MEparams.peak_sep/dt)),ns);end;
   end;
else, 
   if me.MEparams.datadir==1,,
     thpos = me.MEparams.thresh2; thneg = me.MEparams.thresh;
   elseif me.MEparams.datadir==2,
     thpos = me.MEparams.thresh; thneg = me.MEparams.thresh2;
   else, thpos = me.MEparams.thresh; thneg = me.MEparams.thresh;
   end;
   ppos1= peakPos2(e_pos',thpos,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
		%floor(me.MEparams.overlap_sep/dt));
   ppos2= peakPos2(e_neg',thneg,...
                max(1,floor(me.MEparams.peak_sep/dt)),0);
		%floor(me.MEparams.overlap_sep/dt));
   if length(ppos1)+length(ppos2)>0,
     if me.MEparams.datadir~=0,
       if me.MEparams.datadir==1, pposm=ppos1; pposM=ppos2;
       elseif me.MEparams.datadir==2, pposm=ppos2; pposM=ppos1; end;
       [ppos,s2,iip,iin]=mergePos(me,pposm,pposM,dt);
       sc=zeros(size(ppos));sc(iip)=-(2*me.MEparams.datadir-3);sc(iin)=2*me.MEparams.datadir-3;
     else, [ppos,ii] = unique([ppos1;ppos2]); % all points are major, need to compute sign
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
      sc2 = sc2(ii);
   end;
end;

etime(clock,t0)

if length(ppos)==0, disp('no spikes'); return; end;


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
%if me.MEparams.datadir~=0,
  majMin(majPosInd) = majVal;
  majMin(minPosInd) = minVal;
%else,
%  majMin(majPosInd) = 1;
%end;

segst = find(diff(ppos)>floor(me.MEparams.overlap_sep/dt));
segst = [1;(segst+1);length(ppos)+1];
nseg  = length(segst)-1;
mjmn=[];
pos_db = [];

etime(clock,t0),

th2 = me.MEparams.thresh2;
for k=1:nseg,
  [st,typ]=sd_procSpSeg(e,SC,ppos,segst,k,dt);
  %[st,typ2]=sd_checkFront(data,e,st,typ,th2,ns,dt,... % prob not necessary now
  %    max(1,floor(me.MEparams.peak_sep/dt)),floor(me.MEparams.overlap_sep/dt));
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

etime(clock,t0),

figure(2); clf; plot(h2); hold on;
figure(3); clf; plot(e);  hold on; plot(e_pos,'r'); plot(e_neg,'g'); 
