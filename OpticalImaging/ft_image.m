function data=ft_image(frames,freq,framerate,show)
%FT_IMAGE calculates particular fourier component of sequence of images
%
%   DATA=FT_IMAGE(FRAMES)
%
%   DATA=FT_IMAGE(FRAMES,FREQ,FRAMERATE,SHOW)
%
%     Used mainly in KS_ANALYSIS (Kalatsky Stryker analysis of imaging data)
%
% April 2003, Alexander Heimel (heimel@brandeis.edu)
%
if nargin<4
    show=1;
end
if nargin<3
  framerate = 300/10 ; % frames per second
end

if nargin<2
  freq=[];
end
if isempty(freq)
  disp('No frequency given.');
  data=[];
  return
end
  

n_frames=size(frames,3);
n_time=n_frames/framerate;

global data % for debugging

xsize=size(frames,1);
ysize=size(frames,2);
frames=reshape(frames,xsize*ysize,size(frames,3));
fourvec=exp(2*pi*i*linspace(1/framerate,n_time,n_frames)*freq);
data=frames(:,:)*fourvec';  % notice the complex conjugate!
data=reshape(data,xsize,ysize);

if show
    plot_ks_data(data);
end
