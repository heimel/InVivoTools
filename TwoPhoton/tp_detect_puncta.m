function roilist = tp_detect_puncta( record, unmixing )
%TP_DETECT_PUNCTA
%
% 2011, Alexander Heimel
%

roilist =tp_emptyroirec;
roilist = roilist([]);


image_processing.unmixing = unmixing;
image_processing.spatial_filter = false; % needs to be off

disp('TP_DETECT_PUNCTA: SHOULD STILL ONLY TAKE STATISTICS FOR SELECTED REGION');
params = tpreadconfig(record);
channel = 1;
im = double( tpreadframe(record,channel,1:params.NumberOfFrames,image_processing) );

edge = 2; % to avoid filtering artefacts from median filter
if ndims(im)>2 % i.e stack
    im_cropped =  im(1+edge:end-edge, 1+edge:end-edge, 1+edge:end-edge);
else % single image
    im_cropped =  im(1+edge:end-edge, 1+edge:end-edge);
end
mode_im = mode( round(im_cropped(:)) );

im_neg = im_cropped( im_cropped<mode_im);
im_neg = im_neg - mode_im;

std_background = sqrt( im_neg'*im_neg / length(im_neg));
if isnan(std_background) || std_background <=1
    disp('TP_DETECT_PUNCTA: manually setting std_background!');
    answer = inputdlg('Cannot compute STD of background. Please enter:',...
        'TP_DETECT_PUNCTA: Enter background STD',1,{'10'});
    std_background = str2double(answer);

end
disp(['TP_DETECT_PUNCTA: std_background = ' num2str(std_background) ]);

threshold =  2 * std_background;


% smoothen
image_processing.spatial_filter = true;
im = double( tpreadframe(record,channel,1:params.NumberOfFrames,image_processing) );

% temp
%edge = 2; % to avoid filtering artefacts from median filter
%if ndims(im)>2 % i.e stack
%    im_cropped =  im(1+edge:end-edge, 1+edge:end-edge, 1+edge:end-edge);
%else % single image
%    im_cropped =  im(1+edge:end-edge, 1+edge:end-edge);
%end
%mode_im = mode( round(im_cropped(:)) );
%pmet

im = im -mode_im; % subtract mode, otherwise zero padding really distorts borders when filtering
imsmooth = tp_spatial_filter( double(im), 'smoothen','0.5');
imsmooth(imsmooth<threshold) = threshold;

disp('TP_DETECT_PUNCTA: finding local maxima')
im_maxima = imregionalmax( imsmooth);
maxima=find(im_maxima==1);

disp(['TP_DETECT_PUNCTA: detected ' num2str(length(maxima)) ' puncta']);

%disp('TP_DETECT_PUNCTA: calculating connected regions')
%cc = bwconncomp(imsmooth>threshold);

% sort to do largest first
[temp,ind] = sort(imsmooth(maxima),1,'descend'); %#ok<ASGLU>
maxima = maxima(ind);


debug = false;
if debug
    figure %#ok<UNRCH>
end

hbar = waitbar(0,'Drawing puncta' );


size_org = size(imsmooth);
count = 1;
for i = 1:length(maxima)
    [yi,xi,zi] = ind2sub(size(im_maxima),maxima(i));
    
   [ind_area_checked,xi,yi,ind_area_blank] = find_peak_area( imsmooth(:,:,zi), sub2ind([size(imsmooth,1) size(imsmooth,2)],yi,xi));
    
    % remove peak from image
    imsmooth = reshape(imsmooth,size(imsmooth,1)*size(imsmooth,2),size(imsmooth,3));
    imsmooth(ind_area_blank,max(1,zi-5):min(zi+5,end)) = nan; %threshold;
    imsmooth = reshape(imsmooth,size_org);
    
    if length(ind_area_checked)>=10  % i.e. not too close to the edge, and not too small
        roi = tp_emptyroirec;
        roi.pixelinds = ind_area_checked;
        roi.xi = xi;
        roi.yi = yi;
        roi.zi = zi;
        imf = im(:,:,zi);
        roi.intensity_mean = nanmean(imf(ind_area_checked));
        roi.intensity_max = nanmax(imf(ind_area_checked));
        roilist(count) = roi; %#ok<AGROW>
        count = count+1;
    end
    
    if debug
        hold off %#ok<UNRCH>
        imagesc(imsmooth(:,:,zi).^0.3); colormap gray
        hold on
        plot(xi,yi,'y');
        r = input('Enter 0 to stop');
        if r==0
            keyboard
        end
    end
    
        waitbar(i/length(maxima),hbar);

end
close(hbar);
disp(['TP_DETECT_PUNCTA: returning ' num2str(length(roilist)) ' puncta.']);

return

function [ind_area_checked,xi,yi,ind_area_blank] = find_peak_area( im, ind)
% ind_area_blank = [];
% [ind_area_checked,xi,yi] = find_peak_area_by_descent( im, ind);
[ind_area_checked,xi,yi,ind_area_blank] = find_peak_area_by_fitting_gaussian( im, ind);

return

function [ind_area_checked,xi,yi,ind_area_blank] = find_peak_area_by_fitting_gaussian( im, ind)
% fit area by fitting the largest gaussian that fits below the surface

debug = false;


ind_area_blank = [];
ind_area_checked = [];
xi = [];
yi = [];

if isnan(im(ind))
    % too close to larger punctum
    return;
end

[row,col] = ind2sub(size(im),ind);
if debug
    disp(['row = ' num2str(row) ', col = ' num2str(col)]); %#ok<UNRCH>
end

edge = 10;

if row<=edge || row>=(size(im,1)-edge) || col<=edge || col>=(size(im,2)-edge)
    % too close to edge
    return
end

imcrop = im(row-edge:row+edge,col-edge:col+edge) ;
imcrop = imcrop -mode(imcrop(:)); % subtract baseline?


if debug
    h_debug= figure(23); subplot(1,3,1) %#ok<UNRCH>
    imagesc(imcrop); colormap gray
end

% first get area by gradient descent
ind_area_checked = find_peak_area_by_descent( imcrop, sub2ind(size(imcrop),edge+1,edge+1));
imm = zeros(size(imcrop));
imm(ind_area_checked) = imcrop(ind_area_checked);
imcrop = imm;


if debug
    subplot(1,3,2) %#ok<UNRCH>
    imagesc(imcrop); colormap gray
end


goodfit = false;
attempt = 0;
tol = 0.001;
[X,Y] = meshgrid(1:(2*edge+1),1:(2*edge+1));
while ~goodfit && attempt < 4
    [cx,cy,sx,sy,cxy,amp] = Gaussian2D(imcrop,tol);
    xm=(X-cx);
    ym=(Y-cy);
    detc=(sx*sy)^2-cxy^2;
    if detc~=0
        
        ztmp = (exp(-0.5/detc*(sy^2*xm.^2 - 2*cxy*xm.*ym + sx^2*ym.^2 ))) ;
    else
        ztmp = double(xm==0&ym==0);
    end
        ztmp =ztmp*amp;
    if sqrt( (cx -(edge+1))^2 +  (cy -(edge+1))^2 )>3 % too far off center
        imcrop = thresholdlinear(imcrop - ztmp);
    else
        goodfit = true;
    end
    attempt = attempt + 1;
end

if ~goodfit
    disp('');
    disp('TP_DETECT_PUNCTA: Failed to get good Gaussian fit. ');
end

 

if detc~=0 % no width
    phi = linspace(0,2*pi,10);
    r = 2 * sqrt(detc ./ (sy^2*cos(phi).^2 - 2*cxy * sin(phi).*cos(phi) + sx^2*sin(phi).^2));
    xi = cx  + r.*cos(phi);
    yi = cy  + r.*sin(phi);
    [rows,cols] = find(1/detc*(sy^2*xm.^2 - 2*cxy*xm.*ym + sx^2*ym.^2 )<=2);
    [rows_blank,cols_blank] = find(1/detc*(sy^2*xm.^2 - 2*cxy*xm.*ym + sx^2*ym.^2 )<=3);
else
    % ignore single pixel maxima
    xi = [];
    yi = [];
    return
end

if debug
    figure(h_debug); %#ok<UNRCH>
    subplot(1,3,3)
    imagesc(ztmp); colormap gray
    hold on
    plot(xi,yi,'y');
    hold off

    disp(['Attempt=' num2str(attempt) ', amp = ' num2str(amp) ...
        ', x = ' num2str( cx+col -(edge+1)) ...
        ', y = ' num2str( cy+row -(edge+1))]);
    pause
end

xi = xi+col -(edge+1);
yi = yi +row - (edge+1);

rows = rows + row - (edge+1);
cols = cols + col - (edge+1);
ind_area_checked = sub2ind( size(im), rows, cols);
rows_blank = rows_blank + row - (edge+1);
cols_blank = cols_blank + col - (edge+1);
ind_area_blank = sub2ind( size(im), rows_blank, cols_blank);

if isempty(xi)
    keyboard
end


return



function [ind_area_checked,xi,yi] = find_peak_area_by_descent( im, ind)
% extend area by including all sequentially including all lower neighbors
%

val_start = im(ind(1));
val_min = 0.4*val_start;

ind_area_checked = [];
while ~isempty(ind)
    val = im(ind(1));
    [r,c] = ind2sub(size(im),ind(1));
    if r>1
        if im(r-1,c) < val && im(r-1,c) > val_min
            new_ind = sub2ind(size(im),r-1,c);
            if ~ismember(new_ind,ind_area_checked) && ~ismember(new_ind,ind)
                ind = [ind new_ind];
            end
        end
    end
    if r<size(im,1)
        if im(r+1,c) < val && im(r+1,c) > val_min
            new_ind = sub2ind(size(im),r+1,c);
            if ~ismember(new_ind,ind_area_checked)&& ~ismember(new_ind,ind)
                ind = [ind new_ind];
            end
        end
    end
    if c>1
        if im(r,c-1) < val && im(r,c-1) > val_min
            new_ind = sub2ind(size(im),r,c-1);
            if ~ismember(new_ind,ind_area_checked)&& ~ismember(new_ind,ind)
                ind = [ind new_ind];
            end
        end
    end
    if c<size(im,2)
        if im(r,c+1) < val && im(r,c+1) > val_min
            new_ind = sub2ind(size(im),r,c+1);
            if ~ismember(new_ind,ind_area_checked)&& ~ismember(new_ind,ind)
                ind = [ind new_ind];
            end
        end
    end
    
    ind_area_checked = [ind_area_checked ind(1)];
    ind = ind(2:end);
end

ind_area_checked = sort(ind_area_checked);
d=diff(ind_area_checked);
indbound=find(d>1);
ind_circum = [ind_area_checked(1) ind_area_checked(indbound+1) ind_area_checked(indbound(end:-1:1)) ind_area_checked(1)];

im(ind_area_checked)=max(im(:));
im(ind_circum)=-max(im(:));

[yi,xi]=ind2sub([size(im,1) size(im,2)],ind_circum);

%if mod(yi,2)==1 % i.e. odd
%    nyi = [yi(1:ceil(end/2)) yi(end:-1:ceil(end/2)+1)];
%    nxi = [xi(1:ceil(end/2)) xi(end:-1:ceil(end/2)+1)];
%else
%    nyi = [yi(1:ceil(end/2)) yi(end:-1:ceil(end/2)+1)];
%    nxi = [xi(1:ceil(end/2)) xi(end:-1:ceil(end/2)+1)];
%end
%nxi = [nxi nxi(1)];
%nyi = [nyi nyi(1)];

%figure;
%hold on
%imagesc(im);
%plot(nxi,nyi)



return



