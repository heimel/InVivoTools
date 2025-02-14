function st=getstim(rc);

p = getparameters(rc); I = getinputs(rc);

l = p.datatoview(1);
if l==0,l=1; end;

st = I.stimtime(1).stim;
