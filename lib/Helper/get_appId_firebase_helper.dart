import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> fetchCustomDataFromFirestore() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("GET UI FROM FB");
      print(user.uid);
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data()!;
        dynamic customValue = userData['application_id'];
        print('Custom Value: $customValue');
      } else {
        print('User document does not exist.');
      }
    } else {
      print('User is not logged in.');
    }
  } catch (e) {
    if (e is FirebaseException && e.code == 'unavailable') {
      print('Error: The client is offline.');
    } else {
      print('Error fetching custom data from Firestore: $e');
    }
  }
}
