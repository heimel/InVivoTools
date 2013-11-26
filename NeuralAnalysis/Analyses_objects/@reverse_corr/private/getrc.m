function rc_im = getrc(rc)

p = getparameters(rc);

rc_im = rc.computations.reverse_corr.rc_avg(p.datatoview(1),...
                                            p.datatoview(2),:,:,:);
%rc_im = reshape(rc_im,size(rc_im,3),size(rc_im,4),3);
rc_im = reshape(rc_im,size(rc_im,3),size(rc_im,4),3);
