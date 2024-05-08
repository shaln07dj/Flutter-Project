import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initializeFirebase() async {
  bool isProd = const bool.fromEnvironment('prod', defaultValue: false);

  String envFileName = isProd ? '.env.prod' : '.env.dev';
  await dotenv.load(fileName: envFileName);
  String? apiKey = dotenv.env['API_KEY'];
  String? appId = dotenv.env['APP_ID'];
  String? messagingSenderId = dotenv.env['Messaging_Sender_ID'];
  String? projectId = dotenv.env['PROJECT_ID'];
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey ?? '',
      appId: appId ?? '',
      messagingSenderId: messagingSenderId ?? '',
      projectId: projectId ?? '',
    ),
  );
}
