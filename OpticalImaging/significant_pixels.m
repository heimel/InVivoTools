function [pvals]=significant_pixels(filenames,stims,bv_mask,framesuse,outmeth,normmeth,normflag)

info = imagefile_info(filenames{1});
pvals = single(ones(info.xsize,info.ysize));

 % divide into 4ths
ht = fix(1:info.ysize/4:info.ysize);
wt = fix(1:info.xsize/4:info.xsize);
if wt(end)~=info.xsize, wt(end+1) = info.xsize; end;
if ht(end)~=info.ysize, ht(end+1) = info.ysize; end;

for i=1:length(wt)-1,
	i,
	for j=1:length(ht)-1,
		dummy=single(zeros(info.xsize,info.ysize));
		dummy(wt(i):wt(i+1),ht(j):ht(j+1))=1;
		inds = find(dummy&(1-bv_mask));
		if ~isempty(inds),
		[ind]=average_image_pixels(filenames,reshape(stims,1,prod(size(stims))),...
			framesuse,inds,outmeth,normmeth,normflag);
		ind = reshape(mean(ind,2),size(ind,1),size(ind,3),size(ind,4));
		[d,stimsi] = sort(reshape(stims,1,prod(size(stims))));
		for p=1:size(ind,1),
			clear x;
			kwargstr = 'pv=kruskal_wallis_test(';
			for k=1:size(stims,2),
				kwargstr=[kwargstr 'x{' int2str(k) '},'];
				x{k} = [];
				for l=1:size(stims,1),
					pts = ind(p,find(d==stims(l,k)),:);
					x{k} = cat(2,x{k},reshape(pts,1,length(pts)));
				end;
			end;
			kwargstr = [kwargstr(1:end-1) ');'];
			eval(kwargstr);
			pvals(inds(p)) = pv;
		end;
		end; % if ~isempty(inds)
	end;
end;
