library benchmark_generator.vfs.test;

import 'package:test/test.dart';
import 'package:benchmark_generator/generator.dart';

main() {
  group('VFile', () {
    test('should have a path and file contents', () {
      var f = new VFile('a', 'b');
      expect(f.path, 'a');
      expect(f.contents, 'b');
    });
  });

  group('VFileSystem', () {
    test('should store virtual files', () {
      var vfs = new VFileSystem();
      vfs.addFile('a', 'b');
      vfs.addFile('c', 'd');
      expect(vfs.files, hasLength(2));
      expect(vfs.files[0].path, 'a');
      expect(vfs.files[0].contents, 'b');
      expect(vfs.files[1].path, 'c');
      expect(vfs.files[1].contents, 'd');
    });
  });
}
