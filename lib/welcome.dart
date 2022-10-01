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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AVIABAR"),
        actions: [
          if (true)
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: const Icon(
                    Icons.logout,
                    size: 26.0,
                  ),
                )),
        ],
      ),
      body: Text("Welcome Stranger"),
    );
  }
}
