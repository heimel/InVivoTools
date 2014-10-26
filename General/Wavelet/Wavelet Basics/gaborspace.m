function [GS,freqs,filter]=gaborspace(S,scls,alpha,beta,req)
% USAGE:
%      [GS,frequencies,filter]=gaborspace(S,[s1 ,s2,ns],alpha,beta,norm);
%  OR: GS=gaborspace(S,filter);
% INPUT:
%       S: 1d signal
%       [s1,s2,ns]: either:
%                     initial,final wavelengths (in sample points) and # of scales
%                      if length ~= 3 then the array of values is assumed
%       alpha: scale = alpha*wavelength default is [1]
%       beta: integration interval = beta*scale, default is [3]
%       filter: if given, the ready filter is used;
%               use alternatively the output FF=fourier_embed(filter); periodic BC implied
%       norm: [n1 n2] offset & normalization options, default [0 0]
%          n1 = 0 no offset; n1=1 zero sum; n1=2 zero square  sum (complex)
%          n2 = 0 no normalization; n2=1 L1 normalized; n2=2 L2 normalized
% OUTPUT:
%       GS: complex Gabor spectrum in log-scale space
%       frequencies: the set of frequencies (to be multiplied by the sample freq.)
%       filter: complex Gabor filter; cellular array
% USES:
%   gaborspaceF; matrix;
% VERSION:
%      Stiliyan,03.12.03

logmsg('CHANGED ROUTINE: NEEDS CHECK');


if nargin<2 
    display('not enough arguments'); 
    help gaborspace; 
    return 
end
if nargin<3 
    alpha=1;
end
if nargin<4 
    beta=3;
end
if nargin<5 
    req=[0 0];
end;
if length(req)<2 
    req=[0 0]; 
end;
if ~iscell(scls) && ~isreal(scls)  
    GS=gaborspaceF(S,scls); 
    return
end
% building the filter
if ~iscell(scls) && isreal(scls) 
    if length(scls)==3
        %logarithmic scale list
        ls1=(log(scls(1)));
        ls2=(log(scls(2)));
        ns=scls(3);
        ds=(ls2-ls1)/(ns-1);
        wave=exp((ls1:ds:ls2));
    else
        wave=scls; 
        ns=length(scls);
    end
    freqs=(wave.^(-1));
    filter=cell(ns,1);
    norm=(1/sqrt(2*pi));
    for k=1:ns
        sigma=alpha*wave(k);
%        T=round(beta*sigma); 
        T=floor(beta*sigma); % changed by Alexander Heimel, 2014-10-26
        D=-T:T;
        filter{k}=(norm/sigma)*exp(-(D.^2/sigma^2)-1i*(2*pi*freqs(k))*D);
        switch req(1)
            case 1, filter{k}=filter{k}-mean(filter{k});
            case 2,filter{k}=filter{k}-mean(filter{k})+sqrt((mean(filter{k}))^2-mean((filter{k}).^2));
        end;
        switch req(2)
            case 2, b=sum(filter{k}.*conj(filter{k}));filter{k}=filter{k}/sqrt(b);
            case 1, b=sum(sqrt(filter{k}.*conj(filter{k})));filter{k}=filter{k}/(b);
        end;
    end
else
    filter=scls;
    ns=length(filter);
    freqs=0;
end
%building the Gabor scale-space
GS=cell(ns,1);
ds=numel(S);
S=reshape(S,[1,ds]);
for k=1:ns
    T=length(filter{k});
    if T<=ds
        GS{k}=zeros(ds-T+1,1);
        %S1=[S(T:-1:2),S,S(ds-1:-1:ds-T+1)];
        % for l=1:(ds-T+1) GS{k}(l)=sum(filter{k}.*S(l:(l+T-1)));end
        C=conv(filter{k},S);
        C=conj(C');
        GS{k}=C(T:ds);
    else
        GS{k}=0;
    end
end
if iscell(GS) 
    GS=matrix(GS); 
end