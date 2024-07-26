function cspn = normalize_data(csp, thecov, norm)

%  DATA = NORMALIZE_DATA(CSP, THECOV)
%
%  Normalizes data by covariance

switch norm,
 case 0,V=diag(diag(ones(4)));D=diag(diag(ones(4)));
 case 1,[V,D] = eig(thecov); % eig(mean(thecov,3));
 case 2,[V,D] = eig(diag(diag(thecov)));
end;
T = V*sqrt(inv(D));
cspn = multiply(csp,T);
