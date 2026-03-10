import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class Sharer {
  static Future<void> exportUint8List(
      BuildContext context, Uint8List uint8List, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, fileName));
    await file.writeAsBytes(uint8List);
    final rect = resolveSharePositionOrigin(context);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], sharePositionOrigin: rect),
    );
  }

  @visibleForTesting
  static Rect resolveSharePositionOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery != null && mediaQuery.size != Size.zero) {
      final size = mediaQuery.size;
      return Rect.fromLTWH(0, 0, size.width, size.height);
    }
    return Rect.zero;
  }
}
