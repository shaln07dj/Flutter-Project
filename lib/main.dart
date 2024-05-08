import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_initalize_helper.dart';
import 'package:pauzible_app/Helper/session/session_config.dart';
import 'package:pauzible_app/Helper/session/session_time_out_manager.dart';
import 'package:pauzible_app/Helper/session/sign_out.dart';
import 'package:pauzible_app/app.dart';
import 'package:pauzible_app/screens/auth_gate.dart';
import 'package:pauzible_app/screens/auth_screen.dart';

Future<void> main() async {
  bool isProd = const bool.fromEnvironment('prod', defaultValue: false);

  String envFileName = isProd ? '.env.prod' : '.env.dev';

  WidgetsFlutterBinding.ensureInitialized();
  await initSharedPreferences();
  await initializeFirebase();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    Map<String, String> queryParams = Uri.base.queryParameters;
    String appId = queryParams['appid'] ?? '';
    print("NULL USER $appId");
    await saveAppId(appId);
    if (appId == '') {
      setUrlAppIdFlow(true);
    } else {
      if (appId != '') {
        setUrlAppIdFlow(false);
      }
    }
  }
  if (user?.displayName == null) {
    Map<String, String> queryParams = Uri.base.queryParameters;
    String appId = queryParams['appid'] ?? '';
    print("NULL USER NAME $appId");

    await saveAppId(appId);
    if (appId == '') {
      print("inside appId='' ");

      setUrlAppIdFlow(true);
    }
  }
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
        invalidateSessionForAppLostFocus: const Duration(seconds: 20),
        invalidateSessionForUserInactivity:
            Duration(seconds: inActivitySessionTimeoutDuration));

    sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) {
      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
        debugPrint('Inactivity');
        SignOut();
      } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        debugPrint('Focus Out ');
        SignOut();
      }
    });
    return
        // SessionTimeoutManager(
        //   // wrapping around SessionTimeOutManager
        //   sessionConfig: sessionConfig,
        //   child:
        MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Pauzible',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E5EB6),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => MyForm(),
        '/': (context) => App(),
        '/login': (context) => const AuthGate(),
        '/dashboard': (context) => AuthHomeScreen()
      },
    );
    // );
  }
}
