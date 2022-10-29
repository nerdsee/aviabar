import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aviabar/code/user.dart';
import 'order.dart';
import 'product.dart';

class AviabarBackend {
  AviabarBackend._privateConstructor() {
    serverRoot = "http://192.168.1.148:8080";

    fAviabarProducts = getProducts();
  }

  static final AviabarBackend _instance = AviabarBackend._privateConstructor();
  String serverRoot = "";
  AviabarUser? currentUser = null;
  bool isServerAvailable = false;

  factory AviabarBackend() {
    return _instance;
  }

  List<AviabarProduct> aviabarProducts = [];
  late Future<List<AviabarProduct>> fAviabarProducts;

  void getIDCard() {}

  Future<AviabarUser> getUser(cardId) async {
    http.Response response = await http.get(Uri.parse('${serverRoot}/card/${cardId}'));

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
    http.Response response = await http.get(Uri.parse('${serverRoot}/products'));

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

  Future<List<AviabarOrder>> getOrders() async {

    List<AviabarOrder> aviabarOrders = [];

    if (currentUser != null) {
      http.Response response = await http.get(Uri.parse('${serverRoot}/orders/${currentUser?.id}'));

      if (response.statusCode == 200) {
        var jsonOrderList = jsonDecode(response.body);

        print("Read JSON: $jsonOrderList");

        var p2 = List.from(jsonOrderList);

        print("P2: $p2");

        p2.forEach((element) {
          print("Element: ${element}");
          aviabarOrders.add(AviabarOrder.fromJson(element));
        });

        print("Orders: ${aviabarOrders.length}");

      } else {
        throw Exception('Failed to load orders');
      }
    }
    return aviabarOrders;
  }

  Future<void> buyProduct(AviabarUser user, AviabarProduct product) async {
    http.Response response = await http.get(Uri.parse('${serverRoot}/order/${user.id}/${product.id}'));

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
  }

  Future<void> checkServerAvailability() async {
    print("Check server availability");
    final client = new HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    Future<http.Response> response = http.get(Uri.parse('${serverRoot}/products'));
    response.then(serverFound).catchError((error, stackTrace) => serverTimeout).timeout(const Duration(seconds: 10));
    return;
  }

  void serverFound(http.Response response) {
    print("response available: ${response.statusCode}");
    if (response.statusCode == 200) {
      isServerAvailable = true;
    } else {
      throw Exception('Server returns status code (${response.statusCode}).');
    }
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

  serverTimeout(error, stackTrace) {
    print("ERROR: ${error}");
  }
}
