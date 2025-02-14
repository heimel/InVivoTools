function nrc = buttondwnfcn(rc)
%BUTTONDWNFCN

ax = gca;
ud = get(ax,'userdata');
if ischar(ud)
    pt = get(gca,'CurrentPoint');
    p = getparameters(rc);
    switch ud,
        case 'cubeaxes'
            offsets = p.interval(1):p.timeres:p.interval(2);
            if length(offsets)==1
                offsets= [p.interval(1) p.interval(2)]; 
            end
            ind = find(pt(2,2)>=offsets(1:end-1)&pt(2,2)<offsets(2:end));
            if ~isempty(ind)&&(p.datatoview(2)~=ind),
                p = getparameters(rc);
                p.datatoview(2) = ind;
                rc = setparameters(rc,p);
            end;
        case 'revaxes'
            %disp('nothing to do...event handled.');
    end;
end;
nrc = rc;
if 1
    % get current stim
    I = getinputs(rc);
    st = I.stimtime(1).stim;   % currently assume only 1 stimulus
    p2 = getparameters(st); rect = p2.rect; pixSize = p2.pixSize;
    if (pt(1,1)>=rect(1)&&pt(1,1)<=rect(3))&&(pt(1,2)>=rect(2)&&pt(1,2)<=rect(4)),
        % compute grid
        
        width  = rect(3) - rect(1); height = rect(4) - rect(2);
        if (pixSize(1)>=1)
            X = pixSize(1);
        else
            X = (width*pixSize(1));
        end
        if (pixSize(2)>=1)
            Y = pixSize(2);
        else
            Y = (height*pixSize(2));
        end
        %i = 1:width; x = fix((i-1)/X)+1; i = 1:height; y = fix((i-1)/Y)+1;
        x = fix((pt(1,1)-rect(1))/X); y = fix((pt(1,2)-rect(2))/Y);
        bin=1+x*fix((height/Y))+y;
        in=rc.internal;
        in.selectedbin=bin;
        p.crcpixel = bin;
        rc.internal=in;
        %drawselectedbin(rc);
        %drawshowdata(rc);
        %drawrast(rc);
        %draw1drev(rc);
        rc = setparameters(rc,p);
    end;% do nothing if point not in grid
    nrc = rc;
end
