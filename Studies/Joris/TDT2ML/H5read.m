function [EVENT, DATA] = H5read
%[EVENT, DATA] = H5read 
%USAGE: opens HDF5 files, browses contents and 
%returns selected datasets
%
%Chris van der Togt, 08/06/2006
%javaaddpath('C:\javasrc\ttv\dist\ttv.jar') %set in classpath.txt


import ttv.*
EVENT = [];
DATA = [];

[FileName,PathName] = uigetfile('.h5');
if isa(FileName, 'char') && isa(PathName, 'char')
    f = fullfile(PathName, FileName);
    S = hdf5info(f,'ReadAttributes', false);

    T = tankview;
    T.initmodel(strtok(FileName, '.'))
    ParseObj(S.GroupHierarchy, T)
    T.setmodel()
    T.setSize(200,400)
    T.setVisible(true)
    

    
    if ~isempty(S.GroupHierarchy.Datasets) && strcmp(S.GroupHierarchy.Datasets.Name, '/Dataset') 
       STRSET = hdf5read(f, char('/Dataset'));
       DESC =  eventparser(STRSET);
       
        h =  msgbox( DESC.Description );
        set(h, 'Name', ['Tank description: ' FileName] )
       
%        disp(['Dataset code : ' STRSET.Data{1}.Data ])
%        if isa(STRSET.Data{2}, 'hdf5.h5string')
%            disp(['Dataset description: ' STRSET.Data{2}.Data ])
%        else
%            disp('Dataset description: ')
%            LEN = length(STRSET.Data{2}.MemberNames);
%            for j = 1:LEN
%                disp(STRSET.Data{2}.Data{j}.Data)
%            end
%        end
     end
                    
    EVENT = struct;
    DATA = struct;

        dataset = T.getDataset();
        T.setVisible(false);
        if ~isempty(dataset)
           for i = 1:length(dataset)

                OBJ = hdf5read(f, char(dataset(i)));
                a = regexp(char(dataset(i)), '[^/]+', 'match'); 
                if strcmp('EVENT', a(2))
                    if  isempty(fieldnames(EVENT))
                        EVENT = eventparser(OBJ);
                        %disp('EVENT retrieved');
                    else
                        disp('EVENT structure allready retrieved');
                    end

                elseif isa(OBJ, 'hdf5.h5array') && ~isfield(DATA, a(2))
                    DATA.(a{2}) = OBJ.Data;
                    %disp([a{2} ' retrieved']);

                elseif isa(OBJ, 'hdf5.h5compound') && ( ~isfield(DATA, a(2)) ...
                                                 || ~isfield(DATA.(a{2}), {['C' a{3}]} )  ) 
                    DATA.(a{2}).(['C' a{3}]) = eventparser(OBJ);
                    %disp([a{2} '/' a{3} ' retrieved']);

                else  
                    disp([ a{2:end} ' dataset allready retrieved']);
                end

           end
        end
end



       
       
