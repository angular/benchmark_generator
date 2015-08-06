library web_app_generator.ng2_dart_generator;

import 'package:web_app_generator/generator.dart';

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

  void _generatePubspec() {
    _fs.addFile('pubspec.yaml', '''
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
''');
  }

  void _generateIndexHtml() {
    _fs.addFile('web/index.html', '''
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
    _fs.addFile('web/index.dart', '''
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
    compSpec.template
      .where((NodeInstanceGenSpec nodeSpec) => nodeSpec.ref is ComponentGenSpec)
      .forEach((NodeInstanceGenSpec nodeSpec) {
        final childComponent = nodeSpec.nodeName;
        directives.add(childComponent);
        directiveImports.add("import '${childComponent}.dart';\n");
      });

    _fs.addFile('lib/${compSpec.name}.dart', '''
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
}
''');
  }

  void _generateComponentTemplateFile(ComponentGenSpec compSpec) {
    var template = compSpec.template.map((NodeInstanceGenSpec nodeSpec) {
      return '<${nodeSpec.nodeName}></${nodeSpec.nodeName}>';
    }).join('\n');
    _fs.addFile('lib/${compSpec.name}.html', template);
  }
}
