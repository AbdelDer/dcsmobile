class Insurance {
  num _id;
  String _deviceID;
  String _InsuranceName;
  num _timestampStart;
  num _timestampEnd;

  Insurance(this._id, this._deviceID, this._InsuranceName,
      this._timestampStart, this._timestampEnd);

  Insurance.withoutID(this._deviceID, this._InsuranceName,
      this._timestampStart, this._timestampEnd);

  String get deviceID => _deviceID;

  set deviceID(String value) {
    _deviceID = value;
  }

  factory Insurance.fromJson(Map<dynamic, dynamic> json) {
    return Insurance(
        json["id"],
        json["deviceID"],
        json["insuranceName"],
        json["timestampStart"],
        json["timestampEnd"]);
  }

  Map<String, dynamic> toJson() {
    if (_id != null) {
      return {
        "id": _id,
        "deviceID": _deviceID,
        "timestampStart": _timestampStart,
        "timestampEnd": _timestampEnd,
        "insuranceName": _InsuranceName
      };
    }else {
      return {
        "deviceID": _deviceID,
        "timestampStart": _timestampStart,
        "timestampEnd": _timestampEnd,
        "insuranceName": _InsuranceName
      };
    }
  }

  num get timestampEnd => _timestampEnd;

  set timestampEnd(num value) {
    _timestampEnd = value;
  }

  num get timestampStart => _timestampStart;

  set timestampStart(num value) {
    _timestampStart = value;
  }

  String get insuranceName => _InsuranceName;

  set insuranceName(String value) {
    _InsuranceName = value;
  }
  num get id => _id;

  set id(num value) {
    _id = value;
  }
}
