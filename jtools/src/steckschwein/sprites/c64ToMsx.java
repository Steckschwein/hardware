/**
 * <p/>
 * Copyright: Copyright (c) 2009 Company: Dieter von Holtzbrinck Medien GmbH (DvH Medien)
 * <p/>
 */
package steckschwein.sprites;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Iterator;

/**
 * <p/>
 * Copyright: Copyright (c) 2009 Company: Dieter von Holtzbrinck Medien GmbH (DvH Medien)
 * <p/>
 *
 * @author <a href="mailto:m.lauke@web.de">Marko Lauke</a>
 *
 */
public class c64ToMsx {

   private static final int C64_SPRITE_SIZE = 64;

   public static void main(String[] args) throws IOException {
      File file = null;
      int n = 0;
      boolean mc = false;
      int count = 1;
      for (Iterator<String> argIter = Arrays.asList(args).iterator(); argIter.hasNext();) {
         String arg = argIter.next();
         if ("-f".equals(arg)) {
            if (!argIter.hasNext()) {
               System.err.println("no -file argument given!");
               return;
            }
            file = new File(argIter.next());
            if (!file.exists() || !file.canRead()) {
               System.err.println("file '" + file + "' does not exist or is not accessible for reading!");
               return;
            }
         } else if ("-n".equals(arg)) {
            if (!argIter.hasNext()) {
               System.err.println("no -nr argument given!");
               return;
            }
            n = Integer.parseInt(argIter.next());
         } else if ("-mc".equals(arg)) {
            mc = true;
         } else if ("-c".equals(arg)) {
            if (!argIter.hasNext()) {
               System.err.println("no -c argument given!");
               return;
            }
            count = Integer.parseInt(argIter.next());
         }
      }
      if (file == null) {
         System.err.println("too few arguments!");
         return;
      }
      InputStream is = new FileInputStream(file);
      is.skip(n * C64_SPRITE_SIZE);

      if (mc) {
         for (int i = 1; i <= count; i++) {
            byte[] sprite = readSprite(is);
            dump(sprite);
         }
      } else {

      }
      is.close();

   }

   private static void dump(byte[] pSprite) {
      for (int i = 0; i < 63; i += 3) {
         System.out.println(_8bit(pSprite[0 + i]) + _8bit(pSprite[1 + i]) + _8bit(pSprite[2 + i]));
      }
   }

   private static String _8bit(byte pB) {
      String _8bitString = String.format("%8s", Integer.toBinaryString(pB & 0xff)).replace(' ', '0').replace('1', '#').replace('0', '.');
      return _8bitString;
   }

   private static byte[] readSprite(InputStream pIs) throws IOException {
      byte[] data = new byte[C64_SPRITE_SIZE];
      int r = pIs.read(data);
      if (r != C64_SPRITE_SIZE) {
         throw new IOException("could not read " + C64_SPRITE_SIZE + "byte data! (was: " + r + ")");
      }
      return data;
   }
}
