function structinfo( s )
%STRUCTINFO returns information about memory usage of struct array
%
% STRUCTINFO( S )
%
% 2013, Alexander Heimel
%

m = whos('s');
disp(['Number of records: ' num2str(numel(s))]);
disp(['Memory: ' bytes2str( m.bytes )]);

flds = fieldnames(s);
sumofmem = zeros(length(flds),1);
for i=1:numel(s)
    r = s(i);
    for f=1:length(flds)
        fld = r.(flds{f});
        x = whos('fld');
        sumofmem(f) = sumofmem(f) + x.bytes;
    end
end
for f=1:length(flds)
    disp(['Memory for ' flds{f} ': ' bytes2str( sumofmem(f) )]);
end
disp(['Sum of fields memory: ' bytes2str( sum(sumofmem))]);


if isfield(s,'measures') % very specific to leveltlab
    measuremem = [];
    for i = 1:numel(s)
        for j=1:length(s(i).measures)
            measure = s(i).measures(j);
            flds = fieldnames(measure);
            for f = 1:length(flds)
                if ~isfield(measuremem,flds{f})
                    measuremem.(flds{f}) = 0;
                end
                fld = measure.(flds{f}); %#ok<NASGU>
                x = whos('fld');
                measuremem.(flds{f}) = measuremem.(flds{f}) + x.bytes;
            end
        end
    end
    flds = fieldnames(measuremem);
    szs = struct2array(measuremem);
    [szs,ind] = sort(szs);
    flds = {flds{ind}};
    for f=1:length(flds)
        disp(['Memory for ' flds{f} ': ' bytes2str( szs(f) )]);
    end
end




function siz = bytes2str( bytes )
if bytes < 1024
    siz = [num2str(bytes) ' b'];
elseif bytes < 1024^2
    siz = [num2str(fix(bytes/1024)) ' kb'];
elseif bytes < 1024^3
    siz = [num2str(fix(bytes/1024/1024)) ' Mb'];
end
