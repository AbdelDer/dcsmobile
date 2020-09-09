import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

import 'User.dart';

class DeviceList {
  String _accountID;
  String _deviceID;
  String _groupID;
  String _vehicleModel;
  double _latitude;
  double _longitude;
  num _timestamp;
  double _speedKPH;

  String get groupID => _groupID;

  String get accountID => _accountID;

  String get deviceID => _deviceID;

  String get vehicleModel => _vehicleModel;

  double get latitude => _latitude;

  double get longitude => _longitude;

  num get timestamp => _timestamp;

  double get speedKPH => _speedKPH;

  String get timestampAsString {
    final date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(date);
    return formatted;
  }

  Future<String> get address async {
    final coordinates = new Coordinates(latitude, longitude);
    final addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;
    return '${first.addressLine}';
  }

  DeviceList(
      {groupID,
      accountID,
      deviceID,
      vehicleModel,
      latitude,
      longitude,
      timestamp,
      speedKPH})
      : _groupID = groupID,
        _accountID = accountID,
        _deviceID = deviceID,
        _vehicleModel = vehicleModel,
        _latitude = latitude,
        _longitude = longitude,
        _timestamp = timestamp,
        _speedKPH = speedKPH;

  // ignore: missing_return
  /*factory DeviceList.fromJson(User user, List<dynamic> json) {
    user.devices ??= [];
    for (dynamic j in json) {
      user.devices.add(DeviceList(
          deviceID: j['deviceListID']['deviceID'],
          accountID: j['deviceListID']['accountID'],
          groupID: j['deviceListID']['groupID'],
          vehicleModel: j['vehicleModel']));
    }
  }*/

  factory DeviceList.fromJson(Map<String, dynamic> json) {
    return DeviceList(
        deviceID: json['deviceListID']['deviceID'],
        accountID: json['deviceListID']['accountID'],
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
