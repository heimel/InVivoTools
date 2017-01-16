function im = stimicon( stim )
par = getparameters( stim );
w = 100;
[x,y] = meshgrid(1:w,1:w);

switch par.imageType
    case 2 % sine
        fun = @identity;
        % do nothing
    case 1 % square-wave
        fun = @sign;
end

phi = par.angle/180*pi;
sf = par.sFrequency*2/0.05/w;
im = par.background + par.contrast*par.background*fun(sin(sin(phi)*x*sf*2*pi - cos(phi) * y*sf*2*pi  + par.sPhaseShift/180*pi));

if nargout<1
    image( im*64);
    axis image square off
    colormap gray
end