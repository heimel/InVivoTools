% USAGE:
%   G = gaborspaceF(S,FF,F);
% INPUT:
%   S - signal
%   FF - complex fourier matrix of the filter 
%   F  - optional, original filter, accounts only for boundary effects removal
% OUTPUT:
%   G - complex Gabor spectrum
% VERSION:
%   Stiliyan, 11.01.00

function  G = gaborspaceF(S,FF,F)
[nf,ns]=size(FF); 
ms = min(ns,length(S));
if ns > ms
    S=[S;zeros(ns-ms,1)];
% elseif length(S) > ms
%     FF=[FF;zeros(nf,ns-ms)];
end
[nf,ns]=size(FF); 
G=zeros(nf,ns);

SF=fft(S); % calculate fourier space

%cSF = reshape(conj(SF),[1,ns]);
% for k=1:nf 
% %    G(k,:)=FF(k,:).*reshape(conj(SF),[1,ns]); 
%     G(k,:)=FF(k,:).*cSF; 
% end; 
%convolute wavelets with frequency space
G = FF.*repmat(reshape(conj(SF),[1,ns]),size(G,1),1);


G=fft(G,[],2);
% boundary effects compensation 
if nargin>2
   for k=1:nf 
       L=floor(length(F{k})/2); 
       G(k,1:L)=0;
       G(k,ns-L+1:ns)=0; 
   end;
end