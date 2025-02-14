function draw(rc)

%  Part of the NeuralAnalysis package
%
%  DRAW(REVERSE_CORROBJ)
%
%  Draws the output to the location in the REVERSE_CORR object REVERSE_CORROBJ.
%
%  See also:  ANALYSIS_GENERIC/DRAW
%

w = location(rc);
if ~isempty(w)
    % for now, delete everything and start over
    z = getgraphicshandles(rc);
    for i=1:length(z)
        delete(z(i));
    end
    figure(w.figure);
    
    p = getparameters(rc);
   % in = rc.internal;
    I = getinputs(rc);
    
    [r1,r2,r3,r4] = getdrawrects(rc);
    
    [rc_avg,xsteps,ysteps,cubeaxes,cubesurf1,cubesurf2,cubesurf3,...
        line1,line2]=drawcube(rc,r1);
    drawnow
    a = axes('units',w.units,'position',r3,'tag','analysis_generic',...
        'uicontextmenu',contextmenu(rc),'userdata','revaxes');
 %  xx = repmat(xsteps,length(ysteps),1); 
   %yy=repmat(ysteps,length(xsteps),1);
   % zz = zeros(length(xsteps),length(ysteps));
    
    IM = surf(repmat(xsteps,length(ysteps),1)',repmat(ysteps,length(xsteps),1),...
        zeros(length(xsteps),length(ysteps)),rc_avg');
    set(gca,'ydir','reverse','uicontextmenu',contextmenu(rc),...
        'tag','analysis_generic','userdata','revaxes');
    
    axis equal;
    axis([p.pseudoscreen(1) p.pseudoscreen(3) ...
        p.pseudoscreen(2) p.pseudoscreen(4)]);
    offsets = p.interval(1):p.timeres:p.interval(2);
    if length(offsets)==1
        offsets= [p.interval(1) p.interval(2)]; 
    end
    title([I.cellnames{p.datatoview(1)} ...
        ' over [' num2str(offsets(p.datatoview(2))) 's, ' ...
        num2str(offsets(p.datatoview(2)+1)) 's]'],'Interpreter','none');
    
    drawselectedbin(rc,a);
    drawcrc(rc,r4);
    % drawrast(rc);  % these all check to see if they should draw themselves
    % drawshowdata(rc);
    % draw1drev(rc);
    
    switch p.clickbehav
        case 0
            zoom off;
            set(IM,'ButtonDownFcn',bds);
            set(cubesurf1,'ButtonDownFcn',bds); set(cubesurf2,'ButtonDownFcn',bds);
            set(cubesurf3,'ButtonDownFcn',bds);
            set(line1,'ButtonDownFcn',bds); set(line2,'ButtonDownFcn',bds);
        case 1
            zoom on;
            set(IM,'ButtonDownFcn',bds);
            set(cubesurf1,'ButtonDownFcn',bds); set(cubesurf2,'ButtonDownFcn',bds);
            set(cubesurf3,'ButtonDownFcn',bds);
            set(line1,'ButtonDownFcn',bds); set(line2,'ButtonDownFcn',bds);
        case 2
            zoom on;
    end
end

function str = bds
str = ['uuuuuud.pos=get(gca,''position'');uuuuuud.units=get(gca,''units'');'...
    'uuuuuud.ud=get(gcf,''userdata'');uuuuuud.f=0;uuuuuud.i=0;' ...
    'for uuuuuudi=1:length(uuuuuud.ud),' ...
    'if isinwhere(uuuuuud.pos,uuuuuud.units,location(uuuuuud.ud{uuuuuudi})),' ...
    'uuuuuud.f=uuuuuudi;break;end;' ...
    'end;'...
    'if uuuuuud.f>0,'...
    'uuuuuud.ud{uuuuuud.f}=buttondwnfcn(uuuuuud.ud{uuuuuud.f});'...
    'set(gcf,''userdata'',uuuuuud.ud);'...
    'end; '...
    'clear uuuuuud;'];
