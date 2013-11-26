function gene = mutate_gene( gene, param )
% MUTATE_GENE mutates one gene
%
%   GENE = MUTATE_GENE( GENE, PARAM )
%     mutates gene
%
%   GENE = MUTATE_GENE( GENE )
%     uses genetic_defaults as PARAM
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param=genetic_defaults;
end

fields=fieldnames(gene);
field=fields{unidrnd( length(fields) )};
switch field
 case 'type' % new
   gene.type = param.types( unidrnd( length(param.types) ) );
 case 'position' % adjust
   gene.position.x = mod( gene.position.x-round(param.window(1)/2)+...
			unidrnd(param.window(1)), param.window(1) ) + 1;
   gene.position.y = mod( gene.position.y-round(param.window(2)/2)+...
			unidrnd(param.window(2)), param.window(2) ) + 1;
 case 'duration' % adjust
   gene.duration = gene.duration + unidrnd( round(param.duration/2))-...
       round(param.duration/4) ;
   gene.duration = min( param.duration-gene.onset+1, ...
			gene.duration);  % avoid going past window
   gene.duration = max( 0, gene.duration);  % don't avoid zero
 case 'onset' % adjust
  gene.onset = gene.onset + unidrnd( round(param.duration/2))-...
      floor(param.duration/4)-1 ;
  gene.onset = max( 1, gene.onset); % avoid zero
  gene.onset = min( param.duration-gene.duration+1, gene.onset); 
 case 'size' % new
  gene.size =  param.sizelimits(1)+...
      floor(rand(1)*(param.sizelimits(2)-param.sizelimits(1)+1) );
 case 'contrast' % new
  gene.contrast =  param.contrastlimits(1)+...
      (param.contrastlimits(2)-param.contrastlimits(1))*rand(1);
 case 'color'%  new
  color = param.colors{ unidrnd( length(param.colors) ) };
  gene.color=struct('r',color(1),'g',color(2),'b',color(3));
 case 'speed' % adjust
  gene.speed.x = gene.speed.x - 1 + floor(3* rand(1) );
  gene.speed.x = sign(gene.speed.x)*min( abs(gene.speed.x), param.speedlimits(1));

  gene.speed.y = gene.speed.y - 1 + floor(3* rand(1) );
  gene.speed.y = sign(gene.speed.y)*min( abs(gene.speed.y), param.speedlimits(2));
 case 'orientation' % adjust
  gene.orientation = mod( gene.orientation - 45 + unidrnd(90), 360);
 case 'eccentricity' % adjust
  gene.eccentricity = gene.eccentricity + ...
      0.3*rand(1)*(param.eccentricitylimits(2)-param.eccentricitylimits(1));
  gene.eccentricity=min(gene.eccentricity,param.eccentricitylimits(2));
  gene.eccentricity=max(gene.eccentricity,param.eccentricitylimits(1));
  
 otherwise
  disp( 'warning! mutate_gene: field unknown' );
end
