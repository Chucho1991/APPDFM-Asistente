package ec.com.appdfm.sync;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;

class TextFileCodecTest {

    @TempDir
    Path temp;

    private final TextFileCodec codec = new TextFileCodec();

    @Test
    void detectsWindows1252WhenUtf8IsInvalid() throws Exception {
        Path file = temp.resolve("sample.pks");
        Files.write(file, "año".getBytes(Charset.forName("windows-1252")));

        DecodedFile decoded = codec.read(file, Charset.forName("windows-1252"));

        assertThat(decoded.text()).isEqualTo("año");
        assertThat(decoded.charset()).isEqualTo(Charset.forName("windows-1252"));
        assertThat(decoded.bom()).isEqualTo(Bom.NONE);
    }

    @Test
    void preservesUtf8BomOnWrite() throws Exception {
        Path file = temp.resolve("sample.pkb");
        codec.write(file, "á", StandardCharsets.UTF_8, Bom.UTF8);

        byte[] bytes = Files.readAllBytes(file);
        assertThat(bytes).startsWith((byte) 0xEF, (byte) 0xBB, (byte) 0xBF);
    }

    @Test
    void usesFallbackForAmbiguousAsciiFiles() throws Exception {
        Path file = temp.resolve("ascii.pks");
        Files.writeString(file, "plain ascii", StandardCharsets.US_ASCII);

        DecodedFile decoded = codec.read(file, Charset.forName("windows-1252"));

        assertThat(decoded.charset()).isEqualTo(Charset.forName("windows-1252"));
    }
}
