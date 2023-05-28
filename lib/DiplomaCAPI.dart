import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import 'main.dart';

typedef NativeMatPtr = ffi.IntPtr;
typedef NativeSerializedDataPtr = ffi.IntPtr;

// FFI signature of the hello_world C function
typedef createEmptyMatSignature = NativeMatPtr Function();
// Dart type definition for calling the C foreign function
typedef createEmptyMat_t = int Function();

typedef createMatSignature = NativeMatPtr Function(
    ffi.Int32 cols, ffi.Int32 rows, ffi.Int32 channels);
typedef createMat_t = int Function(int cols, int rows, int channels);

typedef createMatAndFillSignature = NativeMatPtr Function(
    ffi.Int32 cols, ffi.Int32 rows, ffi.Int32 channels, ffi.Int32 dataPtr);
typedef createMatAndFill_t = int Function(
    int cols, int rows, int channels, int dataPtr);

typedef destroyMatSignature = ffi.Void Function(NativeMatPtr matPtr);
typedef destroyMat_t = void Function(int matPtr);

typedef imshowSignature = ffi.Void Function(
    ffi.Pointer<Utf8> windowName, NativeMatPtr matPtr);
typedef imshow_t = void Function(ffi.Pointer<Utf8> windoeName, int matPtr);

//SerializedData DiplomaCompressorCApi_createSerializedData(int size, char* data);
typedef createSerializedDataSignature = NativeSerializedDataPtr Function(
    ffi.Int32 size, ffi.Int32 dataPtr);
typedef createSerializedData_t = int Function(int, int dataPtr);

//SerializedData DiplomaCompressorCApi_createSerializedData(int size, char* data);
typedef destroySerializedDataSignature = ffi.Void Function(ffi.Int32 dataPtr);
typedef destroySerializedData_t = void Function(int dataPtr);

// __declspec(dllexport) ApiMat DiplomaCompressorCApi_deCompress(SerializedData serializedData);
typedef deCompressSignature = NativeMatPtr Function(
    NativeSerializedDataPtr serializedData);
typedef deCompress_t = int Function(int dataPtr);

// __declspec(dllexport) SerializedData DiplomaCompressorCApi_compress(ApiMat MatPtr);
typedef compressSignature = NativeSerializedDataPtr Function(
    NativeMatPtr matPtr, ffi.Int32 m, ffi.Int32 n, ffi.Int32 p);
typedef compress_t = int Function(int matPtr, int m, int n, int p);

// __declspec(dllexport) void DiplomaCompressorCApi_getMatParams(ApiMat, int* cols, int* rows, int* channels, int* dataSize);
typedef getMatParamsSignature = ffi.Void Function(NativeMatPtr matPtr,
    ffi.IntPtr cols, ffi.IntPtr rows, ffi.IntPtr channels, ffi.IntPtr dataSize);
typedef getMatParams_t = void Function(
    int matPtr, int colsPtr, int rowsPtr, int channelsPtr, int dataSizePtr);

// __declspec(dllexport) void DiplomaCompressorCApi_getMatData(ApiMat,char*);
typedef getMatDataSignature = ffi.Void Function(
    NativeMatPtr matPtr, ffi.IntPtr dataPtr);
typedef getMatData_t = void Function(int matPtr, int dataPtr);

class DiplomaCAPI {
  DiplomaCAPI({required String imagePath}) {
    var libraryPath = path.join(Directory.current.path, 'DNNCompression.dll');
    final dylib = ffi.DynamicLibrary.open(libraryPath);

    final createEmptyMat_t createEmptyMat = dylib
        .lookup<ffi.NativeFunction<createEmptyMatSignature>>(
            'DiplomaCompressorCApi_createEmptyMat')
        .asFunction<createEmptyMat_t>();

    final createMat_t createMat = dylib
        .lookup<ffi.NativeFunction<createMatSignature>>(
            'DiplomaCompressorCApi_createMat')
        .asFunction<createMat_t>();

    final createMatAndFill_t createMatAndFill = dylib
        .lookup<ffi.NativeFunction<createMatAndFillSignature>>(
            'DiplomaCompressorCApi_createMatAndFill')
        .asFunction<createMatAndFill_t>();

    final getMatParams_t getMatParams = dylib
        .lookup<ffi.NativeFunction<getMatParamsSignature>>(
            'DiplomaCompressorCApi_getMatParams')
        .asFunction<getMatParams_t>();

    final imshow_t imshow = dylib
        .lookup<ffi.NativeFunction<imshowSignature>>(
            'DiplomaCompressorCApi_imshow')
        .asFunction<imshow_t>();

    final destroyMat_t destroyMat = dylib
        .lookup<ffi.NativeFunction<destroyMatSignature>>(
            'DiplomaCompressorCApi_destroyMat')
        .asFunction<destroyMat_t>();
    final createSerializedData_t createSerializedData = dylib
        .lookup<ffi.NativeFunction<createSerializedDataSignature>>(
            'DiplomaCompressorCApi_createSerializedData')
        .asFunction<createSerializedData_t>();

    final destroySerializedData_t destroySerializedData = dylib
        .lookup<ffi.NativeFunction<destroySerializedDataSignature>>(
            'DiplomaCompressorCApi_destroySerializedData')
        .asFunction<destroySerializedData_t>();

    final deCompress_t deCompress = dylib
        .lookup<ffi.NativeFunction<deCompressSignature>>(
            'DiplomaCompressorCApi_deCompress')
        .asFunction<deCompress_t>();

    final compress_t compress = dylib
        .lookup<ffi.NativeFunction<compressSignature>>(
            'DiplomaCompressorCApi_compress')
        .asFunction<compress_t>();
    final getMatData_t getMatData = dylib
        .lookup<ffi.NativeFunction<getMatDataSignature>>(
            'DiplomaCompressorCApi_getMatData')
        .asFunction<getMatData_t>();
    // List<int> list = [];
    // for (int i = 0; i < 500 * 500; ++i) {
    //   list.add(255);
    //   list.add(0);
    //   list.add(0);
    // }

    // String imagepath =

    //     "C:\\Users\\ADMIN\\Downloads\\d8807dc1-2922-42ca-8aa7-ae91f4c4fdd9.png";

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

      //createMatAndFill(500, 500, 3, intListToArray(list).address);
      ffi.Pointer<ffi.Int32> colsPtr =
          malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
      ffi.Pointer<ffi.Int32> rowsPtr =
          malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

      ffi.Pointer<ffi.Int32> channelsPtr =
          malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

      ffi.Pointer<ffi.Int32> dataSizePtr =
          malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
      {
        getMatParams(matImg, colsPtr.address, rowsPtr.address,
            channelsPtr.address, dataSizePtr.address);

        int cols = colsPtr.value;
        int rows = rowsPtr.value;
        int channels = channelsPtr.value;
        int dataSize = dataSizePtr.value;

        malloc.free(colsPtr);
        malloc.free(rowsPtr);
        malloc.free(channelsPtr);
        malloc.free(dataSizePtr);

        ffi.Pointer<ffi.Int8> imgDataPtr =
            malloc.allocate<ffi.Int8>(ffi.sizeOf<ffi.Int8>() * dataSize);
        getMatData(matImg, imgDataPtr.address);

        img.Image image =
            img.Image(height: rows, width: cols, numChannels: channels);
        for (int y = 0; y < rows; ++y) {
          for (int x = 0; x < cols; ++x) {
            img.Color c = img.ColorInt8(channels);
            for (int i = 0; i < channels; ++i) {
              c[i] = imgDataPtr
                  .elementAt(y * (cols * channels) + (x * channels) + i)
                  .value;
            }
            image.setPixel(x, y, c);
          }
        }
        malloc.free(imgDataPtr);
        img.PngEncoder encoder = img.PngEncoder();
        Uint8List pngBytes = encoder.encode(image);
        File f = File("C:/Users/ADMIN/Desktop/testing/out.png");
        f.writeAsBytes(pngBytes);
      }
      imshow(backwardsUtf82, matImg);

      destroySerializedData(compressedData);

      calloc.free(backwardsUtf8);
      calloc.free(backwardsUtf82);
      destroyMat(matImg);
    } else {
      print(" img.decodeImage = null");
    }
  }

  ffi.Pointer<ffi.Int8> intListToArray(List<int> list) {
    final ptr = malloc.allocate<ffi.Int8>(ffi.sizeOf<ffi.Int8>() * list.length);
    for (var i = 0; i < list.length; i++) {
      ptr.elementAt(i).value = list[i];
    }
    return ptr;
  }

  ffi.Pointer<ffi.Int8> uint8ListToArray(Uint8List list) {
    final ptr = malloc.allocate<ffi.Int8>(ffi.sizeOf<ffi.Int8>() * list.length);
    for (var i = 0; i < list.length; i++) {
      ptr.elementAt(i).value = list[i];
    }
    return ptr;
  }
}
// __declspec(dllexport) ApiMat DiplomaCompressorCApi_createEmptyMat();
// __declspec(dllexport) ApiMat DiplomaCompressorCApi_createMat(int cols,int rows,int channels);
// __declspec(dllexport) ApiMat DiplomaCompressorCApi_createMatAndFill(int cols,int rows,int channels,void* data);
// __declspec(dllexport) void DiplomaCompressorCApi_getMatParams(ApiMat, int* cols, int* rows, int* channels, int* dataSize);
// __declspec(dllexport) void DiplomaCompressorCApi_getMatData(ApiMat,char*);
// __declspec(dllexport) void DiplomaCompressorCApi_destroyMat(ApiMat);
//__declspec(dllexport) void DiplomaCompressorCApi_imshow(char* name,void* mat);

// __declspec(dllexport) SerializedData DiplomaCompressorCApi_compress(ApiMat MatPtr,int m,int n,int p);
// __declspec(dllexport) ApiMat DiplomaCompressorCApi_deCompress(SerializedData serializedData);

// __declspec(dllexport) int DiplomaCompressorCApi_sizeOfSerializedData(SerializedData);
// __declspec(dllexport) SerializedData DiplomaCompressorCApi_createSerializedData(int size, char* data);
// __declspec(dllexport) SerializedData DiplomaCompressorCApi_createEmptySerializedData();
// __declspec(dllexport) void DiplomaCompressorCApi_getDataFromSerializedData(SerializedData serializedData,char* data);
// __declspec(dllexport) void DiplomaCompressorCApi_setDataToSerializedData(int size, char* data, SerializedData);
// __declspec(dllexport) void DiplomaCompressorCApi_destroySerializedData(SerializedData);
