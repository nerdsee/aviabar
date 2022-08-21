import 'package:aviabar/code/user.dart';

class AviabarBackend {
  void getIDCard() {}

  Future<AviabarUser> getUser() async {
    AviabarUser user = AviabarUser.stoeve();

    return Future.delayed(Duration(seconds: 4), () => user);
  }



}