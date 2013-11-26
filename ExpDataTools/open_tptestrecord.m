function open_tptestrecord( record)
%OPEN_TPTESTRECORD
%
%   OPEN_TPTESTRECORD( RECORD)
%
% 2009-2013, Alexander Heimel

if strcmp(record.datatype,'tp')~=1
  warning('InVivoTools:datatypeNotImplemented',['datatype ' record.datatype ' is not implemented.']);
  return
end

tpsetup(record);
if ~exist(tpdatapath(record),'dir')
    errordlg(['There is no directory ' tpdatapath(record) ]);
    return
end
[filename,record] = tpfilename(record);
if ~exist(filename,'file')
    errordlg([filename ' does not exist.']);
    return
end

h_tp = get_fighandle('TP database*');
ud = get(h_tp,'userdata');
analysis_parameters.blind = get(ud.h.blind,'value');
analysis_parameters.record_index = ud.current_record;

analyzetpstack('NewWindow', record, [], analysis_parameters);



