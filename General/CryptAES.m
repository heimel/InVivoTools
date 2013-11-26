function DataOut = CryptAES(Command, DataIn, Key)
% 128 bit AES en/decryption with CBC, integer method
% This function en/decrypts data with the AES-Rijndeal algorithm in pure Matlab
% (no Java, no MEX). Robust "Cipher block chaining" (CBC, see RFC3602) is
% applied.
% Calling a JAVAX or MEX version would be dramatically faster, but this
% implementation works without external functions. This supports e.g. a single
% P-coded function for access control without allowing users to set break points
% in subfunctions to manipulate the program flow.
%
% It is tried to overwrite confidential data with zeros after processing (look
% for: "% Clear secrets"). But this is not really save, because Matlab can
% create copies of the arrays and another process on your computer could read
% secret data from the memory.
%
% Reply = CryptAES(Data, Key, Command)
% INPUT:
%   Command: 'encode' or 'decode'.
%   Data: Array with elements in the range [0:255].
%         Accepted classes: CHAR, DOUBLE, (U)INT(8/16/32).
%         The number of elements must be a multiple of 16.
%   Key:  String or numerical vector with values in the range of UINT8.
%         A 128 bit hash of the Key is built by AES encoding with a fixed key
%         and the random CBC (no MD5 call).
%
% OUTPUT:
%   Reply: Encrypted data as UINT8 column vector. The first 16 bytes are the
%          random initial CBC vector.
%
% EXAMPLE:
%   Encrypt and decrypt random 10000 bytes:
%     Data    = char(floor(rand(1, 10000) * 256));
%     Encoded = CryptAES('encode', Data,    Key);
%     Decoded = CryptAES('decode', Encoded, Key);
%     if ~isequal(Data, char(Decoded)), error('CryptAES failed.'); end
%
%   See: EncryptFile, DecryptFile.
%
% NOTES:
% - CryptAES uses integer arithmetics and needs about the half time of CryptAESd
%   with DOUBLEs. In Matlab 6 only the later works.
% - Speed (1.5GHz Pentium-M, Matlab 7.8): 40 kB/s encoding, 28 kB/s decoding.
%   Although CryptAES is ~4 times faster than the reference implementation of
%   J.J. Buchholz, JAVAX encodes 14MB/s!
%
% REFERENCES:
% Specification of CBC and (successfully applied) test data:
%   RFC 3602 - The AES-CBC Cipher Algorithm and Its Use with IPSec
%   http://www.faqs.org/ftp/rfc/rfc3602.txt
%
% Reference implementation in Matlab:
%   Copyright 2001-2005, J. J. Buchholz, Hochschule Bremen,
%   http://www.mathworks.com/matlabcentral/fileexchange/1190
%   (meanwhile the file has BSD license: Copyright (c) 2009, Joerg Buchholz)
%
% A much faster method using JAVAX (Matlab >= 7):
%   Michael Kleder, 04-Nov-2005
%   http://www.mathworks.com/matlabcentral/fileexchange/8925
%
% Tested: Matlab 7.7, 7.8, Win2K/XP, [UnitTest]
% Author: Jan Simon, Heidelberg, (C) 2009 J@n-Simon.De

% $JRev: R20090915.00b V:025 Sum:D8F2DFC5 Date:15-Sep-2008 18:25:08 $
% $File: User\JSim\Published\CryptAES_20090915\CryptAES.m $

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
% REMOVE THIS AND CryptAESd.m IF YOU DON'T USE MATLAB 6: >>>>>>>>>>>>>>>>>>>>>>>
% Matlab 6 does not allow to add 1 to UINT16 arrays, therefore a slower
% implementation with DOUBLE arithmetics is called:
if sscanf(version, '%f', 1) < 7.0   % I'm not sure which 7.? allows UINT16 ops.
   DataOut = CryptAESd(Command, DataIn, Key);
   return;
end
% <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

ErrID = ['JSim:', mfilename];

% Initial values: --------------------------------------------------------------
% Program Interface: -----------------------------------------------------------
if nargin ~= 3
   error(ErrID, '3 inputs required!');
end

% Length of data must be a multiple of 16:
DataLen = numel(DataIn);
if or(DataLen == 0, rem(DataLen, 16))
   error(ErrID, 'Length of Data not a multiple of 16!');
end

% Reshape input data for fast block operations and use integers if possible:
DataIn = reshape(uint16(DataIn), 4, 4, DataLen / 16);

% Encode if the Command starts with 'e' or 'E', decode otherwise:
doEncode = strncmpi(Command, 'e', 1);

% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
% Initialize AES parameters, create CBC initial vector for encoding:
Param = Init(doEncode, DataIn, Key);

% Process the data:
if doEncode
   DataOut = EncodeI(DataIn, Param);
else
   DataOut = DecodeI(DataIn, Param);
end

Param.W(:) = 0;  % Clear secrets

return;

% ******************************************************************************
function DataOut = EncodeI(DataIn, Param)
% Encode [CBC_IV, encoded data in 16 byte blocks], INT method (Matlab 7)

mTab = Param.mTab;
SBox = Param.SBox;
W    = Param.W;

% Allocate output:
DataLen = numel(DataIn);
DataOut(DataLen + 16, 1) = uint8(0);

% Cyclical shift to the left:
cycleL = uint8([1, 5, 9, 13;  6, 10, 14, 2;  11, 15, 3, 7;  16, 4, 8, 12]);

q1 = uint8([9,  5,  5,  1]);
q2 = uint8([2, 10,  6,  6]);
q3 = uint8([7,  3, 11,  7]);
q4 = uint8([8,  8,  4, 12]);

% CBC IV as first block:
CBC           = uint16(Param.CBC);
DataOut(1:16) = CBC(:);
ind           = uint32(16);

for iBlock = 1:DataLen / 16
   % Copy 4x4 block from input data to the state matrix and apply the CBC mask:
   s = bitxor(bitxor(DataIn(:, :, iBlock), CBC), W(:, :, 1));
   
   for iRound = 2:10
      % Rotate to the left:
      s  = SBox(s(cycleL) + 1);
      s2 = s + s;
      
      % Mix columns:
      A = bitxor(s, s2);
      M = [bitxor(A, mTab(bitshift(A, -8) + 1)); ...
         s; bitxor(s2, mTab(bitshift(s, -7) + 1))];
      
      % New state matrix:
      s = bitxor( ...
         bitxor(bitxor(bitxor(M(q1, :), M(q2, :)), M(q3, :)), M(q4, :)), ...
         W(:, :, iRound));
   end  % for iRound
   
   % Encrypted data is new CBC mask:
   CBC = bitxor(SBox(s(cycleL) + 1), W(:, :, 11));
   ind = ind + 16;
   DataOut(ind - 15:ind) = CBC(:);
end  % for iBlock

CBC(:) = 0; A(:) = 0; M(:) = 0; s(:) = 0;  %#ok<NASGU>  % Clear secrets

return;

% ******************************************************************************
function DataOut = DecodeI(DataIn, Param)
% Decode [CBC_IV, encoded data in 16 byte blocks], INT method (Matlab 7)

mTab  = Param.mTab;
iSBox = Param.iSBox;
W     = Param.W;

% Allocate output:
DataLen = numel(DataIn);
DataOut(DataLen - 16, 1) = uint8(0);
ind     = uint32(0);

% Cyclical shift to the right:
cycleR = uint8([1, 5, 9, 13;  14, 2, 6, 10;  11, 15, 3, 7;  8, 12, 16, 4]);

q1 = uint8([13,  1,  9,  5]);
q2 = uint8([6,  14,  2, 10]);
q3 = uint8([4,   7, 15,  3]);
q4 = uint8([11, 12,  8, 16]);

% First block is the initial CBC:
CBC = DataIn(:, :, 1);

for iBlock = 2:DataLen / 16
   % Use encrypted data block as CBC value for the block:
   nCBC = DataIn(:, :, iBlock);
   s    = bitxor(nCBC, W(:, :, 11));
   
   for iRound = 10:-1:2
      % Rotate state matrix to the right:
      s = bitxor(iSBox(s(cycleR) + 1), W(:, :, iRound));
      
      % Inverse column mixing:
      s2 = s  + s;
      s4 = s2 + s2;
      s8 = s4 + s4;
      
      A = bitxor(s, s8);
      A = bitxor(A, mTab(bitshift(A, -8) + 1));
      B = bitxor(A, s2);
      B = bitxor(B, mTab(bitshift(B, -8) + 1));
      C = bitxor(A, s4);
      C = bitxor(C, mTab(bitshift(C, -8) + 1));
      D = bitxor(bitxor(s2, s4), s8);
      M = [A; B; C; bitxor(D, mTab(bitshift(D, -8) + 1))];
      
      % New state matrix:
      s = bitxor(bitxor(bitxor(M(q1, :), M(q2, :)), M(q3, :)), M(q4, :));
   end  % for iRound
   
   % Apply old CBC mask to decrypted data:
   s   = bitxor(bitxor(iSBox(s(cycleR) + 1), W(:, :, 1)), CBC);
   CBC = nCBC;
   ind = ind + 16;
   DataOut(ind - 15:ind) = s(:);  % Append to output
end  % for iBlock

CBC(:) = 0; nCBC(:) = 0; M(:) = 0; s(:) = 0;  %#ok<NASGU>  % Clear secrets
A(:) = 0; B(:) = 0; C(:) = 0; D(:) = 0;       %#ok<NASGU>  % Clear secrets

return;


% ******************************************************************************
function Param = Init(needCBC, DataIn, Key)
% Initialize parameters, create CBC IV

% Create the S-box and the inverse S-box:
SBox = uint16([ ...
   99,  124, 119, 123, 242, 107, 111, 197,  48,   1, 103,  43, ...
   254, 215, 171, 118, 202, 130, 201, 125, 250,  89,  71, 240, ...
   173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147,  38, ...
   54,   63, 247, 204,  52, 165, 229, 241, 113, 216,  49,  21, ...
   4,   199,  35, 195, 24,  150,   5, 154,   7,  18, 128, 226, ...
   235,  39, 178, 117,   9, 131,  44,  26,  27, 110,  90, 160, ...
   82,   59, 214, 179,  41, 227,  47, 132,  83, 209,  0,  237, ...
   32,  252, 177,  91, 106, 203, 190,  57,  74,  76,  88, 207, ...
   208, 239, 170, 251,  67,  77,  51, 133,  69, 249,   2, 127, ...
   80,  60,  159, 168,  81, 163,  64, 143, 146, 157,  56, 245, ...
   188, 182, 218,  33,  16, 255, 243, 210, 205,  12,  19, 236, ...
   95,  151,  68,  23, 196, 167, 126,  61, 100,  93,  25, 115, ...
   96,  129,  79, 220,  34,  42, 144, 136,  70, 238, 184,  20, ...
   222,  94,  11, 219, 224,  50,  58,  10,  73,   6,  36,  92, ...
   194, 211, 172,  98, 145, 149, 228, 121, 231, 200,  55, 109, ...
   141, 213,  78, 169, 108,  86, 244, 234, 101, 122, 174,   8, ...
   186, 120,  37,  46,  28, 166, 180, 198, 232, 221, 116,  31, ...
   75, 189, 139, 138,  112,  62, 181, 102,  72,   3, 246,  14, ...
   97,  53,  87, 185, 134,  193,  29, 158, 225, 248, 152,  17, ...
   105, 217, 142, 148, 155,  30, 135, 233, 206,  85,  40, 223, ...
   140, 161, 137,  13, 191, 230,  66, 104,  65, 153,  45,  15, ...
   176,  84, 187,  22]);

iSBox(SBox + 1) = uint16(0:255);

% Create table for column mixing:
mTab = uint16([ ...
   0,       283,   566,   813,  1132,  1399,  1626,  1857, ...
   2264,   2499,  2798,  3061,  3252,  3503,  3714,  3993, ...
   4528,   4267,  4998,  4765,  5596,  5319,  6122,  5873, ...
   6504,   6259,  7006,  6725,  7428,  7199,  7986,  7721, ...
   9056,   8827,  8534,  8269,  9996,  9751,  9530,  9249, ...
   11192, 10915, 10638, 10389, 12244, 11983, 11746, 11513, ...
   13008, 13259, 12518, 12797, 14012, 14247, 13450, 13713, ...
   14856, 15123, 14398, 14629, 15972, 16255, 15442, 15689, ...
   18112, 18395, 17654, 17901, 17068, 17335, 16538, 16769, ...
   19992, 20227, 19502, 19765, 19060, 19311, 18498, 18777, ...
   22384, 22123, 21830, 21597, 21276, 20999, 20778, 20529, ...
   24488, 24243, 23966, 23685, 23492, 23263, 23026, 22761, ...
   26016, 25787, 26518, 26253, 25036, 24791, 25594, 25313, ...
   28024, 27747, 28494, 28245, 26900, 26639, 27426, 27193, ...
   29712, 29963, 30246, 30525, 28796, 29031, 29258, 29521, ...
   31944, 32211, 32510, 32741, 30884, 31167, 31378, 31625, ...
   36224, 35995, 36790, 36525, 35308, 35063, 35802, 35521, ...
   34136, 33859, 34670, 34421, 33076, 32815, 33538, 33305, ...
   39984, 40235, 40454, 40733, 39004, 39239, 39530, 39793, ...
   38120, 38387, 38622, 38853, 36996, 37279, 37554, 37801, ...
   44768, 45051, 44246, 44493, 43660, 43927, 43194, 43425, ...
   42552, 42787, 41998, 42261, 41556, 41807, 41058, 41337, ...
   48976, 48715, 48486, 48253, 47932, 47655, 47370, 47121, ...
   46984, 46739, 46526, 46245, 46052, 45823, 45522, 45257, ...
   52032, 51803, 51574, 51309, 53036, 52791, 52506, 52225, ...
   50072, 49795, 49582, 49333, 51188, 50927, 50626, 50393, ...
   56048, 56299, 55494, 55773, 56988, 57223, 56490, 56753, ...
   53800, 54067, 53278, 53509, 54852, 55135, 54386, 54633, ...
   59424, 59707, 59926, 60173, 60492, 60759, 61050, 61281, ...
   57592, 57827, 58062, 58325, 58516, 58767, 59042, 59321, ...
   63888, 63627, 64422, 64189, 65020, 64743, 65482, 65233, ...
   61768, 61523, 62334, 62053, 62756, 62527, 63250, 62985]);

% Random initialization vector (encrypt it to encrease the entropy):
if needCBC
   % I do not trust the Matlab 6 RAND:
   cycleL = uint8([1, 5, 9, 13;  6, 10, 14, 2;  11, 15, 3, 7;  16, 4, 8, 12]);
   W      = uint16(floor(rand(4, 4, 11) * 256));
   s      = W(:, :, 1);
   tmp    = clock;
   s(1:4) = bitxor(s(1:4), ...
      uint16(floor(rem(tmp([4, 5, 6, 6]) .* [1, 1, 1, 1000], 256))));
   for iRound = 2:10
      s  = SBox(s(cycleL) + 1);
      s2 = s + s;
      A  = bitxor(s, s2);
      M  = [bitxor(A, mTab(bitshift(A, -8) + 1)); ...
             s; bitxor(s2, mTab(bitshift(s, -7) + 1))];
      s  = bitxor(W(:, :, iRound), ...
             bitxor(bitxor(bitxor(M([9, 5, 5, 1], :), M([2, 10, 6, 6], :)), ...
             M([7, 3, 11, 7], :)), M([8, 8, 4, 12], :)));
   end
   Param.CBC = bitxor(SBox(s(cycleL) + 1), W(:, :, 11));
else
   Param.CBC = reshape(DataIn(1:16), 4, 4);
end

Param.mTab  = mTab;
Param.SBox  = SBox;
Param.iSBox = iSBox;

% Expand/limit key to 16 characters: -------------------------------------------
% Here an AES encryption with a fixed cipher and random CBC is applied end the
% last 16 bytes are used as cipher. Usually this is done by MD5, but I want to
% avoid all external calls in this implementation.

% Use an arbitrary fixed cipher to encode the Key (the CBC is random for
% encoding and taken from the data for decoding):
Param.W = ExpandCipher(uint16([227, 199, 69, 241, 142, 36, 103, 246, ...
      114, 135, 224, 49, 19, 196, 99, 102]), Param);

KeyNum = uint8(Key);    % Limit the range of values to 0:255
KeyLen = numel(KeyNum);
if mod(KeyLen, 16)
   if KeyLen < 16
      KeyNum(16) = 0;
   else
      KeyNum((floor(KeyLen / 16) + 1) * 16) = 0;
   end
end
Cipher  = EncodeI(reshape(uint16(KeyNum), 4, 4, []), Param);
Param.W = ExpandCipher(Cipher(length(Cipher) - 15:length(Cipher)), Param);

% KAT test (known test data, from rfc3602):
% Param.CBC   = sscanf('c782dc4c098c66cbd9cd27d825682c81', '%2x');
% Cipher      = sscanf('6c3ea0477630ce21a2ce334aa746c2cd', '%2x');
% Param.W     = ExpandCipher(Cipher, Param);
% Plaintext   = 'This is a 48-byte message (exactly 3 AES blocks)'
% Cipthertext = sscanf(['d0a02b3836451753d493665d33f0e886', ...
%                       '2dea54cdb293abc7506939276772f8d5', ...
%                       '021c19216bad525c8579695d83ba2684'], '%2x');

return;


% ******************************************************************************
function W = ExpandCipher(Key, Param)
% Expand the 16-byte cipher to the 4x4x11 array

SBoxT     = Param.SBox(:);
rcon      = uint16([1, 2, 4, 8, 16, 32, 64, 128, 27, 54]);
W(4, 44)  = uint16(0);
W(:, 1:4) = reshape(Key, 4, 4);  % Copy 16 bytes column-wise

for i = 5:44   % Loop over remaining rows
   temp = W(:, i - 1);
   if rem(i, 4) == 1
      temp    = SBoxT(temp([2, 3, 4, 1]) + 1);
      temp(1) = bitxor(temp(1), rcon((i - 1) / 4));
   end
   W(:, i) = bitxor(W(:, i - 4), temp);
end

W = reshape(W, 4, 4, 11);

return;
