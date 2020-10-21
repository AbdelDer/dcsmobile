import 'dart:core';

import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

class EventData {
  String _deviceID;
  String _vehicleModel;
  num _timestamp;
  double _latitude;
  double _longitude;
  double _altitude;
  double _speedKPH;
  String _simPhoneNumber;
  bool _late;

  String get deviceID => _deviceID;

  String get vehicleModel => _vehicleModel;

  num get timestamp => _timestamp;

  double get latitude => _latitude;

  double get longitude => _longitude;

  double get altitude => _altitude;

  double get speedKPH => _speedKPH;

  String get simPhoneNumber => _simPhoneNumber;

  bool get late => _late;

  String get timestampAsString {
    final date =
        new DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
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

  EventData(
      {deviceID,
      vehicleModel,
      timestamp,
      latitude,
      longitude,
      altitude,
      speedKPH,
      simPhoneNumber,
      late})
      : _deviceID = deviceID,
        _vehicleModel = vehicleModel,
        _timestamp = timestamp,
        _latitude = latitude,
        _longitude = longitude,
        _altitude = altitude,
        _speedKPH = speedKPH,
        _simPhoneNumber = simPhoneNumber,
        _late = late;

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
        deviceID: json['deviceID'],
        timestamp: json['timestamp'],
        vehicleModel: json['vehicleModel'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        altitude: json['altitude'],
        speedKPH: json['speedKPH'],
        simPhoneNumber: json['simPhoneNumber'],
        late: json['late']);
  }
}
