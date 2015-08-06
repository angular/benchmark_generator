library app_generator.generate;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:web_app_generator/ng2/dart/ng2_dart_generator.dart';
import 'package:web_app_generator/generator.dart';

main(List<String> rawArgs) {
  final args = _parseArgs(rawArgs);
  final inputFile = new File(args['input']);
  final genSpecYaml = inputFile.readAsStringSync();
  final appName = path.basenameWithoutExtension(inputFile.path);
  final appGenSpec = parseGenSpecYaml(appName, genSpecYaml);
  final framework = args['framework'];

  Generator generator = null;
  switch(framework) {
    case 'ng2':
      generator = new Ng2DartGenerator();
      break;
    default:
      throw 'Unsupported framework: ${framework}';
  }

  final vfs = generator.generate(appGenSpec);
  final outputDir = new Directory(args['output']);
  _emitFiles(vfs, outputDir);
}

_emitFiles(VFileSystem vfs, Directory outputDir) {
  outputDir.createSync(recursive: true);
  vfs.files.forEach((VFile vfile) {
    var fullPath = path.join(outputDir.path, vfile.path);
    print('[EMITTER]: writing ${fullPath}');
    new Directory(path.dirname(fullPath)).createSync(recursive: true);
    new File(fullPath).writeAsStringSync(vfile.contents);
  });
}

ArgResults _parseArgs(List<String> rawArgs) {
  final parser = new ArgParser()
    ..addOption('input', abbr: 'i')
    ..addOption('output', abbr: 'o')
    ..addOption('framework', abbr: 'f');

  return parser.parse(rawArgs);
}
