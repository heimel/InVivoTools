function [pvals]=significant_pixels(filenames,stims,bv_mask,framesuse,outmeth,normmeth,normflag)

info = imagefile_info(filenames{1});
pvals = single(ones(info.xsize,info.ysize));

 % divide into pieces
ht = fix(2:info.ysize/5:info.ysize-1);
wt = fix(2:info.xsize/5:info.xsize-1);
if wt(end)~=info.xsize-1, wt(end+1) = info.xsize-1; end;
if ht(end)~=info.ysize-1, ht(end+1) = info.ysize-1; end;

dummy=single(zeros(info.xsize,info.ysize));
d = reshape(stims,1,prod(size(stims)));

for i=1:length(wt)-1,
	i,
	for j=1:length(ht)-1,
		dummy(wt(i)-1:wt(i+1)+1,ht(j)-1:ht(j+1)+1)=1;
		szy=ht(j+1)-ht(j)+3;
		szx=wt(i+1)-wt(i)+3;
		inds = find(dummy);
		if ~isempty(inds),
			[ind]=average_image_pixels(filenames,d,framesuse,inds,outmeth,normmeth,normflag);
			ind = reshape(mean(ind,2),size(ind,1),size(ind,3),size(ind,4));
			for x_=wt(i):wt(i+1),
				x__ = 2+x_-wt(i);  % 1 for being from 1..n, 2 b/c want to avoid first row
				for y_=ht(j):ht(j+1),
					y__ = 2+y_-ht(j);
					clear x;
					kwargstr = 'pv=kruskal_wallis_test(';
					for k=1:size(stims,2),
						x{k} = [];
						kwargstr=[kwargstr 'x{' int2str(k) '},'];
						for l=1:size(stims,1),
							ptsind = find(d==stims(l,k));
							pts = ind(x__+(y__-1)*szx,ptsind(1),:);
							x{k} = cat(2,x{k},reshape(pts,1,length(pts)));
							pts = ind(x__-1+(y__-1)*szx,ptsind(1),:);
							x{k} = cat(2,x{k},reshape(pts,1,length(pts)));
							pts = ind(x__+1+(y__-1)*szx,ptsind(1),:);
							x{k} = cat(2,x{k},reshape(pts,1,length(pts)));
							pts = ind(x__+(y__-1-1)*szx,ptsind(1),:);
							x{k} = cat(2,x{k},reshape(pts,1,length(pts)));
							pts = ind(x__+(y__-1+1)*szx,ptsind(1),:);
							x{k} = cat(2,x{k},reshape(pts,1,length(pts)));
						end;
					end;
					kwargstr = [kwargstr(1:end-1) ');'];
					eval(kwargstr);
					pvals(x_,y_) = pv;
					if (x_+(y_-1)*info.xsize) == 25108, disp(['P value is ' mat2str(pv) ':' mat2str(pv) '.']); end;
				end;
			end;
		dummy(inds) = 0; % rezero
		end; % if ~isempty(inds)
	end;
end;

pvals(find(bv_mask))=2;  % ignore background pixels
pvals(1,:) = 2; pvals(end,:) = 2; pvals(:,1) = 2; pvals(:,end) = 2;
