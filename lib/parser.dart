class ParsedEntry {
  ParsedEntry({
    required this.keys,
    required this.values,
    required this.language,
  });

  late List<String> keys;
  late List<String> values;
  late String language;
}

List<ParsedEntry> parse(List<String> keys, Map<String, dynamic> map) {
  final ret = <ParsedEntry>[];

  if (!isLangValueMap(map)) {
    for (final entry in map.entries) {
      final nextParentKeys = [...keys, entry.key];
      final nextMap = entry.value as Map<String, dynamic>;
      ret.addAll(parse(nextParentKeys, nextMap));
    }
    return ret;
  }

  for (final entry in map.entries) {
    final language = entry.key;
    final values = entry.value is String
        ? [entry.value as String]
        : (entry.value as List<dynamic>).cast<String>();
    ret.add(ParsedEntry(
      keys: keys,
      values: values,
      language: language,
    ));
  }
  return ret;
}

bool isLangValueMap(Map<String, dynamic> map) {
  return map.values.every((value) => value is String || value is List<String>);
}
