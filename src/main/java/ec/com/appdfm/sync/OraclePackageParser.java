package ec.com.appdfm.sync;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
class OraclePackageParser {

    private static final String IDENTIFIER = "(?:\"[^\"]+\"|[A-Za-z][A-Za-z0-9_$#]*)";
    private static final Pattern HEADER = Pattern.compile(
            "(?im)^[\\t ]*CREATE\\s+(?:OR\\s+REPLACE\\s+)?(?:EDITIONABLE\\s+|NONEDITIONABLE\\s+)?" +
                    "PACKAGE\\s+(BODY\\s+)?(?:" + IDENTIFIER + "\\s*\\.\\s*)?(" + IDENTIFIER + ")\\s+" +
                    "(?:AUTHID\\s+(?:CURRENT_USER|DEFINER)\\s+)?(?:IS|AS)\\b");

    List<ParsedPart> parse(String text) {
        // Se buscan cabeceras sobre una copia enmascarada. Los índices se mantienen,
        // evitando confundir SQL citado o comentado con una declaración real.
        String searchable = maskCommentsAndStrings(text);
        Matcher matcher = HEADER.matcher(searchable);
        List<HeaderMatch> headers = new ArrayList<>();
        while (matcher.find()) {
            PackagePart part = matcher.group(1) == null ? PackagePart.SPECIFICATION : PackagePart.BODY;
            headers.add(new HeaderMatch(matcher.start(), canonical(matcher.group(2)), part));
        }

        if (headers.isEmpty()) {
            throw new IllegalArgumentException("No se encontró una sentencia CREATE PACKAGE válida");
        }

        List<ParsedPart> result = new ArrayList<>();
        for (int i = 0; i < headers.size(); i++) {
            HeaderMatch current = headers.get(i);
            int start = i == 0 ? 0 : current.start();
            int end = i + 1 < headers.size() ? headers.get(i + 1).start() : text.length();
            result.add(new ParsedPart(current.packageName(), current.part(), text.substring(start, end)));
        }
        return result;
    }

    private String maskCommentsAndStrings(String text) {
        StringBuilder masked = new StringBuilder(text);
        ScanState state = ScanState.CODE;
        char quotedEnd = '\0';
        for (int i = 0; i < text.length(); i++) {
            char current = text.charAt(i);
            char next = i + 1 < text.length() ? text.charAt(i + 1) : '\0';

            if (state == ScanState.CODE && current == '-' && next == '-') {
                masked.setCharAt(i, ' ');
                masked.setCharAt(++i, ' ');
                state = ScanState.LINE_COMMENT;
            } else if (state == ScanState.CODE && current == '/' && next == '*') {
                masked.setCharAt(i, ' ');
                masked.setCharAt(++i, ' ');
                state = ScanState.BLOCK_COMMENT;
            } else if (state == ScanState.CODE && (current == 'q' || current == 'Q')
                    && next == '\'' && i + 2 < text.length()) {
                char quotedStart = text.charAt(i + 2);
                quotedEnd = switch (quotedStart) {
                    case '[' -> ']';
                    case '{' -> '}';
                    case '(' -> ')';
                    case '<' -> '>';
                    default -> quotedStart;
                };
                masked.setCharAt(i, ' ');
                masked.setCharAt(++i, ' ');
                masked.setCharAt(++i, ' ');
                state = ScanState.QUOTED_STRING;
            } else if (state == ScanState.CODE && current == '\'') {
                masked.setCharAt(i, ' ');
                state = ScanState.STRING;
            } else if (state == ScanState.LINE_COMMENT) {
                if (current == '\r' || current == '\n') {
                    state = ScanState.CODE;
                } else {
                    masked.setCharAt(i, ' ');
                }
            } else if (state == ScanState.BLOCK_COMMENT) {
                if (current == '*' && next == '/') {
                    masked.setCharAt(i, ' ');
                    masked.setCharAt(++i, ' ');
                    state = ScanState.CODE;
                } else if (current != '\r' && current != '\n') {
                    masked.setCharAt(i, ' ');
                }
            } else if (state == ScanState.STRING) {
                masked.setCharAt(i, current == '\r' || current == '\n' ? current : ' ');
                if (current == '\'' && next == '\'') {
                    masked.setCharAt(++i, ' ');
                } else if (current == '\'') {
                    state = ScanState.CODE;
                }
            } else if (state == ScanState.QUOTED_STRING) {
                masked.setCharAt(i, current == '\r' || current == '\n' ? current : ' ');
                if (current == quotedEnd && next == '\'') {
                    masked.setCharAt(++i, ' ');
                    state = ScanState.CODE;
                }
            }
        }
        return masked.toString();
    }

    private String canonical(String identifier) {
        String value = identifier.startsWith("\"")
                ? identifier.substring(1, identifier.length() - 1).replace("\"\"", "\"")
                : identifier;
        return value.toUpperCase(Locale.ROOT);
    }

    private record HeaderMatch(int start, String packageName, PackagePart part) {
    }

    private enum ScanState {
        CODE, LINE_COMMENT, BLOCK_COMMENT, STRING, QUOTED_STRING
    }
}
