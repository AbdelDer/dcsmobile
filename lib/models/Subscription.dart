import 'package:flutter/material.dart';

class Subscription {
  String _vehicleModel;
  String _deviceID;
  num _timeInSeconds;
  Color _color;

  String get vehicleModel => _vehicleModel;

  String get deviceID => _deviceID;

  num get days => Duration(seconds: _timeInSeconds).inDays;

  Color get color {
    if(days <= 0) {
      return Colors.red;
    } else if(days <= 30) {
      return Colors.deepOrange;
    } else {
      return Colors.green;
    }
  }

  Subscription({vehicleModel, deviceID, endDate, timeInSeconds})
      : _vehicleModel = vehicleModel,
        _deviceID = deviceID,
        _timeInSeconds = timeInSeconds;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
        deviceID: json['deviceID'],
        vehicleModel: json['vehicleModel'],
        timeInSeconds: json['remainingTime']);
  }
}
