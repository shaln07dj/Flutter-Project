import 'package:firebase_auth/firebase_auth.dart';

Future updateUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  String displayName = user?.displayName ?? '';

  displayName.split('');

}
