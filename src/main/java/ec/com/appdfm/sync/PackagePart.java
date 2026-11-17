package ec.com.appdfm.sync;

enum PackagePart {
    SPECIFICATION("Especificación"),
    BODY("Body");

    private final String label;

    PackagePart(String label) {
        this.label = label;
    }

    String label() {
        return label;
    }
}
