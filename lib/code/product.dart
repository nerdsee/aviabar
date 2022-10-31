class AviabarProduct {
  late int id;
  late String name;
  late double price;
  late String logo;

  AviabarProduct(this.id, this.name, this.price, this.logo);

  AviabarProduct.empty() {
    id=0;
    name="";
    price = 0;
    logo = "";
  }

  factory AviabarProduct.fromJson(Map<String, dynamic> json) {
    var ap = AviabarProduct(json['id'], json['name'], json['price'], json['logo']);
    return ap;
  }
}
