function play_testrecord( record) 
%PLAY_TESTRECORD wrapper around specific results testrecords
%
% 2021, Alexander Heimel

switch record.datatype
    case 'wc' % webcam
        play_wctestrecord( record );
    case 'hc' % head camera freely moving
        play_hctestrecord( record );
    otherwise
        errormsg(['Unknown datatype ' record.datatype ]);
        return
end