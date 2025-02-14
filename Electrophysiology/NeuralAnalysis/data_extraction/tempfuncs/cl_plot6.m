function cl_plot6(x,holdon,color)

% cl_plot6(x,holdon,color)
count = 1;
for i=1:3
	for j=(i+1):4
		subplot(3,2,count);count=count+1;
		if holdon
			hold on;
		else
			hold off;
		end
		plot(x(:,i),x(:,j),color);
		title([num2str(i) '-' num2str(j)]);
	end
end
