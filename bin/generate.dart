library app_generator.generate;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:web_app_generator/generator.dart';

main(List<String> rawArgs) {
  final args = _parseArgs(rawArgs);
  final genSpecYaml = new File(args['input']).readAsStringSync();
  final appGenSpec = parseGenSpecYaml(genSpecYaml);
}

ArgResults _parseArgs(List<String> rawArgs) {
  final parser = new ArgParser()
    ..addOption('input', abbr: 'i')
    ..addOption('output', abbr: 'o');

  return parser.parse(rawArgs);
}
