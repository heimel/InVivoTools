function [s,h] = struct2char(a,delimiter,delimit_arrays,recurse)
%STRUCT2CHAR converts structure to string
%
%  [S,H] = STRUCT2CHAR(A,DELIMITER,DELIMIT_ARRAYS)
%
%    Use SAVESTRUCTARRAY to save struct array
%
% Steve Van Hooser? , 2013 Alexander Heimel
%

if nargin<4
    recurse = [];
end
if isempty(recurse)
    recurse = true;
end

if nargin<3
    delimit_arrays = [];
end
if isempty(delimit_arrays)
    delimit_arrays = false;
end

if nargin<2
   delimiter = [];
end
if isempty(delimiter)
        delimiter=char(9); % tab
end

s={};
for r=1:length(a)
    [s{end+1},h] = parse_single_line(a(r),delimiter,delimit_arrays,recurse);
end
if length(s)==1
    s=s{1};
end


function [s,h] = parse_single_line(a,delimiter,delimit_arrays,recurse)
s = '';
fn = fieldnames(a);
h = '';
for i=1:length(fn)
    f = a.(fn{i});
    if ischar(f)
        v = f;
        h = [h delimiter fn{i}];
    elseif iscell(f)
        v = cell2str(f);
        h = [h delimiter fn{i}];
    elseif isstruct(f)
        if recurse
            v = struct2char(f);
        else
            v = '';
        end
        h = [h delimiter fn{i}];
    elseif delimit_arrays
        v = num2str(f(:)',[delimiter '%.5f']);
        for j = 1:numel(f)
            h = [h delimiter fn{i}];
        end
    else
        v = mat2str(f,5);
        h =[h delimiter fn{i}];
    end
    s = [s delimiter v];
end
s= s(2:end);
h = h(2:end);
