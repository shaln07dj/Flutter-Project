import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendApplicatonIdToFirestore(
    String uid, String appIdKey, dynamic appIdValue) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      appIdKey: appIdValue,
    }, SetOptions(merge: false));
  } catch (e) {
    print('Error adding custom data to Firestore: $e');
  }
}
