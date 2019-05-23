function [B,G] = sgolay(order,frameLen,weights)
%SGOLAY Savitzky-Golay Filter Design.
%   B = SGOLAY(ORDER,FRAMELEN) designs a Savitzky-Golay (polynomial) FIR
%   smoothing filter B.  The polynomial order, ORDER, must be less than the
%   frame length, FRAMELEN, and FRAMELEN must be odd.
%
%   Note that if the polynomial order ORDER equals FRAMELEN-1, no smoothing
%   will occur.
%
%   SGOLAY(ORDER,FRAMELEN,WEIGHTS) specifies a weighting vector, WEIGHTS,
%   of length FRAMELEN containing real, positive valued weights employed
%   during the least-squares minimization.
%
%   [B,G] = SGOLAY(...) returns the matrix G of differentiation filters.
%   Each column of G is a differentiation filter for derivatives of order
%   P-1 where P is the column index.  Given a length FRAMELEN signal X, an
%   estimate of the P-th order derivative of its middle value can be found
%   from:
%
%                     ^(P)
%                     X((FRAMELEN+1)/2) = P!*G(:,P+1)'*X
%
%   % Example 1:
%   %   Use sgolay to smooth a noisy sinusoid via a fourth order polynomial
%   %   and a frame length of 21 samples.
%   order = 4;
%   framelen = 21;
%   b = sgolay(order,framelen);
%   t = (0:0.2:200-1)';
%   x = 5*sin(2*pi*0.2*t)+randn(size(t));
%   ybegin = b(end:-1:(framelen+3)/2,:) * x(framelen:-1:1);
%   ycenter = conv(x,b((framelen+1)/2,:),'valid');
%   yend = b((framelen-1)/2:-1:1,:) * x(end:-1:end-(framelen-1));
%   y = [ybegin; ycenter; yend];
%   plot([x y]);
%   legend('Noisy Sinusoid','S-G smoothed sinusoid')
%
%   % Example 2:
%   %   Use sgolay to smooth a noisy sinusoid and find its first three
%   %   derivatives via a fifth order polynomial and a frame length of
%   %   25 samples.
%   [~,g] = sgolay(5,25);
%   dt = 0.25;
%   t = (0:dt:20-1)';
%   x = 5*sin(2*pi*0.2*t)+0.5*randn(size(t));
%   dx = zeros(length(x),4);
%   for p=0:3
%     dx(:,p+1) = conv(x, factorial(p)/(-dt)^p * g(:,p+1), 'same');
%   end
%   plot([x dx]);
%   legend('x','x (smoothed)','x'' (smoothed)','x'''' (smoothed)', 'x'''''' (smoothed)');
%   title('Derivative Computation via Savitzky-Golay');
%
%   See also SGOLAYFILT, FIR1, FIRLS, FILTER

%   References:
%     [1] Sophocles J. Orfanidis, INTRODUCTION TO SIGNAL PROCESSING,
%              Prentice-Hall, 1995, Chapter 8

%   Copyright 1988-2016 The MathWorks, Inc.

narginchk(2,3);
% Cast to enforce Precision Rules
% order = signal.internal.sigcasttofloat(order,'double','sgolay',...
%   'ORDER','allownumeric');
% frameLen = signal.internal.sigcasttofloat(frameLen,'double','sgolay',...
%   'FRAMELEN','allownumeric');

% Check if the input arguments are valid
if round(frameLen) ~= frameLen
  error(message('signal:sgolay:FrameMustBeInteger'))
end
if rem(frameLen,2) ~= 1
 error(message('signal:sgolay:InvalidDimensions'))
end
if round(order) ~= order
  error(message('signal:sgolay:DegreeMustBeInteger'))
end
if order > frameLen-1
  error(message('signal:sgolay:DegreeGeLength'))
end
if nargin < 3
   weights = [];
elseif ~isempty(weights)
   % Cast to enforce Precision Rules
   weights = signal.internal.sigcasttofloat(weights,'double','sgolay','W',...
     'allownumeric');
   % Check WEIGHTS is real.
   if ~isreal(weights)
     error(message('signal:sgolay:NotReal'))
   end
   % Check for right length of W
   if length(weights) ~= frameLen
     error(message('signal:sgolay:MismatchedDimensions'))
   end
   % Check to see if all elements are positive
   if min(weights) <= 0
     error(message('signal:sgolay:WVMustBePos'))
   end
end

% Compute the Vandermonde matrix
S = (-(frameLen-1)/2:(frameLen-1)/2)' .^ (0:order);

if isempty(weights)
  % Compute QR decomposition
  [Q,R] = qr(S,0);
  
  % Compute the projection matrix B
  B = Q*Q';
  
  if nargout==2
    % Find the matrix of differentiators
    G = Q/R';
  end
  
else
  % Compute QR decomposition with optional weight
  [~,R] = qr(sqrt(weights(:)).*S,0);
  
  % Compute the projection matrix B
  if nargout==2
    % Find the matrix of differentiators
    G = S/(R'*R);
    
    % Compute the projection matrix B
    B = G*S';
  else
    % Compute the projection matrix B
    T = S/R;
    B = T*T';
  end
  
  B = weights(:)'.*B;
end
