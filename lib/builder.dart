import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';

import 'converter.dart';
import 'parser.dart';

Builder slangI18nGeneratorFactory(BuilderOptions options) {
  return SlangI18nGenerator(options);
}

class SlangI18nGenerator extends Builder {
  final BuilderOptions options;

  SlangI18nGenerator(this.options);

  @override
  Map<String, List<String>> get buildExtensions {
    final extensions = ['.i18n.json'];

    for (final language
        in options.config['additional_locales'] as List<dynamic>) {
      extensions.add('_$language.i18n.json');
    }

    return {
      '.slang.json': extensions,
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;

    final input = json.decode(await buildStep.readAsString(inputId));
    final convertedEntries = convert(parse([], input as Map<String, dynamic>));

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
        await File(outputId.path).create(recursive: true);
        await buildStep.writeAsString(outputId, json.encode(entry.map));
      }
    }
  }
}
