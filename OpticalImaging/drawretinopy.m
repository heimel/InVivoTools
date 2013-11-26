function cols=drawretinopy(n,m,label)

% DRAWRETINOPY - Draws a picture of 3x2 retinopy stimulus
%
% COLORS=DRAWRETINOPY(N,M,[LABEL])
%
%  Draws a picture of a horizontal retinopy stimulus with number of stimuli
%  NxM in the current axes.  The colors used are returned in COLORS.
%
%  If label is given and is 1, text labels are drawn.

if nargin>2, LABEL=label; else, LABEL=[]; end;

inbox = drawcomputerscreen;

szx = inbox(3)-inbox(1);
szy = inbox(4)-inbox(2);

wd = szx/n; ht = szy/m;

cols=retinotopy_colormap(n,m);
colormap(cols);

for j=1:m,
  for i=1:n,
    patch_x = [inbox(1)+(i-1)*wd inbox(1)+i*wd ...
	       inbox(1)+i*wd inbox(1)+(i-1)*wd inbox(1)+(i-1)*wd];
    patch_y = [inbox(2)+(j-1)*ht inbox(2)+(j-1)*ht ...
	       inbox(2)+(j)*ht   inbox(2)+(j)*ht ...
	       inbox(2)+(j-1)*ht];
    ctr = [mean([inbox(1)+(i-1)*wd inbox(1)+i*wd]) mean([inbox(2)+(j-1)*ht inbox(2)+(j)*ht])];
    fill(patch_x,patch_y,cols((j-1)*n+i,:));
    if ~isempty(LABEL),
      text(ctr(1),ctr(2),int2str((j-1)*n+i),'fontname','helvetica',...
	   'horizontalalignment','center','verticalalignment','middle',...
	   'fontsize',9);
    end;
  end;
end;
