function record = tp_analyse_movie( record )
%TP_ANALYSE_MOVIE analyses two-photon time series
%
% RECORD = TP_ANALYSE_MOVIE( RECORD )
%
% 2014, Alexander Heimel
%


if ~exist(tpdatapath(record),'dir')
    errormsg(['There is no directory ' tpdatapath(record) ]);
    return
end
[filename,record] = tpfilename(record);
if ~exist(filename,'file')
    errormsg([filename ' does not exist.']);
    return
end

[pixelarg.data,pixelarg.t] = tpreaddata(record,[],{record.ROIs.celllist.pixelinds}',1);

record = tptuningcurve(record,pixelarg);
record = tppsth(record,pixelarg);

process_params = tpprocessparams(record);
[pixelarg.data,pixelarg.t] = tpsignalprocess(process_params, pixelarg.data, pixelarg.t);

record = tpraw(record,pixelarg);


