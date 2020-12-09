import 'dart:core';

import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

class SummaryReport {
  double _speedAvg;
  int _parkingTimes;
  int _stops;
  double _odometerStart;
  double _odometerEnd;
  double _distance;
  double _speedMax;
  Duration _runningTimeSeconds;

  double get odometerStart => _odometerStart;

  double get odometerEnd => _odometerEnd;

  double get distance => _distance;

  double get speedMax => _speedMax;

  double get speedAvg => _speedAvg;

  int get parkingTimes => _parkingTimes;

  int get stops => _stops;

  String runningTime() {
    return format(_runningTimeSeconds);
  }

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  SummaryReport(this._parkingTimes, this._stops, this._speedAvg,
      this._odometerStart, this._odometerEnd,
      this._distance, this._speedMax, this._runningTimeSeconds);

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
        json['parkingTimes'],
        json['stops'],
        json['speedAvg'],
        json['odometerStart'],
        json['odometerEnd'],
        json['distance'],
        json['speedMax'],
        Duration(milliseconds: json['runningTime'] ?? 0)
    );
  }
}
