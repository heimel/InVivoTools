function d = newtestdir(cksds)

%  Part of the NelsonLabTools package
%
%  D = NEWTESTDIR(CKSDIRSTRUCT_OBJ)
%
%  Returns in D the name of a suitable new test directory.

p = getpathname(cksds);

i=1;

if ~isempty(findstr(lower(p),'antigua'))
        d = 't-1';
        while exist([p 't-' sprintf('%d',i)],'dir')
            d=['t-' sprintf('%d',i)];
            i=i+1; 
        end
        if exist(fullfile(p,d,'stims.mat'),'file')
            d=['t-' sprintf('%d',i)];
        end
else
    while(exist([p 't' sprintf('%.5d',i)])==7), i=i+1; end;
        d=['t' sprintf('%.5d',i)];
end

