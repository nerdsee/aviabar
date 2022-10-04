import 'dart:collection';
import 'dart:typed_data';

import 'package:aviabar/code/backend.dart';
import 'package:aviabar/list.dart';
import 'package:aviabar/welcome.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import 'code/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVIABAR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AVIABAR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AviabarUser user = AviabarUser.empty();

  bool simCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (user.isValid)
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      user = AviabarUser.empty();
                    });
                  },
                  child: Icon(
                    Icons.logout,
                    size: 26.0,
                  ),
                )),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!user.isValid)
              ElevatedButton(
                onPressed: _login,
                child: const Icon(Icons.login),
              ),
            if (user.isValid) Text(""),
            Switch(
                // This bool value toggles the switch.
                value: simCard,
                activeColor: Colors.red,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    simCard = value;
                  });
                })
          ],
        ),
      ),
    );
  }

  void _login() async {

      if (simCard) {
        print("Sim. user 12345");
        String cardId = "12345";
        _handleCard(cardId);
      } else {
        readNFC();
      }
  }

  Future<void> _handleCard(String? cardId) async {

    if (cardId != null) {
      AviabarUser user = await AviabarBackend().getUser(cardId);

      print(user.name);
      if (user != null) {
        setState(() {
          user = user;
        });
        if (user.isRegistered) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProductList()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const WelcomePage()));
        }
      }
    }
    return;
  }

  Future<void> readNFC() async {

    bool isAvailable = await NfcManager.instance.isAvailable();
    // Start Session
    if (isAvailable) {
      print("nfc: " + NfcManager.instance.toString());

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        NfcManager.instance.stopSession();
        handleTag(tag);
      }, onError: (NfcError error) async {
        String msg = "NFC ERROR: (${error.type}) ${error.message} ${error.details}";
        print(msg);
        AviabarBackend().snackMessage(context, msg, Colors.red, 2);
      });
    }

    return;
  }

  void handleTag(NfcTag tag) {
    String? cardId = null;

    Map<String, dynamic> data = tag.data;

    print("Available keys: ${data.keys.toString()}");

    Iso7816? iso = Iso7816.from(tag);

    if (iso != null) {
      cardId="";
      var id = iso.identifier;
      Uint8List data8 = new Uint8List.fromList(id);
      for (int i in data8) {
        cardId = "${cardId}${i.toRadixString(16)}";
      }
      print("Found CardId: ${cardId}");
    } else {
      String msg = "Unsupported Cars: ${data.keys.toString()}";
      AviabarBackend().snackMessage(context, msg, Colors.red, 2);
    }

    _handleCard(cardId);
  }
}


class NfcException implements Exception {
  NfcException(this.message);

  String message;
}
