function [rc_avg_2,xsteps,ysteps,ax,s1,s2,s3,yel1,yel2] = drawcube(rc, drawrect)

w  = location(rc);
ax = axes('units',w.units,'Position',drawrect);

% gets colormap, draws cube
p = getparameters(rc);
I = getinputs(rc);
c = getoutput(rc);

rc_avg = p.gain*(c.reverse_corr.rc_avg(p.datatoview(1),:,:,:,:)-p.feamean)+...
    p.immean;

if p.normalize==0,
    ind_saturated=find(rc_avg>255);
    if ~isempty(ind_saturated)
        disp('Reverse correlation image saturated. Reduce image gain.');
        rc_avg(ind_saturated) = 255;
    end
    ind_saturated=find(rc_avg<0);
    if ~isempty(ind_saturated)
        disp('Reverse correlation image falls below zero. Reduce image gain.');
        rc_avg(ind_saturated) = 0;
    end
    rc_avg_t = mean(rc_avg(1,:,:,:,:),2);
    rc_avg_x = mean(rc_avg(1,:,:,:,:),4);
    rc_avg_y = mean(rc_avg(1,:,:,:,:),3);
    rc_avg_s = (rc_avg(1,p.datatoview(2),:,:,:));
    xx = size(rc_avg_t,4); yy = size(rc_avg_t,3); tt = size(rc_avg_x,2);
    p2 = getparameters(I.stimtime(1).stim); rect = p2.rect;
    tsteps2 = p.interval(1):p.timeres:p.interval(2);
    tint=[tsteps2(1) tsteps2(end)];
    %     if length(tsteps2)==1
    %         tsteps2= [p.interval(1) p.interval(2)];
    %     end;
    rc_reshape = reshape(fix(rc_avg_s),xx*yy,3);
    sz_ = size(rc_reshape,1);
    rctreshape = reshape(fix(rc_avg_t),xx*yy,3);
    szt = size(rctreshape,1);
    rcxreshape = reshape(fix(rc_avg_x),yy*tt,3);
    szx = size(rcxreshape,1);
    rcyreshape = reshape(fix(rc_avg_y),xx*tt,3);
    [ctab,dum,inds]=unique([rc_reshape;rctreshape;rcxreshape;rcyreshape;],'rows'); %#ok<ASGLU>
    colormap(ctab/255);
    rc_avg_2    = reshape(inds(1:sz_),yy,xx);
    rc_avg_t2 = reshape(inds(sz_+1:szt+sz_),yy,xx);
    rc_avg_x2 = reshape(inds(sz_+szt+1:szt+szx+sz_),tt,yy);
    rc_avg_y2 = reshape(inds(sz_+szt+1+szx:end),tt,xx);
    xsteps = rect(1):((rect(3)-rect(1))/(xx)):rect(3);
    ysteps = rect(2):((rect(4)-rect(2))/(yy)):rect(4);
    tsteps = tint(1):((tint(2)-tint(1))/(tt)):tint(2);
    Xtsteps = repmat(xsteps,length(ysteps),1)';
    Ytsteps = repmat(tint(2),length(ysteps),length(xsteps))';
    Ztsteps = repmat(ysteps,length(xsteps),1);
    hold off;
    s1 = surf(Xtsteps,Ytsteps,Ztsteps,rc_avg_t2');
    hold on;
    Xysteps = repmat(xsteps,length(tsteps),1);
    Yysteps = repmat(tsteps',1,length(xsteps));
    Zysteps = repmat(rect(4),length(tsteps),length(xsteps));
    s2=surf(Xysteps,Yysteps,Zysteps,rc_avg_y2);
    Xxsteps = repmat(rect(1),length(tsteps),length(ysteps));
    Yxsteps = repmat(tsteps',1,length(ysteps));
    Zxsteps = repmat(ysteps,length(tsteps),1);
    s3=surf(Xxsteps,Yxsteps,Zxsteps,rc_avg_x2);
    set(gca,'zdir','reverse');
    yel1=plot3([rect(3) rect(1) rect(1) rect(3) rect(3)],...
        tsteps(p.datatoview(2))*[1 1 1 1 1],...
        [rect(4) rect(4) rect(2) rect(2) rect(4)],'y','linewidth',2);
    yel2=plot3([rect(3) rect(1) rect(1) rect(3) rect(3)],...
        tsteps(p.datatoview(2)+1)*[1 1 1 1 1],...
        [rect(4) rect(4) rect(2) rect(2) rect(4)],'y','linewidth',2);
    % now we're deleting everything and starting over so we don't need to save
    % these
    set(gca,'DataAspectRatio',[1 1.5/10000 1],'View',[30.5000   18.0000]);
    set(gca,'tag','analysis_generic','uicontextmenu',contextmenu(rc),...
        'userdata','cubeaxes');  % use cubeaxes reference later
    ylabel('Time (s)');
    a = axis;
    %     a(2) = rect(3);
    a(6) = rect(4);
    %     a(3) = p.interval(1);
    %     a(4) = p.interval(2);
    axis(a);
elseif p.normalize==1, % normalize by difference from mean assuming two choices
    p2 = getparameters(I.stimtime(1).stim);
    rect = p2.rect;
    %    z1 = norm(p2.values(1,:));
    %    z2 = norm(p2.values(2,:)); % pick brighter stim
    %     if z1>=z2
    %         z=0;
    %     else
    %         z=1;
    %     end
    meanvec = mean(p2.values);
    %    step = (p2.values(z+1,:)-meanvec)/sum(c.reverse_corr.norms);
    z = zeros(size(rc_avg));
    %    z2=z;
    z(:,:,:,:,1) = meanvec(1);
    %    z2(:,:,:,:,1) = step(1);
    z(:,:,:,:,2) = meanvec(2);
    %    z2(:,:,:,:,2) = step(2);
    z(:,:,:,:,3) = meanvec(3);
    %    z2(:,:,:,:,3) = step(3);
    rc_avg = (c.reverse_corr.rc_avg(p.datatoview(1),:,:,:,:)-z(p.datatoview(1),:,:,:,:));
    %    sig = sum(c.reverse_corr.norms)/length(c.reverse_corr.norms);
    %     p_rc_avg = 1/(sqrt(2*pi)*sig)*exp(-(rc_avg(:,:,:,:,1).^2)/(2*sig^2));
    rc_avg(rc_avg>255) = 255;
    rc_avg(rc_avg<0) = 0;
    rc_avg_t = mean(rc_avg(1,:,:,:,:),2);
    rc_avg_x = mean(rc_avg(1,:,:,:,:),4);
    rc_avg_y = mean(rc_avg(1,:,:,:,:),3);
    rc_avg_s = (rc_avg(1,p.datatoview(2),:,:,:));
    xx = size(rc_avg_t,4);
    yy = size(rc_avg_t,3); tt = size(rc_avg_x,2);
    tsteps2 = p.interval(1):p.timeres:p.interval(2);
    tint = [tsteps2(1) tsteps2(end)];
    %     if length(tsteps2)==1
    %         tsteps2= [p.interval(1) p.interval(2)];
    %     end
    rc_reshape = reshape(fix(rc_avg_s),xx*yy,3);
    sz_ = size(rc_reshape,1);
    rctreshape = reshape(fix(rc_avg_t),xx*yy,3);
    szt = size(rctreshape,1);
    rcxreshape = reshape(fix(rc_avg_x),yy*tt,3);
    szx = size(rcxreshape,1);
    rcyreshape = reshape(fix(rc_avg_y),xx*tt,3);
    [ctab,dum,inds] = unique([rc_reshape;rctreshape;rcxreshape;rcyreshape;],'rows'); %#ok<ASGLU>
    colormap(ctab/255);
    rc_avg_2    = reshape(inds(1:sz_),yy,xx);
    rc_avg_t2 = reshape(inds(sz_+1:szt+sz_),yy,xx);
    rc_avg_x2 = reshape(inds(sz_+szt+1:szt+szx+sz_),tt,yy);
    rc_avg_y2 = reshape(inds(sz_+szt+1+szx:end),tt,xx);
    xsteps = rect(1):((rect(3)-rect(1))/(xx)):rect(3);
    ysteps = rect(2):((rect(4)-rect(2))/(yy)):rect(4);
    tsteps = tint(1):((tint(2)-tint(1))/(tt)):tint(2);
    Xtsteps = repmat(xsteps,length(ysteps),1)';
    Ytsteps = repmat(tint(2),length(ysteps),length(xsteps))';
    Ztsteps = repmat(ysteps,length(xsteps),1);
    hold off
    s1 = surf(Xtsteps,Ytsteps,Ztsteps,rc_avg_t2'); %set(gca,'zdir','reverse');
    hold on
    Xysteps = repmat(xsteps,length(tsteps),1);
    Yysteps = repmat(tsteps',1,length(xsteps));
    Zysteps = repmat(rect(4),length(tsteps),length(xsteps));
    s2 = surf(Xysteps,Yysteps,Zysteps,rc_avg_y2);
    Xxsteps = repmat(rect(1),length(tsteps),length(ysteps));
    Yxsteps = repmat(tsteps',1,length(ysteps));
    Zxsteps = repmat(ysteps,length(tsteps),1);
    s3=surf(Xxsteps,Yxsteps,Zxsteps,rc_avg_x2);
    set(gca,'zdir','reverse');
    yel1=plot3([rect(3) rect(1) rect(1) rect(3) rect(3)],...
        tsteps(p.datatoview(2))*[1 1 1 1 1],...
        [rect(4) rect(4) rect(2) rect(2) rect(4)],'y','linewidth',2);
    yel2=plot3([rect(3) rect(1) rect(1) rect(3) rect(3)],...
        tsteps(p.datatoview(2)+1)*[1 1 1 1 1],...
        [rect(4) rect(4) rect(2) rect(2) rect(4)],'y','linewidth',2);
    % now we're deleting everything and starting over so we don't need to save
    % these
    set(gca,'DataAspectRatio',[1 1.5/10000 1],'View',[30.5000   18.0000]);
    set(gca,'tag','analysis_generic','uicontextmenu',contextmenu(rc),...
        'userdata','cubeaxes');  % use cubeaxes reference later
    ylabel('Time (s)');
    a = axis;
    a(6) = rect(4);
    axis(a);
    
end  % normalize
