part of app_generator;

/// Parses [source] YAML that describes an application into a [AppGenSpec],
/// which can then be used to generate an application for a given framework.
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

  componentSpecs.values.forEach((ComponentGenSpec spec) {
    spec.template = makeTree(spec.template);
  });

  appSpec
    ..rootComponent = componentSpecs[entrypoint]
    ..components = componentSpecs;

  return appSpec;
}

/// Parameters used to generate an application.
class AppGenSpec extends Object with Boilerplate {
  String name;
  ComponentGenSpec rootComponent;
  Map<String, ComponentGenSpec> components;
}

abstract class NodeGenSpec {
  String name;
  bool get canHaveChildren;
}

/// Parameters used to generate a component
class ComponentGenSpec extends NodeGenSpec with Boilerplate {
  List<NodeInstanceGenSpec> template;
  @override
  bool get canHaveChildren => false;
}

class PlainNodeGenSpec extends NodeGenSpec with Boilerplate {
  @override
  bool get canHaveChildren => true;
}

class NodeInstanceGenSpec extends Object with Boilerplate {
  final children = <NodeInstanceGenSpec>[];

  String nodeName;
  NodeGenSpec ref;
  BranchSpec branchSpec = null;
  int propertyBindingCount = 0;
  int textBindingCount = 0;
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
  final flatTemplate = <NodeInstanceGenSpec>[];
  specYaml['template'].forEach((nodeSpec) {
    flatTemplate.add(_parseNodeInstanceGenSpec(nodeSpec));
  });
  spec.template = flatTemplate;
  return spec;
}

/// Takes a flat list of nodes and nests them to that they form a tree.
List<NodeInstanceGenSpec> makeTree(List<NodeInstanceGenSpec> flatNodes) {
  // Add an artificial root node
  var root = new NodeInstanceGenSpec();
  flatNodes = [root]..addAll(flatNodes);
  var branchingFactor = sqrt(flatNodes.length).toInt();
  var iter = flatNodes.iterator;
  var q = new Queue();
  iter.moveNext();
  q.addFirst(iter.current);
  while(q.isNotEmpty) {
    var node = q.removeLast();
    int childCount = 0;
    while((q.isEmpty || childCount < branchingFactor) && iter.moveNext()) {
      var child = iter.current;
      if (child.ref.canHaveChildren) {
        q.addFirst(child);
      }
      node.children.add(child);
      childCount++;
    }
  }

  return root.children;
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
      ..propertyBindingCount = firstNonNull(data['props'], 0)
      ..textBindingCount = firstNonNull(data['textBindings'], 0)
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
