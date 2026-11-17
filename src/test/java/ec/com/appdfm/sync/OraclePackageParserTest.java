package ec.com.appdfm.sync;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class OraclePackageParserTest {

    private final OraclePackageParser parser = new OraclePackageParser();

    @Test
    void separatesSpecificationAndBodyFromPck() {
        String sql = "CREATE OR REPLACE PACKAGE trx3.Demo_Pk AS\r\nEND Demo_Pk;\r\n/\r\n"
                + "CREATE OR REPLACE PACKAGE BODY trx3.Demo_Pk AS\r\nEND Demo_Pk;\r\n/\r\n";

        List<ParsedPart> parts = parser.parse(sql);

        assertThat(parts).hasSize(2);
        assertThat(parts.get(0).packageName()).isEqualTo("DEMO_PK");
        assertThat(parts.get(0).part()).isEqualTo(PackagePart.SPECIFICATION);
        assertThat(parts.get(0).text()).doesNotContain("PACKAGE BODY");
        assertThat(parts.get(1).part()).isEqualTo(PackagePart.BODY);
    }

    @Test
    void ignoresCreateTextInsideStringsAndComments() {
        String sql = "CREATE PACKAGE Demo AS\n"
                + "  x varchar2(100) := 'text\nCREATE PACKAGE BODY Fake AS\nmore text';\n"
                + "  -- CREATE PACKAGE BODY Fake AS\n"
                + "  /* comment\nCREATE PACKAGE BODY OtherFake AS\n*/\n"
                + "  y varchar2(100) := q'[it's text\nCREATE PACKAGE BODY QuotedFake AS\n]';\n"
                + "END Demo;\n/\n";

        assertThat(parser.parse(sql)).hasSize(1);
    }

    @Test
    void acceptsEditionableAndQuotedIdentifiers() {
        String sql = "CREATE OR REPLACE EDITIONABLE PACKAGE BODY \"TRX3\".\"MixedName\" "
                + "AUTHID CURRENT_USER IS\nEND;\n/";

        ParsedPart part = parser.parse(sql).get(0);

        assertThat(part.packageName()).isEqualTo("MIXEDNAME");
        assertThat(part.part()).isEqualTo(PackagePart.BODY);
    }
}
