import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/session/sign_out.dart';
import 'package:pauzible_app/app.dart';

class NavBar extends StatefulWidget {
  final User? authInfo;
  final int? selectedIndex;
  bool? isUserNameUpdateScreen;
  NavBar({this.authInfo, this.isUserNameUpdateScreen, this.selectedIndex});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int counter = 0;
  bool isFormSubmitted = false;
  String? formStatus;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out
        debugPrint('User is currently signed out!');
      } else {
        // User is signed in
        UserMetadata metadata = user.metadata;
        if (metadata.creationTime == metadata.lastSignInTime) {
          // New user registration
          debugPrint('New user registered: ${user.email}');
          if (counter < 1) {
            getAppId().then((result) {
              String? appId = result;
              if (appId != '') {
                // Commmenting this code because of temprary Removal of Concent Screen
                // sendAppId(
                //   appId!,
                //   user.uid,
                //   user.email!,
                //   '',
                // );
              }
              setState(() {
                counter = counter + 1;
              });
            });
          }
        } else {
          getSkyFlowToken().then((result) {
            getFirebaseIdToken().then((firebaseToken) {});
          });
        }
        print('User is signed in!');
      }
    });
    getFormSubmissionStatus().then((status) {
      setState(() {
        isFormSubmitted = status;
        debugPrint(
            'User index tab nav ${widget.selectedIndex} $isFormSubmitted');
      });
    });
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                SignOut();
                Navigator.of(context).pop();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void saveNextChanges(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Changes"),
          content: const Text(
              "You might have unsaved changes. Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                SignOut();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? nameInitial_;
    String? nameInitial;
    if (_auth.currentUser!.email != null) {
      nameInitial_ = _auth.currentUser!.email ?? '';
      nameInitial = nameInitial_[0].toUpperCase();
    }

    return SizedBox(
        child: PopupMenuButton(
      tooltip: "Click to logout",
      onSelected: (value) async {
        formStatus = await getStatusForm();
        debugPrint('NAVBAR $formStatus');
        if (value == "logout" &&
            formStatus != 'submitted' &&
            widget.selectedIndex == 0) {
          saveNextChanges(context);
        } else {
          showLogoutConfirmationDialog(context);
        }
      },
      itemBuilder: widget.isUserNameUpdateScreen == null
          ? (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 1),
                        child: Icon(Icons.logout),
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ]
          : (BuildContext context) => <PopupMenuEntry>[
                // Render something else if isUserNameUpdateScreen is not null
              ],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              nameInitial ?? 'U',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
