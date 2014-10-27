function record = tpraw(record, pixels)
%TPRAW reads full length raw signal and adds it to measures
%
% 2014 Alexander Heimel
%

if isempty(pixels)
    pixels = {record.ROIs.celllist.pixelinds}';
end

if iscell(pixels)
    [data,t] = tpreaddata(record,[], pixels,1);
else
    data = pixels.data;
    t = pixels.t;
end

if ~isempty(record.measures) && length(record.ROIs.celllist)~=length(record.measures)
    errormsg('Different number of measures and ROIs');
    return
end

for i=1:length(record.ROIs.celllist)
    record.measures(i).raw_t = t{i};
    record.measures(i).raw_data = data{i};
end
