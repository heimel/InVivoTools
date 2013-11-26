function input=normmodelinput(t,contrast)


input=contrast*double(t>50&t<150).*sin((t-50)*pi/100).^5;


