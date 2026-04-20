function [data,txt] = yamlread(txt,join)
%Convert YAML text to data (uses SnakeYAML).
% data = yamlread(txt)      -yaml string or location of yaml file
% data = yamlread(txt,join)   -join cells where possible (default:0)
%
%See also: yamlsetup, yamlwrite
%
% Version 1.14
% Downloaded from https://github.com/serg3y/yaml-matlab/tree/main


%setup
if ~any(contains(javaclasspath('-all'),'snakeyaml'))
    yamlsetup
end

%defaults
if nargin<2 || isempty(join), join = true; end

%read yaml text from file (optional)
if isfile(txt)
    txt = fileread(txt);
end

%parse yaml text
J = org.yaml.snakeyaml.Yaml().load(txt); %load as java class
data = java2matlab(J,join,0); %convert to MatLab (recursive)

function [data,maxdepth] = java2matlab(J,join,depth)
%Convert Java class to MatLab struct
%-When JoinCells=true nested cells are joined to form an array with
% any number of dimension. During recursive call through the nested cells
% 'depth' is used to track recursion depth and hence dimension number,
% 'maxdepth' tracks total number of dimensions. Before exiting from
% depth==1 permute is used to swap dimension order.
maxdepth = depth; %init
switch class(J)
    case 'java.util.ArrayList' %java list
        if J.size == 0
            data = {}; %convert to empty cell
        else
            data = J.toArray.cell'; %convert to vector of cells
            if join
                types = {'double' 'logical' 'java.util.ArrayList' 'java.util.LinkedHashMap'}; %data types that can be joined
                ValidType = ismember(class(data{1}),types); %is first element of a type that can be joined?
                SameType = all(cellfun(@(x)isequal(class(x),class(data{1})),data)); %are all elements of the same type?
                SameSize = all(cellfun(@(x)isequal(size(x),size(data{1})),data)); %are all elements of the same length?
                depth = (depth+1) * (ValidType && SameType && SameSize); %reset depth if joining is not possible, else elements will be joined
            end
            for k = 1:numel(data)
                [data{k},maxdepth] = java2matlab(data{k},join,depth); %receptively convert each element
            end
            if join && ValidType && SameType && SameSize
                try %cell contents may have changed after recursive joining, field names may not match
                    data = cat(depth,data{:}); %join
                end
                if depth==1
                    if maxdepth==1
                        ord = [2 1];
                    else
                        ord = max(maxdepth,2):-1:1;
                        ord = ord([2 1 3:end]);
                    end
                    data = permute(data,ord);
                end
            end
        end
    case 'java.util.LinkedHashMap'
        val = J.values.toArray; %values
        if isempty(val)
            data = struct();
        else
            par = J.keySet.toArray.string; %slow but handles edge cases such as 'a: 1\n2: 2'
            % par = cell(1,J.size); t = J.keySet.iterator; for k = 1:J.size, par{k} = t.next.string; end %fast but fails on edge cases
            %the alternative is slower: par = cellstr(char(J.keySet.toArray)); %medium but fails on some edge cases
            par = matlab.lang.makeValidName(par); %ensure field names are valid, replace bad characters with _, prefix x to leading numbers
            par = matlab.lang.makeUniqueStrings(par); %ensure parameters are unique, append _1 _2 if needed
            for k = 1:numel(par)
                data.(par{k}) = java2matlab(val(k),join,0); %assign and also convert contents
            end
        end
    case 'java.util.Date'
        data = datetime(J.getTime/1000,'ConvertFrom','posixtime','TimeZone','UTC');
        data.Format = 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''; %display format only, note java rounds milliseconds
    case {'char' 'double' 'logical'}
        data = J; %do nothing
    otherwise
        data = J;
        fprintf(2,'Unsupported data type: %s\n',class(J))
end