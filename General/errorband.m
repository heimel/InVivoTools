function h = errorband(x,y,b,color)
%errorband. Plots errorband around line
%
%    h = errorband(x,y,b,[color])
%
% 2025, Alexander

if nargin<4 || isempty(color)
    co = colororder(gca());
    color = co(gca().ColorOrderIndex,:);
end

x = x(:)';
y = y(:)';
b = b(:)';

vx = [x flip(x)];
vy = [y-b flip(y+b)]';
held = ishold();
h(1) = fill( vx,vy,color,'LineStyle','none','FaceAlpha',0.5);
hold on;
h(2) = plot(x,y,'color',color);
if ~held
    hold off;
end
