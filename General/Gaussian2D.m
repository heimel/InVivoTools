function [cx,cy,sx,sy,cxy,PeakOD] = Gaussian2D(m,tol,rect,fast)
%Gaussian2D fits a 2-D gaussian to an array of values
%%
%%  [cx,cy,sx,sy,cxy,PeakOD] = Gaussian2D(m,tol);
%%
%% m = image
%% tol = fitting tolerance
%% adapted from 
%%%   http://jilawww.colorado.edu/bec/BEC_for_everyone/matlabfitting.htm
%%% by Alexander Heimel
%
% 2006-12-19 JFH Added conversion to rect coordinates
% 2006-12-21 JFH Added varying the covariance

if nargin<4
    fast = false; 
end

if nargin<3
    rect=[];
end
if nargin<2
    tol=0.001;
end


options = optimset('Display','off','TolFun',tol,'LargeScale','off');

[sizey sizex] = size(m);
[cx,cy,sx,sy] = centerofmass(m);
PeakOD = max(m(:));

%fprintf('\n')
%disp([num2str(cx,2) ' ' num2str(cy,2) ' ' num2str(sx,2) ' ' num2str(sy,2) ' ' num2str(0,2) ' ' num2str(PeakOD,2)])

if sx~=0 
    mx = m( max(1,min(round(cy),end)),:);
    x1D = 1:sizex;
    ip1D = [cx,sx,PeakOD];
    fp1D = fminsearch(@fitGaussian1D,ip1D,options,mx,x1D);
    
    cx = fp1D(1);
    sx = fp1D(2);
    PeakOD = fp1D(3);
end

%disp([num2str(cx,2) ' ' num2str(cy,2) ' ' num2str(sx,2) ' ' num2str(sy,2) ' ' num2str(0,2) ' ' num2str(PeakOD,2)])

if sy~=0
    my = m(:,max(1,min(round(cx),end)) )';
    y1D = 1:sizey;
    ip1D = [cy,sy,PeakOD];
    fp1D = fminsearch(@fitGaussian1D,ip1D,options,my,y1D);
    cy = fp1D(1);
    sy = fp1D(2);
    PeakOD = fp1D(3);
end


cxy=0;

%disp([num2str(cx,2) ' ' num2str(cy,2) ' ' num2str(sx,2) ' ' num2str(sy,2) ' ' num2str(cxy,2) ' ' num2str(PeakOD,2)])

if sx~=0 && sy~=0
    [X,Y] = meshgrid(1:sizex,1:sizey);
    if ~fast
        initpar = [cx,cy,sx,sy,cxy,PeakOD];
        fp = fminsearch(@fitGaussian2D,initpar,options,m,X,Y);
        cx = fp(1);
        cy = fp(2);
        sx = fp(3);
        sy = fp(4);
        cxy = fp(5);
        PeakOD = fp(6);
    else
        initpar = [sx,sy,cxy,PeakOD];
        fp = fminsearch(@fitGaussian2Dfast,initpar,options,m,X,Y,cx,cy);
        sx = fp(1);
        sy = fp(2);
        cxy = fp(3);
        PeakOD = fp(4);
    end
end
%disp([num2str(cx,2) ' ' num2str(cy,2) ' ' num2str(sx,2) ' ' num2str(sy,2) ' ' num2str(cxy,2) ' ' num2str(PeakOD,2)])
%disp('done')
%pause

if ~isempty(rect)
    [cx cy sx sy cxy]=convertcoord(cx,cy,sx,sy,cxy,size(m),rect);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Purpose: convert matrixcoordinates to given rect
function [cx,cy,sx,sy,cxy]=convertcoord(cx,cy,sx,sy,cxy,sizem,rect)
  width_old=sizem(2);
  width_new=rect(3)-rect(1);
  height_old=sizem(1);
  height_new=rect(4)-rect(2);
  cx= (cx-0.5) / width_old * width_new + rect(1);
  sx= sx / width_old*width_new;
  cy=( cy-0.5) / height_old*height_new+rect(2);
  sy=sy/height_old*height_new;
  
  cxy=cxy/height_old*height_new/width_old*width_new;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Purpose: get initial correlation coefficient around known point
function cxy=covariance(m,cx,cy)    
[sizey sizex] = size(m); 
x=(1:sizex);
y=(1:sizey);
xy=y'*x;
cxy=sum(sum(xy.*m))/sum(m(:))-cx*cy;
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: find c of m of distribution
function [cx,cy,sx,sy] = centerofmass(m)

[sizey sizex] = size(m);
vx = sum(m);
vy = sum(m,2)';

vx = vx.*(vx>0);
vy = vy.*(vy>0);

x = (1:sizex);
y = (1:sizey);

cx = sum(vx.*x)/sum(vx);
cy = sum(vy.*y)/sum(vy);

sx = sqrt(sum(vx.*(abs(x-cx).^2))/sum(vx));
sy = sqrt(sum(vy.*(abs(y-cy).^2))/sum(vy));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z] = fitGaussian1D(p,v,x)

%cx = p(1);
%wx = p(2);
%amp = p(3);

zx = p(3)*exp(-0.5*(x-p(1)).^2./(p(2)^2)) - v;

z = sum(zx.^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z] = fitGaussian2D(p,m,X,Y)
%cx = p(1);
%cy = p(2);
%sx = p(3);
%sy = p(4);
%cxy = p(5);
%amp = p(6);

xm=(X-p(1));
ym=(Y-p(2));
detc=(p(3)*p(4))^2-p(5)^2;
ztmp = (exp(-0.5/detc*( p(4)^2*xm.^2 - 2*p(5)*xm.*ym + p(3)^2*ym.^2 ))) ;
ztmp =ztmp*p(6);
%neglect deviations from baseline
%ztmp = ztmp.*(ztmp-m);
%proper error:
ztmp=ztmp-m;
z = ztmp(:)'*ztmp(:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z] = fitGaussian2Dfast(p,m,X,Y,cx,cy)
%sx = p(1);
%sy = p(2);
%cxy = p(3);
%amp = p(4);

xm=(X-cx);
ym=(Y-cy);
detc=(p(1)*p(2))^2-p(3)^2;
ztmp = (exp(-0.5/detc*( p(2)^2*xm.^2 - 2*p(3)*xm.*ym + p(1)^2*ym.^2 ))) ;
ztmp =ztmp*p(4);
%neglect deviations from baseline
%ztmp = ztmp.*(ztmp-m);
%proper error:
ztmp=ztmp-m;
z = ztmp(:)'*ztmp(:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


