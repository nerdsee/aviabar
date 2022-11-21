import 'package:aviabar/code/backend.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';

import 'code/order.dart';
import 'package:intl/intl.dart';

import 'code/token.dart';

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
        body: FutureBuilder<List<AviabarToken>>(
          future: AviabarBackend().getUserToken(),
          builder: (context, AsyncSnapshot<List<AviabarToken>> snapshot) {
            if (snapshot.hasData) {
              var tokenList = snapshot.data as List<AviabarToken>;

              return GroupedListView<AviabarToken, String>(
                // elements: [...getItemList(snapshot.data)],
                elements: tokenList,
                groupBy: (token) => token.valid ? "VALID" : "INVALID",
                groupComparator: (value1, value2) => value2.compareTo(value1),
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                itemBuilder: (c, order) {
                  return Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: SizedBox(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        leading: Icon(Icons.security, color: order.valid ? Colors.green[900] : Colors.red[900],),
                        title: Text("TOKEN"),
                        subtitle: Text("Issuer: ${order.getIssuer()}"),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: const CircularProgressIndicator());
            }
          },
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
