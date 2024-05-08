import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Fab_Whatsapp extends StatelessWidget {
  const Fab_Whatsapp({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      onPressed: () async {
        String prewrittenMessage = Uri.encodeComponent(
            "Hi, I would like to know more about the product.");
        Uri whatsappUrl =
            Uri.parse("https://wa.me/4402088653352?text=$prewrittenMessage");
        // if (await canLaunchUrl(whatsappUrl)) {
        debugPrint("Inside Whatsapp");
        await launchUrl(
          whatsappUrl,
        );
      },
      child: Image.asset(
        'assets/images/whatsapp-iconwebp.webp',
      ),
    );
  }
}
