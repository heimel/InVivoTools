function [u,z,P,thesign] = mwustat(data1,data2)
% [u,z,P] = mwustat(data1,data2)
% mwustat.m: given vectors data1 and data2, the Mann-Whitney U statistic is
% returned along with the significance statistic Z.  The Z value should be
% compared to T(alpha,infinity) for samples larger than 40 data points,
% otherwise The U value should be compared to a table of the U distribution.
% This implementation assumes a precision in measurements that renders
% tie values (i.e., > 1 occurence of the same value) unlikely.  If tie
% values are expected, this function should be modified.
%
% Adapted from Biostatistical Analysis, Zar JH, Prentice-Hall, 1974.
% This script was written by Carsten D. Hohnke, currently at BCS at MIT
%
% u - the U statistic
% z - the z-score for U
% P - the p-value for that z
% thesign - the sign of the difference (data2 - data1): +1 if Rank2>Rank1
% NOTE: Is this the correct order?
data1=data1(:); data2=data2(:); % JC, to ensure column vectors

% JC, attempt to deal with ties, and do it all better anyway....
n1=length(data1); n2=length(data2);
data=sortrows([[data1 ones(size(data1))];[data2 2*ones(size(data2))]]);
clear data1; clear data2;

data(:,3)=[1:size(data,1)]'; % the positions are the ranks

test=1;
if(~test)
vals=unique(data(:,1)); % get all the unique values
for v=vals' % to account for ties, make the ranks the avg. of all similar
            % values' ranks....
  theset=find(data(:,1)==v);
  if(length(theset)>1) data(theset,3)=mean(theset); end;
%  else data(theset,3)=theset; end;
end
clear vals;
else
h=1; numthisval=1; v=data(h,1); startval=h;
while(h<size(data,1))
  h=h+1;
  if(data(h,1)==v) numthisval=numthisval+1;
  else
    if(numthisval>1)
%      fprintf(1,'.');
      data(startval:(h-1),3)=mean(data(startval:(h-1),3));
    end;
    startval=h; v=data(h,1); numthisval=1;
  end;
end;
% finally, do the last value
if(numthisval>1) data(startval:(h),3)=mean(data(startval:(h),3)); end;
end

% extract the ranks
rank1=data(find(data(:,2)==1),3);
rank2=data(find(data(:,2)==2),3);

clear data;
u = n1*n2+((n1*(n1+1))/2)-sum(rank1); clear rank1;
% compute the sign of the stat
u2 = n1*n2+((n2*(n2+1))/2)-sum(rank2); clear rank2;
if(u<u2) thesign=+1; else thesign=-1; end; % sign for 2-1

up = n1*n2-u;
u = max(u,up);
z = (u-(n1*n2)/2)/sqrt((n1*n2*(n1+n2+1))/12);
df=n1+n2-2;
%P=1-jtcdf(z,df);
P=1-normcdf(z,0,1);

P=2*min(P,1-P); % to make it two-tailed.....
