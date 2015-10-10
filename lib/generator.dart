library benchmark_generator;

import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:boilerplate/boilerplate.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:quiver/core.dart';

part 'src/gen_spec.dart';
part 'src/vfs.dart';

final JsonEncoder json = new JsonEncoder.withIndent('  ');

abstract class Generator {
  VFileSystem generate(AppGenSpec genSpec);
}
