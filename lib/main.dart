import 'dart:collection';
import 'dart:typed_data';

import 'package:aviabar/code/backend.dart';
import 'package:aviabar/list.dart';
import 'package:aviabar/welcome.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'code/user.dart';
import 'package:http/http.dart' as http;

import 'orderhistory.dart';

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
  bool showServerError = false;

  serverStateChecked(void v) {
    print("server state checked.");
    setState(() {
      if (!AviabarBackend().isServerAvailable) {
        showServerError = true;
      } else {
        showServerError = false;
      }
    });
  }

  void connectionTimeout() {
    print("No connection to server");
    return;
  }

  @override
  void initState() {
    super.initState();
    checkServer();
  }

  void checkServer() {
    AviabarBackend().checkServerAvailability().then(serverStateChecked);
  }

  @override
  Widget build(BuildContext context) {
    print("Backend is available ${AviabarBackend().isServerAvailable}");
    print("Error is visible ${showServerError}");

    if (!user.isValid) loadUserFromPreferences();

    var drawerHeader = DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.cyan[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: FlutterLogo(size: 42.0),
            ),
            SizedBox(height: 20),
            Text(user.name, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ));

    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
          title: const Text('Purchase History'),
          //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderHistory()));
          },
        ),
        ListTile(
          title: const Text('Sign Out'),
          onTap: () {
            Navigator.of(context).pop();
            setState(() {
              _logout();
            });
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showServerError)
              Column(children: [
                Container(
                    height: 50,
                    width: 200,
                    alignment: Alignment.center,
                    child: Text(
                      "Server error.",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900]),
                    )),
                ElevatedButton(
                  onPressed: checkServer,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 100),
                    shape: const CircleBorder(),
                    primary: Colors.red[900],
                  ),
                  child: Text("Retry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                )
              ]),
            if (!user.isValid)
              Column(
                children: [
                  Container(
                      height: 50,
                      width: 200,
                      alignment: Alignment.center,
                      child: Text(
                        "",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.cyan[300]),
                      )),
                  ElevatedButton(
                    onPressed: AviabarBackend().isServerAvailable ? _login : null,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 200),
                      shape: const CircleBorder(),
                      primary: Colors.cyan[300],
                    ),
                    child: Text("Login", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            if (user.isValid)
              Column(
                children: [
                  Container(
                      height: 50,
                      width: 200,
                      alignment: Alignment.center,
                      child: Text(
                        "Hello, ${user.name}",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.cyan[900]),
                      )),
                  ElevatedButton(
                    onPressed: _order,
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 200), shape: const CircleBorder(), primary: Colors.cyan[900]),
                    child: Text(
                      "Order",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
      endDrawer: user.isValid
          ? Drawer(
              child: user.isValid ? drawerItems : null,
            )
          : null,
    );
  }

  /*
  * Preference Handling
  *
  * */

  Future<void> loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final cardId = prefs.getString('aviabar_cardid') ?? "";

    print("Found Card: ${cardId}");

    if (cardId != "") {
      _handleCard(cardId);
    }
  }

  Future<void> removeUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('aviabar_cardid');
  }

  /*
  * METHODS
  * */

  /* interim function to enable testing with a pseudo id
  * normally just forwards to NFC handling for new users
  * */
  void _login() async {
    if (simCard) {
      print("Sim. user 12345");
      String cardId = "12345";
      _handleCard(cardId);
    } else {
      _readNFC();
    }
  }

  void _logout() {
    removeUserFromPreferences();
    this.user = AviabarUser.empty();
  }

  /* for a given card ID, load the AVIABAR user
  * */
  Future<void> _handleCard(String? cardId) async {
    if (cardId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aviabar_cardid', cardId);

      AviabarUser newuser = await AviabarBackend().getUser(cardId);

      print(newuser.name);
      if (newuser != null) {
        setState(() {
          user = newuser;
        });
      }
    }
    return;
  }

  /**
   * forward to the product list
   */
  void _order() {
    if (user != null) {
      if (user.isRegistered) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
      }
    }
    return;
  }

  Future<void> _readNFC() async {
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

  /*
  * callback to handle the cardID read by the NFC reader
  * */
  void handleTag(NfcTag tag) {
    String? cardId = null;

    Map<String, dynamic> data = tag.data;

    print("Available keys: ${data.keys.toString()}");

    Iso7816? iso = Iso7816.from(tag);

    if (iso != null) {
      cardId = "";
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
