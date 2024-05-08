import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Firebase/auth_helper.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_initalize_helper.dart';
import 'package:pauzible_app/widgets/footer.dart';
import 'package:pauzible_app/widgets/helper_widgets/text_widget.dart';
import 'package:pauzible_app/widgets/nav_bar.dart';
import 'package:pauzible_app/widgets/user_name_update_form.dart';

class UserDetailUpdate extends StatefulWidget {
  User? auth;
  UserDetailUpdate({Key? key, this.auth}) : super(key: key);

  @override
  _UserDetailUpdateState createState() => _UserDetailUpdateState();
}

class _UserDetailUpdateState extends State<UserDetailUpdate> {
  bool newApplicaton = false;
  void getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    } else {}
  }

  @override
  initState() {
    super.initState();
    updateUser();
    initializeFirebase();
    getUrlAppIdFlow().then((status) {
      if (status == true) {
        setState(() {
          newApplicaton = true;
        });
      } else {
        getAppId().then((appid) {
          if (appid == '') {
            setState(() {
              newApplicaton = true;
            });
          }
        });
      }
    });
  }

  User? _auth = FirebaseAuth.instance.currentUser;
  User? authUser;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0E5EB6),
        title: isDesktop(context)
            ? Image.asset(
                'assets/images/logo.png',
                width: 160,
              )
            : null,
        actions: [
          _auth != null
              ? SizedBox(
                  width: 200,
                  child: TextWidget(
                    displayText: '',
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : const SizedBox(),
          _auth != null ? NavBar() : const SizedBox(),
        ],
      ),
      bottomNavigationBar: Footer(),
      body: isDesktop(context)
          ? Container(
              margin: EdgeInsets.only(top: screenHeight * 0.025),
              height: screenHeight * 0.8,
              child: Row(children: [
                if (isDesktop(context))
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.80,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset('assets/images/registerbg.png'),
                      ),
                    ),
                  ),
                SizedBox(
                    height: screenHeight * 0.70,
                    child: UserNameUpdateForm(
                      generateNewApplication: newApplicaton,
                    )),
              ]),
            )
          : Center(
              child: SizedBox(
                height: screenHeight * 0.70,
                width: screenWidth * 0.80,
                child: SizedBox(
                  child: UserNameUpdateForm(
                    generateNewApplication: newApplicaton,
                  ),
                ),
              ),
            ),
    );
  }
}
