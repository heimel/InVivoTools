function input=markinput(t,contrast)


input=contrast*double(t>50&t<150);
%input=contrast*double(t>50&t<70);

