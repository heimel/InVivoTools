function set_logticks
%SET_LOGTICKS 
%
% 2004, Alexander Heimel
%
  
  
  ax=axis;
  
  ticks=[ (0.001:0.001:0.009) (0.01:0.01:0.09) (0.1:0.1:0.9) (1:1:9) ...
	  (10:10:90) ];
  
  ticks=ticks(find(ticks>ax(1) & ticks<ax(2)));
  
  ticklength=0.03*(ax(4)-ax(3));
  
  if strcmp(get(gca,'YDir'),'normal')
    hs=line( [ticks;ticks],...
	     [ax(3)+zeros(size(ticks));...
	      ax(3)+ticklength*(ones(size(ticks)))]);
  else
    hs=line( [ticks;ticks],...
	     [ax(3)+zeros(size(ticks))+ax(4);...
	      ax(4)-ticklength*(ones(size(ticks)))]);
  end    
    
  
  for i=1:length(hs)
    set(hs(i),'Color',[0 0 0]);
  end
  

  

    ticks=[ 0.001 0.01 0.1 1 10 100];
  
  ticks=ticks(find(ticks>ax(1) & ticks<ax(2)));
  
  ticklength=0.05*(ax(4)-ax(3));
  
  if strcmp(get(gca,'YDir'),'normal')
    hs=line( [ticks;ticks],...
	     [ax(3)+zeros(size(ticks));...
	      ax(3)+ticklength*(ones(size(ticks)))]);
  else
    hs=line( [ticks;ticks],...
	     [zeros(size(ticks))+ax(4);ax(4)-ticklength*(ones(size(ticks)))]);
  end    
    
  
  for i=1:length(hs)
    set(hs(i),'Color',[0 0 0]);
  end
  

  

