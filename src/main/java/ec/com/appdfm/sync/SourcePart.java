package ec.com.appdfm.sync;

import java.nio.file.Path;

record SourcePart(String packageName, PackagePart part, String text, Path source) {
}
