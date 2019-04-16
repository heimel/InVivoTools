function [Id,dpx,dpy] = tp_lucaskanade(T,I,dpx,dpy)
% You have a template T you want to use to align image I. The function 
% finds the non-rigid displacement field D, and alters I so it aligns with 
% T which results in image Id. The displacement coordinates are returned as 
% dpx and dpy.
% 
% T and I must be the same size!
%
% SOURCE https://xcorr.net/2014/08/02/non-rigid-deformation-for-calcium-imaging-frame-alignment/
% code from Patrick Mineault
% see also paper https://www.sciencedirect.com/science/article/pii/S0165027008004913#app1

% Edited by Laila Blomer, 2019

    warning('off','fastBSpline:nomex');
    Nbasis = 16;
    niter = 25;
    damping = 1;
    deltacorr = .0005;
 
    lambda = .0001*median(T(:))^2;
    %Use a non-iterative algo to get the initial displacement
 
    if nargin < 3
        [dpx,dpy] = doBlockAlignment(I,T,Nbasis);
        dpx = [dpx(1);(dpx(1:end-1)+dpx(2:end))/2;dpx(end)];
        dpy = [dpy(1);(dpy(1:end-1)+dpy(2:end))/2;dpy(end)];
    end
 
    %linear b-splines
    knots = linspace(1,size(T,1),Nbasis+1);
    knots = [knots(1)-(knots(2)-knots(1)),knots,knots(end)+(knots(end)-knots(end-1))];
    spl = fastBSpline(knots,knots(1:end-2));
    B = spl.getBasis((1:size(T,1))');
 
    %Find optimal image warp via Lucas Kanade
 
    Tnorm = T(:)-mean(T(:));
    Tnorm = Tnorm/sqrt(sum(Tnorm.^2));
    B = full(B);
    c0 = mycorr(I(:),Tnorm(:));
 
    %theI = gpuArray(eye(Nbasis+1)*lambda);
    theI = (eye(Nbasis+1)*lambda);
 
    Bi = B(:,1:end-1).*B(:,2:end);
    allBs = [B.^2,Bi];
 
    [xi,yi] = meshgrid(1:size(T,2),1:size(T,1));
 
    bl = quantile(I(:),.01);
 
    for ii = 1:niter
 
        %Displaced template
        Dx = repmat((B*dpx),1,size(T,2));
        Dy = repmat((B*dpy),1,size(T,2));
 
        Id = interp2(I,xi+Dx,yi+Dy,'linear');
 
        Id(isnan(Id)) = bl;
 
        c = mycorr(Id(:),Tnorm(:));
 
        if c - c0 < deltacorr && ii > 1
            break;
        end
 
        c0 = c;
 
        %gradient of template
        dTx = (Id(:,[1,3:end,end])-Id(:,[1,1:end-2,end]))/2;
        dTy = (Id([1,3:end,end],:)-Id([1,1:end-2,end],:))/2;
 
        del = T(:) - Id(:);
 
        %special trick for g (easy)
        gx = B'*sum(reshape(del,size(dTx)).*dTx,2);
        gy = B'*sum(reshape(del,size(dTx)).*dTy,2);
 
        %special trick for H - harder
        Hx = constructH(allBs'*sum(dTx.^2,2),size(B,2))+theI;
        Hy = constructH(allBs'*sum(dTy.^2,2),size(B,2))+theI;
 
        %{
        %Compare with fast method
        dTx_s = reshape(bsxfun(@times,reshape(B,size(B,1),1,size(B,2)),dTx),[numel(dTx),size(B,2)]);
        dTy_s = reshape(bsxfun(@times,reshape(B,size(B,1),1,size(B,2)),dTy),[numel(dTx),size(B,2)]);
 
        Hx = (doMult(dTx_s) + theI);
        Hy = (doMult(dTy_s) + theI);
        %}
 
        dpx_ = Hx\gx;
        dpy_ = Hy\gy;
 
        dpx = dpx + damping*dpx_;
        dpy = dpy + damping*dpy_;
    end
end
 
function thec = mycorr(A,B)
    A = A(:) - mean(A(:));
    A = A / sqrt(sum(A.^2));
    thec = A'*B;
end
 
function H2 = constructH(Hd,ns)
    H2d1 = Hd(1:ns)';
    H2d2 = [Hd(ns+1:end);0]';
    H2d3 = [0;Hd(ns+1:end)]';
 
    H2 = spdiags([H2d2;H2d1;H2d3]',-1:1,ns,ns);
end
 
function [dpx,dpy] = doBlockAlignment(T,I,nblocks)
    dpx = zeros(nblocks,1);
    dpy = zeros(nblocks,1);
 
    dr = 10;
    blocksize = size(T,1)/nblocks;
 
    [xi,yi] = meshgrid(1:size(T,2),1:blocksize);
    thecen = [size(T,2)/2+1,floor(blocksize/2+1)];
    mask = (xi-thecen(1)).^2+(yi-thecen(2)).^2< dr^2;
 
    for ii = 1:nblocks
%         dy = (ii-1)*size(T,1)/nblocks;        % Laila
        dy = round((ii-1)*size(T,1)/nblocks);   % Laila
        rg = (1:size(T,1)/nblocks) + dy;
        T_ = T(rg,:);
        I_ = I(rg,:);
        T_ = bsxfun(@minus,T_,mean(T_,1));
        I_ = bsxfun(@minus,I_,mean(I_,1));
        dx = fftshift(ifft2(fft2(T_).*conj(fft2(I_))));
        theM = dx.*mask;
 
        [yy,xx] = find(theM == max(theM(:)));
        
        if size(yy,1) > 1                       % Laila
            yy = round(mean(yy));
        end
        
        if size(xx,1) > 1                       % Laila
            xx = round(mean(xx));
        end
 
        dpx(ii) = (xx-thecen(1));
        dpy(ii) = (yy-thecen(2));
    end
end