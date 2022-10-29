import 'package:aviabar/code/backend.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';

import 'code/order.dart';
import 'code/product.dart';
import 'code/user.dart';
import 'package:intl/intl.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({Key? key}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  late List<Slidable> _items;
  late final mainActions;
  late final secondaryActions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Purchases"),
      ),
      body: FutureBuilder(
        builder: (context, AsyncSnapshot<List<AviabarOrder>> snapshot) {
          if (snapshot.hasData) {
            return GroupedListView<AviabarOrder, String>(
              // elements: [...getItemList(snapshot.data)],
              elements: snapshot.data as List<AviabarOrder>,
              groupBy: (order) => order.getFormattedDate(),
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
                      leading: ExtendedImage.network(
                        '${AviabarBackend().serverRoot}/logos/${order.product.logo}',
                        // cache: true, (by default caches image)
                        shape: BoxShape.rectangle,
                        width: 40,
                        height: 40,
                        borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                      ),
                      title: Text(order.product.name),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
        future: AviabarBackend().getOrders(),
      ),
    );
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

  void _buy(AviabarProduct product) {
    AviabarBackend().doBuy(product, context);
  }
}
