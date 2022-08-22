import 'package:flutter/material.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Two-line list'),
        ),
        body: ListView(
          children: [
            Card(
                clipBehavior: Clip.antiAlias,
                child: Row(children: [
                  Text("JAN"),
                  ListTile(
                    title: Text('List item 1'),
                    subtitle: Text('Secondary text'),
                    trailing: Radio(
                      value: 1,
                      groupValue: "1",
                      onChanged: (value) {
                        // Update value.
                      },
                    ),
                  )
                ])),
            Card(
                child: ListTile(
              title: Text('List item 2'),
              subtitle: Text('Secondary text'),
              leading: Icon(Icons.label),
              trailing: Radio(
                value: 2,
                groupValue: "1",
                onChanged: (value) {
                  // Update value.
                },
              ),
            )),
          ],
        ));
  }
}
