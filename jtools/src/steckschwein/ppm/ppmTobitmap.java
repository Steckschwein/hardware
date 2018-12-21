package steckschwein.ppm;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * @author marko.lauke
 *
 */
public class ppmTobitmap {

	static Map<String, Byte> vdpColorMap = new HashMap<String, Byte>();
	static {
		putColor(vdpColorMap, "None", 0);
		putColor(vdpColorMap, "#000000", 1);
		putColor(vdpColorMap, "#23CB32", 2);
		putColor(vdpColorMap, "#60DD6C", 3);
		putColor(vdpColorMap, "#544EFF", 4);
		putColor(vdpColorMap, "#7D70FF", 5);
		putColor(vdpColorMap, "#D25442", 6);
		putColor(vdpColorMap, "#45EBFF", 7);
		putColor(vdpColorMap, "#FA5948", 8);
		putColor(vdpColorMap, "#FF7C6C", 9);
		putColor(vdpColorMap, "#D3C63C", 0xa);
		putColor(vdpColorMap, "#E5D26D", 0xb);
		putColor(vdpColorMap, "#23B22C", 0x0c);
		putColor(vdpColorMap, "#C85AC6", 0x0d);
		putColor(vdpColorMap, "#CCCCCC", 0x0e);
		putColor(vdpColorMap, "#FFFFFF", 0x0f);
	}

	public static void main(String[] args) throws IOException {

		if (args.length < 1) {
			System.err.println("ppm file not given!");
			return;
		}

		File file = new File(args[0]);
		if (!file.exists() || !file.canRead()) {
			System.err.println("ppm file '" + file
					+ "' does not exist or is not accessible for reading!");
			return;
		}
		BufferedReader reader = new BufferedReader(new InputStreamReader(
				new FileInputStream(file)));
		String[] ppmHeader;
		String[] ppmData;

		String line = nextLine(reader);
		if (line == null || !line.startsWith("P3")) {
			System.err.println("unknown ppm image format!");
			return;
		}
		String header = skipComments(reader);
		String[] headerArr = header.split("\\s");
		if (headerArr.length < 2) {
			System.err.println("error in ppm file, invalid header '" + header
					+ "' given!");
		}
		int width = toInt(headerArr[0]);
		int height = toInt(headerArr[1]);

		if (width % 8 != 0) {
			System.err
					.println("invalid width, must be multiple of 8px, but was "
							+ width + "!");
			return;
		}

		line = nextLine(reader);
		int maxColors = toInt(line);
		int row = 0;
		Pattern p = Pattern.compile(" ");
		byte[] rawData = new byte[width * height];
		int n = 0;
		while ((line = nextLine(reader)) != null) {
			String[] colorArr = p.split(line);
			if (colorArr.length % 3 != 0) {
				System.err.println("invalid data length in row " + row + ", !");
				return;
			}
			for (int i = 0; i < colorArr.length; i += 3) {
				String code = toColorCode(colorArr, i);
				Byte vdpColor = toVdpColor(code);
				if (vdpColor == null) {
					System.err.println("unknown vdp color for code '" + code
							+ "' in row " + row + "!");
					return;
				}
				rawData[n++] = vdpColor;
			}
			row++;
		}

		// 40x72 one digit
		int figureX = 40;
		int figureY = 72;
		byte[] vdpBitmapData = new byte[width / 8 * height];
		l1: for (int i = 0; i < rawData.length; i += 8) {
			byte[] bytes = new byte[7];
			for (int j = 0; j < 7; j++) {
				bytes[j] = rawData[i + j];
			}
			break l1;
			// int x = (i)

			// vdpBitmapData[x+y] =

		}
	}

	private static Byte toVdpColor(String code) {
		Byte vdpColor = vdpColorMap.get(code);
		return vdpColor;
	}

	private static String toColorCode(String[] colorArr, int i) {
		String code = String.format("#%02X%02X%02X",//
				toInt(colorArr[i + 0]),//
				toInt(colorArr[i + 1]),//
				toInt(colorArr[i + 2]));
		return code;
	}

	private static String skipComments(BufferedReader reader)
			throws IOException {
		String line;
		while ((line = nextLine(reader)) != null && line.startsWith("#"))
			;
		return line;
	}

	private static void putColor(Map<String, Byte> colorMap, String string,
			int i) {
		colorMap.put(string, (byte) i);
	}

	private static String nextLine(BufferedReader reader) throws IOException {
		String line = reader.readLine();
		return line;
	}

	private static void skip(BufferedReader reader, int i) throws IOException {
		for (int n = 0; n < i; n++)
			reader.readLine();
	}

	private static int toInt(String string) {
		return Integer.valueOf(string);
	}
}
