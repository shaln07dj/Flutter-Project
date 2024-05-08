import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pauzible_app/Helper/Constants/colors.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/widgets/contact_us_widget.dart';
import 'package:pauzible_app/widgets/helper_widgets/text_widget.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';

class Footer extends StatelessWidget {
  Future<String> getVersionNumber() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('Error fetching version number: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<String>(
      future: getVersionNumber(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: 10.w, child: const LoadingWidget());
        }

        if (snapshot.hasError) {
          return const Text('Error fetching version number');
        }

        String versionNumber = snapshot.data!;

        // if (isDesktop(context) || isTablet(context)) {
        //   return Container(
        //     padding: EdgeInsets.all(screenWidth * 0.004),
        //     color: Color(seedColor),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: [
        //         TextWidget(
        //           displayText: 'version $versionNumber',
        //           fontWeight: FontWeight.bold,
        //           fontSize: 12,
        //           fontColor: Colors.white,
        //         ),
        //         TextWidget(
        //           displayText: footerCopywriteText,
        //           fontWeight: FontWeight.bold,
        //           fontSize: 12,
        //           fontColor: Colors.white,
        //         ),
        //         RichText(
        //           text: TextSpan(
        //             children: [
        //               const TextSpan(
        //                 text: footerTroubleText,
        //                 style: TextStyle(
        //                   fontSize: 12,
        //                   color: Colors.white,
        //                 ),
        //               ),
        //               TextSpan(
        //                 text: footerContactText,
        //                 style: const TextStyle(
        //                   fontSize: 12,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.white,
        //                 ),
        //                 recognizer: TapGestureRecognizer()
        //                   ..onTap = () {
        //                     showDialog(
        //                       context: context,
        //                       builder: (BuildContext context) {
        //                         return AlertDialog(
        //                           title: const Text(
        //                             "Contact Us",
        //                             textAlign: TextAlign.center,
        //                           ),
        //                           contentPadding: EdgeInsets.symmetric(
        //                               horizontal: screenWidth * 0.1,
        //                               vertical: screenHeight * 0.1),
        //                           content: SizedBox(
        //                             width: screenWidth * 0.3,
        //                             height: screenHeight * 0.4,
        //                             child: ContactUsForm(),
        //                           ),
        //                         );
        //                       },
        //                     );
        //                   },
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   );
        // }
        // //else if (isMobile(context)) {
        // //   return Container(
        // //     padding: EdgeInsets.all(screenWidth * 0.004),
        // //     color: Color(seedColor),
        // //     child: Padding(
        // //       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18),
        // //       child: TextWidget(
        // //         displayText: footerCopywriteText,
        // //         fontWeight: FontWeight.bold,
        // //         fontSize: 12,
        // //         fontColor: Colors.white,
        // //       ),
        // //     ),
        // //   );
        // // }
        // else {
        //   return SizedBox();
        // }
        if (isDesktop(context) || isTablet(context)) {
          return Container(
            padding: EdgeInsets.all(screenWidth * 0.004),
            color: Color(seedColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextWidget(
                  displayText: 'version $versionNumber',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontColor: Colors.white,
                ),
                TextWidget(
                  displayText: footerCopywriteText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontColor: Colors.white,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: footerTroubleText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: footerContactText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
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
                                      text: const TextSpan(children: [
                                        TextSpan(
                                          text:
                                              "If you encounter any issues while using our application, have any questions, feedback or suggestions, we're here to help! Please feel free to reach out to our support team at ",
                                          style: TextStyle(
                                              fontSize: 14, height: 1.5),
                                        ),
                                        TextSpan(
                                          text: "support@pauzible.com",
                                          style: TextStyle(
                                              fontSize: 14,
                                              height: 1.5,
                                              fontWeight: FontWeight.bold),
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
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (isMobile(context)) {
          return Container(
            padding: EdgeInsets.all(screenWidth * 0.004),
            color: Color(seedColor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18),
              child: TextWidget(
                displayText: footerCopywriteText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontColor: Colors.white,
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
