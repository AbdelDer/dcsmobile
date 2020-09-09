import 'package:flutter/cupertino.dart';

class Report {
  String _deviceID;
  double _maxSpeed;
  double _avgSpeed;
  double _distance;
  double _runningTime;
  double _parkingTime;

  String get deviceID => _deviceID;

  double get maxSpeed => _maxSpeed;


  double get runningTime => _runningTime;

  double get parkingTime => _parkingTime;

  double get distance => _distance;

  double get avgSpeed => _avgSpeed;

  String get parkingTimeAsString {
    var d = Duration(minutes: _parkingTime.toInt());
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  List<String> get parkingTimeAsStringList {
    var d = Duration(minutes: _parkingTime.toInt());
    List<String> parts = d.toString().split(':');
    return parts;
  }

  String get runningTimeAsString {
    var d = Duration(minutes: _runningTime.toInt());
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  List<String> get runningTimeAsStringList {
    var d = Duration(minutes: _runningTime.toInt());
    List<String> parts = d.toString().split(':');
    return parts;
  }


  set deviceID(String value) {
    _deviceID = value;
  }

  Report({deviceID, maxSpeed, avgSpeed, distance, runningTime, parkingTime})
      : _deviceID = deviceID,
        _maxSpeed = maxSpeed,
        _avgSpeed = avgSpeed,
        _distance = distance,
        _runningTime = runningTime,
        _parkingTime = parkingTime;


  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      deviceID: json['deviceID'],
      maxSpeed: json['maxSpeed'],
      parkingTime: json['parkingTime'],
      runningTime: json['runningTime'],
      distance: json['distance'],
      avgSpeed: json['avgSpeed'],
    );
  }

  set maxSpeed(double value) {
    _maxSpeed = value;
  }

  set avgSpeed(double value) {
    _avgSpeed = value;
  }

  set distance(double value) {
    _distance = value;
  }

  set runningTime(double value) {
    _runningTime = value;
  }

  set parkingTime(double value) {
    _parkingTime = value;
  }
}
