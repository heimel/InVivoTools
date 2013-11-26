function [linepoints,inds,selX,selY] = lineselectpixels(pt1,pt2,X,Y)

% LINESELECTPIXELS - Select pixels defined by a line
%
%  [LINEPOINTS,INDS,SELX,SELY]=LINESELECTPIXELS(PT1,PT2,X,Y)
%
% Selects pixels from a sampled grid between two points.  Pixels are
% considered selected if the imaginary line through points PT1=[X0 Y0] and
% PT2=[X1 Y1] intersects the pixel.The pixel points are projected onto the line
% at distances from PT2 specified in LINEPOINTS.  X and Y specify the
% center location of each pixel in the square grid, and are assumed to be
% equally spaced.  INDS is an array of selected matrix indicies if the
% grid defined by X AND Y were represented in a LENGTH(Y)xLENGTH(X)
% matrix and has length equal to LENGTH(LINEPOINTS).
% SELX and SELY are the X and Y center coordinates of each pixel
% projected onto the line between PT1 and PT2.
%
% Bug: presently the distances in LINEPOINTS seem to be randomly chosen
% from PT1 or PT2, so don't count on these distances being measured from PT1
% or PT2 (best to check).  Low priority fix.

if size(X,1)>size(X,2), X=X';end; if size(Y,1)>size(Y,2), Y=Y';end;

[XX,YY]=meshgrid(X,Y);

sel = zeros(length(Y),length(X));

dx=X(2)-X(1);dy=Y(2)-Y(1);
Xbord=[X-dx/2 X(end)+dx/2];Ybord=[Y-dy/2 Y(end)+dy/2];

if (pt2(1)-pt1(1))~=0,
	m=(pt2(2)-pt1(2))/(pt2(1)-pt1(1));
	b=pt2(2)-m*pt2(1);
	Yz=m*Xbord+b;
else,
	Yz=repmat(NaN,1,length(Xbord)); m=Inf; b = pt2(1);
	Xz=repmat(pt2(1),1,length(Ybord));
end;
if pt1(1)>pt2(1),PT1=pt2;PT2=pt1;else,PT1=pt1;PT2=pt2;end;

A2 = ((Xbord(1:end-1)>=PT1(1))&(Xbord(2:end)<=PT2(1)))|...
	 ((Xbord(1:end-1)<=PT1(1))&(Xbord(2:end)>=PT1(1)))|...
	 ((Xbord(1:end-1)<=PT2(1))&(Xbord(2:end)>=PT2(1)));

if PT1(2)>=PT2(2), pttmp=PT1; PT1=PT2; PT2=pttmp; end;
	 % make sure we're increasing; X order no longer matters

for i=1:length(Y),
	A = ((Yz(2:end)>=Ybord(i+1))&(Yz(1:end-1)<Ybord(i+1)))|...
	    ((Yz(2:end)<=Ybord(i))  &(Yz(1:end-1)>=Ybord(i)))|...
		((Yz(2:end)<=Ybord(i+1))&(Yz(2:end)>=Ybord(i)))|...
		((Yz(1:end-1)<=Ybord(i+1))&(Yz(1:end-1)>=Ybord(i)));
	C=(((PT1(2)>=Ybord(i))&(PT1(2)<=Ybord(i+1)))|...
	   ((PT1(2)<=Ybord(i))&(PT2(2)>=Ybord(i))))*ones(size(A2));
	B = ((Yz(1:end-1)<=Ybord(i))&(Yz(2:end)>=Ybord(i+1)))|...
	    ((Yz(1:end-1)>=Ybord(i))&(Yz(1:end-1)<=Ybord(i+1)))|...
	    ((Yz(2:end)>=Ybord(i))&(Yz(2:end)<=Ybord(i+1)));
	sel(i,:) = A2&(B|((m==Inf)&C));
end;

inds=find(sel); selX=XX(inds); selY=YY(inds); linepoints=[];

for i=1:length(inds),
	[d,xx,yy]=dist2line(m,b,[XX(inds(i)) YY(inds(i))]);
	linepoints(i)=sqrt( (xx-pt1(1))^2 + (yy-pt1(2))^2 );
	if xx<pt1(1), linepoints(i)=-linepoints(i);end;
end;
