class AviabarUser {
  String name = "leer";
  late final int id;
  double balance=0;
  String cardId = "";
  bool isRegistered = false;
  bool isValid = false;

  AviabarUser.empty() {
    this.name="";
    this.id=0;
    this.isRegistered = false;
    this.isValid = false;
  }

  AviabarUser(int id, String username, double balance, String cardId, bool isRegistered) {
    this.name=username;
    this.balance = balance;
    this.cardId = cardId;
    this.id=id;
    this.isRegistered = isRegistered;
    this.isValid = true;
  }

  factory AviabarUser.fromJson(Map<String, dynamic> json) {
    var user = AviabarUser(json['id'], json['username'], json['balance'], json['cardId'], json['registered']);
    return user;
  }

  @override
  String toString() {
    String rep = "AviabarUser($id)(name=$name, isRegistered=$isRegistered, isValid=$isValid)";
    return rep;
  }

}