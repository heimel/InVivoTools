function d = newtestdir(cksds)

%  D = NEWTESTDIR(DIRSTRUCT_OBJ)
%
%  Returns in D the name of a suitable new test directory.

p = getpathname(cksds);

i=1;

while(exist([p 't' sprintf('%.5d',i)])==7), i=i+1; end;

d=['t' sprintf('%.5d',i)];
