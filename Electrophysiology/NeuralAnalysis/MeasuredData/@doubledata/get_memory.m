function b = get_memory(dd, interval)

if nargin==2,
  inds=find(dd.time>=interval(1)&dd.time<=interval(2));
  b = 8 * (1+size(dd.data,2))*length(inds);
elseif nargin==1,
  b = 8 * (1+size(dd.data,2))*size(dd.data,1);
end;
