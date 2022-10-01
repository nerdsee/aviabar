import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aviabar/code/user.dart';
import 'product.dart';

class AviabarBackend {

  AviabarBackend._privateConstructor() {

    serverRoot = "http://192.168.1.148:8080";

    fAviabarProducts = getProducts();
  }

  static final AviabarBackend _instance = AviabarBackend._privateConstructor();
  String serverRoot = "";
  AviabarUser? currentUser = null;

  factory AviabarBackend() {
    return _instance;
  }

  List<AviabarProduct> aviabarProducts = [];
  late Future<List<AviabarProduct>> fAviabarProducts;

  void getIDCard() {}

  Future<AviabarUser> getUser() async {
    AviabarUser user = AviabarUser.stoeve();
    currentUser = user;
    return Future.delayed(Duration(seconds: 4), () => user);
  }

  AviabarUser? getCurrentUser() {
    return currentUser;
  }

  Future<List<AviabarProduct>> getProducts() async {
    http.Response response = await http
        .get(Uri.parse('${serverRoot}/products'));

    if (response.statusCode == 200) {
      var jsonProductList = jsonDecode(response.body);

      print("Read JSON: $jsonProductList");
      // print(jsonProductList["products"]);

      var p2 = List.from(jsonProductList);
      print("P2 $p2");

      p2.forEach((element) {
        aviabarProducts.add(AviabarProduct.fromJson(element));
      });
    } else {
      throw Exception('Failed to load album');
    }

    return aviabarProducts;
  }

  void doBuy(AviabarProduct product, BuildContext context) {
    AviabarUser? currentUser = AviabarBackend().currentUser;
    String message = '';
    if (currentUser != null) {
      message =
      'Buy ${product.name} ${product.id} ${AviabarBackend().currentUser?.name}';
    } else {
      message = 'No Current User';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

}
