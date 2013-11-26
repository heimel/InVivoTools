function plot_oi_frames( frames )
%PLOT_OI_FRAMES plot first and last and difference of frames
%
%  H = PLOT_OI_FRAMES( FRAMES )
%     Plot first and last and difference of frames, as
%     IMAGESC(FRAMES(:,:,1)') and IMAGESC(FRAMES(:,:,END)')
%
%     H is figure handle    
%
%  April 2003, Alexander Heimel, heimel@brandeis.edu


h=figure;
subplot(3,1,1)
imagesc(frames(:,:,1)')
title('First frame')
axis equal off
axis off
subplot(3,1,2)
imagesc(frames(:,:,end)')
title('Last frame')
axis equal off
axis off
subplot(3,1,3)
imagesc(transpose(frames(:,:,1)-frames(:,:,end)))
title('Difference between first and last')
axis equal off
axis off

