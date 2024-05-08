import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:pauzible_app/Helper/Constants/colors.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/get_form_status_helper.dart';
import 'package:pauzible_app/Helper/get_user_file_helper.dart';
import 'package:pauzible_app/Helper/save&next_form_record_helper.dart';
import 'package:pauzible_app/Helper/send_from_record_helper.dart';
import 'package:pauzible_app/Helper/table_builder_helper.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/screens/thanks_screen.dart';
import 'package:pauzible_app/widgets/form_details.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';
import 'package:http/http.dart' as http;

class ApplicationForm extends StatefulWidget {
  const ApplicationForm({
    super.key,
  });

  @override
  _ApplicationFormState createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> dialogKey = GlobalKey();
  Map<String, dynamic> formData = {};
  dynamic otherOption = {
    "index": 0,
    "value": [' '],
    "pre_populated_has_other": true
  };
  String otherOptionValue = '';
  List<dynamic> otherOptionList = [];

  bool isFormReset = false;
  List<dynamic> formItems = [];
  List<String> identifiers = [
    "pre_qual",
    // "pre_qual_test_form_small"
  ];

  List<dynamic> formskeleton = [];
  String? token;
  String? applicationId;
  String? userId;
  // might change in future
  String? formIdentifier;
  int? version;
  String? submittedFormSkyflowId;
  bool isFormSubmitted = false;
  bool isEditMode = false;
  dynamic? userFromInfo = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  User? auth;
  // Initialize a map to track form field trackers
  Map<String, FormFieldTracker> formFieldTrackers = {};
  String? displayName;
  String? firstName;
  String? lastName;
  List<String>? parts;
  var loaderText = "Loading Form...";
  int currentSectionIndex = 0;
  Object? lastSelectedValue;
  bool subItemsAppended = false;
  var streetAdd;
  var addressline2;
  var citY;
  var postalcode;
  var property;
  bool sameAsCurrentAdd = false;
  String? userEmail;
  String? userPhoneNo;
  String formStatusSaveNext = 'partially_submitted';
  String formStatusSubmit = 'submitted';
  String lastFormIdSubmit = '';
  dynamic formStatus;
  bool isFormCreated = false;
  List<String> subItemIds = [];
  List<String> subsubItemIds = [];

  late Map<String, dynamic> jsonDataMapp;

  @override
  void initState() {
    super.initState();

    if (_auth!.currentUser!.email != null) {
      print("INSIDE EMAIL");
      if (_auth.currentUser!.displayName != null) {
        setState(() {
          displayName = _auth.currentUser!.displayName?.toUpperCase();

          print(firstName);
        });
        parts = displayName!.split(' ');

        setState(() {
          firstName = parts![0];
          lastName = parts!.last;
        });
      }
    }

    getsubmittedFormId().then((id) {
      getFormstatus(id).then((value) {
        getUserFileURL(id).then((url) {
          fetchData(url).then((jsonData) {
            setState(() {
              submittedFormSkyflowId = id;
              formStatus = value['fields']['form_status'];
              debugPrint('NAVBAR DYNAMIC $formStatus $isFormSubmitted');
              setStatusForm(formStatus);
            });
            // Ensure that the form is partially submitted before proceeding
            if (formStatus == 'partially_submitted') {
              jsonDataMapp = jsonData;
              processPartiallySubmittedForm();
            }
            isFormCreated = true;
          });
        });
      });
    });

    getFormSubmissionStatus().then((status) {
      isFormSubmitted = status;
      if (!isFormSubmitted) isFormCreated = true;
      print('get Form Submission Status $isFormSubmitted');
    });

    getUserEmail().then((val) {
      setState(() {
        userEmail = val;
      });
    });

    getUserPhoneNo().then((value) {
      setState(() {
        userPhoneNo = value;
      });
    });

    getAppId().then((appId) {
      setState(() {
        applicationId = appId;
        isFormReset = false;
      });
    });
    getUserId().then((userid) {
      setState(() {
        userId = userid;
      });
    });
    getSkyFlowToken().then((skyflowToken) {
      setState(() {
        token = skyflowToken;
      });
    });
    getFirebaseIdToken().then((token) {
      builderTable(token!, identifiers).then((res) {
        if (res is Map<String, dynamic>) {
          setState(() {
            formskeleton = res["formTemplates"];
            formIdentifier = formskeleton[0]["templateidentifier"];
            version = formskeleton[0]["version"];
            formItems = formskeleton[0]["templatejson"]["items"]
                [currentSectionIndex]["fields"];
          });
        } else {}
      });
    });
  }

  void processPartiallySubmittedForm() {
    for (var entry in jsonDataMapp.entries.toList()) {
      String key = entry.key;
      dynamic value = entry.value;

      if (value is String) {
        RegExp datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
        if (datePattern.hasMatch(value)) {
          DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(value);
          jsonDataMapp[key] = parsedDate;
        }
      } else if (value is List<dynamic>) {
        // Check if the value is a list
        List<String> stringList =
            value.map((dynamic item) => item.toString()).toList();
        jsonDataMapp[key] = stringList;
      }
    }
    // Patch main fields directly from jsonDataMapp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jsonDataMapp.keys.toList().reversed.forEach((key) {
        _formKey.currentState?.patchValue({key: jsonDataMapp[key]});
      });

      // Patch subitem IDs from formItems
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findAllIds(formItems, 'id');
        debugPrint("subItem Ids $subItemIds");
        Map<String, dynamic> subItemPatchValues = {};

        // Iterate through subItemIds and patch values
        for (String id in subItemIds) {
          if (jsonDataMapp.containsKey(id)) {
            subItemPatchValues[id] = jsonDataMapp[id];
          }
        }

        subItemPatchValues.keys.toList().reversed.forEach((key) {
          _formKey.currentState?.patchValue({key: subItemPatchValues[key]});
        });

        // Patch subitem IDs within nested subitems
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint("debug sssiids $subsubItemIds");
          Map<String, dynamic> subItemPatchValues = {};

          // Iterate through subItemIds and patch values
          for (String id in subsubItemIds) {
            if (jsonDataMapp.containsKey(id)) {
              subItemPatchValues[id] = jsonDataMapp[id];
            }
          }
          debugPrint("debug sssiids $subItemPatchValues");
          subItemPatchValues.keys.toList().reversed.forEach((key) {
            debugPrint("debug sssiids $key ${subItemPatchValues[key]}");
            _formKey.currentState?.patchValue({key: subItemPatchValues[key]});
          });
        });
      });
    });
  }

  List<String> findAllSUBSUBIDs(List<dynamic> list, String key) {
    List<String> idValues = [];

    for (var item in list) {
      if (item is Map<String, dynamic> && item.containsKey(key)) {
        idValues.add(item[key]);
      }

      if (item is Map<String, dynamic> && item.containsKey('config')) {
        var config = item['config'];
        if (config.containsKey('subItems')) {
          var subItems = config['subItems'];
          if (subItems is Map<String, dynamic>) {
            List<dynamic> subItemValues =
                subItems.values.expand((items) => items).toList();

            subsubItemIds.addAll(findAllIds(subItemValues, key));
            // Recursively search subItems
          }
        }
        // Recursively search within 'config'
        idValues.addAll(findAllIds([config], key));
      }

      if (item is List<dynamic>) {
        // Recursively search within nested lists
        idValues.addAll(findAllIds(item, key));
      }
    }

    return idValues;
  }

  List<String> findAllIds(List<dynamic> list, String key) {
    List<String> idValues = [];

    for (var item in list) {
      if (item is Map<String, dynamic> && item.containsKey(key)) {
        idValues.add(item[key]);
      }

      if (item is Map<String, dynamic> && item.containsKey('config')) {
        var config = item['config'];
        if (config.containsKey('subItems')) {
          var subItems = config['subItems'];
          if (subItems is Map<String, dynamic>) {
            List<dynamic> subItemValues =
                subItems.values.expand((items) => items).toList();
            findAllSUBSUBIDs(subItemValues, key);
            debugPrint("debug siids $subItemValues");

            subItemIds.addAll(findAllIds(subItemValues, key));
            // Recursively search subItems
          }
        }
        // Recursively search within 'config'
        idValues.addAll(findAllIds([config], key));
      }

      if (item is List<dynamic>) {
        // Recursively search within nested lists
        idValues.addAll(findAllIds(item, key));
      }
    }

    return idValues;
  }

// // Function to collect all IDs recursively from a list of items
//   List<String> findAllIds(List<dynamic> list, String key) {
//     List<String> idValues = [];

//     for (var item in list) {
//       if (item is Map<String, dynamic> && item.containsKey(key)) {
//         idValues.add(item[key]);
//       }

//       if (item is Map<String, dynamic> && item.containsKey('config')) {
//         var config = item['config'];
//         if (config.containsKey('subItems')) {
//           var subItems = config['subItems'];
//           if (subItems is Map<String, dynamic>) {
//             List<dynamic> subItemValues =
//                 subItems.values.expand((items) => items).toList();
//             idValues.addAll(
//                 findAllIds(subItemValues, key)); // Recursively search subItems
//           }
//         }
//         // Recursively search within 'config'
//         idValues.addAll(findAllIds([config], key));
//       }

//       if (item is List<dynamic>) {
//         // Recursively search within nested lists
//         idValues.addAll(findAllIds(item, key));
//       }
//     }

//     return idValues;
//   }

  Future<Map<String, dynamic>> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load JSON');
    }
  }

  updateSubmittedFormSkyflowId(id) {
    setState(() {
      if (id != Null) {
        submittedFormSkyflowId = id;
        isFormSubmitted = true;
      }
    });
  }

  editMode(id, userFormInfo) {
    setState(() {
      submittedFormSkyflowId = id;
      isFormSubmitted = false;
      isEditMode = true;
      userFromInfo = userFormInfo;
    });
  }

  String customEncoder(dynamic item) {
    if (item is DateTime) {
      return DateFormat('dd-MM-yyyy').format(item);
    }
    return item;
  }

  void showToast(String msg) {
    showToastHelper(msg);
  }

  void resetData() {
    setState(() {
      isFormReset = true;
    });
    _formKey.currentState?.reset();
  }

  void NoResetData() {
    setState(() {
      isFormReset = false;
    });
    _formKey.currentState?.save();
  }

  void handleDispalyFormDetails(isFormResetStatus, isFormSubmitedStatus) {
    setState(() {
      isFormReset = isFormResetStatus;
      isFormSubmitted = isFormSubmitedStatus;
    });
  }

  void goToNextSection() {
    setState(() {
      if (_formKey.currentState!.saveAndValidate()) {
        // Validate current section before moving to next section
        Map<String, dynamic> formData = _formKey.currentState!.value;
        String jsonString = jsonEncode(formData, toEncodable: customEncoder);
        Map<String, dynamic> parsedData = jsonDecode(jsonString);
        // Remove the key-value pair where the key contains the substring "custom other option"
        parsedData
            .removeWhere((key, value) => key.contains("custom other option"));
        String modifiedData = jsonEncode(parsedData);
        getsubmittedFormId().then((id) {
          setState(() {
            submittedFormSkyflowId = id;
            debugPrint('sendFormRecord modifiedData $modifiedData');
            saveNextFormRecord(token!, applicationId!, userId!, modifiedData,
                formIdentifier!, version!, formStatusSaveNext, id);
          });
          if (currentSectionIndex <
              formskeleton[0]["templatejson"]["items"].length - 1) {
            if (formStatus == 'partially_submitted') {
              processPartiallySubmittedForm();
            }
            currentSectionIndex++;
          }
        });
      }
    });
  }

  void goToPreviousSection() {
    setState(() {
      if (currentSectionIndex > 0) {
        currentSectionIndex--;
      }
    });
  }

  int lastLoginInDays(String dateTimeString) {
    // Split the string by whitespace to get date and time parts
    List<String> parts = dateTimeString.split(' ');

    // Get the date part and split it by '-'
    List<String> dateParts = parts[0].split('-');

    // Convert all parts to integers
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    DateTime lastLoginDate = DateTime.utc(year, month, day);

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Calculate the difference in years
    int differenceInYears = currentDate.year - lastLoginDate.year;

    // Check if the last login date has passed this year
    if (currentDate.month < lastLoginDate.month ||
        (currentDate.month == lastLoginDate.month &&
            currentDate.day < lastLoginDate.day)) {
      differenceInYears--;
    }

    return differenceInYears;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    List<Widget> formFields = [];
    if (formskeleton.isNotEmpty) {
      formFields = formskeleton[0]["templatejson"]["items"][currentSectionIndex]
              ["fields"]
          .map<Widget>((item) {
        int index = formskeleton[0]["templatejson"]["items"]
                [currentSectionIndex]["fields"]
            .indexOf(item);
        formItems = formskeleton[0]["templatejson"]["items"]
            [currentSectionIndex]["fields"];
        try {
          switch (item['type']) {
            case 'text':
              List<dynamic> validationList = [];

              if (item["validations"] != null && item["validations"] != {}) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item['validations']['isRequired'] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                      break;
                    case 'maxLength':
                      validationList.add(FormBuilderValidators.maxLength(
                          item["validations"]["maxLength"]));
                      break;
                    case 'maxWords':
                      validationList.add(FormBuilderValidators.maxWordsCount(
                          item["validations"]["maxWords"]));
                      break;
                    case 'isEmail':
                      if (item["validations"]["isEmail"] == true) {
                        validationList.add(FormBuilderValidators.email());
                      }
                      break;
                    case 'isNumeric':
                      if (item["validations"]["isNumeric"] == true) {
                        validationList.add(FormBuilderValidators.numeric());
                      }
                      break;
                  }
                });
              }
              return Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormBuilderTextField(
                        key: Key(item["id"]),
                        initialValue: getInitialValue(item['id']) != ''
                            ? getInitialValue(item['id'])
                            : item['displayName'] == "First Name"
                                ? firstName
                                : item['displayName'] == "Last Name"
                                    ? lastName
                                    : item['id'] == "email"
                                        ? userEmail
                                        : item['id'] == "phone"
                                            ? userPhoneNo
                                            : "",
                        name: item['id'],
                        onChanged: (value) {
                          switch (item['id']) {
                            case 'streetAddress':
                              setState(() {
                                streetAdd = _formKey.currentState!
                                    .fields['streetAddress']?.value;
                              });

                              break;
                            case 'addressLine2':
                              setState(() {
                                addressline2 = _formKey.currentState!
                                    .fields['addressLine2']?.value;
                              });

                              break;
                            case 'city':
                              setState(() {
                                citY = _formKey
                                    .currentState!.fields['city']?.value;
                              });

                              break;
                            case 'postalCode':
                              setState(() {
                                postalcode = _formKey
                                    .currentState!.fields['postalCode']?.value;
                              });

                              break;
                          }
                        },
                        decoration: InputDecoration(
                          enabledBorder: borderStyle(),
                          label: LabelTextWidget(
                              fieldDisplayName: item['displayName'],
                              isRequired: requiredCheck(item)),
                          border: const OutlineInputBorder(),
                          floatingLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                          hintText: item["config"]["hintText"],
                        ),
                        validator:
                            FormBuilderValidators.compose([...validationList]),
                        inputFormatters: item['validations']["isPhone"] == true
                            ? [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\+\d*( \d*)?$'))
                              ]
                            : [],
                      ),
                      if (item['config']['subHeading'] != null)
                        Text(
                          item['config']['subHeading'],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 161, 160, 160)),
                        )
                    ],
                  ));
            case 'radiobutton':
              List<dynamic> validationList = [];
              if (item["validations"] != null &&
                  item["validations"].isNotEmpty) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item['validations']['isRequired'] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                  }
                });
              }
              return Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.05),
                  child: FormBuilderRadioGroup(
                    key: Key(item["id"]),
                    name: item['id'],
                    initialValue: getInitialValue(item['id']),
                    wrapAlignment: isMobile(context)
                        ? WrapAlignment.start
                        : WrapAlignment.spaceEvenly,
                    // validator: FormBuilderValidators.required(),
                    validator: (value) {
                      if (_formKey.currentState!.fields[item['id']]?.value ==
                              '' ||
                          _formKey.currentState!.fields[item['id']]?.value ==
                              item['config']['hintText']) {
                        if (requiredCheck(item)) {
                          return item['config']['hintText'] ??
                              item['displayName'];
                        }
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: borderStyle(),
                      errorBorder: borderStyle(isError: true),
                      focusedBorder: borderStyle(),
                      focusedErrorBorder: borderStyle(),
                      border: InputBorder.none,
                      label: LabelTextWidget(
                        fieldDisplayName: item['displayName'],
                        isRequired: requiredCheck(item),
                      ),
                      labelStyle:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    options: (item['config']['options'] as List<dynamic>)
                        .map((option) {
                      return FormBuilderFieldOption<String>(
                        value: option,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (item['id'] == 'applicationRelated') {
                          property = _formKey.currentState!
                              .fields['applicationRelated']?.value;
                          debugPrint('applicationRelated $property');
                        }
                        if (item['config']['subItems'] != null) {
                          if (item['config']['options'].contains(value)) {
                            final int selectedOptionIndex =
                                item['config']['options'].indexOf(value);
                            // Iterate through all options except the selected one
                            for (int i = 0;
                                i < item['config']['options'].length;
                                i++) {
                              if (i != selectedOptionIndex) {
                                final otherOption =
                                    item['config']['options'][i];
                                item['config']['subItems'][otherOption]
                                    .forEach((subItem) {
                                  final fieldName = subItem['id'];
                                  _formKey.currentState
                                      ?.removeInternalFieldValue(fieldName);
                                });

                                formItems.removeWhere((subItem) =>
                                    item['config']['subItems'][otherOption]
                                        .contains(subItem));
                              }
                            }

                            if (item['config']['options'].contains(value)) {
                              final List<dynamic> subItemsToAdd =
                                  item['config']['subItems'][value];
                              final Set<dynamic> existingItems =
                                  formItems.toSet();

                              // Filter out the sub-items that are not already present in formItems
                              final List<dynamic> newSubItems = subItemsToAdd
                                  .where((subItem) =>
                                      !existingItems.contains(subItem))
                                  .toList();

                              // Insert the new sub-items into formItems
                              formItems.insertAll(index + 1, newSubItems);
                            }
                          }
                        }
                        // debugPrint(
                        //     "Form Items after on changed radio button $formItems $index");
                      });
                    },
                  ));
            case 'multichoice':
              List<dynamic> validationList = [];
              if (item["validations"] != null &&
                  item["validations"].isNotEmpty) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item['validations']['isRequired'] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                  }
                });
              }
              return Container(
                margin: EdgeInsets.only(top: screenHeight * 0.05),
                child: FormBuilderCheckboxGroup(
                  key: Key(item["id"]),
                  onChanged: (List<String>? values) {
                    final tracker =
                        formFieldTrackers[item['id']] ??= FormFieldTracker();
                    tracker.handleValueChanged(values);
                    setState(() {
                      item['config']['options'].forEach((option) {
                        item['config']['subItems'][option].forEach((subItem) {
                          final fieldName = subItem['id'];

                          _formKey.currentState
                              ?.removeInternalFieldValue(fieldName);
                          debugPrint('Inside setState Multichoice $fieldName');
                        });
                      });
                      item['config']['options'].forEach((option) {
                        formItems.removeWhere((subItem) => item['config']
                                ['subItems'][option]
                            .contains(subItem));
                      });

                      values!.forEach((value) {
                        formItems.insertAll(
                            index + 1, item['config']['subItems'][value]);
                      });
                    });
                  },
                  wrapAlignment: isMobile(context)
                      ? WrapAlignment.start
                      : WrapAlignment.spaceEvenly,
                  name: item['id'],
                  initialValue: isEditMode == true
                      ? (item['config']['options'] as List<dynamic>)
                          .where((element) =>
                              userFromInfo[item['id']]
                                  ?.contains(element.toString()) ??
                              false)
                          .toList()
                          .cast<String>()
                      : <String>[],
                  validator: FormBuilderValidators.compose([
                    ...validationList
                        .where((validator) =>
                            item['config']['options'].contains(validator))
                        .map<String Function(List<String>?)>((validator) {
                      return (values) {
                        print('VALUES $values');
                        return validator(
                            values?.map((value) => value.toString()).toList());
                      };
                    }).toList(),
                  ]),
                  decoration: InputDecoration(
                    enabledBorder: borderStyle(),
                    border: InputBorder.none,
                    label: LabelTextWidget(
                      fieldDisplayName: item['displayName'],
                      isRequired: requiredCheck(item),
                    ),
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  options: (item['config']['options'] as List<dynamic>)
                      .map((option) =>
                          FormBuilderFieldOption<String>(value: option))
                      .toList(),
                ),
              );

            case 'dropdown':
              List<dynamic> validationList = [];
              if (item["validations"] != null &&
                  item["validations"].isNotEmpty) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item['validations']['isRequired'] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                  }
                });
              }
              return Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FormBuilderDropdown<String>(
                          key: Key(item["id"]),
                          alignment: Alignment.center,
                          name: item['id'],
                          initialValue: isEditMode == true
                              ? userFromInfo[item['displayName']]
                              : '',
                          validator: (value) {
                            if (_formKey.currentState!.fields[item['id']]
                                        ?.value ==
                                    '' ||
                                _formKey.currentState!.fields[item['id']]
                                        ?.value ==
                                    item['config']['hintText']) {
                              if (requiredCheck(item)) {
                                return item['config']['hintText'] ??
                                    item['displayName'];
                              }
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            enabledBorder: borderStyle(),
                            border: const OutlineInputBorder(),
                            label: LabelTextWidget(
                              fieldDisplayName: item['displayName'],
                              isRequired: requiredCheck(item),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  // Iterate through each option in the dropdown
                                  item['config']['options'].forEach((option) {
                                    // Remove subItems of each option
                                    item['config']['subItems'][option]
                                        .forEach((subItem) {
                                      final subItemDisplayName = subItem['id'];
                                      _formKey.currentState
                                          ?.removeInternalFieldValue(
                                              subItemDisplayName);
                                      // Remove the subItem from formItems
                                      formItems.removeWhere((item) =>
                                          item['id'] == subItemDisplayName);

                                      // Check if the subItem has further subItems
                                      if (subItem['config']['subItems'] !=
                                          null) {
                                        // Iterate through further subItems
                                        subItem['config']['subItems']
                                            .forEach((subOption, subSubItems) {
                                          // Remove each further subItem
                                          subSubItems.forEach((subSubItem) {
                                            final subSubItemDisplayName =
                                                subSubItem['id'];
                                            _formKey.currentState
                                                ?.removeInternalFieldValue(
                                                    subSubItemDisplayName);
                                            formItems.removeWhere((item) =>
                                                item['id'] ==
                                                subSubItemDisplayName);
                                          });
                                        });
                                      }
                                    });
                                  });

                                  // Remove the main item and its associated subItems from formItems
                                  formItems.removeWhere((subItem) =>
                                      item['config']['options']
                                          .contains(subItem['id']));
                                });
                                // Reset the main item's field value
                                _formKey.currentState!.fields[item['id']]
                                    ?.reset();
                              },
                            ),
                            hintText: item['config']['hintText'] ??
                                'Select ${item['displayName']}',
                          ),
                          items: (item['config']['options'] as List<dynamic>)
                              .map((option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              if (item['config']['subItems'] != null) {
                                item['config']['options'].forEach((option) {
                                  item['config']['subItems'][option]
                                      .forEach((subItem) {
                                    final fieldName = subItem['id'];

                                    _formKey.currentState
                                        ?.removeInternalFieldValue(fieldName);
                                  });
                                });
                              }
                              if (item['config']['subItems'] != null) {
                                item['config']['options'].forEach((option) {
                                  formItems.removeWhere((subItem) =>
                                      item['config']['subItems'][option]
                                          .contains(subItem));
                                });

                                formItems.insertAll(index + 1,
                                    item['config']['subItems'][value]);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ));
            case 'date':
              List<dynamic> validationList = [];
              if (item["validations"] != null &&
                  item["validations"].isNotEmpty) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item['validations']['isRequired'] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                  }
                });
              }
              return Container(
                margin: EdgeInsets.only(top: screenHeight * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderDateTimePicker(
                      key: Key(item["id"]),
                      initialValue: isEditMode == true
                          ? DateFormat('dd-MM-yyyy')
                              .parseStrict(userFromInfo[item['displayName']])
                          : null, // Set initialValue to null when not in edit mode
                      name: item['id'],
                      validator: FormBuilderValidators.compose(
                        validationList
                            .map<String? Function(DateTime?)>((validator) {
                          return (value) {
                            return validator(value);
                          };
                        }).toList(),
                      ),
                      inputType: InputType.date,
                      format: DateFormat('dd-MM-yyyy'),
                      firstDate: item['config'] != null &&
                              item['config']['range'] != null &&
                              item['config']['range']['firstDay'] != null
                          ? DateTime(
                              item["config"]["range"]["firstDay"]["year"],
                              item["config"]["range"]["firstDay"]["month"],
                              item["config"]["range"]["firstDay"]["day"],
                            )
                          : null, // Set firstDate only if the data is present
                      lastDate: item['config'] != null &&
                              item['config']['range'] != null &&
                              item['config']['range']['lastDay'] != null
                          ? DateTime(
                              item["config"]["range"]["lastDay"]["year"],
                              item["config"]["range"]["lastDay"]["month"],
                              item["config"]["range"]["lastDay"]["day"],
                            )
                          : null,
                      onChanged: (value) {
                        setState(() {
                          int diffYears = lastLoginInDays(value.toString());

                          if (diffYears < 3 &&
                              item['config']['subItems'] != null &&
                              !subItemsAppended) {
                            List<dynamic> subItems =
                                item['config']['subItems']['Start Date'];
                            int index = formItems.indexOf(item);

                            // Insert subItems into formItems list after the current item
                            subItems.reversed.forEach((subItem) {
                              formItems.insert(index + 1, subItem);
                            });

                            subItemsAppended =
                                true; // Set the flag to true after appending subItems
                          } else if (diffYears >= 3 &&
                              item['config']['subItems'] != null) {
                            List<dynamic> subItems =
                                item['config']['subItems']['Start Date'];
                            for (var subItem in subItems) {
                              formItems.remove(subItem);
                            }

                            subItemsAppended =
                                false; // Reset the flag after removing subItems
                          }
                          // debugPrint(
                          //     "Form Items after on changed date $formItems $index");
                        });
                      },

                      decoration: InputDecoration(
                        enabledBorder: borderStyle(),
                        border: const OutlineInputBorder(),
                        label: LabelTextWidget(
                          fieldDisplayName: item['displayName'],
                          isRequired: requiredCheck(item),
                        ),
                      ),
                    ),
                    if (item['config']['subHeading'] != null)
                      Text(
                        item['config']['subHeading'],
                        style: const TextStyle(
                            color: Color.fromARGB(255, 161, 160, 160)),
                      )
                  ],
                ),
              );

            case 'multiline':
              List<dynamic> validationList = [];

              if (item["validations"] != null &&
                  item["validations"].isNotEmpty) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item["validations"]["isRequired"] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                    case 'maxLength':
                      validationList.add(FormBuilderValidators.maxLength(
                          item["validations"]["maxLength"]));
                    case 'maxWords':
                      validationList.add(FormBuilderValidators.maxWordsCount(
                          item["validations"]["maxWords"]));
                    case 'isNumeric':
                      if (item["validations"]["isNumeric"] == true) {
                        validationList.add(FormBuilderValidators.numeric());
                      }
                  }
                });
              }
              return Container(
                margin: EdgeInsets.only(top: screenHeight * 0.05),
                child: FormBuilderTextField(
                    key: Key(item["id"]),
                    name: item['id'],
                    initialValue: isEditMode == true
                        ? userFromInfo[item['displayName']]
                        : '',
                    maxLines: item["config"]["lines"],
                    decoration: InputDecoration(
                      enabledBorder: borderStyle(),
                      label: LabelTextWidget(
                          fieldDisplayName: item['displayName'],
                          isRequired: requiredCheck(item)),
                      border: const OutlineInputBorder(),
                      hintText: item["config"]["hintText"],
                    ),
                    validator:
                        FormBuilderValidators.compose([...validationList])),
              );
            case 'singlecheckbox':
              List<dynamic> validationList = [];
              if (item["validations"] != null &&
                  item["validations"].isNotEmpty) {
                item["validations"].keys.forEach((val) {
                  switch (val) {
                    case 'isRequired':
                      if (item['validations']['isRequired'] == true) {
                        validationList.add(FormBuilderValidators.required());
                      }
                  }
                });
              }

              return Container(
                margin: EdgeInsets.only(top: screenHeight * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item['config'] != null && item['config']['heading'] != null
                        ? Text(
                            item['config']['heading'],
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
                    FormBuilderCheckbox(
                      key: Key(item["id"]),
                      name: item['id'],
                      initialValue: isEditMode == true
                          ? userFromInfo[item['displayName']]
                          : false,
                      title: Text(
                        item["config"]["hintText"],
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'You must accept this field to proceed',
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (item['id'] == 'propertyAddressHeading') {
                            debugPrint(
                                'INSIDE IF ${_formKey.currentState!.fields['propertyStreetAddress']}');
                            sameAsCurrentAdd = _formKey.currentState!
                                .fields['propertyAddressHeading']?.value;
                            //  streetAdd =  _formKey.currentState!.fields['streetAddress']?.value;
                            if (sameAsCurrentAdd &&
                                property == 'Owner occupied') {
                              debugPrint('INSIDE IF SAME AS CURRENT');
                              _formKey.currentState!
                                  .fields['propertyStreetAddress']!
                                  .didChange(streetAdd);
                              _formKey
                                  .currentState!.fields['propertyAddressLine2']!
                                  .didChange(addressline2);
                              _formKey.currentState!.fields['propertyCity']!
                                  .didChange(citY);
                              _formKey
                                  .currentState!.fields['propertyPostalCode']!
                                  .didChange(postalcode);
                              //_formKey.currentState!.fields['propertyStreetAddress']!.=false;
                            } else {
                              debugPrint('INSIDE ELSE SAME AS CURRENT');
                              _formKey.currentState!
                                  .fields['propertyStreetAddress']!
                                  .didChange('');
                              _formKey
                                  .currentState!.fields['propertyAddressLine2']!
                                  .didChange('');
                              _formKey.currentState!.fields['propertyCity']!
                                  .didChange('');
                              _formKey
                                  .currentState!.fields['propertyPostalCode']!
                                  .didChange('');
                            }
                            debugPrint(
                                'propertyAddressHeading $sameAsCurrentAdd $streetAdd');
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            case "heading":
              return Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: screenHeight * 0.05),
                  child: HeadingWidget(
                      key: Key(item["id"]),
                      mainHeading: item["displayName"],
                      subHeading: item["config"] != null
                          ? item["config"]["subHeading"]
                          : null,
                      isRequired: requiredCheck(item),
                      isSectionHeading: item["config"]["isSectionHeading"]));

            default:
              return Container();
          }
        } catch (e) {
          debugPrint('Error form $e');
          return Container(
            height: 10,
            color: Colors.amber,
          );
        }
      }).toList();
    }
    return Container(
      child: isFormReset == false &&
              formItems.isNotEmpty &&
              isFormSubmitted == true &&
              formStatus == 'submitted'
          ? FormDetailsWidget(
              id: submittedFormSkyflowId!,
              identifier: formIdentifier,
              version: version,
              editMode: editMode)
          : Container(
              child: isFormReset == false &&
                      formItems.isNotEmpty &&
                      isFormCreated == true
                  // isFormSubmitted == false
                  ? Column(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: screenWidth * 0.03,
                                      right: screenWidth * 0.03),
                                  child: FormBuilder(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: screenWidth * 0.01),
                                                child: Text(
                                                    formskeleton[0]
                                                            ["templatejson"]
                                                        ["displayName"],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                              ...formFields,
                                            ]),
                                        if (currentSectionIndex > 0)
                                          Padding(
                                            padding: EdgeInsets.only(top: 10.w),
                                            child: SizedBox(
                                              width: 200.w,
                                              height: 30.w,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          const Color(
                                                              0xFF0E5EB6)),
                                                ),
                                                onPressed: goToPreviousSection,
                                                child: const Text(
                                                  'Previous',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (currentSectionIndex <
                                            formskeleton[0]["templatejson"]
                                                        ["items"]
                                                    .length -
                                                1)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 30.w,
                                              bottom: 30.w,
                                            ),
                                            child: SizedBox(
                                              width: 200.w,
                                              height: 30.w,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          const Color(
                                                              0xFF0E5EB6)),
                                                ),
                                                onPressed: goToNextSection,
                                                child: const Text(
                                                  'Save & Next',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (currentSectionIndex ==
                                            formskeleton[0]["templatejson"]
                                                        ["items"]
                                                    .length -
                                                1)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 30.w, bottom: 30.w),
                                            child: SizedBox(
                                              width: 200.w,
                                              height: 30.w,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          const Color(
                                                              0xFF0E5EB6)),
                                                ),
                                                onPressed: () async {
                                                  print(jsonEncode(
                                                      _formKey
                                                          .currentState!.value,
                                                      toEncodable:
                                                          customEncoder));
                                                  if (_formKey.currentState!
                                                      .saveAndValidate()) {
                                                    _formKey
                                                        .currentState!.fields
                                                        .removeWhere((key,
                                                                value) =>
                                                            key.contains(
                                                                "custom other option"));
                                                    print(_formKey
                                                        .currentState?.fields);
                                                    Map<String, dynamic>
                                                        formData = _formKey
                                                            .currentState!
                                                            .value;

                                                    String jsonString =
                                                        jsonEncode(formData,
                                                            toEncodable:
                                                                customEncoder);
                                                    Map<String, dynamic>
                                                        parsedData =
                                                        jsonDecode(jsonString);

                                                    // Remove the key-value pair where the key contains the substring "custom other option"
                                                    parsedData.removeWhere((key,
                                                            value) =>
                                                        key.contains(
                                                            "custom other option"));

                                                    // Convert the modified map back to a JSON string
                                                    String modifiedData =
                                                        jsonEncode(parsedData);
                                                    print(_formKey.currentState!
                                                        .fields.entries
                                                        .map((e) => e.key
                                                            .contains(
                                                                "other")));
                                                    print(_formKey.currentState!
                                                        .fields.entries
                                                        .where((entry) =>
                                                            entry.key.contains(
                                                                "custom other option"))
                                                        .map((entry) =>
                                                            entry.key));

                                                    print(
                                                        'SUBMITTED $modifiedData');
                                                    sendFormRecord(
                                                      token!,
                                                      applicationId!,
                                                      modifiedData,
                                                      resetData,
                                                      formStatusSubmit,
                                                      showToast,
                                                      submittedFormSkyflowId,
                                                      dialogKey,
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : isFormReset == true && formItems.isNotEmpty
                      ? ThankYouWidget(
                          handelFormDetailsScreen: handleDispalyFormDetails)
                      : SizedBox(
                          width: screenWidth * .938,
                          height: screenHeight * 0.62,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LoadingWidget(
                                loadingText: loaderText,
                              )
                            ],
                          ))),
    );
  }

  bool requiredCheck(item) {
    return item["validations"] != null &&
        item["validations"] != {} &&
        item["validations"]["isRequired"] != null &&
        item["validations"]["isRequired"] == true;
  }

  OutlineInputBorder borderStyle({bool isError = false}) {
    return OutlineInputBorder(
        borderSide: BorderSide(
            color: isError ? Colors.red : Color(borderColor),
            width: isError ? 1 : 0.5));
  }

  getInitialValue(id) {
    // if (jsonDataMapp.isNotEmpty) {
    //   return jsonDataMapp[id];
    // }
    return '';
  }
}

class FormFieldTracker {
  List<String>? previousValues;

  void handleValueChanged(List<String>? newValues) {
    if (previousValues != null) {
      final addedValues = newValues!
          .where((value) => !previousValues!.contains(value))
          .toList();
      final removedValues = previousValues!
          .where((value) => !newValues!.contains(value))
          .toList();
      debugPrint("addedValue $addedValues");
      debugPrint("removedValues $removedValues");
    } else {
      debugPrint("addedValue $newValues");
    }

    previousValues = newValues;
  }
}

class LabelTextWidget extends StatelessWidget {
  final String fieldDisplayName;
  final bool isRequired;
  const LabelTextWidget(
      {super.key, required this.fieldDisplayName, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(
      text: fieldDisplayName,
      children: [
        if (isRequired == true)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
      ],
    ));
  }
}

class HeadingWidget extends StatelessWidget {
  final String mainHeading;
  final String? subHeading;
  final bool? isRequired;
  final bool isSectionHeading;

  const HeadingWidget(
      {super.key,
      required this.mainHeading,
      this.subHeading,
      this.isRequired,
      required this.isSectionHeading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: mainHeading,
                style: TextStyle(
                    fontSize: isSectionHeading == true
                        ? 20
                        : 18, // Adjust the font size as needed
                    fontWeight: isSectionHeading == true
                        ? FontWeight.bold
                        : FontWeight.bold,
                    color:
                        isSectionHeading == true ? Colors.black : Colors.black),
              ),
              if (isRequired == true)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),

        // Subheading if present
        if (subHeading != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              Divider(
                height: 1,
                color: Color(borderColor),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                subHeading!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(borderColor),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
