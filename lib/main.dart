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
  AviabarBackend();
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
        primarySwatch: Colors.blueGrey,
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
  bool simCard = true;
  bool showServerError = false;

  serverStateChecked() {
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
    AviabarBackend().checkServerAvailability();
    Future.delayed(Duration(seconds: 10), serverStateChecked);
  }

  @override
  Widget build(BuildContext context) {
    print("Backend is available ${AviabarBackend().isServerAvailable}");
    print("Error is visible $showServerError");

    AviabarUser user = AviabarBackend().currentUser;
    print("User $user");

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
              minRadius: 30,
              child: FlutterLogo(size: 30.0),
            ),
            SizedBox(height: 20),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(user.name.length == 0 ? "*" : user.name,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))),
          ],
        ));

    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
          leading: const Icon(Icons.history),
          minLeadingWidth: 10,
          title: const Text('Purchase History', style: TextStyle(fontSize: 20)),
          //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderHistory()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.euro),
          minLeadingWidth: 10,
          title: const Text('Recharge', style: TextStyle(fontSize: 20)),
          //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
          onTap: () {
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          minLeadingWidth: 10,
          title: const Text('Preferences', style: TextStyle(fontSize: 20)),
          //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
          onTap: () async {
            Navigator.of(context).pop();
            final val = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WelcomePage()));
            print("Returned from Welcome");
            setState(() {
              user = AviabarBackend().currentUser;
            });
          },
        ),
        Divider(
          color: Colors.grey,
          thickness: 2,
          indent: 10,
          endIndent: 10,
        ),
        ListTile(
          leading: Icon(Icons.logout),
          minLeadingWidth: 10,
          title: const Text('Sign Out', style: TextStyle(fontSize: 20)),
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
            if (!user.isRegistered)
              Column(
                children: [
                  Container(
                      width: 200,
                      alignment: Alignment.center,
                      child: Text(
                        "",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.cyan[300]),
                      )),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: AviabarBackend().isServerAvailable ? _login : null,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 160),
                      shape: CircleBorder(side: BorderSide(color: Colors.cyan, width: 5)),
                      primary: Colors.cyan[300],
                    ),
                    child: Text("Login", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            if (user.isRegistered)
              Column(
                children: [
                  Container(
                      width: 250,
                      alignment: Alignment.center,
                      child: RichText(textAlign: TextAlign.center,
                          text: TextSpan(
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.cyan[900]),
                        children: [
                          TextSpan(
                            text: "Hi ",
                          ),
                          TextSpan(text: "${user.name}", style: TextStyle(color: Colors.cyan[700])),
                          TextSpan(
                            text: ", let's have a drink.",
                          ),
                        ],
                      ))),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _order,
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(160, 160),
                        shape: const CircleBorder(side: BorderSide(color: Color(0xFF0097A7), width: 5)),
                        primary: Colors.cyan[900]),
                    child: Text(
                      "Order",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                      width: 250,
                      alignment: Alignment.center,
                      child: RichText(textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan[900]),
                            children: [
                              TextSpan(
                                text: "Your balance is ",
                              ),
                              TextSpan(text: "${user.getReadableBalance()} EUR", style: TextStyle(color: user.balance < 0 ? Colors.red[900] : Colors.cyan[700])),
                            ],
                          ))),

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
      endDrawer: user.isRegistered
          ? Drawer(
              child: user.isRegistered ? drawerItems : null,
            )
          : null,
    );
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
    AviabarBackend().logout();
  }

  /* for a given card ID, load the AVIABAR user
  * */
  Future<void> _handleCard(String? cardId) async {
    if (cardId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aviabar_cardid', cardId);

      AviabarUser newuser = await AviabarBackend().getUser(cardId);

      if (newuser.isRegistered) {
        setState(() {
          AviabarBackend().currentUser = newuser;
        });
      } else {
        final val = await Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
        setState(() {});
      }
    }
    return;
  }

  /**
   * forward to the product list
   */
  void _order() async {
    print("Order: ${AviabarBackend().currentUser}");

    if (AviabarBackend().currentUser.isRegistered) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
      setState(() {

      });
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
        cardId = "$cardId${i.toRadixString(16)}";
      }
      print("Found CardId: $cardId");
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
