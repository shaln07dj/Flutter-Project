import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/Models/File_Data_Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class DropZoneMobWidget extends StatefulWidget {
  final ValueChanged<File_Data_Model> onDroppedFile;
  final Function(bool isValid) isValidFileType;
  final bool isValidFile;
  final DropZoneMobController controller;
  final Function resetFileInfo;
  final Function resetfileSucess;

  const DropZoneMobWidget(
      {required this.controller,
      Key? key,
      required this.onDroppedFile,
      required this.isValidFileType,
      required this.isValidFile,
      required this.resetFileInfo,
      required this.resetfileSucess})
      : super(key: key);
  @override
  _DropZoneMobWidgetState createState() => _DropZoneMobWidgetState(controller);
}

class DropZoneMobController {
  late void Function() reset;
}

class _DropZoneMobWidgetState extends State<DropZoneMobWidget> {
  late DropzoneViewController controller;
  bool highlight = false;
  final List<String> dropdownItems = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  String? selectedValue;
  // File? file;
  String fileName = '';
  bool allowedFileType = true;
  bool allowedSize = false;
  void resetDropzoneView() {
    setState(() {
      highlight = false;
    });
    setState(() {
      fileName = '';
    });
  }

  Future pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom,
        // allowedExtensions: const [
        //   'image/jpeg',
        //   'image/png',
        //   'image/gif',
        //   'application/pdf',
        //   'application/msword',
        //   'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        // ],
        withData: true,
      );
      final PlatformFile file = result!.files.first;
      uploadedFile(file);
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void resetData() {
    resetDropzoneView();
  }

  _DropZoneMobWidgetState(DropZoneMobController controller) {
    controller.reset = resetData;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        if (fileName == "")
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: pickFile,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder_open,
                      color: Colors.blue,
                      size: 40,
                    ),
                    const Text(
                      'Browse to upload documents',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    !allowedFileType
                        ? const Text(
                            '',
                            style: TextStyle(
                                color: Color.fromARGB(255, 249, 5, 5),
                                fontSize: 10,
                                fontWeight: FontWeight.normal),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
                    allowedSize
                        ? const Text(
                            'Too large file',
                            style: TextStyle(
                                color: Color.fromARGB(255, 249, 5, 5),
                                fontSize: 10,
                                fontWeight: FontWeight.normal),
                          )
                        : const Text(
                            '',
                            style: TextStyle(
                                color: Color.fromARGB(255, 249, 5, 5),
                                fontSize: 10,
                                fontWeight: FontWeight.normal),
                          )
                  ]),
            ),
          ),
        if (fileName != "")
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    color: Color(0xFF8F8F8F),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.resetFileInfo();
                  widget.resetfileSucess();
                  setState(() {
                    fileName = "";
                  });
                  setState(() {
                    allowedFileType = true;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
      ],
    );
  }

  Future uploadedFile(final PlatformFile event) async {
    List<String> allowedMime = [
      'application/pdf',
      'image/jpeg',
      'image/png',
      'image/gif',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];
    final name = event.name;
    debugPrint("fileName: $name");
    final mime = lookupMimeType(name);
    debugPrint("mime of file: $mime");
    final byteSize = event.size;
    debugPrint("byte size of file: $byteSize");

    // final url = await controller.createFileUrl(event);

    if (byteSize < maxFileSize * 1024 * 1024) {
      setState(() {
        allowedSize = false;
      });
      if (allowedMime.contains(mime)) {
        setState(() {
          allowedFileType = true;
        });

        widget.isValidFileType(allowedFileType);
        setState(() {
          fileName = name;
        });
      } else {
        setState(() {
          allowedFileType = false;
          showToastHelper("File Type Unsupported");
        });

        setState(() {
          fileName = '';
        });
        widget.isValidFileType(allowedFileType);
      }
      if (allowedFileType == true) {
        debugPrint('Inside IF of Bytes');
        final bytes = event.bytes;
        debugPrint("bytes of file: $bytes");
        final filePath = await saveFileToTempDirectory(name, bytes!);
        final droppedFile = File_Data_Model(
          name: name,
          mime: mime!,
          byteSize: byteSize,
          bytes: bytes,
          filePath: filePath,
        );
        widget.onDroppedFile(droppedFile);

        setState(() {
          fileName = name;
        });
        setState(() {
          highlight = false;
        });
      }
    } else {
      setState(() {
        allowedSize = true;
      });
    }
  }

  Future<String?> saveFileToTempDirectory(String name, Uint8List bytes) async {
    try {
      debugPrint("Inside saveFileToTempDirectory: ");
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$name';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes);
      debugPrint("File saved to temp directory: $tempFilePath");
      return tempFilePath;
    } catch (e) {
      debugPrint('Error saving file to temp directory: $e');
      return null;
    }
  }

  Widget buildDecoration({required Widget child}) {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.all(1),
        child: DottedBorder(
            borderType: BorderType.RRect,
            strokeWidth: 1,
            dashPattern: const [8, 4],
            padding: EdgeInsets.zero,
            child: child),
      ),
    );
  }
}
