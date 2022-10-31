class PPResponse {
  late String status;
  late String payerId;
  late String paymentId;
  late String payerEmail;
  late String payerFirstName;
  late String payerLastName;
  double amount = 0;

  PPResponse(Map params) {
    try {
      status = params["status"];
      payerId = params["payerID"];
      paymentId = params["paymentId"];
      payerEmail = params["data"]["payer"]["payer_info"]["email"];
      payerFirstName = params["data"]["payer"]["payer_info"]["first_name"];
      payerLastName = params["data"]["payer"]["payer_info"]["last_name"];
    } catch (e) {
      print("PPR: $e");
    }
    try {
      String stramount = params["data"]["transactions"][0]["amount"]["total"];
      amount = double.parse(stramount);
    } catch (e) {
      print("Amount not read: $e");
    }

  }

  @override
  String toString() {
    return "status: $status - payer: $payerEmail / $payerFirstName $payerLastName - paymentId: $paymentId";
  }
}
