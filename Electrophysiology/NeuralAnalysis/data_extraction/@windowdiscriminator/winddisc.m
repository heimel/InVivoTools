function [samps,vals] = winddisc(wd,data,thresh1,thresh2)

samps = []; vals = []; begshift = 0;

if size(data,2)>size(data,1),data=data';end;

if thresh2-thresh1>0,
   z = find(data>=thresh1);
   if ~isempty(z),
      d = [1; find(diff(z)~=1)+1];
      d=[d; length(z)+1];
      if z(1)==1,
         if wd.WDparams.allowborders,
            begshift=1; data=[thresh1-1; data]; z=z+1;
	 else, d=d(2:end); end;
      end;
      if z(end)==length(data),
         if wd.WDparams.allowborders, data=[data; thresh1-1];
	 else, d=d(1:end-1); end;
      end;
      for i=2:length(d),
	%k=local_max(data((z(d(i-1))-1):(z(d(i)-1)+1)));
	[m,k]=max(data((z(d(i-1))-1):(z(d(i)-1)+1)));
	if (length(k)==1&isempty(find(data(z(d(i-1))-2+k)>=thresh2))),
	   samps = [samps z(d(i-1))+k-2-begshift];
	   vals = [vals data(z(d(i-1))+k-2)];
        end;
      end;
   end;
else,
   z = find(data<=thresh1);
   if ~isempty(z),
      d = [1; find(diff(z)~=1)+1];
      d=[d; length(z)+1];
      if z(1)==1,
         if wd.WDparams.allowborders,
            begshift=1; data=[thresh1+1; data]; z=z+1;
	 else, d=d(2:end); end;
      end;
      if z(end)==length(data),
         if wd.WDparams.allowborders, data=[data; thresh1+1];
	 else, d=d(1:end-1); end;
      end;
      for i=2:length(d),
	%k=local_max(-data((z(d(i-1))-1):(z(d(i)-1)+1)));
	[m,k]=max(-data((z(d(i-1))-1):(z(d(i)-1)+1)));
	if (length(k)==1&isempty(find(data(z(d(i-1))-2+k)<=thresh2))),
	   samps = [samps z(d(i-1))+k-2-begshift];
	   vals = [vals data(z(d(i-1))+k-2)];
        end;
      end;
   end;
end;


