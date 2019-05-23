function semap = makesemap(minval,maxval,darken)
%MAKESEMAP MAkes a Suppression/Enhancement colormap
%Darken makes the map move through full red/blue to darkr colors
%
% 2019, Matthew Self

if nargin<3
    darken = 0;
end

cspace = linspace(minval,maxval,64);

%Find zero-point
zp = find(cspace>=0,1,'first');
semap = zeros(64,3)+0.5;

%MAke all points above zero scale from grey to red

if darken
    hp = round(zp+(64-zp)/2);
    semap(zp:hp,1) = linspace(0.5,1,hp-zp+1)';
    semap(hp:end,1) = linspace(1,0.5,64-hp+1)';
    semap(zp:hp,2) = linspace(0.5,0,hp-zp+1)';
    semap(hp:end,2) = 0;
    semap(zp:hp,3) = linspace(0.5,0,hp-zp+1)';
    semap(hp:end,3) = 0;

else
    semap(zp:end,1) = linspace(0.5,1,64-zp+1)';
    semap(zp:end,2) = linspace(0.5,0,64-zp+1)';
    semap(zp:end,3) = linspace(0.5,0,64-zp+1)';
end


%All pojts below scale from grey to blue

if darken
    hp = round(zp/2);
    semap(1:hp,3) = linspace(0.5,1,length(hp:zp))';
    semap(hp:zp,3) = linspace(1,0.5,length(hp:zp))';
    semap(1:hp,2) = 0;
    semap(hp:zp,2) = linspace(0,0.5,length(hp:zp))';
    semap(1:hp,1) = 0;
    semap(hp:zp,1) = linspace(0,0.5,length(hp:zp))';
    
else
    semap(1:zp,1) = linspace(0,0.5,zp)';
    semap(1:zp,2) = linspace(0,0.5,zp)';
    semap(1:zp,3) = linspace(1,0.5,zp)';
end


return