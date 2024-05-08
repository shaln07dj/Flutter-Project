import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Models/category_sub_category.dart';
import 'package:pauzible_app/Models/file_record.dart';

List<String> list = <String>['One', 'Two', 'Three', 'Four'];

// ignore: must_be_immutable
class SubDropdown extends StatefulWidget {
  final Function(String) callback;
  final bool resetSubCategory;
  final Function(bool) setSubCategory;
  List<String> subCategoryDropdownItems;

  SubDropdown({
    Key? key,
    required this.callback,
    required this.resetSubCategory,
    required this.setSubCategory,
    required this.subCategoryDropdownItems,
  }) : super(key: key);
  @override
  State<SubDropdown> createState() => _SubDropdownState();
}

// created the statefull Widget
class _SubDropdownState extends State<SubDropdown> {
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  FileRecord? record;
  String dropdownValue = list.first;
  List<String> subCategoryDropdownItems = [];

  String? selectedValue;
  void setSubCategoryList(category) {
    for (var item in categorySubCategoryData) {
      if (kDebugMode) {
        print(item['category']);
      }

      if (item['category'] == category) {
        subCategoryDropdownItems = item['category'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool resetSubCat = widget.resetSubCategory;

    setState(() {
      screenWidth = (MediaQuery.of(context).size.width);
      screenHeight = (MediaQuery.of(context).size.height);
    });

    return Container(
        width: screenWidth * 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0E5EB6)),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
            onTap: () {},
            child: DropdownButton2<String>(
              isExpanded: true,
              value: resetSubCat ? null : selectedValue,
              underline: const SizedBox.shrink(),
              onChanged: (String? newValue) {
                widget.callback(newValue!);
                widget.setSubCategory(false);
                setState(() {
                  selectedValue = newValue!;
                });
                setState(() {});
                resetSubCat = true;
              },
              items: subCategoryDropdownItems
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0E5EB6)),
                      borderRadius: BorderRadius.circular(5))),
              menuItemStyleData: MenuItemStyleData(
                overlayColor: MaterialStatePropertyAll(
                    const Color(0xFF0E5EB6).withOpacity(0.3)),
              ),
              hint: const Text(
                "Select Sub Category",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w100),
              ),
            )));
  }
}
