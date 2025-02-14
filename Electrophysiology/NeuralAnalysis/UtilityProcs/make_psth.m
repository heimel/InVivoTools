function [N,X, rast,vals] = make_psth(spikedata, triggers, interv, res, normalize);

%  [N,X, RAST] = MAKE_PSTH(SPIKEDATA, TRIGGERS, INTERV, RES, NORMALIZE, RASTTYPE)
%
%      MAKE_PSTH gives a peri-stimulus time histogram.  The bins of the
%  histogram are given in X, while the values in each bin are given in N.
%  Rasters are also returned in the sparse matrix RAST; each trial has a
%  separate row.  The function takes as arguments SPIKEDATA, a spikedata
%  object to be evaluated, TRIGGERS, a list of trigger times,
%  INTERV = [ before after], which tells how much before and after the
%  trigger the histogram should examine, and RES, which is the time
%  resolution of the histogram.  NORMALIZE = 0/1, and if it is 1 then the
%  output is normalized by the number of triggers.  RASTTYPE == 1 specifies
%  RAST should be a cell with number of trigger entries, each of which has
%  all spike times for that peri-stimulus time.  RASTTYPE == 0 specifies
%  that the RAST should be an X x (length of histogram) sparse matrix with
%  each peri-stimulus time in a row.   All units are SI.
%
%  (documentation cryptic...fix)
%
%                                          Questions?  vanhoosr@brandeis.edu

   edges = [ -interv(1) : res : interv(2) ];
   N = zeros(length(edges),1);
   X = edges-res/2;
   rast_x = []; rast_y = [];
   vals = zeros(length(edges),length(triggers));

for i=1:length(triggers),

   g = get_data(spikedata, [triggers(i)-interv(1) triggers(i)+interv(2)]);
   n = histc(g-triggers(i),edges);
   if size(n,2)>size(n,1),n=n'; end;
   if ~isempty(n),
       vals(:,i) = n;
	N = N + n;
	rast_x=[ rast_x edges(find(n)) ];
	rast_y=[ rast_y repmat(i,1,length(find(n))) ];
   end;
end;

% make new rast, a Nx2 matrix with X and Y for raster plot

rast = [ rast_x ; rast_y;];

if normalize, N = N / (length(triggers)*res); end;
