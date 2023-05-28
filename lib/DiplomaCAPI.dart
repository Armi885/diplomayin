import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

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

// __declspec(dllexport) int DiplomaCompressorCApi_sizeOfSerializedData(SerializedData);
typedef sizeOfSerializedDataSignature = ffi.Int Function(
    NativeSerializedDataPtr serDataPtr);
typedef sizeOfSerializedData_t = int Function(int serDataPtr);

// __declspec(dllexport) void DiplomaCompressorCApi_getDataFromSerializedData(SerializedData serializedData,char* data);
typedef getDataFromSerializedDataSignature = ffi.Void Function(
    NativeSerializedDataPtr serDatPtr, ffi.IntPtr dataPtr);
typedef getDataFromSerializedData_t = void Function(int serDatPtr, int dataPtr);

class DiplomaCAPI {
  late final ffi.DynamicLibrary _dylib = ffi.DynamicLibrary.open(
      path.join(Directory.current.path, 'DNNCompression.dll'));

  late final createEmptyMat_t _createEmptyMat = _dylib
      .lookup<ffi.NativeFunction<createEmptyMatSignature>>(
          'DiplomaCompressorCApi_createEmptyMat')
      .asFunction<createEmptyMat_t>();

  late final createMat_t _createMat = _dylib
      .lookup<ffi.NativeFunction<createMatSignature>>(
          'DiplomaCompressorCApi_createMat')
      .asFunction<createMat_t>();

  late final createMatAndFill_t _createMatAndFill = _dylib
      .lookup<ffi.NativeFunction<createMatAndFillSignature>>(
          'DiplomaCompressorCApi_createMatAndFill')
      .asFunction<createMatAndFill_t>();

  late final getMatParams_t _getMatParams = _dylib
      .lookup<ffi.NativeFunction<getMatParamsSignature>>(
          'DiplomaCompressorCApi_getMatParams')
      .asFunction<getMatParams_t>();

  late final imshow_t _imshow = _dylib
      .lookup<ffi.NativeFunction<imshowSignature>>(
          'DiplomaCompressorCApi_imshow')
      .asFunction<imshow_t>();

  late final destroyMat_t _destroyMat = _dylib
      .lookup<ffi.NativeFunction<destroyMatSignature>>(
          'DiplomaCompressorCApi_destroyMat')
      .asFunction<destroyMat_t>();
  late final createSerializedData_t _createSerializedData = _dylib
      .lookup<ffi.NativeFunction<createSerializedDataSignature>>(
          'DiplomaCompressorCApi_createSerializedData')
      .asFunction<createSerializedData_t>();

  late final destroySerializedData_t _destroySerializedData = _dylib
      .lookup<ffi.NativeFunction<destroySerializedDataSignature>>(
          'DiplomaCompressorCApi_destroySerializedData')
      .asFunction<destroySerializedData_t>();

  late final deCompress_t _deCompress = _dylib
      .lookup<ffi.NativeFunction<deCompressSignature>>(
          'DiplomaCompressorCApi_deCompress')
      .asFunction<deCompress_t>();

  late final compress_t _compress = _dylib
      .lookup<ffi.NativeFunction<compressSignature>>(
          'DiplomaCompressorCApi_compress')
      .asFunction<compress_t>();
  late final getMatData_t _getMatData = _dylib
      .lookup<ffi.NativeFunction<getMatDataSignature>>(
          'DiplomaCompressorCApi_getMatData')
      .asFunction<getMatData_t>();

  late final getDataFromSerializedData_t _getDataFromSerializedData = _dylib
      .lookup<ffi.NativeFunction<getDataFromSerializedDataSignature>>(
          'DiplomaCompressorCApi_getDataFromSerializedData')
      .asFunction<getDataFromSerializedData_t>();

  late final sizeOfSerializedData_t _sizeOfSerializedData = _dylib
      .lookup<ffi.NativeFunction<sizeOfSerializedDataSignature>>(
          'DiplomaCompressorCApi_sizeOfSerializedData')
      .asFunction<sizeOfSerializedData_t>();

  Uint8List? compressImage(img.Image? image, int m, int n, int p) {
    if (image == null) return null;
    Uint8List pixelsRawList =
        Uint8List(image.width * image.height * image.numChannels);
    for (var pixel in image) {
      int index = pixel.x * image.numChannels +
          image.width * image.numChannels * pixel.y;
      pixelsRawList[index + 2] = pixel.r.toInt();
      pixelsRawList[index + 1] = pixel.g.toInt();
      pixelsRawList[index + 0] = pixel.b.toInt();
    }

    var rawNative = _uint8ListToArray(pixelsRawList);

    var matImg = _createMatAndFill(
        image.width, image.height, image.numChannels, rawNative.address);
    calloc.free(rawNative);

    //imshow(backwardsUtf8, matImg);

    var compressedData = _compress(matImg, m, n, p);

    Uint8List? data;
    {
      int serialziedDataSize = _sizeOfSerializedData(compressedData);
      ffi.Pointer<ffi.Int8> serialziedDataPtr = malloc
          .allocate<ffi.Int8>(ffi.sizeOf<ffi.Int8>() * serialziedDataSize);
      _getDataFromSerializedData(compressedData, serialziedDataPtr.address);
      data = Uint8List(serialziedDataSize);
      for (int i = 0; i < serialziedDataSize; ++i) {
        data[i] = serialziedDataPtr.elementAt(i).value;
      }
      malloc.free(serialziedDataPtr);
    }

    _destroySerializedData(compressedData);
    _destroyMat(matImg);

    return data;
  }

  img.Image? decompressImage(Uint8List? input) {
    if (input == null) return null;
    var data = _uint8ListToArray(input);
    var compressedData = _createSerializedData(input.length, data.address);
    var matImg = _deCompress(compressedData);
    malloc.free(data);

    ffi.Pointer<ffi.Int32> colsPtr =
        malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
    ffi.Pointer<ffi.Int32> rowsPtr =
        malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

    ffi.Pointer<ffi.Int32> channelsPtr =
        malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

    ffi.Pointer<ffi.Int32> dataSizePtr =
        malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

    _getMatParams(matImg, colsPtr.address, rowsPtr.address, channelsPtr.address,
        dataSizePtr.address);

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

    _getMatData(matImg, imgDataPtr.address);

    img.Image image =
        img.Image(height: rows, width: cols, numChannels: channels);
    for (int y = 0; y < rows; ++y) {
      for (int x = 0; x < cols; ++x) {
        img.Color c = img.ColorInt8(channels);
        for (int i = 0; i < channels; ++i) {
          c[i] = imgDataPtr
              .elementAt(
                  y * (cols * channels) + (x * channels) + (channels - 1 - i))
              .value;
        }
        image.setPixel(x, y, c);
      }
    }
    malloc.free(imgDataPtr);
    _destroyMat(matImg);
    _destroySerializedData(compressedData);
    return image;
  }

  DiplomaCAPI();

  // ffi.Pointer<ffi.Int8> _intListToArray(List<int> list) {
  //   final ptr = malloc.allocate<ffi.Int8>(ffi.sizeOf<ffi.Int8>() * list.length);
  //   for (var i = 0; i < list.length; i++) {
  //     ptr.elementAt(i).value = list[i];
  //   }
  //   return ptr;
  // }

  ffi.Pointer<ffi.Int8> _uint8ListToArray(Uint8List list) {
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

// __declspec(dllexport) SerializedData DiplomaCompressorCApi_createSerializedData(int size, char* data);
// __declspec(dllexport) SerializedData DiplomaCompressorCApi_createEmptySerializedData();
// __declspec(dllexport) void DiplomaCompressorCApi_getDataFromSerializedData(SerializedData serializedData,char* data);
// __declspec(dllexport) void DiplomaCompressorCApi_setDataToSerializedData(int size, char* data, SerializedData);
// __declspec(dllexport) void DiplomaCompressorCApi_destroySerializedData(SerializedData);
