import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/component/html_bio_formatter.dart';

void main() {
  group('normalizeBioHtml', () {
    test('converts plain URLs into anchor tags', () {
      const input = 'Portfolio: https://example.com/me';
      final html = normalizeBioHtml(input);

      expect(
        html,
        contains(
          '<a href="https://example.com/me">https://example.com/me</a>',
        ),
      );
    });

    test('preserves line breaks for bio text', () {
      const input = 'line one\nline two\nline three';
      final html = normalizeBioHtml(input);

      expect(html, contains('line one<br/>line two<br/>line three'));
    });

    test('does not double-wrap existing anchor links', () {
      const input = '<a href="https://example.com">site</a>';
      final html = normalizeBioHtml(input);

      expect(
        '<a href="https://example.com">site</a>'.allMatches(html).length,
        1,
      );
    });
  });
}
