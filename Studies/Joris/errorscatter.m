function h = errorscatter(x,y,e,col)

%Scattered errorbar plot, works similar to errorbar, x and y should be
%columns
%Plots in a pre-opened figure
%If a matrix is entered then the columns are grouped together around teh x
%values

ncols = size(y,2);
if nargin < 4
    col = jet(ncols);
end

if ncols == 1
    h = errorbar(x,y,e,'linestyle','none','Color',col);
    hold on
    scatter(x,y,[],col,'filled')
else
    %Make the x-axis
    xdiff = mean(diff(x))./4;
    xadd = linspace(-xdiff,xdiff,ncols);
    
    for n = 1:ncols
         errorbar(x+xadd(n),y(:,n),e(:,n),'linestyle','none','Color',col(n,:));
        hold on
        h(n) = scatter(x+xadd(n),y(:,n),[],col(n,:),'filled');
    end
end

return

