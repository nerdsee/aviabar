import 'package:aviabar/code/backend.dart';
import 'package:aviabar/list.dart';
import 'package:aviabar/welcome.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

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
                onPressed: readCardDialog,
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

  void readCardDialog() async {

    try {
      AviabarUser? ret = await _readCard();
      print(ret?.name);
      if (ret != null) {
        setState(() {
          user = ret;
        });
        if (ret.isRegistered) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProductList()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const WelcomePage()));
        }
      }
    }
    on NfcException catch (e) {
      AviabarBackend().snackMessage(context, e.message, Colors.red, 2);
    }
  }

  Future<AviabarUser> _readCard() async {
    String cardId = "12345";

    if (simCard) {
      cardId = "12345";
      print("Sim. user 12345");
    } else {
      print("read card");
      Future<String> cardId = readNFC();
    }

    Future<AviabarUser> user = AviabarBackend().getUser(cardId);

    return user;
  }

  Future<String> readNFC() async {
    ValueNotifier<dynamic> result = ValueNotifier(null);

    bool isAvailable = await NfcManager.instance.isAvailable();
    // Start Session
    if (isAvailable) {

      print("nfc: " + NfcManager.instance.toString());

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        result.value = tag.data;
        NfcManager.instance.stopSession();
      },onError: (NfcError error) async {
        print("NFC ERROR: ${error.message} ${error.details}");
        throw NfcException(error.message);
      } );
    }

    return "7890";
  }
}

class NfcException implements Exception {
  NfcException(this.message);
  String message;
}
