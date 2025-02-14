function [r1,r2,r3,r4]=getdrawrects(pc)

  p = getparameters(pc); w = location(pc); fr = w.figure;

  if p.graphParams(1).draw+p.graphParams(2).draw+p.graphParams(3).draw+...
        p.graphParams(4).draw>1,
     % then we need four plot areas
    % set up drawing areas
    r1=grect2local([0.1300 0.5811 0.3270 0.3439],w.units,w.rect,fr);
    r2=grect2local([0.5780 0.5811 0.3270 0.3439],w.units,w.rect,fr);
    r3=grect2local([0.1300 0.1100 0.3270 0.3439],w.units,w.rect,fr);
    r4=grect2local([0.5780 0.1100 0.3270 0.3439],w.units,w.rect,fr);
  else,
    for i=1:4,
      if p.graphParams(i).draw,
        eval(['r' int2str(i) '=grect2local([0.1300 0.1100 0.7750 0.8150],w.units,w.rect,fr);']);
      else, eval(['r' int2str(i) '=[-1 -1 -1 -1];']);
      end;
    end;
  end;
