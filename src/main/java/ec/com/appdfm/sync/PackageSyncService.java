package ec.com.appdfm.sync;

import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Stream;

@Service
class PackageSyncService {

    private static final Set<String> TEST_EXTENSIONS = Set.of("pck", "spc", "pks", "pkb");
    private static final Set<String> PRODUCTION_EXTENSIONS = Set.of("pks", "pkb");
    private static final String MANIFEST = ".oracle-sync-manifest";

    private final SyncProperties properties;
    private final TextFileCodec codec;
    private final OraclePackageParser parser;

    PackageSyncService(SyncProperties properties, TextFileCodec codec, OraclePackageParser parser) {
        this.properties = properties;
        this.codec = codec;
        this.parser = parser;
    }

    SyncSummary synchronize() throws IOException {
        validateDirectory(properties.testDirectory(), "test");
        validateDirectory(properties.productionDirectory(), "producción");
        Files.createDirectories(properties.resultDirectory());
        cleanPreviousGeneratedFiles();

        List<String> warnings = new ArrayList<>();
        Map<PartKey, SourcePart> testParts = loadTestParts(warnings);
        List<ComparisonRow> rows = new ArrayList<>();
        Set<PartKey> productionKeys = new HashSet<>();
        int generated = 0;
        int unchanged = 0;

        for (Path productionFile : listFiles(properties.productionDirectory(), PRODUCTION_EXTENSIONS)) {
            DecodedFile production = codec.read(productionFile, properties.fallbackCharset());
            List<ParsedPart> parsedProduction = parser.parse(production.text());
            if (parsedProduction.size() != 1) {
                throw new IOException("Producción debe contener una sola parte por archivo: " + productionFile);
            }
            ParsedPart prodPart = parsedProduction.get(0);
            PartKey key = new PartKey(prodPart.packageName(), prodPart.part());
            if (!productionKeys.add(key)) {
                throw new IOException("Parte duplicada en producción: " + key);
            }

            SourcePart test = testParts.get(key);
            Path relative = properties.productionDirectory().relativize(productionFile);
            Path resultFile = properties.resultDirectory().resolve(relative);
            if (test == null) {
                String detail = "No existe esta parte en test";
                warnings.add(key + ": " + detail);
                rows.add(new ComparisonRow(key.packageName(), key.part(), productionFile, null, null,
                        production.charset(), "NO ENCONTRADO", detail));
                continue;
            }

            String outputText = adaptLineEndings(test.text(), production.text());
            if (outputText.equals(production.text())) {
                unchanged++;
                rows.add(new ComparisonRow(key.packageName(), key.part(), productionFile, test.source(), null,
                        production.charset(), "SIN CAMBIOS", "El contenido es idéntico"));
            } else {
                codec.write(resultFile, outputText, production.charset(), production.bom());
                generated++;
                rows.add(new ComparisonRow(key.packageName(), key.part(), productionFile, test.source(), resultFile,
                        production.charset(), "GENERADO", "Contenido de test adaptado al formato de producción"));
            }
        }

        testParts.forEach((key, value) -> {
            if (!productionKeys.contains(key)) {
                String detail = "Existe en test, pero no hay archivo equivalente en producción";
                warnings.add(key + ": " + detail);
                rows.add(new ComparisonRow(key.packageName(), key.part(), null, value.source(), null,
                        null, "SOLO EN TEST", detail));
            }
        });

        rows.sort(Comparator.comparing(ComparisonRow::packageName).thenComparing(row -> row.part().name()));
        Path report = properties.resultDirectory().resolve(properties.reportFile());
        writeReport(report, rows, warnings);
        writeManifest(rows);
        return new SyncSummary(generated, unchanged, warnings.size(), report);
    }

    private void cleanPreviousGeneratedFiles() throws IOException {
        Path root = properties.resultDirectory().toAbsolutePath().normalize();
        Path manifest = root.resolve(MANIFEST);
        if (!Files.isRegularFile(manifest)) return;

        for (String relative : Files.readAllLines(manifest, StandardCharsets.UTF_8)) {
            if (relative.isBlank()) continue;
            Path target = root.resolve(relative).normalize();
            if (!target.startsWith(root) || target.equals(root)) {
                throw new IOException("Ruta insegura en el manifiesto de resultados: " + relative);
            }
            Files.deleteIfExists(target);
            removeEmptyParents(target.getParent(), root);
        }
    }

    private void removeEmptyParents(Path directory, Path root) throws IOException {
        Path current = directory;
        while (current != null && !current.equals(root) && current.startsWith(root)) {
            try (Stream<Path> entries = Files.list(current)) {
                if (entries.findAny().isPresent()) return;
            }
            Files.delete(current);
            current = current.getParent();
        }
    }

    private void writeManifest(List<ComparisonRow> rows) throws IOException {
        Path root = properties.resultDirectory().toAbsolutePath().normalize();
        List<String> generated = rows.stream()
                .map(ComparisonRow::resultFile)
                .filter(path -> path != null)
                .map(path -> root.relativize(path.toAbsolutePath().normalize()).toString())
                .toList();
        Files.write(root.resolve(MANIFEST), generated, StandardCharsets.UTF_8,
                StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    }

    private Map<PartKey, SourcePart> loadTestParts(List<String> warnings) throws IOException {
        Map<PartKey, SourcePart> result = new HashMap<>();
        for (Path file : listFiles(properties.testDirectory(), TEST_EXTENSIONS)) {
            DecodedFile decoded = codec.read(file, properties.fallbackCharset());
            List<ParsedPart> parts;
            try {
                parts = parser.parse(decoded.text());
            } catch (IllegalArgumentException ex) {
                warnings.add(file + ": " + ex.getMessage());
                continue;
            }
            for (ParsedPart part : parts) {
                PartKey key = new PartKey(part.packageName(), part.part());
                SourcePart previous = result.putIfAbsent(key,
                        new SourcePart(part.packageName(), part.part(), part.text(), file));
                if (previous != null) {
                    throw new IOException("Parte duplicada en test para " + key + ": "
                            + previous.source() + " y " + file);
                }
            }
        }
        return result;
    }

    private List<Path> listFiles(Path directory, Set<String> extensions) throws IOException {
        try (Stream<Path> paths = Files.walk(directory)) {
            return paths.filter(Files::isRegularFile)
                    .filter(path -> extensions.contains(extension(path)))
                    .sorted()
                    .toList();
        }
    }

    private String extension(Path path) {
        String name = path.getFileName().toString();
        int dot = name.lastIndexOf('.');
        return dot < 0 ? "" : name.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private String adaptLineEndings(String source, String target) {
        String lineEnding = target.contains("\r\n") ? "\r\n" : target.contains("\n") ? "\n" : "\r";
        return source.replace("\r\n", "\n").replace('\r', '\n').replace("\n", lineEnding);
    }

    private void writeReport(Path report, List<ComparisonRow> rows, List<String> warnings) throws IOException {
        StringBuilder md = new StringBuilder();
        String generatedAt = OffsetDateTime.now(ZoneId.systemDefault())
                .format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
        md.append("# Reporte de actualización de paquetes Oracle\n\n")
                .append("Generado: `").append(generatedAt).append("`\n\n")
                .append("Este reporte es genérico: los paquetes se descubren por sus sentencias `CREATE PACKAGE` ")
                .append("y no dependen de los nombres de la muestra. Solo se escriben en `resultado` las partes cuyo contenido cambió.\n\n")
                .append("| Paquete | Parte | Estado | Archivo test | Archivo producción | Archivo resultado | Codificación salida |\n")
                .append("|---|---|---|---|---|---|---|\n");
        for (ComparisonRow row : rows) {
            md.append('|').append(escape(row.packageName()))
                    .append('|').append(row.part().label())
                    .append('|').append(row.status())
                    .append('|').append(path(row.testFile()))
                    .append('|').append(path(row.productionFile()))
                    .append('|').append(path(row.resultFile()))
                    .append('|').append(row.targetCharset() == null ? "—" : row.targetCharset().name())
                    .append("|\n");
        }
        md.append("\n## Advertencias\n\n");
        if (warnings.isEmpty()) {
            md.append("No se encontraron advertencias.\n");
        } else {
            warnings.forEach(warning -> md.append("- ").append(escape(warning)).append("\n"));
        }
        Files.createDirectories(report.getParent());
        Files.writeString(report, md.toString(), StandardCharsets.UTF_8,
                StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    }

    private String path(Path value) {
        return value == null ? "—" : escape(value.toString().replace('\\', '/'));
    }

    private String escape(String value) {
        return value.replace("|", "\\|").replace("\r", " ").replace("\n", " ");
    }

    private void validateDirectory(Path path, String label) throws IOException {
        if (!Files.isDirectory(path)) {
            throw new IOException("No existe el directorio de " + label + ": " + path.toAbsolutePath());
        }
    }

    private record PartKey(String packageName, PackagePart part) {
        @Override
        public String toString() {
            return packageName + " / " + part.label();
        }
    }
}
