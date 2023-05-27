import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import 'DiplomaCAPI.dart';

typedef NativeMatPtr = ffi.IntPtr;
typedef NativeSerializedDataPtr = ffi.IntPtr;

typedef CreateEmptyMatSignature = NativeMatPtr Function();
typedef CreateEmptyMat_t = int Function();

typedef CreateMatSignature = NativeMatPtr Function(
    ffi.Int32 cols, ffi.Int32 rows, ffi.Int32 channels);
typedef CreateMat_t = int Function(int cols, int rows, int channels);

typedef CreateMatAndFillSignature = NativeMatPtr Function(
    ffi.Int32 cols, ffi.Int32 rows, ffi.Int32 channels, ffi.Int32 dataPtr);
typedef CreateMatAndFill_t = int Function(
    int cols, int rows, int channels, int dataPtr);

typedef DestroyMatSignature = ffi.Void Function(NativeMatPtr matPtr);
typedef DestroyMat_t = void Function(int matPtr);

typedef ImshowSignature = ffi.Void Function(
    ffi.Pointer<Utf8> windowName, NativeMatPtr matPtr);
typedef Imshow_t = void Function(ffi.Pointer<Utf8> windowName, int matPtr);

typedef CreateSerializedDataSignature = NativeSerializedDataPtr Function(
    ffi.Int32 size, ffi.Int32 dataPtr);
typedef CreateSerializedData_t = int Function(int, int dataPtr);

typedef DestroySerializedDataSignature = ffi.Void Function(ffi.Int32 dataPtr);
typedef DestroySerializedData_t = void Function(int dataPtr);

typedef DeCompressSignature = NativeMatPtr Function(
    NativeSerializedDataPtr serializedData);
typedef DeCompress_t = int Function(int dataPtr);

typedef CompressSignature = NativeSerializedDataPtr Function(
    NativeMatPtr matPtr, ffi.Int32 m, ffi.Int32 n, ffi.Int32 p);
typedef Compress_t = int Function(int matPtr, int m, int n, int p);

class DiplomCAPI {
  int matImgDecompress = 0;

  DiplomCAPI({required String imagePath}) {
    runInIsolate(imagePath);
  }

  void runInIsolate(String imagePath) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_isolate, receivePort.sendPort);

    SendPort sendPort = await receivePort.first;
    ReceivePort response = ReceivePort();

    sendPort.send([imagePath, response.sendPort]);

    response.listen((data) {
      if (data is int) {
        print('The image succesfuly   decompressed');
        print('deCompressData:$data');
        
      } else if (data is Uint8List) {
      } else {
        print('Error when image compressed');
        print('vuxxx amannn');
      }
    });
  }
}

void _isolate(SendPort sendPort) {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  port.listen((message) {
    String imagePath = message[0];
    SendPort replyPort = message[1];

    try {
      var libraryPath = path.join(Directory.current.path, 'DNNCompression.dll');
      final dylib = ffi.DynamicLibrary.open(libraryPath);

      final createEmptyMat_t createEmptyMat = dylib
          .lookup<ffi.NativeFunction<CreateEmptyMatSignature>>(
              'DiplomaCompressorCApi_createEmptyMat')
          .asFunction<CreateEmptyMat_t>();

      final createMat_t createMat = dylib
          .lookup<ffi.NativeFunction<CreateMatSignature>>(
              'DiplomaCompressorCApi_createMat')
          .asFunction<CreateMat_t>();

      final createMatAndFill_t createMatAndFill = dylib
          .lookup<ffi.NativeFunction<CreateMatAndFillSignature>>(
              'DiplomaCompressorCApi_createMatAndFill')
          .asFunction<CreateMatAndFill_t>();

      final imshow_t imshow = dylib
          .lookup<ffi.NativeFunction<ImshowSignature>>(
              'DiplomaCompressorCApi_imshow')
          .asFunction<Imshow_t>();

      final destroyMat_t destroyMat = dylib
          .lookup<ffi.NativeFunction<DestroyMatSignature>>(
              'DiplomaCompressorCApi_destroyMat')
          .asFunction<DestroyMat_t>();

      final createSerializedData_t createSerializedData = dylib
          .lookup<ffi.NativeFunction<CreateSerializedDataSignature>>(
              'DiplomaCompressorCApi_createSerializedData')
          .asFunction<CreateSerializedData_t>();

      final destroySerializedData_t destroySerializedData = dylib
          .lookup<ffi.NativeFunction<DestroySerializedDataSignature>>(
              'DiplomaCompressorCApi_destroySerializedData')
          .asFunction<DestroySerializedData_t>();

      final deCompress_t deCompress = dylib
          .lookup<ffi.NativeFunction<DeCompressSignature>>(
              'DiplomaCompressorCApi_deCompress')
          .asFunction<DeCompress_t>();

      final compress_t compress = dylib
          .lookup<ffi.NativeFunction<CompressSignature>>(
              'DiplomaCompressorCApi_compress')
          .asFunction<Compress_t>();

      img.Image? image = img.decodeImage(File(imagePath).readAsBytesSync());

      if (image != null) {
        const backwards = 'Before compression';
        final backwardsUtf8 = backwards.toNativeUtf8();
        const backwards2 = 'After decompression';
        final backwardsUtf82 = backwards2.toNativeUtf8();

        image = image.convert(numChannels: 3);

        Uint8List pixelsRawList =
            Uint8List(image.width * image.height * image.numChannels);

        for (var pixel in image) {
          int index = pixel.x * image.numChannels +
              image.width * image.numChannels * pixel.y;
          pixelsRawList[index + 2] = pixel.r.toInt();
          pixelsRawList[index + 1] = pixel.g.toInt();
          pixelsRawList[index + 0] = pixel.b.toInt();
        }

        var rawNative = uint8ListToArray(pixelsRawList);
        var matImg = createMatAndFill(
            image.width, image.height, image.numChannels, rawNative.address);
        calloc.free(rawNative);

        imshow(backwardsUtf8, matImg);

        var compressedData = compress(matImg, 8, 8, 37);
        destroyMat(matImg);
        matImg = 0;

        matImg = deCompress(compressedData);

        replyPort.send(matImg);

        destroySerializedData(compressedData);

        calloc.free(backwardsUtf8);
        calloc.free(backwardsUtf82);
        destroyMat(matImg);
      } else {
        replyPort.send('Image decode error');
      }
    } catch (e) {
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
