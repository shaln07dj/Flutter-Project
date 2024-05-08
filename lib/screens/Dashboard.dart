import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pauzible_app/Helper/Constants/colors.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/get_applicationId_helper.dart';
import 'package:pauzible_app/Helper/get_records_helper.dart';
import 'package:pauzible_app/Helper/get_token_helper.dart';
import 'package:pauzible_app/Helper/send_file_info_helper.dart';
import 'package:pauzible_app/Helper/session/sign_out.dart';
import 'package:pauzible_app/Helper/set_last_login.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/Models/File_Data_Model.dart';
import 'package:pauzible_app/Models/category_sub_category.dart';
import 'package:pauzible_app/Models/file_record.dart';
import 'package:pauzible_app/screens/dynamic_form_json.dart';
import 'package:pauzible_app/widgets/category_drop_down.dart';
import 'package:pauzible_app/widgets/drop_zone_mob_widget.dart';
import 'package:pauzible_app/widgets/drop_zone_widget.dart';
import 'package:pauzible_app/widgets/floating_whatsapp.dart';
import 'package:pauzible_app/widgets/helper_widgets/text_widget.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';
import 'package:pauzible_app/widgets/nav_bar.dart';
import 'package:pauzible_app/widgets/received_document.dart';
import 'package:pauzible_app/widgets/word_limit_input_formatter.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<_RightBlockState> _rightWidgetKey = GlobalKey();

  String submittedFormSkyflowId = '';
  bool isFormSubmitted = false;
  bool viewConsentScreen = true;
  int tabLength = 3;
  String? applicationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  User? auth;
  String? targetApplicationID = '';
  String skyflowToken = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late TabController _tabController;

  String? versionNumber;
  String? greetText = 'Welcome, ';
  int selectedIndex = 0;

  final GlobalKey<_DashBoardState> dialogKey = GlobalKey();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getVersionNum();
    _tabController = TabController(length: tabLength, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      print("Selected Index: " + _tabController.index.toString());
    });
    user!.getIdToken().then((fireToken) {
      getToken(fireToken!).then((skyToken) {
        getSkyFlowToken().then((token) {
          debugPrint("Token in dashboard 66 $token");
          setState(() {
            skyflowToken = token;
          });

          getAppId().then((appIdSharedPref) {
            debugPrint("AppID inside dashboard.dart  set app id");
            if (appIdSharedPref == '') {
              debugPrint("AppID inside dashboard.dart  set app if");

              getApplicationId(token).then((appId) {
                appId = appId[0]["fields"]["application_id"];
                appId = appId[0]["fields"]["application_id"];
                setState(() {
                  debugPrint("AppID inside dashboard.dart  set app id 1");
                  applicationId = appId;
                  targetApplicationID = appId;
                });
              });
            } else {
              debugPrint("AppID inside dashboard.dart  set app else");

              setState(() {
                debugPrint("AppID inside dashboard.dart  set app id 2");

                applicationId = appIdSharedPref;
                targetApplicationID = appIdSharedPref;
              });
            }
          });
        });
      });
    });
    _auth.authStateChanges().listen((User? user) async {
      // _getSkyflowToken();

      if (user == null) {
        // User is signed out

        print('User is currently signed out!');
      } else {
        // User is signed in
        setState(() {
          if (user != null) {
            auth = user;
            _initializeApplicationId();
          }
        });

        print('User is signed in!');
      }
    });
    setLastLogin();

    getAppId().then((appId) {
      setState(() {
        applicationId = appId;
      });
    });

    getFirebaseIdToken().then((tokenVal) {
      setState(() {});
    });
    getAppId().then((appId) {
      setState(() {
        applicationId = appId;
      });
    });
  }

  // Future<void> _getSkyflowToken() async {
  //   var token = await getSkyFlowToken();
  //   setState(() {
  //     skyflowToken = token;
  //   });
  // }

  Future<void> _initializeApplicationId() async {
    String appIdSharedPref = await getAppId();
    var appId;
    if (appIdSharedPref == '') {
      appId = await getApplicationId(skyflowToken);
      setState(() {
        applicationId = appId;
        targetApplicationID = appId;
      });
    } else {
      appId = appIdSharedPref;
      setState(() {
        applicationId = appId;
        targetApplicationID = appId;
      });
    }
  }

  handleConsentScreen(status) {
    setState(() {
      viewConsentScreen = status;
    });
  }

  void getVersionNum() async {
    var version = await getVersionNumber();

    setState(() {
      versionNumber = version;
    });
  }

  Future<void> _launchEmail(String emailAddress) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    // if (await canLaunch(emailLaunchUri.toString())) {
    await launch(emailLaunchUri.toString());
    // } else {
    //   throw 'Could not launch email';
    // }
  }

  void showDialogBox(BuildContext context, {double screenWidth = 0.0}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Contact Us",
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: screenWidth * 0.3,
            child: RichText(
              text: TextSpan(children: [
                const TextSpan(
                  text:
                      "If you encounter any issues while using our application, have any questions, feedback or suggestions, we're here to help! Please feel free to reach out to our support team at ",
                  style:
                      TextStyle(color: Colors.black, fontSize: 14, height: 1.5),
                ),
                TextSpan(
                  text: "support@pauzible.com",
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.lightBlue,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchEmail('support@pauzible.com');
                    },
                ),
              ]),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Okay"),
              ),
            ),
          ],
        );
      },
    );
  }

  void onTapped(int index) {
    debugPrint("Index of selected nav bar item: $index");
    switch (index) {
      case 0:
        setState(() {
          selectedIndex = index;
        });
        _tabController.animateTo(0);
        break;
      case 1:
        setState(() {
          selectedIndex = index;
        });
        _tabController.animateTo(1);
        break;
      case 2:
        setState(() {
          selectedIndex = index;
        });
        _tabController.animateTo(2);
        break;
      case 3:
        setState(() {
          selectedIndex = index;
        });
        showDialogBox(
          dialogKey.currentContext!,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? displayName = '';
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (auth?.email != null) {}
    if (auth?.email != null) {
      if (_auth.currentUser!.displayName != null) {
        displayName = _auth.currentUser!.displayName?.toUpperCase();

        String? appID = targetApplicationID;
        debugPrint("AppID inside dashboard.dart: $targetApplicationID");
        setState(() {
          greetText = 'Welcome, ';

          if (appID != null && appID.isNotEmpty && !isMobile(context)) {
            greetText = '$greetText $displayName ($targetApplicationID)';
          } else if (isMobile(context)) {
            greetText = '$displayName ($targetApplicationID)';
          } else {
            greetText = '$greetText $displayName';
          }
        });
      }
    }
    void rightReload() {
      _rightWidgetKey.currentState?.fetchNewData();
    }

    void reloadCallBack() {
      rightReload();
    }

    String? nameInitial_;
    String? nameInitial;
    if (_auth.currentUser!.email != null) {
      nameInitial_ = _auth.currentUser!.email ?? '';
      nameInitial = nameInitial_[0].toUpperCase();
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0E5EB6),
        title: !isMobile(context)
            ? Image.asset(
                'assets/images/logo.png',
                width: 160,
              )
            : null,
        leading: isMobile(context)
            ? IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              )
            : null,
        actions: [
          _auth.currentUser != null && _auth.currentUser!.displayName != null
              ? !isMobile(context)
                  ? Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: TextWidget(
                            displayText: greetText!,
                            fontColor: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.w),
                      ),
                    )
                  : const SizedBox()
              : const SizedBox(),
          _auth.currentUser != null
              ? !isMobile(context)
                  ? NavBar(
                      authInfo: user!,
                      selectedIndex: _selectedIndex,
                    )
                  : const SizedBox()
              : const SizedBox(),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120.h,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E5EB6),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
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
                    title: Text(
                      displayName!,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(targetApplicationID!,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dynamic_form_outlined),
                title: const Text('Information Form'),
                onTap: () {
                  _tabController.animateTo(0);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload Documents'),
                onTap: () {
                  _tabController.animateTo(1);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.document_scanner_sharp),
                title: const Text('Documents Received'),
                onTap: () {
                  _tabController.animateTo(2);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.task_outlined),
                title: const Text('Terms of Use'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://www.pauzible.com/terms-of-use'),
                  );
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.contact_emergency),
                title: const Text('Privacy Policy'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://www.pauzible.com/privacy'),
                  );
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.contact_page_outlined),
                title: const Text('Contact Us'),
                onTap: () {
                  showDialogBox(context, screenWidth: screenWidth);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat With Us'),
                onTap: () async {
                  String prewrittenMessage = Uri.encodeComponent(
                      "Hi, I would like to know more about the product.");
                  Uri whatsappUrl = Uri.parse(
                      "https://wa.me/4402088653352?text=$prewrittenMessage");
                  // if (await canLaunchUrl(whatsappUrl)) {
                  debugPrint("Inside Whatsapp");
                  await launchUrl(
                    whatsappUrl,
                  );
                  // } else {
                  //   debugPrint("Inside ELSE Whatsapp");
                  //   throw 'Could not launch WhatsApp';
                  // }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text('Logout'),
                onTap: () async {
                  showLogoutConfirmationDialog(context);
                },
              ),
              const Divider(),
              Center(
                child: versionNumber != null
                    ? Text(
                        'v$versionNumber',
                        style: const TextStyle(color: Colors.black),
                      )
                    : const Text(''),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isMobile(context) || isTablet(context)
          ? BottomNavigationBar(
              key: dialogKey,
              onTap: onTapped,
              currentIndex: selectedIndex,
              selectedFontSize: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dynamic_form_outlined),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.upload_file),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.document_scanner_sharp),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.email_outlined),
                  label: "",
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Material(
            child: DefaultTabController(
              length: tabLength,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !isMobile(context)
                      ? SizedBox(
                          width: 800.w,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF0E5EB6),
                            unselectedLabelColor:
                                const Color.fromARGB(255, 88, 87, 87),
                            tabs: const [
                              Tab(
                                icon: Row(
                                  children: [
                                    Icon(Icons.dynamic_form_outlined),
                                    SizedBox(width: 5),
                                    Text('Information Form'),
                                  ],
                                ),
                              ),
                              Tab(
                                icon: Row(
                                  children: [
                                    Icon(Icons.upload_file),
                                    SizedBox(width: 5),
                                    Text('Upload Documents'),
                                  ],
                                ),
                              ),
                              Tab(
                                icon: Row(
                                  children: [
                                    Icon(Icons.document_scanner_sharp),
                                    SizedBox(width: 5),
                                    Text('Documents Received'),
                                  ],
                                ),
                              ),
                            ],
                            labelStyle: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                        )
                      : const SizedBox(),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF5F5F5),
                      child: Column(
                        children: [
                          TopBar(isInsideTab: false),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                Container(
                                  color: const Color(0xFFF5F5F5),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 15.w,
                                      left: screenWidth * 0.03,
                                      right: screenWidth * 0.03,
                                    ),
                                    child: Column(
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: TopBar(
                                            isInsideTab: true,
                                          ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(top: 15.w),
                                            height: screenHeight * 0.57,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: ApplicationForm())),
                                      ],
                                    ),
                                  ),
                                ),
                                isDesktop(context)
                                    ? Container(
                                        margin: EdgeInsets.only(
                                          top: screenHeight * 0.02,
                                          left: screenWidth * 0.03,
                                          right: screenWidth * 0.03,
                                        ),
                                        color: const Color(0xFFF5F5F5),
                                        child: Column(
                                          children: [
                                            Flexible(
                                              flex: 1,
                                              child: TopBar(
                                                isInsideTab: true,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15.w,
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex: 9,
                                                  child: LeftBlock(
                                                    callback: reloadCallBack,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 12,
                                                  child: RightBlock(
                                                    reloadCallBack,
                                                    key: _rightWidgetKey,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : isMobile(context) || isTablet(context)
                                        ? Container(
                                            color: const Color(0xFFF5F5F5),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 15.w,
                                                  left: 18.w,
                                                  right: 15.w),
                                              width: 1920.w,
                                              child: Column(
                                                children: [
                                                  TopBar(
                                                    isInsideTab: true,
                                                  ),
                                                  Expanded(
                                                      child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      15.w),
                                                          width: screenWidth *
                                                              .938,
                                                          height: screenHeight *
                                                              0.62,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                          ),
                                                          child: RightBlock(
                                                              reloadCallBack,
                                                              key:
                                                                  _rightWidgetKey))),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 15.w,
                                      left: screenWidth * 0.03,
                                      right: screenWidth * 0.03),
                                  color: const Color(0xFFF5F5F5),
                                  child: Column(
                                    children: [
                                      TopBar(
                                        isInsideTab: true,
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                            margin: EdgeInsets.only(top: 15.w),
                                            child:
                                                const ReceivedDocumentWidget()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            width: 40,
            height: 40,
            bottom: 60,
            right: 20,
            child: isDesktop(context) ? const Fab_Whatsapp() : Container(),
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatefulWidget {
  bool isInsideTab;
  TopBar({super.key, required this.isInsideTab});

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  int counter = 0;
  int activeStep = 1;
  int userCurrentState = 0;

  @override
  void initState() {
    super.initState();
    print("STATUS CHECk");
    getFirebaseIdToken().then((token) {
      getSkyFlowToken().then((resp) {
        getApplicationId(resp, fireBaseToken: token).then((records) {
          String? targetApplicationStatus =
              records[0]["fields"]["application_status"];
          for (var status in userStatusList) {
            String applicationStatus = status['application_status'];
            if (applicationStatus == targetApplicationStatus) {
              setState(() {
                print("STATUS CHECk Update ${status['application_status_id']}");

                userCurrentState = status['application_status_id'];
              });
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return !isMobile(context) && widget.isInsideTab
        ? Material(
            child: SizedBox(
              height: screenHeight * .175,
              child: Container(
                color: const Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text('Application Progress',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Container(
                      height: screenHeight * .12,
                      color: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: userCurrentState / userStatusList.length,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3B86FF)),
                            minHeight: 2.5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(
                              userStatusList.length,
                              (index) {
                                int ind = index + 1;
                                return Container(
                                  margin:
                                      EdgeInsets.only(top: screenHeight * 0.02),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: userCurrentState >= ind
                                                  ? const Color(0xFF3B86FF)
                                                  : Colors.transparent,
                                              width: 1),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: userCurrentState >= ind
                                                  ? const Color(0xFF3B86FF)
                                                  : const Color(0xFFCCCCCC),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: userCurrentState >= ind
                                                  ? Text(
                                                      ind.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    )
                                                  : Text(
                                                      ind.toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (ind <= userStatusList.length)
                                        SizedBox(
                                          height:
                                              isTablet(context) ? 30.h : null,
                                          width:
                                              isTablet(context) ? 70.w : null,
                                          child: Text(
                                            userStatusList[index]
                                                ['application_status'],
                                            overflow: TextOverflow.visible,
                                            textAlign: isTablet(context)
                                                ? TextAlign.center
                                                : null,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: userCurrentState >= ind
                                                  ? const Color(0xFF3B86FF)
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : isMobile(context) && !widget.isInsideTab
            ? Material(
                child: Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.175,
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.005,
                    right: screenWidth * 0.005,
                    bottom: screenHeight * 0.005,
                    top: screenHeight * 0.005,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: screenWidth * 0.01,
                        ),
                        child: const Text('Application Progress',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(
                        height: screenWidth * 0.05,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: screenWidth * 0.05),
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                SizedBox(
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.15,
                                  child: CircularProgressIndicator(
                                    value: userCurrentState != 0
                                        ? userCurrentState /
                                            userStatusList.length
                                        : null,
                                    strokeWidth: 10,
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(seedColor),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${userCurrentState}/${userStatusList.length}',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ]),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: screenWidth * 0.05),
                              child: userCurrentState != 0
                                  ? Text(
                                      userStatusList[userCurrentState - 1]
                                          ['application_status'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const SizedBox(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox();
  }
}

@immutable
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

List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class _SubDropdownState extends State<SubDropdown> {
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  FileRecord? record;

  String dropdownValue = list.first;
  List<String> subCategoryDropdownItems = [];

  String? selectedValue;
  void setSubCategoryList(category) {
    setState(() {
      selectedValue = null;
    });
    for (var item in categorySubCategoryData) {
      if (item['category'] == category) {
        setState(() {
          subCategoryDropdownItems = item['sub-category'];
        });
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
        width: screenWidth * 0.1, // 80% of the screen width
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF0E5EB6),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
            onTap: () {},
            child: DropdownButton2<String>(
              isExpanded:
                  true, // Allows the dropdown to take up the entire available width
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
                      border: Border.all(color: const Color(0xFF0E5EB6)),
                      borderRadius: BorderRadius.circular(5))),
              menuItemStyleData: MenuItemStyleData(
                height: 60,
                overlayColor: MaterialStatePropertyAll(
                    const Color(0xFF0E5EB6).withOpacity(0.3)),
              ),
              hint: const Text(
                "Select Sub Category",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  // color: Colors.black,
                  fontSize: 12,
                  // fontWeight: FontWeight.w100
                ),
              ),
            )));
  }
}

class LeftBlock extends StatefulWidget {
  final Function() callback;

  const LeftBlock({super.key, required this.callback});
  @override
  _LeftBlockState createState() => _LeftBlockState();
}

class _LeftBlockState extends State<LeftBlock> {
  final GlobalKey<_SubDropdownState> _subDropDownKey =
      GlobalKey<_SubDropdownState>();

  final TextEditingController _description = TextEditingController();
  final DropZoneController dropzoneViewController = DropZoneController();
  final DropZoneController dropzoneViewMobController = DropZoneController();

  File_Data_Model? file;
  String? descp;

  String? category;
  String? subCategory;
  bool? isValidFileType = false;
  bool resetCategoryValue = false;
  bool resetSubCategoryValue = false;
  bool isResetFile = false;
  bool disableButton = false;
  bool success = false;
  bool categorySuccess = false;
  bool subCategorySuccess = false;
  bool fileSuccess = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> subCategoryDropdownItems = [];
  String? appId;

  @override
  void initState() {
    super.initState();
    getAppId().then((result) {
      setState(() {
        appId = result;
      });
    });
  }

  void isSuccessfull() {
    setState(() {
      success = !success;
      categorySuccess = false;
      subCategorySuccess = false;
      fileSuccess = false;
    });
  }

  void resetsuccessStatus() {
    setState(() {
      success = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    void updateCategory(String cat) {
      setState(() {
        category = cat;
        categorySuccess = true;
        _subDropDownKey.currentState!.setSubCategoryList(cat);
        subCategory = null;
        subCategorySuccess = false;
        resetsuccessStatus();
      });
    }

    void updateSubCategory(String subCat) {
      setState(() {
        subCategory = subCat;
        subCategorySuccess = true;
        resetsuccessStatus();
      });
    }

    void checkValidFileType(bool isValidFile) {
      setState(() {
        isValidFileType = isValidFile;
      });
    }

    void resetfileSucess() {
      setState(() {
        fileSuccess = false;
      });
    }

    void resetCategory(bool resetCatVal) {
      setState(() {
        category = null;
        subCategory = null;
        resetCategoryValue = resetCatVal;
        categorySuccess = false;
        subCategorySuccess = false;
      });
      setState(() {
        disableButton = true;
      });
    }

    void resetSubCategory(bool resetSubCatVal) {
      setState(() {
        resetSubCategoryValue = resetSubCatVal;
        disableButton = true;
      });
    }

    void setCategory(bool resetCatVal) {
      setState(() {
        resetCategoryValue = resetCatVal;
        success = true;
        categorySuccess = true;
      });
      setState(() {
        disableButton = false;
      });
    }

    void setSubCategory(bool resetSubCatVal) {
      setState(() {
        resetSubCategoryValue = resetSubCatVal;
        success = true;
      });
      setState(() {
        disableButton = false;
      });
    }

    void fileReset(bool resetFile) {
      setState(() {
        isResetFile = resetFile;
      });
    }

    void resetDropZone() {
      dropzoneViewController.reset();
      dropzoneViewMobController.reset();
    }

    void resetTextField() {
      _description.clear();
    }

    void resetFileInfo() {
      setState(() {
        file = null;
      });
    }

    void showToast(String msg) {
      showToastHelper(msg);
    }

    void resetSubCategoryDefault() {
      setState(() {
        subCategory = null;
      });
    }

    if (isDesktop(context)) {
      return Container(
        height: screenHeight * .58,
        color: const Color(0xFFFFFFFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                left: screenWidth * 0.0,
                top: screenHeight * 0.015,
              ),
              child: Center(
                child: Text(
                  "Send Documents Securely",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: screenWidth * .011,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.027),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: screenWidth * 0.03),
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.06,
                    child: Dropdown(
                      callback: updateCategory,
                      resetCategory: resetCategoryValue,
                      setCategory: setCategory,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.06,
                    child: SubDropdown(
                      key: _subDropDownKey,
                      callback: updateSubCategory,
                      resetSubCategory: resetSubCategoryValue,
                      setSubCategory: setSubCategory,
                      subCategoryDropdownItems: subCategoryDropdownItems,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(
                    left: screenWidth * 0.03, right: screenWidth * 0.015),
                width: screenWidth * 0.35,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 2,
                  inputFormatters: [
                    WordLimitInputFormatter(descrptionMaxWords),
                  ],
                  onChanged: (value) {
                    setState(() {
                      descp = value;
                    });
                  },
                  controller: _description,
                  decoration: const InputDecoration(
                    hintText:
                        'Please enter description ($descrptionMaxWords words)',
                    hintStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0E5EB6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0E5EB6)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              width: screenWidth * 0.232,
              height: screenHeight * 0.150,
              child: SizedBox(
                width: screenWidth * 0.242,
                child: DropZoneWidget(
                  onDroppedFile: (file) {
                    setState(() {
                      this.file = file;
                      fileSuccess = true;
                    });
                  },
                  isValidFileType: checkValidFileType,
                  isValidFile: isResetFile,
                  controller: dropzoneViewController,
                  resetFileInfo: resetFileInfo,
                  resetfileSucess: resetfileSucess,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Center(
              child: Container(
                color: categorySuccess && subCategorySuccess && fileSuccess
                    ? const Color(0xFF0E5EB6)
                    : Colors.grey,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      categorySuccess && subCategorySuccess && fileSuccess
                          ? const Color(0xFF0E5EB6)
                          : Colors.grey,
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onPressed: categorySuccess &&
                          subCategorySuccess &&
                          fileSuccess
                      ? () {
                          sendFileInfo(
                            category: category,
                            subCategory: subCategory,
                            description: descp,
                            isDeleted: false,
                            applicationId: appId,
                            userId: _auth.currentUser?.uid,
                            filename: file!.name,
                            byteSize: file!.size,
                            callback: widget.callback,
                            isSuccessfull: isSuccessfull,
                            resetFileInfo: resetFileInfo,
                            showToast: showToast,
                            resetCategory: resetCategory,
                            resetSubCategory: resetSubCategory,
                            resetTextField: resetTextField,
                            fileReset: fileReset,
                            resetDropZone: resetDropZone,
                            resetSubCategoryDefault: resetSubCategoryDefault,
                            blobUrl: file!.url,
                          );
                          showToast('Uploading File');
                        }
                      : () {
                          if (!categorySuccess) {
                            showToastHelper("Select Category");
                          }
                          if (categorySuccess && !subCategorySuccess) {
                            showToastHelper("Select Sub Category");
                          }
                          if (categorySuccess &&
                              subCategorySuccess &&
                              !fileSuccess) {
                            showToastHelper("Select File");
                          }
                        },
                  child: Text(
                    "Upload",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            subCategory != null ? const SizedBox(height: 0) : Container()
          ],
        ),
      );
    } else if (isMobile(context) || isTablet(context)) {
      return Container(
        width: screenWidth * 0.8,
        height: screenHeight * .65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFFFFFFFF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Send Documents Securely",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: screenWidth * .05,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              width: screenWidth * 0.9,
              height: screenHeight * 0.06,
              child: Dropdown(
                callback: updateCategory,
                resetCategory: resetCategoryValue,
                setCategory: setCategory,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.035,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              width: screenWidth * 0.9,
              height: screenHeight * 0.06,
              child: SubDropdown(
                key: _subDropDownKey,
                callback: updateSubCategory,
                resetSubCategory: resetSubCategoryValue,
                setSubCategory: setSubCategory,
                subCategoryDropdownItems: subCategoryDropdownItems,
              ),
            ),
            SizedBox(height: screenHeight * 0.035),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                width: screenWidth * 0.9,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 3,
                  minLines: 3,
                  inputFormatters: [
                    WordLimitInputFormatter(descrptionMaxWords),
                  ],
                  onChanged: (value) {
                    setState(() {
                      descp = value;
                    });
                  },
                  controller: _description,
                  decoration: const InputDecoration(
                    hintText:
                        'Please enter description ($descrptionMaxWords words)',
                    hintStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0E5EB6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0E5EB6)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                width: screenWidth * 0.7,
                height: screenHeight * 0.1,
                child: SizedBox(
                  width: screenWidth * 0.242,
                  child: DropZoneMobWidget(
                    onDroppedFile: (file) {
                      setState(() {
                        this.file = file;
                        fileSuccess = true;
                      });
                    },
                    isValidFileType: checkValidFileType,
                    isValidFile: isResetFile,
                    controller: DropZoneMobController(),
                    resetFileInfo: resetFileInfo,
                    resetfileSucess: resetfileSucess,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Expanded(
              child: Center(
                child: Container(
                  color: categorySuccess && subCategorySuccess && fileSuccess
                      ? const Color(0xFF0E5EB6)
                      : Colors.grey,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        categorySuccess && subCategorySuccess && fileSuccess
                            ? const Color(0xFF0E5EB6)
                            : Colors.grey,
                      ),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: categorySuccess &&
                            subCategorySuccess &&
                            fileSuccess
                        ? () {
                            sendFileInfo(
                              category: category,
                              subCategory: subCategory,
                              description: descp,
                              isDeleted: false,
                              applicationId: appId,
                              userId: _auth.currentUser?.uid,
                              filename: file!.name,
                              byteSize: file!.size,
                              callback: widget.callback,
                              isSuccessfull: isSuccessfull,
                              resetFileInfo: resetFileInfo,
                              showToast: showToast,
                              resetCategory: resetCategory,
                              resetSubCategory: resetSubCategory,
                              resetTextField: resetTextField,
                              fileReset: fileReset,
                              resetDropZone: resetDropZone,
                              resetSubCategoryDefault: resetSubCategoryDefault,
                              bytes: file!.bytes,
                              filePath: file!.filePath,
                            );
                            showToast('Uploading File');
                            Navigator.of(context).pop();
                          }
                        : () {
                            if (!categorySuccess) {
                              showToastHelper("Select Category");
                            }
                            if (categorySuccess && !subCategorySuccess) {
                              showToastHelper("Select Sub Category");
                            }
                            if (categorySuccess &&
                                subCategorySuccess &&
                                !fileSuccess) {
                              showToastHelper("Select File");
                            }
                          },
                    child: Text(
                      "Upload",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.035,
            ),
            subCategory != null ? const SizedBox(height: 0) : Container()
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class RightBlock extends StatefulWidget {
  Function() reloadCallback;
  RightBlock(this.reloadCallback, {super.key});
  @override
  _RightBlockState createState() => _RightBlockState();
}

class _RightBlockState extends State<RightBlock> {
  final scrollController = ScrollController();
  var hasMore = true;
  File_Data_Model? file;
  List<Map<String, dynamic>> data = [];
  String loading = 'progress';
  var isLoading = false;
  var loaderText =
      "Fetching information from Pauzible's Secure, Encrypted data vaults...";

  String? appId;
  dynamic result;

  final columnTitle = ['Sent On', 'Category', 'Sub Category', 'Description'];

  final List<String> expectedFields = [
    'created_at',
    'category',
    'sub_category',
    'description',
  ];

  final grid = <List<String>>[];
  final rowTitle = <String>[];

  var currentPage = 1;
  var nextPage;
  var rowPerPage = 25;

  bool isFirstCall = true;

  void handleLoading(status) {
    setState(() {
      loading = status;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(handleLoading, currentPage);

    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        fetchData(handleLoading, nextPage);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void fetchData(Function(String status) handleLoading, var thisPage) async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      int offSetValue = (thisPage - 1) * rowPerPage;
      result = await getRecords(handleLoading, offSetValue);
      if (isFirstCall) {
        isFirstCall = false;
        if (result.isEmpty) {
          setState(() {
            hasMore = false;
            loading = "failed";
            isLoading = false;
          });
          return;
        }
      } else {
        if (result.isEmpty || result.length < 25) {
          setState(() {
            hasMore = false;
          });
        }
      }

      for (var record in result) {
        rowTitle.add("");
        var fields = record['fields'];
        if (fields != null) {
          for (var key in expectedFields) {
            if (!fields.containsKey(key)) {
              fields[key] = "";
            }
          }

          grid.add([
            formatDate(fields['created_at']),
            fields['category'] ?? "",
            fields['sub_category'] ?? "",
            fields['description'] ?? "",
          ]);
        } else {
          grid.add(["", "", "", ""]);
        }
      }
      debugPrint("Grid===>>> $grid");
      //storing into data for mobile view list builder
      data.addAll(List<Map<String, dynamic>>.from(result));

      setState(() {
        loading = "success";
        isLoading = false;
        nextPage = thisPage + 1;
        grid;
        data;
      });
    } catch (error) {
      const snackBar = SnackBar(
          content: Text('Occur data loading error. Please try latter'));
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
      print('Loading error: $error');
    }
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      grid.clear();
      data.clear();
      rowTitle.clear();
    });

    fetchData(handleLoading, currentPage);
  }

  void fetchNewData() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      grid.clear();
      rowTitle.clear();
      data.clear();
      loading = 'progress';
    });
    fetchData(handleLoading, currentPage);
  }

  String formatDate(String timestamp) {
    if (timestamp == null || timestamp == "") {
      return "";
    }
    DateFormat customFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS Z');

    try {
      DateTime dateTime = customFormat.parse(timestamp);

      String formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(dateTime);

      debugPrint("formattedDate in 2nd tab $formattedDate");
      return formattedDate;
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    _auth.currentUser!.getIdToken().then((token) {}).catchError((error) {});

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return isDesktop(context)
        ? Container(
            margin: EdgeInsets.only(
                left: screenWidth * 0.01, right: screenWidth * 0.0),
            height: screenHeight * .58,
            color: const Color(0xFFFFFFFF),
            child: grid.isNotEmpty && loading == 'success'
                ? Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          RefreshIndicator(
                            onRefresh: refreshData,
                            child: StickyHeadersTable(
                              scrollControllers: ScrollControllers(
                                  verticalBodyController: scrollController),
                              columnsLength: columnTitle.length,
                              rowsLength: rowTitle.length,
                              columnsTitleBuilder: (i) => Container(
                                color: const Color(0xFF0E5EB6),
                                child: SizedBox(
                                  width: screenWidth * 0.145,
                                  height: screenHeight * 0.08,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        columnTitle[i],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              rowsTitleBuilder: (i) => const SizedBox(
                                height: 0,
                                width: 0,
                              ),
                              contentCellBuilder: (j, i) => Container(
                                color: i.isEven
                                    ? const Color.fromARGB(255, 221, 221, 233)
                                        .withOpacity(0.3)
                                    : Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      grid[i][j],
                                    ),
                                  ),
                                ),
                              ),
                              cellAlignments: const CellAlignments.fixed(
                                contentCellAlignment: Alignment.centerLeft,
                                stickyColumnAlignment: Alignment.topLeft,
                                stickyRowAlignment: Alignment.centerLeft,
                                stickyLegendAlignment: Alignment.centerLeft,
                              ),
                              cellDimensions: CellDimensions.fixed(
                                contentCellWidth: screenWidth * 0.13,
                                contentCellHeight: screenHeight * 0.13,
                                stickyLegendWidth: 0,
                                stickyLegendHeight: 50,
                              ),
                              showVerticalScrollbar: false,
                              showHorizontalScrollbar: false,
                            ),
                          ),
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  )
                : loading == 'progress'
                    ? Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.2),
                        child: Center(
                          child: Column(
                            children: [
                              LoadingWidget(
                                loadingText: loaderText,
                              )
                            ],
                          ),
                        ),
                      )
                    : loading == 'failed'
                        ? Container(
                            margin: EdgeInsets.only(top: screenHeight * 0.1),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/MicrosoftTeams-image.png',
                                    width: 125,
                                  ),
                                  const Text(
                                    "No Records Found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
          )
        : //Mobile View
        Container(
            margin: EdgeInsets.only(
              left: screenWidth * 0.01,
              right: screenWidth * 0.01,
              bottom: screenHeight * 0.01,
            ),
            width: screenWidth * 0.95,
            height: screenHeight * 0.62,
            color: const Color(0xFFFFFFFF),
            child: grid.isNotEmpty && loading == 'success'
                ? Column(
                    children: [
                      Expanded(
                        flex: 75,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.02,
                            right: screenWidth * 0.02,
                            top: screenHeight * 0.01,
                            bottom: screenHeight * 0.01,
                          ),
                          child: SizedBox(
                            height: screenHeight * 0.82,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                var item = data[index];
                                bool isEven = index.isEven;

                                Color? backgroundColor = isEven
                                    ? const Color.fromARGB(255, 221, 221, 233)
                                        .withOpacity(0.3)
                                    : null;
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: screenHeight * 0.015),
                                  child: ExpansionTileCard(
                                    baseColor: backgroundColor,
                                    elevation: 4.0,
                                    leading: CircleAvatar(
                                        child: Text((index + 1).toString())),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["fields"]["category"] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          item["fields"]["created_at"] != null
                                              ? formatDate(
                                                  item["fields"]["created_at"])
                                              : '',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.only(
                                        top: screenHeight * 0.02,
                                        bottom: screenHeight * 0.02,
                                        left: screenWidth * 0.03,
                                        right: screenWidth * 0.03),
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Sub Category: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Expanded(
                                                  child: Text(
                                                    item["fields"]
                                                            ["sub_category"] ??
                                                        '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Description: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    item["fields"]
                                                            ["description"] ??
                                                        '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.005),
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.02,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                debugPrint('Inside right block');
                                _showMyDialog(context, widget.reloadCallback);
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF0E5EB6)),
                            ),
                            child: const Center(
                              child: Text(
                                "Upload Documents",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : loading == 'progress'
                    ? Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.2),
                        child: Center(
                          child: Column(
                            children: [
                              LoadingWidget(
                                loadingText: loaderText,
                              )
                            ],
                          ),
                        ),
                      )
                    : loading == 'failed'
                        ? Container(
                            margin: EdgeInsets.only(top: screenHeight * 0.1),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/MicrosoftTeams-image.png',
                                    width: 125,
                                  ),
                                  const Text(
                                    "No Records Found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Container(
                                      padding: EdgeInsets.only(top: 20.h),
                                      width: screenWidth * 0.8,
                                      height: screenHeight * 0.08,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            print('Inside right block');
                                            _showMyDialog(
                                                context, widget.reloadCallback);
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFF0E5EB6)),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Upload Documents",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
          );
  }

  Future<void> _showMyDialog(context, callback) async {
    Dialog dialog = Dialog(
      child: LeftBlock(callback: callback),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }
}

class BottomBlock extends StatelessWidget {
  const BottomBlock({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        width: screenWidth * .938,
        height: screenHeight * .295,
        color: const Color(0xFFFFFFFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: screenHeight * 0.045, left: screenWidth * 0.039),
              child: Text(
                "Your signature",
                textAlign: TextAlign.left,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * .011,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.045),
            )
          ],
        ));
  }
}
