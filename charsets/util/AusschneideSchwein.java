import java.awt.image.BufferedImage;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

/**
 * <p/>
 * Copyright: Copyright (c) 2009-2015 Company: Dieter von Holtzbrinck Medien GmbH (DvH Medien)
 * <p/>
 * 
 * @author <a href="mailto:m.lauke@web.de">Marko Lauke</a>
 *
 */
public class AusschneideSchwein {

   public static void main(String[] args) throws IOException {
      if (args.length < 1) {
         System.err.println("nich so...!");
         System.exit(-1);
      }
      File fontFile = new File(args[0]);
      if (!fontFile.exists() || !fontFile.canRead()) {
         System.err.println("geht nicht '" + fontFile + "'!");
         System.exit(-1);
      }
      BufferedImage fontImage = ImageIO.read(fontFile);
      int w = fontImage.getWidth();
      int h = fontImage.getHeight();
      int[] geometrie = { 8, 8 };
      DataBuffer db = fontImage.getRaster().getDataBuffer();
      int imgType = fontImage.getType();
      switch (imgType) {
         case BufferedImage.TYPE_BYTE_BINARY:
            byte[] bytes = ((DataBufferByte) db).getData();
            bytes = blowup6x8(bytes, w, h, geometrie);
            w = w / 6 * 8;// new width after blow up
            printBlackAndWhiteImage8x8(bytes, w, geometrie, false);
            break;
         default:
            System.err.println("cannot handle....");
            break;
      }
   }

   static byte[] blowup6x8(byte[] bytes, int w, int h, int[] geo) {
      int newSize = bytes.length / 6 * 8;
      byte[] newBytes = new byte[newSize];
      for (int i = 0, j = 0; i < bytes.length; i += 3, j += 4) {
         long v = (bytes[i] << 16 & 0xff0000) | (bytes[i + 1] << 8 & 0xff00) | (bytes[i + 2] & 0xff);
         byte b1 = (byte) (v >> 16 & 0xfc);
         byte b2 = (byte) (v >> 10 & 0xfc);
         byte b3 = (byte) (v >> 4 & 0xfc);
         byte b4 = (byte) (v << 2 & 0xfc);
         newBytes[j] = b1;
         newBytes[j + 1] = b2;
         newBytes[j + 2] = b3;
         newBytes[j + 3] = b4;
      }
      return newBytes;
   }

   static void printBlackAndWhiteImage8x8(byte[] bytes, int w, int[] geo, boolean inverse) {
      short mask = 0xff;// 6px TODO FIXME
      int bytesPerRow = (w / 8);
      int[] row = new int[8];
      for (int x = 0; x < bytes.length; x++) {
         if (x % 8 == 0)
            System.out.print("!byte ");
         int xy = ((x / w) * w) + (x % geo[1] * bytesPerRow) + (x / geo[1] % bytesPerRow);
         int v = (bytes[xy] & mask);
         v = (inverse ? 255 - v : v);
         System.out.print("$" + Integer.toHexString(v));
         row[x % 8] = v;
         if (x % 8 == 7) {
            System.out.println("; code 0x"+Integer.toHexString((x/8)));
            for (int l : row) {
               System.out.print(";");
               for (int b = 7; b >= 0; b--)
                  System.out.print((l & 1 << b) == 0 ? "." : "#");
               System.out.println();
            }
         } else
            System.out.print(", ");
      }
   }
}