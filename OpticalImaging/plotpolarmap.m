function [imhandle,ctab,or_angs]=plotpolarmap(or_map,numColors,setctab,mask)

or_angs = rescale(mod(angle(or_map),2*pi),[0 2*pi],[2 numColors+1]);
if ~isempty(mask), or_angs(find(mask)) = 0; end;
imhandle=image(or_angs);

ctab = [];
if setctab,
	ctab = fitzlabclut(numColors);
	ctab = [0 0 0; ctab];
	colormap(ctab);
end;
