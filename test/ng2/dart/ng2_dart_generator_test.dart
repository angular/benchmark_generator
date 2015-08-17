library benchmark_generator.ng2_dart_generator.test;

import 'package:test/test.dart';
import 'package:benchmark_generator/generator.dart';
import 'package:benchmark_generator/ng2/dart/ng2_dart_generator.dart';

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

    void expectCode(String path, String code) {
      final expectedTrimmed = code
          .split('\n')
          .where((String line) => line.trim().isNotEmpty)
          .join('\n');
      final actualTrimmed = app.getFile(path).contents
          .split('\n')
          .where((String line) => line.trim().isNotEmpty)
          .join('\n');
      expect(actualTrimmed, expectedTrimmed);
    }

    test('should generate pubspec.yaml', () {
      generate(simpleSpec);
      expectCode('pubspec.yaml', '''
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
    commandLineOptions: [--trust-type-annotations,--trust-primitives]
''');
    });

    test('should generate index.html', () {
      generate(simpleSpec);
      expectCode('web/index.html', '''
<!doctype html>
<html>
  <title>Generated app: app</title>
<body>
  <Component>
    Loading...
  </Component>

  <script type="text/javascript">
    console.timeStamp('>>> pre-script');
  </script>
  <script src="index.dart" type="application/dart"></script>
  <script src="packages/browser/dart.js" type="text/javascript"></script>
</body>
</html>
''');
    });

    test('should generate index.dart', () {
      generate(simpleSpec);
      expectCode('web/index.dart', '''
library app;

import 'dart:html';
import 'package:angular2/bootstrap.dart';
import 'package:app/Component.dart';

main() async {
  window.console.timeStamp('>>> before bootstrap');
  await bootstrap(Component);
  window.console.timeStamp('>>> after bootstrap');
}
''');
    });

    test('should generate Dart code for component', () {
      generate(simpleSpec);
      expectCode('lib/Component.dart', '''
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
      expectCode('lib/Component.html', '''
<div></div>''');
    });

    test('should list directives', () {
      generate('''
entrypoint: Parent

Parent:
  template:
    - Child1
    - Child2

Child1:
  template:
    - div

Child2:
  template:
    - div
''');

      expectCode('lib/Parent.dart', '''
library app.Parent;

import 'package:angular2/angular2.dart';
import 'Child1.dart';
import 'Child2.dart';

@Component(
  selector: 'Parent'
)
@View(
  templateUrl: 'Parent.html'
  , directives: const [Child1, Child2]
)
class Parent {
}
''');
    });

    test('should generate property bindings on plain nodes', () {
      generate('''
entrypoint: WithBindings

WithBindings:
  template:
    - div:
        props: 2
''');

      expectCode('lib/WithBindings.dart', '''
library app.WithBindings;

import 'package:angular2/angular2.dart';

@Component(
  selector: 'WithBindings'
)
@View(
  templateUrl: 'WithBindings.html'
)
class WithBindings {
  var prop0;
  var prop1;
}
''');

      expectCode('lib/WithBindings.html', '''
<div [prop0]="prop0" [prop1]="prop1"></div>''');
    });

    test('should generate text bindings on plain nodes', () {
      generate('''
entrypoint: WithBindings

WithBindings:
  template:
    - div:
        textBindings: 2
''');

      expectCode('lib/WithBindings.dart', '''
library app.WithBindings;

import 'package:angular2/angular2.dart';

@Component(
  selector: 'WithBindings'
)
@View(
  templateUrl: 'WithBindings.html'
)
class WithBindings {
  var text0;
  var text1;
}
''');

      expectCode('lib/WithBindings.html', '''
<div>{{text0}}{{text1}}</div>''');
    });

    test('should generate property bindings on child components', () {
      generate('''
entrypoint: WithBindings

WithBindings:
  template:
    - Child:
        props: 2

Child:
  template:
    - div
''');

      expectCode('lib/WithBindings.dart', '''
library app.WithBindings;

import 'package:angular2/angular2.dart';
import 'Child.dart';

@Component(
  selector: 'WithBindings'
)
@View(
  templateUrl: 'WithBindings.html'
  , directives: const [Child]
)
class WithBindings {
  var prop0;
  var prop1;
}
''');

      expectCode('lib/WithBindings.html', '''
<Child [prop0]="prop0" [prop1]="prop1"></Child>''');
    });

    test('should generate ng-if', () {
      generate('''
entrypoint: BranchIf

BranchIf:
  template:
    - Child:
        branch: if

Child:
  template:
    - div
''');

      expectCode('lib/BranchIf.dart', '''
library app.BranchIf;

import 'package:angular2/angular2.dart';
import 'Child.dart';

@Component(
  selector: 'BranchIf'
)
@View(
  templateUrl: 'BranchIf.html'
  , directives: const [Child]
)
class BranchIf {
  var branch0;
}
''');

      expectCode('lib/BranchIf.html', '''
<Child *ng-if="branch0"></Child>''');
    });

    test('should generate ng-for', () {
      generate('''
entrypoint: BranchRepeat

BranchRepeat:
  template:
    - Child:
        branch:
          repeat: 10

Child:
  template:
    - div
''');

      expectCode('lib/BranchRepeat.dart', '''
library app.BranchRepeat;

import 'package:angular2/angular2.dart';
import 'Child.dart';

@Component(
  selector: 'BranchRepeat'
)
@View(
  templateUrl: 'BranchRepeat.html'
  , directives: const [Child]
)
class BranchRepeat {
  var branch0;
}
''');

      expectCode('lib/BranchRepeat.html', '''
<Child *ng-for="#item of branch0"></Child>''');
    });
  });
}
