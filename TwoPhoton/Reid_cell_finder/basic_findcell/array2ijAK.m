function out = array2ijAK(in)

in = uint8(in);
si = size(in);
ip = ij.process.ByteProcessor(si(2), si(1));
Pix = reshape((in'),(si(2)*si(1)),1);
ip.setPixels(Pix);
out = ij.ImagePlus('',ip);