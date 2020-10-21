import 'dart:core';

import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

class SummaryReport {
  double _speedAvg;
  double _odometerStart;
  double _odometerEnd;
  double _distance;
  double _speedMax;
  Duration _runningTimeInMinutes;

  double get odometerStart => _odometerStart;

  double get odometerEnd => _odometerEnd;

  double get distance => _distance;

  double get speedMax => _speedMax;

  double get speedAvg => _speedAvg;

  String runningTime() {
    return '${_runningTimeInMinutes.inHours}:${_runningTimeInMinutes.inMinutes.remainder(60)}';
  }

  SummaryReport(this._speedAvg, this._odometerStart, this._odometerEnd,
      this._distance, this._speedMax, this._runningTimeInMinutes);

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
      json['speedAvg'],
      json['odometerStart'],
      json['odometerEnd'],
      json['distance'],
      json['speedMax'],
      Duration(minutes: json['runningTime'] ?? 0)
    );
  }
}
