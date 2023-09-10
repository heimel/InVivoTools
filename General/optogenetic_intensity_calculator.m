function Iz = optogenetic_intensity_calculator(z,I,r)
% optogenetic_intensity_calculator. Computes how much power remains at a certain distance in gray matter
%
% IZ = optogenetic_intensity_calculator(Z,I,R)
%    I is power of light level fiber
%    R is radius of optic fiber
%    Z is distance from fiber tip in meter
%    IZ is power at distance Z in same units as I
%
% From Aravanis et al. J Neural Eng 4, S143-S156 (2007) 
%    An optical neural interface: in vivo control of rodent motor cortex with integrated fiberoptic and optogenetic technology
%
% 2023, Alexander Heimel 

if nargin<3 || isempty(r)
    r = 100E-6; % m, radius of fiber
end

% z = linspace(0,1E-3,100)
% figure
% plot(z,intensity(z,1,r))
% set(gca,'yscale','log')
% ylim([1E-3 1])
% xlabel('Depth (m)')

I0 = I / (pi*r^2); % W/m^2
S = 11.2E3; % m^1 for mouse
NA = 0.37; % From Aravanis
n_tissue = 1.36; % From Aravanis
rho = r * sqrt( (n_tissue/NA)^2 -1);
Iz = I0 * rho^2 ./ ((S * z + 1) .* (z + rho).^2);
