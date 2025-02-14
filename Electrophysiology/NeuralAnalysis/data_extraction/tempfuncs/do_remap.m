
dn = '/home/data/2002-01-22/';
n  = 'tet1';
r  =  2;

cksds=cksdirstruct(dn);
t = gettests(cksds,n,r);

for j=1:length(t),
  cd([dn t{j}]);
  remap_blank_2x2half
  cd ..;
  t{j},
end;
