function mcsp = cl_medianTemplates(csp,cls)
% mcsp = cl_medianTemplates(csp,cls)

N = length(cls);

mcsp = zeros(size(csp,1),N);

for i=1:N
	mcsp(:,i) = median(csp(:,cls(i).idx)')';
end
