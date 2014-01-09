% 2013-06-20
% Author Mehran
% Modified Rajeev
% Function find out absolute intensity of ROI widefield data
% Function name: "absolute_intensity_widefield"

data = zeros(size(ffrr{1},1),size(ffrr{1},2),length(ffrr));
for i=1:length(ffrr)
    data(:,:,i) = ffrr{i};
end
average_absolute_intensity=mean(data,3);

% Mean absolute values of an ROI and plot time series
% replace with initial and final pixel values of x-axis
x=44:57;
% replace with initial and final pixel values of y-axis
y=42:54;

ts = data(x,y,:);
ts = mean(ts, 1);
ts = mean(ts, 2);
ts = squeeze(ts);
figure, plot(ts)