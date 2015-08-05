part of app_generator;

/// Parameters used to generate an application.
class AppGenSpec extends Object with Boilerplate {
  String name;
  ComponentGenSpec rootComponent;
  Map<String, ComponentGenSpec> components;
}

abstract class NodeGenSpec {
  String name;
}

/// Parameters used to generate a component
class ComponentGenSpec extends NodeGenSpec with Boilerplate {
  List<NodeInstanceGenSpec> template;
}

class PlainNodeGenSpec extends NodeGenSpec with Boilerplate {}

class NodeInstanceGenSpec extends Object with Boilerplate {
  String nodeName;
  NodeGenSpec ref;
  int nestingLevel = 0;
  BranchSpec branchSpec = null;
  int propertyBingingCount = 0;
  int timesToRepeatNode = 1;
}

abstract class BranchSpec {}

class IfBranchSpec extends Object with Boilerplate implements BranchSpec {}

class RepeatBranchSpec extends Object with Boilerplate implements BranchSpec {
  int times = 1;
}

class AppDescriptor extends Object with Boilerplate {
  String name;
  ComponentDescriptor rootComponent;
}

class ComponentDescriptor extends Object with Boilerplate {
  String name;
  Node template;
}

class Node extends Object with Boilerplate {
  String tag;
  Map<String, String> attributes;
  Map<String, String> bindings;
}

AppGenSpec parseGenSpecYaml(String appName, String source) {
  Map specYaml = yaml.loadYaml(source);
  final appSpec = new AppGenSpec()
    ..name = appName;
  String entrypoint = specYaml['entrypoint'];
  final componentSpecs = <String, ComponentGenSpec>{};

  specYaml
    .keys
    .where((k) => k != 'entrypoint')
    .forEach((k) {
      componentSpecs[k] = _parseComponentGenSpec(k, specYaml[k]);
    });

  _resolveRefs(componentSpecs);

  appSpec
    ..rootComponent = componentSpecs[entrypoint]
    ..components = componentSpecs;

  return appSpec;
}

void _resolveRefs(Map<String, ComponentGenSpec> components) {
  for (ComponentGenSpec component in components.values) {
    component.template.forEach((NodeInstanceGenSpec nodeSpec) {
      if (components.containsKey(nodeSpec.nodeName)) {
        nodeSpec.ref = components[nodeSpec.nodeName];
      } else {
        nodeSpec.ref = new PlainNodeGenSpec()
          ..name = nodeSpec.nodeName;
      }
    });
  }
}

ComponentGenSpec _parseComponentGenSpec(String name, Map specYaml) {
  final spec = new ComponentGenSpec()
    ..name = name;
  final template = <NodeInstanceGenSpec>[];
  specYaml['template'].forEach((nodeSpec) {
    template.add(_parseNodeInstanceGenSpec(nodeSpec));
  });
  spec.template = template;
  return spec;
}

NodeInstanceGenSpec _parseNodeInstanceGenSpec(specYaml) {
  if (specYaml is String) {
    // Trivial type of plain node where no addition specification is
    return new NodeInstanceGenSpec()
      ..nodeName = specYaml;
  }

  if (specYaml is Map) {
    final name = specYaml.keys.single;
    final data = specYaml.values.single;
    return new NodeInstanceGenSpec()
      ..nodeName = name
      ..nestingLevel = firstNonNull(data['nestingLevel'], 0)
      ..propertyBingingCount = firstNonNull(data['props'], 0)
      ..timesToRepeatNode = firstNonNull(data['repeat'], 0)
      ..branchSpec = _parseBranchSpec(data['branch']);
  }

  throw 'Unrecognized node instance type ${specYaml.runtimeType}: ${specYaml}';
}

BranchSpec _parseBranchSpec(dynamic specYaml) {
  if (specYaml == null) return null;
  if (specYaml == 'if') {
    return new IfBranchSpec();
  }
  if (specYaml is Map && specYaml['repeat'] != null) {
    return new RepeatBranchSpec()
      ..times = specYaml['repeat'];
  }
  throw 'Unrecognizable branch spec: $specYaml';
}
