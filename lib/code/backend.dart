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

  Future<AviabarUser> getUser(cardId) async {
    http.Response response =
        await http.get(Uri.parse('${serverRoot}/card/${cardId}'));

    AviabarUser user;

    if (response.statusCode == 200) {
      var jsonUser = jsonDecode(response.body);

      // print("Read JSON: $jsonUser");

      user = AviabarUser.fromJson(jsonUser);
      // print("P2 $user");
    } else {
      throw Exception('Failed to load user');
    }

    currentUser = user;
    return user;
  }

  AviabarUser? getCurrentUser() {
    return currentUser;
  }

  Future<List<AviabarProduct>> getProducts() async {
    http.Response response =
        await http.get(Uri.parse('${serverRoot}/products'));

    if (response.statusCode == 200) {
      var jsonProductList = jsonDecode(response.body);

      // print("Read JSON: $jsonProductList");

      var p2 = List.from(jsonProductList);

      p2.forEach((element) {
        aviabarProducts.add(AviabarProduct.fromJson(element));
      });
    } else {
      throw Exception('Failed to load album');
    }

    return aviabarProducts;
  }

  Future<void> buyProduct(AviabarUser user, AviabarProduct product) async {
    http.Response response = await http
        .get(Uri.parse('${serverRoot}/order/${user.id}/${product.id}'));

    if (response.statusCode == 200) {
      var jsonProductList = jsonDecode(response.body);

      print("Read JSON: $jsonProductList");
      // print(jsonProductList["products"]);

    } else {
      throw Exception('Failed to load album');
    }

    return;
  }

  void doBuy(AviabarProduct product, BuildContext context) {
    AviabarUser? currentUser = AviabarBackend().currentUser;
    String message = '';
    if (currentUser != null) {
      buyProduct(currentUser, product);
      message = 'Buy ${product.name} ${product.id} ${currentUser.name}';
    } else {
      message = 'No Current User';
    }

    snackMessage(context, message, Colors.green, 1);

/*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
*/
  }

  void snackMessage(BuildContext context, String message, MaterialColor color, int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: seconds),
      ),
    );
  }
}
