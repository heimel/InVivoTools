global squirrel_white squirrel_blue_plus squirrel_blue_minus 
global squirrel_green_plus squirrel_green_minus squirrel_blue_equal
global squirrel_green_equal

squirrel_blue_plus =255*[0      0       1      ]'; % cone act. : 8.0914, 5.1492
squirrel_blue_minus=255*[0.9720 0       0      ]'; % cone act. : 0.2077, 5.1493
%max blue contrast, 0.9499

squirrel_green_plus  =255* [1      1    0      ]'; % cone act. : 1.9386,22.1422
squirrel_green_minus =255* [0      0    0.2396 ]'; % cone act. : 1.9387, 1.2337
%max green contrast, 0.8944

squirrel_blue_equal  =255* [0      0       1   ]'; % cone act. : 8.0914, 5.1492
squirrel_green_equal =255* [1      0.4162  0   ]'; % cone act. : 0.9317,12.3089

squirrel_white       =255* [1      1       0.68]'; % cone act. : 7.4407,25.6437

% Cone isolating stimuli including rods
%                                                       B       G        R
squirrel_rod_plus = fix(255*[0 0.1836    0.])'; % act: 0.0010  0.0136 0.0033
squirrel_rod_minus= fix(255*[1 0     0.0089])'; % act: 0.0010  0.0136 0.0095
% contrast 0.4881

squirrel_m_plus  = fix(255*[1 0          0])'; % act: 0.0008  0.0135 0.0030
squirrel_m_minus =fix(255*[0 0.0454 0.0174])'; % act: 0.0008  0.0037 0.0030
% contrast 0.5686

squirrel_s_plus   = fix(255*[1 0        0.2969])'; % act: 0.0097  0.0191 0.0134
squirrel_s_minus  = fix(255*[0 0.2578   0     ])'; % act: 0.0015  0.0191 0.0134
% contrast 0.7360

squirrel_white = round(squirrel_white);
squirrel_green_plus = round(squirrel_green_plus);
squirrel_green_minus= round(squirrel_green_minus);
squirrel_blue_plus  = round(squirrel_blue_plus);
squirrel_blue_minus = round(squirrel_blue_minus);
squirrel_blue_equal = round(squirrel_blue_equal);
squirrel_green_equal = round(squirrel_green_equal);
