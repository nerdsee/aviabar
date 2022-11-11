import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart';

class AviabarToken {
  late String _strToken;
  late JWT _jwtToken;

  AviabarToken(String str, JWT token) {
    _strToken = str;
    _jwtToken = token;
  }

  static Future<AviabarToken> createToken(String str) async {
    var f = await rootBundle.loadString('assets/public_key.pem');

    // final pem = File('./keys/public_key.pem').readAsStringSync();
    final key = RSAPublicKey(f);
    final jwt = JWT.verify(str, key, issuer: "aviabar");

    AviabarToken token = AviabarToken(str, jwt);

    return token;
  }

  String getIssuer() {
    return _jwtToken.issuer ?? "";
  }

  String getTokenString() {
    return _strToken;
  }

  AviabarToken.empty() {}

}
