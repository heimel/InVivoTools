function hb = shiftedbar(bins, data, shft,col)

% SHIFTEDBAR - Shifted bar graph
%
%  HB = SHIFTEDBAR(BINS, DATA, SHFT, COL)
%
%  Draws a bar graph that is shifted from the X-axis by SHFT and using color
%  COL (a 1x3 RGB color).  If BINS and DATA have multiple rows, then
%  multiple graphs are drawn, and SHFT can be a vector giving the offset for
%  each graph and COL can be nx3, describing the color for each graph.
%  HB is the set of patch handles created during the drawing.
%
%  SHIFTEDBAR assumes one is plotting histogram data, so BINS should have one
%  more column than DATA, since DATA(i,j) is the number of points between
%  BINS(i,j) and BINS(i,j+1).
%
%  See also:  BAR, BARH, HIST, HISTC

nRow = size(bins,1);
nCol = size(bins,2);

if size(data,2)~=(nCol-1),
	disp(['data must have one fewer column than bins.']);
end;

if nRow>1,
	if ~(eqlen(size(shft),[1 1])|prod(size(shft))~=nRow),
	  error(['shft must have == number of points as bins,data have rows.'; end;
	if eqlen(size(shft),[1 1]), shft = repmat(shft,1,nRow); end;
    if size(col,1)==1, col = repmat(col,nRow,1); end;
end;

hb = [];

for i=1:nRow,
	for j=1:nCol-1,
		x=[bins(i,j) bins(i,j+1) bins(i,j+1) bins(i,j)];
		y=[0 0 data(i,j) data(i,j)]+shft(i);
		hb(end+1)=patch(x,y,col(i,:));
	end;
end;
