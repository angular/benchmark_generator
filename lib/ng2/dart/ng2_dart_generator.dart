library benchmark_generator.ng2_dart_generator;

import 'package:benchmark_generator/generator.dart';

class Ng2DartGenerator implements Generator {
  final _fs = new VFileSystem();
  AppGenSpec _genSpec;

  VFileSystem generate(AppGenSpec genSpec) {
    _genSpec = genSpec;
    _generatePubspec();
    _generateIndexHtml();
    _generateIndexDart();
    _genSpec.components.values.forEach(_generateComponentFiles);
    return _fs;
  }

  _addFile(String path, String contents) {
    _fs.addFile(path, contents);
  }

  void _generatePubspec() {
    _addFile('pubspec.yaml', '''
name: ${_genSpec.name}
version: 0.0.0
dependencies:
  angular2: any
  browser: any
transformers:
- angular2:
    entry_points:
      - web/index.dart
    reflection_entry_points:
      - web/index.dart
- \$dart2js:
    minify: true
    commandLineOptions: [--trust-type-annotations,--trust-primitives]
''');
  }

  void _generateIndexHtml() {
    _addFile('web/index.html', '''
<!doctype html>
<html>
  <title>Generated app: ${_genSpec.name}</title>
<body>
  <${_genSpec.rootComponent.name}>
    Loading...
  </${_genSpec.rootComponent.name}>

  <script type="text/javascript">
    console.timeStamp('>>> pre-script');
  </script>
  <script src="index.dart" type="application/dart"></script>
  <script src="packages/browser/dart.js" type="text/javascript"></script>
</body>
</html>
''');
  }

  void _generateIndexDart() {
    _addFile('web/index.dart', '''
library ${_genSpec.name};

import 'dart:html';
import 'package:angular2/bootstrap.dart';
import 'package:${_genSpec.name}/${_genSpec.rootComponent.name}.dart';

main() async {
  window.console.timeStamp('>>> before bootstrap');
  await bootstrap(${_genSpec.rootComponent.name});
  window.console.timeStamp('>>> after bootstrap');
}
''');
  }

  void _generateComponentFiles(ComponentGenSpec compSpec) {
    _generateComponentDartFile(compSpec);
    _generateComponentTemplateFile(compSpec);
  }

  void _generateComponentDartFile(ComponentGenSpec compSpec) {
    final directiveImports = <String>[];
    final directives = <String>[];
    int totalProps = 0;
    int totalTextProps = 0;
    compSpec.template
      .map((NodeInstanceGenSpec nodeSpec) {
        totalProps += nodeSpec.propertyBindingCount;
        totalTextProps += nodeSpec.textBindingCount;
        return nodeSpec;
      })
      .where((NodeInstanceGenSpec nodeSpec) => nodeSpec.ref is ComponentGenSpec)
      .forEach((NodeInstanceGenSpec nodeSpec) {
        final childComponent = nodeSpec.nodeName;
        directives.add(childComponent);
        directiveImports.add("import '${childComponent}.dart';\n");
      });

    final props = new StringBuffer('\n');
    props.write(new List.generate(totalProps, (i) => '  var prop${i};')
        .join('\n'));

    final textProps = new StringBuffer('\n');
    textProps.write(new List.generate(totalTextProps, (i) => '  var text${i};')
        .join('\n'));

    final branchProps = new StringBuffer();
    int i = 0;
    compSpec.template.forEach((NodeInstanceGenSpec nodeSpec) {
      if (nodeSpec.branchSpec != null) {
        branchProps.write('  var branch${i++};');
      }
    });

    _addFile('lib/${compSpec.name}.dart', '''
library ${_genSpec.name}.${compSpec.name};

import 'package:angular2/angular2.dart';
${directiveImports.join('')}
@Component(
  selector: '${compSpec.name}'
)
@View(
  templateUrl: '${compSpec.name}.html'
${directives.isNotEmpty ? '  , directives: const ${directives}' : ''}
)
class ${compSpec.name} {
${props}
${branchProps}
${textProps}
}
''');
  }

  void _generateComponentTemplateFile(ComponentGenSpec compSpec) {
    int branchIndex = 0;
    int propIdx = 0;
    int textIdx = 0;
    var template = compSpec.template.map((NodeInstanceGenSpec nodeSpec) {
      final bindings = new StringBuffer();
      if (nodeSpec.propertyBindingCount > 0) {
        bindings.write(' ');
        bindings.write(new List.generate(nodeSpec.propertyBindingCount, (i) => '[prop${i}]="prop${i}"')
            .join(' '));
      }
      final branch = new StringBuffer();
      if (nodeSpec.branchSpec is IfBranchSpec) {
        IfBranchSpec ifBranch = nodeSpec.branchSpec;
        branch.write(' *ng-if="branch${branchIndex++}"');
      } else if (nodeSpec.branchSpec is RepeatBranchSpec) {
        RepeatBranchSpec repeatBranch = nodeSpec.branchSpec;
        branch.write(' *ng-for="#item of branch${branchIndex++}"');
      }

      final textBindings = new List.generate(nodeSpec.textBindingCount, (_) {
        return '{{text${textIdx++}}}';
      }).join();

      return '<${nodeSpec.nodeName}${bindings}${branch}>${textBindings}</${nodeSpec.nodeName}>';
    }).join('\n');
    _addFile('lib/${compSpec.name}.html', template);
  }
}
