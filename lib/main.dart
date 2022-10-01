import 'package:aviabar/code/backend.dart';
import 'package:aviabar/list.dart';
import 'package:aviabar/welcome.dart';
import 'package:flutter/material.dart';

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
            if (user.isValid) Text("")
          ],
        ),
      ),
    );
  }

  void readCardDialog() async {

    SimpleDialog cardReaderDialog = SimpleDialog(
      title: const Text('Show ID Card'),
      children: [
        FutureBuilder(
          builder: (context, AsyncSnapshot<AviabarUser> snapshot) {
            if (snapshot.hasData) {
              Navigator.pop(context, snapshot.data);
              return const Text("");
            } else {
              return Center(child: const CircularProgressIndicator());
            }
          },
          future: _readCard(),
        ),
      ],
    );

    AviabarUser? ret = await showDialog<AviabarUser>(context: context, builder: (context) => cardReaderDialog);
    print(ret?.name);
    if (ret != null) {
      setState(() {
        user = ret;
      });
      if (ret.isRegistered) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductList()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
      }
    }
  }

  Future<AviabarUser> _readCard() async {
    String cardId = "12345";

    Future<AviabarUser> user = AviabarBackend().getUser(cardId);

    return user;
  }
}
