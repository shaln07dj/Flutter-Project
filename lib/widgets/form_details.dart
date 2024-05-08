import 'dart:convert';
import 'dart:math';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/form_temp_helper.dart';
import 'package:pauzible_app/Helper/get_user_file_helper.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';

class FormDetailsWidget extends StatefulWidget {
  String id;
  String? identifier;
  int? version;
  Function(String id, dynamic userFormInfo)? editMode;

  FormDetailsWidget({super.key, required this.id, required this.identifier, required this.version,this.editMode});

  @override
  _FormDetailsWidgetState createState() => _FormDetailsWidgetState();
}

class _FormDetailsWidgetState extends State<FormDetailsWidget> {
  Map<String, dynamic>? jsonData;
  Map<String, dynamic>? selectedFormData;
  Map<String, dynamic>? formTempData;
  bool isRightLoading = false;
  String? firetoken;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String loading = 'progress';
  var loaderText =
      "Fetching information from Pauzible's Secure, Encrypted data vaults...";

  @override
  void initState() {
    super.initState();
    isRightLoading = true;
    void handleLoading(status) {
      setState(() {
        loading = status;
      });
    }

    print(
      _auth.currentUser!.uid,
    );

    print(_auth.currentUser);
    getFirebaseIdToken().then((tokenVal) {
      setState(() {
        firetoken = tokenVal;
      });
      getUserFileURL(widget.id, handleLoading: handleLoading).then((url) {
        formTemp(firetoken!, widget.identifier, widget.version).then((value){
        fetchData(url).then((data) {
          setState(() {
            selectedFormData = data;
            formTempData = value;
            isRightLoading = false;
            saveApplicationFromData(selectedFormData);
          });
          setState(() {
  selectedFormData = data;
  isRightLoading = false;
  saveApplicationFromData(selectedFormData);
  formTempData = value;

Map<String, dynamic> updatedFormData = {};
Map<String, String> idToDisplayNameMap = {}; // Mapping of id to displayName

// Extract id and displayName from formTempData
if (formTempData != null && formTempData!['formTemplates'] != null) {
  var templatejson = formTempData!['formTemplates']['templatejson'];
  if (templatejson != null && templatejson['items'] != null) {
    for (var item in templatejson['items']) {
      var fields = item['fields'];
      if (fields != null) {
        // Extract id and displayName from fields
        for (var field in fields) {
          String id = field['id'];
          String displayName = field['displayName'];
          idToDisplayNameMap[id] = displayName;
          // debugPrint('EXTRACT METHOD1 $id $displayName ${idToDisplayNameMap[id]}');
          // Check for subItems and extract them if present
          if (field['config'] != null && field['config']['subItems'] != null) {
            var subItems = field['config']['subItems'];
            for (var subItemKey in subItems.keys) {
              var subItemFields = subItems[subItemKey];
              for (var subField in subItemFields) {
                String subId = subField['id'];
                String subDisplayName = subField['displayName'];
                idToDisplayNameMap[subId] = subDisplayName;
                // debugPrint('EXTRACT METHOD2 $subId $subDisplayName ${idToDisplayNameMap[subId]}');
              }
            }
          }
        }
      }
    }
  }
}


// Use the idToDisplayNameMap to update the keys of selectedFormData
selectedFormData!.forEach((key, value) {
  String newKey = idToDisplayNameMap[key] ?? key;
  updatedFormData[newKey] = value;
});

// Update selectedFormData with updatedFormData
selectedFormData = updatedFormData;

});
        });
      });
      });
    });
  }

  handleEdit() {
    widget.editMode!('', selectedFormData);
    setFormSubmission(false);
    print("FORM DATA");
    getApplicationFromData().then((data) {
      print("$data");
      if (FirebaseAuth.instance.currentUser != null) {}
    });
  }

  Future<Map<String, dynamic>> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      debugPrint('Response of form: ${response.body}');
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load JSON');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double columnWidth =
        screenWidth * 0.5; // Adjust this according to your needs
    double totalColumnWidth = columnWidth - 32; // Subtract margins and padding
    double availableColumnWidth =
        totalColumnWidth - (8 * 2); // Subtract spacing between cells

    ScreenUtil.init(context);
    return ScreenUtilInit(
        designSize: Size(screenWidth, screenHeight),
        builder: (BuildContext context, Widget? child) {
          return SizedBox(
            child: Column(
              children: [
              Container(
                  margin: EdgeInsets.only(
                      right: screenWidth * 0.01,
                      bottom: screenHeight * 0.02,
                      top: screenHeight * 0.02),
                  width: screenWidth,
                  height: isMobile(context)
                      ? screenHeight * .60
                      : screenHeight * .50,
                  color: const Color(0xFFFFFFFF),
                  child: (isRightLoading)
                      ? Center(
                          child: LoadingWidget(loadingText: loaderText),
                        )
                      : (selectedFormData != null)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable2(
                                headingRowColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFF0E5EB6)),
                                columns: [
                                  const DataColumn(
                                      label: Text(
                                    'Field',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'Information',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines:
                                        ScreenUtil().screenHeight > 600 ? 2 : 1,
                                  )),
                                ],
                                rows: selectedFormData!.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  MapEntry<String, dynamic> data = entry.value;
                                  Color? rowColor = index % 2 == 0
                                      ? const Color.fromARGB(255, 221, 221, 233)
                                          .withOpacity(0.3)
                                      : null;
                                  double specificRowHeight =
                                      _calculateRowHeight(
                                          data.key,
                                          data.value?.toString() ?? '-',
                                          availableColumnWidth);
                                  // debugPrint(" Logs $index : $specificRowHeight $selectedFormData");

                                  return DataRow2(
                                    color: MaterialStateColor.resolveWith(
                                        (states) => rowColor ?? Colors.white),
                                    specificRowHeight: specificRowHeight,
                                    cells: [
                                      DataCell(
                                        Text(
                                          style: TextStyle(fontSize: 16.sp),
                                          data.key,
                                          maxLines:
                                              null, // Allow the text to wrap to multiple lines
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          style: TextStyle(fontSize: 16.sp),
                                          data.value?.toString() ?? '-',
                                          maxLines: null,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            )
                          : const SizedBox()),
            ]),
          );
        });
  }

  double _calculateRowHeight(
      String fieldText, String informationText, double availableColumnWidth) {
    final TextPainter fieldPainter = TextPainter(
      text: TextSpan(
        text: fieldText,
        style: TextStyle(fontSize: 16.sp),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: availableColumnWidth);

    final TextPainter informationPainter = TextPainter(
      text: TextSpan(
        text: informationText,
        style: TextStyle(fontSize: 16.sp),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: availableColumnWidth);

    return max(fieldPainter.size.height, informationPainter.size.height) +
        48; // Add 16 for padding
  }

  Widget _buildFormField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (value is List) Text(value.join(', ')),
          if (value is DateTime)
            Text('${value.day}-${value.month}-${value.year}'),
          if (value is String) Text(value.toString()),
          const Divider(),
        ],
      ),
    );
  }
}
