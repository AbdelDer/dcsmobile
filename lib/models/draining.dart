class Draining {
  String _deviceID;
  String _drainingName;
  num _timestamp;
  double _kmStart;
  double _kmEnd;

  Draining(this._deviceID, this._drainingName, this._timestamp, this._kmStart,
      this._kmEnd);

  Draining.id(this._deviceID, this._timestamp);

  String get deviceID => _deviceID;

  set deviceID(String value) {
    _deviceID = value;
  }

  factory Draining.fromJson(Map<dynamic, dynamic> json) {
    return Draining(json["drainingID"]["deviceID"], json["drainingName"],
        json["drainingID"]["timestamp"], json["kmStart"], json["kmEnd"]);
  }

  Map<String, dynamic> toJson() => {
    "drainingID": {
      "deviceID": _deviceID,
      "timestamp" : _timestamp
    },
    "drainingName" : _drainingName,
    "kmStart" : _kmStart,
    "kmEnd" : _kmEnd
  };

  Map<String, dynamic> idToJson() => {
      "deviceID": _deviceID,
      "timestamp": _timestamp
  };

  String get drainingName => _drainingName;

  set drainingName(String value) {
    _drainingName = value;
  }

  num get timestamp => _timestamp;

  set timestamp(num value) {
    _timestamp = value;
  }

  double get kmStart => _kmStart;

  set kmStart(double value) {
    _kmStart = value;
  }

  double get kmEnd => _kmEnd;

  set kmEnd(double value) {
    _kmEnd = value;
  }
}
