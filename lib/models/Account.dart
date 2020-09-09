import 'Device.dart';

class Account {
  String _accountID;
  String _password;
  List<Device> devices;

  String get accountID => _accountID;
  String get password => _password;

  Account({accountID, password}) : _accountID = accountID, _password = password;


  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountID: json['accountID'],
      password: json['password'],
    );
  }
}