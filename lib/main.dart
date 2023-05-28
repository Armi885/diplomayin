import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'DiplomaCAPI.dart';
import 'image_isolate.dart';

import 'package:image/image.dart' as img;

void main() {
  DiplomaCAPI api = DiplomaCAPI(); //     ;

  img.Image? image = img.decodeImage(File(
          "C:\\Users\\ADMIN\\Downloads\\d8807dc1-2922-42ca-8aa7-ae91f4c4fdd9.png")
      .readAsBytesSync());
  var data = api.compressImage(image, 8, 8, 37);
  img.Image? imageDecompressed = api.decompressImage(data);
  img.PngEncoder encoder = img.PngEncoder();
  if (imageDecompressed == null) return;
  Uint8List pngBytes = encoder.encode(imageDecompressed);
  File f = File("C:/Users/ADMIN/Desktop/testing/out123.png");
  f.writeAsBytes(pngBytes);
  return;
  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desktop Drop Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageDimensions = '';

  Color _backgroundColor = const Color.fromRGBO(248, 249, 252, 1);
  bool isShow = false;
  bool isDownload = false;

  Uint8List? imageBytes;

  String? _selectedOption;
  @override
  void initState() {
    super.initState();

    _selectedOption = 'High Quality (Recommend)';
    DiplomCAPI.response.listen((message) {
      if (message is Uint8List) {
        Navigator.of(context).pop();
        setState(() {
          imageBytes = message;
        });
      }
    });
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

    // new Future.delayed(new Duration(seconds: 3), () {
    //   Navigator.pop(context); //pop dialog

    // });
  }

  List<XFile> _imageFiles = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: const Color.fromRGBO(240, 243, 250, 1),
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Compressor',
                      style: TextStyle(
                          color: Color.fromRGBO(72, 72, 82, 1), fontSize: 14)),
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
                                      final files = await FilePicker.platform
                                          .pickFiles(allowMultiple: true);
                                      if (files == null) return;
                                      for (var platformFile in files.files) {
                                        setState(() {
                                          _imageFiles
                                              .add(XFile(platformFile.path!));
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.file_upload_outlined,
                                        color: Color.fromRGBO(73, 126, 126, 1)))
                              ],
                            ),
                            const Divider(),
                            if (imageBytes != null)
                              _buildDecompress()
                            else if (_imageFiles.isEmpty)
                              _buildDropTarget()
                            else
                              _buildCompressor(),
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
        ));
  }

  Future<void> _selectLocation() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final File file = File('$result/image.png');
      print('path:${file.path}');
      file.writeAsBytesSync(imageBytes!.toList());
    }
  }

  Row _buildDecompress() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            color: const Color.fromRGBO(247, 249, 252, 1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: MouseRegion(
                onEnter: (event) => _downloadImage(true),
                onExit: (event) => _downloadImage(false),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Opacity(
                          opacity: isDownload ? 0.7 : 1,
                          child: Image.memory(
                            imageBytes!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    if (isDownload)
                      Positioned(
                        child: IconButton(
                          icon: const Icon(Icons.download, size: 25),
                          color: Colors.white,
                          onPressed: () async {
                            await _selectLocation();
                            // Add your download functionality here
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Text(getUin8ListImageSize(
          uint8ListImage: imageBytes!,
        )),
      ],
    );
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

  String getImageFileSizeInMB(imageFile) {
    int fileSizeInBytes = File(imageFile.path).lengthSync();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return '${fileSizeInMB.toStringAsFixed(3)}MB';
  }

  String getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  Future<String> getImageDimensions(File imageFile) async {
    // Or any other way to get a File instance.

    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    return '${decodedImage.width} * ${decodedImage.height}';
  }

  _buildCompressor() {
    return MouseRegion(
      onEnter: (event) => _removeImage(true),
      onExit: (event) => _removeImage(false),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          color: const Color.fromRGBO(247, 249, 252, 1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: SizedBox(
                    width: 120, // Set a specific width for the container
                    height: 120,
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // Set the desired aspect ratio here

                      child: Image.file(
                        // height: 120,
                        // width: 120,
                        File(_imageFiles[0].path),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            getImageName(
                              _imageFiles[0],
                            ),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                        const SizedBox(height: 20),
                        DottedBorder(
                          borderType: BorderType.RRect,
                          // radius: const Radius.circular(12),
                          dashPattern: const [6, 3, 2, 3],
                          //224,229,238
                          color: const Color.fromRGBO(224, 229, 238, 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.folder,
                                      color: Color.fromRGBO(73, 126, 126, 1),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                        getImageFileSizeInMB(
                                          _imageFiles[0],
                                        ),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 2,
                                      backgroundColor: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(getFileExtension(_imageFiles[0].name)),
                                    const SizedBox(width: 20),
                                    const CircleAvatar(
                                      radius: 2,
                                      backgroundColor: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(_getImageDimensions()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
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
                                return MyAlertDialog();
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const InkResponse(
                              containedInkWell: true,
                              child: Icon(Icons.close, color: Colors.grey)),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromRGBO(73, 126, 126, 1)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the value as per your preference
                              ),
                            ),
                          ),
                          onPressed: () {
                            DiplomCAPI decompress =
                                DiplomCAPI(imagePath: _imageFiles[0].path);
                            _onLoading();
                            // DiplomaCAPI f =
                            //     DiplomaCAPI(imagePath: _imageFiles[0].path);
                            //    int a = f.uint8ListToArray(list);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Compress'),
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

  String _getImageDimensions() {
    File image = File(_imageFiles[0].path);
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

  void _downloadImage(bool isRemoved) {
    setState(() {
      isDownload = isRemoved;
    });
  }

  MyAlertDialog() {
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
            setState(() {
              _imageFiles = [];
            });
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
            final files =
                await FilePicker.platform.pickFiles(allowMultiple: true);
            if (files == null) return;
            for (var platformFile in files.files) {
              setState(() {
                _imageFiles.add(XFile(platformFile.path!));
              });
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

                      // const Color.fromRGBO(248, 249, 252, 1),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_download,
                                size: 64,
                                color: Color.fromRGBO(73, 126, 126, 1)),
                            const Text(
                                'Add or drag file here to start compression',
                                style: TextStyle(
                                    color: Color.fromRGBO(72, 72, 82, 1))),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Row(
                                children: const [
                                  Text('Step 1: Add ',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(72, 72, 82, 1))),
                                  SizedBox(width: 8),
                                  Icon(Icons.file_upload_outlined,
                                      color: Color.fromRGBO(73, 126, 126, 1)),
                                  SizedBox(width: 8),
                                  Text(
                                      'or drag file here to start compression.',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(72, 72, 82, 1))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Row(
                                children: const [
                                  Text('Step 2: Start compression.',
                                      style: TextStyle(
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
