import 'package:flutter/material.dart';

class Subscription {
  String _vehicleModel;
  String _deviceID;
  num _startDate;
  num _endDate;
  Color _color;

  String get vehicleModel => _vehicleModel;

  String get deviceID => _deviceID;

  num get startDate => _startDate;

  num get endDate => _endDate;

  Color get color {
    if(subscriptionTime <= 0) {
      return Colors.red;
    } else if(subscriptionTime <= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  int get subscriptionTime {
    final end = new DateTime.fromMillisecondsSinceEpoch(endDate.toInt() * 1000);
    final subscriptionTime = end.difference(DateTime.now());
    return subscriptionTime.inDays;
  }

  Subscription({vehicleModel, deviceID, endDate, startDate})
      : _vehicleModel = vehicleModel,
        _deviceID = deviceID,
        _startDate = startDate,
        _endDate = endDate;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
        deviceID: json['deviceID'],
        vehicleModel: json['vehicleModel'],
        endDate: json['endDate'],
        startDate: json['startDate']);
  }
}
