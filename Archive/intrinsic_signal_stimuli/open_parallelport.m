function lpt=open_parallelport
%OPEN_PARALLELPORT


import parport.ParallelPort;
lpt=ParallelPort( hex2dec('378') );
