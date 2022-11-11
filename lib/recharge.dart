import 'package:aviabar/code/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

import 'code/ppresponse.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({Key? key}) : super(key: key);

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Recharge Account"),
        ),
        body: Center(
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
              AviabarBackend().rechargeUser(response);
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

