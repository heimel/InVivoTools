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
    errordlg([filename ' does not exist.']);
    return
end

rois = record.ROIs.celllist([record.ROIs.celllist.present]==1);
listofcells = {rois.pixelinds}';

[data,t] = tpreaddata(record,[],listofcells,1);

pixelarg.data = data;
pixelarg.listofcells = listofcells;
pixelarg.t = t;

record = tptuningcurve(record,pixelarg);
record = tppsth(record,pixelarg);


