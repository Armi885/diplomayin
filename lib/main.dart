import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cross_file/cross_file.dart' show XFile;

import 'package:dotted_border/dotted_border.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_isolate.dart';
import 'package:path/path.dart' as path;

import 'package:image/image.dart' as img;

void main() {
  runApp(const Diploma());
}

class Diploma extends StatelessWidget {
  const Diploma({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desktop Drop Example',
      home: Compress(),
    );
  }
}

class Compress extends StatefulWidget {
  const Compress({super.key});

  @override
  _CompressState createState() => _CompressState();
}

class _CompressState extends State<Compress> {
  void openFileLocation(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $filePath';
    }
  }

  File? _imageDecompressing;
  String imageDimensions = '';

  Color _backgroundColor = const Color.fromRGBO(248, 249, 252, 1);
  bool isShow = false;
  bool isZoom = false;
  bool isDownload = false;

  String? _selectedOption;
  @override
  void initState() {
    super.initState();

    _selectedOption = 'High Quality (Recommend)';
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _dragging = false;
  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(250),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Please wait while your file is being processed",
                    style: TextStyle(
                        color: Color.fromRGBO(120, 120, 120, 1), fontSize: 16)),
                const SizedBox(height: 30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: const Color.fromRGBO(73, 126, 126, 1),
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text("Loading...",
                        style: TextStyle(
                            color: Color.fromRGBO(31, 31, 31, 1),
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    "Unitl the conversion process has been finished, you have the following options:",
                    style: TextStyle(
                        color: Color.fromRGBO(31, 31, 31, 1), fontSize: 16)),
                const Text(
                    "Just wait, the page will update the conversion status automatically.",
                    style: TextStyle(
                        color: Color.fromRGBO(120, 120, 120, 1), fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<XFile> _imageFiles = [];
  List<XFile> _compressedFiles = [];

  bool isCompressingMode = true;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (isCompressingMode) {
      return Scaffold(
          backgroundColor: const Color.fromRGBO(240, 243, 250, 1),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(228, 232, 240, 1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                //228,232,240

                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromRGBO(73, 126, 126, 1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: const Text('Compressing'),
                        onPressed: () {},
                      ),
                      //228,232,240
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                          backgroundColor:
                              const Color.fromRGBO(228, 232, 240, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Decompressing',
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          setState(() {
                            isCompressingMode = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRect(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Attach file'),
                                      IconButton(
                                          onPressed: () async {
                                            if (isCompressingMode) {
                                              FilePickerResult? files =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                          allowMultiple: true,
                                                          type: FileType.image,
                                                          lockParentWindow:
                                                              true);
                                              if (files == null) return;
                                              for (var platformFile
                                                  in files.files) {
                                                setState(() {
                                                  _imageFiles.add(XFile(
                                                      platformFile.path!));
                                                });
                                              }
                                            } else {
                                              FilePickerResult? files =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                          allowMultiple: true,
                                                          type: FileType.custom,
                                                          lockParentWindow:
                                                              true,
                                                          allowedExtensions: [
                                                    "diplomaOut"
                                                  ]);
                                              if (files == null) return;
                                              for (var platformFile
                                                  in files.files) {
                                                setState(() {
                                                  _compressedFiles.add(XFile(
                                                      platformFile.path!));
                                                });
                                              }
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.file_upload_outlined,
                                              color: Color.fromRGBO(
                                                  73, 126, 126, 1))),
                                    ],
                                  ),
                                  const Divider(),
                                  if (_imageFiles.isEmpty)
                                    _buildDropTarget()
                                  else
                                    _buildImageProcessingWidget(
                                        isCompressingMode),
                                  const Divider(),
                                  _buildButtonsRow()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ));
    } else {
      return Scaffold(
          backgroundColor: const Color.fromRGBO(240, 243, 250, 1),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(228, 232, 240, 1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                          backgroundColor:
                              const Color.fromRGBO(228, 232, 240, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Compressing',
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          setState(() {
                            isCompressingMode = true;
                          });
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromRGBO(73, 126, 126, 1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: const Text('Decompressing',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRect(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Attach file'),
                                      IconButton(
                                          onPressed: () async {
                                            final files = await FilePicker
                                                .platform
                                                .pickFiles(
                                                    allowMultiple: false);
                                            if (files == null) return;
                                            for (var platformFile
                                                in files.files) {
                                              setState(() {
                                                _compressedFiles.add(
                                                    XFile(platformFile.path!));
                                              });
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.file_upload_outlined,
                                              color: Color.fromRGBO(
                                                  73, 126, 126, 1))),
                                    ],
                                  ),
                                  const Divider(),
                                  if (_compressedFiles.isEmpty)
                                    _buildDropTarget()
                                  else
                                    _buildImageProcessingWidget(
                                        isCompressingMode),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ));
    }
  }

  String getUin8ListImageSize({required Uint8List uint8ListImage}) {
    double fileSizeInMB = uint8ListImage.lengthInBytes / (1024 * 1024);
    return '${fileSizeInMB.toStringAsFixed(3)} MB';
  }

  Row _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Flexible(
            child: Text('Quality:',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
        Flexible(
          child: RadioListTile(
            title: const Text('Low Quality'),
            value: 'Low Quality',
            activeColor: const Color.fromRGBO(73, 126, 126, 1),
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
        ),
        Flexible(
          child: RadioListTile(
            title: const Text('Standard'),
            value: 'Standard',
            activeColor: const Color.fromRGBO(73, 126, 126, 1),
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
        ),
        Flexible(
          child: RadioListTile(
            title: const Text('High Quality (Recommend)'),
            value: 'High Quality (Recommend)',
            activeColor: const Color.fromRGBO(73, 126, 126, 1),
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void updateUI() {
    setState(() {});
  }

  String getImageName(XFile imageFile) {
    return imageFile.name;
  }

  Future<String> getImageFileSizeInMB(imageFile) async {
    assert(imageFile != null);
    img.Image? decodedImageC = await img.decodeImageFile(imageFile);

    if (decodedImageC == null || decodedImageC.data == null) {
      return "";
    }
    return '${decodedImageC.data!.lengthInBytes / (1024 * 1024)}MB';
  }

  Future<String> getFileSizeInMB(imageFile) async {
    double fileSizeInMB = File(imageFile).lengthSync() / (1024 * 1024);
    return '${fileSizeInMB.toStringAsFixed(3)} MB';
  }

  String getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  Future<String> getImageDimensions(File imageFile) async {
    // Or any other way to get a File instance.

    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    return '${decodedImage.width} * ${decodedImage.height}';
  }

  Future<void> compressionFinished(Uint8List? data) async {
    Navigator.of(context).pop();
    if (data == null || data.isEmpty) {
      //print error message
      return;
    }
    String? result = await FilePicker.platform.saveFile(
        dialogTitle: "Please select dompressed data path.",
        type: FileType.custom,
        allowedExtensions: ["diplomaOut"],
        lockParentWindow: true);
    if (result != null) {
      if (!result.endsWith(".diplomaOut")) result += ".diplomaOut";
      File(result).writeAsBytesSync(data);
    }
    print("finished with ${data.length}");
  }

  Future<void> deCompressionFinished(img.Image? image) async {
    Navigator.of(context).pop();
    if (image == null || image.isEmpty) {
      //print error message
      return;
    }

    String? result = await FilePicker.platform.saveFile(
        dialogTitle: "Please select output data path.",
        type: FileType.custom,
        allowedExtensions: ["png"],
        lockParentWindow: true);
    if (result != null) {
      if (!result.endsWith(".png")) result += ".png";
      var data = img.encodeNamedImage(result, image);
      if (data == null || data.isEmpty) {
        //print error message
        return;
      }
      File(result).writeAsBytesSync(data);
      setState(() {
        _imageDecompressing = File(result!);
      });
    }

    print("finished with $image");
  }

  _buildImageProcessingWidget(bool isCompressor) {
    return MouseRegion(
      onEnter: (event) => _removeImage(true),
      onExit: (event) => _removeImage(false),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          color: const Color.fromRGBO(247, 249, 252, 1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _imageDecompressing != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MouseRegion(
                        onEnter: (event) => _zoomImage(true),
                        onExit: (event) => _zoomImage(false),
                        child: Stack(
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.black26.withOpacity(isZoom ? 0.4 : 0),
                                  BlendMode.srcOver),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: SizedBox(
                                  width:
                                      120, // Set a specific width for the container
                                  height: 120,
                                  child: AspectRatio(
                                    aspectRatio: 16 /
                                        9, // Set the desired aspect ratio here
                                    child: Image.file(
                                      _imageDecompressing!,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isZoom)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    openFileLocation(_imageDecompressing!.path);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: const [
                                      Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      Text('Open Image',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              path.basename(_imageDecompressing!.path),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: Row(
                                children: [
                                  Image.file(
                                    File(
                                        'C://Users//ADMIN//Downloads//resolution.png'),
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.fill,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(_getImageDimensions(
                                      filePath: _imageDecompressing!.path)),
                                ],
                              ),
                            ),
                            // IconButton(
                            //   icon: const Icon(Icons.folder),
                            //   onPressed: () async {
                            //     openFileLocation(imageDecompressing!.path);
                            //   },
                            // )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return informationDialog(isCompressingMode);
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const InkResponse(
                              containedInkWell: true,
                              child: Icon(Icons.close, color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCompressor)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: SizedBox(
                            width:
                                120, // Set a specific width for the container
                            height: 120,
                            child: AspectRatio(
                              aspectRatio:
                                  16 / 9, // Set the desired aspect ratio here
                              child: Image.file(
                                File(isCompressor
                                    ? _imageFiles[0].path
                                    : _compressedFiles[0].path),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: SizedBox(
                              width:
                                  120, // Set a specific width for the container
                              height: 120,
                              child: Container(
                                //240,243,250
                                color: const Color.fromRGBO(240, 243, 250, 1),
                                child: Image.file(
                                  File('C://Users//ADMIN//Documents//doc.png'),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fill,
                                ),
                              )),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getImageName(
                                isCompressor
                                    ? _imageFiles[0]
                                    : _compressedFiles[0],
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            DottedBorder(
                              borderType: BorderType.RRect,
                              dashPattern: const [6, 3, 2, 3],
                              color: const Color.fromRGBO(224, 229, 238, 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.folder,
                                          color:
                                              Color.fromRGBO(73, 126, 126, 1),
                                        ),
                                        const SizedBox(width: 5),
                                        FutureBuilder(
                                          future: isCompressor
                                              ? getImageFileSizeInMB(
                                                  _imageFiles[0].path)
                                              : getFileSizeInMB(
                                                  _compressedFiles[0].path),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                snapshot.data!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              );
                                            }
                                            return Container();
                                          },
                                        ),
                                      ],
                                    ),
                                    if (isCompressor)
                                      Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 2,
                                            backgroundColor: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(getFileExtension(
                                              _imageFiles[0].name)),
                                          const SizedBox(width: 20),
                                          const CircleAvatar(
                                            radius: 2,
                                            backgroundColor: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(_getImageDimensions(
                                              filePath: _imageFiles[0].path)),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isShow)
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return informationDialog(
                                          isCompressingMode);
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: const InkResponse(
                                  containedInkWell: true,
                                  child: Icon(Icons.close, color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            Container(),
                          Padding(
                            padding: isShow
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(top: 25.0),
                            child: Center(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color.fromRGBO(73, 126, 126, 1),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _onLoading();
                                  if (isCompressor) {
                                    img.Image? image = img.decodeImage(
                                      File(_imageFiles[0].path)
                                          .readAsBytesSync(),
                                    );
                                    if (image != null) {
                                      runCompressionIsolate(image)
                                          .then((value) => {
                                                compressionFinished(value),
                                              })
                                          .onError((error, stackTrace) => {});
                                    }
                                  } else {
                                    var data = File(_compressedFiles[0].path)
                                        .readAsBytesSync();
                                    runDecompressionIsolate(data)
                                        .then((value) => {
                                              deCompressionFinished(value),
                                            })
                                        .onError((error, stackTrace) => {});
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                      isCompressor ? 'Compress' : 'Decompress'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _getImageDimensions({required String filePath}) {
    File image = File(filePath);
    decodeImageFromList(image.readAsBytesSync()).then((value) {
      setState(() {
        imageDimensions = '${value.height} * ${value.width}';
      });
    });
    return imageDimensions;
  }

  void _onHover(bool isHovered) {
    setState(() {
      _backgroundColor = isHovered
          ? const Color.fromRGBO(242, 244, 248, 1)
          : const Color.fromRGBO(248, 249, 252, 1);
    });
  }

  void _removeImage(bool isRemoved) {
    setState(() {
      isShow = isRemoved;
    });
  }

  void _zoomImage(bool isZoomed) {
    setState(() {
      isZoom = isZoomed;
    });
  }

  informationDialog(bool isCompressor) {
    return AlertDialog(
      title: const Text('Information'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: const [
                  Icon(Icons.info, color: Color.fromRGBO(73, 126, 126, 1)),
                  SizedBox(width: 4),
                  Text('Are you sure you want to remove this selected item?'),
                ],
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
                const Color.fromRGBO(73, 126, 126, 1)),
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 239, 44, 30)),
          ),
          child: const Text('Remove'),
          onPressed: () {
            if (isCompressor) {
              setState(() {
                _imageFiles = [];
              });
            } else {
              setState(() {
                _compressedFiles = [];
              });
            }

            // Perform submit action
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  DropTarget _buildDropTarget() {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          _imageFiles.addAll(detail.files);
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: MouseRegion(
        onEnter: (event) => _onHover(true),
        onExit: (event) => _onHover(false),
        child: GestureDetector(
          onTap: () async {
            if (isCompressingMode) {
              FilePickerResult? files = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.image,
                  lockParentWindow: true);
              if (files == null) return;
              for (var platformFile in files.files) {
                setState(() {
                  _imageFiles.add(XFile(platformFile.path!));
                });
              }
            } else {
              FilePickerResult? files = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  lockParentWindow: true,
                  allowedExtensions: ["diplomaOut"]);
              if (files == null) return;
              for (var platformFile in files.files) {
                setState(() {
                  _compressedFiles.add(XFile(platformFile.path!));
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: ClipRect(
              child: Card(
                color: _backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [6, 3, 2, 3],
                  color: const Color.fromRGBO(222, 227, 238, 1),
                  strokeWidth: 2,
                  child: Container(
                      height: 250,
                      width: 500,
                      color: _dragging
                          ? Colors.blue.withOpacity(0.4)
                          : _backgroundColor,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_download,
                                size: 64,
                                color: Color.fromRGBO(73, 126, 126, 1)),
                            Text(
                                isCompressingMode
                                    ? 'Add or drag file here to start compression'
                                    : 'Add or drag file here to start decompression',
                                style: const TextStyle(
                                    color: Color.fromRGBO(72, 72, 82, 1))),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Row(
                                children: [
                                  const Text('Step 1: Add ',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(72, 72, 82, 1))),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.file_upload_outlined,
                                      color: Color.fromRGBO(73, 126, 126, 1)),
                                  const SizedBox(width: 8),
                                  Text(
                                      isCompressingMode
                                          ? 'or drag file  here to start compression.'
                                          : 'or drag file here to start decompression.',
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(72, 72, 82, 1))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Row(
                                children: [
                                  Text(
                                      isCompressingMode
                                          ? 'Step 2: Start compression.'
                                          : 'Step 2: Start decompression.',
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(72, 72, 82, 1))),
                                ],
                              ),
                            )
                          ])),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
