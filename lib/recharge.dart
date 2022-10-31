import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

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
          child: TextButton(
              onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                            sandboxMode: true,
                            clientId:
                                "Ae4hjP3lezF1UcaxXCCMlYc1jrKtb1mQ-cygE2ZyFibZWmqxf2eHhF9hmP1xSyyS01_xBHFw5hRN3zIS",
                            secretKey:
                                "EKlG8pc5vsUd3HyWQ5aopwm43cuTkkKDa4vuzPjOpX1G2KKiqX-3e8CWJcB9V6OkyuRKUEUU3MVQIYfg",
                            returnURL: "https://samplesite.com/return",
                            cancelURL: "https://samplesite.com/cancel",
                            transactions: const [
                              {
                                "amount": {
                                  "total": '10',
                                  "currency": "EUR",
                                  "details": {"subtotal": '10', "shipping": '0', "shipping_discount": 0}
                                },
                                "description": "The payment transaction description.",
                                // "payment_options": {
                                //   "allowed_payment_method":
                                //       "INSTANT_FUNDING_SOURCE"
                                // },
                                "item_list": {
                                  "items": [
                                    {"name": "A demo product", "quantity": 1, "price": '10', "currency": "EUR"}
                                  ],

                                  // shipping address is not required though
                                  "shipping_address": {
                                    "recipient_name": "Jane Foster",
                                    "line1": "Travis County",
                                    "line2": "",
                                    "city": "Austin",
                                    "country_code": "US",
                                    "postal_code": "73301",
                                    "phone": "+00000000",
                                    "state": "Texas"
                                  },
                                }
                              }
                            ],
                            note: "Contact us for any questions on your order.",
                            onSuccess: (Map params) async {
                              print("onSuccess: $params");
                            },
                            onError: (error) {
                              print("onError: $error");
                            },
                            onCancel: (params) {
                              print('cancelled: $params');
                            }),
                      ),
                    )
                  },
              child: const Text("Make Payment")),
        ));
  }
}
