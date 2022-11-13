class PPResponse {
  late final int _id;
  late String _status;
  late String _payerId;
  late String _paymentId;
  late String _payerEmail;
  late String _payerFirstName;
  late String _payerLastName;
  double _amount = 0;

  double get amount {
    return _amount;
  }

  PPResponse(Map params) {
    try {
      _id = 0;
      _status = params["status"];
      _payerId = params["payerID"];
      _paymentId = params["paymentId"];
      _payerEmail = params["data"]["payer"]["payer_info"]["email"];
      _payerFirstName = params["data"]["payer"]["payer_info"]["first_name"];
      _payerLastName = params["data"]["payer"]["payer_info"]["last_name"];
    } catch (e) {
      print("PPR: $e");
    }
    try {
      String stramount = params["data"]["transactions"][0]["amount"]["total"];
      _amount = double.parse(stramount);
    } catch (e) {
      print("Amount not read: $e");
    }
  }

  Map toJson() {
    print("Serialize PPResponse to Maps");
    final data = <String, dynamic>{};
    data['id'] = _id;
    data['amount'] = _amount;
    data['status'] = _status;
    data['payerId'] = _payerId;
    data['paymentId'] = _paymentId;
    data['payerEmail'] = _payerEmail;
    data['payerFirstName'] = _payerFirstName;
    data['payerLastName'] = _payerLastName;
    print("done.");
    return data;
  }

  Map toJson2() => {
        'id': _id,
        //'amount': amount,
        'status': _status,
        'payerId': _payerId,
        'paymentId': _paymentId,
        'payerEmail': _payerEmail,
        'payerFirstName': _payerFirstName,
        'payerLastName': _payerLastName
      };

  @override
  String toString() {
    return "status: $_status - payer: $_payerEmail / $_payerFirstName $_payerLastName - paymentId: $_paymentId";
  }
}
