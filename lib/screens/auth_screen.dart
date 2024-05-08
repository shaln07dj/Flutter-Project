import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/get_applicationId_helper.dart';
import 'package:pauzible_app/Helper/get_token_helper.dart';
import 'package:pauzible_app/Helper/set_last_login.dart';
import 'package:pauzible_app/screens/dashboard.dart';
import 'package:pauzible_app/widgets/footer.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';

class AuthHomeScreen extends StatefulWidget {
  bool? route;
  AuthHomeScreen({Key? key, this.route}) : super(key: key);

  @override
  _AuthHomeScreenState createState() => _AuthHomeScreenState();
}

class _AuthHomeScreenState extends State<AuthHomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  User? auth;

  var loaderText =
      "Logging in securely into the system with encrypted data protection...";

  @override
  void initState() {
    print('FROM INSIDE OF THR AUTH SCREEN');
    super.initState();

    setLastLogin();
  }

  Future<void> _initializeApplicationId() async {
    var appId = await getAppId();
    if (appId == '') {
      debugPrint("In Auth Screen if $appId");
      var uToken = await user?.getIdToken();
      await getToken(uToken!);
      var skyflowToken_ = await getSkyFlowToken();
      appId = await getApplicationId(skyflowToken_);
      appId = appId[0]["fields"]["application_id"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future:
          _initializeApplicationId(), // Replace this with your actual future function
      builder: (context, snapshot) {
        debugPrint(" Auth Screen  snapshot ${snapshot.connectionState}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                LoadingWidget(
                  loadingText: loaderText,
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            bottomNavigationBar: Footer(),
            body: const Column(
              children: [
                Expanded(
                  child: DashBoard(),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          // Handle error case
          return Text('Error: ${snapshot.error}');
        } else {
          return const Text('Error: ');
        }
      },
    );
  }
}
