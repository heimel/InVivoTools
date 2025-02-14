function gene=create_gene(param)
% CREATE_GENE creates new stimulus gene
%
%   GENE=CREATE_GENE(PARAM)
%      PARAM is struct with general parameters
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%


gene.type = param.types(unidrnd( length(param.types) ) );
gene.position = struct('x',unidrnd(param.window(1)),...
		       'y',unidrnd(param.window(2)));

gene.onset = unidrnd(param.duration); 
gene.duration = unidrnd(param.duration-gene.onset+1);
gene.size = param.sizelimits(1)+...
      floor(rand(1)*(param.sizelimits(2)-param.sizelimits(1)+1) );

color = param.colors{ unidrnd( length(param.colors) ) };
gene.color=struct('r',color(1),'g',color(2),'b',color(3));

gene.contrast = param.contrastlimits(1)+...
    (param.contrastlimits(2)-param.contrastlimits(1))*rand(1);

speed = -param.speedlimits -1 + unidrnd( 2*param.speedlimits+1 );
gene.speed=struct('x',speed(1),'y',speed(2));

gene.orientation = unidrnd(360)-1;

gene.eccentricity = param.eccentricitylimits(1)+...
    (param.eccentricitylimits(2)-param.eccentricitylimits(1))*rand(1);
