package ec.com.appdfm.sync;

enum Bom {
    NONE(new byte[0]),
    UTF8(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF}),
    UTF16_LE(new byte[]{(byte) 0xFF, (byte) 0xFE}),
    UTF16_BE(new byte[]{(byte) 0xFE, (byte) 0xFF});

    private final byte[] bytes;

    Bom(byte[] bytes) {
        this.bytes = bytes;
    }

    byte[] bytes() {
        return bytes.clone();
    }
}
