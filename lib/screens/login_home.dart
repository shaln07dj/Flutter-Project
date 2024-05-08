import 'package:flutter/material.dart';
import 'package:pauzible_app/screens/auth_gate.dart';

class LoginHome extends StatefulWidget {
  const LoginHome({super.key});

  @override
  _LoginHomeState createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Row(
      children: [
        Expanded(child: AuthGate()),
      ],
    ));
  }
}
