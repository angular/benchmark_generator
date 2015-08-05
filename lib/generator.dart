library app_generator;

import 'dart:convert';
import 'package:boilerplate/boilerplate.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:quiver/core.dart';

part 'src/gen_spec.dart';
part 'src/vfs.dart';

final JsonEncoder json = new JsonEncoder.withIndent('  ');

abstract class Generator {
  VFileSystem generate(AppGenSpec genSpec);
}
