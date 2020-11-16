import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Notification {
  String _deviceID;
  String _vehicleModel;
  num _timestamp;
  String _type;
  String _message;

  Notification(
      {@required deviceID,
      @required vehicleModel,
      @required timestamp,
      @required type,
      @required message})
      : this._deviceID = deviceID,
        this._vehicleModel = vehicleModel,
        this._timestamp = timestamp,
        this._type = type,
        this._message = message;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      deviceID: json['deviceID'],
      vehicleModel: json['vehicleModel'],
      timestamp: json['timestamp'],
      type: json['type'],
      message: json['message'],
    );
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  num get timestamp => _timestamp;

  set timestamp(num value) {
    _timestamp = value;
  }

  String get deviceID => _deviceID;

  set deviceID(String value) {
    _deviceID = value;
  }

  String get vehicleModel => _vehicleModel;

  set vehicleModel(String value) {
    _vehicleModel = value;
  }

  String get timestampAsString {
    final date = new DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    final formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(date);
    return formatted;
  }

  String getAssetPath() {
    switch(type) {
      case "BATTERY" : return 'assets/alarm/battery&disconnect.png';
      case "BONNET" : return 'assets/alarm/bonnet.png';
      case "CRASH" : return 'assets/alarm/crash.png';
      case "DISCONNECT" : return 'assets/alarm/battery&disconnect.png';
      case "DRIVER" : return 'assets/alarm/driver.png';
      case "SPEED" : return 'assets/alarm/speed.png';
      case "MAXTEMP" : return 'assets/alarm/temp.png';
      case "MINTEMP" : return 'assets/alarm/temp.png';
      case "STARTUP" : return 'assets/alarm/startup.png';
      case "TOWING" : return 'assets/alarm/towing.png';
    }
  }
}
