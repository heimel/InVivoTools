function [b,t] = getbins(rc)

  % returns bins and mti's selected in parameters->datatoview

p = getparameters(rc); I = getinputs(rc); c = getoutput(rc);

b = {}; t = {};
if p.datatoview(2)==0,loop=1:length(I.stimtime);else,loop=p.datatoview(2);end;
for i=loop,
  b = cat(1,b,{c.reverse_corr.bins{i}});
  t = cat(1,t,I.stimtime(i).mti);
end;
