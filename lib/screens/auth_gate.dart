import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/get_applicationId_helper.dart';
import 'package:pauzible_app/Helper/get_skyflowId_user_helper.dart';
import 'package:pauzible_app/Helper/get_token_helper.dart';
import 'package:pauzible_app/screens/auth_screen.dart';
import 'package:pauzible_app/screens/multi_factor.dart';
import 'package:pauzible_app/screens/user_update.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? appId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  User? auth;
  var loaderText =
      "Logging in securely into the system with encrypted data protection...";
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    debugPrint("FirebaseAuth.instance ${FirebaseAuth.instance}");
    debugPrint(
        "FirebaseAuth.instance.currentUser ${FirebaseAuth.instance.currentUser}");
    _initializeApplicationId();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void setTimer() {
    debugPrint("timer start");
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        debugPrint("Email verified from timer");
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiFactorAuth(
              route: true,
            ),
          ),
        );
      }
    });
  }

  Future<void> _initializeApplicationId() async {
    String applicationId = await getAppId();
    if (applicationId == '') {}
    setState(() {
      appId = applicationId;
    });
  }

  Future<String> _getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? idToken = await user?.getIdToken() ?? '';
    debugPrint("GETID TOKEN $idToken");
    String? userId = user?.uid;
    saveUserId(userId!);
    try {
      if (user != null) {
        UserMetadata metadata = user.metadata;
        var skyflowToken = await getSkyFlowToken();
        // fetchSkyflowIdUser().then((val) async {
        //   await setUserEmail(val['email']);
        //   await setUserPhoneNo(val["phone_number"]);
        // });
        var val = await fetchSkyflowIdUser(); // Use await here
        setUserEmail(val['email']);
        setUserPhoneNo(val["phone_number"]);

        if (metadata.creationTime == metadata.lastSignInTime) {
          getAppId().then((result) {
            String? appId = result;
            if (appId != '') {
              getSkyFlowToken().then((resp) {
                //COMMENTING THIS CODE BEACUSE OF TEMPRARY REMOVAL OF CONCENT SCREEN
                // sendAppId(
                //   appId!,
                //   user.uid,
                //   user.email!,
                //   '',
                // );
              });
            }
          });
        } else {
          getToken(idToken).then((res) async {
            if (res != '') {
              var stoken = await getSkyFlowToken();
              var appId = await getApplicationId(stoken);
              debugPrint("App Id getIdToken $appId");
              appId = appId[0]["fields"]["application_id"];
              saveAppId(appId);
            }
          });
        }
      }
    } catch (error) {
      // Handle errors
      print('Error: $error');
    }
    debugPrint("ID TOKEn $idToken");
    return idToken!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint("Inside StreamBuilder<User?> Widget");
        if (!snapshot.hasData) {
          debugPrint(
              "FirebaseAuth.instance.authStateChanges(): ${FirebaseAuth.instance.authStateChanges()}");
          final mfaAction = AuthStateChangeAction<MFARequired>(
            (context, state) async {
              final nav = Navigator.of(context);
              await startMFAVerification(
                resolver: state.resolver,
                context: context,
              );
            },
          );
          debugPrint("mfaAction: $mfaAction");

          return SignInScreen(
            actions: [mfaAction],
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return LayoutBuilder(
                builder: (context, layoutConstraints) {
                  double widthFraction = 1;
                  return FractionallySizedBox(
                    widthFactor: widthFraction,
                    child: Image.asset(
                      'assets/images/mob_logo.jpg',
                      fit: BoxFit.fitWidth,
                    ),
                  );
                },
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Login to Dashboard account')
                    : const Text('Login to Dashboard account'),
              );
            },
            footerBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'By signing in, you agree to our ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://$siteBaseUrl/$endpointPrivacy');
                          },
                      ),
                      const TextSpan(
                        text: ' and the ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: 'Terms of Use.',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://$siteBaseUrl/$endpointTermsOfUse');
                          },
                      ),
                    ],
                  ),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/registerbg.png'),
                ),
              );
            },
          );
        } else {
          return FutureBuilder<String>(
            future: _getIdToken(),
            builder: (context, snapshot) {
              debugPrint(
                  "Inside FutureBuilder ${snapshot.hasData}   ${snapshot.connectionState}");
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return FutureBuilder<List<MultiFactorInfo>>(
                  future: FirebaseAuth.instance.currentUser!.multiFactor
                      .getEnrolledFactors(),
                  builder: (context, factorsSnapshot) {
                    debugPrint(
                        "FirebaseAuth.instance.currentUser!.multiFactor.getEnrolledFactors() ${FirebaseAuth.instance.currentUser!.multiFactor.getEnrolledFactors()}");
                    if (factorsSnapshot.connectionState ==
                        ConnectionState.done) {
                      debugPrint(
                          "Line 352 factorsSnapshot.connectionState: ${factorsSnapshot.connectionState}\nConnectionState.done: ${ConnectionState.done}");
                      if (factorsSnapshot.hasData) {
                        debugPrint(
                            "Line 354 factorsSnapshot.hasData: ${factorsSnapshot.hasData}");
                        // Check if email is verified
                        if (FirebaseAuth.instance.currentUser!.emailVerified) {
                          // debugPrint(
                          //     "factorsSnapshot ${jsonEncode(factorsSnapshot.data)}");
                          debugPrint(
                              "Line 358 FirebaseAuth.instance.currentUser!.emailVerified: ${FirebaseAuth.instance.currentUser!.emailVerified}");
                          // Check if there are enrolled factors
                          if (factorsSnapshot.data!.length > 0) {
                            debugPrint(
                                "Line 362 factorsSnapshot.data!.isNotEmpty: ${factorsSnapshot.data!.isNotEmpty}");
                            debugPrint(
                                "Line 364 _auth.currentUser!.displayName (Before return): ${_auth.currentUser!.displayName}");
                            debugPrint("LINE 374 open name screen");

                            return _auth.currentUser!.displayName == null
                                ? UserDetailUpdate(
                                    auth: user,
                                  )
                                : AuthHomeScreen(route: true);
                          } else {
                            debugPrint(
                                "Line 372 MultiFactorAuth(route: true) {Else of factorsSnapshot.data!.isNotEmpty condition}");
                            return MultiFactorAuth(route: true);
                          }
                        } else {
                          debugPrint(
                              "Line 377 EmailVerificationScreen {Else of FirebaseAuth.instance.currentUser!.emailVerified condition}");
                          setTimer();
                          return EmailVerificationScreen(
                            actions: [
                              EmailVerifiedAction(() {
                                if (_timer.isActive) {
                                  debugPrint("Timer cancelled");
                                  _timer.cancel();
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MultiFactorAuth(
                                      route: true,
                                    ),
                                  ),
                                );
                              }),
                              AuthCancelledAction((context) {
                                FirebaseUIAuth.signOut(context: context);
                                Navigator.pushReplacementNamed(context, '/');
                              }),
                            ],
                          );
                        }
                      } else {
                        return const Text(
                            'Error occurred while getting enrolled factors');
                      }
                    } else {
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
                    }
                  },
                );
              } else if (snapshot.hasError) {
                return const Text('Error occurred');
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingWidget(
                        loadingText: loaderText,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
