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
  double _heading;
  double _speedKPH;
  String _simPhoneNumber;
  bool _late;
  int _parked;

  String get deviceID => _deviceID;

  String get vehicleModel => _vehicleModel;

  num get timestamp => _timestamp;

  double get latitude => _latitude;

  double get longitude => _longitude;

  double get altitude => _altitude;

  double get heading => _heading;

  double get speedKPH => _speedKPH;

  String get simPhoneNumber => _simPhoneNumber;

  bool get late => _late;

  int get parked => _parked;

  String get timestampAsString {
    final date =
        new DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    final formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(date);
    return formatted;
  }

  bool between(val1, val2) {
    if(this._heading > val1 && this._heading < val2) {
      return true;
    }
    return false;
  }

  String iconPath() {
    if(_late != null && _late) {
      return 'assets/icons/r_marker_blue.png';
    } else if(_parked != null && _parked == 1) {
      return 'assets/icons/marker_blue_parking';
    } else {
      if(_speedKPH < 3) {
        return 'assets/icons/stop_small.png';
      } else if(_speedKPH <= 60) {
        if(_heading == 0) {
          return 'assets/icons/marker_green.png';
        }else if(between(0, 90)) {
          return 'assets/icons/marker_green_ne.png';
        }else if(_heading == 90) {
          return 'assets/icons/marker_green_e.png';
        }else if(between(90, 180)) {
          return 'assets/icons/marker_green_se.png';
        }else if(_heading == 180) {
          return 'assets/icons/marker_green_s.png';
        }else if(between(180, 270)) {
          return 'assets/icons/marker_green_sw.png';
        }else if(_heading == 270){
          return 'assets/icons/marker_green_w.png';
        }else if(between(270, 360)) {
          return 'assets/icons/marker_green_nw.png';
        }else if(_heading == 360) {
          return 'assets/icons/marker_green_n.png';
        }
      } else if(_speedKPH < 100 && _speedKPH > 60) {
        if(_heading == 0) {
          return 'assets/icons/marker_grey.png';
        }else if(between(0, 90)) {
          return 'assets/icons/marker_grey_ne.png';
        }else if(_heading == 90) {
          return 'assets/icons/marker_grey_e.png';
        }else if(between(90, 180)) {
          return 'assets/icons/marker_grey_se.png';
        }else if(_heading == 180) {
          return 'assets/icons/marker_grey_s.png';
        }else if(between(180, 270)) {
          return 'assets/icons/marker_grey_sw.png';
        }else if(_heading == 270){
          return 'assets/icons/marker_grey_w.png';
        }else if(between(270, 360)) {
          return 'assets/icons/marker_grey_nw.png';
        }else if(_heading == 360) {
          return 'assets/icons/marker_grey_n.png';
        }
      } else {
        if(_heading == 0) {
          return 'assets/icons/marker_yellow.png';
        }else if(between(0, 90)) {
          return 'assets/icons/marker_yellow_ne.png';
        }else if(_heading == 90) {
          return 'assets/icons/marker_yellow_e.png';
        }else if(between(90, 180)) {
          return 'assets/icons/marker_yellow_se.png';
        }else if(_heading == 180) {
          return 'assets/icons/marker_yellow_s.png';
        }else if(between(180, 270)) {
          return 'assets/icons/marker_yellow_sw.png';
        }else if(_heading == 270){
          return 'assets/icons/marker_yellow_w.png';
        }else if(between(270, 360)) {
          return 'assets/icons/marker_yellow_nw.png';
        }else if(_heading == 360) {
          return 'assets/icons/marker_yellow_n.png';
        }
      }

    }
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
      heading,
      speedKPH,
      simPhoneNumber,
      late,
      parked})
      : _deviceID = deviceID,
        _vehicleModel = vehicleModel,
        _timestamp = timestamp,
        _latitude = latitude,
        _longitude = longitude,
        _altitude = altitude,
        _heading = heading ?? 0,
        _speedKPH = speedKPH,
        _simPhoneNumber = simPhoneNumber,
        _late = late,
        _parked = parked;

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
        deviceID: json['deviceID'],
        timestamp: json['timestamp'],
        vehicleModel: json['vehicleModel'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        altitude: json['altitude'],
        heading: json['heading'],
        speedKPH: json['speedKPH'],
        simPhoneNumber: json['simPhoneNumber'],
        late: json['late'],
        parked: json['parked']);
  }
}
