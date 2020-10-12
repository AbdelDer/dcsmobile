import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

import 'Account.dart';

class Device {
  String _accountID;
  String _deviceID;
  String _vehicleModel;
  double _latitude;
  double _longitude;
  num _timestamp;
  double _speedKPH;

  String get accountID => _accountID;

  String get deviceID => _deviceID;

  String get vehicleModel => _vehicleModel;

  double get latitude => _latitude;

  double get longitude => _longitude;

  num get timestamp => _timestamp;

  double get speedKPH => _speedKPH;

  String get timestampAsString {
    final date = new DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    final formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(date);
    return formatted;
  }

  Future<String> get address async {
    final coordinates = new Coordinates(latitude, longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;
    // print('${first.addressLine}');
    return '${first.addressLine}';
  }

  Device(
      {accountID,
      deviceID,
      vehicleModel,
      latitude,
      longitude,
      timestamp,
      speedKPH})
      : _accountID = accountID,
        _deviceID = deviceID,
        _vehicleModel = vehicleModel,
        _latitude = latitude,
        _longitude = longitude,
        _timestamp = timestamp,
        _speedKPH = speedKPH;

  // ignore: missing_return
  /*factory Device.fromJson(Account account, List<dynamic> json) {
    account.devices ??= [];
    for (dynamic j in json) {
      account.devices.add(Device(
          deviceID: j['deviceID']['deviceID'],
          accountID: j['deviceID']['accountID'],
          vehicleModel: j['vehicleModel']));
    }
  }*/

  factory Device.fromJson(Map<dynamic, dynamic> json) {
    return Device(
        deviceID: json['deviceID']['deviceID'],
        accountID: json['deviceID']['accountID'],
        vehicleModel: json['vehicleModel'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        timestamp: json['timestamp'],
        speedKPH: json['speedKPH']);
  }

  @override
  String toString() {
    // TODO: implement toString
    return _deviceID + ' ' + _vehicleModel;
  }
}
