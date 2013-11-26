function out = fixsignAK(in)

in = double(in);
I = find(in<0);
in(I) = in(I)+256;
out = uint8(in);