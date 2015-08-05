library web_app_generator.generator.test;

import 'package:test/test.dart';
import 'package:web_app_generator/generator.dart';

const simpleSpec = '''
entrypoint: Component

Component:
  template:
    - div
''';

main() {
  group('parseGenSpecYaml', () {
    test('should extract entrypoint component', () {
      var spec = parseGenSpecYaml(simpleSpec);
      expect(spec.rootComponent, isNotNull);
      expect(spec.rootComponent.name, 'Component');
    });

    test('should extract trivial PlainNodeGenSpec', () {
      var spec = parseGenSpecYaml(simpleSpec).components['Component'];
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

          var spec = parseGenSpecYaml(specFile).components['Parent'];
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

          var spec = parseGenSpecYaml(specFile).components['RepeatedDiv'];
          expect(spec.template.single.timesToRepeatNode, 20);
        });

        test('should extract nestingLevel', () {
          var specFile = '''
${simpleSpec}

NestedDiv:
  template:
    - ${nodeType[0]}:
        nestingLevel: 4
''';

          var spec = parseGenSpecYaml(specFile).components['NestedDiv'];
          expect(spec.template.single.nestingLevel, 4);
        });

        test('should extract "if" branches', () {
          var specFile = '''
${simpleSpec}

IfBranch:
  template:
    - ${nodeType[0]}:
        branch: if
''';

          var spec = parseGenSpecYaml(specFile).components['IfBranch'];
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

          var spec = parseGenSpecYaml(specFile).components['Props'];
          expect(spec.template.single.propertyBingingCount, 6);
        });
      });
      });
    });
}
