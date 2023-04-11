import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';

import 'converter.dart';
import 'parser.dart';

Builder slangI18nGeneratorFactory(BuilderOptions options) {
  return SlangI18nGenerator();
}

class SlangI18nGenerator extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.slang.json': ['.i18n.json', '_jp.i18n.json'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final input =
        json.decode(await buildStep.readAsString(inputId)) as List<dynamic>;

    final parsedEntries = <ParsedEntry>[];
    for (final entry in input) {
      final map = entry as Map<String, dynamic>;
      parsedEntries.addAll(parse([], map));
    }
    final convertedEntries = convert(parsedEntries);

    for (final entry in convertedEntries) {
      final language = entry.language;
      final outputId = AssetId(
          inputId.package,
          inputId.path.replaceFirst(
            ".slang.json",
            language == "base" ? ".i18n.json" : "_$language.i18n.json",
          ));
      if (language == "base") {
        await buildStep.writeAsString(outputId, json.encode(entry.map));
      } else {
        final filename = outputId.path.split("/").last;
        await File(outputId.path).create(recursive: true);
        // buildStep.findAssets(Glob('*_*.i18n.json')).listen((id) async {
        //   await buildStep.writeAsString(outputId, json.encode(entry.map));
        // });
        await buildStep.writeAsString(outputId, json.encode(entry.map));
      }
    }
  }
}
