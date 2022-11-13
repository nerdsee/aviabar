import 'package:aviabar/code/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:intl/intl.dart';

import 'code/ppresponse.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({Key? key}) : super(key: key);

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  double rechargedAmount = 0;
  bool recharged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Recharge Account"),
        ),
        body: recharged
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 250,
                        alignment: Alignment.center,
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.cyan[900]),
                              children: [
                                TextSpan(
                                  text: "You succesfully recharged ",
                                ),
                                TextSpan(
                                    text: "${NumberFormat("####0.00", "de_DE").format(rechargedAmount)} €",
                                    style: TextStyle(color: Colors.cyan[700])),
                                TextSpan(
                                  text: " to your account.",
                                ),
                              ],
                            ))),
                    SizedBox(height: 30),
                    Container(
                        width: 250,
                        alignment: Alignment.center,
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan[900]),
                              children: [
                                TextSpan(
                                  text: "Your balance is ",
                                ),
                                TextSpan(
                                    text: "${AviabarBackend().currentUser.getReadableBalance()} EUR",
                                    style: TextStyle(
                                        color: AviabarBackend().currentUser.balance < 0
                                            ? Colors.red[900]
                                            : Colors.cyan[700])),
                              ],
                            ))),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(100, 100),
                          shape: CircleBorder(side: BorderSide(color: Colors.orange[900] as Color, width: 5)),
                          backgroundColor: Colors.orange[700]),
                      child: Icon(Icons.arrow_back, size: 50),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
                    recharge(10);
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(120, 120),
                      shape: const CircleBorder(side: BorderSide(color: Color(0xFF0097A7), width: 5)),
                      primary: Colors.cyan[700]),
                  child: Text(
                    "10 EUR",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    recharge(20);
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(120, 120),
                      shape: const CircleBorder(side: BorderSide(color: Color(0xFF0097A7), width: 5)),
                      primary: Colors.cyan[800]),
                  child: Text(
                    "20 EUR",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    recharge(50);
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(120, 120),
                      shape: const CircleBorder(side: BorderSide(color: Color(0xFF0097A7), width: 5)),
                      primary: Colors.cyan[900]),
                  child: Text(
                    "50 EUR",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ])));
  }

  void recharge(double amount) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: true,
            clientId: "Ae4hjP3lezF1UcaxXCCMlYc1jrKtb1mQ-cygE2ZyFibZWmqxf2eHhF9hmP1xSyyS01_xBHFw5hRN3zIS",
            secretKey: "EKlG8pc5vsUd3HyWQ5aopwm43cuTkkKDa4vuzPjOpX1G2KKiqX-3e8CWJcB9V6OkyuRKUEUU3MVQIYfg",
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": amount,
                  "currency": "EUR",
                  "details": {"subtotal": amount, "shipping": '0', "shipping_discount": 0}
                },
                "description": "AVIABAR Credits.",
                "item_list": {
                  "items": [
                    {"name": "AVIABAR Credits", "quantity": 1, "price": amount, "currency": "EUR"}
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              var response = PPResponse(params);
              print("onSuccess: $params");
              print("Response: $response");
              await AviabarBackend().rechargeUser(response);
              setState(() {
                rechargedAmount = response.amount;
                recharged = true;
              });
            },
            onError: (error) {
              print("onError: $error");
            },
            onCancel: (params) {
              print('cancelled: $params');
            }),
      ),
    );
  }
}
