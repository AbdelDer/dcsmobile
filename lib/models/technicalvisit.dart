class TechnicalVisit {
  num _id;
  String _deviceID;
  String _technicalVisitName;
  num _timestampStart;
  num _timestampEnd;

  TechnicalVisit(this._id, this._deviceID, this._technicalVisitName,
      this._timestampStart, this._timestampEnd);

  TechnicalVisit.withoutID(this._deviceID, this._technicalVisitName,
      this._timestampStart, this._timestampEnd);

  String get deviceID => _deviceID;

  set deviceID(String value) {
    _deviceID = value;
  }

  factory TechnicalVisit.fromJson(Map<dynamic, dynamic> json) {
    return TechnicalVisit(
        json["id"],
        json["deviceID"],
        json["technicalVisitName"],
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
        "technicalVisitName": _technicalVisitName
      };
    }else {
      return {
        "deviceID": _deviceID,
        "timestampStart": _timestampStart,
        "timestampEnd": _timestampEnd,
        "technicalVisitName": _technicalVisitName
      };
    }
  }

  String get drainingName => _technicalVisitName;

  set drainingName(String value) {
    _technicalVisitName = value;
  }

  num get timestampEnd => _timestampEnd;

  set timestampEnd(num value) {
    _timestampEnd = value;
  }

  num get timestampStart => _timestampStart;

  set timestampStart(num value) {
    _timestampStart = value;
  }

  String get technicalVisitName => _technicalVisitName;

  set technicalVisitName(String value) {
    _technicalVisitName = value;
  }
  num get id => _id;

  set id(num value) {
    _id = value;
  }
}
