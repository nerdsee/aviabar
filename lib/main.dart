import 'package:aviabar/code/backend.dart';
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

  AviabarUser user = AviabarUser();

  @override
  Widget build(BuildContext context) {
    SimpleDialog sd = SimpleDialog(
      title: Text('Show ID Card'),
      children: [
        FutureBuilder(
          builder: (context, AsyncSnapshot<AviabarUser> snapshot) {
            if (snapshot.hasData) {
              Navigator.pop(context, snapshot.data);
              return Text("");
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
          future: _login(),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (user.valid)
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      user = AviabarUser();
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
            if (!user.valid)
              ElevatedButton(
                onPressed: () async {
                  AviabarUser? ret = await showDialog<AviabarUser>(
                      context: context, builder: (context) => sd);
                  print(ret?.name);
                  if (ret != null) {
                    setState(() {
                      user = ret;
                    });
                  }
                },
                child: const Icon(Icons.login),
              ),
            if (user.valid) Text(user.name)
          ],
        ),
      ),
    );
  }

  Future<AviabarUser> _login() async {
    AviabarUser user = await AviabarBackend().getUser();

    return user;
  }
}
