function b = get_memory(cksmu, interval)

if nargin==2,
b = 8*length(get_data(cksmu,interval,2));
elseif nargin==1,
b = 8*length(cksmu.data);
end;
