
H = path;
pad = regexpi(H, '[^;]+tdt2ml', 'match');
pad = ['file:///' pad{1} '/Tdt2ml.htm'];
web(pad)