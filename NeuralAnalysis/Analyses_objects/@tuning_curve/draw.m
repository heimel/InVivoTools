function draw(tc)

%  Part of the NeuralAnalysis package
%
%  DRAW(TUNING_CURVEOBJ)
%
%  Draws the output to the location in the TUNING_CURVE object TUNING_CURVEOBJ.
%
%  See also:  ANALYSIS_GENERIC/DRAW

c = getoutput(tc);
if isempty(c.curve)
    logmsg('No computed curve.');
    return
end

w = location(tc); 
p = getparameters(tc); 
I = getinputs(tc);

if ~isempty(w)
    z = getgraphicshandles(tc);
    if ~isempty(z) % delete objects
        for i=1:length(z)
            if strcmp(get(z(i),'type'),'axes')
                disp('found the axes');
                ud2 = get(z(i),'userdata');
                delete(ud2{1}); 
                delete(ud2{2});
            end
            delete(z(i));
        end
    end
    %ud = get(w.figure,'userdata');
    figure(w.figure);
    rct3 = [];
    rct2 = [];
    if p.drawspont && ~isempty(tc.internals.spont) && p.showrast
        rct = grect2local([0.1300 0.1100 0.3270 0.3439],w.units,w.rect,w.figure);
        rct3 = grect2local([0.5780 0.1100 0.3270 0.3439],w.units,w.rect,w.figure);
        rct2 = grect2local([0.1300 0.5 0.7750 0.39],w.units,w.rect,w.figure);
    elseif p.drawspont && ~isempty(tc.internals.spont)
        rct = grect2local([0.1300 0.5811 0.7750 0.3439],w.units,w.rect,w.figure);
        rct3 = grect2local([0.1300 0.1100 0.7750 0.3439],w.units,w.rect,w.figure);
    elseif p.showrast
        rct = grect2local([0.1300 0.1100 0.7750 0.39],w.units,w.rect,w.figure);
        rct2 = grect2local([0.1300 0.5 0.7750 0.39],w.units,w.rect,w.figure);
    else
        rct = grect2local([0.1300 0.1100 0.7750 0.8150],w.units,w.rect,w.figure);
    end
    r = axes('units',w.units,'position',rct,'tag','analysis_generic',...
        'uicontextmenu',contextmenu(tc));
    h = errorbar(c.curve(1,:),c.curve(2,:),c.curve(3,:),'r');
    for jj = 1:length(h)
        set(h(jj),'linewidth',1);
    end
    hold on;
    h = errorbar(c.curve(1,:),c.curve(2,:),c.curve(4,:),'linewidth',2);
    for jj=1:length(h)
        set(h(jj),'linewidth',2);
    end
    if ~isempty(c.spont)
        ll = ones(size(c.curve(1,:)));
        hold on;
        plot(c.curve(1,:),c.spont(1)*ll,'--','color',0*[1 1 1]);
        % plot STD
        plot(c.curve(1,:),c.spont(1)*ll+c.spont(2)*ll,'--','color',0.7*[1 1 1]);
        plot(c.curve(1,:),c.spont(1)*ll-c.spont(2)*ll,'--','color',0.7*[1 1 1]);
    end
    title(I.title,'Interpreter','none');
    set(gca,'tag','analysis_generic','uicontextmenu',contextmenu(tc));
    if ~isempty(rct2)
        rastwhere.figure = w.figure;
        rastwhere.units = w.units;
        rastwhere.rect = rct2;
        tc.internals.rast = setlocation(tc.internals.rast,rastwhere);
    end
    if ~isempty(rct3)
        spontwhere.figure = w.figure;
        spontwhere.units = w.units;
        spontwhere.rect = rct3;
        tc.internals.spont = setlocation(tc.internals.spont,spontwhere);
    end
    set(r,'userdata',{ tc.internals.rast tc.internals.spont});
end
