function [r1,r2,r3,r4]=getdrawrects(rc)

  p=getparameters(rc);
  w = location(rc);

  % set up drawing areas
  fr = w.figure;
  r1=grect2local([0.1300 0.5811 0.3270 0.3439],w.units,w.rect,fr);
  r2=grect2local([0.5780 0.5811 0.3270 0.3439],w.units,w.rect,fr);
  r3=grect2local([0.1300 0.1100 0.3270 0.3439],w.units,w.rect,fr);
  r4=grect2local([0.5780 0.1100 0.3270 0.3439],w.units,w.rect,fr);
  if ~(p.showrast|p.show1drev),
     if ~p.showdata,
        r3=grect2local([0.1300 0.1100 0.7750 0.8150],w.units,w.rect,fr);
     else,
        r3=grect2local([0.1300 0.1100 0.3270 0.8150],w.units,w.rect,fr);
        r4=grect2local([0.5780 0.1100 0.3270 0.8150],w.units,w.rect,fr);
     end;
  end;

