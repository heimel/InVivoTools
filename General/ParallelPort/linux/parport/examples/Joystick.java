import parport.ParallelPort;

class Joystick {
   /** This is a simple digital joystick connected to the LPT1 parallel port
     * with base address 0x378. This example is described with lots of details
     * at: http://www.doc.ic.ac.uk/~ih/doc/joystick/
     *
   */

   public static void main ( String []args )
   {
      System.out.println("find details about this joystick at: http://www.doc.ic.ac.uk/~ih/doc/joystick/\n");
      System.out.println("Ian\'s Parallel Port JoyStick Reader");
      System.out.println("===================================\n");
      System.out.println("<Centre + Button> to Quit\n");

      int BS = 8; // ASCII BackSpace
      int JShigh=0, JSlow=0, i, oldbyte, newbyte;
      ParallelPort lpt1 = new ParallelPort(0x378);

      lpt1.write(0xF8); // output TTL High on enable lines
      oldbyte = 0xFF;
      do
      {
         newbyte = lpt1.read();
         if (newbyte != oldbyte) 
         {
            // new joystick status
            oldbyte = newbyte;
            for (i=0;i<20;i++)
            {
                // clear the previous status report on the screen
                System.out.print((char)BS + " " + (char)BS);
            }

            JSlow  = (newbyte & 0x0F) >>> 3; // Button Signal
            JShigh = (newbyte ^ 0x80) >>> 4; // Direction Signal

            switch (JShigh)
            {
               case 0 : System.out.print("Centre"); break;
               case 1 : System.out.print("North"); break;
               case 2 : System.out.print("South"); break;
               case 4 : System.out.print("East"); break;
               case 5 : System.out.print("NorthEast"); break;
               case 6 : System.out.print("SouthEast"); break;
               case 8 : System.out.print("West"); break;
               case 9 : System.out.print("NorthWest"); break;
               case 10 : System.out.print("SouthWest"); break;
            }

            if (JSlow == 1)
               System.out.print(" + Button");
         }
      }
      while( ! ((JSlow == 1) && (JShigh == 0)) ); // Centre and button to quit
      System.out.println("Goodbye!");
   }
}
