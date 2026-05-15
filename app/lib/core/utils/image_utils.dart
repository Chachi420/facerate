import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file) async {
  final bytes = await file.readAsBytes();
  var image = img.decodeImage(bytes);
  if (image == null) return file;

  if (image.width > 800) {
    image = img.copyResize(image, width: 800);
  }

  final compressed = img.encodeJpg(image, quality: 80);

  // Only use compressed version if it's actually smaller
  if (compressed.length >= bytes.length) return file;

  final tempDir = await getTemporaryDirectory();
  final outFile = File(
    '${tempDir.path}/fr_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  await outFile.writeAsBytes(compressed);
  return outFile;
}
