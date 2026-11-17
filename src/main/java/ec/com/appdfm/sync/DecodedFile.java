package ec.com.appdfm.sync;

import java.nio.charset.Charset;
import java.nio.file.Path;

record DecodedFile(Path path, String text, Charset charset, Bom bom) {
}
