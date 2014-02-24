function y = mattsmooth(x,win)

%Sliding window mean smoothing
[sz1,sz2] = size(x);

%Win is best as an odd-number, then the window is symmetrci around sample
if ~rem(win,2)
    win = win+1;
end

%pad x with zeros
edge = zeros((win-1)./2,1);

y = zeros(sz1,sz2);

%smooth the rows (i.e. across the columns)
for n = 1:sz1
    
    b = [edge,x(n,:),edge];
    for m = length(edge)+1:sz2
       xwin = m-length(edge):m+length(edge);
       y(m-length(edge)) = mean(b(xwin)); 
    end
        
    
end

return
