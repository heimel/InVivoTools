function Out = eventparser( In)  
%Out = eventparser( In)
%recursive function to parse EVENT structure from HDF5 file
%In : dataset containing EVENT data
%Out : structure element added to EVENT structure

    for i = 1:length(In.MemberNames)
        mfield1 = In.MemberNames{i};
        if isvarname(mfield1)
            if isa(In.Data{i}, 'hdf5.h5string')
                Out.(mfield1) = In.Data{i}.Data;
            elseif isa(In.Data{i}, 'hdf5.h5array')
                Out.(mfield1) = In.Data{i}.Data;
            elseif isa(In.Data{i}, 'hdf5.h5compound')
                Out.(mfield1) = eventparser(In.Data{i});   
            else          
                Out.(mfield1) = In.Data{i}; 
            end
        else
        Out(i) = {In.Data{i}.Data };
        end
    end
