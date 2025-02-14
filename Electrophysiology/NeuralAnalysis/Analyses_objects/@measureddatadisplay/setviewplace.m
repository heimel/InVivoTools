function nmdd = setviewplace(mdd, where, whichtrace)

%  NEWMDD = SETVIEWPLACE(MDD, WHERE [, WHICHTRACE])
%
%  Sets the viewplace for the MEASUREDDATADISPLAY object MDD to WHERE, and
%  returns the changes in NEWMDD.
%
%  WHERE is a string, and can be one of:
%
%  'beginning'
%  'end'
%  'half frame forward'
%  'full frame forward'
%  'half frame backward'
%  'full frame backward'
%  'beginning of trace' *
%  'end of trace' *
%  'beginning of trace interval' *
%  'end of trace interval' *
%  'beginning of next trace interval' *
%  'end of prev trace interval' *
%  'beginning of prev trace interval' *
%
%  When it is required (*), WHICHTRACE should be the number of the trace to
%  which the WHERE command applies.

p = getparameters(mdd); I=getinputs(mdd);
if ischar(p.xaxis)&strcmp(p.xaxis,'auto'),xaxis=p.xauto;else,xaxis=p.xaxis; end;
xmin = xaxis(1);
switch(where),
  case 'beginning',
    gmin = [];
    for i=1:length(p.displayParams),
      ints=get_intervals(I.measureddata{i});g=min(min(ints));gmin=min([gmin g]);
    end;
    p.xaxis = gmin+[0 diff(xaxis)];
  case 'end',
    gmax = [];
    for i=1:length(p.displayParams),
      ints=get_intervals(I.measureddata{i});g=max(max(ints));gmax=max([gmax g]);
    end;
    p.xaxis = gmax-[diff(xaxis) 0];
  case 'half frame forward', p.xaxis = xaxis + 1/2*diff(xaxis);
  case 'full frame forward', p.xaxis = xaxis + diff(xaxis);
  case 'half frame backward', p.xaxis = xaxis - 1/2*diff(xaxis);
  case 'full frame backward', p.xaxis = xaxis - diff(xaxis);
  case 'beginning of trace',
    ints = get_intervals(I.measureddata{whichtrace});
    g = min(min(ints));
    p.xaxis = g+[0 diff(xaxis)];
  case 'end of trace',
    ints = get_intervals(I.measureddata{whichtrace});
    g = max(max(ints));
    p.xaxis = g-[diff(xaxis) 0];
  case 'beginning of trace interval',
    ints = get_intervals(I.measureddata{whichtrace}); j=-1;
    for i=1:size(ints,1),if xmin>=ints(i,1)&xmin<=ints(i,2),j=i;break;end;end;
    if j~=-1, p.xaxis = ints(j,1)+[0 diff(xaxis)];
    elseif xmin<ints(i,1), %p.xaxis = ints(1,1)+[0 diff(xaxis)]; not in trace
    elseif xmin>ints(end,2),end;% p.xaxis = ints(end,1)+[0 diff(xaxis)]; end;
  case 'end of trace interval',
    ints = get_intervals(I.measureddata{whichtrace}); j=-1;
    for i=1:size(ints,1),if xmin>=ints(i,1)&xmin<=ints(i,2),j=i;break;end;end;
    if j~=-1, p.xaxis = ints(j,2)-[diff(xaxis) 0];
    elseif xmin<ints(i,1), %p.xaxis = ints(1,2)-[diff(xaxis) 0];
    elseif xmin>ints(end,2),end;% p.xaxis = ints(end,2)-[diff(xaxis) 0]; end;
  case 'beginning of next trace interval',
    ints = get_intervals(I.measureddata{whichtrace}); j=-1;
    for i=1:size(ints,1),if xmin>=ints(i,1)&xmin<=ints(i,2),j=i;break;end;end;
    if j~=-1,
       if j+1<=size(ints,1), p.xaxis = ints(j+1,1)+[0 diff(xaxis)]; end;
    elseif xmin<ints(i,1), %p.xaxis = ints(1,1)+[0 diff(xaxis)];
    end; % otherwise do nothing
  case 'end of prev trace interval',
    ints = get_intervals(I.measureddata{whichtrace}); j=-1;
    for i=1:size(ints,1),if xmin>=ints(i,1)&xmin<=ints(i,2),j=i;break;end;end;
    if j~=-1, if j==1, % do nothing 
              else, p.xaxis = ints(j-1,2)-[diff(xaxis) 0]; end;
    elseif xmin<ints(i,1), % do nothing
    elseif xmin>ints(end,2), p.xaxis = ints(end,2)-[diff(xaxis) 0]; end;
  case 'beginning of prev trace interval',
    disp('here');
    ints = get_intervals(I.measureddata{whichtrace}); j=-1;
    for i=1:size(ints,1),if xmin>=ints(i,1)&xmin<=ints(i,2),j=i;break;end;end;
    if j~=-1, if j==1, disp('do nithing'); % do nothing 
              else, p.xaxis = ints(j-1,1)+[0 diff(xaxis)]; end;
    elseif xmin<ints(i,1), % do nothing
    elseif xmin>ints(end,2), p.xaxis = ints(end,1)+[0 diff(xaxis)]; end;
end;

%  'beginning of trace interval' *
%  'end of trace interval' *
%  'beginning of next interval of trace' *
%  'end of prev interval of trace' *
%  'beginning of prev interval of trace' *


nmdd=setparameters(mdd,p);
