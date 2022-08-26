import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  static final _kActionpaneTypes = <String, Widget>{
    'DrawerMotion': DrawerMotion(),
    'BehindMotion': BehindMotion(),
    'ScrollMotion': ScrollMotion(),
    'StretchMotion': StretchMotion(),
  };
  late List<Slidable> _items;

  @override
  void initState() {
    super.initState();
    final mainActions = <Widget>[
      SlidableAction(
        label: 'Buy',
        foregroundColor: Colors.green,
        icon: Icons.shopping_basket,
        onPressed: (_) => _showSnackBar('Archive'),
      ),
    ];
    final secondaryActions = <Widget>[
      SlidableAction(
        label: 'Buy',
        foregroundColor: Colors.green,
        icon: Icons.shopping_basket,
        onPressed: (_) => _showSnackBar('More'),
      ),
    ];
    _items = [
      for (final entry in _kActionpaneTypes.entries)
        Slidable(
          key: ValueKey(entry.key),
          // swipe right
          startActionPane: ActionPane(
            motion: entry.value,
            extentRatio: 0.2,
            children: mainActions,
          ),
          //swipe left
          endActionPane: ActionPane(
            motion: entry.value,
            extentRatio: 0.2,
            children: secondaryActions,
          ),
          child: ListTile(
            leading: ExtendedImage.network(
              'https://www.fritz-kola-shop.com/media/webp_image/catalog/product/cache/1ab04fefefa1d95048e1215eaefb4050/f/r/fritz-kola_fritz-limo_honigmelone_033.webp',
              // cache: true, (by default caches image)
              shape: BoxShape.rectangle,
              width: 40,
              height: 40,
              borderRadius: const BorderRadius.all(Radius.circular(3.0)),
            ),
            title: Text('ListTile with ${entry.key}'),
            subtitle: const Text('Swipe left and right to see the actions'),
          ),
        ),
    ];
    // Dismissible tile example:
    // First create a dismissal obj
    final dismissal = DismissiblePane(
      onDismissed: () {
        _showSnackBar('Dismiss Archive');
        setState(() => this._items.removeAt(_items.length - 1));
      },
      // Confirm on dismissal:
      confirmDismiss: () async {
        final bool? ret = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Archive'),
              content: const Text('Confirm action?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
        return ret ?? false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("AVIABAR"),
          actions: [
            if (true)
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: Icon(
                      Icons.logout,
                      size: 26.0,
                    ),
                  )),
          ],
        ),
        body: ListView(children: _items));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
