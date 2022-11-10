import 'package:aviabar/code/backend.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';

import 'code/order.dart';
import 'package:intl/intl.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  late final mainActions;
  late final secondaryActions;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Security"),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tokens assigned to your ID Card",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan[900])),
              SizedBox(height: 5),
              Expanded(
                child: ListView(children: [
                  Container(
                      child: Card(
                          child: Column(
                    children: [
                      Text("Issuer: ${AviabarBackend().currentUser.getToken().getIssuer()}"),
                      Text("Token: ${AviabarBackend().currentUser.getToken().getTokenString()}"),
                    ],
                  )))
                ]),
              )
            ],
          ),
        ));
  }

  List<Widget> getItemList(List<AviabarOrder>? orders) {
    List<Widget> itemlist = [];
    print("get orders.");
    if (orders != null) {
      int n = orders.length;
      print("number of items $n");
      itemlist = [
        for (final order in orders)
          ListTile(
            leading: ExtendedImage.network(
              '${AviabarBackend().serverRoot}/logos/${order.product.logo}',
              // cache: true, (by default caches image)
              shape: BoxShape.rectangle,
              width: 40,
              height: 40,
              borderRadius: const BorderRadius.all(Radius.circular(3.0)),
            ),
            title: Text(order.product.name),
            subtitle: Text(DateFormat('dd.MM.yyyy – kk:mm').format(order.orderDate)),
          ),
      ];
    }
    return itemlist;
  }
}
