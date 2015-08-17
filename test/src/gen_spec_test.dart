library benchmark_generator.generator.test;

import 'package:test/test.dart';
import 'package:benchmark_generator/generator.dart';

const simpleSpec = '''
entrypoint: Component

Component:
  template:
    - div
''';

main() {
  group('parseGenSpecYaml', () {
    test('should have application name', () {
      expect(parseGenSpecYaml('app', simpleSpec).name, 'app');
    });

    test('should extract entrypoint component', () {
      var spec = parseGenSpecYaml('app', simpleSpec);
      expect(spec.rootComponent, isNotNull);
      expect(spec.rootComponent.name, 'Component');
    });

    test('should extract trivial PlainNodeGenSpec', () {
      var spec = parseGenSpecYaml('app', simpleSpec).components['Component'];
      expect(spec.name, 'Component');
      expect(spec.template.length, 1);
      expect(spec.template[0], new isInstanceOf<NodeInstanceGenSpec>());
      expect(spec.template[0].nodeName, 'div');
      PlainNodeGenSpec div = spec.template[0].ref;
      expect(div.name, 'div');
    });

    [
      ['div', PlainNodeGenSpec],
      ['Component', ComponentGenSpec]
    ].forEach((List nodeType) {
      group(nodeType[0], () {
        test('should have the correct node ref type', () {
          var specFile = '''
${simpleSpec}

Parent:
  template:
    - ${nodeType[0]}:
        repeat: 20
''';

          var spec = parseGenSpecYaml('app', specFile).components['Parent'];
          expect(spec.template.single.ref.runtimeType, nodeType[1]);
        });

        test('should extract "repeat" spec', () {
          var specFile = '''
${simpleSpec}

RepeatedDiv:
  template:
    - ${nodeType[0]}:
        repeat: 20
''';

          var spec = parseGenSpecYaml('app', specFile).components['RepeatedDiv'];
          expect(spec.template.single.timesToRepeatNode, 20);
        });

        test('should extract "if" branches', () {
          var specFile = '''
${simpleSpec}

IfBranch:
  template:
    - ${nodeType[0]}:
        branch: if
''';

          var spec = parseGenSpecYaml('app', specFile).components['IfBranch'];
          expect(spec.template.single.branchSpec, new isInstanceOf<IfBranchSpec>());
        });

        test('should extract property bindings ("props")', () {
          var specFile = '''
${simpleSpec}

Props:
  template:
    - ${nodeType[0]}:
        props: 6
''';

          var spec = parseGenSpecYaml('app', specFile).components['Props'];
          expect(spec.template.single.propertyBindingCount, 6);
        });

        test('should extract "repeat" branches', () {
          var specFile = '''
${simpleSpec}

RepeatBranch:
  template:
    - ${nodeType[0]}:
        branch:
          repeat: 10
''';

          var spec = parseGenSpecYaml('app', specFile).components['RepeatBranch'];
          expect(spec.template.single.branchSpec, new isInstanceOf<RepeatBranchSpec>());
        });
      });
    });
  });
}
