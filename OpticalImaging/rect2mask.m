function mask=rect2mask( rect, arraysize )
%RECT2MASK produces an array mask from a rectangle
%
%  MASK=RECT2MASK( RECT, ARRAYSIZE )
%
%  2004, Alexander Heimel
%

masky = repmat((1:arraysize(2))',1,arraysize(1));
maskx = repmat((1:arraysize(1)),arraysize(2),1);
masky(masky>rect(4) | masky<rect(2)) = 0;
maskx(maskx>rect(3) | maskx<rect(1)) = 0;
mask = (maskx.*masky)>0;
