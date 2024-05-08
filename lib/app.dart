import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/screens/login_home.dart';

class App extends StatefulWidget {
  App({Key? key});

  @override
  State<App> createState() {
    return _App();
  }
}

class _App extends State<App> with WidgetsBindingObserver {
  var channel = const MethodChannel("CHANNEL");
  List<String> itemList = [];
  List<Widget> widgetList = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? auth;
  String? targetApplicationID = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        // User is signed out

        print('User is currently signed out!');
      } else {
        // User is signed in
        setState(() {
          if (user != null) {
            auth = user;
            getAppId().then((appId) {
              setState(() {
                targetApplicationID = appId;
              });
            });
          }
        });

        print('User is signed in!');
        // print(auth?.displayName);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes here
    print('state life cycle ${state}');
    if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.paused) {}
    super.didChangeAppLifecycleState(state);
  }

  void handleAppMinimized() {
    // Perform actions when the app is minimized
    // For example, push to the authentication screen
    print('MINIMIZED');
    // Navigator.of(context).pushNamed("/auth");
  }

  void navigateToSecondPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => App()),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? _nameInitial;
    String? nameInitial;
    String? displayName = '';
    String? greetText = 'Welcome, ';

    if (auth?.email != null) {
      _nameInitial = auth?.email ?? '';
      nameInitial = _nameInitial[0].toUpperCase();
    }
    if (auth?.email != null) {
      if (_auth.currentUser!.displayName != null) {
        displayName = _auth.currentUser!.displayName?.toUpperCase();

        String? appID = targetApplicationID;
        print("AppID inside app.dart: $appID");
        if (appID != null && appID.isNotEmpty) {
          greetText = '$greetText $displayName $appID';
        } else {
          greetText = '$greetText $displayName';
        }
      }
    }

    return const LoginHome();
  }
}
