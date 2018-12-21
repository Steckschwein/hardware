package steckschwein.ppm;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;

/**
 * @author marko.lauke
 *
 */
public class ppm2raw {

   static class PpmImage {
      int width;
      int height;
      int depth;

      int[][] imageData;

      public PpmImage(int width2, int height2, int colors) {
         width = width2;
         height = height2;
         depth = colors;
         int rgb_f = 3 * (colors > 255 ? 2 : 1);
         imageData = new int[height][width * rgb_f];
      }

      @Override
      public String toString() {
         return "PpmImage [width=" + width + ", height=" + height + ", depth=" + depth + "]";
      }
   }

   public static final void main(String[] args) throws IOException {

      if (args.length < 1) {
         System.err.println("ppm file not given!");
         return;
      }

      File file = new File(args[0]);
      if (!file.exists() || !file.canRead()) {
         System.err.println("ppm file '" + file + "' does not exist or is not accessible for reading!");
         return;
      }
      InputStream s = new FileInputStream(file);
      PpmImage ppmImage = parsePpmImage(s);

      File rawFile = new File(file.getParentFile(), file.getName() + ".raw");
      toV9958RawImage(ppmImage, rawFile);

   }

   private static void toV9958RawImage(PpmImage ppmImage, File rawFile) throws IOException {
      int[] rgb = new int[3];
      FileOutputStream fOut = new FileOutputStream(rawFile);
      for (int y = 0; y < ppmImage.height; y++) {
         for (int x = 0; x < ppmImage.width; x++) {
            System.arraycopy(ppmImage.imageData[y], x * 3, rgb, 0, 3);
            int r = rgb[0];
            int g = rgb[1];
            int b = rgb[2];
            int grb_332 = (g & 0xe0) | ((r & 0xe0) >> 3) | ((b & 0xe0) >> 6);
            fOut.write(grb_332);
         }
      }

      fOut.close();
   }

   private static PpmImage parsePpmImage(InputStream stream) throws IOException {
      String identifier = parseString(stream);

      if (!"P6".equals(identifier)) {
         System.err.println("unknown ppm image format!");
         return null;
      }
      int width = parseInt(parseString(stream));
      int height = parseInt(parseString(stream));
      int colors = parseInt(parseString(stream));

      PpmImage ppmImage = new PpmImage(width, height, colors);

      int x = 0, y = 0;
      int rgbByteCount = (ppmImage.depth > 255 ? 2 : 1) * 3;// 8 or 16bpp * 3 (RGB)
      byte[] rgb = new byte[rgbByteCount];
      try {
         while (stream.read(rgb) != -1) {
            ppmImage.imageData[y][x * rgbByteCount + 0] = rgb[0];
            ppmImage.imageData[y][x * rgbByteCount + 1] = rgb[1];
            ppmImage.imageData[y][x * rgbByteCount + 2] = rgb[2];
            if (rgbByteCount == 6) {// TODO support 16bit ppm
            }
            x++;
            if (x == ppmImage.width) {
               x = 0;
               y++;
            }
         }
      } catch (Exception e) {
         e.printStackTrace();
         System.err.println("x:" + x + " y:" + y + "");
      } finally {
         stream.close();
      }

      return ppmImage;
   }

   private static int parseInt(String readString) {
      try {
         return Integer.parseInt(readString);
      } catch (NumberFormatException e) {
         System.err.println("invalid value '" + readString + "', could not parse to numeric value!");
         throw e;
      }
   }

   static byte[] whitespaces = { ' ', '\t', '\n', '\r' };

   private static String parseString(InputStream stream) throws IOException {
      ByteBuffer allocate = ByteBuffer.allocate(8);
      int r;
      while ((r = stream.read()) != -1) {
         if (isWhitespace(r))
            break;
         allocate.put((byte) (r & 0xff));
      }
      byte[] array = allocate.array();
      return new String(array, 0, allocate.position());
   }

   private static boolean isWhitespace(int r) {
      for (byte b : whitespaces) {
         if (b == (r & 0xff))
            return true;
      }
      return false;
   }

}
