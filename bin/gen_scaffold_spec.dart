/*
 * This utility generates a sample application descriptor that follows the
 * standard mobile app template:
 *
 * - a sidebar containing a configurable number of tabs
 * - for each tab a component of configurable depth and width
 */
library benchmark_generator.gen_scaffold_spec;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

// parsed command-line arguments
int tabCount;
int depth;
int branchingFactor;
int conditionalBranchingFactor;

// internals
final _argParser = new ArgParser();
int _componentIndex = 0;
final _components = <String>[];

main(List<String> rawArgs) {
  if(!_parseArgs(rawArgs)) return;
  final String tabs = new List.generate(tabCount, (int i) {
    _generateTree('Tab${i}');
    return '''
    - Tab${i}:
        branch: if
        props: 1''';
  }).join('\n');

  print('''
entrypoint: Shell

Shell:
  template:
${tabs}

${_components.join('\n\n')}
''');
}

void _generateTree(String rootComponent) {
  _components.add('''
${rootComponent}:
  template:
    - div
${_generateChildren(branchingFactor).map((String s) => '    - ${s}').join('\n')}
''');
}

List<String> _generateChildren(int count, [int level = 0]) {
  if (level == depth) return [];
  final res = <String>[];

  String childComponent(String name) => '    - ${name}';

  String conditionalChildComponent(String name) {
    return
'''    - ${name}:
           branch: if''';
  }

  for (int i = 0; i < count; i++) {
    var cmpId = _componentIndex++;
    var cmpName = 'Component${cmpId}';
    res.add(cmpName);
    _components.add('''
${cmpName}:
  template:
    - div:
        props: 1
    - div:
        textBindings: 1
${_generateChildren(branchingFactor, level + 1).map(childComponent).join('\n')}
${_generateChildren(conditionalBranchingFactor, level + 1).map(conditionalChildComponent).join('\n')}
''');
  }

  return res;
}

bool _parseArgs(List<String> rawArgs) {
  _addOption('tabs',
      'number of tabs in sidebar',
      abbr: 't',
      callback: (val) {
        tabCount = int.parse(val);
      });
  _addOption('depth',
      'how deep is the compnent hierarchy for each tab',
      abbr: 'd',
      callback: (val) {
        depth = int.parse(val);
      });
  _addOption('branching-factor',
      'number of child components at each intermediate level',
      abbr: 'b',
      callback: (val) {
        branchingFactor = int.parse(val);
      });
  _addOption('conditional-branching-factor',
      'number of child components at intermediate levels guarded by "if"',
      abbr: 'c',
      callback: (val) {
        conditionalBranchingFactor = int.parse(val);
      });

  try {
    _argParser.parse(rawArgs);
    return true;
  } catch (e) {
    print('Bad arguments: ${e}\n');
    print('Usage:\n');
    print(_argParser.usage);
    return false;
  }
}

void _addOption(String option, String description, {String abbr,
    callback(String value)}) {
  _argParser.addOption(option, abbr: abbr, valueHelp: description,
      callback: (String value) {
        if (value == null || value.isEmpty) {
          throw '${option}${abbr != null ? ' (${abbr})' : ''} required: ${description}';
        }
        callback(value);
      });
}
