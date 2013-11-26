function tpodanalysis( resps,data , t, listofcells, listofcellnames, params, process_params, timeint)
%TPODANALYSIS analyses twophoton sgs(3d) data
%
%  TPODANALYSIS( RESPS )
%
% 2010, Alexander Heimel & Charlotte van Coeverden
%
%

for c=1:length(listofcells)
   data{1,c} = resps(c).curve(2,1)/(resps(c).curve(2,1)+resps(c).curve(2,2)); % Mrsic-Flogel OD score
   t{1,c} = c;  % just an example
end


plot_params.what = 'amplitude';
process_params.method = 'event_detection';

 tpshowevents( data, t, listofcells, listofcellnames, params,process_params, timeint,plot_params)
