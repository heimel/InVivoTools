function [pvals]=significant_pixels(filenames,stims,bv_mask,framesuse,outmeth,normmeth,normflag)

info = imagefile_info(filenames{1});
pvals = single(ones(info.xsize,info.ysize));

 % divide into 4ths
ht = fix(1:info.ysize/5:info.ysize);
wt = fix(1:info.xsize/5:info.xsize);
if wt(end)~=info.xsize, wt(end+1) = info.xsize; end;
if ht(end)~=info.ysize, ht(end+1) = info.ysize; end;

[Sw,w]=warning;
warning off;

for i=1:length(wt)-1,
	i,
	for j=1:length(ht)-1,
		dummy=single(zeros(info.xsize,info.ysize));
		dummy(wt(i):wt(i+1),ht(j):ht(j+1))=1;
		inds = find(dummy&(1-bv_mask));
		if ~isempty(inds),
		d = reshape(stims,1,prod(size(stims)));
		[ind]=average_image_pixels(filenames,d,framesuse,inds,outmeth,normmeth,normflag);
		ind = reshape(mean(ind,2),size(ind,1),size(ind,3),size(ind,4));
		%[d,stimsi] = sort(reshape(stims,1,prod(size(stims))));
		for p=1:size(ind,1),
			thepts = [];
			thegrps = [];
			for k=1:size(stims,2),
				for l=1:size(stims,1),
					pts = ind(p,find(d==stims(l,k)),:);
					thepts = cat(2,thepts,reshape(pts,1,length(pts)));
					thegrps = cat(2,thegrps,k*ones(1,length(pts)));
				end;
			end;
			pv = myanova1(thepts,thegrps); drawnow; close; close;
			pvals(inds(p)) = pv;
			if inds(p)==25108, disp(['P value is ' mat2str(pv) ':' mat2str(double(pvals(inds(p)))) '.']); end;
		end;
		end; % if ~isempty(inds)
	end;
end;

eval(['warning ' Sw]);
