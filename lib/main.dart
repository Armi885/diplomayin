import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';

import 'DiplomaCAPI.dart';

void main() {
  DiplomaCAPI f = DiplomaCAPI();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Drop Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _dragging = false;

  final List<XFile> _imageFiles = [];

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                const Text('Attach Image'),
                                IconButton(
                                    onPressed: () async {
                                      final files = await FilePicker.platform
                                          .pickFiles(allowMultiple: true);
                                      if (files == null) return;
                                      for (var platformFile in files.files) {
                                        setState(() {
                                          _imageFiles
                                              .add(platformFile as XFile);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.file_upload_outlined,
                                        color: Color.fromRGBO(73, 126, 126, 1)))
                              ],
                            ),
                            const Divider(),
                            if (_imageFiles.isEmpty)
                              _buildDropTarget()
                            else
                              _buildCompressor(),
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

  String getImageName(XFile imageFile) {
    return imageFile.name;
  }

  String getImageFileSizeInMB(XFile imageFile) {
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        color: const Color.fromRGBO(247, 249, 252, 1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.file(
                  height: 170,
                  width: 150,
                  File(_imageFiles[0].path),
                  fit: BoxFit.fill,
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
                              vertical: 18.0, horizontal: 8),
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
                                    backgroundColor: Colors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(getFileExtension(_imageFiles[0].name)),
                                  // Text( getImageDimensions(File((_imageFiles[0].path))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(73, 126, 126, 1),
                              shape: const StadiumBorder()),
                          child: const Text('Compress'),
                        ),
                      )
                    ]),
              )
            ],
          ),
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ClipRect(
          child: Card(
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
                      : const Color.fromRGBO(248, 249, 252, 1),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_download,
                            size: 64, color: Color.fromRGBO(73, 126, 126, 1)),
                        const Text('Add or drag file here to start compression',
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
                                      color: Color.fromRGBO(72, 72, 82, 1))),
                              SizedBox(width: 8),
                              Icon(Icons.file_upload_outlined,
                                  color: Color.fromRGBO(73, 126, 126, 1)),
                              SizedBox(width: 8),
                              Text('or drag file here to start compression.',
                                  style: TextStyle(
                                      color: Color.fromRGBO(72, 72, 82, 1))),
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
                                      color: Color.fromRGBO(72, 72, 82, 1))),
                            ],
                          ),
                        )
                      ])),
            ),
          ),
        ),
      ),
    );
  }
}
