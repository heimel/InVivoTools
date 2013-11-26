function r=exprc(par,x)
%EXPRC returns cascaded exponential low-pass and RC high-pass filter
%
%    R=EXPRC(PAR, X)
%
%    PAR = [ R0 RMAX FLOW FHIGH EXPLOW] 
%    
%    X is input variable vector
%    R0 is baseline response
%    RMAX is maximum response
%    FLOW is halfheight frequency low-pass filter
%    FHIGH is halfheight frequenct high-pass filter
%    EXPLOW is exponent of exponential low-pass
%
%  Phenomelogical fit for temporal frequency tuning. First used in
%    Levitt, Kiper, Movshon 1994
%    also used in O'Keefe, Levitt, Kiper, Shapley, Movshon, 1998
%    Hawken, Shapley, Grosof, 1996
%

%par=abs(par);
par(3)=par(3)/log(2);  

% exponential low pas, rc high pass
%r= par(1)+ (par(2)-par(1))*exp( -x/par(3))./sqrt(1+3*par(4)^2.*x.^-2);

% rc low and rc high pass
%r= par(1)+ (par(2)-par(1))./sqrt(1+3*par(4)^-2.*x.^2)./sqrt(1+3*par(4)^2.*x.^-2);


par=abs(par);
r= par(1)+ par(2).*exp( -x.^2/2./par(3)^2) - par(4) .* exp( -x.^2/2./par(5)^2);


%using explow with free exponential
%r= par(1)+ (par(2)-par(1))*exp( -x.^par(5)/par(3)^2)./sqrt(1+3*par(4)^2.*x.^-2);

