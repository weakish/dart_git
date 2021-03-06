import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:dart_git/plumbing/reference.dart';

class ReferenceStorage {
  String dotGitDir;

  ReferenceStorage(this.dotGitDir);

  Future<Reference> reference(ReferenceName refName) async {
    var file = File(p.join(dotGitDir, refName.value));
    if (file.existsSync()) {
      var contents = await file.readAsString();
      return Reference(refName.value, contents.trimRight());
    }

    var packedRefsFile = File(p.join(dotGitDir, 'packed-refs'));
    if (!packedRefsFile.existsSync()) {
      return null;
    }

    var contents = await packedRefsFile.readAsString();
    for (var ref in _loadPackedRefs(contents)) {
      if (ref.name == refName) {
        return ref;
      }
    }

    return null;
  }
}

Iterable<Reference> _loadPackedRefs(String raw) sync* {
  for (var line in LineSplitter.split(raw)) {
    if (line.startsWith('#')) {
      continue;
    }

    var parts = line.split(' ');
    assert(parts.length == 2);
    if (parts.length != 2) {
      continue;
    }
    yield Reference(parts[1], parts[0]);
  }
}
