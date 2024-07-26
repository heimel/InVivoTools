function [data,T,discont,ncksmd] = get_data(cksmd,interval,warnon)
if nargin<=2, warn = 0; else, warn = warnon; end;
if interval(2)<interval(1), error('interval(2) must be >= interval(1)');end;

[inter,cksmd] =  get_intervals(cksmd);
[data,discont] = get_data(cksmd.measureddata,interval,warn);

if interval(1)<min(inter(:,1)), interval(1) = inter(1); end; % if user wanted warning it would
if interval(2)>max(inter(:,2)), interval(2) = inter(2); end; % already have happened
check1 = find(interval(1)>=inter(:,1));
check2 = find(interval(2)<=inter(:,2));
%check1,check2,
int_start = size(interval,1)+1;
int_stop  = size(interval,1);
if ~isempty(check1),
   int_start = check1(end);
   if ~isempty(check2),
       int_stop = check2(1);
   else, int_stop = size(interval,1);
   end;
end;
%disp(['int_start:int_stop = ' int2str(int_start) ':' int2str(int_stop) '.']);
data = single([]);
T = single([]);
for i=int_start:int_stop,
   %i,
   if i==int_start,
     s0 = fix((interval(1)-inter(int_start,1))/cksmd.acq(int_start).samp_dt)+1;
   else, s0=1; t0=inter(int_start,1);
   end;
   if i==int_stop,
     s1 = fix((interval(2)-inter(int_stop, 1))/cksmd.acq(int_stop).samp_dt)+1;
   else, s1 = inter(int_stop,2)*cksmd.acq(int_stop).samp_dt;
   end;
   %int_start,int_stop,s0,s1,s1-314390,t0,t1,t1-t0
   [d_temp,t_temp] = loaddata(cksmd,i,s0,s1,inter(i,1));
   data = cat(1,data,d_temp);  % no longer need to divide by cksmd.acq(i).ECGain
   T = cat(1,T,t_temp);
end;

data = double(data); T = double(T);
ncksmd = cksmd;
%disp('end of function.');
function [d,T] = loaddata(cksmd,i,s0,s1,intstart)
%disp(['Loading directory ' cksmd.dirnames{i} ]);
S0f = floorfloor(s0/(cksmd.ckslen/cksmd.acq(i).samp_dt))+1;
S0s = round(s0 - (S0f-1)*(cksmd.ckslen/cksmd.acq(i).samp_dt));
S1f = floorfloor(s1/(cksmd.ckslen/cksmd.acq(i).samp_dt))+1;
S1s = round(s1 - (S1f-1)*(cksmd.ckslen/cksmd.acq(i).samp_dt));
d = single([]); T = single([]);
for k=S0f:S1f,
   if k==S0f, s_o = S0s;
              t_o = (k-1)*cksmd.ckslen+(S0s-1)*cksmd.acq(i).samp_dt;
   else,      s_o = 1;
              t_o = (k-1)*cksmd.ckslen;
   end;
   if k==S1f, s_e = S1s;
              t_e = (k-1)*cksmd.ckslen+(S1s-1)*cksmd.acq(i).samp_dt;
   else,      s_e = Inf;
              t_e = k*cksmd.ckslen-cksmd.acq(i).samp_dt;
   end;
   d = cat(1,d,loadfiledata(cksmd,k,i,s_o,s_e));
   T = cat(1,T,((intstart+t_o):cksmd.acq(i).samp_dt:(t_e+intstart))');
end;

function d = loadfiledata(cksmd,k,i,s_o,s_e)
pf= [fixpath([fixpath(cksmd.thedir) cksmd.dirnames{i}]) 'r' sprintf('%.3d',k)];
switch(cksmd.acq(i).type),
case 'tetrode',
  fname1=[pf '_' cksmd.acq(i).fname '_c01'];
  fname2=[pf '_' cksmd.acq(i).fname '_c02'];
  fname3=[pf '_' cksmd.acq(i).fname '_c03'];
  fname4=[pf '_' cksmd.acq(i).fname '_c04'];
  d=[single(loadIgor(fname1,s_o,s_e)) single(loadIgor(fname2,s_o,s_e))  ...
     single(loadIgor(fname3,s_o,s_e)) single(loadIgor(fname4,s_o,s_e)) ];
  %disp(['L ' fname1 ' from ' int2str(s_o) ' to ' int2str(s_e) ', got ' int2str(size(d,1)) ' samps.']);
case {'singleEC','singleIC','fieldrecording','singleLF'},
  fname=[pf '_' cksmd.acq(i).fname ]; d = single(loadIgor(fname,s_o,s_e)); %disp(['loading file']);
end;
