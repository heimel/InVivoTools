function ind = namerefind(nameref_str,name,ref)
 % returns -1 if not there, or the index of the nameref pair
ind = -1;
for i=1:length(nameref_str),
        if strcmp(nameref_str(i).name,name)&nameref_str(i).ref==ref,
                ind=i; i=length(nameref_str)+1;
        end;
end;
