final RegExp _urlRegex = RegExp(r'https?://[^\s<]+', caseSensitive: false);
final RegExp _htmlTagRegex = RegExp(r'<[^>]+>');

String normalizeBioHtml(String input) {
  final linked = _linkifyTextSegments(input);
  return linked.replaceAll('\n', '<br/>');
}

String _linkifyTextSegments(String input) {
  final buffer = StringBuffer();
  var cursor = 0;

  for (final match in _htmlTagRegex.allMatches(input)) {
    if (match.start > cursor) {
      buffer.write(_linkifyPlainText(input.substring(cursor, match.start)));
    }
    buffer.write(match.group(0));
    cursor = match.end;
  }

  if (cursor < input.length) {
    buffer.write(_linkifyPlainText(input.substring(cursor)));
  }

  return buffer.toString();
}

String _linkifyPlainText(String text) {
  return text.replaceAllMapped(_urlRegex, (match) {
    final url = match.group(0)!;
    return '<a href="$url">$url</a>';
  });
}
