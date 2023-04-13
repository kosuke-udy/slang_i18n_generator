import 'parser.dart';

class ConvertedItem {
  ConvertedItem({
    required this.language,
    required this.map,
  });

  late String language;
  late Map<String, dynamic> map;
}

List<ConvertedItem> convert(List<ParsedEntry> parsedEntries) {
  final ret = <ConvertedItem>[];

  for (final entry in parsedEntries) {
    final keys = entry.keys;
    final lang = entry.language;
    final values = entry.values;
    final retIndexResult = ret.indexWhere((item) => item.language == lang);
    if (retIndexResult == -1) {
      ret.add(ConvertedItem(language: lang, map: {}));
    }
    final retIndex = retIndexResult == -1 ? ret.length - 1 : retIndexResult;

    ret[retIndex].map = addValues(ret[retIndex].map, keys, values);
  }

  return ret;
}

Map<String, dynamic> addValues(
    Map<String, dynamic> map, List<String> keys, List<String> values) {
  if (keys.length == 1) {
    return {...map, keys.first: values.length == 1 ? values.first : values};
  } else if (!map.containsKey(keys.first)) {
    return {
      ...map,
      keys.first: addValues({}, keys.sublist(1), values),
    };
  }

  return {
    ...map,
    keys.first: addValues(
        map[keys.first] as Map<String, dynamic>, keys.sublist(1), values)
  };
}
