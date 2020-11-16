import 'package:flutter/cupertino.dart';

class Filter {
  String _filterName;
  bool _filterValue = true;


  String get filterName => _filterName;

  set filterName(String value) {
    _filterName = value;
  }

  bool get filterValue => _filterValue;

  set filterValue(bool value) {
    _filterValue = value;
  }

  Filter({@required filterName, filterValue})
      : _filterName = filterName,
        _filterValue = filterValue == null ? true : filterValue;

  @override
  String toString() {
    return "'$filterName' : $filterValue";
  }

// factory Filter.fromJson(Map<dynamic, dynamic> json) {
  //   return Filter(
  //     deviceID: json['deviceID'],
  //     vehicleModel: json['vehicleModel'],
  //   );
  // }

  Map<String, dynamic> toJson() =>
      {
        'filterName': _filterName,
        'value': _filterValue,
      };
}
