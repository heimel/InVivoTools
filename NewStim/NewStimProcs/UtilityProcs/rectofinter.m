function C = rectofinter(A,B)
%
%  C = rectofinter(A,B)
%
%  Returns the rectangle of intersection of rectangle A and B.  A and B
%  are expected to be [x1 y1 x2 y2 ], where (x1,y1), and (x2,y2) are two
%  verticies of the rectangle.  C returns the rectangle of intersection
%  (possibly empty, []) of the two rectangles, and C is
%  [top_x top_y bottom_x bottom_y], where top_x>=bottom_x, top_y>=bottom_y.

ax1=min(A([1 3]));ax2=max(A([1 3])); bx1=min(B([1 3]));bx2=max(B([1 3]));
ay1=min(A([2 4]));ay2=max(A([2 4])); by1=min(B([2 4]));by2=max(B([2 4]));

cx1 = max([ax1 bx1]); cy1 = max([ay1 by1]);
cx2 = min([ax2 bx2]); cy2 = min([ay2 by2]);
if (cx1>cx2)|(cy1>cy2), C = [];
else, C = [cx1 cy1 cx2 cy2];
end;
