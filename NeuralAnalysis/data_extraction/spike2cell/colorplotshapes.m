function colorplotshapes(shapes)
%COLORPLOTSHAPES plots all spikeshapes in SHAPES in subplots

[n_times n_channels n_shapes]=size(shapes);

     cols=3;
     rows=ceil(n_shapes/cols);

for sh=1:n_shapes
subplot(rows,cols,sh);
plot(shapes(:,:,sh));axis([1 n_times min(shapes(:)) max(shapes(:))])  

end
