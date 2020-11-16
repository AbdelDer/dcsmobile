import 'package:flutter/cupertino.dart';

class Filter {
  String _filterName;
  String _filterAbbreviation;
  bool _filterValue = true;

  String get filterName => _filterName;

  set filterName(String value) {
    _filterName = value;
  }

  bool get filterValue => _filterValue;

  set filterValue(bool value) {
    _filterValue = value;
  }

  String get filterAbbreviation => _filterAbbreviation;

  set filterAbbreviation(String value) {
    _filterAbbreviation = value;
  }

  Filter({@required filterName, filterAbbreviation, filterValue})
      : _filterName = filterName,
        _filterAbbreviation = filterAbbreviation,
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

  toJson() => _filterAbbreviation;
}
