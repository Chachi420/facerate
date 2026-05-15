import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareImage(Uint8List bytes, String text) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/facerate_share_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path)], text: text);
}

Future<void> saveImageToGallery(Uint8List bytes) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/facerate_card_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes);
  // Share with no text so user can save to gallery
  await Share.shareXFiles([XFile(file.path)]);
}
