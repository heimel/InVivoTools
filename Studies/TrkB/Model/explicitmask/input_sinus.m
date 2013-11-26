function input=input_sinus(t,c)


level=lgncontrast(c);
input=level*double(t>50&t<150).*sin((t-50)*pi/100);


