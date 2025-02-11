function open_tptestrecord( record)
%OPEN_TPTESTRECORD
%
%   OPEN_TPTESTRECORD( RECORD)
%
% 2009-2014, Alexander Heimel

if strcmp(record.datatype,'tp')~=1
  warning('InVivoTools:datatypeNotImplemented',['datatype ' record.datatype ' is not implemented.']);
  return
end

tpsetup(record);
if ~exist(experimentpath(record),'dir')
    errormsg(['There is no directory ' experimentpath(record) ]);
    return
end
[filename,record] = tpfilename(record);
% filename=tpfilename(record); % Laila
if ~exist(filename,'file')
    errormsg([filename ' does not exist.']);
    return
end

h_tp = get_fighandle('TP database*');
if ~isempty(h_tp)
    ud = get(h_tp,'userdata');
    analysis_parameters.blind = get(ud.h.blind,'value');
    analysis_parameters.record_index = ud.current_record;
else
    analysis_parameters.blind = 0;
    analysis_parameters.record_index = [];
end

analyzetpstack('NewWindow', record, [], analysis_parameters);



