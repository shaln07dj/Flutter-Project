import 'dart:convert';

FileRecord fileRecordFromJson(String str) =>
    FileRecord.fromJson(json.decode(str));

String fileRecordToJson(FileRecord data) => json.encode(data.toJson());

class FileRecord {
  List<Record> records;

  FileRecord({
    required this.records,
  });

  factory FileRecord.fromJson(Map<String, dynamic> json) => FileRecord(
        records:
            List<Record>.from(json["records"].map((x) => Record.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "records": List<dynamic>.from(records.map((x) => x.toJson())),
      };
}

class Record {
  Fields fields;

  Record({
    required this.fields,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "fields": fields.toJson(),
      };
}

class Fields {
  String skyflowId;
  String? email;
  String? file;
  String? name;

  Fields({
    required this.skyflowId,
    this.email,
    this.file,
    this.name,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        skyflowId: json["skyflow_id"],
        email: json["email"],
        file: json["file"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "skyflow_id": skyflowId,
        "email": email,
        "file": file,
        "name": name,
      };
}
