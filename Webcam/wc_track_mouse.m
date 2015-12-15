function record  = wc_track_mouse(record)


wcinfo = wc_getmovieinfo( record);
filename = fullfile(wcinfo.path,wcinfo.mp4name);

[freezeTimes, flightTimes] = trackmouse(filename,true)