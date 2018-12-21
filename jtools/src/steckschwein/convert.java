/**
 * <p/>
 * Copyright: Copyright (c) 2009 Company: Dieter von Holtzbrinck Medien GmbH (DvH Medien)
 * <p/>
 */
package steckschwein;

import java.io.File;
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
public class convert {

   public static void main(String[] args) {
      for (Iterator<String> argIter = Arrays.asList(args).iterator(); argIter.hasNext();) {
         String arg = argIter.next();
         if ("-file".equals(arg)) {
            if (!argIter.hasNext()) {
               System.err.println("no file argument given!");
               return;
            }
            File file = new File(argIter.next());
            if (!file.exists() || !file.canRead()) {
               System.err.println("file '" + file + "' does not exist or is not accessible for reading!");
               return;
            }
         } else if ("-plugin".equals(arg)) {

         }
      }
   }
}
