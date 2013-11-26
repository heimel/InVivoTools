function [ output_args ] = colbars(h, colmap, inx)
ch = get(h,'Children');
fvd = get(ch,'Faces');
fvcd = get(ch,'FaceVertexCData');
for i = 1:size(fvd,1)
    fvcd(fvd(i,:)) = inx(i);
end
set(ch,'FaceVertexCData',fvcd);
colormap(colmap);
