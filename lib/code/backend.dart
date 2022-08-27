import 'package:aviabar/code/user.dart';

class AviabarBackend {
  void getIDCard() {}

  Future<AviabarUser> getUser() async {
    AviabarUser user = AviabarUser.stoeve();

    return Future.delayed(Duration(seconds: 4), () => user);
  }

  Future<List<AviabarProduct>> getProducts() {
    List<AviabarProduct> products = [];

    products.add(AviabarProduct(1,"Fritz Kola", 1.0, "black.png"));
    products.add(AviabarProduct(2,"Fritz Kola zuckerfrei", 1.0, "white.png"));
    products.add(AviabarProduct(3,"Fritz Limo Orange", 1.0, "yellow.png"));

    return Future.delayed(Duration(seconds: 2), () => products);
  }

}

class AviabarProduct {
  int id;
  String name;
  double price;
  String logo;

  AviabarProduct(this.id, this.name, this.price, this.logo);
}