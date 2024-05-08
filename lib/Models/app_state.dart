
class AppState {
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? userEmail;
  final String? userId;
  final String? photoUrl;
  final String? token;
  final String? skyFlowToken;
  final String? category;
  final String? subCategory;
  final String? description;
  final String? fileName;
  final String? fileSize;
  final List? fileInfoList;
  final List<Map<String, dynamic>>? data;

  AppState({
    this.firstName,
    this.lastName,
    this.displayName,
    this.userEmail,
    this.userId,
    this.photoUrl,
    this.token,
    this.skyFlowToken,
    this.category,
    this.subCategory,
    this.description,
    this.fileName,
    this.fileSize,
    this.fileInfoList,
    this.data,
  });
}
