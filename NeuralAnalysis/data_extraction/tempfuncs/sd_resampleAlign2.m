function [csp,idx]= sd_resampleAlign2(me,ex,cest,cidx,dt)
% [csp,idx]= sd_resampleAlign(ex,cest,cidx,nv)

pre = ceil(me.MEparams.pre_time/dt);
len = ceil(me.MEparams.pre_time/dt)+ceil(me.MEparams.post_time/dt)+1;
os = me.MEparams.oversampling;

premar = 2;			% margin for resampling peak pos adjustment
postmar = 2;
margin = premar + postmar;

X = 1:1:(len+margin);
XX = 1:(1/os):(len+margin);
XOS = 1:(1/os):(len);	% length(XOS) = (len-1)*os + 1 = len*os - os + 1;

L1 = length(XX);
L = length(XOS)	;	% be careful : len*os > length(XX)
N = length(cest);

csp = zeros(4*L,N);
idx = cidx;

count = 1;
for i=1:N
	st = cest(i) - pre;
	if os == 1
		ed = st + len -1;
		if (st > 0 & ed < length(ex))
			YYY = ex(st:ed,:);
		else
			YYY = [];
			idx(i) = nan;
		end
	else	% re-sample
		st = st - premar;
		ed = st + (len+margin) -1;
		if (st > 0 & ed < length(ex))
			YY = spline(X,ex(st:ed,:)',XX);
			ppos = 	os*(pre+premar-1)+1;
			% find max pos around the peak		
			tmp = sum(YY(:,ppos-os:ppos+os).^2);
			[mv,mpos] = max(tmp);
			st0 = (ppos-os)+mpos-1 - os*pre;
			ed0 = st0 + L -1;
			if (st0 > 0 & ed0 <= L1)
				YYY = YY(:,st0:ed0)';
			else
				YYY = [];
				idx(i) = nan;
				disp(['    reject i:' num2str(i) ' st0:' num2str(st0) ' cst(i):' num2str(cest(i))]);	
			end
		else
			YYY = [];
			idx(i) = nan;
		end
	end
	if ~isempty(YYY)
% 		YYY = YYY - ones(size(YYY,1),1)*mean(YYY);
		csp(:,count) = reshape(YYY,4*L,1);
		count = count + 1;
	end		

end

idx = idx(~isnan(idx));

if count > 1
	csp = csp(:,1:(count-1));
else
	csp = [];
end
