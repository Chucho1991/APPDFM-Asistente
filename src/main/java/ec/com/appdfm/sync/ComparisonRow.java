package ec.com.appdfm.sync;

import java.nio.charset.Charset;
import java.nio.file.Path;

record ComparisonRow(
        String packageName,
        PackagePart part,
        Path productionFile,
        Path testFile,
        Path resultFile,
        Charset targetCharset,
        String status,
        String detail) {
}
