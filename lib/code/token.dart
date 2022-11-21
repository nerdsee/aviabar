import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart';

class AviabarToken {
  late String _strToken;
  late JWT _jwtToken;
  late bool _valid;

  AviabarToken(String str, JWT token, bool valid) {
    _strToken = str;
    _jwtToken = token;
    _valid = valid;
  }

  static Future<AviabarToken> createToken(String str) async {

    JWT jwt = await _buildJWTToken(str);
    AviabarToken token = AviabarToken(str, jwt, true);

    return token;
  }

  static Future<JWT> _buildJWTToken(String str) async {
    var f = await rootBundle.loadString('assets/public_key.pem');

    // final pem = File('./keys/public_key.pem').readAsStringSync();
    final key = RSAPublicKey(f);
    final jwt = JWT.verify(str, key, issuer: "aviabar");
    return jwt;
  }

  static Future<AviabarToken> fromJson(Map<String, dynamic> json) async {
    final String strToken = json['tokenString'];
    final bool valid = json['valid'];
    final JWT jwtToken = await _buildJWTToken(strToken);
    final token = AviabarToken(strToken, jwtToken, valid);

    return token;
  }

  String getIssuer() {
    return _jwtToken.issuer ?? "";
  }

  String get tokenString {
    return _strToken;
  }

  bool get valid {
    return _valid;
  }

  AviabarToken.empty() {}

}
