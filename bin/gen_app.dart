library benchmark_generator.gen_app;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:benchmark_generator/ng2/dart/ng2_dart_generator.dart';
import 'package:benchmark_generator/generator.dart';

/// Generates an app given an application descriptor YAML file.
///
/// A descriptor can either be hand-coded or generated. Hand-coded descriptors
/// are good for emulating precise application structures. Generated
/// descriptors are good for load tests, as they can generate larger
/// application structures that would be prohibitively hard to hand-code.
main(List<String> rawArgs) {
  final args = _parseArgs(rawArgs);
  final inputFile = new File(args['input']);
  final genSpecYaml = inputFile.readAsStringSync();
  final appName = path.basenameWithoutExtension(inputFile.path);
  final appGenSpec = parseGenSpecYaml(appName, genSpecYaml);
  final framework = args['framework'];

  Generator generator = null;
  switch(framework) {
    case 'ng2-dart':
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
    ..addOption('input', abbr: 'i', callback: (val) {
      if (val == null || val.isEmpty) {
        throw '--input (-i) required: app descriptor file';
      }
    })
    ..addOption('output', abbr: 'o', callback: (val) {
      if (val == null || val.isEmpty) {
        throw '--output (-o) required: output directory';
      }
    })
    ..addOption('framework', abbr: 'f', callback: (val) {
      if (val == null || val.isEmpty) {
        throw '--framework (-f) required: framework (ng2-dart)';
      }
    });

  try {
    return parser.parse(rawArgs);
  } catch (e) {
    print('Bad arguments: ${e}\n');
    print('Usage:\n');
    print(parser.usage);
    throw '';
  }
}
