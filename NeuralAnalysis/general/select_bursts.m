function newcell=select_bursts( cell, intervals, params )
%SELECT_BURST selects burst events from spikedata
%
%     NEWCELL=SELECT_BURSTS( CELL )
%     NEWCELL=SELECT_BURSTS( CELL, INTERVALS, PARAMS )
%       CELL is a spikedata object
%       INTERVALS is Nx2 array of intervals
%       PARAMS is structure with parameters for burst selection
%       to be used in call to GET_BURSTTIMES, see help there.
%
%       returns a measureddata object NEWCELL with spikedata containing
%       only the times of the first spikes in burst as returned by 
%       GET_BURSTTIMES. NEWCELL contains all associates from CELL
%       and as first associate the type 'Burst fraction of events',
%       which contains as data the ratio of the number of bursts over
%       the number of all events (bursts and single spikes).
%
% 2003, Alexander Heimel (heimel@brandeis.edu)
%

if nargin<3
  params=[];   % let get_bursts decide on default parameters
end
if nargin<2
  intervals=get_intervals( cell );
end


n_intervals=size(intervals,1);
n_spikes=0;
n_all_events=0;

all_bursttimes=[];
for int=1:n_intervals
  spiketimes=get_data( cell, intervals( int, :) );
  n_spikes=n_spikes+length(spiketimes); % just for information
  [bursttimes n_events params]=get_bursttimes( spiketimes, params );
  all_bursttimes=[all_bursttimes bursttimes];
  n_all_events=n_all_events+n_events; 
end

n_bursts=length(all_bursttimes);
fraction=n_bursts/n_all_events;

disp(['# spikes: ' num2str(n_spikes)]);
disp(['# bursts: ' num2str(n_bursts)]);
disp(['# events: ' num2str(n_all_events) ' (#bursts + #tonic spikes)']);
disp(['burst fraction: ' num2str(fraction,2) ' (#bursts / #events)']);


if length(all_bursttimes)==0
  disp('Warning: no bursts detected');
end

newcell = cksmultipleunit(intervals,'bursts','bursts',all_bursttimes,params);


% associate fraction of bursts as first associate to NEWCELL
try
  assoc=getassociate(cell,1); % to get owner
catch
  % no associate present
  assoc=struct(owner,'unknown')
end
assoc.type='Burst fraction of events';
assoc.desc='Fraction of burst out of all burst and tonic spike events';
assoc.data=fraction;
newcell=associate(newcell,assoc);

  
% copy associates from cell to newcell
for i=1:numassociates(cell)
  newcell=associate(newcell,getassociate(cell,i));
end



