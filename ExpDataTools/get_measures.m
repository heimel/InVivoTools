function measuress = get_measures( measures, measuredb )
%GET_MEASURES gets measure-structs by name from measuredb
%
% MEASURESS = GET_MEASURES( MEASURES )
% MEASURESS = GET_MEASURES( MEASURES, MEASUREDB )
%
% 2007, Alexander Heimel
%

if nargin<2
  measuredb=[];
end
if isempty(measuredb)
  measuredb=load_measuredb;
end
if ~iscell(measures)
  measures=split(measures,',');
end
n_measures=length(measures);
ind=[];
for m=1:n_measures
  ind=[ind find_record(measuredb,['name~' measures{m}])];
end
if isempty(ind)
    % try to parese measures
    % expecting DATATYPE:STIM_TYPE:MEASURE
    for i=1:length(measures)
        measuress(i).name = measures{i};
        measuress(i).label = measures{i};
        
        measuress(i).datatype = measures{i}(1:find(measures{i}==':',1)-1);
        measuress(i).stim_type = measures{i}((find(measures{i}==':',1)+1):(find(measures{i}==':',1,'last')-1));
        measuress(i).point = '';
        measuress(i).measure = measures{i}((find(measures{i}==':',1,'last')+1):end);
    end
else
    measuress=measuredb(ind);
end


