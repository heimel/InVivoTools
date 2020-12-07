function [n,xedges,yedges, binx, biny] = histcounts2_fast(x,y,xedges,yedges)
%HISTCOUNTS2_FAST is stripped version of histcount2
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(X,Y) partitions the values in X and Y
%   into bins, and returns the count in each bin, as well as the bin edges.
%   X and Y can be arrays of any shape, but they must have the same size.
%   HISTCOUNTS2 determines the bin edges using an automatic binning
%   algorithm that returns uniform bins chosen to cover the range of values
%   in X and Y and reveal the shape of the underlying distribution.
%
%   N is an I-by-J matrix where I and J are the number of bins along the
%   X and Y dimensions respectively. N(i,j) will count the value [X(k),Y(k)]
%   if XEDGES(i) <= X(k) < XEDGES(i+1) and YEDGES(j) <= Y(k) < YEDGES(j+1).
%   The last bins in the X and Y dimensions will also include the upper
%   edge. For example, [X(k),Y(k)] will fall into the i-th bin in the last
%   row if XEDGES(end-1) <= X(k) <= XEDGES(end) &&
%   YEDGES(i) <= Y(k) < YEDGES(i+1).
%
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(X,Y,NBINS) where NBINS is a scalar or
%   2-element vector, specifies the number of bins to use. A scalar
%   specifies the same number of bins in each dimension, whereas the
%   2-element vector [nbinsx nbinsy] specifies a different number of bins 
%   for the X and Y dimensions.
%
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(X,Y,XEDGES,YEDGES) where XEDGES and YEDGES
%   are vectors, specifies the edges of the bins.
%
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(...,'BinWidth',BW) where BW is a scalar
%   or 2-element vector, uses bins of size BW. A scalar specifies the same
%   bin width for each dimension, whereas the 2-element vector [bwx bwy]
%   specifies different bin widths for the X and Y dimensions. To prevent 
%   from accidentally creating too many bins, a limit of 1024 bins can be 
%   created along each dimension when specifying 'BinWidth'. If BW is too 
%   small such that more than 1024 bins are needed in either dimension, 
%   HISTCOUNTS2 uses larger bins instead.
%
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(...,'XBinLimits',[XBMIN,XBMAX])
%   bins only elements between the bin limits inclusive along the X axis,
%   X>=XBMIN & X<=XBMAX. Similarly,
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(...,'YBinLimits',[YBMIN,YBMAX])
%   bins only elements between the bin limits inclusive along the Y axis,
%   Y>=YBMIN & Y<=YBMAX.
%
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(...,'Normalization',NM) specifies the
%   normalization scheme of the histogram values returned in N. NM can be:
%                  'count'   Each N value is the number of observations in
%                            each bin. SUM(N(:)) is generally equal to 
%                            NUMEL(X) and NUMEL(Y), but is 
%                            less than if some of the input data is not 
%                            included in the bins. This is the default.
%            'probability'   Each N value is the relative number of
%                            observations (number of observations in bin /
%                            total number of observations), and SUM(N(:)) 
%                            is less than or equal to 1.
%           'countdensity'   Each N value is the number of observations in
%                            each bin divided by the area of the bin. The
%                            sum of the bin volumes (N value * area of bin)
%                            is less than or equal to NUMEL(X) and NUMEL(Y).
%                    'pdf'   Probability density function estimate. Each N
%                            value is, (number of observations in bin) /
%                            (total number of observations * area of bin).
%                            The sum of the bin volumes (N value * area of bin)
%                            is less than or equal to 1.
%               'cumcount'   Each N value is the cumulative number of
%                            observations in each bin and all previous bins
%                            in both the X and Y dimensions. N(end,end) is
%                            less than or equal to NUMEL(X) and NUMEL(Y).
%                    'cdf'   Cumulative density function estimate. Each N
%                            value is the cumulative relative number of
%                            observations in each bin and all previous bins
%                            in both the X and Y dimensions. N(end,end) is
%                            less than or equal to 1.
%
%   [N,XEDGES,YEDGES] = HISTCOUNTS2(...,'BinMethod',BM), uses the specified automatic
%   binning algorithm to determine the number and width of the bins.  BM can be:
%                   'auto'   The default 'auto' algorithm chooses a bin
%                            size to cover the data range and reveal the
%                            shape of the underlying distribution.
%                  'scott'   Scott's rule is optimal if X and Y are close
%                            to being jointly normally distributed, but
%                            is also appropriate for most other
%                            distributions. It uses a bin size of
%                            [3.5*STD(X(:))*NUMEL(X)^(-1/4)
%                            3.5*STD(Y(:))*NUMEL(Y)^(-1/4)]
%                     'fd'   The Freedman-Diaconis rule is less sensitive to
%                            outliers in the data, and may be more suitable
%                            for data with heavy-tailed distributions. It
%                            uses a bin size of [2*IQR(X(:))*NUMEL(X)^(-1/4)
%                            2*IQR(Y(:))*NUMEL(Y)^(-1/4)] where IQR is the
%                            interquartile range.
%               'integers'   The integer rule is useful with integer data,
%                            as it creates a bin for each pair of integer
%                            X and Y. It uses a bin width of 1 along each
%                            dimension and places bin edges halfway
%                            between integers. To prevent from accidentally
%                            creating too many bins, a limit of 1024 bins
%                            can be created along each dimension with this
%                            rule. If the data range along either dimension
%                            is greater than 1024, then larger bins are
%                            used instead.
%
%   [N,XEDGES,YEDGES,BINX,BINY] = HISTCOUNTS2(...) also returns index arrays
%   BINX and BINY, using any of the previous syntaxes. BINX and BINY are
%   arrays of the same size as X and Y whose elements are the bin indices for
%   the corresponding input elements. The number of elements in the (i,j)th
%   bin is NNZ(BINX==i & BINY==j), which is the same as N(i,j) when
%   Normalization is 'count'. A value of 0 in BINX and BINY indicates an
%   element which does not belong to any of the bins (for example, a NaN
%   value).
%
%   Class support for inputs X, Y, XEDGES, YEDGES:
%      float: double, single
%      integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      logical
%
%   See also HISTOGRAM2, HISTCOUNTS, HISTOGRAM, DISCRETIZE

%   Copyright 1984-2016 The MathWorks, Inc.
%
% 2020, Stripped by Alexander Heimel


import matlab.internal.math.binpicker

% validateattributes(x,{'numeric','logical'},{'real'}, mfilename, 'x', 1)
% validateattributes(y,{'numeric','logical'},{'real','size',size(x)}, ...
%     mfilename, 'y', 2)

% opts = parseinput(varargin);

% Determine Bin Edges on X axis

% opts.NumBins = [];
% opts.XBinEdges = xbinedges;
% opts.YBinEdges = ybinedges;
% opts.XBinLimits = [];
% opts.YBinLimits = [];
% opts.Normalization = 'count';
% opts.BinMethod = [];

% if ~isempty(opts.XBinEdges)
%    xedges = reshape(opts.XBinEdges,1,[]);
% else
%     if isempty(opts.XBinLimits)
%         if ~isfloat(x)
%             % for integers, the edges are doubles
%             xc = x(:);
%             minx = double(min(xc));
%             maxx = double(max(xc));
%         else
%             xc = x(isfinite(x) & isfinite(y));
%             minx = min(xc);  % exclude Inf and NaN
%             maxx = max(xc);
%         end
%     else
%         if ~isfloat(opts.XBinLimits)
%             % for integers, the edges are doubles
%             minx = double(opts.XBinLimits(1));
%             maxx = double(opts.XBinLimits(2));
%         else
%             minx = opts.XBinLimits(1);
%             maxx = opts.XBinLimits(2);
%         end
%         inrange = x>=minx & x<=maxx;
%         if ~isempty(opts.YBinLimits)
%             inrange = inrange & y>=opts.YBinLimits(1) & y<=opts.YBinLimits(2);
%         end
%         xc = x(inrange);
%     end
%     xrange = maxx - minx;
%     if ~isempty(opts.NumBins)
%         numbins = double(opts.NumBins);
%         if isempty(opts.XBinLimits)
%             xedges = binpicker(minx,maxx,numbins(1),xrange/numbins(1));
%         else
%             xedges = linspace(minx, maxx, numbins(1)+1);
%         end
%     elseif ~isempty(opts.BinWidth)
%         if ~isfloat(opts.BinWidth)
%             opts.BinWidth = double(opts.BinWidth);
%         end
%         if ~isempty(minx)
%             % Do not create more than maximum bins.
%             MaximumBins = getmaxnumbins();       
%             if isempty(opts.XBinLimits)
%                 binWidthx = opts.BinWidth(1);
%                 leftEdgex = binWidthx*floor(minx/binWidthx);
%                 nbinsx = max(1,ceil((maxx-leftEdgex) ./ binWidthx));
%                 if nbinsx > MaximumBins  % maximum exceeded, recompute
%                     % See if we can use exactly range/MaximumBins as the 
%                     % bin width. This occurs only when miny is exactly a
%                     % multiple of range/MaximumBins. Otherwise we use 
%                     % range/(MaximumBins-1), to make sure we have exactly
%                     % MaximumBins number of bins.
%                     if rem(minx*MaximumBins, xrange)==0
%                         binWidthx = xrange/MaximumBins;
%                         leftEdgex = minx;
%                     else
%                         binWidthx = xrange/(MaximumBins-1);
%                         leftEdgex = binWidthx*floor(minx/binWidthx);
%                     end
%                     nbinsx = MaximumBins;
%                 end
%                 xedges = leftEdgex + (0:nbinsx) .* binWidthx; % get exact multiples
%             else
%                 binWidthx = max(opts.BinWidth(1), xrange/MaximumBins);
%                 xedges = minx:binWidthx:maxx;
%                 if xedges(end) < maxx || isscalar(xedges)
%                     xedges = [xedges maxx];
%                 end
%             end
%         else
%             xedges = cast([0 opts.BinWidth(1)], 'like', xrange);
%         end
%     else    % BinMethod specified
%         hardlimits = ~isempty(opts.XBinLimits);
%         switch opts.BinMethod
%             case 'auto'
%                 xedges = autorule(xc,minx,maxx,hardlimits);
%             case 'scott'
%                 xedges = scottsrule(xc,minx,maxx,hardlimits);
%             case 'fd'
%                 xedges = fdrule(xc,minx,maxx,hardlimits);
%             case 'integers'
%                 xedges = integerrule(xc,minx,maxx,hardlimits,getmaxnumbins());
%         end
%     end
% end

% Determine Bin Edges on Y axis
% if ~isempty(opts.YBinEdges)
%    yedges = reshape(opts.YBinEdges,1,[]);
% else
%     if isempty(opts.YBinLimits)
%         if ~isfloat(y)
%             % for integers, the edges are doubles
%             yc = y(:);
%             miny = double(min(yc));
%             maxy = double(max(yc));
%         else
%             yc = y(isfinite(x) & isfinite(y));
%             miny = min(yc);  % exclude Inf and NaN
%             maxy = max(yc);
%         end
%     else
%         if ~isfloat(opts.YBinLimits)
%             % for integers, the edges are doubles
%             miny = double(opts.YBinLimits(1));
%             maxy = double(opts.YBinLimits(2));
%         else
%             miny = opts.YBinLimits(1);
%             maxy = opts.YBinLimits(2);
%         end
%         inrange = y>=miny & y<=maxy;
%         if ~isempty(opts.XBinLimits)
%             inrange = inrange & x>=opts.XBinLimits(1) & x<=opts.XBinLimits(2);
%         end
%         yc = y(inrange);
%     end
%     yrange = maxy - miny;
%     if ~isempty(opts.NumBins)
%         numbins = double(opts.NumBins);
%         if isempty(opts.YBinLimits)
%             yedges = binpicker(miny,maxy,numbins(2),yrange/numbins(2));
%         else
%             yedges = linspace(miny, maxy, numbins(2)+1);
%         end
%     elseif ~isempty(opts.BinWidth)
%         if ~isfloat(opts.BinWidth)
%             opts.BinWidth = double(opts.BinWidth);
%         end
%         if ~isempty(miny)
%             % Do not create more than maximum bins.
%             MaximumBins = getmaxnumbins();
%             if isempty(opts.YBinLimits)
%                 binWidthy = opts.BinWidth(2);
%                 leftEdgey = binWidthy*floor(miny/binWidthy);
%                 nbinsy = max(1,ceil((maxy-leftEdgey) ./ binWidthy));
%                 if nbinsy > MaximumBins  % maximum exceeded, recompute
%                     % See if we can use exactly range/MaximumBins as the 
%                     % bin width. This occurs only when miny is exactly a
%                     % multiple of range/MaximumBins. Otherwise we use 
%                     % range/(MaximumBins-1), to make sure we have exactly
%                     % MaximumBins number of bins.
%                     if rem(miny*MaximumBins, yrange)==0
%                         binWidthy = yrange/MaximumBins;
%                         leftEdgey = miny;
%                     else
%                         binWidthy = yrange/(MaximumBins-1);
%                         leftEdgey = binWidthy*floor(miny/binWidthy);
%                     end
%                     nbinsy = MaximumBins;
%                 end
%                 yedges = leftEdgey + (0:nbinsy) .* binWidthy; % get exact multiples
%             else
%                 binWidthy = max(opts.BinWidth(2), yrange/MaximumBins);
%                 yedges = miny:binWidthy:maxy;
%                 if yedges(end) < maxy || isscalar(yedges)
%                     yedges = [yedges maxy];
%                 end
%             end
%         else
%             yedges = cast([0 opts.BinWidth(2)], 'like', yrange);
%         end
%     else    % BinMethod specified
%         hardlimits = ~isempty(opts.YBinLimits);
%         switch opts.BinMethod
%             case 'auto'
%                 yedges = autorule(yc,miny,maxy,hardlimits);
%             case 'scott'
%                 yedges = scottsrule(yc,miny,maxy,hardlimits);
%             case 'fd'
%                 yedges = fdrule(yc,miny,maxy,hardlimits);
%             case 'integers'
%                 yedges = integerrule(yc,miny,maxy,hardlimits,getmaxnumbins());
%         end
%     end
% end

%xedges = full(xedges); % make sure edges are non-sparse
%yedges = full(yedges);

if verLessThan('matlab','9.8')
    [~,binx] = histcountsmex(x,xedges);
    [~,biny] = histcountsmex(y,yedges);
else
    % necessary for >= Matlab R2020a
    [~,binx] = matlab.internal.math.histcounts(x,xedges);
    [~,biny] = matlab.internal.math.histcounts(y,yedges);
end

countslenx = length(xedges)-1;
countsleny = length(yedges)-1;
% Filter out NaNs and out-of-range data
subs = [binx(:) biny(:)];
subs(any(subs==0,2),:) = [];
n = accumarray(subs,ones(size(subs,1),1),[countslenx countsleny]);

% switch opts.Normalization
%     case 'countdensity'
%         binarea = double(diff(xedges.')) .* double(diff(yedges));
%         n = n./binarea;
%     case 'cumcount'
%         n = cumsum(cumsum(n,1),2);
%     case 'probability'
%         n = n/numel(x);
%     case 'pdf'
%         binarea = double(diff(xedges.')) .* double(diff(yedges));
%         n = n/numel(x)./binarea;
%     case 'cdf'
%         n = cumsum(cumsum(n/numel(x),1),2);
% end

% if nargout > 1
%     % make sure the returned bin edges have the same shape as inputs
%     if ~isempty(opts.XBinEdges)
%         xedges = reshape(xedges, size(opts.XBinEdges));
%     end
%     if ~isempty(opts.YBinEdges)
%         yedges = reshape(yedges, size(opts.YBinEdges));
%     end
%     if nargout > 3
%         binx(biny==0) = 0;
%         biny(binx==0) = 0;
%     end
% end

end

% function opts = parseinput(input)
% 
% opts = struct('NumBins',[],'XBinEdges',[],'YBinEdges',[],'XBinLimits',[],...
%     'YBinLimits',[],'BinWidth',[],'Normalization','count','BinMethod','auto');
% funcname = mfilename;
% 
% % Parse third and fourth input in the function call
% inputlen = length(input);
% if inputlen > 0
%     in = input{1};
%     inputoffset = 0;
%     if isnumeric(in) || islogical(in)
%         if inputlen == 1 || ~(isnumeric(input{2}) || islogical(input{2}))
%             % Numbins
%             if isscalar(in)
%                 in = [in in];
%             end
%             validateattributes(in,{'numeric','logical'},{'integer', 'positive', ...
%                 'numel', 2, 'vector'}, funcname, 'm', inputoffset+3)
%             opts.NumBins = in;
%             input(1) = [];
%             inputoffset = inputoffset + 1;
%         else
%             % XBinEdges and YBinEdges
%             in2 = input{2};
%             validateattributes(in,{'numeric','logical'},{'vector', ...
%                 'real', 'nondecreasing'}, funcname, 'xedges', inputoffset+3)
%             if length(in) < 2
%                 error(message('MATLAB:histcounts2:EmptyOrScalarXBinEdges'));
%             end
%             validateattributes(in2,{'numeric','logical'},{'vector', ...
%                 'real', 'nondecreasing'}, funcname, 'yedges', inputoffset+4)
%             if length(in2) < 2
%                 error(message('MATLAB:histcounts2:EmptyOrScalarYBinEdges'));
%             end
%             opts.XBinEdges = in;
%             opts.YBinEdges = in2;
%             input(1:2) = [];
%             inputoffset = inputoffset + 2;
%         end
%         opts.BinMethod = [];
%     end
%     
%     % All the rest are name-value pairs
%     inputlen = length(input);
%     if rem(inputlen,2) ~= 0
%         error(message('MATLAB:histcounts2:ArgNameValueMismatch'))
%     end
%     
%     for i = 1:2:inputlen
%         name = validatestring(input{i}, {'NumBins', 'XBinEdges', ...
%             'YBinEdges','BinWidth', 'BinMethod', 'XBinLimits', ...
%             'YBinLimits','Normalization'}, i+2+inputoffset);
%         
%         value = input{i+1};
%         switch name
%             case 'NumBins'
%                 if isscalar(value)
%                     value = [value value]; %#ok
%                 end
%                 validateattributes(value,{'numeric','logical'},{'integer', ...
%                     'positive', 'numel', 2, 'vector'}, funcname, 'NumBins', i+3+inputoffset)
%                 opts.NumBins = value;
%                 if ~isempty(opts.XBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
%                 elseif ~isempty(opts.YBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
%                 end
%                 opts.BinMethod = [];
%                 opts.BinWidth = [];
%             case 'XBinEdges'
%                 validateattributes(value,{'numeric','logical'},{'vector', ...
%                     'real', 'nondecreasing'}, funcname, 'XBinEdges', i+3+inputoffset);
%                 if length(value) < 2
%                     error(message('MATLAB:histcounts2:EmptyOrScalarXBinEdges'));
%                 end
%                 opts.XBinEdges = value;
%                 % Only set NumBins field to empty if both XBinEdges and
%                 % YBinEdges are set, to enable BinEdges override of one
%                 % dimension
%                 if ~isempty(opts.YBinEdges)
%                     opts.NumBins = [];
%                     opts.BinMethod = [];
%                     opts.BinWidth = [];
%                 end
%                 opts.XBinLimits = [];
%             case 'YBinEdges'
%                 validateattributes(value,{'numeric','logical'},{'vector', ...
%                     'real', 'nondecreasing'}, funcname, 'YBinEdges', i+3+inputoffset);
%                 if length(value) < 2
%                     error(message('MATLAB:histcounts2:EmptyOrScalarYBinEdges'));
%                 end                
%                 opts.YBinEdges = value;
%                 % Only set NumBins field to empty if both XBinEdges and
%                 % YBinEdges are set, to enable BinEdges override of one
%                 % dimension
%                 if ~isempty(opts.XBinEdges)
%                     opts.BinMethod = [];
%                     opts.NumBins = [];
%                     %opts.BinLimits = [];
%                     opts.BinWidth = [];
%                 end
%                 opts.YBinLimits = [];
%             case 'BinWidth'
%                 if isscalar(value)
%                     value = [value value]; %#ok
%                 end
%                 validateattributes(value, {'numeric','logical'}, {'real', 'positive',...
%                     'finite','numel',2,'vector'}, funcname, ...
%                     'BinWidth', i+3+inputoffset);
%                 opts.BinWidth = value;
%                 if ~isempty(opts.XBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
%                 elseif ~isempty(opts.YBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
%                 end
%                 opts.BinMethod = [];
%                 opts.NumBins = [];
%             case 'BinMethod'
%                 opts.BinMethod = validatestring(value, {'auto','scott',...
%                     'fd','integers'}, funcname, 'BinMethod', i+3+inputoffset);
%                 if ~isempty(opts.XBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
%                 elseif ~isempty(opts.YBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
%                 end
%                 opts.BinWidth = [];
%                 opts.NumBins = [];
%             case 'XBinLimits'
%                 validateattributes(value, {'numeric','logical'}, {'numel', 2, ...
%                     'vector', 'real', 'finite','nondecreasing'}, funcname, ...
%                     'XBinLimits', i+3+inputoffset)
%                 opts.XBinLimits = value;
%                 if ~isempty(opts.XBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
%                 end
%             case 'YBinLimits'
%                 validateattributes(value, {'numeric','logical'}, {'numel', 2, ...
%                     'vector', 'real', 'finite','nondecreasing'}, funcname, ...
%                     'YBinLimits', i+3+inputoffset)
%                 opts.YBinLimits = value;
%                 if ~isempty(opts.YBinEdges)
%                     error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
%                 end
%             otherwise % 'Normalization'
%                 opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
%                     'probability', 'pdf', 'cdf'}, funcname, 'Normalization', i+3+inputoffset);
%         end
%     end
% end
% end

function mb = getmaxnumbins
mb = 1024;
end

function edges = autorule(x, minx, maxx, hardlimits)
xrange = maxx - minx;
if ~isempty(x) && (~isfloat(x) || isequal(round(x),x))...
        && xrange <= 50 && maxx <= flintmax(class(maxx))/2 ...
        && minx >= -flintmax(class(minx))/2
    edges = integerrule(x,minx,maxx,hardlimits,getmaxnumbins());
else
    edges = scottsrule(x,minx,maxx,hardlimits);
end
end

function edges = scottsrule(x, minx, maxx, hardlimits)
% Scott's normal reference rule
if ~isfloat(x)
    x = double(x);
end
% Note the multiplier and the power are different from the 1D case
binwidth = 3.5*std(x)/(numel(x)^(1/4));
if ~hardlimits
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);
else
    edges = matlab.internal.math.binpickerbl(min(x(:)),max(x(:)),minx,maxx,binwidth);
end
end

function edges = fdrule(x, minx, maxx, hardlimits)
n = numel(x);
xrange = max(x(:)) - min(x(:));
if n > 1
    % Guard against too small an IQR.  This may be because there
    % are some extreme outliers.
    iq = max(datafuniqr(x(:)),double(xrange)/10);
    % Note the power is different from the 1D case
    binwidth = 2 * iq * n^(-1/4);
else
    binwidth = 1;
end
if ~hardlimits
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);
else
    edges = matlab.internal.math.binpickerbl(min(x(:)),max(x(:)),minx,maxx,binwidth);
end
end

