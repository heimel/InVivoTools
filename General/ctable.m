function ct = ctable(cmap, sz)

%  CTABLE  Creates a color table from a colormap.
%
%  CT = CTABLE(CMAP [, SZ])
%
%  Returns a color table matrix from the colormap CMAP.  The color table is
%  3xSZ, and if size is not specified SZ is assumed to be 256.  Each entry
%  of the colortable CT(i+1,j+1,k+1) contains the index of the closest
%  color in the colormap cmap, where i,j,and k run from 1...SZ.

ct = repmat(uint8(-1),[ sz sz sz]);

for i=0:sz-1,
  for j=0:sz-1,
    disp(['i: ' int2str(i) ', j: ' int2str(j) '.']);
    for k=0:sz-1,
       [v,ind]=min(sum(repmat([i j k]/sz,size(cmap,1),1)-cmap,2));
       ct(i+1,j+1,k+1) = ind;
    end;
  end;
end;
