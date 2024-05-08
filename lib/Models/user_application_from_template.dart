class UserApplicationFormTemplate {
  List<FormTemplate> formTemplates;

  UserApplicationFormTemplate({
    required this.formTemplates,
  });
}

class FormTemplate {
  String id;
  String templateidentifier;
  int version;
  Templatejson templatejson;
  bool isDeleted;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  FormTemplate({
    required this.id,
    required this.templateidentifier,
    required this.version,
    required this.templatejson,
    required this.isDeleted,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });
}

class Templatejson {
  String name;
  String displayName;
  Submit submit;
  List<Item> items;

  Templatejson({
    required this.name,
    required this.displayName,
    required this.submit,
    required this.items,
  });
}

class Item {
  Type type;
  String displayName;
  Config config;
  Validations? validations;

  Item({
    required this.type,
    required this.displayName,
    required this.config,
    this.validations,
  });
}

class Config {
  String? subHeading;
  bool? isSectionHeading;
  String? hintText;
  List<String>? options;
  bool? isOther;
  String? heading;

  Config({
    this.subHeading,
    this.isSectionHeading,
    this.hintText,
    this.options,
    this.isOther,
    this.heading,
  });
}

enum Type {
  DATE,
  DROPDOWN,
  HEADING,
  MULTICHOICE,
  RADIOBUTTON,
  SINGLECHECKBOX,
  TEXT
}

class Validations {
  bool? isRequired;
  int? maxLength;
  bool? isEmail;
  bool? isNumeric;

  Validations({
    this.isRequired,
    this.maxLength,
    this.isEmail,
    this.isNumeric,
  });
}

class Submit {
  String destination;
  String column;

  Submit({
    required this.destination,
    required this.column,
  });
}
