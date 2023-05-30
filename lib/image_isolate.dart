import 'dart:io' show  File;
import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

import 'DiplomaCAPI.dart';

Uint8List? _compressionIsolate(img.Image image) {
  DiplomaCAPI api = DiplomaCAPI();
  Uint8List? data = api.compressImage(image, 8, 8, 37);
  return data;
}

Future<Uint8List?> runCompressionIsolate(img.Image image) async {
  return await compute<img.Image, Uint8List?>(_compressionIsolate, image);
}

img.Image? _deCompressionIsolate(Uint8List imageCompressedData) {
  DiplomaCAPI api = DiplomaCAPI();
  return api.decompressImage(imageCompressedData);
  
}

Future<img.Image?> runDecompressionIsolate  (
    Uint8List imageCompressedData) async {
  return await compute<Uint8List, img.Image?>(
      _deCompressionIsolate, imageCompressedData);
}

void _isolate(SendPort sendPort) {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  port.listen((message) {
    String imagePath = message[0];
    SendPort replyPort = message[1];

    try {
      DiplomaCAPI api = DiplomaCAPI();

      img.Image? image = img.decodeImage(File(
              "C:\\Users\\ADMIN\\Downloads\\d8807dc1-2922-42ca-8aa7-ae91f4c4fdd9.png")
          .readAsBytesSync());
      Uint8List? data = api.compressImage(image, 8, 8, 37);
      replyPort.send({data, 'compress'});
      img.Image? imageDecompressed = api.decompressImage(data);
      img.PngEncoder encoder = img.PngEncoder();
      if (imageDecompressed == null) return;
      Uint8List pngBytes = encoder.encode(imageDecompressed);
      replyPort.send({pngBytes, 'decompress'});
      // File f = File("C:/Users/ADMIN/Desktop/testing/out123.png");
      // f.writeAsBytes(pngBytes);
    } catch (e) {
      replyPort.send(e.toString());
    }
  });
}
