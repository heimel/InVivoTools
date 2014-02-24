function  ParseObj(Obj, TV)


if ~isempty(Obj.Groups)
   
   for i = 1:length(Obj.Groups)
       
        %name = strrep(regexp(Obj.Groups(i).Name, '[^/]+$', 'match'), '-', '_');  
        name = regexp(Obj.Groups(i).Name, '[^/]+$', 'match');
        TV.addBranch(name);
        if ~isempty(Obj.Groups(i).Datasets)
            dsets = {};
            Datasets = Obj.Groups(i).Datasets;
            for j = 1:length(Datasets)
                dsets(j) =  regexp(Datasets(j).Name, '[^/]+$', 'match');
            end

            TV.addLeaves(dsets);
        end

        ParseObj(Obj.Groups(i), TV);
        TV.Up();
        
   end
end