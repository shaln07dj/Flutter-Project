import 'package:flutter/material.dart';
import 'package:pauzible_app/Models/category_sub_category.dart';
import 'package:pauzible_app/Models/file_record.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

List<String> list1 = <String>['One', 'Two', 'Three', 'Four'];

class Dropdown extends StatefulWidget {
  final Function(String) callback;
  final bool resetCategory;
  final Function(bool) setCategory;

  const Dropdown(
      {super.key,
      required this.callback,
      required this.resetCategory,
      required this.setCategory});
  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  FileRecord? record;

  String dropdownValue = list1.first;
  final List<String> categoryDropdownItems = [];
  String? selectedValue;
  @override
  void initState() {
    super.initState();
    for (var item in categorySubCategoryData) {
      if (!categoryDropdownItems.contains(item['category'])) {
        categoryDropdownItems.add(item['category']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          value: widget.resetCategory ? null : selectedValue,
          underline: const SizedBox.shrink(),
          onChanged: (String? category) {
            widget.callback(category!);
            widget.setCategory(false);
            setState(() {
              selectedValue = category;
            });
          },
          items: categoryDropdownItems
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF0E5EB6),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            customHeights: List.from([30.0, 30.0, 30.0, 60.0, 30.0]),
            overlayColor: MaterialStatePropertyAll(
              const Color(0xFF0E5EB6).withOpacity(0.3),
            ),
          ),
          hint: const Text(
            "Select Category",
            style: TextStyle(
              fontFamily: 'Roboto',
              // color: Colors.black,
              fontSize: 12,
              // fontWeight: FontWeight.w100
            ),
          ),
        ),
      ),
    );
  }
}
