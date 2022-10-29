import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aviabar/code/user.dart';

class AviabarProduct {
  late int id;
  late String name;
  late double price;
  late String logo;

  AviabarProduct(this.id, this.name, this.price, this.logo);

  AviabarProduct.empty() {
    this.id=0;
    this.name="";
    this.price = 0;
    this.logo = "";
  }

  factory AviabarProduct.fromJson(Map<String, dynamic> json) {
    var ap = AviabarProduct(json['id'], json['name'], json['price'], json['logo']);
    return ap;
  }
}
