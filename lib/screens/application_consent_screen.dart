import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/generate_app_id_helper.dart';
import 'package:pauzible_app/Helper/session/sign_out.dart';
import 'package:pauzible_app/app.dart';
import 'package:pauzible_app/screens/user_update.dart';
import 'package:pauzible_app/widgets/helper_widgets/text_widget.dart';

class ApplicationConsentScreen extends StatelessWidget {
  const ApplicationConsentScreen({super.key});

  void navigateToSecondPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailUpdate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    displayText: "Do you want to start new application",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  SizedBox(height: screenHeight * 0.25),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await generateAppId();
                            setUrlAppIdFlow(true);
                            navigateToSecondPage(context);
                          },
                          child: const Text('Yes'),
                        ),
                        const SizedBox(width: 100),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirmation"),
                                  content: const Text(
                                      "Are you sure you want to exit the application?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Close the dialog
                                        Navigator.of(context).pop();
                                        SignOut();
                                      },
                                      child: const Text("Okay"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
