import 'package:dotted_border/dotted_border.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/Models/File_Data_Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class DropZoneWidget extends StatefulWidget {
  final ValueChanged<File_Data_Model> onDroppedFile;
  final Function(bool isValid) isValidFileType;
  final bool isValidFile;
  final DropZoneController controller;
  final Function resetFileInfo;
  final Function resetfileSucess;

  const DropZoneWidget(
      {required this.controller,
      Key? key,
      required this.onDroppedFile,
      required this.isValidFileType,
      required this.isValidFile,
      required this.resetFileInfo,
      required this.resetfileSucess})
      : super(key: key);
  @override
  _DropZoneWidgetState createState() => _DropZoneWidgetState(controller);
}

class DropZoneController {
  late void Function() reset;
}

class _DropZoneWidgetState extends State<DropZoneWidget> {
  late DropzoneViewController controller;
  bool highlight = false;
  final List<String> dropdownItems = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  String? selectedValue;
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

  void resetData() {
    resetDropzoneView();
  }

  _DropZoneWidgetState(DropZoneController controller) {
    controller.reset = resetData;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return buildDecoration(
        child: Stack(
      children: [
        DropzoneView(
          mime: const [
            'image/jpeg',
            'image/png',
            'image/gif',
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ],
          onCreated: (controller) => this.controller = controller,
          onDrop: uploadedFile,
          onHover: () => setState(() => highlight = true),
          onLeave: () => setState(() => highlight = false),
          onLoaded: () => {},
          onError: (err) => {},
          onDropInvalid: (ev) => {},
          onDropMultiple: (ev) async {},
        ),
        Center(
          child: GestureDetector(
            onTap: () async {
              final events = await controller.pickFiles(
                multiple: false,
                mime: [
                  'image/jpeg',
                  'image/png',
                  'image/gif',
                  'application/pdf',
                  'application/msword',
                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                ],
              );
              if (events.isEmpty) return;
              uploadedFile(events.first);
            },
            child: SizedBox(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: screenHeight * 0.147,
                    color: const Color(0xFFF1F1F1),
                    child: fileName == ''
                        ? GestureDetector(
                            onTap: () async {
                              final events = await controller.pickFiles(
                                multiple: false,
                                mime: [
                                  'image/jpeg',
                                  'image/png',
                                  'image/gif',
                                  'application/pdf',
                                  'application/msword',
                                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                                ],
                              );
                              if (events.isEmpty) return;
                              uploadedFile(events.first);
                            },
                            child: Column(children: [
                              Container(
                                  margin:
                                      EdgeInsets.only(top: screenHeight * 0.0),
                                  child: const Icon(
                                    Icons.cloud_upload,
                                    size: 30,
                                    color: Colors.grey,
                                  )),
                              const Text(
                                'Drag & Drop your documents here',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const Text(
                                'or',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const Text(
                                'Browse to upload documents',
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.lightBlue),
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
                          )
                        : Column(children: [
                            Container(
                              margin: EdgeInsets.only(
                                top: screenHeight * 0,
                                left: screenWidth * 0.17,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                ),
                                onPressed: () {
                                  // here
                                  widget.resetFileInfo();
                                  widget.resetfileSucess();
                                  setState(() {
                                    fileName = '';
                                  });
                                  setState(() {
                                    allowedFileType = true;
                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: screenHeight * 0.0),
                              width: screenWidth * 0.120,
                              height: screenHeight * 0.08,
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  color: Color(0xFF8F8F8F),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Future uploadedFile(dynamic event) async {
    List<String> allowedMime = [
      'application/pdf',
      'image/jpeg',
      'image/png',
      'image/gif',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];
    final name = event.name;
    final mime = await controller.getFileMIME(event);
    final byteSize = await controller.getFileSize(event);
    final url = await controller.createFileUrl(event);

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
        final droppedFile = File_Data_Model(
            name: name, mime: mime, byteSize: byteSize, url: url);
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

  Widget buildDecoration({required Widget child}) {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.all(1),
        color: const Color.fromARGB(255, 224, 223, 223),
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
