import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import 'DiplomaCAPI.dart';

class DiplomCAPI {
  int matImgDecompress = 0;
  static final ReceivePort _response = ReceivePort();

  static ReceivePort get response => _response;

  DiplomCAPI({required String imagePath}) {
    runInIsolate(imagePath);
  }

  void runInIsolate(String imagePath) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_isolate, receivePort.sendPort);

    SendPort sendPort = await receivePort.first;

    sendPort.send([imagePath, response.sendPort]);
  }
}

void _isolate(SendPort sendPort) {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  port.listen((message) {
    String imagePath = message[0];
    SendPort replyPort = message[1];

    try {} catch (e) {
      replyPort.send(e.toString());
    }
  });
}

ffi.Pointer<ffi.Int8> uint8ListToArray(Uint8List list) {
  final ptr = malloc.allocate<ffi.Int8>(ffi.sizeOf<ffi.Int8>() * list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}
