import 'package:firebase_auth/firebase_auth.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/generate_app_id_helper.dart';
import 'package:pauzible_app/Helper/get_skyflow_id.dart';
import 'package:pauzible_app/Helper/post_application_id_helper.dart';

Future<void> updateDisplayName(String firstName, String lastName, String token,
    String applicationId, Function redirect,
    {generateNewApplication,
    required Function(bool status) handleUpdating}) async {
  print("TOKEN");
  print(token);
  try {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    String? email = user!.email;

    if (user != null) {
      // await user.reload();

      user = FirebaseAuth.instance.currentUser;
      if (generateNewApplication == true) {
        if (applicationId == '') {
          var newApplicationId = await generateAppId();
          await sendAppId(
              newApplicationId, userId, email!, '$firstName $lastName',
              handleUpdating: handleUpdating);
          await fetchSkyflowId(token, applicationRecordsTable, true,
              firstName: firstName,
              lastName: lastName,
              handleUpdating: handleUpdating);
        }
      } else {
        await sendAppId(applicationId, userId, email!, '$firstName $lastName',
            handleUpdating: handleUpdating);

        await fetchSkyflowId(token, applicationRecordsTable, true,
            firstName: firstName,
            lastName: lastName,
            handleUpdating: handleUpdating);
      }
    } else {
      print('No user signed in.');
    }
  } catch (e) {
    print('Error updating user display name: $e');
  }
}
