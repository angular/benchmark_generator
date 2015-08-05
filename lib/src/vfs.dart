part of app_generator;

class VFileSystem {
  List<VFile> files = <VFile>[];

  VFile addFile(String path, String contents) {
    files.add(new VFile(path, contents));
  }

  VFile getFile(String path) {
    return files.firstWhere((f) => f.path == path);
  }
}

class VFile {
  final String path;
  final String contents;

  VFile(this.path, this.contents);
}
