import 'package:intl/intl.dart';

class AviabarUser {
  String name = "leer";
  String email = "leer";
  late final int id;
  double balance = 0;
  String cardId = "";
  bool isRegistered = false;

  AviabarUser.empty() {
    this.name = "";
    this.email = "";
    this.id = 0;
    this.isRegistered = false;
  }

  AviabarUser(int _id, String _username, String _email, double _balance, String _cardId, bool _isRegistered) {
    this.name = _username;
    this.email = _email;
    this.balance = _balance;
    this.cardId = _cardId;
    this.id = _id;
    this.isRegistered = _isRegistered;
  }

  getReadableBalance() {
    return NumberFormat("####0.00", "de_DE").format(balance);
  }

  factory AviabarUser.fromJson(Map<String, dynamic> json) {
    var user =
        AviabarUser(json['id'], json['username'], json['email'], json['balance'], json['cardId'], json['registered']);
    return user;
  }

  @override
  String toString() {
    String rep = "AviabarUser($id)(name=$name, email=$email, isRegistered=$isRegistered)";
    return rep;
  }

  Map toJson() => {
        'id': id,
        'username': name,
        'email': email,
      };

  void reduceBalance(double price) {
    balance = balance - price;
  }
}
