package steckschwein.nixie;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * @author marko.lauke
 *
 */
public class reorggfx {

	public static void main(String[] args) throws IOException {
		if (args.length <= 0) {
			System.err.println("base file name required!");
			System.exit(0);
		}
		String baseName = args[0];
		File tiap = new File(baseName + ".tiap");
		File tiac = new File(baseName + ".tiac");
		checkAccess(tiap);
		checkAccess(tiac);

		byte[] patterns = reorg(tiap);
		byte[] colors = reorg(tiac);

		File tiapReorg = new File(baseName + ".reorg.tiap");
		File tiacReorg = new File(baseName + ".reorg.tiac");
		write(tiapReorg, patterns);
		write(tiacReorg, colors);
	}

	private static void write(File f, byte[] ba) throws IOException {
		FileOutputStream fOut = new FileOutputStream(f);
		fOut.write(ba);
		fOut.close();
	}

	private static byte[] reorg(File f) throws IOException {
		byte[] inb = toByteArray(f);
		// 8 byte per pattern, 5 pattern per digit line, 9 lines per digit, 10 digits overall (0..9)
		// 2048 per bank, 1st bank 5 rows with digit lines + 8byte blank, 2nd bank 4 rows with digit lines + 8byte blank
		byte[] b = new byte[4096];// (8 * 5 * 9 * 10) + (2 * 8)];// 3616

		int ix = 0;
		// 1st bank = 8*5*5*10 = 2000 byte + 8byte blank
		ix = reorgBank(inb, b, ix, 0, 5);
		ix = fill(b, ix, 2048);
		// 2nd bank = 8*5*4*10 = 1600 byte + 8byte blank
		ix = reorgBank(inb, b, ix, 5, 4);
		fill(b, ix, 4096);
		return b;
	}

	private static int fill(byte[] b, int ix, int i) {
		while (ix < i) {
			b[ix++] = 0;// blank
		}
		return ix;
	}

	private static int reorgBank(byte[] inb, byte[] b, int ix, int startRow, int rows) {
		int bytesPerLine = 32 * 8;
		int zero2fiveOffs = 0;
		int six2NineOffs = bytesPerLine * 9;
		for (int i = startRow; i < (startRow + rows); i++) {
			int offs = zero2fiveOffs + (i * bytesPerLine); // 0-5
			ix = cut(inb, offs, 5 * 8 * 6, b, ix);
			offs = six2NineOffs + (i * bytesPerLine);// 6-9
			ix = cut(inb, offs, 5 * 8 * 4, b, ix);
		}
		for (int i = 0; i < 7; i++)
			b[ix++] = 0;// blank

		return ix;
	}

	// private static int reorgBank(byte[] inb, byte[] b, int ix, int startRow, int rows) {
	// int bytesPerLine = 32 * 8;
	// int zeroOffs = (5 * 8 * 6 + 2 * 8) * 9 + 5 * 8 * 3;
	// int one2sixOffs = 0;
	// int seven29Offs = (5 * 8 * 6 + 2 * 8) * 9;
	// for (int i = startRow; i < (startRow + rows); i++) {
	// int offs = zeroOffs + (i * bytesPerLine); // zero
	// ix = cut(inb, offs, 5 * 8 * 1, b, ix);
	// offs = one2sixOffs + (i * bytesPerLine); // 1-6
	// ix = cut(inb, offs, 5 * 8 * 6, b, ix);
	// offs = seven29Offs + (i * bytesPerLine);// 7-9
	// ix = cut(inb, offs, 5 * 8 * 3, b, ix);
	// }
	// for (int i = 0; i < 7; i++)
	// b[ix++] = 0;// blank
	//
	// return ix;
	// }

	private static int cut(byte[] inb, int offs, int l, byte[] b, int ix) {
		for (int i = 0; i < l; i++) {
			b[ix++] = inb[offs + i];
		}
		return ix;
	}

	private static byte[] toByteArray(File f) throws FileNotFoundException, IOException {
		FileInputStream fin = new FileInputStream(f);
		int l = fin.available();
		byte[] inb = new byte[l];
		fin.read(inb);
		fin.close();
		return inb;
	}

	private static void checkAccess(File f) {
		if (!f.exists() || !f.canRead()) {
			System.err.println("file does not exist or is not accessible for reading!");
			System.exit(0);
		}
	}
}
