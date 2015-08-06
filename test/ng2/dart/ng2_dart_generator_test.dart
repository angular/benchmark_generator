library web_app_generator.ng2_dart_generator.test;

import 'package:test/test.dart';
import 'package:web_app_generator/generator.dart';
import 'package:web_app_generator/ng2/dart/ng2_dart_generator.dart';

const simpleSpec = '''
entrypoint: Component

Component:
  template:
    - div
''';

main() {
  group('Ng2DartGenerator', () {
    AppGenSpec spec;
    VFileSystem app;

    void generate(String specYaml, [String appName = 'app']) {
      spec = parseGenSpecYaml(appName, specYaml);
      app = new Ng2DartGenerator().generate(spec);
    }

    test('should generate pubspec.yaml', () {
      generate(simpleSpec);
      expect(app.getFile('pubspec.yaml').contents, '''
name: app
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
    });

    test('should generate index.html', () {
      generate(simpleSpec);
      expect(app.getFile('web/index.html').contents, '''
<!doctype html>
<html>
  <title>Generated app: app</title>
<body>
  <gen-app>
    Loading...
  </gen-app>

  <script src="index.dart" type="application/dart"></script>
  <script src="packages/browser/dart.js" type="text/javascript"></script>
</body>
</html>
''');
    });

    test('should generate index.dart', () {
      generate(simpleSpec);
      expect(app.getFile('web/index.dart').contents, '''
library app;

import 'package:angular2/bootstrap.dart';
import 'package:app/Component.dart';

main() {
  bootstrap(Component);
}
''');
    });

    test('should generate Dart code for component', () {
      generate(simpleSpec);
      expect(app.getFile('lib/Component.dart').contents, '''
library app.Component;

import 'package:angular2/angular2.dart';

@Component(
  selector: 'Component'
)
@View(
  templateUrl: 'Component.html'
)
class Component {
}
''');
    });

    test('should generate template code for component', () {
      generate(simpleSpec);
      expect(app.getFile('lib/Component.html').contents, '''
<div></div>''');
    });
  });
}
