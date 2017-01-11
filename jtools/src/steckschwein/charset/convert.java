package steckschwein.charset;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author marko.lauke
 *
 */
public class convert {

	public static void main(String[] args) throws IOException {

		File dir = new File("/development/steckschwein-code/charsets");
		File file = new File(dir, "char.ascii.6x8.v4.h.a");
		BufferedReader reader = new BufferedReader(new InputStreamReader(
				new FileInputStream(file)));
		Pattern p = Pattern.compile("!byte (0x[0-9a-f]{2},?){8}.*");
		String line;
		int chrn = 0;
		while ((line = reader.readLine()) != null) {
			Matcher matcher = p.matcher(line);
			if (!matcher.matches()) {
				System.err.println("invalid format in line '" + line + "'");
				System.exit(-1);
			}
			String hexDigits = line.substring(6, 6 + 5 * 8 - 1);
			String[] hexArr = hexDigits.split(",");
			short c = 0x80;
			short[] r = { 0, 0, 0, 0, 0, 0, 0, 0 };
			for (int i = 0; i < hexArr.length; i++) {
				short s = 0x01;
				short b = Short.decode(hexArr[i]);
				for (int x = 0; x < 7; x++) {
					if ((b & s) != 0) {
						r[x] |= c;
					}
					s <<= 1;
				}
				c >>= 1;
			}
			System.out.print("!byte ");
			for (int x = 0; x <= 7; x++) {
				System.out.print("0x"
						+ Integer.toHexString(r[x])
						+ (x < 7 ? "," : "; " + (chrn >= 32 ? (char) chrn : "")
								+ " (" + Integer.toHexString(chrn) + ")"));
			}
			System.out.println();
			chrn++;
		}
		reader.close();
	}
}
