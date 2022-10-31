import 'package:aviabar/code/backend.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'code/product.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late final mainActions;
  late final secondaryActions;

  @override
  Widget build(BuildContext context) {
    var user = AviabarBackend().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("AVIABAR"),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: user.balance < 0 ? Colors.red[900] : Colors.green, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Text(user.getReadableBalance(),style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
      body: FutureBuilder(
        builder: (context, AsyncSnapshot<List<AviabarProduct>> snapshot) {
          if (snapshot.hasData) {
            return ListView(children: [...getItemList(snapshot.data)]);
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
        future: AviabarBackend().getProducts(),
      ),
    );
  }

  List<Widget> getItemList(List<AviabarProduct>? products) {
    List<Widget> itemlist = [];
    print("get items.");
    if (products != null) {
      int n = products.length;
      print("number of items $n");
      itemlist = [
        for (final product in products)
          Slidable(
            key: ValueKey(product.id),
            // swipe right
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.2,
              children: [
                SlidableAction(
                  label: 'Buy',
                  foregroundColor: Colors.green,
                  icon: Icons.shopping_basket,
                  onPressed: (_) => _buy(product),
                ),
              ],
            ),
            //swipe left
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.2,
              children: [
                SlidableAction(
                  label: 'Buy',
                  foregroundColor: Colors.green,
                  icon: Icons.shopping_basket,
                  onPressed: (_) => _buy(product),
                ),
              ],
            ),
            child: ListTile(
              leading: ExtendedImage.network(
                '${AviabarBackend().serverRoot}/logos/${product.logo}',
                // cache: true, (by default caches image)
                shape: BoxShape.rectangle,
                width: 40,
                height: 40,
                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
              ),
              title: Text(product.name),
              subtitle: const Text('Swipe left and right to see the actions'),
            ),
          ),
      ];
    }
    return itemlist;
  }

  void _buy(AviabarProduct product) async {
    await AviabarBackend().doBuy(product, context);
    setState(() {

    });
  }
}
