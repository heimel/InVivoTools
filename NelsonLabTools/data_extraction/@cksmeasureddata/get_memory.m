function [b,cksmd] = get_memory(cksmd,interval)

[inter,cksmd] = get_intervals(cksmd);

if nargin==1, inter = [cksmd.tint(1,1) cksmd.tint(end,2)]; end;
if interval(2)<interval(1), error('interval(2) must be >= interval(1)');end;

[data,discont] = get_data(cksmd.measureddata,interval,2);

check1 = find(interval(1)>=inter(:,1));
check2 = find(interval(2)<=inter(:,2));
int_start = size(interval,1)+1;
int_stop  = size(interval,1);
if ~isempty(check1),
   int_start = check1(end);
   if ~isempty(check2),
       int_stop = check2(1);
   else, int_stop = size(interval,1);
   end;
end;

b = 0; mult = 1;
for i=int_start:int_stop,
   if i==int_start,
     s0 = fix((interval(1)-inter(int_start,1))/cksmd.acq(int_start).samp_dt)+1;
     t0 = inter(int_start,1)+(s0-1)*cksmd.acq(int_start).samp_dt;
   else, s0=1; t0=inter(int_start,1);
   end;
   if i==int_stop,
     s1 = fix((interval(2)-inter(int_stop, 1))/cksmd.acq(int_stop).samp_dt)+1;
     t1 = inter(int_stop,1)+(s1-1)*cksmd.acq(int_stop).samp_dt;
   else, s1 = inter(int_stop,2)*cksmd.acq(int_stop).samp_dt;
         t1 = inter(int_stop,1)+(s1-1)*cksmd.acq(int_stop).samp_dt;
   end;
   switch(cksmd.acq(i).type),
   case 'tetrode',
     mult = 5;
   case {'singleEC','singleIC','fieldrecording'},
     mult = 2;
   otherwise, mult = 2;
   end;
   b = b + mult*8*(s1-s0+1);
end;
