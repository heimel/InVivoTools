function fname=tpfilename(fnameprefix,cycle,channel,frame)

fname=[fnameprefix 'Cycle' sprintf('%.3d',cycle) '_Ch' int2str(channel) '_' sprintf('%.6d',frame) '.tif'];