import 'dart:convert';
import 'dart:io';

import 'package:aviabar/code/device.dart';
import 'package:aviabar/code/ppresponse.dart';
import 'package:aviabar/code/token.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:aviabar/code/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order.dart';
import 'product.dart';

class AviabarBackend {
  static final AviabarBackend _instance = AviabarBackend._privateConstructor();
  String serverRoot = "";
  AviabarUser currentUser = AviabarUser.empty();
  AviabarToken currentToken = AviabarToken.empty();

  bool isServerAvailable = false;

  AviabarBackend._privateConstructor() {
    serverRoot = "http://192.168.1.148:8080";
    // serverRoot = "http://www.notonto.de:8080";

    loadUserFromPreferences();

    fAviabarProducts = getProducts();
  }

  factory AviabarBackend() {
    return _instance;
  }

  List<AviabarProduct> aviabarProducts = [];
  late Future<List<AviabarProduct>> fAviabarProducts;

  void getIDCard() {}

  Future<AviabarUser> getUser(cardId) async {

    Uri url = Uri.parse('$serverRoot/card/$cardId/device/123');
    print("URL: $url");
    http.Response response = await http.get(url);

    AviabarUser user;

    Device device = Device();
    await device.initPlatformState();
    //device.print_devicedata();

    String identifier = device.getIdentifier();

    if (response.statusCode == 200) {
      var jsonUser = jsonDecode(response.body);

      print("Read JSON: $jsonUser");
      user = AviabarUser.fromJson(jsonUser);

      print("Headers (${response.headers.keys})");

      String? token = response.headers["avi_token"];

      if (token != null) {
        print("Token: $token");

        validateToken(token);
        user.setToken(token);

        currentUser = user;
        currentToken = await AviabarToken.createToken(token);

        return currentUser;
      } else {
        print("No Token found");
        throw Exception('No valid token found');
      }
      // print("P2 $user");
    } else {
      throw Exception('Failed to load user');
    }
  }

  void validateToken(String token) async {
    /* Verify */
    try {
      // Verify a token

      var f = await rootBundle.loadString('assets/public_key.pem');

      // final pem = File('./keys/public_key.pem').readAsStringSync();
      final key = RSAPublicKey(f);

      final jwt = JWT.verify(token, key, issuer: "aviabar");
      print('Payload: ${jwt.payload}');
      print('Subject: ${jwt.subject}');
      print('Issuer: ${jwt.issuer}');
    } on JWTExpiredError catch (ex) {
      print('jwt expired');
      throw ex;
    } on JWTError catch (ex) {
      print("Invalid Token: ${ex.message}"); // ex: invalid signature
      throw ex;
    }
  }

  Future<AviabarUser> saveUserPreferences(String username, String email) async {
    print("Store Preferences (${currentUser.id}): $username");

    currentUser.name = username;
    currentUser.email = email;

    var body = jsonEncode(currentUser);

    http.Response response = await http.put(Uri.parse('$serverRoot/user/${currentUser.id}'),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print("User updated.");

      var jsonUser = jsonDecode(response.body);
      print("Read JSON: $jsonUser");
      currentUser = AviabarUser.fromJson(jsonUser);
    } else {
      throw Exception('Failed to load user (${response.statusCode})');
    }
    return currentUser;
  }

  Future<AviabarUser> saveUserPreferencesDirect(String username, String email) async {
    print("Store Preferences (${currentUser.id}): $username");
    http.Response response = await http.put(Uri.parse('$serverRoot/user/${currentUser.id}/$username'));

    if (response.statusCode == 200) {
      var jsonUser = jsonDecode(response.body);

      print("Read JSON: $jsonUser");

      currentUser = AviabarUser.fromJson(jsonUser);
      // print("P2 $user");
    } else {
      throw Exception('Failed to load user (${response.statusCode})');
    }
    return currentUser;
  }

  AviabarUser? getCurrentUser() {
    return currentUser;
  }

  Future<List<AviabarProduct>> getProducts() async {
    http.Response response = await http.get(Uri.parse('$serverRoot/products'));

    if (response.statusCode == 200) {
      var jsonProductList = jsonDecode(response.body);

      // print("Read JSON: $jsonProductList");

      var p2 = List.from(jsonProductList);

      aviabarProducts.clear();

      p2.forEach((element) {
        aviabarProducts.add(AviabarProduct.fromJson(element));
      });
    } else {
      throw Exception('Failed to load product list');
    }

    return aviabarProducts;
  }

  Future<List<AviabarOrder>> getOrders() async {
    List<AviabarOrder> aviabarOrders = [];

    http.Response response = await http.get(Uri.parse('$serverRoot/orders/${currentUser.id}'));

    if (response.statusCode == 200) {
      var jsonOrderList = jsonDecode(response.body);

      print("Read Orders JSON: $jsonOrderList");

      var p2 = List.from(jsonOrderList);

      print("P2: $p2");

      p2.forEach((element) {
        print("Element: $element");
        aviabarOrders.add(AviabarOrder.fromJson(element));
      });

      print("Orders: ${aviabarOrders.length}");
    } else {
      throw Exception('Failed to load orders');
    }

    return aviabarOrders;
  }

  Future<void> doBuy(AviabarProduct product, BuildContext context) async {
    AviabarUser currentUser = AviabarBackend().currentUser;
    String message = '';

    print("Order token: ${currentToken.getTokenString()}");

    http.Response response = await http.get(
      Uri.parse('$serverRoot/order/${currentUser.id}/${product.id}'),
      headers: {
        'avi_token': currentToken.getTokenString(),
      },
    );

    if (response.statusCode == 200) {
      var jsonOrder = jsonDecode(response.body);

      print("Read order JSON: $jsonOrder");
      // print(jsonProductList["products"]);

      currentUser.reduceBalance(product.price);

      message = 'You successfully bought ${product.name} ${product.id} ${currentUser.name}';
      snackMessage(context, message, Colors.green, 1);
    } else {
      message = 'Unauthorized.';
      snackMessage(context, message, Colors.red, 2);
      // throw Exception('Unauthorized.');
    }

    return;
  }

  /*
  * Preference Handling
  *
  * */

  Future<void> loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final cardId = prefs.getString('aviabar_cardid') ?? "";

    print("Found Card: $cardId");

    currentUser = await AviabarBackend().getUser(cardId);
  }

  Future<void> removeUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('aviabar_cardid');
  }

  Future<void> checkServerAvailability() async {
    print("Check server availability");
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    Future<http.Response> response = http.get(Uri.parse('$serverRoot/products'));
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
    print("ERROR: $error");
  }

  void logout() {
    removeUserFromPreferences();
    currentUser = AviabarUser.empty();
  }

  void rechargeUser(PPResponse response) {
    print("Recharge: ${currentUser.name} with ${response.amount}");
  }
}
