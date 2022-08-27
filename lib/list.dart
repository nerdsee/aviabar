import 'package:aviabar/code/backend.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'code/user.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late List<Slidable> _items;
  late final mainActions;
  late final secondaryActions;

  @override
  void initState() {
    super.initState();
    mainActions = <Widget>[
      SlidableAction(
        label: 'Buy',
        foregroundColor: Colors.green,
        icon: Icons.shopping_basket,
        onPressed: (_) => _showSnackBar('Archive'),
      ),
    ];
    secondaryActions = <Widget>[
      SlidableAction(
        label: 'Buy',
        foregroundColor: Colors.green,
        icon: Icons.shopping_basket,
        onPressed: (_) => _showSnackBar('More'),
      ),
    ];

  }

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
      body:
      FutureBuilder(
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
                  onPressed: (_) => _showSnackBar('Buy ${product.id}'),
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
                  onPressed: (_) => _showSnackBar('Buy ${product.id}'),
                ),
              ],
            ),
            child: ListTile(
              leading: ExtendedImage.network(
                'https://www.notonto.de/aviabar/${product.logo}',
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1),),
    );
  }
}
