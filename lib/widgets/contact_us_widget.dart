import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/mail_helper.dart';
import 'package:pauzible_app/screens/dynamic_form_json.dart';
import 'package:pauzible_app/utility_helper_methods.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';

class ContactUsForm extends StatefulWidget {
  @override
  _ContactUsFormState createState() => _ContactUsFormState();
}

class _ContactUsFormState extends State<ContactUsForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? displayName;
  String? email;
  User? auth;
  bool isSendingMessage = false;
  @override
  void initState() {
    super.initState();
    if (_auth?.currentUser!.email != null) {
      if (_auth.currentUser!.displayName != null) {
        setState(() {
          displayName = _auth.currentUser!.displayName;
          email = _auth.currentUser!.email;
        });
      }
    }
  }

  void handleSendingMessage(status) {
    setState(() {
      isSendingMessage = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: isSendingMessage == true
            ? const Center(child: LoadingWidget(loadingText: "Sending Message"))
            : Column(
                children: [
                  FormBuilderTextField(
                    name: 'subject',
                    decoration: InputDecoration(
                      enabledBorder: borderStyle(),
                      label: const LabelTextWidget(
                          fieldDisplayName: 'Subject', isRequired: true),
                      border: const OutlineInputBorder(),
                      hintText: "Subject",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      _wordLimitValidator,
                    ]),
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'message',
                    decoration: InputDecoration(
                        enabledBorder: borderStyle(),
                        label: const LabelTextWidget(
                            fieldDisplayName: 'Message', isRequired: true),
                        border: const OutlineInputBorder(),
                        hintText: "Message (250 words)",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                    maxLines: null, // Allow multiple lines
                    minLines: 3, // Set the minimum number of lines
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      _wordLimitValidator,
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _submitForm(context,
                              handleSendingMessage: handleSendingMessage);
                          handleSendingMessage(true);
                        },
                        child: const Text('Submit'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitForm(context,
      {required Function(bool status) handleSendingMessage}) async {
    String appId = await getAppId();

    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      String subject = formData['subject'];
      String mailBody = formData['message'];

      sendEmail(context, subject, mailBody,
          applicationId: appId,
          userName: displayName,
          email: email,
          handleSendingMessage: handleSendingMessage);
      print(formData);
    }
  }

  String? _wordLimitValidator(value) {
    if (value != null && value.toString().length > 250) {
      return 'Word limit exceeded (250 characters)';
    }
    return null;
  }
}
