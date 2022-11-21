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
  String _serverRoot = "";
  AviabarUser _currentUser = AviabarUser.empty();
  AviabarToken _currentToken = AviabarToken.empty();
  List<AviabarProduct> _currentProducts = [];

  // late List<AviabarProduct> currentProducts;

  bool isServerAvailable = false;

  AviabarBackend._privateConstructor() {
    _serverRoot = "http://192.168.1.148:8080";
    // serverRoot = "http://www.notonto.de:8080";
    loadUserFromPreferences();
    loadProducts();
  }

  factory AviabarBackend() {
    return _instance;
  }

  void getIDCard() {}

  String get serverRoot {
    return _serverRoot;
  }

  void setServer(bool testServer) {
    if (testServer) {
      _serverRoot = "http://192.168.1.148:8080";
    } else {
      _serverRoot = "http://www.notonto.de:8080";
    }
  }

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

      String? tokenString = response.headers["avi_token"];

      if (tokenString != null) {
        print("Token: $tokenString");

        validateToken(tokenString);

        _currentUser = user;
        _currentToken = await AviabarToken.createToken(tokenString);

        return _currentUser;
      } else {
        print("No Token found");
        throw Exception('No valid token found');
      }
      // print("P2 $user");
    } else {
      throw Exception('Failed to load user');
    }
  }

  AviabarUser get currentUser {
    return _currentUser;
  }

  AviabarToken get currentToken {
    return _currentToken;
  }

  List<AviabarProduct> get currentProducts {
    return _currentProducts;
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
    print("Store Preferences (${_currentUser.id}): $username");

    _currentUser.name = username;
    _currentUser.email = email;

    var body = jsonEncode(_currentUser);

    http.Response response = await http.put(Uri.parse('$serverRoot/user/${_currentUser.id}'),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print("User updated.");

      var jsonUser = jsonDecode(response.body);
      print("Read JSON: $jsonUser");
      _currentUser = AviabarUser.fromJson(jsonUser);
    } else {
      throw Exception('Failed to load user (${response.statusCode})');
    }
    return _currentUser;
  }

  Future<AviabarUser> saveUserPreferencesDirect(String username, String email) async {
    print("Store Preferences (${_currentUser.id}): $username");
    http.Response response = await http.put(Uri.parse('$serverRoot/user/${_currentUser.id}/$username'));

    if (response.statusCode == 200) {
      var jsonUser = jsonDecode(response.body);

      print("Read JSON: $jsonUser");

      _currentUser = AviabarUser.fromJson(jsonUser);
      // print("P2 $user");
    } else {
      throw Exception('Failed to load user (${response.statusCode})');
    }
    return _currentUser;
  }

  Future<void> loadProducts() async {
    http.Response response = await http.get(Uri.parse('$serverRoot/products'));

    if (response.statusCode == 200) {
      var jsonProductList = jsonDecode(response.body);

      print("Read JSON products: $jsonProductList");

      var p2 = List.from(jsonProductList);

      _currentProducts.clear();

      p2.forEach((element) {
        _currentProducts.add(AviabarProduct.fromJson(element));
      });
    } else {
      throw Exception('Failed to load product list');
    }
  }

  Future<List<AviabarToken>> getUserToken() async {
    print("Order token: ${_currentToken.tokenString}");

    http.Response response = await http.get(
      Uri.parse('$serverRoot/token/${_currentUser.id}'),
      headers: {
        'avi_token': _currentToken.tokenString,
      },
    );

    List<AviabarToken> tokenList = [];

    if (response.statusCode == 200) {
      var jsonProductList = jsonDecode(response.body);

      print("Read JSON products: $jsonProductList");

      var p2 = List.from(jsonProductList);

      print("P2: $p2");

      for (var element in p2) {
        AviabarToken at = await AviabarToken.fromJson(element);
        tokenList.add(at);
      }
    } else {
      throw Exception('Failed to load product list');
    }

    return tokenList;
  }

  Future<List<AviabarOrder>> getOrders() async {
    List<AviabarOrder> aviabarOrders = [];

    http.Response response = await http.get(Uri.parse('$serverRoot/orders/${_currentUser.id}'));

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
    String message = '';

    print("Order token: ${_currentToken.tokenString}");

    http.Response response = await http.get(
      Uri.parse('$serverRoot/order/${_currentUser.id}/${product.id}'),
      headers: {
        'avi_token': _currentToken.tokenString,
      },
    );

    if (response.statusCode == 200) {
      var jsonOrder = jsonDecode(response.body);

      print("Read order JSON: $jsonOrder");
      // print(jsonProductList["products"]);

      _currentUser.reduceBalance(product.price);

      message = 'Enjoy your ${product.name} ';
      snackMessage(context, message, Colors.green, 2);
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

    _currentUser = await AviabarBackend().getUser(cardId);
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
    _currentUser = AviabarUser.empty();
  }

  Future<AviabarUser> rechargeUser(PPResponse ppResponse) async {
    print("Recharge: ${_currentUser.name} with ${ppResponse.amount}");

    var body = jsonEncode(ppResponse);

    String uri = '$serverRoot/recharge/${_currentUser.id}';
    print("Recharge URI: $uri");

    http.Response response = await http.put(Uri.parse(uri),
        headers: {"Content-Type": "application/json", 'avi_token': _currentToken.tokenString}, body: body);

    if (response.statusCode == 200) {
      print("User recharged.");

      var jsonUser = jsonDecode(response.body);
      print("Read JSON: $jsonUser");
      _currentUser = AviabarUser.fromJson(jsonUser);
    } else {
      throw Exception('Failed to load user (${response.statusCode})');
    }
    return _currentUser;
  }
}
