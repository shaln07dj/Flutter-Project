import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pauzible_app/Firebase/auth_helper.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/update_display_name_helper.dart';
import 'package:pauzible_app/app.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';

class UserNameUpdateForm extends StatefulWidget {
  bool? generateNewApplication;
  UserNameUpdateForm({Key? key, this.generateNewApplication}) : super(key: key);

  @override
  _UserNameUpdateFormState createState() => _UserNameUpdateFormState();
}

class _UserNameUpdateFormState extends State<UserNameUpdateForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  String firstName = '';
  String lastName = '';
  RegExp get _name => RegExp(r'^[a-zA-Z]+$');
  double inputBoxHeight = 50;
  String? token;
  String? applicationId;
  bool isUpdating = false;
  bool isNameUpdating = false;

  void getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    } else {}
  }

  @override
  void initState() {
    super.initState();
    getAppId().then((appId) {
      setState(() {
        applicationId = appId;
      });
    });
    updateUser();
    getFirebaseIdToken().then((resp) {
      setState(() {
        token = resp;
      });
    });
  }

  void redirect() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => App()),
    );
  }

  void handleUpdating(status) {
    setState(() {
      isUpdating = status;
    });
  }

  void handleNameUpdating(status) {
    setState(() {
      isNameUpdating = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: SizedBox(
        width: screenWidth * 0.4,
        height: screenHeight * 0.50,
        child: Container(
          margin: EdgeInsets.only(
              top: screenHeight * 0.05, left: screenWidth * 0.05),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 180, 179, 179),
              width: 0.5,
            ),
          ),
          child: FormBuilder(
              key: _formKey,
              child: Column(children: [
                Container(
                  width: 250.w,
                  height: 100.w,
                  color: const Color(0xFF0E5EB6),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      'assets/images/mob_logo.jpg',
                    ),
                  ),
                ),
                SizedBox(height: 10.w),
                Text(
                  "Please Provide Your Name",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                SizedBox(
                  width: 270.w,
                  child: FormBuilderTextField(
                    name: 'First Name',
                    obscureText: false,
                    validator: FormBuilderValidators.compose([
                      (value) {
                        if (!RegExp(r'^[a-zA-Z]+ *$').hasMatch(value!)) {
                          return 'Name is not in valid format';
                        }
                      },
                    ]),
                    onChanged: (value) {
                      setState(() {
                        firstName = value!.trimRight();
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'First Name ',
                      errorText: (firstName.isEmpty ||
                              RegExp(r'^[a-zA-Z]+ *$').hasMatch(firstName))
                          ? null
                          : 'Invalid input: Only alphabets are allowed',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 270.w,
                  child: FormBuilderTextField(
                    name: 'Last Name',
                    obscureText: false,
                    validator: FormBuilderValidators.compose([
                      (value) {
                        if (!RegExp(r'^[a-zA-Z]+ *$').hasMatch(value!)) {
                          return 'Name is not in valid format';
                        }
                      },
                    ]),
                    onChanged: (value) {
                      setState(() {
                        lastName = value!.trimRight();
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Last Name',
                      errorText: (lastName.isEmpty ||
                              RegExp(r'^[a-zA-Z]+ *$').hasMatch(lastName))
                          ? null
                          : 'Invalid input: Only alphabets are allowed',
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: isDesktop(context)
                        ? EdgeInsets.only(top: screenHeight * 0.07)
                        : EdgeInsets.only(top: screenHeight * 0.03),
                    width: 200.w,
                    height: 30.w,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: isUpdating!
                            ? MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 176, 177, 178))
                            : MaterialStateProperty.all<Color>(
                                const Color(0xFF0E5EB6)),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.saveAndValidate() &&
                            isUpdating == false) {
                          handleUpdating(true);
                          debugPrint(
                              "generateNewApplication ${widget.generateNewApplication}");
                          updateDisplayName(firstName, lastName, token!,
                              applicationId!, redirect,
                              generateNewApplication:
                                  widget.generateNewApplication,
                              handleUpdating: handleUpdating);
                        }
                      },
                      child: Text(
                        "Update",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                    child: isUpdating == true
                        ? const LoadingWidget(loadingText: "Updating Name")
                        : const SizedBox())
              ])),
        ),
      ),
    );
  }
}
