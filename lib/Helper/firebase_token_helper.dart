import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseIdToken() async {
  String tokenFirebase =
      await FirebaseAuth.instance.currentUser?.getIdToken() as String;
  return tokenFirebase;
}
