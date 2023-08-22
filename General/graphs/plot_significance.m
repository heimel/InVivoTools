function plot_significance(x1,x2,y,p,height,w,extra_space)
%PLOT_SIGNIFICANCE calculates significance level and plots stars
%
%   plot_significance(X1,X2,Y,P,[HEIGHT=0],[W=0],[EXTRA_SPACE=False])
%
%  X1, X2 horizontal position of datasets
%  Y height of horizontal line and stars
%  HEIGHT height of vertical lines
%  W extra horizontal width to be added to X1 and X2
%  If EXTRA_SPACE is true, then add a line between stars and Y
%
% 2007-2023, Alexander Heimel
%

if nargin<7 || isempty(extra_space)
    extra_space = false;
end

if nargin<6 || isempty(w)
    w = 0;
end
if nargin<5 || isempty(height)
    height = 0;
end
if isempty(p) || p>0.05 || isnan(p)
    return
end

if ~isnan(y)
    pc = '*';
    if p<0.01
        pc = '**';
    end
    if p<0.001
        pc = '***';
    end
    if extra_space
        pc = [pc '\newline '];
    end

    textx = (x1 + x2) / 2; 
    fontsize = get(gca,'FontSize');
    hl = text(textx,y,pc,'FontSize',fontsize+5,'horizontalalignment','center');
    
    if x1~=x2
        left = x1+w;
        right = x2-w;
        if left~=right
            hl = line([left right],[y y]);
            set(hl,'Color',[0 0 0]);
        end
        if height>0
            hl = line([left left],[y-height/2 y]);
            set(hl,'Color',[0 0 0]);
            hl = line([right right],[y-height/2 y]);
            set(hl,'Color',[0 0 0]);
        end
    end
end

