function vector_image=plotimagevector(data,stimlist,blank_stim,colortab_0,colortabgain,maskinds,maskcoltab_0,...
maskcoltab_1)

% PLOTWTA - Plots winner-take-all plot of intrinsic imaging data
%
%   DATA_CMPLX=PLOTWTA(DATA, STIMLIST, BLANK_STIM, COLORTAB_0,
%    MASKINDS,MASKCOLTAB_0, MASKCOLTAB_1)
%
%  Plots vector plot of intrinsic imaging data using color map
%  entries COLORTAB_0..COLORTAB_0+length(STIMLIST) for each stimulus and
%  and allowing all points in MASKINDS to 'show through'.  MASKCOLTAB_0 through
%  MASKCOLTAB_1 are used to draw the pixels showing through.  DATA is an
%  XxYxNUMSTIM matrix of imaging data.  DATA_CMPLX is an XxY matrix with the
%  vector average response.
%
%  Example: h=plotimagevector(avg_data,2:8,1,256,0,256);

vec_img = double(data(:,:,stimlist));
angles = -pi:(2*pi)/length(stimlist):pi-2*pi/length(stimlist);
for i=1:length(stimlist),
	vec_img(:,:,i)=vec_img(:,:,i).*...
			repmat(exp(sqrt(-1)*angles(i)),size(vec_img,1),size(vec_img,2));
end;

vector_image = mean(vec_img,3);
%max(max((angle(vector_image)+pi)/(2*pi))),
vecimg = (colortabgain)*length(stimlist)*(angle(vector_image)+pi)/(2*pi)+colortab_0+1;
%max(max(angle(vector_image))),min(min(angle(vector_image))),

img0= double(data(:,:,blank_stim));
img0= img0-min(min(img0));
img0= (maskcoltab_1-maskcoltab_0)*img0/max(max(img0))+maskcoltab_0;

min(min(vecimg)),max(max(vecimg)),
vecimg(find(maskinds)) = img0(find(maskinds));
image(vecimg'); axis equal off;
min(min(img0)),max(max(img0)),
