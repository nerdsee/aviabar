class AviabarProduct {
  late int id;
  late String name;
  late double price;
  late String logo;
  late bool _newproduct;

  AviabarProduct(this.id, this.name, this.price, this.logo, this._newproduct);

  AviabarProduct.empty() {
    id=0;
    name="";
    price = 0;
    logo = "";
    _newproduct = false;
  }

  factory AviabarProduct.fromJson(Map<String, dynamic> json) {
    var ap = AviabarProduct(json['id'], json['name'], json['price'], json['logo'], json['new']);
    return ap;
  }

  bool get newproduct {
    return _newproduct;
  }

}
