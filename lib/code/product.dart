import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aviabar/code/user.dart';

class AviabarProduct {
  int id;
  String name;
  double price;
  String logo;

  AviabarProduct(this.id, this.name, this.price, this.logo);

  factory AviabarProduct.fromJson(Map<String, dynamic> json) {
    var ap = AviabarProduct(json['id'], json['name'], json['price'], json['logo']);
    return ap;
  }
}
