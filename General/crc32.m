function crc = crc32(data)

%crc32   Computes the CRC-32 checksum value of a byte vector.
%--------------------------------------------------------------------------
%   CRC = crc32(DATA) computes the CRC-32 checksum value of the data stored
%   in vector DATA. The elements of DATA are interpreted as unsigned bytes
%   (uint8). The result is an unsigned 32-bit integer (uint32). Polynomial
%   bit positions have been reversed, and the algorithm modified, in order
%   to improve performance.

%   Version:    1.00
%   Programmer: Costas Vlachos
%   Date:       23-Dec-2014

% Initialize variables
crc  = uint32(hex2dec('FFFFFFFF'));
poly = uint32(hex2dec('EDB88320'));
data = uint8(data);

% Compute CRC-32 value
for i = 1:length(data)
    crc = bitxor(crc,uint32(data(i)));
    for j = 1:8
        mask = bitcmp(bitand(crc,uint32(1)));
        if mask == intmax('uint32'), mask = 0; else mask = mask+1; end
        crc = bitxor(bitshift(crc,-1),bitand(poly,mask));
    end
end
crc = bitcmp(crc);