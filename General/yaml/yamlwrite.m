function txt = yamlwrite(data,file)
%Convert data to YAML text (uses SnakeYAML).
% yamlwrite(data,file)     -write data to yaml file
% txt = yamlwrite(data)     -encode data into yaml string
%
%See also: yamlsetup, yamlread
%
% Version 1.14
% Downloaded from https://github.com/serg3y/yaml-matlab/tree/main


%setup
if ~any(contains(javaclasspath('-all'),'snakeyaml'))
    yamlsetup
end

%generate yaml text
txt = yamlencode(data);

%write to file (optional)
if nargin>1 && ~isempty(file)
    fid = fopen(file,'w');
    fprintf(fid,'%s',txt);
    fclose(fid);
end

function txt = yamlencode(data)
%Convert MatLab data to YAML text
J = matlab2java(data); %intermediate Java class
txt = org.yaml.snakeyaml.Yaml().dump(J).char; %yaml text

function J = matlab2java(data) 
%Convert MatLab data to a Java class
if isnumeric(data) && isempty(data) %null
    J = false(0);
elseif ischar(data)
    J = java.lang.String(data);
elseif numel(data)>1 && (isnumeric(data) || isstruct(data) || islogical(data)) %convert non scalars into cells
    J = matlab2java(num2cell(data));
elseif isnumeric(data)
    J = java.lang.Double(data);
elseif islogical(data)
    J = java.lang.Boolean(data);
elseif iscell(data) %convert arrays to nested cells, dim order: ..>4>3>1>2
    if ndims(data)>2 %#ok<ISMAT>
        data = num2cell(data,1:ndims(data)-1); %nest higher dimensions
    elseif size(data,1)>1 %nest columns
        data = num2cell(data,2);
    end
    J = java.util.ArrayList; %init
    for k = 1:numel(data)
        J.add(matlab2java(data{k}));
    end
elseif isstruct(data)
    J = java.util.LinkedHashMap;
    for f = string(fields(data))'
        J.put(f,matlab2java(data.(f)));
    end
elseif isdatetime(data) %time with millisec: 2011-03-29T16:09:20.667Z
    J = java.util.Calendar.getInstance();
    J.setTimeInMillis(data.Second*1000);
    [Y,data,D,h,m,s] = datevec(data);
    J.set(Y,data-1,D,h,m,s);
    J.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
else
    J = data;
    fprintf(2,'Unsupported data type: %s\n',class(data));
end