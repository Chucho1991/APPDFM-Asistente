package ec.com.appdfm.sync;

import java.nio.file.Path;

public record SyncSummary(int generated, int unchanged, int warnings, Path report) {
}
