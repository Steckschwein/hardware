package com.twomla.steckschwein;

import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import javax.imageio.ImageIO;
import javax.swing.ButtonGroup;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;

/**
 * <p/>
 * Copyright: Copyright (c) 2009-2014 Company: circIT GmbH & Co. KG
 * <p/>
 * 
 * @author <a href="mailto:m.lauke@web.de">Marko Lauke</a>
 * 
 */
public class Jpeg2Vdp extends JFrame {

   private static final byte transparent = 0;
   private static final byte white = 15;
   private static final byte black = 0;
   private static final byte bit_set_color = black;

   public static void main(String[] args) {
      Jpeg2Vdp jpeg2Vdp = new Jpeg2Vdp();
      jpeg2Vdp.start();
   }

   private JLabel imageCanvas;
   private BufferedImage mImage;
   private File mSelectedFile;

   void loadFile() {
      File selectedFile = chooseFile();
      if (selectedFile != null) {
         try {
            mSelectedFile = selectedFile;
            URL fileUrl = selectedFile.toURI().toURL();
            mImage = ImageIO.read(fileUrl);
            imageCanvas.setIcon(new ImageIcon(mImage));
            pack();
         } catch (MalformedURLException e) {
            e.printStackTrace();
         } catch (IOException e) {
            e.printStackTrace();
         }
      }
   }

   void saveFile() {
      if (mImage != null) {
         int w = mImage.getWidth();
         int h = mImage.getHeight();
         if (mSelectedFile != null) {
            int[] rgbArray = mImage.getRGB(0, 0, w, h, null, 0, w);
            byte[][] output = gfx_2_bm(rgbArray, w, h);
            try {
               FileOutputStream outputStream = new FileOutputStream(mSelectedFile + ".raw");
               for (int y = 0, n = output.length; y < n; y++) {
                  outputStream.write(output[y]);
               }
               outputStream.flush();
               outputStream.close();
            } catch (FileNotFoundException e) {
               e.printStackTrace();
            } catch (IOException e) {
               e.printStackTrace();
            }
         }
      }
   }

   static byte[][] gfx_2_bm(int[] pRgbArray, int w, int h) {
      byte[][] output = new byte[192][32];
      for (int y = 0; y < 192; y++) {
         for (int x = 0; x < 256; x++) {
            byte color = transparent;
            if (x < w && y < h) {
               int off = y * w + x;
               color = getColor(pRgbArray[off]);
            }
            int bit = (color == bit_set_color ? 0x80 : 0);
            output[y][x / 8] |= (bit >>> (x % 8));
            System.out.println(color);
         }
      }
      return output;
   }

   private static byte getColor(int pRgb) {
      int red = (pRgb >> 16) & 0xff;
      int green = (pRgb >> 8) & 0xff;
      int blue = (pRgb) & 0xff;
      for (byte i = 0, n = (byte) tms9929ColorMap.length; i < n; i++) {
         short[] rgb = tms9929ColorMap[i];
         if (rgb[0] == red && rgb[1] == green && rgb[2] == blue) {
            return i;
         }
      }
      return 0;
   }

   static short[][] tms9929ColorMap = { { 0, 0, 0 },//
         { 0, 0, 0 },//
         { 35, 203, 50 },//
         { 96, 221, 108 },//
         { 84, 78, 255 },//
         { 125, 112, 255 },//
         { 210, 84, 66 },//
         { 69, 232, 255 },//
         { 250, 89, 72 },//
         { 255, 124, 108 },//
         { 211, 198, 60 },//
         { 229, 210, 109 },//
         { 35, 178, 44 },//
         { 200, 90, 198 },//
         { 204, 204, 204 },//
         { 255, 255, 255 } //
   };

   File chooseFile() {
      File selectedFile = null;
      JFileChooser chooser = new JFileChooser(new File("."));
      int returnVal = chooser.showOpenDialog(this);
      if (returnVal == JFileChooser.APPROVE_OPTION) {
         selectedFile = chooser.getSelectedFile();
         return (selectedFile != null && selectedFile.canRead() ? selectedFile : null);
      }
      return selectedFile;
   }

   public void printPixelARGB(int pixel) {
      int alpha = (pixel >> 24) & 0xff;
      int red = (pixel >> 16) & 0xff;
      int green = (pixel >> 8) & 0xff;
      int blue = (pixel) & 0xff;
      System.out.println("argb: " + alpha + ", " + red + ", " + green + ", " + blue);
   }

   private void start() {
      JPanel panel = new JPanel();
      panel.setLayout(new GridLayout(4, 1));

      JButton openfileButton = new JButton("open file...");
      openfileButton.addActionListener(new ActionListener() {

         @Override
         public void actionPerformed(ActionEvent pE) {
            loadFile();
         }
      });
      JButton saveFileButton = new JButton("save file");
      saveFileButton.addActionListener(new ActionListener() {

         @Override
         public void actionPerformed(ActionEvent pE) {
            saveFile();
         }
      });
      panel.add(openfileButton);
      panel.add(saveFileButton);

      JPanel gfxModePanel = new JPanel();
      panel.add(gfxModePanel);
      ButtonGroup group = new ButtonGroup();
      JRadioButton gfx_1_bm = new JRadioButton("Graphic II Mode (Bitmap 256x192)", true);
      group.add(gfx_1_bm);
      gfxModePanel.add(gfx_1_bm);
      JRadioButton gfx_mc = new JRadioButton("Multicolor Mode (4x4px 15 colors)", true);
      group.add(gfx_mc);
      gfxModePanel.add(gfx_mc);
      panel.add(gfxModePanel);

      imageCanvas = new JLabel("Bild");
      panel.add(imageCanvas);

      getContentPane().add(panel);
      setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
      setSize(640, 320);
      pack();
      setVisible(true);
   }
}