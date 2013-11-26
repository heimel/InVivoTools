function n_omega=normalization_pool(sf,sf_low,sf_high,c_high,sigma,n,animal)
%N(omega) from TrkB.T1 paper
%
% 2009, Alexander Heimel
%
if nargin<7
  animal='mouse';
end


n_omega_l=1;

n_omega= sigma^n * population_response_c_high( sf,sf_low,sf_high,animal) * n_omega_l ...
	./ (sigma^n+c_high^n- ...
	   c_high^n* population_response_c_high( sf,sf_low,sf_high,animal) );

return

function p=population_response_c_high(sf,sf_low,sf_high,animal)
switch animal
  case 'mouse'
    p=max(0,(sf_high-sf))/(sf_high-sf_low);
  case 'cat'
    % from Schmidt et al. 2004
    % cat vep response linear on a x-log axis (y linear)
    % and end at 4 cpd (below 6cpd literature value)
    % sf_low=0.1;
    % sf_high=4;
    % contrast_high=0.93;
    % p=max(0,(log10(sf_high)-log10(sf)))/(log10(sf_high)-log10(sf_low));
    
    % from Heywood, Petry, Casagrande, 1983
    %p=250*sf.^0.6.*exp(-sf.^2/0.9^2);
    %p=p/max(p); % normalize
    
    % from Mallik et al., 2008
    p=250*sf.^0.6.*exp(-sf.^2/0.9^2);
    p=p/max(p); % normalize
  case 'macaque'
    p=sf.^0.05.*exp(-sf.^2/10^2);
    p=p/max(p); % normalize

  case 'flat'
    p=ones(size(sf));
end
