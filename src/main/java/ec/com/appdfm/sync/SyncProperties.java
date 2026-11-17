package ec.com.appdfm.sync;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.nio.charset.Charset;
import java.nio.file.Path;

@ConfigurationProperties("oracle-sync")
public record SyncProperties(
        Path testDirectory,
        Path productionDirectory,
        Path resultDirectory,
        String reportFile,
        Charset fallbackCharset) {

    public SyncProperties {
        testDirectory = testDirectory == null ? Path.of("fuente/test") : testDirectory;
        productionDirectory = productionDirectory == null ? Path.of("fuente/produccion") : productionDirectory;
        resultDirectory = resultDirectory == null ? Path.of("resultado") : resultDirectory;
        reportFile = reportFile == null || reportFile.isBlank() ? "REPORTE.md" : reportFile;
        fallbackCharset = fallbackCharset == null ? Charset.forName("windows-1252") : fallbackCharset;
    }
}
