import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';

class ThankYouWidget extends StatefulWidget {
  Function(bool isFormResetStatus, bool isFormSubmitedStatus)
      handelFormDetailsScreen;
  ThankYouWidget({required this.handelFormDetailsScreen, Key? key})
      : super(key: key);

  @override
  _ThankYouWidgetState createState() => _ThankYouWidgetState();
}

class _ThankYouWidgetState extends State<ThankYouWidget> {
  void navigateToTab(int index) {
    DefaultTabController.of(context)?.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
        designSize: Size(screenWidth, screenHeight),
        builder: (BuildContext context, Widget? child) {
          return isDesktop(context) || isTablet(context)
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 35,
                          color: Colors.green,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Thank you for submitting your information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              :  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100.w,
                    ),
                    const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      child: Text(
                        'Thank you for submitting your information',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
        });
  }
}
