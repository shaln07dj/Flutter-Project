// ignore: file_names
class FormData {
  String option;
  String docType;
  String file;

  FormData({required this.option, required this.docType, required this.file});

  Map<String, dynamic> toJson() {
    return {
      'option': option,
      'docType': docType,
      'file': file,
    };
  }
}
