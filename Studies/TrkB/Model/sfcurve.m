function r=sfcurve(sf,lowsfwidth,highsfwidth)


r=exp(-sf.^2/highsfwidth^2)-exp(-sf.^2/lowsfwidth^2);
r=r/max(r);