package ec.com.appdfm.sync;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class OraclePackageSyncApplication implements CommandLineRunner {

    private final PackageSyncService syncService;

    public OraclePackageSyncApplication(PackageSyncService syncService) {
        this.syncService = syncService;
    }

    public static void main(String[] args) {
        SpringApplication.run(OraclePackageSyncApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        SyncSummary summary = syncService.synchronize();
        System.out.printf(
                "Proceso terminado: %d archivo(s) generado(s), %d sin cambios, %d advertencia(s). Reporte: %s%n",
                summary.generated(), summary.unchanged(), summary.warnings(), summary.report());
    }
}
