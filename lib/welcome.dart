import 'package:aviabar/code/backend.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final mainActions;
  late final secondaryActions;

  String? name = AviabarBackend().currentUser.name;
  String? email = AviabarBackend().currentUser.email;
  bool somethingChanged = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AVIABAR"),
      ),
      body: Container(
        padding: new EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Text("Welcome Stranger"),
            TextFormField(
              initialValue: name,
              onChanged: (value) {
                name = value;
                somethingChanged = true;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.account_circle_outlined),
                labelText: 'Enter your name:',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: email,
              onChanged: (value) {
                email = value;
                somethingChanged = true;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (value != null) {
                  final bool isValid = EmailValidator.validate(value);
                  if (!isValid) return 'Please enter a valid email address';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                icon: const Icon(Icons.email_outlined),
                labelText: 'Enter your email:',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  savePreferences();
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(100, 100),
                shape: const CircleBorder(),
                primary: Colors.cyan[900],
              ),
              child: Text("Save", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> savePreferences() async {
    print("user: $name - email: $email");
    if (somethingChanged && (name != null) && (email != null)) {
      await AviabarBackend().saveUserPreferences(name!, email!);
    }
    Navigator.of(context).pop();
  }
}
