import 'DeviceList.dart';

class User {
  String _accountID;
  String _userID;
  String _password;
  List<DeviceList> devices;

  String get userID => _userID;
  String get accountID => _accountID;
  String get password => _password;

  User({userID, accountID, password}) : _userID = userID, _accountID = accountID, _password = password;
  

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID']['userID'],
      accountID: json['userID']['accountID'],
      password: json['password'],
    );
  }
}