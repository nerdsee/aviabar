import 'package:aviabar/code/product.dart';
import 'package:intl/intl.dart';

class AviabarOrder {
  late int id;
  late DateTime orderDate;
  late AviabarProduct product;

  AviabarOrder.empty() {
    this.id = 0;
    this.orderDate = DateTime.now();
    this.product = new AviabarProduct.empty();
  }

  AviabarOrder(this.id, this.orderDate, this.product);

  factory AviabarOrder.fromJson(Map<String, dynamic> json) {
    var product = AviabarProduct.fromJson(json['product']);
    print("Product: $product");
    print("0");
    print("JSON $json");
    print("OD ${json['orderDate']}");

    var dateTimeString = json['orderDate'];
    print("1");
    DateTime orderDate = DateTime.parse(dateTimeString);
    print("2");

    var order = AviabarOrder(json['id'], orderDate, product);
    print("3");
    return order;
  }

  String getFormattedDate() {
    return DateFormat('dd.MM.yyyy').format(orderDate);
  }

}