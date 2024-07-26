function ind = typefind(autoextractlist,type)
 % returns -1 if not there, or the index of the nameref pair
ind = -1;
for i=1:length(autoextractlist),
        if strcmp(autoextractlist(i).type,type)
                ind=i; i=length(autoextractlist)+1;
        end;
end;
