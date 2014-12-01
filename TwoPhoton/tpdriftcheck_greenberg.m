function [p, iter_used, corr, failed, settings, xpixelposition, ypixelposition] = motioncorrect_greenberg(data,base_image,subrec,settings,est_p)
%MOTIONCORRECT
%Correct motion artifacts in raster scanned imaging
%
%Format:
%[p, iter_used, corr, failed, settings, xpixelposition, ypixelposition] = ...
%motioncorrect(data,base_image,subrec,settings,est_p)
%
%Inputs:
%data -- 3D array of double precision, h x w x n. n is the number of image
%frames. It is assumed that raster scanning has proceed along each row of
%data, and that there are h scan lines.
%
%base_image -- an image to which the data will be aligned. it need not be
%the same size as each image in data. in theory this should be an image
%without motion distortion
%
%subrec -- the rectangular region of base_image to which the raster scan
%was targeted. subrec is a vector of form [left right bottom top], and its
%values are pixel coordinates in base_image. if subrec is omitted or empty,
%it will be assumed that the entire base_image was targeted in the raster
%scanning
%
%settings -- a structure whos fields contain parameters for motion
%correction. Either all the following subfields should be set, or the whole
%settings structure should be omitted or empty, in which case default
%values will be used. The subfields and their default values are:
%   *move_thresh (0.075) -- the converence threshold for changes in
%   estimated displacements in pixels
%   *corr_thresh (0.75) -- the minimum pearson's correlation value for a
%   successful converence 
%   *max_iter (120) -- the maximum number of allowed Lucas-Kanade iterations
%   *scanlinesperparameter (2) -- the number of scanlines between displacement
%   stimations, and probably the most important parameter. Higher values
%   allow noiser data to be used, while lower values allow faster
%   displacement to be corrected.
%   *pregauss (0.75) -- the width in pixels of the gaussian filter applied to data
%   before displacement estimation
%   *haltcorr (0.95) -- the correlation value for which no further
%   improvement will be attempted, even if the convergence criteria are not
%   met
%   *dampcorr (0.8) -- the correlation value above which the amplitude of
%   the parameter updates will be slowly reduced, in order to prevent
%   oscillations near a local minimum
%
%est_p -- estimated displacements to be used as seed values for gradient
%descent. est_p should have n rows and number of columns
%2 + 2 * floor(h / settings.scanlinesperparameter)
%est_p can be omitted or left empty. Whether or not est_p is given,
%displacements of zero will also be attempted as seed values.
%
%Outputs:
%p -- estimated displacement. Each row of p corresponds to one of the n
%images. For each image, the displaced position of the focus will be estimated
%1 + floor(h / settings.scanlinesperparameter) times per frame. the first
%half of each row contains these x displacement values, and the second half
%contains y displacement values. the units of the values are pixels of
%base_image
%
%iter_used -- the number of Lucas Kanade iterations used for each image
%
%corr -- the final pearson's correlation value between each image and
%base_image after convergence
%
%failed -- a vector containing 1's for images with failed convergence, 0's otherwise
%
%setttings -- the settings that were used for motion correction. This will
%contain the input settings and some additional fields. It can be used as
%an input to another call of motioncorrect.
%
%xpixelposition, ypixelposition -- the estimated positions of each pixel in
%data after motion correction. Its values are pixel coordinates in base_image.
%Same dimensions as data.
%--------------------------------------------------------------------------
%INFO
%For further details, see "Automated correction of fast motion artifacts for two-photon
%imaging of awake animals," D.S. Greenberg & J.N.D. Kerr, Journal of
%Neuroscience Methods, 2009.
%http://dx.doi.org/10.1016/j.jneumeth.2008.08.020
%
%Written and released by David S. Greenberg, Tuebingen, Germany, March 2009.
%
%By usings this code you agree not to distribute it to anyone else, modify
%it and then distribute it, or publish the code............... brother.
%
%For general inquiries contact david@tuebingen.mpg.de or jason@tuebingen.mpg.de
%This code is not supported, feel free to submit questions, problems, or
%bug reports but a timely response may not be possible.
%
%As we are a curious bunch, please let us know if you modify it in a useful
%way, for richer or poorer etc etc
%David says: that he retains all commercial rights etc 
%Jason says: he looks forward to seeing what it winds up being used for, if
%you send us your email we will send you updates and future modifications.........
%
% copyright David Greenberg, david.greenberg@caesar.de
%
%==========================================================================

sD = size(data); sD(end+1:3) = 1; nlines = sD(1); linewidth = sD(2); nframes = sD(3);
irows = size(base_image,1); icols = size(base_image,2);
if ~exist('subrec','var') || isempty(subrec)
    subrec = [1 icols 1 irows]; %by default, assume the template is the same size and location as the image frames
end
if ~exist('settings','var')
    settings = [];
end
settings = init_settings(settings, nlines, linewidth, subrec);
max_iter = settings.max_iter; move_thresh = settings.move_thresh; corr_thresh = settings.corr_thresh; dampcorr = settings.dampcorr; haltcorr = settings.haltcorr; scanlinesperparameter = settings.scanlinesperparameter; nblocks = settings.nblocks; reltime = settings.reltime; blockt = settings.blockt; pregauss = settings.pregauss; basex = settings.basex; basey = settings.basey; blockind = settings.blockind; blockind2 = blockind + settings.nblocks + 1;

data = prefilter_data(data, pregauss, sD);

if ~exist('est_p','var') || isempty(est_p)
    est_given = 0;
    est_p = [];
else
    est_given = 1;
end

min_blockpoints_ratio = 0.5;
pointsperblock = scanlinesperparameter * size(data,2);
minpointsperblock = pointsperblock * min_blockpoints_ratio;

%calculate gradients
xgrad = diff(base_image,1,2);    ygrad = diff(base_image,1,1);
xgrad = (xgrad(:,1:end-1) + xgrad(:,2:end)) / 2; xgrad = [nan + zeros(irows,1) xgrad nan + zeros(irows,1)];
ygrad = (ygrad(1:end-1,:) + ygrad(2:end,:)) / 2; ygrad = [nan + zeros(1,icols); ygrad; nan + zeros(1,icols)];

failed = zeros(nframes,1);
corr = zeros(nframes,1);
iter_used = zeros(nframes,1);
p = zeros(nframes,nblocks * 2 + 2);

frac = reltime / blockt;
comp = 1 - frac;

for j = 1:nframes    
    disp(['Working on frame ' num2str(j) ' of ' num2str(nframes)])
    T = reshape(data(:,:,j),[],1);
    %compile a list of choices for the intial warp parameters
    init_p = zeros(1, nblocks * 2 + 2); %no displacement
    if est_given %user-input estimated displacement for this frame
        init_p = [init_p; est_p(j,:)];
    end
    if j > 1 && ~failed(j-1) %displacement at the end of the previosu frame
        init_p = [init_p; est_fromlast];
    end
    %now test each initial parameter estimate
    initcorr = -1 + zeros(size(init_p,1),1);
    for k = 1:size(init_p,1)
        testp = init_p(k,:);
        x = basex + p(blockind) .* comp + testp(blockind + 1) .* frac;
        y = basey + p(blockind2) .* comp + testp(blockind2 + 1) .* frac;
        mask2 = (x >= 2) & (x < icols - 1) & (y >= 2) & (y < irows - 1);

        x_int = floor(x);
        y_int = floor(y);
        matind = y_int + irows * (x_int - 1);
        x_frac = x - x_int;
        y_frac = y - y_int;
        matind(~mask2) = 1; %use bogus values for points that are masked out (not used) so we don't need an indexing operation
        %now compute the image value at the warped coordinates from the surrounding 4 pixels' values, using a 4-way weighted average
        wI = (1 - x_frac) .* ((1 - y_frac) .* base_image(matind) + ...
            y_frac .* base_image(matind + 1)) + ...
            x_frac .* ((1 - y_frac) .* base_image( matind + irows) + ...
            y_frac .* base_image(matind + irows + 1));
        if any(mask2)
            pixperblock = histc(blockind(mask2),1:nblocks);
            if any(pixperblock >= minpointsperblock)
                initcorr(k) = quickcorr(wI(mask2),T(mask2));
            end
        end
    end
    %rank the initial parameter estimates in in descending order of correlation
    [garb,sortind] = sort(initcorr);
    sortind = flipud(sortind);
    init_p = init_p(sortind,:);    
    for k = 1:size(init_p,1) %use the inital parameter estimates to start gradient descent until we exceed corr_thresh
        [p(j,:),corr(j),iter_used(j),mask] = align_frame_to_template(...
            T,base_image,init_p(k,:)',xgrad,ygrad,frac,blockind, basex, basey, minpointsperblock, max_iter, move_thresh, corr_thresh, dampcorr, haltcorr, nblocks);
        if corr(j) >= corr_thresh
            break;
        end        
    end
    if corr(j) >= corr_thresh %alignment successful
        blocksused = unique(blockind(mask));
        %zero unused parameters
        p(j,1:min(blocksused) - 1) = 0;
        p(j,(1:min(blocksused) - 1) + nblocks + 1) = 0;
        p(j,max(blocksused) + 1:nblocks + 1) = 0;
        p(j,(max(blocksused) + 1:nblocks + 1) + nblocks + 1) = 0;
        est_fromlast = [repmat(p(nblocks + 1),1,nblocks + 1) repmat(p(end),1, nblocks + 1)];
    else %alignment failed
        failed(j) = 1;
        p(j,:) = nan;        
    end
end

if nargout > 5
    blockind2 = blockind + nblocks + 1;
    xpixelposition = nan + zeros(size(data)); ypixelposition = xpixelposition;
    for j = find(~failed)'
        nextp = p(j,:);
        xpixelposition(:,:,j) = basex + nextp(blockind) .* comp + nextp(blockind + 1) .* frac;
        ypixelposition(:,:,j) = basey + nextp(blockind2) .* comp + nextp(blockind2 + 1) .* frac;
    end
end

function [p,corr,iter,mask] = align_frame_to_template(T,I,est_p,xgrad,ygrad,frac,blockind,basex, basey, minpointsperblock, max_iter, move_thresh, corr_thresh, dampcorr, haltcorr, nblocks)
framew = size(basex,2); frameh = size(basex,1);
blocksize = ceil(numel(basex) / nblocks); %number of pixels per block, possibly not including last block
%reorder matrices so that each column corresponds to one linear segment of the interpolated trajectories
blockind = blockorder(blockind, blocksize, framew, frameh);
blockind(~blockind) = 1; %this allows us to use blockind as an index without indexing blockind itself, to increase speed. the resulting bogus values will be masked out later
basex = blockorder(basex, blocksize, framew, frameh);
basey = blockorder(basey, blocksize, framew, frameh);

frac = blockorder(frac, blocksize, framew, frameh);
T = blockorder(T, blocksize, framew, frameh);

p = est_p;
best_p = [];
delta_p = zeros(size(p));
best_corr = -1;
iter = 0; best_iter = 0;

ratefac = 1;
nparampoints = nblocks + 1;
nparams = 2 * nparampoints;
H = spalloc(nparams, nparams, 4 * (nparampoints + nparampoints - 1 + nparampoints - 1));

diagindx = 1:(nparams+1):nparams * nparampoints - nparampoints;
offdiagindLx = diagindx(1:end-1) + 1;
offdiagindUx = diagindx(1:end-1) + nparams;

%store indices into the pseudo-Hessian matrix corresponding to different groups of parameters
Dshift = nparampoints;
Rshift = nparams * nparampoints;

diagindy = diagindx + Dshift + Rshift;
offdiagindLy = offdiagindLx + Dshift + Rshift;
offdiagindUy = offdiagindUx + Dshift + Rshift;

diagindxyL = diagindx + Dshift;
offdiagindLxyL = offdiagindLx + Dshift;
offdiagindUxyL = offdiagindUx + Dshift;

diagindxyU = diagindx + Rshift;
offdiagindLxyU = offdiagindLx + Rshift;
offdiagindUxyU = offdiagindUx + Rshift;

H(diagindx) = 0; H(diagindy) = 0; H(offdiagindLx) = 0; H(offdiagindLy) = 0;
H(diagindxyL) = 0; H(offdiagindLxyL) = 0; H(offdiagindLxyU) = 0;
H(diagindxyU) = 0; H(offdiagindUxyL) = 0; H(offdiagindUxyU) = 0;

comp = 1 - frac;
fracsq = frac.^2;
compsq = comp.^2;
fcprod = comp .* frac;

templatew =size(I,2); templateh = size(I,1);

blocks_present = false(nparampoints,1);
blocked = 1:max(max(blockind));
best_mask = false(size(basex));
best_wI = zeros(size(blockind));
blockind2 = blockind + nparampoints;

while (iter <= max_iter)
    iter = iter + 1;
    p = p + delta_p;

    x = basex + p(blockind) .* comp + p(blockind + 1) .* frac;
    y = basey + p(blockind2) .* comp + p(blockind2 + 1) .* frac;
    mask = (x >= 2) & (x < templatew - 1) & (y >= 2) & (y < templateh - 1);
    mask_comp = ~mask;
    
    x_int = floor(x);
    y_int = floor(y);
    matind = y_int + templateh * (x_int - 1);
    x_frac = x - x_int;
    y_frac = y - y_int;
    x_frac_comp = 1 - x_frac;
    y_frac_comp = 1 - y_frac;    
    matind(mask_comp) = 1; %use bogus values for points that are masked out (not used) so we don't need an indexing operation
    %precalculate indices to be used for warping
    matindp1 = matind + 1;
    matindpth = matind + templateh;
    matindpthp1 = matindpth + 1;
    %now compute the image value at the warped coordinates from the surrounding 4 pixels' values, using a 4-way weighted average
    wI = x_frac_comp .* ((y_frac_comp) .* I(matind) + ...
        y_frac .* I(matindp1)) + ...
        x_frac .* ((y_frac_comp) .* I(matindpth) + ...
        y_frac .* I(matindpthp1));
    %do the corresponding thing for the gradients
    wxgrad = x_frac_comp .* ((y_frac_comp) .* xgrad(matind) + ...
        y_frac .* xgrad(matindp1)) + ...
        x_frac .* ((y_frac_comp) .* xgrad(matindpth) + ...
        y_frac .* xgrad(matindpthp1));
    wygrad = x_frac_comp .* ((y_frac_comp) .* ygrad(matind) + ...
        y_frac .* ygrad(matindp1)) + ...
        x_frac .* ((y_frac_comp) .* ygrad(matindpth) + ...
        y_frac .* ygrad(matindpthp1));
    %set these to zero now so we don't have to index later    
    wxgrad(mask_comp) = 0;
    wygrad(mask_comp) = 0;
    
    if ~any(mask)
        blocks_present(:) = 0;
    else
        pixperblock = histc(blockind(mask),blocked);
        blocks_present = pixperblock >= minpointsperblock;
        mask(pixperblock(blockind) < minpointsperblock) = 0;
    end
    if ~any(blocks_present)
        break;
    end
    param_points_used = [blocks_present(1); blocks_present(1:end-1) | blocks_present(2:end); blocks_present(end)];
    params_used = [param_points_used; param_points_used];
    
    cval = quickcorr(wI(mask),T(mask));
    difference_image = T - wI; %calculate difference image by subtracting template from warped frame
    difference_image(mask_comp) = 0;
    
    if (cval > best_corr)
        best_iter = iter;
        best_corr = cval;
        best_p = p;
        best_mask = mask;
        best_wI = wI;
        ratefac = 1;
        if cval > haltcorr
            break;
        end
    elseif cval > dampcorr
        ratefac = 1 / (iter - best_iter);
    end
    %precalcuations:
    wxgradsq = wxgrad.^2;
    wygradsq = wygrad.^2;
    wxygrad = wxgrad .* wygrad;    
    %Calculate the pseudo-Hessian matrix:
    %x-x diagonal
    H(diagindx) = [sum(wxgradsq .* compsq) 0] + [0 sum(wxgradsq .* fracsq)];
    %x-x off-diagonal
    offdiag = sum(wxgradsq .* fcprod);
    H(offdiagindLx) = offdiag;
    H(offdiagindUx) = offdiag;
    %y-y diagonal
    H(diagindy) = [sum(wygradsq .* compsq) 0] + [0 sum(wygradsq .* fracsq)];
    %y-y off-diagonal
    offdiag = sum(wygradsq .* fcprod);
    H(offdiagindLy) = offdiag;
    H(offdiagindUy) = offdiag;    
    %x-y diagonal
    diagon = [sum(wxygrad .* compsq) 0] + [0 sum(wxygrad .* fracsq)];
    H(diagindxyL) = diagon;
    H(diagindxyU) = diagon;
    %x-y off-diagonal    
    offdiag = sum(wxygrad .* fcprod);
    H(offdiagindLxyL) = offdiag;
    H(offdiagindUxyL) = offdiag;
    H(offdiagindLxyU) = offdiag;
    H(offdiagindUxyU) = offdiag;    
    %calculate the vector v which will be multiplied by the inverse pseudo-hessian to yield the new delta_p
    v = [[sum(wxgrad .* comp .* difference_image) 0] + [0 sum(wxgrad .* frac .* difference_image)] ...
        [sum(wygrad .* comp .* difference_image) 0] + [0 sum(wygrad .* frac .* difference_image)]]';
    %invert H and multiply by v, ignoring unused parameters
    delta_p(:) = 0;
    delta_p(params_used) = ratefac * inv(H(params_used,params_used)) * v(params_used);
    %check whether convergence criteria have been met
    if all(abs(delta_p) < move_thresh) && best_corr >= corr_thresh
        break;
    end
end
if isempty(best_p)
    corr = nan;
    p(:) = nan;
else
    corr = best_corr;
    p = best_p; 
    iter = best_iter;
    %reconvert the mask to the original indexing format:
    maskconvmat = zeros(size(best_wI));
    maskconvmat(best_mask) = 1;    
    invbomat = invblockorder(maskconvmat, framew, frameh);
    mask = find(invbomat);    
end

function y = blockorder(x, blocksize, w, h)
x = reshape(x,h,w);
y = zeros(blocksize, ceil(w * h / blocksize));
y(1:w*h) = x';

function y = invblockorder(x, w, h)
y = reshape(x(1:w*h),w,h)';

function q = quickcorr(a,b)
n = size(a,1);
a = a - sum(a) / n;
b = b - sum(b) / n;
assq = a' * a;
bssq = b' * b;
q = a' * b;
q = q / sqrt(assq * bssq);

function data = prefilter_data(data, pregauss, sD)
%prefilter data
L = ceil(sqrt((2*pregauss^2) * log(10000 / (sqrt(2*pi)*pregauss)))); %.0001 > 1/(sqrt(2*pi)*pregauss * exp(L^2/(2*pregauss^2)))
sbig = sD(1:2) + L;
[x,y]=meshgrid(1:sbig(2),1:sbig(1));
g2d = exp( - (min(x - 1, sbig(2) + 1 - x).^2 + min(y - 1, sbig(1) + 1 - y).^2) / (2 * pregauss^2) );
g2d = g2d / sum(sum(g2d));
g2d = fft2(g2d,sbig(1),sbig(2));
for k = 1:size(data,3)
    u = real(ifft2(fft2(data(:,:,k),sbig(1),sbig(2)) .* g2d));
    data(:,:,k) = u(1:sD(1),1:sD(2));
end

function settings = init_settings(settings, nlines, linewidth, subrec)
if isempty(settings)
    settings = struct('move_thresh',0.075,'corr_thresh',0.75,'max_iter',120,'scanlinesperparameter',2,'pregauss',0.75,'haltcorr',0.95,'dampcorr',0.8);
end
%initialize settings structure
settings.nblocks = max(floor(nlines / settings.scanlinesperparameter),1);
settings.blockt = settings.scanlinesperparameter / nlines;
settings.lastblockt = 1 - settings.blockt * (settings.nblocks - 1);
settings.blocke = 1 : settings.scanlinesperparameter : nlines + 1;
settings.blocke(end) = nlines + 1;
[garb,settings.blockind] = histc(repmat((1:nlines)', 1, linewidth),settings.blocke);
settings.reltime = (repmat(1:linewidth,nlines,1) + repmat(linewidth * (0:nlines - 1)',1,linewidth) - 0.5) / (linewidth * nlines);
settings.reltime = settings.reltime - (settings.blockind - 1) * settings.blockt;

settings.basex = subrec(1) + (0:(linewidth-1)) * (subrec(2) - subrec(1)) / (linewidth - 1);
settings.basex = repmat(settings.basex,nlines,1);
settings.basey = subrec(3) + (0:(nlines-1))' * (subrec(4) - subrec(3)) / (nlines - 1);
settings.basey = repmat(settings.basey,1,linewidth);
