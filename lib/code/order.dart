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

    String dateTimeString = json['orderDate'];
    DateTime orderDate = DateTime.parse(dateTimeString);

    var order = AviabarOrder(json['id'], orderDate, product);
    return order;
  }

  String getFormattedDate() {
    return DateFormat('dd.MM.yyyy – kk:mm').format(orderDate);
  }

}