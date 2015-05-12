function oi_plot_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y)
%OI_PLOT_MONITORCENTER plots circle at response position
%
% 2015, Alexander Heimel

if isempty(record.response)
    logmsg('No monitor center position');
    return
end

subplot(h_image);

% convert x y back to image scale
xy=record.response/record.scale;
x=xy(1);y=xy(2);

% shift by lambda
x=x+lambda_x;
y=y+lambda_y;

% shift to absolute unbinned coordinates
if isfield(fileinfo,'xoffset')
    x=x-fileinfo.xoffset;
    y=y-fileinfo.yoffset;
else
    logmsg('no xoffset in fileinfo. probably missing data file');
    return
end

% transform monitor center to binned coordinates
x=round(x)/fileinfo.xbin;
y=round(y)/fileinfo.ybin;

hold on
plot(x,y,'ow');
h=plot(x,y,'ow');
set(h,'MarkerSize',10);

