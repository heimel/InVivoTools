function configuremenu(mdd)

%  Part of the NeuralAnalysis package
%
%  CONFIGUREMENU(MDD)
%
%  Configures the menu options (such as setting checks and enabling/disabling
%  menu options) based on the current parameters and inputs.
%
%  See also:  MEASUREDDATADISPLAY, SETPARAMETERS

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

cm = contextmenu(mdd);
if ishandle(cm),
  try,
        p = getparameters(mdd);
        xa = findobj(cm,'label','x axis');
        xaa= findobj(xa,'label','auto');
        if ischar(p.xaxis)&strcmp(p.xaxis,'auto'),
            set(xaa,'checked','on');
        else, set(xaa,'checked','off');
        end;
        ya = findobj(cm,'label','y axis');
        yaa= findobj(ya,'label','auto');
        if ischar(p.yaxis)&strcmp(p.yaxis,'auto'),
            set(yaa,'checked','on');
        else, set(yaa,'checked','off');
        end;
        begoftrace=findobj(cm,'label','beginning of trace');
        try, cs=get(begoftrace,'children'); delete(cs); end;
	endoftrace=findobj(cm,'label','end of trace');
        try, cs=get(endoftrace,'children'); delete(cs); end;
	begtraceint=findobj(cm,'label','beginning of trace interval');
        try, cs=get(begtraceint,'children'); delete(cs); end;
	endtraceint=findobj(cm,'label','end of trace interval');
        try, cs=get(endtraceint,'children'); delete(cs); end;
	begnextint=findobj(cm,'label','beginning of next trace interval');
        try, cs=get(begnextint,'children'); delete(cs); end;
	endprevint=findobj(cm,'label','end of prev trace interval');
        try, cs=get(endprevint,'children'); delete(cs); end;
	begprevint=findobj(cm,'label','beginning of prev trace interval');
        try, cs=get(begprevint,'children'); delete(cs); end;

        dp = findobj(cm,'label','display params');
        dpc = get(dp,'children');
        try, delete(dpc); end;

        for i=1:length(p.displayParams),
           blah=uimenu(begoftrace,'label',['trace ' int2str(i)],'userdata',i,...
                 'callback',cb);
           blah=uimenu(endoftrace,'label',['trace ' int2str(i)],'userdata',i,...
                 'callback',cb);
           blah=uimenu(begtraceint,'label',['trace ' int2str(i)],...
                 'userdata',i,'callback',cb);
           blah=uimenu(endtraceint,'label',['trace ' int2str(i)],...
                 'userdata',i,'callback',cb);
           blah=uimenu(begnextint,'label',['trace ' int2str(i)],'userdata',i,...
                 'callback',cb);
           blah=uimenu(endprevint,'label',['trace ' int2str(i)],'userdata',i,...
                 'callback',cb);
           blah=uimenu(begprevint,'label',['trace ' int2str(i)],'userdata',i,...
                 'callback',cb);
           dpm = uimenu(dp,'label',['trace ' int2str(i)]);
           dpsm = uimenu(dpm,'label','separation method');
             m0=uimenu(dpsm,'label','fraction of max-min','userdata',i,...
                                        'callback',cb,'checked','off');
             m1=uimenu(dpsm,'label','fraction of standard deviation',...
                                        'userdata',i,'callback',cb,...
                                        'checked','off');
             m2=uimenu(dpsm,'label','constant offset','userdata',i,...
                                        'callback',cb,'checked','off');
             eval(['set(m' int2str(p.displayParams(i).sepmeth) ...
                   ',''checked'',''on'');']);
           dpsd = uimenu(dpm,'label','set separation distance','userdata',i,...
                                        'callback',cb);
           dpl  = uimenu(dpm,'label','line');
             dpll = uimenu(dpl,'label','draw line','callback',cb,'userdata',i);
             if p.displayParams(i).line, set(dpll,'checked','on');
             else, set(dpll,'checked','off'); end;
             dpls = uimenu(dpl,'label','set line size','callback',cb,...
                                'userdata',i);
           dpsm = uimenu(dpm,'label','symbols');
             dpsym = uimenu(dpsm,'label','set symbol','callback',cb,...
                                'userdata',i);
             dpmark= uimenu(dpsm,'label','set marker size','callback',cb,...
                                'userdata',i);
           dpsc = uimenu(dpm,'label','set scaling','userdata',i,'callback',cb);
           dpcol= uimenu(dpm,'label','set color','userdata',i,'callback',cb);
           dpdr = uimenu(dpm,'label','draw','userdata',i','callback',cb);
           if p.displayParams(i).draw, set(dpdr,'checked','on');
           else, set(dpdr,'checked','off'); end;
        end;
  end;
end;

