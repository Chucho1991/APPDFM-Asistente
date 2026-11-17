package ec.com.appdfm.sync;

import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

@Component
class TextFileCodec {

    DecodedFile read(Path path, Charset fallback) throws IOException {
        byte[] bytes = Files.readAllBytes(path);
        Bom bom = detectBom(bytes);
        int offset = bom.bytes().length;
        Charset charset = switch (bom) {
            case UTF8 -> StandardCharsets.UTF_8;
            case UTF16_LE -> StandardCharsets.UTF_16LE;
            case UTF16_BE -> StandardCharsets.UTF_16BE;
            // Un archivo ASCII no aporta evidencia para distinguir UTF-8 de una
            // codificación monobyte. En ese caso se respeta el fallback configurado.
            case NONE -> isAscii(bytes) ? fallback : isValidUtf8(bytes) ? StandardCharsets.UTF_8 : fallback;
        };
        String text = decode(bytes, offset, charset);
        return new DecodedFile(path, text, charset, bom);
    }

    void write(Path path, String text, Charset charset, Bom bom) throws IOException {
        byte[] content;
        try {
            ByteBuffer encoded = charset.newEncoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .encode(CharBuffer.wrap(text));
            content = new byte[encoded.remaining()];
            encoded.get(content);
        } catch (CharacterCodingException ex) {
            throw new IOException("El contenido no se puede representar en " + charset.name() + ": " + path, ex);
        }

        Files.createDirectories(path.getParent());
        ByteArrayOutputStream output = new ByteArrayOutputStream(bom.bytes().length + content.length);
        output.writeBytes(bom.bytes());
        output.writeBytes(content);
        Files.write(path, output.toByteArray());
    }

    private String decode(byte[] bytes, int offset, Charset charset) throws IOException {
        try {
            return charset.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(bytes, offset, bytes.length - offset))
                    .toString();
        } catch (CharacterCodingException ex) {
            throw new IOException("No se pudo decodificar el archivo como " + charset.name(), ex);
        }
    }

    private boolean isValidUtf8(byte[] bytes) {
        try {
            StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(bytes));
            return true;
        } catch (CharacterCodingException ex) {
            return false;
        }
    }

    private boolean isAscii(byte[] bytes) {
        for (byte value : bytes) {
            if ((value & 0x80) != 0) return false;
        }
        return true;
    }

    private Bom detectBom(byte[] bytes) {
        if (startsWith(bytes, Bom.UTF8.bytes())) return Bom.UTF8;
        if (startsWith(bytes, Bom.UTF16_LE.bytes())) return Bom.UTF16_LE;
        if (startsWith(bytes, Bom.UTF16_BE.bytes())) return Bom.UTF16_BE;
        return Bom.NONE;
    }

    private boolean startsWith(byte[] value, byte[] prefix) {
        if (value.length < prefix.length) return false;
        for (int i = 0; i < prefix.length; i++) {
            if (value[i] != prefix[i]) return false;
        }
        return true;
    }
}
