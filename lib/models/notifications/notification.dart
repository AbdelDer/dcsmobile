import 'package:flutter/foundation.dart';

class Notification {
  String _deviceID;
  num _timestamp;
  String _type;
  String _message;

  Notification(
      {@required deviceID,
      @required timestamp,
      @required type,
      @required message})
      : this._deviceID = deviceID,
        this._timestamp = timestamp,
        this._type = type,
        this._message = message;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      deviceID: json['deviceID'],
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
}
