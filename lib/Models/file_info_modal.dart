class FileInfo {
  String fileName;
  String fileSize;

  FileInfo({
    required this.fileName,
    required this.fileSize,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) => FileInfo(
        fileName: json["fileName"],
        fileSize: json["fileSize"],
      );

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "fileSize": fileSize,
      };
}
