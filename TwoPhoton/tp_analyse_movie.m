function record = tp_analyse_movie( record, verbose )
%TP_ANALYSE_MOVIE analyses two-photon time series
%
% RECORD = TP_ANALYSE_MOVIE( RECORD,VERBOSE )
%
% 2014-2017, Alexander Heimel
%

if nargin<2 || isempty(verbose)
    verbose = true;
end

if ~exist(experimentpath(record),'dir')
    errormsg(['There is no directory ' experimentpath(record) ]);
    return
end
[filename,record] = tpfilename(record);
if ~exist(filename,'file')
    errormsg([filename ' does not exist.']);
    return
end

[pixelarg.data,pixelarg.t] = tpreaddata(record,[],{record.ROIs.celllist.pixelinds}',1,[],[],verbose);

record = tptuningcurve(record,pixelarg);
record = tppsth(record,pixelarg,verbose);

[pixelarg.data,pixelarg.t] = tpsignalprocess(record, pixelarg.data, pixelarg.t);

record = tpraw(record,pixelarg);


