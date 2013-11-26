function mouse_photoreceptors
%MOUSE_PHOTORECEPTORS produces graph with photoreceptor monograms
%
%  cones: ref. Jacobs et al. 2004
%  cones + rod: ref. Lyubarsky et al. 1999
%     in the latter are also equations for more precise graphs

  
  
  figure
  
  [l_UV,s_UV]=nomogram(360);
  [l_M,s_M]=nomogram(510.5);
  [l_ME,s_ME]=nomogram(479);
  [l_Rod,s_Rod]=nomogram(498);


  
  plot(s_UV,l_UV,'b');
  hold on
  plot(s_M,l_M,'g');
  plot(s_Rod,l_Rod,'k');
  plot(s_ME,l_ME,'r:');
  
  grid on
  
  
  legend('UV','M','Rod','Melanopsin')
  
  bigger_linewidth(2)
  smaller_font(-5)
  title('Mouse photoreceptor sensitivities')
